import SwiftUI

// =============================================================================
// Iremia — SwiftUI Design Tokens
// 1:1 translation of IremiaColor.kt, IremiaDimens.kt, IremiaShape.kt, IremiaType.kt.
// Use these tokens everywhere; never hardcode hex values or magic numbers in views.
// =============================================================================

// MARK: - Colors

/// Brand color tokens derived from the Iremia design system.
/// Names match the Kotlin `IremiaColors` object for cross-referencing.
enum IremiaColors {
    // ---- Brand / Primary (teal) ----
    static let teal900  = Color(red: 0x0F / 255.0, green: 0x4D / 255.0, blue: 0x5E / 255.0) // pressed / deepest
    static let teal800  = Color(red: 0x15 / 255.0, green: 0x5E / 255.0, blue: 0x72 / 255.0)
    static let teal700  = Color(red: 0x1A / 255.0, green: 0x70 / 255.0, blue: 0x88 / 255.0) // PRIMARY
    static let teal600  = Color(red: 0x1F / 255.0, green: 0x82 / 255.0, blue: 0x99 / 255.0)
    static let teal500  = Color(red: 0x2E / 255.0, green: 0x97 / 255.0, blue: 0xAE / 255.0)
    static let teal300  = Color(red: 0x6B / 255.0, green: 0xA3 / 255.0, blue: 0xB2 / 255.0) // muted
    static let teal100  = Color(red: 0xC7 / 255.0, green: 0xE0 / 255.0, blue: 0xE6 / 255.0)
    static let teal50   = Color(red: 0xEE / 255.0, green: 0xF8 / 255.0, blue: 0xFA / 255.0) // pale card tint

    // ---- Surface blues (calm backgrounds) ----
    static let blueHeader = Color(red: 0xDC / 255.0, green: 0xED / 255.0, blue: 0xF1 / 255.0)
    static let blueCard   = Color(red: 0xE8 / 255.0, green: 0xF0 / 255.0, blue: 0xF3 / 255.0)

    // ---- Garden / growth (tree-planting feature) ----
    static let garden900 = Color(red: 0x0B / 255.0, green: 0x4D / 255.0, blue: 0x3C / 255.0)
    static let garden700 = Color(red: 0x0F / 255.0, green: 0x6E / 255.0, blue: 0x56 / 255.0)
    static let garden500 = Color(red: 0x2E / 255.0, green: 0x95 / 255.0, blue: 0x76 / 255.0)
    static let garden300 = Color(red: 0x7F / 255.0, green: 0xC0 / 255.0, blue: 0xA8 / 255.0)
    static let garden100 = Color(red: 0xDC / 255.0, green: 0xEE / 255.0, blue: 0xE6 / 255.0)
    static let bloom     = Color(red: 0xE5 / 255.0, green: 0xA3 / 255.0, blue: 0xB8 / 255.0)
    static let branch    = Color(red: 0x8A / 255.0, green: 0x6B / 255.0, blue: 0x4F / 255.0)

    // ---- Ink / Neutrals ----
    static let ink     = Color(red: 0x0A / 255.0, green: 0x0A / 255.0, blue: 0x0A / 255.0)
    static let ink900  = Color(red: 0x1E / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0)
    static let ink700  = Color(red: 0x3E / 255.0, green: 0x3E / 255.0, blue: 0x3E / 255.0)
    static let gray600 = Color(red: 0x4A / 255.0, green: 0x55 / 255.0, blue: 0x65 / 255.0)
    static let gray500 = Color(red: 0x6A / 255.0, green: 0x72 / 255.0, blue: 0x82 / 255.0)
    static let gray400 = Color(red: 0x99 / 255.0, green: 0xA1 / 255.0, blue: 0xAF / 255.0)
    static let gray300 = Color(red: 0xD1 / 255.0, green: 0xD5 / 255.0, blue: 0xDC / 255.0)
    static let gray200 = Color(red: 0xE5 / 255.0, green: 0xE7 / 255.0, blue: 0xEB / 255.0)
    static let gray100 = Color(red: 0xF3 / 255.0, green: 0xF4 / 255.0, blue: 0xF6 / 255.0)
    static let gray50  = Color(red: 0xF9 / 255.0, green: 0xFA / 255.0, blue: 0xFB / 255.0)
    static let white   = Color.white

    // ---- Semantic ----
    static let success   = Color(red: 0x0F / 255.0, green: 0x6E / 255.0, blue: 0x56 / 255.0)
    static let warning   = Color(red: 0x85 / 255.0, green: 0x4F / 255.0, blue: 0x0B / 255.0)
    static let warningBg = Color(red: 0xFE / 255.0, green: 0xF6 / 255.0, blue: 0xE1 / 255.0)
    static let warningBd = Color(red: 0xFE / 255.0, green: 0xE6 / 255.0, blue: 0x85 / 255.0)
    static let danger    = Color(red: 0xA3 / 255.0, green: 0x2D / 255.0, blue: 0x2D / 255.0)
    static let info      = Color(red: 0x14 / 255.0, green: 0x47 / 255.0, blue: 0xE6 / 255.0)
    static let infoBd    = Color(red: 0xBE / 255.0, green: 0xDB / 255.0, blue: 0xFF / 255.0)
}

// MARK: - Spacing

/// Spacing ruler (4px base) and screen layout constants.
/// Matches the Kotlin `IremiaSpacing` object.
enum IremiaSpacing {
    static let s1: CGFloat  = 4
    static let s2: CGFloat  = 8
    static let s3: CGFloat  = 12
    static let s4: CGFloat  = 16
    static let s5: CGFloat  = 20
    static let s6: CGFloat  = 24
    static let s8: CGFloat  = 32
    static let s10: CGFloat = 40
    static let s12: CGFloat = 48

    /// Left/right padding on every screen.
    static let screenGutter: CGFloat = 22
    /// Default inner card padding (16–22 range).
    static let cardPadding: CGFloat = 20
    /// Vertical rhythm between sections.
    static let sectionGap: CGFloat = 24
    /// Bottom padding so content clears the nav bar.
    static let bottomNavClearance: CGFloat = 110
}

// MARK: - Motion

/// Animation durations from the design system.
enum IremiaMotion {
    static let durFast: Double = 0.14 // seconds
    static let dur: Double     = 0.24 // seconds
}

// MARK: - Shapes

/// Shape tokens (corner radii) matching `IremiaShapes`.
/// Iremia is "pill-first": buttons and chips are fully rounded; cards use big radii.
enum IremiaShapes {
    static let card: CGFloat   = 22  // --r-card
    static let cardSm: CGFloat = 16  // --r-card-sm
    static let tile: CGFloat   = 14  // --r-tile
    static let field: CGFloat  = 14  // --r-field

    /// Bottom-only rounded shape for the header wash (26pt bottom corners).
    static func headerWash() -> some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 26,
            bottomTrailingRadius: 26,
            topTrailingRadius: 0,
            style: .continuous
        )
    }
}

// MARK: - Typography

/// Text style factories matching the `IremiaText` Kotlin object.
/// Single brand face: system font (Inter TODO, same as Android).
enum IremiaText {
    /// --display: 700 34/1.05, tracking -0.02em
    static let display: Font = .system(size: 34, weight: .bold)
    /// --h1: 800 28/1.12, tracking -0.02em
    static let h1: Font = .system(size: 28, weight: .heavy)
    /// --h2: 700 22/1.2
    static let h2: Font = .system(size: 22, weight: .bold)
    /// --card-title: 700 18/1.25
    static let cardTitle: Font = .system(size: 18, weight: .bold)
    /// --body-lg: 400 17/1.45
    static let bodyLg: Font = .system(size: 17, weight: .regular)
    /// --body: 400 15/1.5
    static let body: Font = .system(size: 15, weight: .regular)
    /// --caption: 400 13/1.4
    static let caption: Font = .system(size: 13, weight: .regular)
    /// --eyebrow: 700 12/1.2, uppercase + tracking 0.06em
    static let eyebrow: Font = .system(size: 12, weight: .bold)
    /// --num-xl: 800 40/1.0 (big counters)
    static let numXl: Font = .system(size: 40, weight: .heavy)
}
