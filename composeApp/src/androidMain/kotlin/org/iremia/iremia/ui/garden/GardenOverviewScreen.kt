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
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.controller.GardenState
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.ui.journal.monthName
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaShapes
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.ui.theme.IremiaText
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

/**
 * Full-screen "Forest"-style garden overview.
 *
 * Shows one month of the isometric [GardenScene] with prev/next navigation; tapping
 * a tile reveals that day's entry count. Styled to match the Journal (light surfaces,
 * brand blue header wash) so moving here does not feel like a different app.
 *
 * State is driven by [GardenViewModel] → [GardenState]. Composable stays stateless.
 */
@Composable
fun GardenOverviewScreen(
    viewModel: GardenViewModel,
    onClose: () -> Unit,
) {
    val context = LocalContext.current
    val state by viewModel.state.collectAsState()
    val activeAmbient by viewModel.activeAmbient.collectAsState()
    val days = state.tiles.map { it.entryCount }

    Box(modifier = Modifier.fillMaxSize()) {
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
                Text(localized(SharedRes.strings.garden_title).toString(context), style = IremiaText.H2, color = IremiaColors.Ink)
                IconButton(onClick = onClose) {
                    Icon(Icons.Filled.Close, contentDescription = localized(SharedRes.strings.nav_close).toString(context), tint = IremiaColors.Ink900)
                }
            }

            Spacer(Modifier.height(IremiaSpacing.S3))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
            ) {
                IconButton(onClick = { viewModel.navigateMonth(-1) }) {
                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = localized(SharedRes.strings.garden_prev_month).toString(context), tint = IremiaColors.Teal700)
                }
                Text(
                    text = "${monthName(state.month)} ${state.year}",
                    style = IremiaText.CardTitle,
                    color = IremiaColors.Ink,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = IremiaSpacing.S4),
                )
                IconButton(onClick = { viewModel.navigateMonth(1) }) {
                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = localized(SharedRes.strings.garden_next_month).toString(context), tint = IremiaColors.Teal700)
                }
            }

            Spacer(Modifier.height(IremiaSpacing.S5))

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(IremiaShapes.Card)
                    .background(IremiaColors.BlueHeader)
                    .padding(IremiaSpacing.S3),
            ) {
                GardenScene(
                    tiles = state.tiles,
                    columns = state.gridConfig.columns,
                    rows = state.gridConfig.rows,
                    interactive = true,
                    selectedTile = state.selectedTile,
                    onTileTap = { viewModel.selectTile(it) },
                    newlyPlantedTileIndex = state.newlyPlantedTileIndex,
                    onAnimationFinished = { viewModel.clearNewlyPlanted() },
                    modifier = Modifier.fillMaxWidth(),
                )
            }

            Spacer(Modifier.height(IremiaSpacing.S5))

            val info = state.selectedTile?.let { tile ->
                val count = days.getOrElse(tile) { 0 }
                if (count == 0) {
                    localized(SharedRes.strings.garden_no_entry).toString(context)
                } else {
                    localized(SharedRes.strings.garden_entry_singular).toString(context).replace("%1\$d", "1")
                }
            } ?: localized(SharedRes.strings.garden_month_trees).toString(context).replace("%1\$d", state.totalPlants.toString())

            Text(
                text = info,
                style = IremiaText.Body,
                color = IremiaColors.Gray600,
                textAlign = TextAlign.Center,
                modifier = Modifier.fillMaxWidth(),
            )
        }

        activeAmbient?.let { config ->
            AmbientSurpriseOverlay(
                config = config,
                onAnimationFinished = { viewModel.clearAmbient() }
            )
        }

        // Tapping a planted tree reveals the journal entry it represents. Rendered
        // as an in-layout overlay (not ModalBottomSheet) because the garden is
        // already hosted inside a Dialog and nested platform windows misbehave.
        state.selectedEntry?.let { entry ->
            GardenEntrySheet(
                entry = entry,
                onDismiss = { viewModel.selectTile(null) },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }
    }
}

/**
 * Bottom-sheet-style overlay showing the journal entry behind a tapped plant:
 * its date and the full content. A scrim dims the garden; tapping the scrim or
 * the close button clears the tile selection.
 */
@Composable
private fun GardenEntrySheet(
    entry: Note,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val dateText = remember(entry.createdAt) { formatEntryDate(entry.createdAt) }
    val content = entry.content.trim()

    Box(modifier = Modifier.fillMaxSize()) {
        // Scrim: tap to dismiss.
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.32f))
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onDismiss,
                ),
        )

        Column(
            modifier = modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp))
                .background(IremiaColors.White)
                .navigationBarsPadding()
                .padding(horizontal = IremiaSpacing.ScreenGutter)
                .padding(top = IremiaSpacing.S4, bottom = IremiaSpacing.S6),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text(
                    text = localized(SharedRes.strings.garden_entry_sheet_title).toString(context),
                    style = IremiaText.H2,
                    color = IremiaColors.Ink,
                )
                IconButton(onClick = onDismiss) {
                    Icon(
                        Icons.Filled.Close,
                        contentDescription = localized(SharedRes.strings.nav_close).toString(context),
                        tint = IremiaColors.Gray600,
                        modifier = Modifier.size(20.dp),
                    )
                }
            }
            Text(text = dateText, style = IremiaText.Caption, color = IremiaColors.Gray500)
            Spacer(Modifier.height(IremiaSpacing.S4))
            Text(
                text = content.ifEmpty {
                    localized(SharedRes.strings.garden_entry_sheet_empty).toString(context)
                },
                style = IremiaText.Body,
                color = IremiaColors.Ink700,
                modifier = Modifier
                    .heightIn(max = 280.dp)
                    .verticalScroll(rememberScrollState()),
            )
        }
    }
}

/** Formats an epoch-millis timestamp like "5. Jun 2026 · 14:30" in the system zone. */
private fun formatEntryDate(epochMillis: Long): String {
    val dt = Instant.fromEpochMilliseconds(epochMillis)
        .toLocalDateTime(TimeZone.currentSystemDefault())
    val month = dt.month.name.take(3).lowercase().replaceFirstChar { it.uppercase() }
    val time = "${dt.hour.toString().padStart(2, '0')}:${dt.minute.toString().padStart(2, '0')}"
    return "${dt.dayOfMonth}. $month ${dt.year} · $time"
}
