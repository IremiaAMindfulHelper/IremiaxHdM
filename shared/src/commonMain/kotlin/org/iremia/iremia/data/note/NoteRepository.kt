package org.iremia.iremia.data.note

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.iremia.iremia.domain.note.EntryType
import org.iremia.iremia.domain.note.EpisodeDraft
import org.iremia.iremia.domain.note.Note
import kotlinx.coroutines.flow.Flow

/**
 * Repository for journal entries (panic and journal types).
 *
 * Responsibility:
 * - Wrap DAO operations.
 * - Ensure write operations run on the IO dispatcher.
 */
class NoteRepository(
    private val dao: NoteDao,
    private val io: CoroutineDispatcher = Dispatchers.Default
) {

    fun observeAll(): Flow<List<Note>> = dao.observeAll()

    /**
     * Adds an entry from a captured [EpisodeDraft]. Works for both entry types:
     * a panic draft carries the context/mood fields, a journal draft usually only
     * carries text. @return the new entry id.
     */
    suspend fun addDraft(draft: EpisodeDraft, fallbackCreatedAt: Long): Long = withContext(io) {
        dao.insert(
            content = draft.content,
            createdAt = draft.createdAt ?: fallbackCreatedAt,
            type = draft.type,
            title = draft.title,
            strength = draft.strength,
            places = draft.places,
            activities = draft.activities,
            bodySignals = draft.bodySignals,
            moodBefore = draft.moodBefore,
            moodAfter = draft.moodAfter,
        )
    }

    /** Updates an existing entry from a captured [EpisodeDraft]. */
    suspend fun updateDraft(id: Long, draft: EpisodeDraft) = withContext(io) {
        dao.update(
            id = id,
            content = draft.content,
            type = draft.type,
            title = draft.title,
            strength = draft.strength,
            places = draft.places,
            activities = draft.activities,
            bodySignals = draft.bodySignals,
            moodBefore = draft.moodBefore,
            moodAfter = draft.moodAfter,
        )
    }

    /** Adds a text-only entry (defaults to a journal entry). @return the new entry id. */
    suspend fun add(
        content: String,
        createdAt: Long,
        type: EntryType = EntryType.JOURNAL,
    ): Long = withContext(io) {
        dao.insert(content, createdAt, type = type)
    }

    /** Adds a full panic episode with its captured metadata. @return the new entry id. */
    suspend fun addEpisode(
        content: String,
        createdAt: Long,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
    ): Long = withContext(io) {
        dao.insert(
            content, createdAt, EntryType.PANIC, null,
            strength, places, activities, bodySignals, moodBefore, moodAfter,
        )
    }

    /** Updates a text-only entry. */
    suspend fun update(id: Long, content: String) = withContext(io) {
        dao.update(id, content)
    }

    /** Updates a panic episode and its metadata. */
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
        dao.update(
            id, content, EntryType.PANIC, null,
            strength, places, activities, bodySignals, moodBefore, moodAfter,
        )
    }

    suspend fun delete(id: Long) = withContext(io) {
        dao.delete(id)
    }
}
