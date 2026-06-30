import SwiftUI
import Shared

// =============================================================================
// Full-screen garden overview — 1:1 translation of GardenOverviewScreen.kt.
// =============================================================================

/// Full-screen "Forest"-style garden browser with month navigation.
struct GardenOverviewScreen: View {
    let initialYear: Int
    let initialMonth: Int
    let entryCounts: [Int]
    let onClose: () -> Void

    @State private var year: Int
    @State private var month: Int
    @State private var selectedTile: Int? = nil

    init(initialYear: Int, initialMonth: Int, entryCounts: [Int], onClose: @escaping () -> Void) {
        self.initialYear = initialYear
        self.initialMonth = initialMonth
        self.entryCounts = entryCounts
        self.onClose = onClose
        _year = State(initialValue: initialYear)
        _month = State(initialValue: initialMonth)
    }

    /// 1 tree per entry (up to 25).
    private var days: [Int] {
        let count = min(entryCounts.count, 25)
        return Array(entryCounts.prefix(count)) + Array(repeating: 0, count: 25 - count)
    }

    var body: some View {
        let trees = days.filter { $0 > 0 }.count

        VStack(spacing: 0) {
            // Header
            HStack {
                Text(PS.garden_title)
                    .font(IremiaText.h2)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.nav_close)
            }

            Spacer().frame(height: IremiaSpacing.s3)

            // Month navigation
            HStack {
                Button {
                    selectedTile = nil
                    if month > 1 { month -= 1 } else { month = 12; year -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(IremiaColors.teal700)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.garden_prev_month)

                Spacer()

                Text("\(monthName(month: month)) \(String(year))")
                    .font(IremiaText.cardTitle)
                    .foregroundColor(IremiaColors.ink)

                Spacer()

                Button {
                    selectedTile = nil
                    if month < 12 { month += 1 } else { month = 1; year += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(IremiaColors.teal700)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.garden_next_month)
            }
            .padding(.horizontal, IremiaSpacing.s4)

            Spacer().frame(height: IremiaSpacing.s5)

            // Garden scene on blue header wash
            GardenSceneView(
                days: days,
                columns: 5,
                rows: 5,
                interactive: true,
                selectedTile: selectedTile,
                onTileTap: { selectedTile = $0 }
            )
            .padding(IremiaSpacing.s3)
            .background(
                RoundedRectangle(cornerRadius: IremiaShapes.card, style: .continuous)
                    .fill(IremiaColors.blueHeader)
            )

            Spacer().frame(height: IremiaSpacing.s5)

            // Info text
            Text(infoText(days: days, trees: trees))
                .font(IremiaText.body)
                .foregroundColor(IremiaColors.gray600)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, IremiaSpacing.screenGutter)
        .padding(.vertical, IremiaSpacing.s3)
        .background(IremiaColors.gray100.ignoresSafeArea())
    }

    private func infoText(days: [Int], trees: Int) -> String {
        if let tile = selectedTile {
            let count = tile < days.count ? days[tile] : 0
            if count == 0 {
                return PS.garden_no_entry
            } else {
                // In this "one tree per entry" mode, clicking a tree represents a single entry.
                return PS.garden_entry_singular.replacingOccurrences(of: "%1$d", with: "1")
            }
        }
        return PS.garden_month_trees.replacingOccurrences(of: "%1$d", with: "\(trees)")
    }
}
