package org.iremia.iremia.ui.journal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.listSaver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.ui.journal.JournalViewModel
import org.iremia.iremia.ui.garden.GardenViewModel
import androidx.compose.runtime.collectAsState
import org.iremia.iremia.controller.NotesState
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import org.iremia.iremia.ui.theme.IremiaText
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.LocalDate
import kotlinx.datetime.minus
import kotlinx.datetime.plus
import org.iremia.iremia.ui.garden.GardenOverviewScreen
import org.iremia.iremia.ui.journal.episode.EpisodeCaptureFlow
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.utils.DateService
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

import androidx.compose.runtime.derivedStateOf
import org.iremia.iremia.domain.note.Note
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/** Saver so the selected [LocalDate] survives configuration changes. */
private val LocalDateSaver: Saver<LocalDate, Any> = listSaver(
    save = { listOf(it.year, it.monthNumber, it.dayOfMonth) },
    restore = { LocalDate(it[0], it[1], it[2]) },
)


/**
 * Journal screen (SIC-24): the collapsible calendar, the 30-day tree overview, the
 * recent notes, and the "Episode erfassen" call to action that opens the capture
 * wizard as a full-screen flow.
 *
 * Everything runs on dummy data and local UI state — no persistence yet.
 */
@Composable
fun JournalScreen(
    viewModel: JournalViewModel,
    modifier: Modifier = Modifier,
    openCaptureFlow: () -> Unit = {},
    // Set true by MainScreen (e.g. after "view garden" from the capture flow) to
    // open the garden; JournalScreen resets it via [onGardenShown].
    openGardenSignal: Boolean = false,
    onGardenShown: () -> Unit = {},
) {
    val context = androidx.compose.ui.platform.LocalContext.current

    // Wire up the garden ViewModel with the SharedFactory (notes VM is hoisted).
    val driverFactory = remember { DriverFactory(context) }

    val gardenViewModel: GardenViewModel = viewModel(
        factory = viewModelFactory {
            initializer {
                val gardenController = SharedFactory.createGardenController(driverFactory)
                GardenViewModel(gardenController)
            }
        }
    )

    val state by viewModel.state.collectAsState()
    val gardenState by gardenViewModel.state.collectAsState()
    val today = remember { DateService().getToday() }
    var selectedDate by rememberSaveable(stateSaver = LocalDateSaver) { mutableStateOf(today) }
    var showGarden by rememberSaveable { mutableStateOf(false) }
    var detailNoteId by rememberSaveable { mutableStateOf<Long?>(null) }

    // Open the garden when MainScreen signals it (from the capture flow's "view garden").
    androidx.compose.runtime.LaunchedEffect(openGardenSignal) {
        if (openGardenSignal) {
            showGarden = true
            onGardenShown()
        }
    }
    // Id of the entry pending deletion; drives the confirmation dialog (1.4).
    var pendingDeleteId by rememberSaveable { mutableStateOf<Long?>(null) }

    // Map real entries to calendar dots.
    val entryDates by remember {
        derivedStateOf {
            state.items.map { note ->
                Instant.fromEpochMilliseconds(note.createdAt)
                    .toLocalDateTime(TimeZone.currentSystemDefault()).date
            }.toSet()
        }
    }
    
    val gardenEntries by remember {
        derivedStateOf {
            state.gardenEntries
        }
    }
    val treesPlanted by remember {
        derivedStateOf { state.entryCount }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(IremiaColors.Gray100),
    ) {
        // Scrollable content. The bottom spacer keeps the last items clear of the
        // sticky button that floats on top.
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState()),
        ) {
            JournalCalendar(
                selectedDate = selectedDate,
                today = today,
                entryDates = entryDates,
                onDateSelected = { selectedDate = it },
                onTodayClick = { selectedDate = today },
            )

            Column(Modifier.padding(horizontal = IremiaSpacing.ScreenGutter)) {
                Spacer(Modifier.height(IremiaSpacing.SectionGap))
                TreeOverviewCard(
                    treesPlanted = gardenState.totalPlants,
                    tiles = gardenState.tiles,
                    modifier = Modifier.fillMaxWidth(),
                    onClick = { showGarden = true },
                )

                Spacer(Modifier.height(IremiaSpacing.SectionGap))
                RecentNotesSection(
                    notes = state.items,
                    onAdd = openCaptureFlow,
                    onNoteClick = { detailNoteId = it.id },
                    onDelete = { pendingDeleteId = it.id }
                )

                Spacer(Modifier.height(IremiaSpacing.S6))
            }
        }
        // The "+" FAB now lives at the app-shell level (MainScreen), so it shows on
        // every tab; it opens the same capture flow via [openCaptureFlow].
    }

    // Delete confirmation (1.4): nothing is removed until the user confirms.
    val deleteId = pendingDeleteId
    if (deleteId != null) {
        AlertDialog(
            onDismissRequest = { pendingDeleteId = null },
            title = { Text(localized(SharedRes.strings.entry_delete_title).toString(context), style = IremiaText.CardTitle, color = IremiaColors.Ink) },
            text = { Text(localized(SharedRes.strings.entry_delete_message).toString(context), style = IremiaText.Body, color = IremiaColors.Gray600) },
            confirmButton = {
                TextButton(onClick = {
                    viewModel.deleteNote(deleteId)
                    pendingDeleteId = null
                }) {
                    Text(localized(SharedRes.strings.entry_delete_confirm).toString(context), color = IremiaColors.Teal700)
                }
            },
            dismissButton = {
                TextButton(onClick = { pendingDeleteId = null }) {
                    Text(localized(SharedRes.strings.entry_delete_cancel).toString(context), color = IremiaColors.Gray500)
                }
            },
            containerColor = IremiaColors.White,
        )
    }

    if (showGarden) {
        Dialog(
            onDismissRequest = { showGarden = false },
            properties = DialogProperties(usePlatformDefaultWidth = false),
        ) {
            GardenOverviewScreen(
                viewModel = gardenViewModel,
                onClose = { showGarden = false },
                onOpenEntry = { entryId ->
                    // Block 2.2: open the tapped plant's entry in the detail view.
                    showGarden = false
                    detailNoteId = entryId
                },
            )
        }
    }

    val detailNote = detailNoteId?.let { id -> state.items.firstOrNull { it.id == id } }
    if (detailNote != null) {
        Dialog(
            onDismissRequest = { detailNoteId = null },
            properties = DialogProperties(usePlatformDefaultWidth = false),
        ) {
            EpisodeDetailScreen(
                note = detailNote,
                onClose = { detailNoteId = null },
                onSave = { draft -> viewModel.updateEntry(detailNote.id, draft) },
            )
        }
    }
}
