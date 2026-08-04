package org.iremia.iremia.garden

import org.iremia.iremia.domain.garden.GardenRandomizer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Locks in the day-indexed garden's sprite selection and month-length rules.
 * Placement itself is now by calendar day (position = dayOfMonth - 1), so these
 * tests cover the parts the randomizer still owns: deterministic sprites and the
 * tree/flower split.
 */
class GardenRandomizerTest {

    @Test
    fun tree_sprite_is_deterministic() {
        assertEquals(
            GardenRandomizer.treeSprite(42L),
            GardenRandomizer.treeSprite(42L),
            "same seed must yield the same tree sprite",
        )
    }

    @Test
    fun flower_sprite_is_deterministic() {
        assertEquals(
            GardenRandomizer.flowerSprite(42L),
            GardenRandomizer.flowerSprite(42L),
            "same seed must yield the same flower sprite",
        )
    }

    @Test
    fun tree_sprite_is_always_a_tree() {
        for (seed in 1L..200L) {
            assertTrue(GardenRandomizer.treeSprite(seed).isTree, "seed $seed produced a non-tree")
        }
    }

    @Test
    fun flower_sprite_is_always_a_flower() {
        for (seed in 1L..200L) {
            assertTrue(!GardenRandomizer.flowerSprite(seed).isTree, "seed $seed produced a non-flower")
        }
    }

    @Test
    fun assign_position_is_deterministic_and_free() {
        val occupied = setOf(0, 1, 2)
        val a = GardenRandomizer.assignPosition(seed = 42L, occupiedPositions = occupied, gridSize = 25)
        val b = GardenRandomizer.assignPosition(seed = 42L, occupiedPositions = occupied, gridSize = 25)
        assertEquals(a, b, "same seed must yield the same position")
        assertTrue(a !in occupied, "must pick a free cell")
        assertTrue(a in 0 until 25, "must be within the grid")
    }

    @Test
    fun assign_position_returns_minus_one_when_full() {
        val full = (0 until 25).toSet()
        assertEquals(-1, GardenRandomizer.assignPosition(seed = 1L, occupiedPositions = full, gridSize = 25))
    }

    @Test
    fun days_in_month_covers_lengths_and_leap_years() {
        assertEquals(31, GardenRandomizer.daysInMonth(2026, 1))
        assertEquals(30, GardenRandomizer.daysInMonth(2026, 4))
        assertEquals(28, GardenRandomizer.daysInMonth(2026, 2))
        assertEquals(29, GardenRandomizer.daysInMonth(2024, 2)) // leap year
        assertEquals(28, GardenRandomizer.daysInMonth(2100, 2)) // century, not leap
        assertEquals(29, GardenRandomizer.daysInMonth(2000, 2)) // 400-divisible, leap
    }
}
