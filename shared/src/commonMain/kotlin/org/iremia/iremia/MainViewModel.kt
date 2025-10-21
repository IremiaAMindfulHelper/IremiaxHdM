package org.iremia.iremia

import org.iremia.iremia.shared.navigation.NavigationState
import org.iremia.iremia.shared.navigation.NavigationTarget

class MainViewModel {
    val navigation = NavigationState()

    fun onTabSelected(target: NavigationTarget) {
        navigation.navigateTo(target)
    }
}