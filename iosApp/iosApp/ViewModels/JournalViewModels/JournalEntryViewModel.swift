import Foundation
import CoreGraphics

final class JournalEntryViewModel: ObservableObject {

    @Published var ballPosition: CGPoint = CGPoint(x: 0, y: 0)
    @Published var isLocked: Bool = false

    @Published var activityMode: ActivityMode = .symbols
    @Published var selectedActivities: Set<ActivitySymbol> = []
    @Published var freeTextActivity: String = ""

    @Published var waterLiters: String = "0"
    @Published var sleepHours: String = "0"
    @Published var notes: String = ""

    enum ActivitySymbol: String, CaseIterable, Identifiable, Hashable {
        case football = "soccerball"
        case university = "graduationcap"
        case shopping = "cart"
        case train = "tram"

        var id: String { rawValue }

        var label: String {
            switch self {
            case .football: return "Fußball"
            case .university: return "Uni"
            case .shopping: return "Einkaufen"
            case .train: return "Zug"
            }
        }
    }

    enum ActivityMode: String, CaseIterable, Hashable {
        case symbols = "Symbole"
        case freetext = "Freitext"
    }

    func toggleLock() {
        isLocked.toggle()
    }

    func toggleActivity(_ activity: ActivitySymbol) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
}
