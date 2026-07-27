package org.iremia.iremia.ui.garden

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.width
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
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
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
    onOpenEntry: (Long) -> Unit = {},
) {
    val context = LocalContext.current
    val state by viewModel.state.collectAsState()
    val activeAmbient by viewModel.activeAmbient.collectAsState()
    val days = state.tiles.map { it.entryCount }

    var showResetConfirm by remember { mutableStateOf(false) }
    // Block 5: long-press the title to open the animation preview (dev tool).
    var showAmbientPreview by remember { mutableStateOf(false) }

    // Pinch-to-zoom / pan state for the full garden view. Kept separate from the
    // planting zoom animation inside GardenScene.
    var zoomScale by remember { mutableFloatStateOf(1f) }
    var panX by remember { mutableFloatStateOf(0f) }
    var panY by remember { mutableFloatStateOf(0f) }

    // Play a fresh ambient animation every time the garden is opened. Runs once per
    // entry (the screen recomposes into existence), restarting even if a previous
    // one was still playing.
    LaunchedEffect(Unit) { viewModel.onEnterGarden() }

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
                Text(
                    localized(SharedRes.strings.garden_title).toString(context),
                    style = IremiaText.H2,
                    color = IremiaColors.Ink,
                    modifier = Modifier.pointerInput(Unit) {
                        detectTapGestures(onLongPress = { showAmbientPreview = true })
                    },
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = { showResetConfirm = true }) {
                        Icon(
                            Icons.Filled.Refresh,
                            contentDescription = localized(SharedRes.strings.garden_reset).toString(context),
                            tint = IremiaColors.Ink900,
                        )
                    }
                    IconButton(onClick = onClose) {
                        Icon(Icons.Filled.Close, contentDescription = localized(SharedRes.strings.nav_close).toString(context), tint = IremiaColors.Ink900)
                    }
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

            // The garden sits free on the screen (no card/box) so it reads bigger
            // and more immersive. It takes the remaining height between the month
            // row and the info text; the scene's width is capped so the 1.2-aspect
            // plot always fits that height — otherwise it blows up in landscape.
            BoxWithConstraints(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentAlignment = Alignment.Center,
            ) {
            val sceneWidth = maxWidth.coerceAtMost(maxHeight * 1.2f)
            Box(
                modifier = Modifier
                    .width(sceneWidth)
                    // Pinch to zoom and drag to pan the garden. Scale is clamped so
                    // the user can't lose the plot; pan resets to center at 1x.
                    .pointerInput(Unit) {
                        detectTransformGestures { _, pan, zoom, _ ->
                            zoomScale = (zoomScale * zoom).coerceIn(1f, 4f)
                            if (zoomScale > 1f) {
                                panX += pan.x
                                panY += pan.y
                            } else {
                                panX = 0f
                                panY = 0f
                            }
                        }
                    }
                    // Swipe left/right to change month, but only at 1x so it does
                    // not fight panning while zoomed in (plan 6.3).
                    .pointerInput(Unit) {
                        var dragTotal = 0f
                        detectHorizontalDragGestures(
                            onDragStart = { dragTotal = 0f },
                            onDragEnd = {
                                if (zoomScale <= 1f) {
                                    val threshold = size.width * 0.18f
                                    if (dragTotal > threshold) viewModel.navigateMonth(-1)
                                    else if (dragTotal < -threshold) viewModel.navigateMonth(1)
                                }
                            },
                        ) { change, dragAmount ->
                            change.consume()
                            dragTotal += dragAmount
                        }
                    },
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
                    modifier = Modifier
                        .fillMaxWidth()
                        .graphicsLayer(
                            scaleX = zoomScale,
                            scaleY = zoomScale,
                            translationX = panX,
                            translationY = panY,
                        ),
                )
            }
            }

            Spacer(Modifier.height(IremiaSpacing.S5))

            val info = state.selectedTile?.let { tileIndex ->
                val tile = state.tiles.getOrNull(tileIndex)
                val dayLabel = localized(SharedRes.strings.garden_day_label).toString(context)
                    .replace("%1\$d", (tile?.dayOfMonth ?: tileIndex + 1).toString())
                val count = tile?.entryCount ?: 0
                if (count == 0) {
                    "$dayLabel · " + localized(SharedRes.strings.garden_no_entry).toString(context)
                } else {
                    val entries = if (count == 1) {
                        localized(SharedRes.strings.garden_entry_singular).toString(context)
                    } else {
                        localized(SharedRes.strings.garden_entry_plural).toString(context)
                    }.replace("%1\$d", count.toString())
                    "$dayLabel · $entries"
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

        if (showResetConfirm) {
            AlertDialog(
                onDismissRequest = { showResetConfirm = false },
                title = { Text(localized(SharedRes.strings.garden_reset_confirm_title).toString(context)) },
                text = { Text(localized(SharedRes.strings.garden_reset_confirm_message).toString(context)) },
                confirmButton = {
                    TextButton(onClick = {
                        viewModel.resetGarden()
                        showResetConfirm = false
                    }) {
                        Text(localized(SharedRes.strings.garden_reset_confirm_action).toString(context))
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showResetConfirm = false }) {
                        Text(localized(SharedRes.strings.garden_reset_cancel).toString(context))
                    }
                },
            )
        }

        // Tapping a planted tree reveals the journal entry it represents. Rendered
        // as an in-layout overlay (not ModalBottomSheet) because the garden is
        // already hosted inside a Dialog and nested platform windows misbehave.
        state.selectedEntry?.let { entry ->
            GardenEntrySheet(
                entry = entry,
                onDismiss = { viewModel.selectTile(null) },
                onOpenEntry = {
                    viewModel.selectTile(null)
                    onOpenEntry(entry.id)
                },
                modifier = Modifier.align(Alignment.BottomCenter),
            )
        }

        // Block 5: animation preview mode (opened by long-pressing the title).
        if (showAmbientPreview) {
            AmbientPreviewScreen(onClose = { showAmbientPreview = false })
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
    onOpenEntry: () -> Unit = {},
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

            // Dezenter "Eintrag öffnen →"-Button (Block 2.2): text + arrow, no border.
            Spacer(Modifier.height(IremiaSpacing.S4))
            Row(
                modifier = Modifier
                    .clip(IremiaShapes.Pill)
                    .clickable(onClick = onOpenEntry)
                    .padding(vertical = IremiaSpacing.S1),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = localized(SharedRes.strings.garden_open_entry).toString(context),
                    style = IremiaText.CardTitle,
                    color = IremiaColors.Teal700,
                )
                Spacer(Modifier.size(6.dp))
                Icon(
                    Icons.AutoMirrored.Filled.KeyboardArrowRight,
                    contentDescription = null,
                    tint = IremiaColors.Teal700,
                    modifier = Modifier.size(20.dp),
                )
            }
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
