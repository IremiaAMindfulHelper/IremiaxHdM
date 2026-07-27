@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * The data the capture wizard collects for one entry before it is saved.
 *
 * Works for both entry types: a panic entry fills the context/mood fields, a
 * journal entry typically only carries [content] (and an optional [title]). All
 * context fields are optional so a quick text-only save still works.
 *
 * @property content Free-text reflection / journal text.
 * @property type Panic or journal entry.
 * @property title Optional user title. Null derives one from [content] at display.
 * @property strength Intensity (1..10), or null if skipped / not a panic entry.
 * @property places Selected places.
 * @property activities Selected activities.
 * @property bodySignals Selected body signals.
 * @property moodBefore Mood index before (0-based), or null.
 * @property moodAfter Mood index after (0-based), or null.
 * @property createdAt When the entry happened, epoch millis. Null falls back to
 *           "now" at save time; the capture wizard sets it from the chosen date+time.
 */
@ObjCName("EpisodeDraft", exact = true)
data class EpisodeDraft(
    val content: String,
    val type: EntryType = EntryType.PANIC,
    val title: String? = null,
    val strength: Int? = null,
    val places: List<String> = emptyList(),
    val activities: List<String> = emptyList(),
    val bodySignals: List<String> = emptyList(),
    val moodBefore: Int? = null,
    val moodAfter: Int? = null,
    val createdAt: Long? = null,
)
