package org.iremia.iremia.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.Handshake
import androidx.compose.material.icons.filled.Home

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import org.iremia.iremia.routes.MantraRoute
import org.iremia.iremia.viewModels.MainViewModel
import org.iremia.iremia.shared.navigation.NavigationTarget
import org.iremia.iremia.ui.theme.AppTheme
import org.iremia.iremia.utils.localized

/**
 * The main app screen that hosts all top-level navigation tabs.
 *
 * Displays a [Scaffold] with a bottom navigation bar, allowing users to switch
 * between the main app sections: Home, Reflection, SOS, Contacts, and Profile.
 *
 * The currently active tab is observed from the provided [viewModel]'s
 * [NavigationTarget] flow via `collectAsState()`.
 *
 * Each tab displays its respective screen composable:
 * - [HomeScreen]
 * - [ReflectionScreen]
 * - [SosScreen]
 * - [ContactScreen]
 * - [ProfileScreen]
 *
 * @param viewModel The [MainViewModel] providing navigation state and handling tab selection.
 */
@Composable
fun MainScreen(viewModel: MainViewModel) {
    val context = LocalContext.current
    val currentTarget by viewModel.navigation.currentTarget.collectAsState()

    AppTheme {
        Scaffold(
            bottomBar = {
                NavigationBar {
                    listOf(
                        NavigationTarget.Home,
                        NavigationTarget.Reflection,
                        NavigationTarget.SOS,
                        NavigationTarget.Contacts,
                        NavigationTarget.Profile
                    ).forEach { target ->
                        NavigationBarItem(
                            icon = {
                                val icon = when (target) {
                                    NavigationTarget.Home -> Icons.Filled.Home
                                    NavigationTarget.Reflection -> Icons.AutoMirrored.Filled.MenuBook
                                    NavigationTarget.SOS -> Icons.Filled.Handshake
                                    NavigationTarget.Contacts -> Icons.Filled.Group
                                    NavigationTarget.Profile -> Icons.Filled.AccountCircle
                                }
                                Icon(icon, contentDescription = null)
                            },
                            label = { Text(localized(target.route).toString(context)) },
                            selected = currentTarget == target,
                            onClick = { viewModel.onTabSelected(target) }
                        )
                    }
                }
            }
        ) { padding ->
            when (currentTarget) {
                NavigationTarget.Home -> HomeScreen(modifier = Modifier.padding(padding))
                NavigationTarget.Reflection -> MantraRoute(modifier = Modifier.padding(padding))
                NavigationTarget.SOS -> SosScreen(modifier = Modifier.padding(padding))
                NavigationTarget.Contacts -> ContactScreen(modifier = Modifier.padding(padding))
                NavigationTarget.Profile -> ProfileScreen(modifier = Modifier.padding(padding))
            }
        }
    }
}
