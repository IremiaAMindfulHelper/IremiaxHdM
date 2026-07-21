@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.garden

import kotlin.native.ObjCName

/**
 * Represents a single tile in the isometric garden grid.
 *
 * @property index Tile position in the flat grid (0-based, row-major).
 * @property entryCount Number of journal entries mapped to this tile (0 = empty).
 * @property isNewlyPlanted True when a plant was just placed here and the growth
 *           animation should play. Reset to false after the animation completes.
 * @property plantType The sprite shown on this tile, or null when the tile is empty.
 * @property entryId Id of the journal entry this plant represents, or null when empty.
 *           Used to open the matching entry when the plant is tapped.
 */
@ObjCName("GardenTile", exact = true)
data class GardenTile(
    val index: Int,
    val entryCount: Int = 0,
    val isNewlyPlanted: Boolean = false,
    val plantType: PlantType? = null,
    val entryId: Long? = null,
)

/**
 * A persisted plant in the garden, independent of any journal entry.
 *
 * Plants live in their own table so they survive deletion of the source entry.
 *
 * @property id Database id of this plant row.
 * @property position Grid cell index this plant occupies (0-based, row-major).
 * @property plantType The sprite shown for this plant.
 * @property sourceEntryId Id of the journal entry that spawned it, or null when it
 *           came from another action (e.g. a breathing exercise).
 * @property createdAt Creation timestamp in millis.
 */
@ObjCName("GardenPlant", exact = true)
data class GardenPlant(
    val id: Long,
    val position: Int,
    val plantType: PlantType,
    val sourceEntryId: Long? = null,
    val createdAt: Long,
)

/**
 * Configuration for the garden grid layout.
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
