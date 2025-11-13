package org.iremia.iremia.routes

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.controller.MantrasState
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.ui.ReflectionScreen
import org.iremia.iremia.viewModels.MantrasViewModel

@Composable
fun MantraRoute(modifier: Modifier = Modifier) {
    val ctx = LocalContext.current
    val controller = remember { SharedFactory.createMantrasController(DriverFactory(ctx)) }
    val vm = remember { MantrasViewModel(controller) }
    val state by vm.state.collectAsState(initial = MantrasState(isLoading = true))

    ReflectionScreen(
        state = state,
        onAdd = { text -> vm.add(text) },
        onRemove = { id -> vm.remove(id) },
        modifier = modifier
    )
}