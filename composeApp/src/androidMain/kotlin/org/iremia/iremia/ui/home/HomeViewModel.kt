package org.iremia.iremia.ui.home

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.StateFlow
import org.iremia.iremia.controller.MotivationController
import org.iremia.iremia.controller.MotivationState

/**
 * ViewModel for the home screen. Wraps [MotivationController] and exposes the
 * motivation-insight state that drives the blue hero card.
 */
class HomeViewModel(
    private val motivationController: MotivationController,
) : ViewModel() {

    val state: StateFlow<MotivationState> = motivationController.state

    override fun onCleared() {
        super.onCleared()
        motivationController.clear()
    }
}
