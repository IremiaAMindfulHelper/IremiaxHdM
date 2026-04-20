@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.interop

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

/**
 * Lightweight cancellation handle to stop an active Kotlin Flow collection
 * that was started from Swift.
 *
 * Usage (Swift):
 * ```
 * let token = Interop.shared.observeState(flow: controller.state) { anyState in ... }
 * // later:
 * token.cancel()
 * ```
 *
 * Lifetime:
 * - Holds a coroutine Job; call [cancel] in `deinit` on the Swift side to
 *   prevent leaks when a ViewModel/ObservableObject goes away.
 */
@ObjCName("KmpCancelable", exact = true)
class Cancelable(private val job: Job) {
    /** Stop the underlying coroutine collection. */
    fun cancel() = job.cancel()
}

/**
 * Small bridge to observe Kotlin [StateFlow] from Swift.
 *
 * Design:
 * - Starts a `collect {}` on the Main dispatcher so UI updates are safe
 *   to forward to SwiftUI.
 * - Returns a [Cancelable] so Swift can end observation explicitly.
 *
 * Threading:
 * - Emission handling runs on `Dispatchers.Main`.
 *   // NOTE: Intentionally on main to align with SwiftUI's main-thread model.
 *
 * Interop:
 * - Generics are erased across Obj-C/Swift boundaries; Swift receives `Any`
 *   and should cast to the expected state type (or map to a Swift model).
 *
 * Limits:
 * - The bridge does not buffer or replay values beyond what StateFlow does.
 *   // TODO: If we ever need backpressure/buffering for non-UI flows,
 *   // introduce a variant with channel-based buffering.
 *
 * @param flow   The [StateFlow] to observe.
 * @param onEach Callback invoked for every emitted value.
 * @return A [Cancelable] to stop the observation.
 */
@ObjCName("Interop", exact = true) // In Swift: Interop.shared.observeState(...)
object Interop {
    fun <T> observeState(
        flow: StateFlow<T>,
        onEach: (T) -> Unit
    ): Cancelable {
        // Dedicated scope with SupervisorJob so one failed collector
        // doesn't cancel other UI collectors accidentally.
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        // Start collecting on main; SwiftUI expects main-thread updates.
        val job = scope.launch {
            flow.collect { value ->
                onEach(value)
            }
        }
        return Cancelable(job)
    }
}