package org.iremia.iremia.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.ui.home.HomeScreen
import org.iremia.iremia.ui.home.HomeViewModel
import org.iremia.iremia.ui.journal.JournalScreen
import org.iremia.iremia.ui.navigation.IremiaBottomBar
import org.iremia.iremia.ui.navigation.MainTab
import org.iremia.iremia.ui.theme.AppTheme

/**
 * The main app screen that hosts the top-level navigation tabs.
 *
 * Displays a [Scaffold] with the Iremia bottom navigation bar ([IremiaBottomBar]),
 * letting users switch between the high-fidelity prototype sections defined in
 * [MainTab]: Start, Training, Journal and Wellbeing.
 *
 * The selected tab is kept as Android-local UI state (via [rememberSaveable]) so it
 * survives configuration changes. This is intentionally decoupled from the shared
 * navigation model, which the iOS app still owns.
 *
 * Start shows the existing [HomeScreen]; the not-yet-built tabs show a
 * [PlaceholderScreen] until their screens land (SIC-18).
 */
@Composable
fun MainScreen() {
    var selectedTab by rememberSaveable { mutableStateOf(MainTab.Start) }

    val context = LocalContext.current
    val driverFactory = androidx.compose.runtime.remember { DriverFactory(context) }
    val homeViewModel: HomeViewModel = viewModel(
        factory = viewModelFactory {
            initializer { HomeViewModel(SharedFactory.createMotivationController(driverFactory)) }
        }
    )
    val homeState by homeViewModel.state.collectAsState()

    AppTheme {
        Scaffold(
            bottomBar = {
                IremiaBottomBar(
                    selectedTab = selectedTab,
                    onTabSelected = { selectedTab = it },
                )
            },
        ) { padding ->
            val contentModifier = Modifier.padding(padding)
            when (selectedTab) {
                MainTab.Start -> HomeScreen(modifier = contentModifier, insight = homeState.insight)
                MainTab.Training -> PlaceholderScreen(MainTab.Training.labelRes, contentModifier)
                MainTab.Journal -> JournalScreen(modifier = contentModifier)
                MainTab.Wellbeing -> PlaceholderScreen(MainTab.Wellbeing.labelRes, contentModifier)
            }
        }
    }
}
