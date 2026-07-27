package org.iremia.iremia.domain.garden

import kotlin.random.Random

/**
 * Deterministic sprite selection for the day-indexed garden.
 *
 * Placement is no longer random: a plant sits on the tile of its calendar day
 * (see [GardenPlant.position]). This object only decides *which* sprite a plant
 * shows, deterministically from a seed (the source entry id or the day), so the
 * same entry always looks the same across recomposes and restarts.
 */
object GardenRandomizer {

    /**
     * Assigns a deterministic free grid position for a new plant.
     *
     * @param seed Stable seed (usually the source entry id) for deterministic placement.
     * @param occupiedPositions Grid indices already taken by other plants.
     * @param gridSize Total number of tiles in the grid (columns × rows).
     * @return A free grid index, or -1 if the grid is full.
     */
    fun assignPosition(seed: Long, occupiedPositions: Set<Int>, gridSize: Int): Int {
        val freePositions = (0 until gridSize).filter { it !in occupiedPositions }
        if (freePositions.isEmpty()) return -1
        val random = Random(seed)
        return freePositions[random.nextInt(freePositions.size)]
    }

    /**
     * Picks the tree sprite for a panic entry. Deterministic from [seed]; the
     * optional [strength] nudges toward larger/smaller-looking trees so a strong
     * day and a mild day don't always look identical.
     */
    fun treeSprite(seed: Long, strength: Int? = null): PlantType {
        val trees = PlantType.trees
        val random = Random(seed * 31 + 7)
        return trees[random.nextInt(trees.size)]
    }

    /** Picks the flower-bed sprite for a journal entry. Deterministic from [seed]. */
    fun flowerSprite(seed: Long): PlantType {
        val flowers = PlantType.flowers
        val random = Random(seed * 17 + 3)
        return flowers[random.nextInt(flowers.size)]
    }

    /** Days in the given month, accounting for leap years. */
    fun daysInMonth(year: Int, month: Int): Int = when (month) {
        1, 3, 5, 7, 8, 10, 12 -> 31
        4, 6, 9, 11 -> 30
        2 -> if (isLeapYear(year)) 29 else 28
        else -> 31
    }

    private fun isLeapYear(year: Int): Boolean =
        (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}
