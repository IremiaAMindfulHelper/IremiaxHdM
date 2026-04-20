import Foundation

// Diese Datei definiert gemeinsame Datentypen für View und ViewModel des Kalenders.
// Sie beschreibt verschiedene Zustände und Darstellungen von Kalenderzellen
// (z.B. Stimmung oder Panik) sowie das Modell einer einzelnen Kalenderzelle.

enum MoodMark: Equatable {
    case moodGradientA
    case moodGradientB
}

enum CellStyle: Equatable {
    case mood(MoodCellStyle)
    case panic(PanicCellStyle)
    case none
}

enum MoodCellStyle: Equatable {
    case plus
    case gradientA
    case gradientB
}

enum PanicCellStyle: Equatable {
    case plus
    case filled
    case brokenHeart
}

// Repräsentiert eine einzelne Zelle im Kalender.
// Enthält alle Informationen, die zur Darstellung und Interaktion benötigt werden.
struct UnifiedCell: Identifiable {
    
    // Eindeutige ID für SwiftUI-Listen
    let id = UUID()
    
    // Tag des Monats (z.B. 1–31)
    let day: Int
    
    // Gibt an, ob der Tag zum aktuell angezeigten Monat gehört
    let isInDisplayedMonth: Bool
    
    // Definiert das visuelle Erscheinungsbild der Zelle
    let style: CellStyle
    
    // Verschiebung relativ zum aktuellen Monat (z.B. -1, 0, +1)
    let monthOffset: Int?
    
    // Tatsächliches Jahr dieser Zelle
    let effectiveYear: Int?
    
    // Tatsächlicher Monat dieser Zelle
    let effectiveMonth: Int?
    
    // Legt fest, ob die Zelle anklickbar ist
    let isTappable: Bool
}
