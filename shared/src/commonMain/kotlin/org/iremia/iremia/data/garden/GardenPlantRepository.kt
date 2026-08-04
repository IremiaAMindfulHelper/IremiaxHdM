@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.data.garden

import kotlin.native.ObjCName
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import org.iremia.iremia.domain.garden.GardenPlant
import org.iremia.iremia.domain.garden.GardenRandomizer
import org.iremia.iremia.domain.garden.PlantCategory

/** Grid size of one month's garden (5x5). */
private const val GARDEN_GRID_SIZE = 25

/**
 * The outcome of a plant attempt, so callers (e.g. the saved screen) can tell
 * whether a new plant was actually placed or the month's garden was full.
 *
 * @property planted True when a new plant was created, false when the garden was full.
 * @property category The category that was requested.
 * @property dayOfMonth The day the entry belongs to.
 */
@ObjCName("PlantResult", exact = true)
data class PlantResult(
    val planted: Boolean,
    val category: PlantCategory,
    val dayOfMonth: Int,
)

/**
 * Repository for the persistent garden.
 *
 * Owns the single planting entry point: each entry plants one plant on a free grid
 * cell of its month's 5x5 garden (panic → tree, journal → flower bed). Placement is
 * deterministic (seeded by the entry id) and per-month, so each month is its own
 * garden and backdated entries land in the right month. When the month's garden is
 * full, nothing new is planted (the UI may still play the growth animation). All
 * writes run on the IO dispatcher.
 */
class GardenPlantRepository(
    private val dao: GardenPlantDao,
    private val io: CoroutineDispatcher = Dispatchers.Default,
) {
    fun observeAll(): Flow<List<GardenPlant>> = dao.observeAll()

    /** Observe one month's garden. */
    fun observeForMonth(year: Int, month: Int): Flow<List<GardenPlant>> =
        dao.observeForMonth(year, month)

    /**
     * Plants one plant for a journal/panic entry on a free cell of its month.
     *
     * @param sourceEntryId Originating entry id (also used as the placement/sprite seed).
     * @param category Tree (panic) or flower bed (journal).
     * @param entryDateMillis The entry's date; decides which month the plant belongs
     *        to (so backdated entries land correctly).
     * @param strength Panic intensity, nudges the tree sprite. Ignored for flowers.
     * @return A [PlantResult]: planted=false when the month's garden was full.
     */
    suspend fun plantForEntry(
        sourceEntryId: Long?,
        category: PlantCategory,
        entryDateMillis: Long,
        strength: Int? = null,
    ): PlantResult = withContext(io) {
        val date = Instant.fromEpochMilliseconds(entryDateMillis)
            .toLocalDateTime(TimeZone.currentSystemDefault()).date
        val year = date.year
        val month = date.monthNumber
        val day = date.dayOfMonth

        val seed = sourceEntryId ?: entryDateMillis
        val occupied = dao.occupiedPositionsForMonth(year, month)
        val position = GardenRandomizer.assignPosition(seed, occupied, GARDEN_GRID_SIZE)
        if (position < 0) {
            // Month's garden is full — plant nothing new.
            return@withContext PlantResult(planted = false, category = category, dayOfMonth = day)
        }

        val plantType = when (category) {
            PlantCategory.TREE -> GardenRandomizer.treeSprite(seed, strength)
            PlantCategory.FLOWERBED -> GardenRandomizer.flowerSprite(seed)
        }
        dao.insert(
            position = position,
            plantType = plantType,
            category = category,
            year = year,
            month = month,
            dayOfMonth = day,
            sourceEntryId = sourceEntryId,
            createdAt = Clock.System.now().toEpochMilliseconds(),
        )
        PlantResult(planted = true, category = category, dayOfMonth = day)
    }

    /** Move a plant to another cell. Reserved for the future drag-and-drop edit mode. */
    suspend fun movePlant(id: Long, newPosition: Int) = withContext(io) {
        dao.updatePosition(id, newPosition)
    }

    /** Remove a single plant. */
    suspend fun remove(id: Long) = withContext(io) {
        dao.delete(id)
    }

    /** Clear the whole garden (Reset Garden button). */
    suspend fun resetGarden() = withContext(io) {
        dao.deleteAll()
    }
}
