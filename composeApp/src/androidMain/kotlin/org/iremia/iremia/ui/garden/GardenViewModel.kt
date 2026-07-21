package org.iremia.iremia.ui.garden

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import org.iremia.iremia.controller.GardenController
import org.iremia.iremia.controller.GardenState

/**
 * ViewModel for the full-screen garden overview.
 *
 * Wraps [GardenController] and delegates state/actions. Handles triggering of
 * ambient surprise animations (both randomly over time and after planting completed).
 */
class GardenViewModel(
    private val gardenController: GardenController,
) : ViewModel() {

    val state: StateFlow<GardenState> = gardenController.state

    private val _activeAmbient = MutableStateFlow<AmbientConfig?>(null)
    val activeAmbient: StateFlow<AmbientConfig?> = _activeAmbient.asStateFlow()

    init {
        // 1. Periodically check for random ambient surprise trigger (every 20s, 15% probability)
        viewModelScope.launch {
            while (isActive) {
                delay(20000)
                if (_activeAmbient.value == null && gardenController.state.value.newlyPlantedTileIndex == null) {
                    val triggerChance = 0.15f
                    if (kotlin.random.Random.nextFloat() < triggerChance) {
                        triggerAmbient()
                    }
                }
            }
        }

        // 2. Listen to planting completion to trigger ambient animation with high probability
        viewModelScope.launch {
            var prevNewlyPlanted: Int? = null
            gardenController.state.collect { currentState ->
                if (prevNewlyPlanted != null && currentState.newlyPlantedTileIndex == null) {
                    // Planting animation finished -> always follow up with an ambient
                    // surprise, so after the tree grows the user reliably sees a
                    // second, different animation (falling leaves, birds, …).
                    delay(400)
                    triggerAmbient()
                }
                prevNewlyPlanted = currentState.newlyPlantedTileIndex
            }
        }
    }

    fun selectTile(index: Int?) = gardenController.selectTile(index)

    fun navigateMonth(delta: Int) = gardenController.navigateMonth(delta)

    fun markNewlyPlanted(tileIndex: Int) = gardenController.markNewlyPlanted(tileIndex)

    fun clearNewlyPlanted() = gardenController.clearNewlyPlanted()

    /** Clear all planted items (Reset Garden). */
    fun resetGarden() = viewModelScope.launch { gardenController.resetGarden() }

    /**
     * Plants a garden item not tied to a journal entry — e.g. after finishing a
     * breathing exercise. The single entry point other features can call.
     */
    fun plantFromAction() = viewModelScope.launch { gardenController.plant(sourceEntryId = null) }

    // Cycle through the animations in order (deterministic for demos) instead of
    // picking randomly, so each surprise is a different, predictable next one.
    private var ambientCycleIndex = 0

    private fun nextAmbient(): AmbientConfig {
        val config = AmbientConfigs[ambientCycleIndex % AmbientConfigs.size]
        ambientCycleIndex++
        return config
    }

    /** Show the next ambient animation only if none is currently playing. */
    fun triggerAmbient() {
        if (_activeAmbient.value == null) {
            _activeAmbient.value = nextAmbient()
        }
    }

    /**
     * Called every time the garden screen is opened. Restarts a fresh animation —
     * any still-running one is dropped so re-entering never gets stuck repeating the
     * same frame, and the user always sees a new animation on entry.
     */
    fun onEnterGarden() {
        _activeAmbient.value = null
        _activeAmbient.value = nextAmbient()
    }

    fun clearAmbient() {
        _activeAmbient.value = null
    }

    override fun onCleared() {
        super.onCleared()
        gardenController.clear()
    }
}
