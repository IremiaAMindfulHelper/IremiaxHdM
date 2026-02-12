//
//  JournalRoutes.swift
//  iosApp
//
//  Created by Anke Raab on 11.02.26.
//

import Foundation

// Definiert alle Navigation-Ziele innerhalb des Journal-Flows.
enum AppRoute: Hashable {
    case journalEntry(date: Date)
    case journalDiaryView(date: Date)
    case panicReflection(date: Date)
    case questionCatalog
}

// Steuert, welche Journal-Startansicht aktiv ist (Stimmung oder Panik).
enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

// Beschreibt, welcher Popup-Typ im Kalender angezeigt werden soll.
enum JournalPopupKind: Hashable {
    case moodA
    case moodB
    case panic
}

// Bündelt die Daten für das Popup-Sheet, damit sheet(item:) stabil arbeiten kann.
struct JournalPopupItem: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let kind: JournalPopupKind
}
