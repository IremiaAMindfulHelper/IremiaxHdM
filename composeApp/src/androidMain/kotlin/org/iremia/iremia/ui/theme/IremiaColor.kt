package org.iremia.iremia.ui.theme

import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color

// =============================================================================
// Iremia — Color tokens
// Derived 1:1 from the design system (colors_and_type.css). Names match the CSS
// variables for cross-referencing. Use IremiaColors.* everywhere; never hardcode
// hex values in screens.
// =============================================================================

object IremiaColors {
    // ---- Brand / Primary (teal) ----
    val Teal900 = Color(0xFF0F4D5E) // pressed / deepest
    val Teal800 = Color(0xFF155E72)
    val Teal700 = Color(0xFF1A7088) // PRIMARY — buttons, active nav, FAB, links
    val Teal600 = Color(0xFF1F8299)
    val Teal500 = Color(0xFF2E97AE)
    val Teal300 = Color(0xFF6BA3B2) // muted teal — secondary marks
    val Teal100 = Color(0xFFC7E0E6)
    val Teal50 = Color(0xFFEEF8FA) // pale card tint

    // ---- Surface blues (calm backgrounds) ----
    val BlueHeader = Color(0xFFDCEDF1) // calendar / hero header wash
    val BlueCard = Color(0xFFE8F0F3) // tinted info card

    // ---- Garden / growth (tree-planting feature) ----
    val Garden900 = Color(0xFF0B4D3C)
    val Garden700 = Color(0xFF0F6E56) // trees / growth accent
    val Garden500 = Color(0xFF2E9576)
    val Garden300 = Color(0xFF7FC0A8)
    val Garden100 = Color(0xFFDCEEE6)
    val Bloom = Color(0xFFE5A3B8) // flowers
    val Branch = Color(0xFF8A6B4F) // bushes / branches

    // ---- Ink / Neutrals ----
    val Ink = Color(0xFF0A0A0A) // display headings
    val Ink900 = Color(0xFF1E1E1E)
    val Ink700 = Color(0xFF3E3E3E) // strong body
    val Gray600 = Color(0xFF4A5565) // secondary text
    val Gray500 = Color(0xFF6A7282) // body / captions
    val Gray400 = Color(0xFF99A1AF) // muted / placeholder
    val Gray300 = Color(0xFFD1D5DC) // borders, dividers, inactive
    val Gray200 = Color(0xFFE5E7EB) // light borders
    val Gray100 = Color(0xFFF3F4F6) // app background
    val Gray50 = Color(0xFFF9FAFB)
    val White = Color(0xFFFFFFFF)

    // ---- Semantic ----
    val Success = Color(0xFF0F6E56)
    val Warning = Color(0xFF854F0B) // caution / disclaimer copy
    val WarningBg = Color(0xFFFEF6E1)
    val WarningBd = Color(0xFFFEE685)
    val Danger = Color(0xFFA32D2D)
    val Info = Color(0xFF1447E6)
    val InfoBd = Color(0xFFBEDBFF)
}

// -----------------------------------------------------------------------------
// Material3 ColorScheme bridge.
// Iremia is a light, single-mode brand. This maps brand tokens onto the M3 slots
// so stock Material components (Button, Chip, NavigationBar…) inherit the right
// colors out of the box. For brand-specific surfaces, prefer IremiaColors directly.
// -----------------------------------------------------------------------------
val IremiaColorScheme = lightColorScheme(
    primary = IremiaColors.Teal700,
    onPrimary = IremiaColors.White,
    primaryContainer = IremiaColors.Teal50,
    onPrimaryContainer = IremiaColors.Teal800,
    secondary = IremiaColors.Garden700,
    onSecondary = IremiaColors.White,
    secondaryContainer = IremiaColors.Garden100,
    onSecondaryContainer = IremiaColors.Garden900,
    background = IremiaColors.Gray100, // app background
    onBackground = IremiaColors.Ink,
    surface = IremiaColors.White, // cards
    onSurface = IremiaColors.Ink900,
    surfaceVariant = IremiaColors.BlueCard,
    onSurfaceVariant = IremiaColors.Gray500,
    outline = IremiaColors.Gray300,
    outlineVariant = IremiaColors.Gray200,
    error = IremiaColors.Danger,
    onError = IremiaColors.White,
)
