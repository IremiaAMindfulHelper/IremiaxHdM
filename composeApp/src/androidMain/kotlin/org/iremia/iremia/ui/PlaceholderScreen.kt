package org.iremia.iremia.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import dev.icerock.moko.resources.StringResource
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.utils.localized

/**
 * Temporary placeholder for tabs whose real content is not implemented yet.
 *
 * Used by the new navigation tabs (Training, Journal, Wellbeing) so the bottom
 * bar is fully navigable while the actual screens are built in a follow-up
 * (SIC-18). It simply centers the localized tab title using the brand theme.
 *
 * @param titleRes The localized title to display (the tab's label resource).
 * @param modifier Modifier applied to the root container.
 */
@Composable
fun PlaceholderScreen(
    titleRes: StringResource,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    Box(
        modifier = modifier
            .fillMaxSize()
            .padding(IremiaSpacing.ScreenGutter),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = localized(titleRes).toString(context),
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
    }
}
