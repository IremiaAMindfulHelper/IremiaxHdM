package org.iremia.iremia.ui.journal

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.garden.GardenScene
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaText

/**
 * "Baumübersicht" card: a compact isometric preview of this month's garden.
 *
 * Shows the trees-planted headline and an isometric mini-garden; tapping the card
 * opens the full garden overview. Purely presentational with sample data for now.
 *
 * @param treesPlanted Number of trees planted in the period.
 * @param days Per-day entry counts, one tile each in the preview garden.
 * @param onClick Opens the full-screen garden overview.
 */
@Composable
fun TreeOverviewCard(
    treesPlanted: Int,
    days: List<Int>,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},
) {
    IremiaCard(modifier = modifier.clickable(onClick = onClick)) {
        Column(Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("BAUMÜBERSICHT", style = IremiaText.Eyebrow, color = IremiaColors.Teal700)
                Text("Letzte 30 Tage", style = IremiaText.Caption, color = IremiaColors.Gray500)
            }

            Spacer(Modifier.height(12.dp))

            Row(verticalAlignment = Alignment.Bottom) {
                Text(treesPlanted.toString(), style = IremiaText.NumXl, color = IremiaColors.Ink)
                Spacer(Modifier.size(8.dp))
                Text(
                    "Bäume gepflanzt",
                    style = IremiaText.Body,
                    color = IremiaColors.Gray600,
                    modifier = Modifier.padding(bottom = 6.dp),
                )
            }

            Spacer(Modifier.height(14.dp))

            // Isometric garden preview (tap the card to open the full overview).
            GardenScene(
                days = days,
                columns = 5,
                rows = 5,
                modifier = Modifier.fillMaxWidth(),
            )

            Spacer(Modifier.height(14.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Filled.Eco,
                    contentDescription = null,
                    tint = IremiaColors.Garden500,
                    modifier = Modifier.size(16.dp),
                )
                Spacer(Modifier.size(6.dp))
                Text(
                    "Leere Tage sind völlig okay — dein Garten wächst in deinem Tempo.",
                    style = IremiaText.Caption,
                    color = IremiaColors.Gray500,
                )
            }
        }
    }
}
