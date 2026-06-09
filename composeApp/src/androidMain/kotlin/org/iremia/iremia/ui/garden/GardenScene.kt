package org.iremia.iremia.ui.garden

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import org.iremia.iremia.ui.theme.IremiaColors
import kotlin.math.roundToInt

// =============================================================================
// Isometric "Forest"-style garden (prototype).
//
// Fakes a 3-D plot with a 2.5-D isometric projection on a Compose Canvas — no 3-D
// engine. Each tile is one day of the month; days with entries grow a plant (taller
// and fuller with more entries), empty days get scattered grass, bushes and flowers.
// Trees vary in color (several foliage palettes + occasional blossom) and the ground
// has light grass tufts on top and an earthy texture on the front walls.
// =============================================================================

private val GrassLight = Color(0xFF8FCB9B)
private val GrassDark = Color(0xFF79BE8B)
private val GrassEdge = Color(0xFF5FA877)
private val SoilLeft = Color(0xFF5E4A38)
private val SoilRight = Color(0xFF7A5C46)
private val FlowerColors = listOf(Color(0xFFE5A3B8), Color(0xFFF6C453), Color(0xFFB7E4C7), Color(0xFFC9A7EB))

/** A foliage color set so trees are not all the same green. */
private data class Foliage(val dark: Color, val mid: Color, val light: Color, val blossom: Color? = null)

private val FoliagePalettes = listOf(
    Foliage(Color(0xFF0F6E56), Color(0xFF2E9576), Color(0xFF7FC0A8)), // brand garden
    Foliage(Color(0xFF3E7D3A), Color(0xFF5BA152), Color(0xFF9ED36B)), // fresh green
    Foliage(Color(0xFF2E6B57), Color(0xFF3E9576), Color(0xFF8FD0B6)), // teal green
    Foliage(Color(0xFF5C7A1E), Color(0xFF87A62F), Color(0xFFC2D257)), // olive
    Foliage(Color(0xFF1F6E4C), Color(0xFF3E9576), Color(0xFFBfE3C8), blossom = Color(0xFFE5A3B8)), // blossom
    Foliage(Color(0xFF235C46), Color(0xFF2E8466), Color(0xFF6FB89A)), // deep pine
)

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

/**
 * Draws an isometric garden for one month.
 *
 * @param days Entry counts per day (index 0 = first day), one tile each.
 * @param columns / [rows] Plot dimensions (columns * rows tiles).
 * @param interactive Whether tiles respond to taps via [onTileTap].
 * @param selectedTile Tile index to highlight, or null.
 * @param onTileTap Invoked with the tapped tile index.
 */
@Composable
fun GardenScene(
    days: List<Int>,
    modifier: Modifier = Modifier,
    columns: Int = 5,
    rows: Int = 5,
    interactive: Boolean = false,
    selectedTile: Int? = null,
    onTileTap: (Int) -> Unit = {},
) {
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
                drawDiamond(c, l.tileW, l.tileH, if ((col + row) % 2 == 0) GrassLight else GrassDark)
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
        val tiles = buildList {
            for (row in 0 until rows) for (col in 0 until columns) add(col to row)
        }.sortedBy { (col, row) -> col + row }

        tiles.forEach { (col, row) ->
            val index = row * columns + col
            val base = l.center(col, row)
            when (val count = days.getOrElse(index) { 0 }) {
                0 -> drawDecoration(base, l.tileW, index)
                else -> {
                    drawShadow(base, l.tileW)
                    val foliage = FoliagePalettes[(index * 5 + 2) % FoliagePalettes.size]
                    if (index % 2 == 0) drawPine(base, l.tileW, scaleFor(count), foliage)
                    else drawBroadleaf(base, l.tileW, scaleFor(count), foliage, index)
                }
            }
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

/** A simple flat 2-D layered-cone pine in the given [foliage] palette. */
private fun DrawScope.drawPine(base: Offset, tileW: Float, scale: Float, foliage: Foliage) {
    val trunkW = tileW * 0.06f * scale
    val trunkH = tileW * 0.12f * scale
    drawRect(IremiaColors.Branch, Offset(base.x - trunkW / 2f, base.y - trunkH), Size(trunkW, trunkH))

    val tierW = tileW * 0.52f * scale
    val tierH = tileW * 0.30f * scale
    var baseY = base.y - trunkH
    for (tier in 0 until 3) {
        val w = tierW * (1f - tier * 0.18f)
        val apexY = baseY - tierH
        val apex = Offset(base.x, apexY)
        val baseLeft = Offset(base.x - w / 2f, baseY)
        val baseRight = Offset(base.x + w / 2f, baseY)
        drawPath(tri(apex, baseRight, baseLeft), foliage.dark)
        // Flat left highlight wedge.
        drawPath(tri(apex, baseLeft, Offset(base.x - w / 6f, baseY)), foliage.mid)
        baseY = apexY + tierH * 0.38f
    }
}

/** A simple flat 2-D broadleaf tree built from solid foliage circles. */
private fun DrawScope.drawBroadleaf(base: Offset, tileW: Float, scale: Float, foliage: Foliage, index: Int) {
    val trunkW = tileW * 0.07f * scale
    val trunkH = tileW * 0.16f * scale
    drawRect(IremiaColors.Branch, Offset(base.x - trunkW / 2f, base.y - trunkH), Size(trunkW, trunkH))

    val r = tileW * 0.24f * scale
    val crown = base.copy(y = base.y - trunkH - r * 0.5f)
    drawCircle(foliage.dark, r, crown)
    drawCircle(foliage.dark, r * 0.8f, crown + Offset(-r * 0.7f, r * 0.1f))
    drawCircle(foliage.dark, r * 0.8f, crown + Offset(r * 0.7f, r * 0.1f))
    drawCircle(foliage.mid, r * 0.85f, crown + Offset(-r * 0.25f, -r * 0.45f))
    drawCircle(foliage.light.copy(alpha = 0.85f), r * 0.35f, crown + Offset(-r * 0.45f, -r * 0.55f))

    // Occasional blossom dots.
    foliage.blossom?.let { blossom ->
        val spots = listOf(Offset(-r * 0.4f, -r * 0.1f), Offset(r * 0.45f, -r * 0.05f), Offset(0f, -r * 0.6f), Offset(r * 0.1f, r * 0.2f))
        spots.forEachIndexed { i, off ->
            if ((index + i) % 2 == 0) drawCircle(blossom, r * 0.12f, crown + off)
        }
    }
}

/** Ambient decoration for an empty day: a small bush or a flower (deterministic). */
private fun DrawScope.drawDecoration(base: Offset, tileW: Float, index: Int) {
    when ((index * 31 + 7) % 10) {
        in 0..2 -> {
            val color = FlowerColors[index % FlowerColors.size]
            drawRect(
                IremiaColors.Garden500,
                Offset(base.x - tileW * 0.012f, base.y - tileW * 0.14f),
                Size(tileW * 0.024f, tileW * 0.14f),
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

private fun tri(a: Offset, b: Offset, c: Offset): Path = Path().apply {
    moveTo(a.x, a.y)
    lineTo(b.x, b.y)
    lineTo(c.x, c.y)
    close()
}

private fun quad(a: Offset, b: Offset, c: Offset, d: Offset): Path = Path().apply {
    moveTo(a.x, a.y)
    lineTo(b.x, b.y)
    lineTo(c.x, c.y)
    lineTo(d.x, d.y)
    close()
}
