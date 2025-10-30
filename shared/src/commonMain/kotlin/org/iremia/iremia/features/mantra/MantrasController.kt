package org.iremia.iremia.features.mantra

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class MantrasState(
    val items: List<Mantra> = emptyList(),
    val isLoading: Boolean = false
)

class MantrasController(
    private val repo: MantraRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) {
    private val _state = MutableStateFlow(MantrasState(isLoading = true))
    val state: StateFlow<MantrasState> = _state.asStateFlow()

    init {
        scope.launch {
            repo.observeAll()
                .onStart { _state.update { it.copy(isLoading = true) } }
                .collect { list ->
                    _state.value = MantrasState(items = list, isLoading = false)
                }
        }
    }

    suspend fun add(text: String): Unit = repo.insert(text)
    suspend fun remove(id: Long): Unit = repo.delete(id)

    /** iOS-freundliche Wrapper ohne suspend */
    fun addAsync(text: String, onDone: (Throwable?) -> Unit) {
        scope.launch {
            try {
                repo.insert(text)
                onDone(null)
            } catch (t: Throwable) {
                onDone(t)
            }
        }
    }

    fun removeAsync(id: Long, onDone: (Throwable?) -> Unit) {
        scope.launch {
            try {
                repo.delete(id)
                onDone(null)
            } catch (t: Throwable) {
                onDone(t)
            }
        }
    }

    fun clear() = scope.cancel()
}