package org.iremia.iremia.ui

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import org.iremia.iremia.utils.localized
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.safeContentPadding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import org.iremia.library.SharedRes
import androidx.compose.foundation.Image
import androidx.compose.material3.ButtonDefaults
import androidx.compose.ui.res.painterResource
import org.iremia.iremia.shared.R
import org.iremia.iremia.ui.theme.AppTheme

/**
 * This function defines the main visual structure for the Android build of Iremia.
 * It demonstrates the integration of shared resources (colors, strings, images) generated via moko-resources.
 *
 * @preview Displays a preview in Android Studio.
 *
 * @details
 * - The background color and text values come from the shared `SharedRes` resource module.
 * - The `AnimatedVisibility` composable is used to toggle visibility smoothly when the user presses the button.
 * - The UI serves as an example of how to access shared multiplatform assets on Android.
 *
 * @see SharedRes for the shared color and string resources
 */
@Composable
@Preview
fun HomeScreen(modifier: Modifier = Modifier) {
    val context = LocalContext.current

    // Local state to toggle visibility of content
    var showContent by remember { mutableStateOf(false) }

    AppTheme {
        Column(
            modifier = Modifier
                // NOTE: Use shared color from moko-resources for consistent theming
                .background(MaterialTheme.colorScheme.background)
                .safeContentPadding()
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Button(
                onClick = { showContent = !showContent }, colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.tertiaryContainer,
                    contentColor = MaterialTheme.colorScheme.onTertiaryContainer
                )
            ) {
                // NOTE: Text comes from shared string resource, enabling localization
                Text(localized(SharedRes.strings.sos_button).toString(context))
            }

            // AnimatedVisibility smoothly fades the content in and out
            AnimatedVisibility(showContent) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    // Shared string resource (title text)
                    Text(
                        text = localized(SharedRes.strings.welcome_title).toString(context),
                        color = MaterialTheme.colorScheme.primary,
                        style = MaterialTheme.typography.headlineMedium
                    )

                    // Shared image (example from resources)
                    Image(
                        painter = painterResource(id = R.drawable.onboarding_2),
                        contentDescription = null
                    )
                }
            }
        }
    }
}
