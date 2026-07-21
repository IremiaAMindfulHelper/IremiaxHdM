@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.iremia.iremia.data.garden.GardenPlantRepository
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.note.Note

/**
 * Immutable UI state for the Journal Notes feature.
 */
@ObjCName("NotesState", exact = true)
data class NotesState(
    val items: List<Note> = emptyList(),
    val isLoading: Boolean = false,
    val entryCount: Int = 0,
    val gardenEntries: List<Int> = emptyList()
)

/**
 * Orchestrates Journal Notes UI state and operations.
 */
@ObjCName("NotesController", exact = true)
class NotesController(
    private val repo: NoteRepository,
    // Adding a note also plants a garden item, linked back to the new entry.
    // Deleting the note later does NOT remove the plant (they are decoupled).
    private val gardenRepo: GardenPlantRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) {
    private val _state = MutableStateFlow(NotesState(isLoading = true))
    val state: StateFlow<NotesState> = _state.asStateFlow()

    init {
        scope.launch {
            repo.observeAll()
                .onStart { _state.value = _state.value.copy(isLoading = true) }
                .collect { list ->
                    val count = list.size
                    val gCount = if (count > 25) 25 else count
                    val garden = List(gCount) { 1 } + List(25 - gCount) { 0 }
                    _state.value = NotesState(
                        items = list,
                        isLoading = false,
                        entryCount = count,
                        gardenEntries = garden
                    )
                }
        }
    }

    /** Android: Add a new note and plant a linked garden item. */
    suspend fun add(content: String, createdAt: Long) {
        val id = repo.add(content, createdAt)
        gardenRepo.plant(sourceEntryId = id)
    }

    /** Android: Add a full episode with captured metadata and plant a linked garden item. */
    suspend fun addEpisode(
        content: String,
        createdAt: Long,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
    ) {
        val id = repo.addEpisode(content, createdAt, strength, places, activities, bodySignals, moodBefore, moodAfter)
        gardenRepo.plant(sourceEntryId = id)
    }

    /** Android: Update an existing note. */
    suspend fun update(id: Long, content: String) = repo.update(id, content)

    /** Android: Update an episode with metadata. */
    suspend fun updateEpisode(
        id: Long,
        content: String,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
    ) = repo.updateEpisode(id, content, strength, places, activities, bodySignals, moodBefore, moodAfter)

    /** Android: Delete a note. */
    suspend fun delete(id: Long) = repo.delete(id)

    /** iOS: Add a new note and plant a linked garden item. */
    fun addAsync(content: String, createdAt: Long, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { add(content, createdAt) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    /** iOS: Add a full episode with captured metadata and plant a linked garden item. */
    fun addEpisodeAsync(
        content: String,
        createdAt: Long,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
        onDone: (Throwable?) -> Unit,
    ) {
        scope.launch {
            runCatching {
                addEpisode(content, createdAt, strength, places, activities, bodySignals, moodBefore, moodAfter)
            }.onFailure(onDone).onSuccess { onDone(null) }
        }
    }

    /** iOS: Update an existing note. */
    fun updateAsync(id: Long, content: String, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.update(id, content) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    /** iOS: Update an episode with metadata. */
    fun updateEpisodeAsync(
        id: Long,
        content: String,
        strength: Int?,
        places: List<String>,
        activities: List<String>,
        bodySignals: List<String>,
        moodBefore: Int?,
        moodAfter: Int?,
        onDone: (Throwable?) -> Unit,
    ) {
        scope.launch {
            runCatching {
                repo.updateEpisode(id, content, strength, places, activities, bodySignals, moodBefore, moodAfter)
            }.onFailure(onDone).onSuccess { onDone(null) }
        }
    }

    /** iOS: Delete a note. */
    fun deleteAsync(id: Long, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.delete(id) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    /** Cancel scope on disposal. */
    fun clear() = scope.cancel()
}
