package org.iremia.iremia.ui.journal

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.listSaver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.LocalDate
import kotlinx.datetime.minus
import kotlinx.datetime.plus
import org.iremia.iremia.ui.components.PrimaryButton
import org.iremia.iremia.ui.garden.GardenOverviewScreen
import org.iremia.iremia.ui.journal.episode.EpisodeCaptureFlow
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.ui.theme.IremiaSpacing
import org.iremia.iremia.utils.DateService

/** Saver so the selected [LocalDate] survives configuration changes. */
private val LocalDateSaver: Saver<LocalDate, Any> = listSaver(
    save = { listOf(it.year, it.monthNumber, it.dayOfMonth) },
    restore = { LocalDate(it[0], it[1], it[2]) },
)

/** Bottom spacer so scrollable content can clear the sticky capture button. */
private val STICKY_BUTTON_CLEARANCE = 96.dp

/**
 * Journal screen (SIC-24): the collapsible calendar, the 30-day tree overview, the
 * recent notes, and the "Episode erfassen" call to action that opens the capture
 * wizard as a full-screen flow.
 *
 * Everything runs on dummy data and local UI state — no persistence yet.
 */
@Composable
fun JournalScreen(modifier: Modifier = Modifier) {
    val today = remember { DateService().getToday() }
    var selectedDate by rememberSaveable(stateSaver = LocalDateSaver) { mutableStateOf(today) }
    var showCaptureFlow by rememberSaveable { mutableStateOf(false) }
    var showGarden by rememberSaveable { mutableStateOf(false) }

    // NOTE: dummy entry markers until the real journal repository is wired up.
    val entryDates = remember(today) {
        setOf(
            today.minus(5, DateTimeUnit.DAY),
            today.minus(2, DateTimeUnit.DAY),
            today,
            today.plus(2, DateTimeUnit.DAY),
            today.plus(4, DateTimeUnit.DAY),
        )
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
                    treesPlanted = sampleTreesPlanted,
                    days = sampleGardenDays,
                    modifier = Modifier.fillMaxWidth(),
                    onClick = { showGarden = true },
                )

                Spacer(Modifier.height(IremiaSpacing.SectionGap))
                RecentNotesSection(
                    notes = sampleNotes,
                    onAdd = { showCaptureFlow = true },
                    onNoteClick = { /* TODO: open note detail (later) */ },
                )

                Spacer(Modifier.height(STICKY_BUTTON_CLEARANCE))
            }
        }

        // Sticky CTA: pinned above the bottom navigation, fades the content behind it.
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        listOf(Color.Transparent, IremiaColors.Gray100, IremiaColors.Gray100),
                    )
                )
                .padding(horizontal = IremiaSpacing.ScreenGutter)
                .padding(top = IremiaSpacing.S6, bottom = IremiaSpacing.S4),
        ) {
            PrimaryButton(
                text = "+   Episode erfassen",
                onClick = { showCaptureFlow = true },
            )
        }
    }

    if (showCaptureFlow) {
        Dialog(
            onDismissRequest = { showCaptureFlow = false },
            properties = DialogProperties(
                usePlatformDefaultWidth = false,
                dismissOnClickOutside = false,
            ),
        ) {
            EpisodeCaptureFlow(
                onClose = { showCaptureFlow = false },
                onFinished = { showCaptureFlow = false },
            )
        }
    }

    if (showGarden) {
        Dialog(
            onDismissRequest = { showGarden = false },
            properties = DialogProperties(usePlatformDefaultWidth = false),
        ) {
            GardenOverviewScreen(
                initialYear = today.year,
                initialMonth = today.monthNumber,
                onClose = { showGarden = false },
            )
        }
    }
}
