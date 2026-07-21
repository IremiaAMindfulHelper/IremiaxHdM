package org.iremia.iremia.ui.garden

import android.content.Context
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import org.iremia.iremia.domain.garden.LottieAsset
import io.github.alexzhirkevich.compottie.LottieCompositionSpec
import io.github.alexzhirkevich.compottie.rememberLottieComposition
import io.github.alexzhirkevich.compottie.rememberLottiePainter
import io.github.alexzhirkevich.compottie.DotLottie

/**
 * Configuration for an ambient animation path and visual scale.
 */
data class AmbientConfig(
    val asset: LottieAsset,
    val weight: Int,
    val startX: Float,      // relative to screen width
    val startY: Float,      // relative to screen height
    val endX: Float,        // relative to screen width
    val endY: Float,        // relative to screen height
    val durationMillis: Int,
    val scale: Float,       // size multiplier relative to screen width
)

/**
 * Weighted pool of ambient surprise animations.
 */
// All ambient animations share the same weight, so each is equally likely.
private const val AMBIENT_WEIGHT = 10

val AmbientConfigs = listOf(
    // Falling green leaves (top -> bottom, centered)
    AmbientConfig(
        asset = LottieAsset.LEAVES,
        weight = AMBIENT_WEIGHT,
        startX = 0.5f, startY = -0.2f,
        endX = 0.5f, endY = 1.2f,
        durationMillis = 5500,
        scale = 1.6f
    ),
    // Single drifting leaf (gentle top -> bottom)
    AmbientConfig(
        asset = LottieAsset.LEAF,
        weight = AMBIENT_WEIGHT,
        startX = 0.35f, startY = -0.2f,
        endX = 0.65f, endY = 1.2f,
        durationMillis = 6000,
        scale = 1.2f
    ),
    // Flying birds (left -> right diagonal up)
    AmbientConfig(
        asset = LottieAsset.BIRDS,
        weight = AMBIENT_WEIGHT,
        startX = -0.3f, startY = 0.3f,
        endX = 1.3f, endY = 0.1f,
        durationMillis = 4500,
        scale = 1.5f
    ),
    // A single bird crossing the sky (left -> right)
    AmbientConfig(
        asset = LottieAsset.BIRD,
        weight = AMBIENT_WEIGHT,
        startX = -0.3f, startY = 0.25f,
        endX = 1.3f, endY = 0.15f,
        durationMillis = 5000,
        scale = 1.3f
    ),
    // Red birds flock (right -> left diagonal up)
    AmbientConfig(
        asset = LottieAsset.RED_BIRDS,
        weight = AMBIENT_WEIGHT,
        startX = 1.3f, startY = 0.35f,
        endX = -0.3f, endY = 0.15f,
        durationMillis = 5000,
        scale = 1.5f
    ),
    // Transparent birds flock (left -> right, higher up)
    AmbientConfig(
        asset = LottieAsset.TRANSPARENT_BIRDS,
        weight = AMBIENT_WEIGHT,
        startX = -0.3f, startY = 0.2f,
        endX = 1.3f, endY = 0.08f,
        durationMillis = 5200,
        scale = 1.5f
    ),
    // Falling autumn red leaves (top -> bottom, centered)
    AmbientConfig(
        asset = LottieAsset.AUTUMN_FALL,
        weight = AMBIENT_WEIGHT,
        startX = 0.5f, startY = -0.2f,
        endX = 0.5f, endY = 1.2f,
        durationMillis = 6000,
        scale = 1.6f
    ),
    // Paper plane (fast diagonal zip, left -> right)
    AmbientConfig(
        asset = LottieAsset.PAPER_PLANE,
        weight = AMBIENT_WEIGHT,
        startX = -0.2f, startY = 0.0f,
        endX = 1.2f, endY = 0.6f,
        durationMillis = 2800,
        scale = 0.55f
    ),
    // Running deer (horizontal along ground)
    AmbientConfig(
        asset = LottieAsset.DEER,
        weight = AMBIENT_WEIGHT,
        startX = -0.4f, startY = 0.72f,
        endX = 1.4f, endY = 0.72f,
        durationMillis = 7000,
        scale = 1.5f
    ),
)

/**
 * Picks a random animation from the pool (all equally likely). Optionally avoids
 * repeating [exclude], so consecutive surprises feel varied instead of sometimes
 * showing the same animation twice in a row.
 */
fun selectRandomAmbient(exclude: LottieAsset? = null): AmbientConfig {
    val pool = AmbientConfigs.filter { it.asset != exclude }.ifEmpty { AmbientConfigs }
    return pool[kotlin.random.Random.nextInt(pool.size)]
}

/**
 * Overlay composable that plays a single ambient animation moving across the screen.
 * Once completed, [onAnimationFinished] is triggered to remove the composable.
 */
@Composable
fun AmbientSurpriseOverlay(
    config: AmbientConfig,
    onAnimationFinished: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val bytes = remember(config.asset) {
        context.resources.openRawResource(config.asset.fileResource.rawResId).use { it.readBytes() }
    }

    val composition by rememberLottieComposition {
        LottieCompositionSpec.DotLottie(bytes)
    }

    val progress = remember { Animatable(0f) }

    val painter = rememberLottiePainter(
        composition = composition,
        progress = { progress.value }
    )

    LaunchedEffect(config) {
        progress.animateTo(
            targetValue = 1f,
            animationSpec = tween(
                durationMillis = config.durationMillis,
                easing = LinearEasing
            )
        )
        onAnimationFinished()
    }

    BoxWithConstraints(modifier = modifier.fillMaxSize()) {
        val width = maxWidth
        val height = maxHeight

        val currentX = lerp(config.startX * width.value, config.endX * width.value, progress.value).dp
        val currentY = lerp(config.startY * height.value, config.endY * height.value, progress.value).dp

        val size = width * config.scale
        val aspect = if (painter.intrinsicSize.width > 0) painter.intrinsicSize.height / painter.intrinsicSize.width else 1f
        val spriteHeight = size * aspect

        Image(
            painter = painter,
            contentDescription = null,
            modifier = Modifier
                .size(size, spriteHeight)
                .offset(x = currentX - size / 2, y = currentY - spriteHeight / 2)
        )
    }
}

private fun lerp(start: Float, stop: Float, fraction: Float): Float {
    return start + fraction * (stop - start)
}
