package org.iremia.iremia.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.iremia.iremia.shared.navigation.NavigationTarget

/**
 * Observes a [StateFlow] from shared Kotlin code and provides its updates to Swift (iOS).
 *
 * `FlowObserver` is primarily used to bridge Kotlin's reactive flows into callback-based APIs.
 * In iOS, for example, it allows observing shared `StateFlow` values and forwarding them to
 * Swift closures on the main thread.
 *
 * The observer launches a coroutine within the provided [CoroutineScope] (default: [MainScope])
 * and collects values from the given [StateFlow].
 *
 * @constructor Creates a new observer with an optional [CoroutineScope].
 * @property scope The coroutine scope in which the observer runs.
 */
public class FlowObserver {

    private val scope: CoroutineScope
    private var job: kotlinx.coroutines.Job? = null

    public constructor() {
        this.scope = MainScope()
    }

    public constructor(scope: CoroutineScope) {
        this.scope = scope
    }

    public fun observeNavigationTarget(
        flow: StateFlow<NavigationTarget>,
        onChange: (NavigationTarget) -> Unit
    ) {
        job = scope.launch {
            flow.collect { value ->
                onChange(value)
            }
        }
    }

    public fun close() {
        job?.cancel()
    }
}
