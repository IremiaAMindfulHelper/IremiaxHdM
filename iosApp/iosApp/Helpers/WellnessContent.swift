//
//  WellnessContent.swift
//  iosApp
//
//  Created by Michael Jaufmann on 24.01.26.
//


import Foundation

// MARK: - Basis Protokoll
protocol WellnessContent: Identifiable {
    var id: UUID { get }
    var titel: String { get }
}

// MARK: - Spezifische Modelle
struct Exercise: WellnessContent {
    let id = UUID()
    let kategorie: String
    let titel: String
    let dauer: String
    let beschreibung: String
}

struct Mantra: WellnessContent {
    let id = UUID()
    let titel: String
    let spruch: String
}

struct Sound: WellnessContent {
    let id = UUID()
    let titel: String
    let beschreibung: String
}

// MARK: - Datenquelle (Dummy Data)
struct WellnessData {
    static let exercises = [
        Exercise(kategorie: "Achtsamkeit", titel: "Atemübung", dauer: "10 Min", beschreibung: "Beruhige deinen Atem."),
        Exercise(kategorie: "Fokus", titel: "Mathe Quiz", dauer: "10 Min", beschreibung: "Fokus durch Kopfrechnen."),
        Exercise(kategorie: "Ablenkung", titel: "Ballon-Pop", dauer: "10 Min", beschreibung: "Lass so viele Ballons wie möglich platzen.")
    ]
    
    static let mantras = [
        Mantra(titel: "Innere Ruhe", spruch: "Ich bin ganz bei mir und finde Frieden."),
        Mantra(titel: "Selbstvertrauen", spruch: "Ich vertraue meinen Fähigkeiten.")
        
    ]
    
    static let sounds = [
        Sound(titel: "Meeresrauschen", beschreibung: "Lass dich von sanften Wellen beruhigen."),
        Sound(titel: "Regenplätschern", beschreibung: "Finde Gelassenheit in den Tropfen."),
        Sound(titel: "Waldgeräusche", beschreibung: "Entspanne dich mit den Klängen des Waldes.")
    ]
}
