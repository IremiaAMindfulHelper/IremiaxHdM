@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * Domain model for a Journal Note.
 *
 * @property id Primary key from the database.
 * @property content The text content of the note.
 * @property createdAt Epoch timestamp in milliseconds.
 */
@ObjCName("Note", exact = true)
data class Note(
    val id: Long,
    val content: String,
    val createdAt: Long
)
