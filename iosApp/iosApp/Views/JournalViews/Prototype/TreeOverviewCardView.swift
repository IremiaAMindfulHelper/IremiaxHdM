import SwiftUI
import Shared

// =============================================================================
// "Baumuebersicht" card — 1:1 translation of TreeOverviewCard.kt.
// =============================================================================

/// Compact isometric preview of this month's garden.
/// Shows trees-planted headline, a mini GardenScene, and encouraging footer.
struct TreeOverviewCardView: View {
    let treesPlanted: Int
    let tiles: [GardenTile]
    var onClick: () -> Void = {}

    var body: some View {
        IremiaCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(PS.tree_overview_title)
                        .font(IremiaText.eyebrow)
                        .foregroundColor(IremiaColors.teal700)
                        .tracking(0.06 * 12)
                    Spacer()
                    Text(PS.tree_overview_period)
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.gray500)
                }

                Spacer().frame(height: 12)

                HStack(alignment: .bottom, spacing: 8) {
                    Text("\(treesPlanted)")
                        .font(IremiaText.numXl)
                        .foregroundColor(IremiaColors.ink)
                    Text(PS.tree_overview_planted)
                        .font(IremiaText.body)
                        .foregroundColor(IremiaColors.gray600)
                        .padding(.bottom, 6)
                }

                Spacer().frame(height: 14)

                GardenSceneView(
                    tiles: tiles,
                    columns: 5,
                    rows: 5
                )

                Spacer().frame(height: 14)

                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 16))
                        .foregroundColor(IremiaColors.garden500)
                    Text(PS.tree_overview_encouragement)
                        .font(IremiaText.caption)
                        .foregroundColor(IremiaColors.gray500)
                }
            }
        }
        // Whole card (image + text) is one tap target, including empty space.
        .contentShape(Rectangle())
        .onTapGesture(perform: onClick)
    }
}
