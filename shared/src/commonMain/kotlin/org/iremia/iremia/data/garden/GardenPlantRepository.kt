package org.iremia.iremia.data.garden

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import kotlinx.datetime.Clock
import org.iremia.iremia.domain.garden.GardenPlant
import org.iremia.iremia.domain.garden.GardenRandomizer

/**
 * Repository for the persistent garden.
 *
 * Owns the single "plant" entry point used by every action that grows something
 * (journal entries today, breathing exercises later). Placement reuses the
 * deterministic [GardenRandomizer] so plants keep the familiar look, but the
 * result is persisted rather than recomputed from journal entries. All writes run
 * on the IO dispatcher per the architecture rules.
 */
class GardenPlantRepository(
    private val dao: GardenPlantDao,
    private val gridSize: Int = 25,
    private val io: CoroutineDispatcher = Dispatchers.Default,
) {
    fun observeAll(): Flow<List<GardenPlant>> = dao.observeAll()

    /**
     * Plants one item on a free grid cell and persists it.
     *
     * @param sourceEntryId Originating journal entry id, or null for other actions
     *        (e.g. finishing a breathing exercise).
     * @param seed Deterministic seed for position/type. Defaults to the source
     *        entry id when present, otherwise the current time so ad-hoc plants
     *        still vary. The seed keeps placement stable and testable.
     * @return The grid position the plant took, or -1 when the garden is full.
     */
    suspend fun plant(sourceEntryId: Long?, seed: Long? = null): Int = withContext(io) {
        val occupied = dao.occupiedPositions()
        if (occupied.size >= gridSize) return@withContext -1

        val effectiveSeed = seed ?: sourceEntryId ?: Clock.System.now().toEpochMilliseconds()
        val position = GardenRandomizer.assignPosition(effectiveSeed, occupied, gridSize)
        if (position < 0) return@withContext -1

        val plantType = GardenRandomizer.assignPlantType(effectiveSeed)
        dao.insert(
            position = position,
            plantType = plantType,
            sourceEntryId = sourceEntryId,
            createdAt = Clock.System.now().toEpochMilliseconds(),
        )
        position
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
