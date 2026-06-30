package org.iremia.iremia.data.note

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import org.iremia.iremia.domain.note.Note
import com.iremia.UserData

/**
 * Data Access Object for the `note` table.
 */
class NoteDao(private val db: UserData) {

    /**
     * Observe all notes, ordered by creation date (newest first).
     */
    fun observeAll(): Flow<List<Note>> =
        db.noteQueries
            .selectAll { id, content, createdAt ->
                Note(id = id, content = content, createdAt = createdAt)
            }
            .asFlow()
            .mapToList(Dispatchers.Default)

    /**
     * Insert a new note.
     */
    fun insert(content: String, createdAt: Long) {
        db.noteQueries.insert(content, createdAt)
    }

    /**
     * Update an existing note by ID.
     */
    fun update(id: Long, content: String) {
        db.noteQueries.updateById(content, id)
    }

    /**
     * Delete a note by ID.
     */
    fun delete(id: Long) {
        db.noteQueries.deleteById(id)
    }
}
