package org.iremia.iremia.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.ui.home.HomeScreen
import org.iremia.iremia.ui.home.HomeViewModel
import org.iremia.iremia.ui.journal.JournalScreen
import org.iremia.iremia.ui.journal.JournalViewModel
import org.iremia.iremia.ui.journal.episode.EpisodeCaptureFlow
import org.iremia.iremia.ui.navigation.IremiaBottomBar
import org.iremia.iremia.ui.navigation.MainTab
import org.iremia.iremia.ui.theme.AppTheme
import org.iremia.iremia.ui.theme.IremiaColors
import org.iremia.iremia.utils.localized
import org.iremia.library.SharedRes

/**
 * The main app screen that hosts the top-level navigation tabs.
 *
 * Displays a [Scaffold] with the Iremia bottom navigation bar ([IremiaBottomBar])
 * and a persistent "+" FAB in the Scaffold's floating-action-button slot, so
 * creating an entry is reachable from *every* tab (Start, Training, Journal,
 * Wellbeing). The capture flow is hosted here at the shell level and shares the
 * single [JournalViewModel] with the Journal tab.
 */
@Composable
fun MainScreen() {
    var selectedTab by rememberSaveable { mutableStateOf(MainTab.Start) }

    val context = LocalContext.current
    val driverFactory = remember { DriverFactory(context) }

    val homeViewModel: HomeViewModel = viewModel(
        factory = viewModelFactory {
            initializer { HomeViewModel(SharedFactory.createMotivationController(driverFactory)) }
        }
    )
    // Single notes VM shared by the FAB's capture flow and the Journal tab, so both
    // observe one NotesController instance.
    val notesViewModel: JournalViewModel = viewModel(
        factory = viewModelFactory {
            initializer { JournalViewModel(SharedFactory.createNotesController(driverFactory)) }
        }
    )

    val homeState by homeViewModel.state.collectAsState()

    // Capture-flow + garden coordination state, hoisted to the shell.
    var showCaptureFlow by rememberSaveable { mutableStateOf(false) }
    var openGardenSignal by rememberSaveable { mutableStateOf(false) }

    fun openCaptureFlow() {
        notesViewModel.clearPlantResult()
        showCaptureFlow = true
    }

    AppTheme {
        Scaffold(
            bottomBar = {
                IremiaBottomBar(
                    selectedTab = selectedTab,
                    onTabSelected = { selectedTab = it },
                )
            },
            floatingActionButton = {
                FloatingActionButton(
                    onClick = { openCaptureFlow() },
                    containerColor = IremiaColors.Teal700,
                    contentColor = IremiaColors.White,
                ) {
                    Icon(
                        Icons.Filled.Add,
                        contentDescription = localized(SharedRes.strings.journal_fab).toString(context),
                    )
                }
            },
        ) { padding ->
            val contentModifier = Modifier.padding(padding)
            when (selectedTab) {
                MainTab.Start -> HomeScreen(
                    modifier = contentModifier,
                    insight = homeState.insight,
                    onOpenJournal = { selectedTab = MainTab.Journal },
                )
                MainTab.Training -> PlaceholderScreen(MainTab.Training.labelRes, contentModifier)
                MainTab.Journal -> JournalScreen(
                    viewModel = notesViewModel,
                    modifier = contentModifier,
                    openCaptureFlow = { openCaptureFlow() },
                    openGardenSignal = openGardenSignal,
                    onGardenShown = { openGardenSignal = false },
                )
                MainTab.Wellbeing -> PlaceholderScreen(MainTab.Wellbeing.labelRes, contentModifier)
            }
        }

        // Capture flow, hosted at the shell so the FAB works on any tab.
        if (showCaptureFlow) {
            val state by notesViewModel.state.collectAsState()
            val plantResult by notesViewModel.lastPlantResult.collectAsState()
            Dialog(
                onDismissRequest = { showCaptureFlow = false },
                properties = DialogProperties(
                    usePlatformDefaultWidth = false,
                    dismissOnClickOutside = false,
                ),
            ) {
                EpisodeCaptureFlow(
                    entryCount = state.entryCount,
                    onClose = { showCaptureFlow = false },
                    onFinished = { showCaptureFlow = false },
                    onViewGarden = {
                        showCaptureFlow = false
                        // Switch to the Journal tab and ask it to open the garden.
                        selectedTab = MainTab.Journal
                        openGardenSignal = true
                    },
                    onSaveEpisode = { draft -> notesViewModel.addEntry(draft) },
                    plantResult = plantResult,
                )
            }
        }
    }
}
