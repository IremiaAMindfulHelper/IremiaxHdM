package org.iremia.iremia.data.garden

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import com.iremia.UserData
import org.iremia.iremia.domain.garden.GardenPlant
import org.iremia.iremia.domain.garden.PlantType

/**
 * Data Access Object for the `gardenPlant` table.
 *
 * Maps the stored [PlantType] enum name to/from the domain model.
 */
class GardenPlantDao(private val db: UserData) {

    /** Observe all persisted plants, ordered by grid position. */
    fun observeAll(): Flow<List<GardenPlant>> =
        db.gardenPlantQueries
            .selectAll { id, position, plantType, sourceEntryId, createdAt ->
                GardenPlant(
                    id = id,
                    position = position.toInt(),
                    plantType = decodePlantType(plantType),
                    sourceEntryId = sourceEntryId,
                    createdAt = createdAt,
                )
            }
            .asFlow()
            .mapToList(Dispatchers.Default)

    /** Grid positions currently occupied by a plant. */
    fun occupiedPositions(): Set<Int> =
        db.gardenPlantQueries.selectOccupiedPositions().executeAsList().map { it.toInt() }.toSet()

    /** Insert one plant at [position] with the given [plantType]. */
    fun insert(position: Int, plantType: PlantType, sourceEntryId: Long?, createdAt: Long) {
        db.gardenPlantQueries.insert(
            position = position.toLong(),
            plantType = plantType.name,
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

    // Unknown/renamed enum names fall back to a tree so an old row never crashes rendering.
    private fun decodePlantType(raw: String): PlantType =
        PlantType.entries.firstOrNull { it.name == raw } ?: PlantType.OAK
}
