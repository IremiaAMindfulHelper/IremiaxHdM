package org.iremia.iremia.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.iremia.iremia.shared.navigation.NavigationTarget

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
