@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.garden

import kotlin.native.ObjCName

/**
 * All available plant sprites in the garden, mapped to their moko-resources image name.
 *
 * 10 isometric tree sprites + 2 flower crates. Each sits on its own grass tile.
 * The [resourceName] matches the generated `MR.images.*` property name
 * (without the `@1x` suffix which moko strips automatically).
 *
 * @property resourceName The moko-resource image identifier (e.g. "sprite_1_1").
 */
@ObjCName("PlantType", exact = true)
enum class PlantType(val resourceName: String) {
    // Row 1 trees — various broadleaf shapes
    BIRCH("sprite_1_1"),
    MAPLE("sprite_1_2"),
    OAK("sprite_1_3"),
    WILLOW("sprite_1_4"),
    CEDAR("sprite_1_5"),

    // Row 2 trees — conifers and mixed
    PINE("sprite_2_1"),
    SPRUCE("sprite_2_2"),
    CHERRY("sprite_2_3"),
    CYPRESS("sprite_2_4"),
    REDWOOD("sprite_2_5"),

    // Flower crates
    FLOWER_YELLOW("flower_gelb"),
    FLOWER_PURPLE("flower_lila");

    /** True for all tree types, false for flower crates. */
    val isTree: Boolean get() = this != FLOWER_YELLOW && this != FLOWER_PURPLE

    /** The moko ImageResource associated with this PlantType. */
    val image: dev.icerock.moko.resources.ImageResource
        get() = when (this) {
            BIRCH -> org.iremia.library.SharedRes.images.sprite_1_1
            MAPLE -> org.iremia.library.SharedRes.images.sprite_1_2
            OAK -> org.iremia.library.SharedRes.images.sprite_1_3
            WILLOW -> org.iremia.library.SharedRes.images.sprite_1_4
            CEDAR -> org.iremia.library.SharedRes.images.sprite_1_5
            PINE -> org.iremia.library.SharedRes.images.sprite_2_1
            SPRUCE -> org.iremia.library.SharedRes.images.sprite_2_2
            CHERRY -> org.iremia.library.SharedRes.images.sprite_2_3
            CYPRESS -> org.iremia.library.SharedRes.images.sprite_2_4
            REDWOOD -> org.iremia.library.SharedRes.images.sprite_2_5
            FLOWER_YELLOW -> org.iremia.library.SharedRes.images.flower_gelb
            FLOWER_PURPLE -> org.iremia.library.SharedRes.images.flower_lila
        }

    companion object {
        /** All tree types (no flowers). */
        val trees: List<PlantType> = entries.filter { it.isTree }

        /** All flower types (no trees). */
        val flowers: List<PlantType> = entries.filter { !it.isTree }
    }
}
