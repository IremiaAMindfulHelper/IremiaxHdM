package org.iremia.iremia.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.AccountCircle
import androidx.compose.material.icons.filled.Group
import androidx.compose.material.icons.filled.Handshake
import androidx.compose.material.icons.automirrored.filled.Help
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
import org.iremia.iremia.MainViewModel
import org.iremia.iremia.shared.navigation.NavigationTarget

@Composable
fun MainScreen(viewModel: MainViewModel) {
    val currentTarget by viewModel.navigation.currentTarget.collectAsState()

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
                            else -> Icons.AutoMirrored.Filled.Help
                        }
                            Icon(icon, contentDescription = null)
                               },
                        label = { Text(target.route) },
                        selected = currentTarget == target,
                        onClick = { viewModel.onTabSelected(target) }
                    )
                }
            }
        }
    ) { padding ->
        when (currentTarget) {
            NavigationTarget.Home -> HomeScreen(modifier = Modifier.padding(padding))
            NavigationTarget.Reflection -> ReflectionScreen(modifier = Modifier.padding(padding))
            NavigationTarget.SOS -> SosScreen(modifier = Modifier.padding(padding))
            NavigationTarget.Contacts -> ContactScreen(modifier = Modifier.padding(padding))
            NavigationTarget.Profile -> ProfileScreen(modifier = Modifier.padding(padding))
        }
    }
}
