import Foundation
import shared

/// The journal entry behind a tapped plant, in a SwiftUI-friendly shape.
struct GardenEntry: Identifiable, Equatable {
    let id: Int64
    let content: String
    let createdAt: Int64
}

/// ObservableObject that bridges the shared KMP GardenController state
/// into SwiftUI-friendly properties. Follows the same pattern as
/// `NotesObservable` — subscribes to the Kotlin StateFlow via `Interop`.
final class GardenObservable: ObservableObject {
    @Published var tiles: [GardenTile] = []
    @Published var selectedTile: Int? = nil
    @Published var selectedEntry: GardenEntry? = nil
    @Published var year: Int = 0
    @Published var month: Int = 0
    @Published var totalPlants: Int = 0
    @Published var isLoading = true
    @Published var newlyPlantedTileIndex: Int? = nil
    @Published var gridColumns: Int = 5
    @Published var gridRows: Int = 5

    /// The currently playing fullscreen ambient surprise, or nil.
    @Published var activeAmbient: AmbientConfig? = nil

    private let controller: GardenController
    private var cancelable: KmpCancelable?
    private var ambientTimer: Timer?
    private var lastNewlyPlanted: Int? = nil

    init() {
        controller = SharedFactory.shared.createGardenController(
            driverFactory: DriverFactory()
        )

        cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
            guard let s = anyValue as? GardenState else { return }

            let rawTiles = (s.tiles as? [GardenTile]) ?? []

            let selectedIdx: Int? = s.selectedTile?.intValue

            let entry: GardenEntry? = s.selectedEntry.map {
                GardenEntry(id: $0.id, content: $0.content, createdAt: $0.createdAt)
            }

            let rawConfig = s.gridConfig
            let cols = Int(rawConfig.columns)
            let rows = Int(rawConfig.rows)

            DispatchQueue.main.async {
                self.tiles = rawTiles
                self.selectedTile = selectedIdx
                self.selectedEntry = entry
                self.year = Int(s.year)
                self.month = Int(s.month)
                self.totalPlants = Int(s.totalPlants)
                self.isLoading = s.isLoading

                let newPlanted = s.newlyPlantedTileIndex?.intValue
                // A planting just finished -> likely trigger an ambient surprise.
                if self.lastNewlyPlanted != nil && newPlanted == nil {
                    if Double.random(in: 0..<1) < 0.8 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.triggerAmbient()
                        }
                    }
                }
                self.lastNewlyPlanted = newPlanted
                self.newlyPlantedTileIndex = newPlanted
                self.gridColumns = cols
                self.gridRows = rows
            }
        }

        // Periodically trigger an ambient surprise (every 20s, 15% chance),
        // matching the Android GardenViewModel cadence.
        ambientTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.activeAmbient == nil && self.newlyPlantedTileIndex == nil {
                if Double.random(in: 0..<1) < 0.15 { self.triggerAmbient() }
            }
        }
    }

    deinit {
        ambientTimer?.invalidate()
        cancelable?.cancel()
        controller.clear()
    }

    // Cycle through the animations in order (deterministic for demos) instead of
    // picking randomly, so each surprise is a different, predictable next one.
    private var ambientCycleIndex = 0

    private func nextAmbient() -> AmbientConfig {
        let config = ambientConfigs[ambientCycleIndex % ambientConfigs.count]
        ambientCycleIndex += 1
        return config
    }

    /// Shows the next ambient animation only if none is currently playing.
    func triggerAmbient() {
        if activeAmbient == nil {
            activeAmbient = nextAmbient()
        }
    }

    /// Called every time the garden screen appears. Restarts a fresh animation — any
    /// still-running one is dropped so re-entering never repeats the same one, and
    /// the user always sees a new animation on entry.
    ///
    /// If a tile is mid-planting (e.g. entering right after saving an episode),
    /// the ambient is skipped here entirely — the zoom-in and tree_grow animation
    /// need the screen to themselves. Once growth finishes, `newlyPlantedTileIndex`
    /// flips back to nil and the observer above schedules the ambient itself.
    func onEnterGarden() {
        guard newlyPlantedTileIndex == nil else { return }
        activeAmbient = nil
        activeAmbient = nextAmbient()
    }

    /// Clears the ambient surprise once its animation finished.
    func clearAmbient() {
        activeAmbient = nil
    }

    // MARK: - Actions

    func selectTile(_ index: Int?) {
        if let idx = index {
            controller.selectTileAsync(index: Int32(idx)) { _ in }
        } else {
            controller.deselectTileAsync { _ in }
        }
    }

    func navigateMonth(delta: Int) {
        controller.navigateMonthAsync(delta: Int32(delta)) { _ in }
    }

    /// Clears all planted items (Reset Garden).
    func resetGarden() {
        controller.resetGardenAsync { _ in }
    }

    /// Clears the growth-animation marker once the planting animation has played.
    func clearNewlyPlanted() {
        controller.clearNewlyPlanted()
    }
}
