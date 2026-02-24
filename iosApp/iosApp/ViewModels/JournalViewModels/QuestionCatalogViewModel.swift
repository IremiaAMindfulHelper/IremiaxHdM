//
//  QuestionCatalogViewModel.swift
//  iosApp
//

import Foundation

/// ViewModel für einen Fragenkatalog.
/// Verwaltet eine Liste verfügbarer Fragen,
/// die Auswahl einzelner Fragen und das Hinzufügen neuer Fragen.
final class QuestionCatalogViewModel: ObservableObject {

    // Aktuelle Liste aller verfügbaren Fragen
    @Published private(set) var questions: [String]

    // Menge der aktuell ausgewählten Fragen
    @Published var selectedQuestions: Set<String> = []

    // Textfeld-Inhalt für das Hinzufügen einer neuen Frage
    @Published var newQuestionText: String = ""

    // Initialisiert das ViewModel mit einer Standardliste an Fragen
    init(questions: [String] = [
        "Gab es heute schwierige Momente für dich?",
        "Was ist heute gut gelaufen?",
        "Welche Gedanken oder Sorgen möchtest du heute loslassen?",
        "Was kann dir helfen, die Situation zu verbessern?",
        "Wie hat sich deine Stimmung im Laufe des Tages verändert?",
        "Wofür bist du heute dankbar?",
        "Gibt es etwas, das du morgen anders machen möchtest?"
    ]) {
        self.questions = questions
    }

    // Wechselt den Auswahlstatus einer Frage:
    // Wenn sie ausgewählt ist, wird sie entfernt,
    // sonst wird sie zur Auswahl hinzugefügt.
    func toggleSelection(_ question: String) {
        if selectedQuestions.contains(question) {
            selectedQuestions.remove(question)
        } else {
            selectedQuestions.insert(question)
        }
    }

    // Fügt eine neue Frage zur Liste hinzu,
    // wenn das Eingabefeld nicht leer ist
    // und die Frage noch nicht existiert.
    func addQuestionIfPossible() {

        // Entfernt Leerzeichen am Anfang und Ende
        let cleaned = newQuestionText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Abbrechen, wenn der Text leer ist
        guard cleaned.isEmpty == false else { return }

        // Prüft, ob die Frage bereits existiert (Groß-/Kleinschreibung ignoriert)
        let exists = questions.contains { $0.lowercased() == cleaned.lowercased() }

        // Wenn sie schon existiert, Eingabefeld leeren und abbrechen
        guard exists == false else {
            newQuestionText = ""
            return
        }

        // Neue Frage zur Liste hinzufügen
        questions.append(cleaned)

        // Optional: Neue Frage direkt als ausgewählt markieren
        selectedQuestions.insert(cleaned)

        // Eingabefeld zurücksetzen
        newQuestionText = ""
    }
}
