package org.iremia.iremia.shared.navigation

import dev.icerock.moko.resources.StringResource
import org.iremia.library.SharedRes

/**
 * Represents a navigation target (tab) in the app.
 *
 * The sealed class ensures that all possible navigation targets are defined in one place,
 * making it safe to use in `when` expressions without an `else` branch.
 *
 * Predefined navigation targets:
 * - [Home]: Home screen
 * - [Reflection]: Reflection screen
 * - [SOS]: SOS screen
 * - [Contacts]: Contacts screen
 * - [Profile]: Profile screen
 *
 * @property route The [StringResource] used as the label or route name for this target.
 */
sealed class NavigationTarget(val route: StringResource) {
    data object Home : NavigationTarget(SharedRes.strings.home)
    data object Reflection : NavigationTarget(SharedRes.strings.reflection)
    data object SOS : NavigationTarget(SharedRes.strings.sos)
    data object Contacts : NavigationTarget(SharedRes.strings.contacts)
    data object Profile : NavigationTarget(SharedRes.strings.profile)
}