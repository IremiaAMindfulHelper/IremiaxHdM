@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * The data the capture wizard collects for one episode before it is saved.
 *
 * All context fields are optional so a quick text-only save still works.
 *
 * @property content Free-text reflection.
 * @property strength Intensity (1..10), or null if skipped.
 * @property places Selected places.
 * @property activities Selected activities.
 * @property bodySignals Selected body signals.
 * @property moodBefore Mood index before (0-based), or null.
 * @property moodAfter Mood index after (0-based), or null.
 * @property createdAt When the episode happened, epoch millis. Null falls back to
 *           "now" at save time; the capture wizard sets it from the chosen date+time.
 */
@ObjCName("EpisodeDraft", exact = true)
data class EpisodeDraft(
    val content: String,
    val strength: Int? = null,
    val places: List<String> = emptyList(),
    val activities: List<String> = emptyList(),
    val bodySignals: List<String> = emptyList(),
    val moodBefore: Int? = null,
    val moodAfter: Int? = null,
    val createdAt: Long? = null,
)
