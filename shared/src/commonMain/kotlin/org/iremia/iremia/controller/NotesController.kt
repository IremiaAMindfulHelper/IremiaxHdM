@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.iremia.iremia.data.garden.GardenPlantRepository
import org.iremia.iremia.data.garden.PlantResult
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.note.EntryType
import org.iremia.iremia.domain.note.EpisodeDraft
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.domain.garden.PlantCategory
import kotlinx.datetime.Clock

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

    /** Android: Add a text-only note (journal) and plant a flower bed for its day. */
    suspend fun add(content: String, createdAt: Long): PlantResult {
        val id = repo.add(content, createdAt)
        return gardenRepo.plantForEntry(
            sourceEntryId = id,
            category = PlantCategory.FLOWERBED,
            entryDateMillis = createdAt,
        )
    }

    /**
     * Android: Add an entry (panic or journal) from a captured [EpisodeDraft] and
     * plant the matching garden item on the entry's day. This is the primary,
     * type-aware write path.
     *
     * @return the [PlantResult] so the saved screen can tell whether a new plant
     *         was set or the day already had this type (plan 6.2 / Block 3).
     */
    suspend fun addDraft(draft: EpisodeDraft): PlantResult {
        val createdAt = draft.createdAt ?: Clock.System.now().toEpochMilliseconds()
        val id = repo.addDraft(draft, fallbackCreatedAt = createdAt)
        val category = when (draft.type) {
            EntryType.PANIC -> PlantCategory.TREE
            EntryType.JOURNAL -> PlantCategory.FLOWERBED
        }
        return gardenRepo.plantForEntry(
            sourceEntryId = id,
            category = category,
            entryDateMillis = createdAt,
            strength = draft.strength,
        )
    }

    /** Android: Update an entry from a captured [EpisodeDraft]. */
    suspend fun updateDraft(id: Long, draft: EpisodeDraft) = repo.updateDraft(id, draft)

    /** Android: Update an existing note. */
    suspend fun update(id: Long, content: String) = repo.update(id, content)

    /** Android: Delete a note. */
    suspend fun delete(id: Long) = repo.delete(id)

    /** iOS: Add a text-only note and plant a flower bed. */
    fun addAsync(content: String, createdAt: Long, onDone: (PlantResult?, Throwable?) -> Unit) {
        scope.launch {
            runCatching { add(content, createdAt) }
                .onFailure { onDone(null, it) }
                .onSuccess { onDone(it, null) }
        }
    }

    /**
     * iOS: Add an entry (panic or journal) from a captured [EpisodeDraft] and plant
     * the matching garden item. Primary, type-aware write path for Swift. The
     * callback carries the [PlantResult] so the saved screen can adapt its text.
     */
    fun addDraftAsync(draft: EpisodeDraft, onDone: (PlantResult?, Throwable?) -> Unit) {
        scope.launch {
            runCatching { addDraft(draft) }
                .onFailure { onDone(null, it) }
                .onSuccess { onDone(it, null) }
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

    /** iOS: Update an entry from a captured [EpisodeDraft]. */
    fun updateDraftAsync(id: Long, draft: EpisodeDraft, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.updateDraft(id, draft) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
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
