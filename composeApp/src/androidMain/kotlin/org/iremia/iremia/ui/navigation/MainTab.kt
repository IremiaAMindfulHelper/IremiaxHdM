package org.iremia.iremia.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.SelfImprovement
import androidx.compose.ui.graphics.vector.ImageVector
import dev.icerock.moko.resources.StringResource
import org.iremia.library.SharedRes

/**
 * Top-level navigation tabs of the high-fidelity prototype (Android Compose).
 *
 * This is an Android-local navigation model: it intentionally does NOT reuse the
 * shared [org.iremia.iremia.shared.navigation.NavigationTarget], because that type
 * is also consumed by the iOS app. Keeping the prototype's tab set local lets us
 * iterate on the Android redesign without touching shared navigation or iOS.
 *
 * NOTE: Icons approximate the prototype and should be confirmed against the final
 * Figma assets; labels resolve through moko-resources so they stay localized.
 *
 * @property labelRes The localized label shown under the tab icon.
 * @property icon The Material icon displayed for the tab.
 */
enum class MainTab(
    val labelRes: StringResource,
    val icon: ImageVector,
) {
    Start(SharedRes.strings.home, Icons.Filled.Home),
    Training(SharedRes.strings.training, Icons.Filled.FitnessCenter),
    Journal(SharedRes.strings.journal, Icons.AutoMirrored.Filled.MenuBook),
    Wellbeing(SharedRes.strings.wellbeing, Icons.Filled.SelfImprovement),
}
