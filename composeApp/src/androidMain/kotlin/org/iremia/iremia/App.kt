package org.iremia.iremia

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.safeContentPadding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import dev.icerock.moko.resources.desc.Resource
import dev.icerock.moko.resources.desc.StringDesc
import org.iremia.library.SharedRes
import androidx.compose.ui.graphics.Color

@Composable
@Preview
fun App() {
    val context = LocalContext.current
    var showContent by remember { mutableStateOf(false) }

    MaterialTheme {
        Column(
            modifier = Modifier
                .background(Color(SharedRes.colors.secondary.getColor(context)))
                .safeContentPadding()
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Button(onClick = { showContent = !showContent }) {
                // 🔹 Shared-String für den Button
                Text(StringDesc.Resource(SharedRes.strings.sos_button).toString(context))

            }

            AnimatedVisibility(showContent) {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    // 🔹 Shared-String für den Titel
                    Text(StringDesc.Resource(SharedRes.strings.welcome_title).toString(context))
                }
            }
        }
    }
}