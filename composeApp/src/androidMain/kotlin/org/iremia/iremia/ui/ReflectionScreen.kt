package org.iremia.iremia.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.controller.MantrasState
import org.iremia.iremia.db.DriverFactory

@Composable
fun ReflectionScreen(state: MantrasState, onAdd: (String) -> Unit, onRemove: (Long) -> Unit, modifier: Modifier = Modifier) {
    val context = LocalContext.current
    // Shared KMP-Controller nur einmal pro Composable erzeugen
    val controller = remember {
        SharedFactory.createMantrasController(driverFactory = DriverFactory(context))
    }
    val scope = rememberCoroutineScope()

    // State aus dem KMP-StateFlow beobachten
    val state by controller.state.collectAsState()

    var input by rememberSaveable { mutableStateOf("") }
    val focusManager = LocalFocusManager.current

    // Controller aufräumen, wenn der Screen disposed wird
    DisposableEffect(Unit) {
        onDispose { controller.clear() }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        // Header
        Text(text = "Reflections (Mantras)")

        Spacer(Modifier.height(12.dp))

        // Liste
        Box(Modifier.weight(1f).fillMaxWidth()) {
            when {
                state.isLoading -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                }
                state.items.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("Noch keine Mantras")
                    }
                }
                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(state.items, key = { it.id }) { item ->
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = item.text,
                                    modifier = Modifier.weight(1f)
                                )
                                Spacer(Modifier.width(8.dp))
                                Button(onClick = {
                                    scope.launch { controller.remove(item.id) }
                                }) {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(12.dp))

        // Eingabe + Add
        Row(verticalAlignment = Alignment.CenterVertically) {
            OutlinedTextField(
                value = input,
                onValueChange = { input = it },
                modifier = Modifier.weight(1f),
                singleLine = true,
                placeholder = { Text("Neues Mantra …") },
                // Single-line field: the IME shows a "done" key that closes the keyboard.
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() }),
            )
            Spacer(Modifier.width(8.dp))
            Button(
                enabled = input.trim().isNotEmpty(),
                onClick = {
                    val text = input.trim()
                    if (text.isNotEmpty()) {
                        scope.launch { controller.add(text) }
                        input = ""
                    }
                }
            ) { Text("Add") }
        }
    }
}