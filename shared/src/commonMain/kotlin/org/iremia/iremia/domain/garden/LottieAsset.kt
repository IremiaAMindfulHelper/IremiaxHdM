@file:OptIn(kotlin.experimental.ExperimentalObjCName::class)

package org.iremia.iremia.domain.garden

import kotlin.native.ObjCName
import org.iremia.library.SharedRes
import dev.icerock.moko.resources.FileResource

/**
 * Catalog of Lottie animations available in the app.
 * Each variant is mapped to its moko-resource [FileResource].
 */
@ObjCName("LottieAsset", exact = true)
enum class LottieAsset(val fileResource: FileResource) {
    // Growth animation — every planting action uses the tree growth animation.
    TREE_GROW(SharedRes.files.tree_growth_without_background_lottie),

    // Ambient surprises
    PAPER_PLANE(SharedRes.files.paper_plane_lottie),
    DEER(SharedRes.files.deer_lottie),
    BIRDS(SharedRes.files.birds_lottie),
    BIRD(SharedRes.files.bird_lottie),
    RED_BIRDS(SharedRes.files.red_birds_lottie),
    TRANSPARENT_BIRDS(SharedRes.files.transparent_birds_lottie),
    LEAVES(SharedRes.files.leaves_lottie),
    LEAF(SharedRes.files.leaf_lottie),
    AUTUMN_FALL(SharedRes.files.autumn_fall_lottie);
}
