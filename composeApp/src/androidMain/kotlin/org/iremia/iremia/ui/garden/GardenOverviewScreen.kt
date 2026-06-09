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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import org.iremia.iremia.ui.journal.monthName
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import kotlin.random.Random

/**
 * Full-screen "Forest"-style garden overview (prototype).
 *
 * Shows one month of the isometric [GardenScene] with prev/next navigation; tapping
 * a tile reveals that day's entry count. Styled to match the Journal (light surfaces,
 * brand blue header wash) so moving here does not feel like a different app.
 *
 * Uses deterministic dummy data per month until journal persistence lands.
 */
@Composable
fun GardenOverviewScreen(
    initialYear: Int,
    initialMonth: Int,
    onClose: () -> Unit,
) {
    var year by rememberSaveable { mutableIntStateOf(initialYear) }
    var month by rememberSaveable { mutableIntStateOf(initialMonth) }
    var selectedTile by remember { mutableStateOf<Int?>(null) }
    val days = remember(year, month) { gardenForMonth(year, month) }
    val trees = days.count { it > 0 }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(IremiaColors.Gray100)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = IremiaSpacing.ScreenGutter, vertical = IremiaSpacing.S3),
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text("Mein Garten", style = IremiaText.H2, color = IremiaColors.Ink)
            IconButton(onClick = onClose) {
                Icon(Icons.Filled.Close, contentDescription = "Schließen", tint = IremiaColors.Ink900)
            }
        }

        Spacer(Modifier.height(IremiaSpacing.S3))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
        ) {
            IconButton(onClick = {
                month--; if (month < 1) { month = 12; year-- }; selectedTile = null
            }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Vorheriger Monat", tint = IremiaColors.Teal700)
            }
            Text(
                text = "${monthName(month)} $year",
                style = IremiaText.CardTitle,
                color = IremiaColors.Ink,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = IremiaSpacing.S4),
            )
            IconButton(onClick = {
                month++; if (month > 12) { month = 1; year++ }; selectedTile = null
            }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = "Nächster Monat", tint = IremiaColors.Teal700)
            }
        }

        Spacer(Modifier.height(IremiaSpacing.S5))

        // Framed garden, on the brand blue header wash.
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(IremiaShapes.Card)
                .background(IremiaColors.BlueHeader)
                .padding(IremiaSpacing.S3),
        ) {
            GardenScene(
                days = days,
                columns = 5,
                rows = 5,
                interactive = true,
                selectedTile = selectedTile,
                onTileTap = { selectedTile = it },
                modifier = Modifier.fillMaxWidth(),
            )
        }

        Spacer(Modifier.height(IremiaSpacing.S5))

        val info = selectedTile?.let { tile ->
            val count = days.getOrElse(tile) { 0 }
            val label = if (count == 0) "kein Eintrag" else "$count Eintrag${if (count > 1) "e" else ""}"
            "Tag ${tile + 1} · $label"
        } ?: "$trees Bäume in diesem Monat gepflanzt"

        Text(
            text = info,
            style = IremiaText.Body,
            color = IremiaColors.Gray600,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}

/** Deterministic dummy garden for a month: 25 days with a mix of empty/small/big. */
private fun gardenForMonth(year: Int, month: Int): List<Int> {
    val random = Random(year * 100 + month)
    return List(25) {
        when (random.nextInt(10)) {
            in 0..3 -> 0
            in 4..6 -> 1
            in 7..8 -> 2
            else -> 3
        }
    }
}
