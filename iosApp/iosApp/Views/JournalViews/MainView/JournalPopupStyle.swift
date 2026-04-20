//
//  JournalPopupStyle.swift
//  iosApp
//

import SwiftUI

/// Beschreibt das visuelle Erscheinungsbild eines Journal-Popups.
/// Enthält den Text für einen Chip sowie den dazugehörigen Farbverlauf.
struct JournalPopupStyle {

    // Text, der im Chip angezeigt wird
    let chipText: String

    // Hintergrund-Farbverlauf des Chips
    let gradient: LinearGradient
}

enum JournalPopupStyleProvider {

    // DateFormatter für die Kopfzeile des Popups.
    // Formatiert das Datum im deutschen Format: Wochentag, Tag.Monat.
    static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter
    }()

    /// Liefert abhängig vom Typ des Popups und dem Datum
    /// das passende Styling (Text + Farbverlauf).
    static func style(for kind: JournalPopupKind, date: Date) -> JournalPopupStyle {

        // Styling für Mood A
        func moodAStyle() -> JournalPopupStyle {
            JournalPopupStyle(
                chipText: "deprimiert, fröhlich",
                gradient: LinearGradient(
                    colors: [
                        Color.red.opacity(0.95),
                        Color.blue.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        // Styling für Mood B
        func moodBStyle() -> JournalPopupStyle {
            JournalPopupStyle(
                chipText: "energiegeladen, fröhlich",
                gradient: LinearGradient(
                    colors: [
                        Color.green.opacity(0.95),
                        Color.blue.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        // Wählt das passende Styling je nach Popup-Art
        switch kind {

        case .moodA:
            return moodAStyle()

        case .moodB:
            return moodBStyle()

        case .panic:
            // Bestimmt den Tag des Monats
            let day = Calendar(identifier: .gregorian)
                .component(.day, from: date)

            // Beispielhafte Logik:
            // An bestimmten Tagen wird ein anderes Styling verwendet
            if day == 6 { return moodAStyle() }
            if day == 7 { return moodBStyle() }

            // Standard-Fallback
            return moodBStyle()
        }
    }
}
