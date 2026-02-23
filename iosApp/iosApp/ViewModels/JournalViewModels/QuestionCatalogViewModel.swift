//
//  QuestionCatalogViewModel.swift
//  iosApp
//
//  Created by Anke Raab on 23.02.26.
//
import Foundation

final class QuestionCatalogViewModel: ObservableObject {

    // Datenquelle der verfügbaren Fragen.
    @Published private(set) var questions: [String]

    // Speichert die aktuell ausgewählten Fragen.
    @Published var selectedQuestions: Set<String> = []

    // Eingabetext für eine neue Frage.
    @Published var newQuestionText: String = ""

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

    // Schaltet den Auswahlstatus einer Frage um.
    func toggleSelection(_ question: String) {
        if selectedQuestions.contains(question) {
            selectedQuestions.remove(question)
        } else {
            selectedQuestions.insert(question)
        }
    }

    // Fügt eine neue Frage hinzu (wenn sinnvoll) und leert das Feld.
    func addQuestionIfPossible() {
        let cleaned = newQuestionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.isEmpty == false else { return }

        // Duplikate vermeiden (case-insensitive).
        let exists = questions.contains { $0.lowercased() == cleaned.lowercased() }
        guard exists == false else {
            newQuestionText = ""
            return
        }

        questions.append(cleaned)
        selectedQuestions.insert(cleaned) // optional: direkt auswählen
        newQuestionText = ""
    }
}

