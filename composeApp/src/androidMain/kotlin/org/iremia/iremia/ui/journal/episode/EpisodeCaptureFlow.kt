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
import org.iremia.iremia.domain.note.EpisodeDraft
import org.iremia.iremia.ui.theme.IremiaColors
import java.util.Calendar

/** The four stages of the "Episode festhalten" wizard. */
private enum class EpisodeStep { Intensity, Context, Reflection, Saved }

/** Sample totals for the confirmation screen (replaced by real data later). */
private const val SAMPLE_ENTRY_COUNT = 26
private const val INSIGHTS_GOAL = 30

/**
 * Self-contained "Episode festhalten" wizard.
 *
 * Holds the in-progress draft purely in UI state — nothing is persisted yet; the
 * flow just needs to "work" end to end. [onClose] backs out of the first step,
 * [onFinished] dismisses after the confirmation screen.
 */
@Composable
fun EpisodeCaptureFlow(
    entryCount: Int,
    onClose: () -> Unit,
    onFinished: () -> Unit,
    onViewGarden: () -> Unit = onFinished,
    onSaveEpisode: (EpisodeDraft) -> Unit,
) {
    val finalEntryCount = remember { entryCount + 1 }
    var step by rememberSaveable { mutableStateOf(EpisodeStep.Intensity) }

    // --- Draft state (no persistence) ---
    val now = remember { Calendar.getInstance() }
    // Selected day (start-of-day millis, UTC) + time-of-day. Defaults to today/now.
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
        when (step) {
            EpisodeStep.Intensity -> EpisodeIntensityStep(
                dateMillis = selectedDateMillis,
                onDateChange = { selectedDateMillis = it },
                hour = hour,
                minute = minute,
                onTimeChange = { h, m -> hour = h; minute = m },
                strength = strength,
                onStrengthChange = { strength = it },
                onBack = onClose,
                onNext = { step = EpisodeStep.Context },
                onSkip = { step = EpisodeStep.Context },
            )

            EpisodeStep.Context -> EpisodeContextStep(
                places = places,
                onTogglePlace = { places.toggle(it) },
                activities = activities,
                onToggleActivity = { activities.toggle(it) },
                bodySignals = bodySignals,
                onToggleSignal = { bodySignals.toggle(it) },
                onBack = { step = EpisodeStep.Intensity },
                onNext = { step = EpisodeStep.Reflection },
                onSkip = { step = EpisodeStep.Reflection },
            )

            EpisodeStep.Reflection -> EpisodeReflectionStep(
                note = note,
                onNoteChange = { note = it },
                moodBefore = moodBefore,
                onMoodBefore = { moodBefore = it },
                moodAfter = moodAfter,
                onMoodAfter = { moodAfter = it },
                onBack = { step = EpisodeStep.Context },
                onSave = {
                    onSaveEpisode(
                        EpisodeDraft(
                            content = note,
                            strength = strength.toInt(),
                            places = places.toList(),
                            activities = activities.toList(),
                            bodySignals = bodySignals.toList(),
                            moodBefore = moodBefore.takeIf { it >= 0 },
                            moodAfter = moodAfter.takeIf { it >= 0 },
                            createdAt = combineDateTime(selectedDateMillis, hour, minute),
                        )
                    )
                    step = EpisodeStep.Saved
                },
            )

            EpisodeStep.Saved -> EpisodeSavedScreen(
                entryCount = finalEntryCount,
                goal = INSIGHTS_GOAL,
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
