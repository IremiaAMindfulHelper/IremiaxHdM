package org.iremia.iremia.shared.navigation

sealed class NavigationTarget(val route: String, val iconName: String) {
    data object Home : NavigationTarget("home", "home")
    data object Reflection : NavigationTarget("reflection", "reflection")
    data object SOS : NavigationTarget("sos", "sos")
    data object Contacts : NavigationTarget("contacts", "contacts")
    data object Profile : NavigationTarget("profile", "profile")
}