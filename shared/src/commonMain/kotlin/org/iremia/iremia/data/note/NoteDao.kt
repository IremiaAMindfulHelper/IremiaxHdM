package org.iremia.iremia.data.note

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import org.iremia.iremia.domain.note.EntryType
import org.iremia.iremia.domain.note.Note
import com.iremia.UserData

/**
 * Data Access Object for the `note` table.
 *
 * Maps episode metadata between the domain model (typed [Int]/[List]) and the
 * database representation (`Long?` and comma-separated `String?`).
 */
class NoteDao(private val db: UserData) {

    /**
     * Observe all notes, ordered by creation date (newest first).
     */
    fun observeAll(): Flow<List<Note>> =
        db.noteQueries
            .selectAll { id, content, createdAt, type, title, strength, place, activity, bodySignals, moodBefore, moodAfter ->
                Note(
                    id = id,
                    content = content,
                    createdAt = createdAt,
                    type = EntryType.fromStorage(type),
                    title = title,
                    strength = strength?.toInt(),
                    places = decodeList(place),
                    activities = decodeList(activity),
                    bodySignals = decodeList(bodySignals),
                    moodBefore = moodBefore?.toInt(),
                    moodAfter = moodAfter?.toInt(),
                )
            }
            .asFlow()
            .mapToList(Dispatchers.Default)

    /**
     * Insert a new note with optional episode metadata.
     *
     * @return The id of the newly inserted row, so callers can link a garden
     *         plant back to this entry.
     */
    fun insert(
        content: String,
        createdAt: Long,
        type: EntryType = EntryType.PANIC,
        title: String? = null,
        strength: Int? = null,
        places: List<String> = emptyList(),
        activities: List<String> = emptyList(),
        bodySignals: List<String> = emptyList(),
        moodBefore: Int? = null,
        moodAfter: Int? = null,
    ): Long = db.noteQueries.transactionWithResult {
        db.noteQueries.insert(
            content = content,
            createdAt = createdAt,
            type = type.storageValue,
            title = title?.takeIf { it.isNotBlank() },
            strength = strength?.toLong(),
            place = encodeList(places),
            activity = encodeList(activities),
            bodySignals = encodeList(bodySignals),
            moodBefore = moodBefore?.toLong(),
            moodAfter = moodAfter?.toLong(),
        )
        db.noteQueries.lastInsertedId().executeAsOne()
    }

    /**
     * Update an existing note and its episode metadata by ID.
     */
    fun update(
        id: Long,
        content: String,
        type: EntryType = EntryType.PANIC,
        title: String? = null,
        strength: Int? = null,
        places: List<String> = emptyList(),
        activities: List<String> = emptyList(),
        bodySignals: List<String> = emptyList(),
        moodBefore: Int? = null,
        moodAfter: Int? = null,
    ) {
        db.noteQueries.updateById(
            content = content,
            type = type.storageValue,
            title = title?.takeIf { it.isNotBlank() },
            strength = strength?.toLong(),
            place = encodeList(places),
            activity = encodeList(activities),
            bodySignals = encodeList(bodySignals),
            moodBefore = moodBefore?.toLong(),
            moodAfter = moodAfter?.toLong(),
            id = id,
        )
    }

    /**
     * Delete a note by ID.
     */
    fun delete(id: Long) {
        db.noteQueries.deleteById(id)
    }

    // Multi-select fields are persisted as comma-separated tokens. Empty list -> null.
    private fun encodeList(items: List<String>): String? =
        items.filter { it.isNotBlank() }.takeIf { it.isNotEmpty() }?.joinToString(",")

    private fun decodeList(raw: String?): List<String> =
        raw?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() } ?: emptyList()
}
