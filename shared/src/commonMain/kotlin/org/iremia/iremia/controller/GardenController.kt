@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.domain.garden.GardenGridConfig
import org.iremia.iremia.domain.garden.GardenTile
import org.iremia.iremia.domain.garden.GardenRandomizer

/**
 * Immutable UI state for the full-screen garden overview.
 *
 * Holds the computed tile grid, navigation state, and animation triggers.
 * Both Android (via ViewModel) and iOS (via ObservableObject) consume this.
 *
 * @property selectedEntry The journal entry behind the selected plant, or null
 *           when the selected tile is empty or nothing is selected. Drives the
 *           entry detail sheet shown when a plant is tapped.
 */
@ObjCName("GardenState", exact = true)
data class GardenState(
    val tiles: List<GardenTile> = emptyList(),
    val selectedTile: Int? = null,
    val selectedEntry: Note? = null,
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

    // Latest notes, kept so a tapped plant can resolve back to its entry.
    private var notesById: Map<Long, Note> = emptyMap()

    init {
        val now = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        _state.value = _state.value.copy(year = now.year, month = now.monthNumber)

        scope.launch {
            var previousIds: Set<Long>? = null
            repo.observeAll().collect { notes ->
                val count = notes.size
                val currentIds = notes.map { it.id }
                val currentIdSet = currentIds.toSet()
                notesById = notes.associateBy { it.id }
                val tiles = GardenRandomizer.buildGrid(currentIds, gridConfig.totalTiles)

                // A growth animation should only play for a genuinely new entry
                // (not on the first load, a recompose, or a deletion). Stable
                // placement guarantees the new id lands on exactly one tile.
                var newPlantedIndex: Int? = null
                val previous = previousIds
                if (previous != null) {
                    val addedId = (currentIdSet - previous).singleOrNull()
                    if (addedId != null) {
                        newPlantedIndex = tiles.firstOrNull { it.entryId == addedId }?.index
                    }
                }

                previousIds = currentIdSet

                _state.value = _state.value.copy(
                    tiles = tiles,
                    totalPlants = count,
                    isLoading = false,
                    newlyPlantedTileIndex = newPlantedIndex ?: _state.value.newlyPlantedTileIndex,
                    selectedEntry = entryForTile(_state.value.selectedTile, tiles),
                )
            }
        }
    }

    // ---- Actions (Android: call directly) ----

    /** Resolve the journal entry shown for a tile, or null when the tile is empty. */
    private fun entryForTile(index: Int?, tiles: List<GardenTile>): Note? {
        val entryId = index?.let { tiles.getOrNull(it)?.entryId } ?: return null
        return notesById[entryId]
    }

    /**
     * Select or deselect a tile by index. When the tile holds a plant, its
     * journal entry is resolved into [GardenState.selectedEntry] so the UI can
     * open the matching entry; tapping an empty tile clears the selection.
     */
    fun selectTile(index: Int?) {
        val current = _state.value
        val entry = entryForTile(index, current.tiles)
        // Tapping bare grass shouldn't select anything to react to.
        val effectiveIndex = if (entry == null) null else index
        _state.value = current.copy(selectedTile = effectiveIndex, selectedEntry = entry)
    }

    /** Navigate months: +1 forward, -1 backward. Resets tile selection. */
    fun navigateMonth(delta: Int) {
        val current = _state.value
        var newMonth = current.month + delta
        var newYear = current.year
        if (newMonth < 1) { newMonth = 12; newYear-- }
        if (newMonth > 12) { newMonth = 1; newYear++ }
        _state.value = current.copy(year = newYear, month = newMonth, selectedTile = null, selectedEntry = null)
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

    /** iOS: deselect current tile. */
    fun deselectTileAsync(onDone: (Throwable?) -> Unit) {
        selectTile(null)
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
