package org.iremia.iremia.data.garden

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import com.iremia.UserData
import org.iremia.iremia.domain.garden.GardenPlant
import org.iremia.iremia.domain.garden.PlantCategory
import org.iremia.iremia.domain.garden.PlantType

/**
 * Data Access Object for the `gardenPlant` table.
 *
 * Maps the stored [PlantType]/[PlantCategory] tokens to/from the domain model and
 * exposes month- and day-scoped queries used by the garden's per-day-per-type rule.
 */
class GardenPlantDao(private val db: UserData) {

    /** Observe all persisted plants, ordered by grid position. */
    fun observeAll(): Flow<List<GardenPlant>> =
        db.gardenPlantQueries
            .selectAll(::mapRow)
            .asFlow()
            .mapToList(Dispatchers.Default)

    /** Observe one month's garden (year + 1..12 month), ordered by tile position. */
    fun observeForMonth(year: Int, month: Int): Flow<List<GardenPlant>> =
        db.gardenPlantQueries
            .selectForMonth(year.toLong(), month.toLong(), ::mapRow)
            .asFlow()
            .mapToList(Dispatchers.Default)

    /** Grid positions already taken in the given month, to place a new plant on a free cell. */
    fun occupiedPositionsForMonth(year: Int, month: Int): Set<Int> =
        db.gardenPlantQueries
            .selectOccupiedPositionsForMonth(year.toLong(), month.toLong())
            .executeAsList()
            .map { it.toInt() }
            .toSet()

    /** Insert one plant on its day tile. */
    fun insert(
        position: Int,
        plantType: PlantType,
        category: PlantCategory,
        year: Int,
        month: Int,
        dayOfMonth: Int,
        sourceEntryId: Long?,
        createdAt: Long,
    ) {
        db.gardenPlantQueries.insert(
            position = position.toLong(),
            plantType = plantType.name,
            category = category.storageValue,
            year = year.toLong(),
            month = month.toLong(),
            dayOfMonth = dayOfMonth.toLong(),
            sourceEntryId = sourceEntryId,
            createdAt = createdAt,
        )
    }

    /** Move a plant to a new grid cell. Reserved for the future drag-and-drop edit mode. */
    fun updatePosition(id: Long, position: Int) {
        db.gardenPlantQueries.updatePositionById(position = position.toLong(), id = id)
    }

    /** Remove a single plant by id. */
    fun delete(id: Long) {
        db.gardenPlantQueries.deleteById(id)
    }

    /** Clear the whole garden. */
    fun deleteAll() {
        db.gardenPlantQueries.deleteAll()
    }

    // Row mapper shared by every query so field mapping stays in one place.
    private fun mapRow(
        id: Long,
        position: Long,
        plantType: String,
        category: String,
        year: Long,
        month: Long,
        dayOfMonth: Long,
        sourceEntryId: Long?,
        createdAt: Long,
    ): GardenPlant = GardenPlant(
        id = id,
        position = position.toInt(),
        plantType = decodePlantType(plantType),
        category = PlantCategory.fromStorage(category),
        year = year.toInt(),
        month = month.toInt(),
        dayOfMonth = dayOfMonth.toInt(),
        sourceEntryId = sourceEntryId,
        createdAt = createdAt,
    )

    // Unknown/renamed enum names fall back to a tree so an old row never crashes rendering.
    private fun decodePlantType(raw: String): PlantType =
        PlantType.entries.firstOrNull { it.name == raw } ?: PlantType.OAK
}
