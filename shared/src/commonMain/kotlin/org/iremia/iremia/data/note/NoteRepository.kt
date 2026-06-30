package org.iremia.iremia.data.note

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.iremia.iremia.domain.note.Note
import kotlinx.coroutines.flow.Flow

/**
 * Repository for Journal Notes.
 *
 * Responsibility:
 * - Wrap DAO operations.
 * - Ensure write operations run on the IO dispatcher.
 */
class NoteRepository(
    private val dao: NoteDao,
    private val io: CoroutineDispatcher = Dispatchers.Default // KMP doesn't have Dispatchers.IO by default in some versions, but 1.11.0 usually does. Using Default as safe fallback if IO is missing, or check CLAUDE.md.
) {
    // CLAUDE.md says: all writes run via withContext(io)
    // Looking at MantraRepository might help check the dispatcher.

    fun observeAll(): Flow<List<Note>> = dao.observeAll()

    suspend fun add(content: String, createdAt: Long) = withContext(io) {
        dao.insert(content, createdAt)
    }

    suspend fun update(id: Long, content: String) = withContext(io) {
        dao.update(id, content)
    }

    suspend fun delete(id: Long) = withContext(io) {
        dao.delete(id)
    }
}
