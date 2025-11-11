@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.iremia.iremia.data.mantra.MantraRepository
import org.iremia.iremia.domain.mantra.Mantra

/**
 * Immutable UI state for the Mantras feature.
 *
 * @property items Currently visible mantras (latest state from repository).
 * @property isLoading True while initial load or refresh is underway.
 */
@ObjCName("MantrasState", exact = true)
data class MantrasState(
    val items: List<Mantra> = emptyList(),
    val isLoading: Boolean = false
)

/**
 * Orchestrates Mantras UI state and write operations.
 *
 * WHY
 * - Bridges shared business logic to platform UIs (SwiftUI/Compose).
 * - Exposes a hot [StateFlow] so views can subscribe reactively.
 *
 * HOW
 * - Subscribes to [MantraRepository.observeAll] and maps results into [MantrasState].
 * - Provides both suspend and callback-style mutators (`addAsync`/`removeAsync`)
 *   so iOS can call without dealing with Kotlin coroutines directly.
 *
 * THREADING
 * - Uses a [SupervisorJob] + [Dispatchers.Main] scope: failures in a child
 *   coroutine won't cancel the whole controller, and state updates are posted
 *   on main.
 *
 * LIFECYCLE
 * - Call [clear] when the owning ViewModel/ObservableObject is torn down to
 *   cancel the internal scope and avoid leaks.
 */
@ObjCName("MantrasController", exact = true)
class MantrasController(
    private val repo: MantraRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) {
    private val _state = MutableStateFlow(MantrasState(isLoading = true))
    /** Hot state stream consumed by platform UIs. */
    val state: StateFlow<MantrasState> = _state.asStateFlow()

    init {
        // NOTE: Collect repository flow once and keep controller state in sync.
        scope.launch {
            repo.observeAll()
                .onStart { _state.value = _state.value.copy(isLoading = true) }
                .collect { list ->
                    _state.value = MantrasState(items = list, isLoading = false)
                }
        }
    }

    /** Insert a new mantra (suspending API for shared/Kotlin callers). */
    suspend fun add(text: String): Unit = repo.add(text)

    /** Delete a mantra (suspending API for shared/Kotlin callers). */
    suspend fun remove(id: Long): Unit = repo.remove(id)

    /**
     * Insert a new mantra with an iOS-friendly callback (no coroutine needed).
     *
     * @param text Mantra content
     * @param onDone Called with null on success or a Throwable on failure.
     */
    fun addAsync(text: String, onDone: (Throwable?) -> Unit) {
        scope.launch {
            // NOTE: We propagate success/failure via callback for Swift interop.
            runCatching { repo.add(text) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    /**
     * Delete a mantra with an iOS-friendly callback (no coroutine needed).
     *
     * @param id Row id to delete
     * @param onDone Called with null on success or a Throwable on failure.
     */
    fun removeAsync(id: Long, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { repo.remove(id) }
                .onFailure(onDone)
                .onSuccess { onDone(null) }
        }
    }

    /** Cancel controller scope to avoid leaks when the owner is disposed. */
    fun clear(): Unit = scope.cancel()
}