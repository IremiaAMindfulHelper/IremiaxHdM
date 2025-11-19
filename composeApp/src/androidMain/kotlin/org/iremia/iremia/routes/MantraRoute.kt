package org.iremia.iremia.routes

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import org.iremia.iremia.bridge.SharedFactory
import org.iremia.iremia.controller.MantrasState
import org.iremia.iremia.db.DriverFactory
import org.iremia.iremia.ui.ReflectionScreen
import org.iremia.iremia.viewModels.MantrasViewModel

/**
 * Route that wires shared Mantras business logic to the Android UI layer.
 *
 * Responsibilities:
 * - Create the shared MantrasController via [SharedFactory] using an Android-specific
 *   [DriverFactory] (requires a [LocalContext] for SQLDelight's Android driver).
 * - Own a [MantrasViewModel] instance for this screen (kept stable with [remember]).
 * - Collect the controller state into Compose state, providing an initial loading frame.
 * - Delegate rendering and user interactions to [ReflectionScreen].
 *
 * Design notes:
 * - This route stays thin and contains no UI itself; it only composes dependencies and
 *   passes them down. That keeps navigation boundaries clean and testable.
 *
 * @param modifier Optional [Modifier] propagated to [ReflectionScreen].
 */
@Composable
fun MantraRoute(modifier: Modifier = Modifier) {
    val ctx = LocalContext.current

    // NOTE: Build the shared controller once per route lifetime.
    // remember{} ensures we don't recreate on every recomposition.
    val controller = remember { SharedFactory.createMantrasController(DriverFactory(ctx)) }

    // NOTE: Keep the ViewModel lifecycle-tied to this route.
    // If you later hoist this into a DI container, replace remember{} accordingly.
    val vm = remember { MantrasViewModel(controller) }

    // NOTE: Provide an initial state to avoid a null/empty flash on first composition.
    val state by vm.state.collectAsState(initial = MantrasState(isLoading = true))

    // Delegate to the feature screen; keep this route free of UI details.
    ReflectionScreen(
        state = state,
        onAdd = { text -> vm.add(text) },
        onRemove = { id -> vm.remove(id) },
        modifier = modifier
    )
}