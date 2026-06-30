@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.garden.GardenGridConfig
import org.iremia.iremia.domain.garden.GardenTile
import org.iremia.iremia.domain.garden.GardenRandomizer

/**
 * Immutable UI state for the full-screen garden overview.
 *
 * Holds the computed tile grid, navigation state, and animation triggers.
 * Both Android (via ViewModel) and iOS (via ObservableObject) consume this.
 */
@ObjCName("GardenState", exact = true)
data class GardenState(
    val tiles: List<GardenTile> = emptyList(),
    val selectedTile: Int? = null,
    val year: Int = 0,
    val month: Int = 0,
    val totalPlants: Int = 0,
    val isLoading: Boolean = false,
    val newlyPlantedTileIndex: Int? = null,
    val gridConfig: GardenGridConfig = GardenGridConfig(),
)

/**
 * Orchestrates the garden overview state: tile computation, month navigation,
 * tile selection, and animation triggers for plant events.
 *
 * Observes [NoteRepository] to derive garden tiles from journal entries.
 * One entry = one planted tile; capped at [GardenGridConfig.totalTiles].
 */
@ObjCName("GardenController", exact = true)
class GardenController(
    private val repo: NoteRepository,
    private val gridConfig: GardenGridConfig = GardenGridConfig(),
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main),
) {
    private val _state = MutableStateFlow(GardenState(isLoading = true, gridConfig = gridConfig))
    val state: StateFlow<GardenState> = _state.asStateFlow()

    init {
        val now = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        _state.value = _state.value.copy(year = now.year, month = now.monthNumber)

        scope.launch {
            repo.observeAll().collect { notes ->
                val count = notes.size
                val tiles = GardenRandomizer.buildGrid(notes.map { it.id }, gridConfig.totalTiles)
                _state.value = _state.value.copy(
                    tiles = tiles,
                    totalPlants = count,
                    isLoading = false,
                )
            }
        }
    }

    // ---- Actions (Android: call directly) ----

    /** Select or deselect a tile by index. */
    fun selectTile(index: Int?) {
        _state.value = _state.value.copy(selectedTile = index)
    }

    /** Navigate months: +1 forward, -1 backward. Resets tile selection. */
    fun navigateMonth(delta: Int) {
        val current = _state.value
        var newMonth = current.month + delta
        var newYear = current.year
        if (newMonth < 1) { newMonth = 12; newYear-- }
        if (newMonth > 12) { newMonth = 1; newYear++ }
        _state.value = current.copy(year = newYear, month = newMonth, selectedTile = null)
    }

    /** Mark a tile as newly planted to trigger the growth animation. */
    fun markNewlyPlanted(tileIndex: Int) {
        _state.value = _state.value.copy(newlyPlantedTileIndex = tileIndex)
    }

    /** Clear the newly-planted marker after the animation finishes. */
    fun clearNewlyPlanted() {
        _state.value = _state.value.copy(newlyPlantedTileIndex = null)
    }

    // ---- iOS-friendly callback variants ----

    /** iOS: select a tile. */
    fun selectTileAsync(index: Int, onDone: (Throwable?) -> Unit) {
        selectTile(index)
        onDone(null)
    }

    /** iOS: navigate months. */
    fun navigateMonthAsync(delta: Int, onDone: (Throwable?) -> Unit) {
        navigateMonth(delta)
        onDone(null)
    }

    /** Cancel scope on disposal. Android calls in onCleared(), iOS in deinit. */
    fun clear() = scope.cancel()
}
