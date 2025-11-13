package org.iremia.iremia.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.MantrasController
import org.iremia.iremia.controller.MantrasState

/**
 * Thin Android wrapper around the shared [MantrasController].
 *
 * Why this exists:
 * - Exposes a platform-friendly API for Compose (Android) while the business
 *   logic and state live in KMP.
 * - Uses [viewModelScope] so jobs are tied to the Android lifecycle and are
 *   cancelled automatically when the ViewModel is cleared.
 *
 * Usage:
 * - Collect [state] in your Composable and render the UI.
 * - Call [add] / [remove] to mutate data; these forward to the shared layer.
 *
 * Threading:
 * - Work is launched in [viewModelScope]; the controller/repository decide
 *   which dispatcher is used for DB work.
 */
class MantrasViewModel(private val controller: MantrasController) : ViewModel() {

    /** UI state stream from the shared layer (hot [StateFlow]). */
    val state: StateFlow<MantrasState> = controller.state

    /**
     * Adds a new mantra.
     * NOTE: Validation (e.g., trimming/empty-checks) should happen in the UI
     * layer before calling this to keep this wrapper minimal.
     */
    fun add(text: String) = viewModelScope.launch { controller.add(text) }

    /** Removes a mantra by id. */
    fun remove(id: Long) = viewModelScope.launch { controller.remove(id) }

    override fun onCleared() {
        // NOTE: Ensure the shared controller cancels its internal scope to avoid leaks.
        controller.clear()
        super.onCleared()
    }
}