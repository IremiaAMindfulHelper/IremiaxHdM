package org.iremia.iremia.domain.garden

import kotlin.random.Random

/**
 * Deterministic randomizer for garden tile placement and plant type selection.
 *
 * Uses seeded [Random] instances so results are stable across recompositions
 * and app restarts — the same entry ID always produces the same position
 * and plant type.
 */
object GardenRandomizer {

    /**
     * Assigns a random free grid position for a new plant.
     *
     * @param entryId Unique entry identifier used as seed for deterministic placement.
     * @param occupiedPositions Set of grid indices already taken by other plants.
     * @param gridSize Total number of tiles in the grid (columns × rows).
     * @return A free grid index, or -1 if the grid is full.
     */
    fun assignPosition(entryId: Long, occupiedPositions: Set<Int>, gridSize: Int): Int {
        val freePositions = (0 until gridSize).filter { it !in occupiedPositions }
        if (freePositions.isEmpty()) return -1

        val random = Random(entryId)
        return freePositions[random.nextInt(freePositions.size)]
    }

    /**
     * Selects a random [PlantType] for the given entry.
     *
     * Weighted toward trees (~80%) with occasional flower crates (~20%).
     *
     * @param entryId Unique entry identifier used as seed for deterministic selection.
     * @return The chosen [PlantType].
     */
    fun assignPlantType(entryId: Long): PlantType {
        val random = Random(entryId * 31 + 7) // Different seed offset than position
        return if (random.nextFloat() < 0.8f) {
            PlantType.trees[random.nextInt(PlantType.trees.size)]
        } else {
            PlantType.flowers[random.nextInt(PlantType.flowers.size)]
        }
    }

    /**
     * Builds a complete garden grid from a list of entry IDs.
     *
     * Placement is append-only and stable: entries are processed in ascending
     * id order (oldest first, since ids are AUTOINCREMENT), so the first planted
     * entry always claims its slot first and no existing plant ever moves when a
     * new entry is added. The caller may pass ids in any order (the journal lists
     * them newest-first) — sorting here keeps positions fixed across recomposes.
     *
     * @param entryIds Journal entry IDs that contribute plants, in any order.
     * @param gridSize Total tiles in the grid (default 25 for a 5×5 grid).
     * @return List of [GardenTile] covering the full grid.
     */
    fun buildGrid(entryIds: List<Long>, gridSize: Int = 25): List<GardenTile> {
        val tiles = Array(gridSize) { GardenTile(index = it) }
        val occupied = mutableSetOf<Int>()

        for (id in entryIds.sorted()) {
            if (occupied.size >= gridSize) break

            val position = assignPosition(id, occupied, gridSize)
            if (position < 0) break

            val plantType = assignPlantType(id)
            tiles[position] = GardenTile(
                index = position,
                entryCount = 1,
                plantType = plantType,
                entryId = id,
            )
            occupied.add(position)
        }

        return tiles.toList()
    }
}
