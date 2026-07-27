@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.controller

import kotlin.native.ObjCName
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.data.garden.GardenPlantRepository
import org.iremia.iremia.data.note.NoteRepository
import org.iremia.iremia.domain.note.Note
import org.iremia.iremia.domain.garden.GardenGridConfig
import org.iremia.iremia.domain.garden.GardenPlant
import org.iremia.iremia.domain.garden.GardenTile

/**
 * Immutable UI state for the full-screen garden overview.
 *
 * Holds the computed tile grid, navigation state, and animation triggers.
 * Both Android (via ViewModel) and iOS (via ObservableObject) consume this.
 *
 * @property selectedEntry The journal entry behind the selected plant, or null
 *           when the selected tile is empty, has no source entry, or nothing is
 *           selected. Drives the entry detail sheet shown when a plant is tapped.
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
 * tile selection, planting, reset, and animation triggers for plant events.
 *
 * Tiles are built from the persistent [GardenPlantRepository] so plants survive
 * deletion of their source journal entry. [NoteRepository] is still observed to
 * resolve a tapped plant back to its originating entry (when it has one).
 *
 * Planting is owned by the notes flow (NotesController), which knows the entry's
 * type and date; this controller only reads and navigates the resulting garden.
 */
@OptIn(ExperimentalCoroutinesApi::class)
@ObjCName("GardenController", exact = true)
class GardenController(
    private val plantRepo: GardenPlantRepository,
    private val noteRepo: NoteRepository,
    private val gridConfig: GardenGridConfig = GardenGridConfig(),
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main),
) {
    private val _state = MutableStateFlow(GardenState(isLoading = true, gridConfig = gridConfig))
    val state: StateFlow<GardenState> = _state.asStateFlow()

    // Latest notes, kept so a tapped plant can resolve back to its entry.
    private var notesById: Map<Long, Note> = emptyMap()

    // The source-entry id behind each tile index, for entry resolution on tap.
    private var sourceEntryByTile: Map<Int, Long> = emptyMap()

    // The displayed month, as a flow so the plant subscription switches with it.
    private val displayedMonth = MutableStateFlow(currentYearMonth())

    // Remembers plant ids across emissions so a growth animation only plays for a
    // genuinely new plant, per displayed month.
    private var previousIds: Set<Long>? = null

    init {
        val (year, month) = displayedMonth.value
        _state.value = _state.value.copy(
            year = year,
            month = month,
            gridConfig = gridConfigFor(year, month),
        )

        // Keep the note lookup fresh so tapping a plant can open its entry.
        scope.launch {
            noteRepo.observeAll().collect { notes ->
                notesById = notes.associateBy { it.id }
                _state.value = _state.value.copy(
                    selectedEntry = entryForTile(_state.value.selectedTile),
                )
            }
        }

        // Re-subscribe to the persistent garden whenever the displayed month
        // changes, so only that month's plants are shown (plan 6.3).
        scope.launch {
            displayedMonth.flatMapLatest { (year, month) ->
                previousIds = null // fresh month: don't animate its existing plants
                // Pair each emission with its month so the tile grid is always sized
                // for the month the plants belong to (no dependency on state timing).
                plantRepo.observeForMonth(year, month).map { plants -> Triple(year, month, plants) }
            }.collect { (year, month, plants) ->
                val config = gridConfigFor(year, month)
                val tiles = buildTiles(plants, config)
                sourceEntryByTile = buildSourceEntryMap(plants)

                val currentIds = plants.map { it.id }.toSet()
                var newPlantedIndex: Int? = null
                val previous = previousIds
                if (previous != null) {
                    val addedId = (currentIds - previous).singleOrNull()
                    if (addedId != null) {
                        newPlantedIndex = plants.firstOrNull { it.id == addedId }?.position
                    }
                }
                previousIds = currentIds

                _state.value = _state.value.copy(
                    year = year,
                    month = month,
                    tiles = tiles,
                    totalPlants = plants.size,
                    isLoading = false,
                    gridConfig = config,
                    newlyPlantedTileIndex = newPlantedIndex ?: _state.value.newlyPlantedTileIndex,
                    selectedEntry = entryForTile(_state.value.selectedTile),
                )
            }
        }
    }

    /** The grid config for a month: a fixed even 5x5 square. */
    private fun gridConfigFor(year: Int, month: Int): GardenGridConfig = gridConfig

    /**
     * Map one month's plants onto the fixed grid. Each plant occupies one tile at
     * its free-cell [GardenPlant.position]; one entry = one plant per tile.
     */
    private fun buildTiles(plants: List<GardenPlant>, config: GardenGridConfig): List<GardenTile> {
        val total = config.totalTiles
        val tiles = Array(total) { GardenTile(index = it) }
        for (plant in plants) {
            val pos = plant.position
            if (pos in 0 until total) {
                tiles[pos] = GardenTile(
                    index = pos,
                    plantType = plant.plantType,
                    category = plant.category,
                    entryId = plant.sourceEntryId,
                    dayOfMonth = plant.dayOfMonth,
                )
            }
        }
        return tiles.toList()
    }

    /** Source-entry id behind each occupied tile, for tap-to-open. */
    private fun buildSourceEntryMap(plants: List<GardenPlant>): Map<Int, Long> {
        val map = mutableMapOf<Int, Long>()
        for (plant in plants) {
            plant.sourceEntryId?.let { map[plant.position] = it }
        }
        return map
    }

    // ---- Actions (Android: call directly) ----

    /** Resolve the journal entry shown for a tile, or null when there is none. */
    private fun entryForTile(index: Int?): Note? {
        val entryId = index?.let { sourceEntryByTile[it] } ?: return null
        return notesById[entryId]
    }

    /**
     * Select or deselect a tile by index. When the tile holds a plant with a
     * source entry, that entry is resolved into [GardenState.selectedEntry] so the
     * UI can open it; tapping an empty tile (or one with no entry) clears it.
     */
    fun selectTile(index: Int?) {
        val current = _state.value
        val hasPlant = index != null && current.tiles.getOrNull(index)?.plantType != null
        val effectiveIndex = if (hasPlant) index else null
        _state.value = current.copy(
            selectedTile = effectiveIndex,
            selectedEntry = entryForTile(effectiveIndex),
        )
    }

    /** Navigate months: +1 forward, -1 backward. Resets tile selection. */
    fun navigateMonth(delta: Int) {
        val current = _state.value
        var newMonth = current.month + delta
        var newYear = current.year
        if (newMonth < 1) { newMonth = 12; newYear-- }
        if (newMonth > 12) { newMonth = 1; newYear++ }
        // Update the visible state immediately (month label + empty grid), then
        // switch the plant subscription; the collector fills in this month's plants.
        _state.value = current.copy(
            year = newYear,
            month = newMonth,
            selectedTile = null,
            selectedEntry = null,
            newlyPlantedTileIndex = null,
            gridConfig = gridConfigFor(newYear, newMonth),
        )
        displayedMonth.value = newYear to newMonth
    }

    private fun currentYearMonth(): Pair<Int, Int> {
        val now = Clock.System.now().toLocalDateTime(TimeZone.currentSystemDefault())
        return now.year to now.monthNumber
    }

    /** Clear the whole garden (Reset Garden button). */
    suspend fun resetGarden() {
        plantRepo.resetGarden()
    }

    /** Move a plant to another cell. Reserved for the future drag-and-drop edit mode. */
    suspend fun movePlant(plantId: Long, newPosition: Int) {
        plantRepo.movePlant(plantId, newPosition)
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

    /** iOS: reset the garden. */
    fun resetGardenAsync(onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { resetGarden() }
                .onFailure { onDone(it) }
                .onSuccess { onDone(null) }
        }
    }

    /** iOS: move a plant. Reserved for the future drag-and-drop edit mode. */
    fun movePlantAsync(plantId: Long, newPosition: Int, onDone: (Throwable?) -> Unit) {
        scope.launch {
            runCatching { movePlant(plantId, newPosition) }
                .onFailure { onDone(it) }
                .onSuccess { onDone(null) }
        }
    }

    /** Cancel scope on disposal. Android calls in onCleared(), iOS in deinit. */
    fun clear() = scope.cancel()
}
