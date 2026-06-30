import Foundation
import Shared

/// ObservableObject that bridges the shared KMP GardenController state
/// into SwiftUI-friendly properties. Follows the same pattern as
/// `NotesObservable` — subscribes to the Kotlin StateFlow via `Interop`.
final class GardenObservable: ObservableObject {
    @Published var tiles: [Int] = []
    @Published var selectedTile: Int? = nil
    @Published var year: Int = 0
    @Published var month: Int = 0
    @Published var totalPlants: Int = 0
    @Published var isLoading = true
    @Published var newlyPlantedTileIndex: Int? = nil
    @Published var gridColumns: Int = 5
    @Published var gridRows: Int = 5

    private let controller: GardenController
    private var cancelable: KmpCancelable?

    init() {
        controller = SharedFactory.shared.createGardenController(
            driverFactory: DriverFactory()
        )

        cancelable = Interop.shared.observeState(flow: controller.state) { anyValue in
            guard let s = anyValue as? GardenState else { return }

            // Map tiles to entry counts (simple Int list for the scene)
            let rawTiles = (s.tiles as? [Any]) ?? []
            let tileCounts = rawTiles.compactMap { tile -> Int? in
                let obj = tile as AnyObject
                if let count = obj.value(forKey: "entryCount") as? NSNumber {
                    return count.intValue
                }
                return 0
            }

            let selectedIdx: Int? = s.selectedTile?.intValue

            let rawConfig = s.gridConfig
            let cols = Int(rawConfig.columns)
            let rows = Int(rawConfig.rows)

            DispatchQueue.main.async {
                self.tiles = tileCounts
                self.selectedTile = selectedIdx
                self.year = Int(s.year)
                self.month = Int(s.month)
                self.totalPlants = Int(s.totalPlants)
                self.isLoading = s.isLoading
                self.newlyPlantedTileIndex = s.newlyPlantedTileIndex?.intValue
                self.gridColumns = cols
                self.gridRows = rows
            }
        }
    }

    deinit {
        cancelable?.cancel()
        controller.clear()
    }

    // MARK: - Actions

    func selectTile(_ index: Int?) {
        if let idx = index {
            controller.selectTileAsync(index: Int32(idx)) { _ in }
        } else {
            controller.selectTile(index: nil)
        }
    }

    func navigateMonth(delta: Int) {
        controller.navigateMonthAsync(delta: Int32(delta)) { _ in }
    }
}
