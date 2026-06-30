package org.iremia.iremia.ui.garden

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.StateFlow
import org.iremia.iremia.controller.GardenController
import org.iremia.iremia.controller.GardenState

/**
 * ViewModel for the full-screen garden overview.
 *
 * Wraps [GardenController] and delegates state/actions. Composables stay stateless;
 * all randomizer, trigger, and animation-state logic lives here (or in the controller).
 */
class GardenViewModel(
    private val gardenController: GardenController,
) : ViewModel() {

    val state: StateFlow<GardenState> = gardenController.state

    fun selectTile(index: Int?) = gardenController.selectTile(index)

    fun navigateMonth(delta: Int) = gardenController.navigateMonth(delta)

    fun markNewlyPlanted(tileIndex: Int) = gardenController.markNewlyPlanted(tileIndex)

    fun clearNewlyPlanted() = gardenController.clearNewlyPlanted()

    override fun onCleared() {
        super.onCleared()
        gardenController.clear()
    }
}
