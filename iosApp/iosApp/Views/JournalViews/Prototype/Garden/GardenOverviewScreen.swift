import SwiftUI
import Shared

// =============================================================================
// Full-screen garden overview — refactored to use GardenObservable (shared controller).
// =============================================================================

/// Full-screen "Forest"-style garden browser with month navigation.
/// State is now driven by `GardenObservable` → shared `GardenController`.
struct GardenOverviewScreen: View {
    @ObservedObject var garden: GardenObservable
    let onClose: () -> Void

    var body: some View {
        let trees = garden.tiles.filter { $0.entryCount > 0 }.count

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
                    garden.navigateMonth(delta: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(IremiaColors.teal700)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(PS.garden_prev_month)

                Spacer()

                Text("\(monthName(month: garden.month)) \(String(garden.year))")
                    .font(IremiaText.cardTitle)
                    .foregroundColor(IremiaColors.ink)

                Spacer()

                Button {
                    garden.navigateMonth(delta: 1)
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
                tiles: garden.tiles,
                columns: garden.gridColumns,
                rows: garden.gridRows,
                interactive: true,
                selectedTile: garden.selectedTile,
                onTileTap: { garden.selectTile($0) }
            )
            .padding(IremiaSpacing.s3)
            .background(
                RoundedRectangle(cornerRadius: IremiaShapes.card, style: .continuous)
                    .fill(IremiaColors.blueHeader)
            )

            Spacer().frame(height: IremiaSpacing.s5)

            // Info text
            Text(infoText(trees: trees))
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

    private func infoText(trees: Int) -> String {
        if let tile = garden.selectedTile {
            let count = tile < garden.tiles.count ? garden.tiles[tile].entryCount : 0
            if count == 0 {
                return PS.garden_no_entry
            } else {
                return PS.garden_entry_singular.replacingOccurrences(of: "%1$d", with: "1")
            }
        }
        return PS.garden_month_trees.replacingOccurrences(of: "%1$d", with: "\(trees)")
    }
}
