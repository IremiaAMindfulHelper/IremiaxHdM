package org.iremia.iremia.ui.journal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Eco
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.iremia.iremia.ui.components.IremiaCard
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaText

/**
 * "Baumübersicht" card: a 30-day garden of dots summarizing journaling activity.
 *
 * Each dot is one day; denser/greener dots mean more entries that day, light dots
 * are empty days. Purely presentational with sample data for now.
 *
 * @param treesPlanted Number of trees planted in the period.
 * @param days Per-day entry counts (oldest → newest), one dot each.
 */
@Composable
fun TreeOverviewCard(
    treesPlanted: Int,
    days: List<Int>,
    modifier: Modifier = Modifier,
) {
    IremiaCard(modifier = modifier) {
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

            // Two rows of dots (15 per row for 30 days).
            days.chunked(15).forEach { week ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 3.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    week.forEach { count -> GardenDot(count, Modifier.weight(1f)) }
                }
            }

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

/** One garden day; color reflects entry [count], showing the number when 2+. */
@Composable
private fun GardenDot(count: Int, modifier: Modifier = Modifier) {
    val color = when (count) {
        0 -> IremiaColors.Garden100
        1 -> IremiaColors.Garden500
        2 -> IremiaColors.Garden700
        else -> IremiaColors.Garden900
    }
    Box(
        modifier = modifier
            .height(14.dp),
        contentAlignment = Alignment.Center,
    ) {
        Box(
            modifier = Modifier
                .size(14.dp)
                .clip(CircleShape)
                .background(color),
            contentAlignment = Alignment.Center,
        ) {
            if (count >= 2) {
                Text(
                    text = count.toString(),
                    color = Color.White,
                    fontSize = 8.sp,
                    fontWeight = FontWeight.Bold,
                )
            }
        }
    }
}
