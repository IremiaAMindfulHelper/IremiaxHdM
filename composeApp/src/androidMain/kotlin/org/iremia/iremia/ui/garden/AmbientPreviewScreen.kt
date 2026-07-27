package org.iremia.iremia.ui.garden

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

/**
 * Developer/preview mode (Block 5): plays each ambient animation in sequence so the
 * team can judge which ones look right and fine-tune their positions/scales. Each
 * animation auto-advances to the next when it finishes; arrows step manually.
 *
 * Not part of the normal user flow — reachable only where explicitly wired in.
 */
@Composable
fun AmbientPreviewScreen(onClose: () -> Unit) {
    val context = LocalContext.current
    var index by remember { mutableIntStateOf(0) }
    val config = AmbientConfigs[index]

    fun next() { index = (index + 1) % AmbientConfigs.size }
    fun prev() { index = (index - 1 + AmbientConfigs.size) % AmbientConfigs.size }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(IremiaColors.BlueHeader),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(horizontal = IremiaSpacing.ScreenGutter, vertical = IremiaSpacing.S3),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(localized(SharedRes.strings.ambient_preview_title).toString(context), style = IremiaText.H2, color = IremiaColors.Ink)
                IconButton(onClick = onClose) {
                    Icon(Icons.Filled.Close, contentDescription = localized(SharedRes.strings.nav_close).toString(context), tint = IremiaColors.Ink900)
                }
            }
            Text(
                text = "${index + 1}/${AmbientConfigs.size} · ${config.asset.name}",
                style = IremiaText.Caption,
                color = IremiaColors.Gray600,
            )
        }

        // The animation plays over the whole screen, exactly as in the real garden.
        // A key on the index restarts the overlay for each selection.
        AmbientSurpriseOverlay(
            config = config,
            onAnimationFinished = { next() },
            modifier = Modifier.fillMaxSize(),
        )

        // Manual step controls.
        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = IremiaSpacing.S6),
            horizontalArrangement = Arrangement.spacedBy(IremiaSpacing.S5),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(
                onClick = { prev() },
                modifier = Modifier.clip(IremiaShapes.Pill).background(IremiaColors.White),
            ) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = localized(SharedRes.strings.ambient_preview_prev).toString(context), tint = IremiaColors.Teal700)
            }
            IconButton(
                onClick = { next() },
                modifier = Modifier.clip(IremiaShapes.Pill).background(IremiaColors.White),
            ) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = localized(SharedRes.strings.ambient_preview_next).toString(context), tint = IremiaColors.Teal700)
            }
        }
    }
}
