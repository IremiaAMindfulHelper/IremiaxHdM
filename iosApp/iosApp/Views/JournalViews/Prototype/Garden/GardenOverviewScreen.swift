import SwiftUI
import shared

// =============================================================================
// Full-screen garden overview — refactored to use GardenObservable (shared controller).
// =============================================================================

/// Full-screen "Forest"-style garden browser with month navigation.
/// State is now driven by `GardenObservable` → shared `GardenController`.
struct GardenOverviewScreen: View {
    @ObservedObject var garden: GardenObservable
    let onClose: () -> Void

    @State private var showResetConfirm = false
    // Pinch-to-zoom / pan for the full garden view. Kept separate from the
    // planting zoom animation inside GardenSceneView.
    @State private var zoomScale: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var panOffset: CGSize = .zero
    @State private var basePan: CGSize = .zero

    var body: some View {
        let trees = garden.tiles.filter { $0.entryCount > 0 }.count

        VStack(spacing: 0) {
            // Header
            HStack {
                Text(Strings.garden_title)
                    .font(IremiaText.h2)
                    .foregroundColor(IremiaColors.ink)
                Spacer()
                Button {
                    showResetConfirm = true
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Strings.garden_reset)
                .padding(.trailing, IremiaSpacing.s3)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(IremiaColors.ink900)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Strings.nav_close)
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
                .accessibilityLabel(Strings.garden_prev_month)

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
                .accessibilityLabel(Strings.garden_next_month)
            }
            .padding(.horizontal, IremiaSpacing.s4)

            Spacer().frame(height: IremiaSpacing.s5)

            // Free-standing garden scene. The flexible frame lets the 1.2-aspect
            // plot scale to fit width AND height, so it stays a clean size in
            // landscape instead of blowing up to full width.
            GardenSceneView(
                tiles: garden.tiles,
                columns: garden.gridColumns,
                rows: garden.gridRows,
                interactive: true,
                selectedTile: garden.selectedTile,
                onTileTap: { garden.selectTile($0) },
                newlyPlantedTileIndex: garden.newlyPlantedTileIndex,
                onGrowthFinished: { garden.clearNewlyPlanted() }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(zoomScale)
            .offset(panOffset)
            .gesture(
                // Pinch to zoom, drag to pan when zoomed in. Scale is clamped so
                // the plot can't be lost; pan resets to center at 1x.
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomScale = min(max(baseZoom * value, 1), 4)
                            if zoomScale <= 1 { panOffset = .zero }
                        }
                        .onEnded { _ in baseZoom = zoomScale },
                    DragGesture()
                        .onChanged { value in
                            guard zoomScale > 1 else { return }
                            panOffset = CGSize(
                                width: basePan.width + value.translation.width,
                                height: basePan.height + value.translation.height
                            )
                        }
                        .onEnded { value in
                            if zoomScale > 1 {
                                basePan = panOffset
                            } else {
                                // Swipe left/right to change month at 1x (plan 6.3).
                                let dx = value.translation.width
                                if dx > 60 { garden.navigateMonth(delta: -1) }
                                else if dx < -60 { garden.navigateMonth(delta: 1) }
                            }
                        }
                )
            )
            // No card/box around the garden — it sits free on the screen so it reads
            // bigger and more immersive. Clip only so the zoomed scene never spills
            // over the info text below it.
            .clipped()

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
        // Fullscreen ambient surprise overlay (leaves, birds, …), drawn above the
        // whole screen so animations never get clipped by the garden card.
        .overlay {
            if let config = garden.activeAmbient {
                AmbientSurpriseOverlayView(config: config) {
                    garden.clearAmbient()
                }
                // Rebuild the view when the animation changes so it starts fresh.
                .id(config.asset.name)
                .transition(.opacity)
            }
        }
        // Play a fresh ambient animation every time the garden is opened.
        .onAppear { garden.onEnterGarden() }
        .alert(Strings.garden_reset_confirm_title, isPresented: $showResetConfirm) {
            Button(Strings.garden_reset_cancel, role: .cancel) {}
            Button(Strings.garden_reset_confirm_action, role: .destructive) {
                garden.resetGarden()
            }
        } message: {
            Text(Strings.garden_reset_confirm_message)
        }
        // Tapping a planted tree reveals the journal entry it represents.
        .sheet(
            item: Binding(
                get: { garden.selectedEntry },
                set: { if $0 == nil { garden.selectTile(nil) } }
            )
        ) { entry in
            GardenEntrySheet(entry: entry)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func infoText(trees: Int) -> String {
        if let tileIndex = garden.selectedTile {
            let idx = Int(tileIndex)
            let tile = idx < garden.tiles.count ? garden.tiles[idx] : nil
            let day = Int(tile?.dayOfMonth ?? Int32(idx + 1))
            let dayLabel = Strings.garden_day_label.replacingOccurrences(of: "%1$d", with: "\(day)")
            let count = Int(tile?.entryCount ?? 0)
            if count == 0 {
                return "\(dayLabel) · \(Strings.garden_no_entry)"
            } else {
                let entries = (count == 1 ? Strings.garden_entry_singular : Strings.garden_entry_plural)
                    .replacingOccurrences(of: "%1$d", with: "\(count)")
                return "\(dayLabel) · \(entries)"
            }
        }
        return Strings.garden_month_trees.replacingOccurrences(of: "%1$d", with: "\(trees)")
    }
}

/// Sheet showing the journal entry behind a tapped plant: its date and full content.
private struct GardenEntrySheet: View {
    let entry: GardenEntry

    private var dateText: String {
        let date = Date(timeIntervalSince1970: Double(entry.createdAt) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM yyyy · HH:mm"
        return formatter.string(from: date)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IremiaSpacing.s3) {
                Text(Strings.garden_entry_sheet_title)
                    .font(IremiaText.h2)
                    .foregroundColor(IremiaColors.ink)

                Text(dateText)
                    .font(IremiaText.caption)
                    .foregroundColor(IremiaColors.gray500)

                let content = entry.content.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(content.isEmpty ? Strings.garden_entry_sheet_empty : content)
                    .font(IremiaText.body)
                    .foregroundColor(IremiaColors.ink700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, IremiaSpacing.screenGutter)
            .padding(.vertical, IremiaSpacing.s5)
        }
        .background(IremiaColors.white.ignoresSafeArea())
    }
}
