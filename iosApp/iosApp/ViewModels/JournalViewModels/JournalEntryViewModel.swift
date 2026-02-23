//
//  JournalEntryViewModel.swift
//  iosApp
//
//  Created by Anke Raab on 23.02.26.
//

import Foundation
import CoreGraphics

final class JournalEntryViewModel: ObservableObject {

    // Stimmungskugel: normalisierte X/Y-Position (-1...1)
    @Published var ballPosition: CGPoint = CGPoint(x: 0, y: 0)

    // Sperrt das Verschieben der Stimmungskugel
    @Published var isLocked: Bool = false

    // Umschalter zwischen Symbol-Auswahl und Freitext
    @Published var activityMode: ActivityMode = .symbols

    // Ausgewählte Aktivitäts-Symbole
    @Published var selectedActivities: Set<ActivitySymbol> = []

    // Freitext-Aktivität
    @Published var freeTextActivity: String = ""

    // Gesundheitstracker (Textfelder als String)
    @Published var waterLiters: String = "0"
    @Published var sleepHours: String = "0"

    // Notizen
    @Published var notes: String = ""

    // MARK: - Types

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

    // MARK: - Actions

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
