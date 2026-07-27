@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.insights.EntrySignal
import org.iremia.iremia.domain.insights.MotivationAlgorithm
import org.iremia.iremia.domain.insights.MotivationInsight
import org.iremia.iremia.domain.insights.SentimentAnalyzer
import org.iremia.iremia.domain.note.Note

/**
 * Immutable UI state for the home screen's motivation insight (blue hero card).
 */
@ObjCName("MotivationState", exact = true)
data class MotivationState(
    val insight: MotivationInsight = MotivationInsight.placeholder,
    val isLoading: Boolean = true,
)

/**
 * Produces the home screen's motivation insight by combining real journal entries
 * with deterministic dummy generators for signals not yet persisted (exercise
 * sessions and extra historical entries).
 *
 * Real entry data feeds intensity, mood, timing and comment sentiment; dummy data
 * fills the gaps so the algorithm runs end-to-end today. See [MotivationAlgorithm].
 */
@ObjCName("MotivationController", exact = true)
class MotivationController(
    private val noteRepo: NoteRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main),
) {
    private val _state = MutableStateFlow(MotivationState())
    val state: StateFlow<MotivationState> = _state.asStateFlow()

    init {
        scope.launch {
            noteRepo.observeAll().collect { notes ->
                _state.value = MotivationState(insight = computeInsight(notes), isLoading = false)
            }
        }
    }

    private fun computeInsight(notes: List<Note>): MotivationInsight {
        val now = Clock.System.now().toEpochMilliseconds()

        // Real entries -> signals.
        val realSignals = notes.map { note ->
            EntrySignal(
                createdAt = note.createdAt,
                intensity = note.strength,
                moodBefore = note.moodBefore,
                moodAfter = note.moodAfter,
                sentiment = SentimentAnalyzer.score(note.content),
                entryId = note.id,
            )
        }

        // The insight is driven purely by real journal entries so it reacts live to
        // what the user actually logs (demo-friendly). Dummy generators remain in
        // [DummyInsightData] for future signals (exercises) but are not mixed in here.
        return MotivationAlgorithm.compute(
            now = now,
            entries = realSignals,
            exercises = emptyList(),
        )
    }

    /** iOS: no-op refresh hook (state is already reactive); kept for symmetry. */
    fun refreshAsync(onDone: (Throwable?) -> Unit) {
        onDone(null)
    }

    /** Cancel scope on disposal. Android calls in onCleared(), iOS in deinit. */
    fun clear() = scope.cancel()
}
