@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * Domain model for a journal entry (panic or journal type).
 *
 * Episode metadata is optional: journal entries and text-only saves leave it null.
 * Multi-select fields are kept as plain lists; the data layer serialises them.
 *
 * @property id Primary key from the database.
 * @property content The text content of the entry.
 * @property createdAt Epoch timestamp in milliseconds.
 * @property type Whether this is a panic or a journal entry.
 * @property title User-set title, or null to derive one from [content] on display.
 * @property strength Episode intensity (1..10), or null.
 * @property places Selected places, empty when none.
 * @property activities Selected activities, empty when none.
 * @property bodySignals Selected body signals, empty when none.
 * @property moodBefore Mood index before (0-based), or null.
 * @property moodAfter Mood index after (0-based), or null.
 */
@ObjCName("Note", exact = true)
data class Note(
    val id: Long,
    val content: String,
    val createdAt: Long,
    val type: EntryType = EntryType.PANIC,
    val title: String? = null,
    val strength: Int? = null,
    val places: List<String> = emptyList(),
    val activities: List<String> = emptyList(),
    val bodySignals: List<String> = emptyList(),
    val moodBefore: Int? = null,
    val moodAfter: Int? = null,
) {
    /**
     * The title to show in lists and detail views: the user's [title] when set,
     * otherwise a title derived locally from [content].
     */
    val displayTitle: String
        get() = title?.takeIf { it.isNotBlank() } ?: deriveTitle(content)
}
