@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.interop

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

@ObjCName("KmpCancelable", exact = true)
class Cancelable(private val job: Job) {
    fun cancel() = job.cancel()
}

@ObjCName("Interop", exact = true) // <- In Swift: Interop.shared.observeState(...)
object Interop {
    fun <T> observeState(flow: StateFlow<T>, onEach: (T) -> Unit): Cancelable {
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
        val job = scope.launch { flow.collect { onEach(it) } }
        return Cancelable(job)
    }
}