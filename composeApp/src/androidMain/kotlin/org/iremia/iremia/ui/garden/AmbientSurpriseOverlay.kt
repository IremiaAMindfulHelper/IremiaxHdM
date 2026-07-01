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
val AmbientConfigs = listOf(
    // 30% weight: falling green leaves (top -> bottom diagonal)
    AmbientConfig(
        asset = LottieAsset.LEAVES,
        weight = 30,
        startX = 0.2f, startY = -0.2f,
        endX = 0.8f, endY = 1.2f,
        durationMillis = 5500,
        scale = 1.0f
    ),
    // 25% weight: flying birds (left -> right diagonal up)
    AmbientConfig(
        asset = LottieAsset.BIRDS,
        weight = 25,
        startX = -0.3f, startY = 0.3f,
        endX = 1.3f, endY = 0.1f,
        durationMillis = 4500,
        scale = 0.9f
    ),
    // 20% weight: falling autumn red leaves (top -> bottom diagonal)
    AmbientConfig(
        asset = LottieAsset.AUTUMN_FALL,
        weight = 20,
        startX = 0.6f, startY = -0.2f,
        endX = 0.2f, endY = 1.2f,
        durationMillis = 6000,
        scale = 1.0f
    ),
    // 15% weight: floating butterflies (sinusoidal right -> left)
    AmbientConfig(
        asset = LottieAsset.BUTTERFLIES,
        weight = 15,
        startX = 1.3f, startY = 0.5f,
        endX = -0.3f, endY = 0.3f,
        durationMillis = 6500,
        scale = 0.75f
    ),
    // 8% weight: paper plane (fast diagonal zip)
    AmbientConfig(
        asset = LottieAsset.PAPER_PLANE,
        weight = 8,
        startX = 1.2f, startY = 0.0f,
        endX = -0.2f, endY = 0.6f,
        durationMillis = 2800,
        scale = 0.6f
    ),
    // 5% weight: running deer (horizontal along ground)
    AmbientConfig(
        asset = LottieAsset.DEER,
        weight = 5,
        startX = -0.4f, startY = 0.72f,
        endX = 1.4f, endY = 0.72f,
        durationMillis = 7000,
        scale = 1.0f
    ),
)

/**
 * Picks an animation randomly from the weighted [AmbientConfigs] pool.
 */
fun selectRandomAmbient(): AmbientConfig {
    val totalWeight = AmbientConfigs.sumOf { it.weight }
    val randomVal = kotlin.random.Random.nextInt(totalWeight)
    var currentWeight = 0
    for (config in AmbientConfigs) {
        currentWeight += config.weight
        if (randomVal < currentWeight) {
            return config
        }
    }
    return AmbientConfigs.first()
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
