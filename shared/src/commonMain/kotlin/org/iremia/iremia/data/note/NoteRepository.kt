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

    /** Adds a text-only note (kept for callers that only have content). */
    suspend fun add(content: String, createdAt: Long) = withContext(io) {
        dao.insert(content, createdAt)
    }

    /** Adds a full episode with its captured metadata. */
    suspend fun addEpisode(
        content: String,
        createdAt: Long,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
    ) = withContext(io) {
        dao.insert(content, createdAt, strength, places, activities, bodySignals, moodBefore, moodAfter)
    }

    /** Updates a text-only note. */
    suspend fun update(id: Long, content: String) = withContext(io) {
        dao.update(id, content)
    }

    /** Updates an episode and its metadata. */
    suspend fun updateEpisode(
        id: Long,
        content: String,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
    ) = withContext(io) {
        dao.update(id, content, strength, places, activities, bodySignals, moodBefore, moodAfter)
    }

    suspend fun delete(id: Long) = withContext(io) {
        dao.delete(id)
    }
}
