@file:OptIn(ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.iremia.iremia.data.mantra.MantraRepository
import org.iremia.iremia.domain.mantra.Mantra
import kotlin.experimental.ExperimentalObjCName

@ObjCName("MantrasState", exact = true)
data class MantrasState(
    val items: List<Mantra> = emptyList(),
    val isLoading: Boolean = false
)

@ObjCName("MantrasController", exact = true)
class MantrasController(
    private val repo: MantraRepository,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) {
    private val _state = MutableStateFlow(MantrasState(isLoading = true))
    val state: StateFlow<MantrasState> = _state.asStateFlow()

    init {
        scope.launch {
            repo.observeAll()
                .onStart { _state.value = _state.value.copy(isLoading = true) }
                .collect { list -> _state.value = MantrasState(items = list, isLoading = false) }
        }
    }

    suspend fun add(text: String): Unit = repo.add(text)
    suspend fun remove(id: Long): Unit = repo.remove(id)

    fun addAsync(text: String, onDone: (Throwable?) -> Unit) {
        scope.launch { runCatching { repo.add(text) }.onFailure(onDone).onSuccess { onDone(null) } }
    }
    fun removeAsync(id: Long, onDone: (Throwable?) -> Unit) {
        scope.launch { runCatching { repo.remove(id) }.onFailure(onDone).onSuccess { onDone(null) } }
    }

    fun clear(): Unit = scope.cancel()
}