@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
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

    /** Android: Add a new note. */
    suspend fun add(content: String, createdAt: Long) = repo.add(content, createdAt)

    /** Android: Update an existing note. */
    suspend fun update(id: Long, content: String) = repo.update(id, content)

    /** Android: Delete a note. */
    suspend fun delete(id: Long) = repo.delete(id)

    /** iOS: Add a new note. */
    fun addAsync(content: String, createdAt: Long, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.add(content, createdAt) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
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
