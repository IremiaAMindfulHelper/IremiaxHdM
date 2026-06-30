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
    onSaveNote: (String) -> Unit,
) {
    val finalEntryCount = remember { entryCount + 1 }
    var step by rememberSaveable { mutableStateOf(EpisodeStep.Intensity) }

    // --- Draft state (no persistence) ---
    val now = remember { Calendar.getInstance() }
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
                    onSaveNote(note)
                    step = EpisodeStep.Saved
                },
            )

            EpisodeStep.Saved -> EpisodeSavedScreen(
                entryCount = finalEntryCount,
                goal = INSIGHTS_GOAL,
                onInsights = onFinished,
                onHome = onFinished,
            )
        }
    }
}

/** Add [value] if absent, remove it if present (multi-select toggle). */
private fun <T> MutableList<T>.toggle(value: T) {
    if (!remove(value)) add(value)
}
