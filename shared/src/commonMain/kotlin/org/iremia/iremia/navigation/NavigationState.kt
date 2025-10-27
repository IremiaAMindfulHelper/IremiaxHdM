package org.iremia.iremia.shared.navigation

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

/**
 * Holds and manages the current navigation target for the app.
 *
 * Provides a [StateFlow] of [NavigationTarget] that can be observed by UI layers
 * (SwiftUI or Jetpack Compose) to reactively update the displayed screen.
 *
 * Use [navigateTo] to change the active target.
 */
class NavigationState {
    private val _currentTarget = MutableStateFlow<NavigationTarget>(NavigationTarget.Home)
    val currentTarget: StateFlow<NavigationTarget> = _currentTarget

    /**
     * Updates the current navigation target.
     *
     * @param target The [NavigationTarget] to navigate to.
     */
    fun navigateTo(target: NavigationTarget) {
        _currentTarget.value = target
    }
}