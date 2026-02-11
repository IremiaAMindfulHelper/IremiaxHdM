//
//  JournalPopupStyle.swift
//  iosApp
//
//  Created by Anke Raab on 11.02.26.
//

import SwiftUI

struct JournalPopupStyle {
    let chipText: String
    let gradient: LinearGradient
}

enum JournalPopupStyleProvider {

    // Formatiert den Header-Text für das Popup.
    static let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter
    }()

    // Liefert den Text und den Farbverlauf für den Chip im Popup.
    static func style(for kind: JournalPopupKind, date: Date) -> JournalPopupStyle {
        func moodAStyle() -> JournalPopupStyle {
            JournalPopupStyle(
                chipText: "deprimiert, fröhlich",
                gradient: LinearGradient(
                    colors: [Color.red.opacity(0.95), Color.blue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        func moodBStyle() -> JournalPopupStyle {
            JournalPopupStyle(
                chipText: "energiegeladen, fröhlich",
                gradient: LinearGradient(
                    colors: [Color.green.opacity(0.95), Color.blue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        switch kind {
        case .moodA:
            return moodAStyle()

        case .moodB:
            return moodBStyle()

        case .panic:
            let day = Calendar(identifier: .gregorian).component(.day, from: date)
            if day == 6 { return moodAStyle() }
            if day == 7 { return moodBStyle() }
            return moodBStyle()
        }
    }
}
