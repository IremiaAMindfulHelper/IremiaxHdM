package org.iremia.iremia.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Shapes
import androidx.compose.ui.unit.dp

// =============================================================================
// Iremia — Shape tokens (corner radii)
// Iremia is "pill-first": buttons and chips are fully rounded; cards use big,
// friendly radii. Derived from --r-* in colors_and_type.css.
// =============================================================================

object IremiaShapes {
    val Card = RoundedCornerShape(22.dp) // --r-card
    val CardSm = RoundedCornerShape(16.dp) // --r-card-sm
    val Tile = RoundedCornerShape(14.dp) // --r-tile
    val Field = RoundedCornerShape(14.dp) // --r-field (text fields, selects)
    val Pill = RoundedCornerShape(percent = 50) // --r-pill (999px) buttons & chips

    // Header / hero wash: rounded only at the bottom (border-radius: 0 0 26px 26px)
    val HeaderWash = RoundedCornerShape(bottomStart = 26.dp, bottomEnd = 26.dp)
}

// Material3 Shapes bridge.
val IremiaMaterialShapes = Shapes(
    extraSmall = IremiaShapes.Tile,
    small = IremiaShapes.CardSm,
    medium = IremiaShapes.Card,
    large = IremiaShapes.Card,
    extraLarge = IremiaShapes.Card,
)
