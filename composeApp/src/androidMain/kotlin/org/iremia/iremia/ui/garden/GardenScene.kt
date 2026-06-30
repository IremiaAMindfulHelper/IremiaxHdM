package org.iremia.iremia.ui.garden

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.EaseInOutCubic
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.domain.garden.GardenTile
import org.iremia.iremia.domain.garden.PlantType
import org.iremia.library.SharedRes
import io.github.alexzhirkevich.compottie.LottieCompositionSpec
import io.github.alexzhirkevich.compottie.rememberLottieComposition
import io.github.alexzhirkevich.compottie.rememberLottiePainter
import io.github.alexzhirkevich.compottie.DotLottie
import kotlin.math.roundToInt

// =============================================================================
// Isometric "Forest"-style garden.
//
// Fakes a 3-D plot with a 2.5-D isometric projection on a Compose Canvas.
// Tiles can hold PlantType sprites, or procedural bushes and flowers if empty.
// Support zoom-in, lottie growth, and crossfade planting animations.
// =============================================================================

// NOTE: A single uniform grass tone for every tile so the top surface reads as
// one seamless meadow instead of a two-tone checkerboard.
private val GrassTop = Color(0xFF8FCB9B)
private val GrassEdge = Color(0xFF5FA877)
private val SoilLeft = Color(0xFF5E4A38)
private val SoilRight = Color(0xFF7A5C46)
private val FlowerColors = listOf(Color(0xFFE5A3B8), Color(0xFFF6C453), Color(0xFFB7E4C7), Color(0xFFC9A7EB))

/** Resolved pixel geometry of the plot for a given canvas size. */
private data class GardenLayout(
    val originX: Float,
    val originY: Float,
    val tileW: Float,
    val tileH: Float,
    val depth: Float,
)

private fun layoutFor(width: Float, columns: Int, rows: Int): GardenLayout {
    val margin = width * 0.06f
    val tileW = (width - 2 * margin) * 2f / (columns + rows)
    val tileH = tileW / 2f
    val treeHeadroom = tileW * 0.95f // room above the top tile for the tallest tree
    return GardenLayout(
        originX = width / 2f,
        originY = treeHeadroom + tileH / 2f,
        tileW = tileW,
        tileH = tileH,
        depth = tileH * 0.7f,
    )
}

private fun GardenLayout.center(col: Int, row: Int) = Offset(
    x = originX + (col - row) * (tileW / 2f),
    y = originY + (col + row) * (tileH / 2f),
)

/** Reverse projection: which tile index a tap landed on, or null if outside the plot. */
private fun GardenLayout.tileAt(p: Offset, columns: Int, rows: Int): Int? {
    val a = (p.x - originX) / (tileW / 2f) // col - row
    val b = (p.y - originY) / (tileH / 2f) // col + row
    val col = ((b + a) / 2f).roundToInt()
    val row = ((b - a) / 2f).roundToInt()
    return if (col in 0 until columns && row in 0 until rows) row * columns + col else null
}

private fun lerp(start: Float, stop: Float, fraction: Float): Float {
    return start + fraction * (stop - start)
}

/**
 * Draws an isometric garden with optional planting animations.
 *
 * @param tiles Grid tile states, holding PlantType sprites if occupied.
 * @param columns / [rows] Plot dimensions (columns * rows tiles).
 * @param interactive Whether tiles respond to taps via [onTileTap].
 * @param selectedTile Tile index to highlight, or null.
 * @param onTileTap Invoked with the tapped tile index.
 * @param newlyPlantedTileIndex Index of a tile that was just planted to animate growth.
 * @param onAnimationFinished Callback when the planting animation completes.
 */
@Composable
fun GardenScene(
    tiles: List<GardenTile>,
    modifier: Modifier = Modifier,
    columns: Int = 5,
    rows: Int = 5,
    interactive: Boolean = false,
    selectedTile: Int? = null,
    onTileTap: (Int) -> Unit = {},
    newlyPlantedTileIndex: Int? = null,
    onAnimationFinished: () -> Unit = {},
) {
    val context = LocalContext.current

    // Pre-load painters for all PlantType enum variants using moko-resources
    val plantPainters = PlantType.entries.associateWith { plantType ->
        painterResource(id = plantType.image.drawableResId)
    }

    // Load growth animations from moko files
    val plantGrowBytes = remember {
        context.resources.openRawResource(SharedRes.files.animated_plant_loader_lottie.rawResId).use { it.readBytes() }
    }
    val treeGrowBytes = remember {
        context.resources.openRawResource(SharedRes.files.tree_growth_without_background_lottie.rawResId).use { it.readBytes() }
    }

    val plantComposition by rememberLottieComposition {
        LottieCompositionSpec.DotLottie(plantGrowBytes)
    }
    val treeComposition by rememberLottieComposition {
        LottieCompositionSpec.DotLottie(treeGrowBytes)
    }

    // Animation progress states
    val zoomProgress = remember { Animatable(0.0f) }
    val lottieProgress = remember { Animatable(0.0f) }
    val crossfadeAlpha = remember { Animatable(0.0f) }

    val treeLottiePainter = rememberLottiePainter(
        composition = treeComposition,
        progress = { lottieProgress.value }
    )
    val plantLottiePainter = rememberLottiePainter(
        composition = plantComposition,
        progress = { lottieProgress.value }
    )

    LaunchedEffect(newlyPlantedTileIndex) {
        if (newlyPlantedTileIndex != null) {
            lottieProgress.snapTo(0.0f)
            crossfadeAlpha.snapTo(0.0f)

            // Step 1: Zoom in (800ms)
            zoomProgress.animateTo(
                targetValue = 1.0f,
                animationSpec = tween(durationMillis = 800, easing = EaseInOutCubic)
            )

            // Step 2: Play growth animation (1800ms)
            lottieProgress.animateTo(
                targetValue = 1.0f,
                animationSpec = tween(durationMillis = 1800, easing = LinearEasing)
            )

            // Step 3: Crossfade (400ms)
            crossfadeAlpha.animateTo(
                targetValue = 1.0f,
                animationSpec = tween(durationMillis = 400, easing = EaseInOutCubic)
            )

            // Step 4: Zoom out (800ms)
            zoomProgress.animateTo(
                targetValue = 0.0f,
                animationSpec = tween(durationMillis = 800, easing = EaseInOutCubic)
            )

            // Finished!
            onAnimationFinished()
        }
    }

    val tap = if (interactive) {
        Modifier.pointerInput(columns, rows) {
            detectTapGestures { offset ->
                layoutFor(size.width.toFloat(), columns, rows)
                    .tileAt(offset, columns, rows)
                    ?.let(onTileTap)
            }
        }
    } else {
        Modifier
    }

    Canvas(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(1.35f)
            .then(tap),
    ) {
        val l = layoutFor(size.width, columns, rows)

        val targetCenter = if (newlyPlantedTileIndex != null) {
            val col = newlyPlantedTileIndex % columns
            val row = newlyPlantedTileIndex / columns
            l.center(col, row)
        } else {
            Offset.Zero
        }

        val drawBlock: DrawScope.() -> Unit = {
            // --- Raised soil walls with an earthy texture ---
            val east = l.center(columns - 1, 0) + Offset(l.tileW / 2f, 0f)
            val south = l.center(columns - 1, rows - 1) + Offset(0f, l.tileH / 2f)
            val west = l.center(0, rows - 1) + Offset(-l.tileW / 2f, 0f)
            val down = Offset(0f, l.depth)
            drawPath(quad(west, south, south + down, west + down), SoilLeft)
            drawPath(quad(south, east, east + down, south + down), SoilRight)
            drawSoilTexture(west, south, east, down)

            // --- Grass top faces with light tufts ---
            for (row in 0 until rows) {
                for (col in 0 until columns) {
                    val c = l.center(col, row)
                    drawDiamond(c, l.tileW, l.tileH, GrassTop)
                    drawGrassTufts(c, l.tileW, l.tileH, row * columns + col)
                }
            }

            // --- Selection highlight ---
            if (selectedTile != null) {
                val col = selectedTile % columns
                val row = selectedTile / columns
                if (row < rows) {
                    val path = diamondPath(l.center(col, row), l.tileW, l.tileH)
                    drawPath(path, IremiaColors.Teal100.copy(alpha = 0.55f))
                    drawPath(path, IremiaColors.Teal700, style = Stroke(width = 2.5f))
                }
            }

            // --- Plants & decorations, back-to-front ---
            val gridOrder = buildList {
                for (row in 0 until rows) for (col in 0 until columns) add(col to row)
            }.sortedBy { (col, row) -> col + row }

            gridOrder.forEach { (col, row) ->
                val index = row * columns + col
                val base = l.center(col, row)
                val tile = tiles.getOrNull(index)
                val plantType = tile?.plantType

                if (plantType == null) {
                    drawDecoration(base, l.tileW, index)
                } else if (index == newlyPlantedTileIndex) {
                    drawShadow(base, l.tileW)

                    val activeLottiePainter = if (plantType.isTree) treeLottiePainter else plantLottiePainter
                    val count = tile.entryCount
                    val scale = scaleFor(count)
                    val spriteWidth = l.tileW * scale

                    // 1. Draw Lottie growth animation (fading out during crossfade)
                    if (crossfadeAlpha.value < 1.0f) {
                        val lottieAspect = activeLottiePainter.intrinsicSize.height / activeLottiePainter.intrinsicSize.width
                        val lottieHeight = spriteWidth * lottieAspect
                        val lottieLeft = base.x - spriteWidth / 2f
                        val lottieTop = (base.y + l.tileH / 2f) - lottieHeight

                        translate(lottieLeft, lottieTop) {
                            with(activeLottiePainter) {
                                draw(
                                    size = Size(spriteWidth, lottieHeight),
                                    alpha = 1.0f - crossfadeAlpha.value
                                )
                            }
                        }
                    }

                    // 2. Draw static sprite (fading in during crossfade)
                    if (crossfadeAlpha.value > 0.0f) {
                        val painter = plantPainters[plantType]
                        if (painter != null) {
                            val staticAspect = painter.intrinsicSize.height / painter.intrinsicSize.width
                            val staticHeight = spriteWidth * staticAspect
                            val staticLeft = base.x - spriteWidth / 2f
                            val staticTop = (base.y + l.tileH / 2f) - staticHeight

                            translate(staticLeft, staticTop) {
                                with(painter) {
                                    draw(
                                        size = Size(spriteWidth, staticHeight),
                                        alpha = crossfadeAlpha.value
                                    )
                                }
                            }
                        }
                    }
                } else {
                    drawShadow(base, l.tileW)
                    val painter = plantPainters[plantType]
                    if (painter != null) {
                        val count = tile.entryCount
                        val scale = scaleFor(count)
                        val spriteWidth = l.tileW * scale
                        val aspect = painter.intrinsicSize.height / painter.intrinsicSize.width
                        val spriteHeight = spriteWidth * aspect

                        val left = base.x - spriteWidth / 2f
                        val top = (base.y + l.tileH / 2f) - spriteHeight

                        translate(left, top) {
                            with(painter) {
                                draw(size = Size(spriteWidth, spriteHeight))
                            }
                        }
                    }
                }
            }
        }

        // Apply scale/translate transformations if zooming
        if (zoomProgress.value > 0.0f && newlyPlantedTileIndex != null) {
            val scaleVal = lerp(1.0f, 1.8f, zoomProgress.value)
            val canvasCenterX = size.width / 2f
            val canvasCenterY = size.height / 2f

            val neededOffsetX = canvasCenterX - targetCenter.x
            val neededOffsetY = canvasCenterY - targetCenter.y

            val currentOffsetX = lerp(0f, neededOffsetX, zoomProgress.value)
            val currentOffsetY = lerp(0f, neededOffsetY, zoomProgress.value)

            translate(currentOffsetX, currentOffsetY) {
                scale(scaleVal, pivot = targetCenter) {
                    drawBlock()
                }
            }
        } else {
            drawBlock()
        }
    }
}

private fun scaleFor(count: Int): Float = when (count) {
    1 -> 0.8f
    2 -> 1.0f
    3 -> 1.15f
    else -> 1.3f
}

private fun diamondPath(c: Offset, w: Float, h: Float): Path = Path().apply {
    moveTo(c.x, c.y - h / 2f)
    lineTo(c.x + w / 2f, c.y)
    lineTo(c.x, c.y + h / 2f)
    lineTo(c.x - w / 2f, c.y)
    close()
}

private fun DrawScope.drawDiamond(c: Offset, w: Float, h: Float, fill: Color) {
    val path = diamondPath(c, w, h)
    drawPath(path, fill)
    drawPath(path, GrassEdge.copy(alpha = 0.45f), style = Stroke(width = 1f))
}

/** A few curved grass blades on a tile for a meadow-like surface. */
private fun DrawScope.drawGrassTufts(c: Offset, tileW: Float, tileH: Float, index: Int) {
    val blade = tileH * 0.5f
    val spots = listOf(
        Offset(-tileW * 0.14f, tileH * 0.06f),
        Offset(tileW * 0.12f, -tileH * 0.05f),
        Offset(tileW * 0.02f, tileH * 0.13f),
    )
    spots.forEachIndexed { i, off ->
        if ((index + i) % 3 != 0) {
            val p = c + off
            val dir = if ((index + i) % 2 == 0) 1f else -1f
            drawBlade(p, blade, dir * 0.4f, GrassEdge)
            drawBlade(p + Offset(tileW * 0.035f, 0f), blade * 0.8f, -dir * 0.35f, GrassEdge.copy(alpha = 0.8f))
        }
    }
}

/** One curved, rounded grass blade from [base], curving sideways by [bend]. */
private fun DrawScope.drawBlade(base: Offset, length: Float, bend: Float, color: Color) {
    val tip = base + Offset(bend * length, -length)
    val control = base + Offset(bend * length * 1.6f, -length * 0.55f)
    val path = Path().apply {
        moveTo(base.x, base.y)
        quadraticBezierTo(control.x, control.y, tip.x, tip.y)
    }
    drawPath(path, color, style = Stroke(width = 2.4f, cap = StrokeCap.Round))
}

/** Strata lines and scattered pebbles on the two front soil walls. */
private fun DrawScope.drawSoilTexture(west: Offset, south: Offset, east: Offset, down: Offset) {
    for (f in listOf(0.42f, 0.72f)) {
        val o = Offset(0f, down.y * f)
        drawLine(Color.Black.copy(alpha = 0.08f), west + o, south + o, strokeWidth = 1f)
        drawLine(Color.Black.copy(alpha = 0.08f), south + o, east + o, strokeWidth = 1f)
    }
    fun lerp(a: Offset, b: Offset, t: Float) = a + (b - a) * t
    val pebble = down.y * 0.12f
    listOf(0.2f to 0.35f, 0.55f to 0.6f, 0.8f to 0.3f).forEach { (t, s) ->
        val pl = lerp(west, south, t) + Offset(0f, down.y * s)
        drawOval(Color.Black.copy(alpha = 0.10f), Offset(pl.x - pebble, pl.y - pebble / 2f), Size(pebble * 2f, pebble))
        val pr = lerp(south, east, t) + Offset(0f, down.y * s)
        drawOval(Color.White.copy(alpha = 0.06f), Offset(pr.x - pebble, pr.y - pebble / 2f), Size(pebble * 2f, pebble))
    }
}

/** Soft contact shadow grounding a plant on its tile. */
private fun DrawScope.drawShadow(base: Offset, tileW: Float) {
    drawOval(
        color = Color.Black.copy(alpha = 0.13f),
        topLeft = Offset(base.x - tileW * 0.26f, base.y - tileW * 0.05f),
        size = Size(tileW * 0.52f, tileW * 0.2f),
    )
}

/** Ambient decoration for an empty day: a small bush or a flower (deterministic). */
private fun DrawScope.drawDecoration(base: Offset, tileW: Float, index: Int) {
    when ((index * 31 + 7) % 10) {
        in 0..2 -> {
            val color = FlowerColors[index % FlowerColors.size]
            drawPath(
                Path().apply {
                    moveTo(base.x - tileW * 0.012f, base.y)
                    lineTo(base.x - tileW * 0.012f, base.y - tileW * 0.14f)
                    lineTo(base.x + tileW * 0.012f, base.y - tileW * 0.14f)
                    lineTo(base.x + tileW * 0.012f, base.y)
                    close()
                },
                IremiaColors.Garden500
            )
            drawCircle(color, tileW * 0.05f, base + Offset(0f, -tileW * 0.16f))
        }
        in 3..4 -> {
            drawCircle(IremiaColors.Garden500, tileW * 0.1f, base + Offset(0f, -tileW * 0.05f))
            drawCircle(IremiaColors.Garden500, tileW * 0.08f, base + Offset(-tileW * 0.1f, -tileW * 0.02f))
            drawCircle(IremiaColors.Garden300, tileW * 0.06f, base + Offset(tileW * 0.08f, -tileW * 0.06f))
        }
        else -> Unit
    }
}

private fun quad(a: Offset, b: Offset, c: Offset, d: Offset): Path = Path().apply {
    moveTo(a.x, a.y)
    lineTo(b.x, b.y)
    lineTo(c.x, c.y)
    lineTo(d.x, d.y)
    close()
}
