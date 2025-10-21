package org.iremia.iremia.shared.navigation

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class NavigationState {
    private val _currentTarget = MutableStateFlow<NavigationTarget>(NavigationTarget.Home)
    val currentTarget: StateFlow<NavigationTarget> = _currentTarget

    fun navigateTo(target: NavigationTarget) {
        _currentTarget.value = target
    }
}