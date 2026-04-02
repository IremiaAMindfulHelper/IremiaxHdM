package org.iremia.iremia.viewModels

import org.iremia.iremia.shared.navigation.NavigationState
import org.iremia.iremia.shared.navigation.NavigationTarget

/**
 * ViewModel for the main app screen, managing navigation state.
 *
 * Exposes a [org.iremia.iremia.shared.navigation.NavigationState] via [navigation] that tracks the currently selected screen.
 * Provides [onTabSelected] to update the active navigation target.
 */
class MainViewModel {
    val navigation = NavigationState()

    /**
     * Updates the current navigation target.
     *
     * @param target The [org.iremia.iremia.shared.navigation.NavigationTarget] selected by the user.
     */
    fun onTabSelected(target: NavigationTarget) {
        navigation.navigateTo(target)
    }
}