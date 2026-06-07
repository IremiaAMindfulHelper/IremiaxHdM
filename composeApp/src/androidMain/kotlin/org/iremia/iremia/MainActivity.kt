package org.iremia.iremia

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import org.iremia.iremia.ui.MainScreen

/**
 * Main entry point for the Android app.
 *
 * Hosts the [MainScreen] composable, which owns the top-level tab navigation of the
 * high-fidelity prototype.
 */
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            MainScreen()
        }
    }
}