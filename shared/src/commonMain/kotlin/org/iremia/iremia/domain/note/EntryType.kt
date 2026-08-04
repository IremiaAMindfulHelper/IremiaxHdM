@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.note

import kotlin.native.ObjCName

/**
 * The kind of journal entry the user creates.
 *
 * - [PANIC]: the existing panic-attack entry (intensity scale, context, reflection).
 * - [JOURNAL]: a free/guided journal entry (text is the only required field).
 *
 * Persisted as a lowercase token ([storageValue]) in the `note.type` column so the
 * database representation stays stable and readable. Older rows migrate to [PANIC].
 */
@ObjCName("EntryType", exact = true)
enum class EntryType(val storageValue: String) {
    PANIC("panic"),
    JOURNAL("journal");

    companion object {
        /** Maps a stored token back to an [EntryType], defaulting to [PANIC]. */
        fun fromStorage(value: String?): EntryType =
            entries.firstOrNull { it.storageValue == value } ?: PANIC
    }
}
