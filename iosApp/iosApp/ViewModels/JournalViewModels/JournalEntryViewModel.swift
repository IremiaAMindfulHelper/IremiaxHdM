import Foundation
import CoreGraphics

/*
 Diese Klasse verwaltet die Daten für einen Tagebucheintrag.
 Sie speichert Position, Aktivitäten, Wasser- und Schlafangaben
 sowie zusätzliche Notizen und stellt Funktionen bereit,
 um bestimmte Zustände zu ändern.
*/
final class JournalEntryViewModel: ObservableObject {

    // Position eines beweglichen Elements im UI
    @Published var ballPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    // Gibt an, ob das Element gesperrt ist
    @Published var isLocked: Bool = false

    // Aktueller Modus für die Aktivitätseingabe (Symbole oder Freitext)
    @Published var activityMode: ActivityMode = .symbols
    
    // Ausgewählte Aktivitäten als Symbolmenge
    @Published var selectedActivities: Set<ActivitySymbol> = []
    
    // Freitext für individuelle Aktivitäten
    @Published var freeTextActivity: String = ""

    // Eingabe für getrunkene Wassermenge
    @Published var waterLiters: String = "0"
    
    // Eingabe für Schlafdauer
    @Published var sleepHours: String = "0"
    
    // Zusätzliche Notizen
    @Published var notes: String = ""

    // Vordefinierte Aktivitätssymbole
    enum ActivitySymbol: String, CaseIterable, Identifiable, Hashable {
        case football = "soccerball"
        case university = "graduationcap"
        case shopping = "cart"
        case train = "tram"

        // Eindeutige ID für SwiftUI-Listen
        var id: String { rawValue }

        // Lesbarer Name der Aktivität
        var label: String {
            switch self {
            case .football: return "Fußball"
            case .university: return "Uni"
            case .shopping: return "Einkaufen"
            case .train: return "Zug"
            }
        }
    }

    // Auswahlmodus für Aktivitäten
    enum ActivityMode: String, CaseIterable, Hashable {
        case symbols = "Symbole"
        case freetext = "Freitext"
    }

    // Wechselt zwischen gesperrt und entsperrt
    func toggleLock() {
        isLocked.toggle()
    }

    // Fügt eine Aktivität hinzu oder entfernt sie, wenn sie bereits ausgewählt ist
    func toggleActivity(_ activity: ActivitySymbol) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
}
