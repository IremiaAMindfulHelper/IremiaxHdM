package org.iremia.iremia.ui.theme

import androidx.compose.ui.unit.dp

// =============================================================================
// Iremia — Spacing ruler (4px base) + screen layout constants.
// From --s-* in colors_and_type.css. Use these instead of magic numbers.
// =============================================================================

object IremiaSpacing {
    val S1 = 4.dp
    val S2 = 8.dp
    val S3 = 12.dp
    val S4 = 16.dp
    val S5 = 20.dp
    val S6 = 24.dp
    val S8 = 32.dp
    val S10 = 40.dp
    val S12 = 48.dp

    // Layout conventions observed in the design:
    val ScreenGutter = 22.dp // left/right padding on every screen
    val CardPadding = 20.dp // default inner card padding (16–22 range)
    val SectionGap = 24.dp // vertical rhythm between sections
    val BottomNavClearance = 110.dp // bottom padding so content clears the nav bar
}

// Motion (from --ease-soft / --dur*). Use with tween(durationMillis, easing = ...).
object IremiaMotion {
    const val DUR_FAST = 140 // --dur-fast (ms)
    const val DUR = 240 // --dur (ms)
    // --ease-soft cubic-bezier(0.22, 0.61, 0.36, 1):
    //   val EaseSoft = CubicBezierEasing(0.22f, 0.61f, 0.36f, 1f)
    // Press feedback: scale to 0.97 on press (see brand UI rules in the handoff README).
}
