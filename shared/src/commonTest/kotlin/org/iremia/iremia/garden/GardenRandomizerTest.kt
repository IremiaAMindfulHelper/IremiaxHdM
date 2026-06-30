package org.iremia.iremia.garden

import org.iremia.iremia.domain.garden.GardenRandomizer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlin.test.assertNull

/**
 * Locks in the placement guarantees the garden relies on: deterministic,
 * append-only positions that never shift when a new entry is added.
 */
class GardenRandomizerTest {

    @Test
    fun placement_is_order_independent() {
        val ids = listOf(1L, 2L, 3L, 4L, 5L)
        val ascending = GardenRandomizer.buildGrid(ids, gridSize = 25)
        val descending = GardenRandomizer.buildGrid(ids.reversed(), gridSize = 25)

        // The journal lists notes newest-first; passing either order must yield
        // the exact same grid so positions are stable across recomposes.
        assertEquals(ascending, descending)
    }

    @Test
    fun adding_an_entry_never_moves_existing_plants() {
        val before = GardenRandomizer.buildGrid(listOf(3L, 2L, 1L), gridSize = 25)
        val after = GardenRandomizer.buildGrid(listOf(4L, 3L, 2L, 1L), gridSize = 25)

        // Every tile that already held a plant keeps the same plant in the same spot.
        for (tile in before.filter { it.entryId != null }) {
            val matching = after[tile.index]
            assertEquals(tile.entryId, matching.entryId, "entry moved at index ${tile.index}")
            assertEquals(tile.plantType, matching.plantType)
        }

        // The new entry occupies exactly one previously-free tile.
        val newlyOccupied = after.filter { it.entryId != null } - before.filter { it.entryId != null }.toSet()
        assertEquals(1, newlyOccupied.size)
        assertEquals(4L, newlyOccupied.single().entryId)
    }

    @Test
    fun each_entry_is_placed_exactly_once() {
        val ids = (1L..10L).toList()
        val grid = GardenRandomizer.buildGrid(ids, gridSize = 25)

        val placedIds = grid.mapNotNull { it.entryId }
        assertEquals(ids.toSet(), placedIds.toSet())
        assertEquals(ids.size, placedIds.size, "an entry was placed more than once")
    }

    @Test
    fun full_grid_does_not_overflow() {
        val ids = (1L..40L).toList()
        val grid = GardenRandomizer.buildGrid(ids, gridSize = 25)

        assertEquals(25, grid.size)
        assertEquals(25, grid.count { it.entryId != null })
    }

    @Test
    fun tile_links_back_to_its_entry() {
        val grid = GardenRandomizer.buildGrid(listOf(42L), gridSize = 25)
        val planted = grid.firstOrNull { it.entryId != null }
        assertNotNull(planted)
        assertEquals(42L, planted.entryId)
        assertNotNull(planted.plantType)
        assertTrue(grid.count { it.entryId == null } == 24)
        assertNull(grid.first { it.entryId == null }.plantType)
    }

    @Test
    fun flower_crates_appear_regularly() {
        // Flower beds should be a meaningful minority (~35%), not almost never.
        val sample = (1L..1000L).map { GardenRandomizer.assignPlantType(it) }
        val flowerShare = sample.count { !it.isTree }.toDouble() / sample.size
        assertTrue(flowerShare in 0.25..0.45, "flower share was $flowerShare, expected ~0.35")
    }
}
