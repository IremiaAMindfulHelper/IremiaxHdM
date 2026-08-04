@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.garden

import kotlin.native.ObjCName

/**
 * Which kind of plant a garden entry is. A panic entry grows a tree, a journal
 * entry grows a flower bed. Persisted as a lowercase token in `gardenPlant.category`.
 */
@ObjCName("PlantCategory", exact = true)
enum class PlantCategory(val storageValue: String) {
    TREE("tree"),
    FLOWERBED("flowerbed");

    companion object {
        fun fromStorage(value: String?): PlantCategory =
            entries.firstOrNull { it.storageValue == value } ?: TREE
    }
}

/**
 * Represents a single tile in the isometric garden grid.
 *
 * Each tile holds at most one plant (one entry = one plant on a free cell). The
 * plant is a tree (panic entry) or a flower bed (journal entry), distinguished by
 * [category] and reflected in [plantType].
 *
 * @property index Tile position in the flat grid (0-based, row-major).
 * @property plantType The sprite shown on this tile, or null when the tile is empty.
 * @property category Whether the plant is a tree or a flower bed, or null when empty.
 * @property entryId Id of the entry this plant represents, or null when empty. Used
 *           to open the matching entry when the plant is tapped.
 * @property dayOfMonth The calendar day of the entry behind this plant (for the day
 *           label shown on tap), or 0 when empty.
 * @property isNewlyPlanted True when a plant was just placed here and the growth
 *           animation should play. Reset to false after the animation completes.
 */
@ObjCName("GardenTile", exact = true)
data class GardenTile(
    val index: Int,
    val plantType: PlantType? = null,
    val category: PlantCategory? = null,
    val entryId: Long? = null,
    val dayOfMonth: Int = 0,
    val isNewlyPlanted: Boolean = false,
) {
    /** True when this tile has a plant. */
    val hasPlant: Boolean get() = plantType != null

    /** Number of entries mapped to this tile (0 or 1). Kept for compatibility. */
    val entryCount: Int get() = if (plantType != null) 1 else 0
}

/**
 * A persisted plant in the garden, independent of any journal entry.
 *
 * Plants live in their own table so they survive deletion of the source entry, and
 * they carry the calendar day they belong to so each month is its own garden.
 *
 * @property id Database id of this plant row.
 * @property position Tile index within the month (0-based = [dayOfMonth] - 1).
 * @property plantType The sprite shown for this plant.
 * @property category Whether this is a tree (panic) or a flower bed (journal).
 * @property year Calendar year the plant belongs to.
 * @property month Calendar month (1..12) the plant belongs to.
 * @property dayOfMonth Calendar day (1..31) the plant belongs to.
 * @property sourceEntryId Id of the journal entry that spawned it, or null.
 * @property createdAt Creation timestamp in millis.
 */
@ObjCName("GardenPlant", exact = true)
data class GardenPlant(
    val id: Long,
    val position: Int,
    val plantType: PlantType,
    val category: PlantCategory = PlantCategory.TREE,
    val year: Int = 0,
    val month: Int = 0,
    val dayOfMonth: Int = 0,
    val sourceEntryId: Long? = null,
    val createdAt: Long,
)

/**
 * Configuration for the garden grid layout: a fixed, even square grid so the plot
 * always looks the same regardless of how many entries a month has.
 *
 * @property columns Number of columns in the isometric grid.
 * @property rows Number of rows in the isometric grid.
 */
@ObjCName("GardenGridConfig", exact = true)
data class GardenGridConfig(
    val columns: Int = 5,
    val rows: Int = 5,
) {
    val totalTiles: Int get() = columns * rows
}
