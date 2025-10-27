package org.iremia.iremia

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import org.iremia.iremia.ui.MainScreen
import org.iremia.iremia.viewModels.MainViewModel

/**
 * Main entry point for the Android app.
 *
 * Hosts the [MainScreen] composable and provides it with the [MainViewModel] for
 * managing app state, including navigation and business logic.
 */
class MainActivity : ComponentActivity() {

    private val viewModel = MainViewModel()

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            MainScreen(viewModel)
        }
    }
}