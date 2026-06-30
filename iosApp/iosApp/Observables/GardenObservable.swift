import Foundation
import Shared

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

    /// Starts an ambient surprise if none is currently playing.
    func triggerAmbient() {
        if activeAmbient == nil {
            activeAmbient = selectRandomAmbient()
        }
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

    /// Clears the growth-animation marker once the planting animation has played.
    func clearNewlyPlanted() {
        controller.clearNewlyPlanted()
    }
}
