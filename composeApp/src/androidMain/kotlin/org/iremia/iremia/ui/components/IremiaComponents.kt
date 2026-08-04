package org.iremia.iremia.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.text.TextAutoSize
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaText

// =============================================================================
// Shared Iremia UI building blocks (buttons, chips) used across the prototype.
// NOTE: text is passed in by callers; visible strings are currently hardcoded at
// the call sites and will be moved to moko-resources in a later localization pass.
// =============================================================================

/** Full-width teal pill button — the primary call to action. */
@Composable
fun PrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    trailingIcon: ImageVector? = null,
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        // heightIn (not height) so the pill grows with the system font scale
        // instead of clipping its label on small screens.
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 54.dp),
        shape = IremiaShapes.Pill,
        contentPadding = PaddingValues(horizontal = 24.dp, vertical = 12.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = IremiaColors.Teal700,
            contentColor = IremiaColors.White,
        ),
    ) {
        Text(text, style = IremiaText.CardTitle, maxLines = 2, textAlign = TextAlign.Center)
        if (trailingIcon != null) {
            Spacer(Modifier.size(8.dp))
            Icon(trailingIcon, contentDescription = null, modifier = Modifier.size(20.dp))
        }
    }
}

/** Quiet, full-width text button for the secondary action (e.g. "skip"). */
@Composable
fun SecondaryTextButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    TextButton(
        onClick = onClick,
        // Keeps the touch target at the 48dp minimum, matching iOS.
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 48.dp),
    ) {
        // Single line, shrinking rather than wrapping, so this quiet link never
        // grows a pinned footer to twice its height at large font scales.
        BasicText(
            text,
            style = IremiaText.Body.copy(color = IremiaColors.Gray500, textAlign = TextAlign.Center),
            maxLines = 1,
            autoSize = TextAutoSize.StepBased(minFontSize = 11.sp, maxFontSize = 15.sp),
        )
    }
}

/**
 * Selectable pill chip: filled teal when [selected], outlined otherwise.
 * Used for the multi-select context options in the episode flow.
 */
@Composable
fun ChoiceChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val shape = IremiaShapes.Pill
    Box(
        modifier = modifier
            .clip(shape)
            .background(if (selected) IremiaColors.Teal700 else IremiaColors.White)
            .then(
                if (selected) Modifier
                else Modifier.border(BorderStroke(1.dp, IremiaColors.Gray300), shape)
            )
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = label,
            style = IremiaText.Body,
            color = if (selected) IremiaColors.White else IremiaColors.Ink700,
        )
    }
}

/** A rounded card surface used for content blocks (notes, overview, …). */
@Composable
fun IremiaCard(
    modifier: Modifier = Modifier,
    shape: RoundedCornerShape = IremiaShapes.Card,
    content: @Composable () -> Unit,
) {
    Box(
        modifier = modifier
            .clip(shape)
            .background(IremiaColors.White)
            .padding(20.dp),
    ) {
        content()
    }
}
