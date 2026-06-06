package org.iremia.iremia.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp

// =============================================================================
// Iremia — Typography
// Single brand face: Inter. Derived from the --display/--h1/... CSS scale.
// line-height is expressed in sp (px ≈ sp, the source is mobile px).
//
// TODO: load the real Inter face. Currently FontFamily.Default. Options:
//   (A) Downloadable Google Fonts — add the ui-text-google-fonts dependency +
//       res/values/font_certs.xml, then build a FontFamily via GoogleFont("Inter").
//       Needs Play Services on the device.
//   (B) Bundled .ttf in res/font/ (offline, recommended for production).
// Tracked as a follow-up to keep this theming change build-safe and dependency-free.
// =============================================================================

val Inter: FontFamily = FontFamily.Default // TODO: swap for Inter via (A) or (B)

// Brand text styles — use these names; they mirror the CSS scale exactly.
object IremiaText {
    // --display : 700 34/1.05, tracking -0.02em
    val Display = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Bold, fontSize = 34.sp, lineHeight = 36.sp, letterSpacing = (-0.02).em)

    // --h1 : 800 28/1.12, tracking -0.02em
    val H1 = TextStyle(fontFamily = Inter, fontWeight = FontWeight.ExtraBold, fontSize = 28.sp, lineHeight = 31.sp, letterSpacing = (-0.02).em)

    // --h2 : 700 22/1.2
    val H2 = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Bold, fontSize = 22.sp, lineHeight = 26.sp)

    // --card-title : 700 18/1.25
    val CardTitle = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Bold, fontSize = 18.sp, lineHeight = 23.sp)

    // --body-lg : 400 17/1.45
    val BodyLg = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Normal, fontSize = 17.sp, lineHeight = 25.sp)

    // --body : 400 15/1.5
    val Body = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Normal, fontSize = 15.sp, lineHeight = 23.sp)

    // --caption : 400 13/1.4
    val Caption = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Normal, fontSize = 13.sp, lineHeight = 18.sp)

    // --eyebrow : 700 12/1.2, uppercase + tracking 0.06em (apply uppercase() at call site)
    val Eyebrow = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Bold, fontSize = 12.sp, lineHeight = 14.sp, letterSpacing = 0.06.em)

    // --num-xl : 800 40/1.0 (big counters)
    val NumXl = TextStyle(fontFamily = Inter, fontWeight = FontWeight.ExtraBold, fontSize = 40.sp, lineHeight = 40.sp)
}

// Material3 Typography bridge (so stock components read sensible defaults).
val IremiaTypography = Typography(
    displaySmall = IremiaText.Display,
    headlineLarge = IremiaText.H1,
    headlineMedium = IremiaText.H2,
    titleLarge = IremiaText.CardTitle,
    bodyLarge = IremiaText.BodyLg,
    bodyMedium = IremiaText.Body,
    bodySmall = IremiaText.Caption,
    labelLarge = IremiaText.Eyebrow,
)
