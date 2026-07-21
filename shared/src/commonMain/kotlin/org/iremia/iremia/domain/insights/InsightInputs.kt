@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.insights

import kotlin.native.ObjCName

/**
 * A completed relaxation/breathing exercise session.
 *
 * Not persisted yet — provided by a dummy generator for now so the behavior-cluster
 * and initiative analyses have data. When exercise tracking lands, a real source can
 * implement [ExerciseSource] without touching the scoring.
 *
 * @property completedAt Timestamp in millis.
 * @property durationSeconds How long the session lasted.
 */
@ObjCName("ExerciseSession", exact = true)
data class ExerciseSession(
    val completedAt: Long,
    val durationSeconds: Int,
)

/**
 * A journal-like data point the algorithm reasons over. Real entries map onto this;
 * dummy historical entries can be generated in the same shape.
 *
 * @property createdAt Timestamp in millis.
 * @property intensity Panic intensity 1..10 (from note.strength), or null if unknown.
 * @property moodBefore Mood index 0..4 before, or null.
 * @property moodAfter Mood index 0..4 after, or null.
 * @property sentiment Lightweight comment sentiment in -1f..1f (0 = neutral/unknown).
 */
@ObjCName("EntrySignal", exact = true)
data class EntrySignal(
    val createdAt: Long,
    val intensity: Int?,
    val moodBefore: Int?,
    val moodAfter: Int?,
    val sentiment: Float,
)

/** Source of exercise sessions. Real implementation swaps in later. */
interface ExerciseSource {
    fun sessions(): List<ExerciseSession>
}

/** Source of extra historical entries (for new users with little real data). */
interface HistoricalEntrySource {
    fun entries(): List<EntrySignal>
}
