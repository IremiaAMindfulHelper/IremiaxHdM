import Foundation

// MARK: - Shared Types (View + ViewModel)

enum MoodMark: Equatable {
    case moodGradientA
    case moodGradientB
}

enum CellStyle: Equatable {
    case mood(MoodCellStyle)
    case panic(PanicCellStyle)
    case none
}

enum MoodCellStyle: Equatable {
    case plus
    case gradientA
    case gradientB
}

enum PanicCellStyle: Equatable {
    case plus
    case filled
    case brokenHeart
}

struct UnifiedCell: Identifiable {
    let id = UUID()
    let day: Int
    let isInDisplayedMonth: Bool
    let style: CellStyle
    let monthOffset: Int?
    let effectiveYear: Int?
    let effectiveMonth: Int?
    let isTappable: Bool
}
