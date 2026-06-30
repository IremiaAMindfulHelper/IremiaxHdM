@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * Domain model for a Journal Note / Episode.
 *
 * Episode metadata is optional: older entries (and text-only saves) leave it null.
 * Multi-select fields are kept as plain lists; the data layer serialises them.
 *
 * @property id Primary key from the database.
 * @property content The text content of the note.
 * @property createdAt Epoch timestamp in milliseconds.
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
    val strength: Int? = null,
    val places: List<String> = emptyList(),
    val activities: List<String> = emptyList(),
    val bodySignals: List<String> = emptyList(),
    val moodBefore: Int? = null,
    val moodAfter: Int? = null,
)
