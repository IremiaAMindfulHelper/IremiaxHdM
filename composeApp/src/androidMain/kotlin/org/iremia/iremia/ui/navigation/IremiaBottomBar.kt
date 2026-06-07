package org.iremia.iremia.ui.navigation

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import org.iremia.iremia.utils.localized

/**
 * Iremia bottom navigation bar.
 *
 * A thin wrapper around the Material 3 [NavigationBar] that renders one item per
 * [MainTab]. Colors, the active-tab indicator and shapes are inherited from the
 * app [androidx.compose.material3.MaterialTheme], so the bar already follows the
 * Iremia brand without extra styling.
 *
 * The bar is stateless: the selected tab and selection callback are hoisted to the
 * caller, keeping this component reusable and easy to preview/test.
 *
 * @param selectedTab The currently active tab.
 * @param onTabSelected Invoked with the tapped tab when the user selects an item.
 * @param modifier Modifier applied to the underlying [NavigationBar].
 */
@Composable
fun IremiaBottomBar(
    selectedTab: MainTab,
    onTabSelected: (MainTab) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    NavigationBar(modifier = modifier) {
        MainTab.entries.forEach { tab ->
            val label = localized(tab.labelRes).toString(context)
            NavigationBarItem(
                selected = selectedTab == tab,
                onClick = { onTabSelected(tab) },
                icon = { Icon(imageVector = tab.icon, contentDescription = label) },
                label = { Text(label) },
            )
        }
    }
}
