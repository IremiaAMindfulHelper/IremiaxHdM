package org.iremia.iremia.ui.journal.episode

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import org.iremia.iremia.data.garden.PlantResult
import org.iremia.iremia.domain.note.EntryType
import org.iremia.iremia.domain.note.EpisodeDraft
import org.iremia.iremia.ui.theme.IremiaColors
import java.util.Calendar

/** The stages of the capture flow. The type chooser comes first, then a branch. */
private enum class CaptureStage { TypeChooser, PanicIntensity, PanicContext, PanicReflection, Journal, Saved }

/** Insights goal shown on the confirmation screen. */
private const val INSIGHTS_GOAL = 30

/**
 * Self-contained capture flow. Opens on the entry-type chooser (panic vs journal),
 * then routes into either the existing panic wizard (intensity → context →
 * reflection) or the journal entry (guided prompts / free text). Both end on the
 * shared "saved" confirmation.
 *
 * The in-progress draft lives purely in UI state; [onSaveEpisode] persists the
 * finished [EpisodeDraft]. [onClose] backs out of the chooser, [onFinished]
 * dismisses after the confirmation screen.
 */
@Composable
fun EpisodeCaptureFlow(
    entryCount: Int,
    onClose: () -> Unit,
    onFinished: () -> Unit,
    onViewGarden: () -> Unit = onFinished,
    onSaveEpisode: (EpisodeDraft) -> Unit,
    // The result of the just-saved entry's plant attempt, for the saved screen's
    // conditional text (Block 3). Null until planting completes.
    plantResult: PlantResult? = null,
) {
    val finalEntryCount = remember { entryCount + 1 }
    var stage by rememberSaveable { mutableStateOf(CaptureStage.TypeChooser) }
    // The type + strength of the entry being saved, captured at save time so the
    // saved screen can show a matching impulse text (Block 3).
    var savedType by rememberSaveable { mutableStateOf(EntryType.PANIC) }
    var savedStrength by rememberSaveable { mutableStateOf<Int?>(null) }

    // --- Panic draft state (only used on the panic branch) ---
    val now = remember { Calendar.getInstance() }
    var selectedDateMillis by rememberSaveable { mutableStateOf(startOfDayUtc(now)) }
    var hour by rememberSaveable { mutableStateOf(now.get(Calendar.HOUR_OF_DAY)) }
    var minute by rememberSaveable { mutableStateOf(now.get(Calendar.MINUTE)) }
    var strength by rememberSaveable { mutableStateOf(6f) }
    val places = remember { mutableStateListOf<String>() }
    val activities = remember { mutableStateListOf<String>() }
    val bodySignals = remember { mutableStateListOf<String>() }
    var note by rememberSaveable { mutableStateOf("") }
    var moodBefore by rememberSaveable { mutableStateOf(-1) }
    var moodAfter by rememberSaveable { mutableStateOf(-1) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(IremiaColors.White),
    ) {
        when (stage) {
            CaptureStage.TypeChooser -> EntryTypeChooserScreen(
                onBack = onClose,
                onPickPanic = { stage = CaptureStage.PanicIntensity },
                onPickJournal = { stage = CaptureStage.Journal },
            )

            CaptureStage.PanicIntensity -> EpisodeIntensityStep(
                dateMillis = selectedDateMillis,
                onDateChange = { selectedDateMillis = it },
                hour = hour,
                minute = minute,
                onTimeChange = { h, m -> hour = h; minute = m },
                strength = strength,
                onStrengthChange = { strength = it },
                onBack = { stage = CaptureStage.TypeChooser },
                onNext = { stage = CaptureStage.PanicContext },
                onSkip = { stage = CaptureStage.PanicContext },
            )

            CaptureStage.PanicContext -> EpisodeContextStep(
                places = places,
                onTogglePlace = { places.toggle(it) },
                activities = activities,
                onToggleActivity = { activities.toggle(it) },
                bodySignals = bodySignals,
                onToggleSignal = { bodySignals.toggle(it) },
                onBack = { stage = CaptureStage.PanicIntensity },
                onNext = { stage = CaptureStage.PanicReflection },
                onSkip = { stage = CaptureStage.PanicReflection },
            )

            CaptureStage.PanicReflection -> EpisodeReflectionStep(
                note = note,
                onNoteChange = { note = it },
                moodBefore = moodBefore,
                onMoodBefore = { moodBefore = it },
                moodAfter = moodAfter,
                onMoodAfter = { moodAfter = it },
                onBack = { stage = CaptureStage.PanicContext },
                onSave = {
                    savedType = EntryType.PANIC
                    savedStrength = strength.toInt()
                    onSaveEpisode(
                        EpisodeDraft(
                            content = note,
                            type = EntryType.PANIC,
                            strength = strength.toInt(),
                            places = places.toList(),
                            activities = activities.toList(),
                            bodySignals = bodySignals.toList(),
                            moodBefore = moodBefore.takeIf { it >= 0 },
                            moodAfter = moodAfter.takeIf { it >= 0 },
                            createdAt = combineDateTime(selectedDateMillis, hour, minute),
                        )
                    )
                    stage = CaptureStage.Saved
                },
            )

            CaptureStage.Journal -> JournalEntryScreen(
                onBack = { stage = CaptureStage.TypeChooser },
                onSave = { title, content ->
                    savedType = EntryType.JOURNAL
                    savedStrength = null
                    onSaveEpisode(
                        EpisodeDraft(
                            content = content,
                            type = EntryType.JOURNAL,
                            title = title.ifBlank { null },
                            // A journal entry lands "now"; no date/time picker.
                            createdAt = System.currentTimeMillis(),
                        )
                    )
                    stage = CaptureStage.Saved
                },
            )

            CaptureStage.Saved -> EpisodeSavedScreen(
                entryCount = finalEntryCount,
                goal = INSIGHTS_GOAL,
                entryType = savedType,
                strength = savedStrength,
                plantResult = plantResult,
                onInsights = onFinished,
                onHome = onFinished,
                onViewGarden = onViewGarden,
            )
        }
    }
}

/** Add [value] if absent, remove it if present (multi-select toggle). */
private fun <T> MutableList<T>.toggle(value: T) {
    if (!remove(value)) add(value)
}

/**
 * Start-of-day in UTC millis for the given calendar. Material's DatePicker works in
 * UTC, so we keep the selected date in UTC and only add the local time-of-day when
 * building the final timestamp.
 */
private fun startOfDayUtc(cal: Calendar): Long {
    val utc = Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
    utc.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH), 0, 0, 0)
    utc.set(Calendar.MILLISECOND, 0)
    return utc.timeInMillis
}

/**
 * Combines a UTC start-of-day [dateMillis] (from the DatePicker) with a local
 * [hour]/[minute] into an epoch-millis timestamp in the device's zone, so the entry
 * lands on the chosen calendar day at the chosen time.
 */
private fun combineDateTime(dateMillis: Long, hour: Int, minute: Int): Long {
    val utc = Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")).apply { timeInMillis = dateMillis }
    val local = Calendar.getInstance().apply {
        set(utc.get(Calendar.YEAR), utc.get(Calendar.MONTH), utc.get(Calendar.DAY_OF_MONTH), hour, minute, 0)
        set(Calendar.MILLISECOND, 0)
    }
    return local.timeInMillis
}
