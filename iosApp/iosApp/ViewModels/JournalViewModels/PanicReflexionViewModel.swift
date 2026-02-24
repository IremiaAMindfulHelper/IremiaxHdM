import Foundation

/*
 Diese Klasse verwaltet die Daten für eine Panik-Reflexion.
 Sie speichert Informationen zur Situation, Intensität,
 Symptomen, Gefühlen, eingesetzten Strategien und
 persönlichen Reflexionen. Außerdem steuert sie,
 welche Abschnitte im UI ein- oder ausgeklappt sind.
*/
final class PanicReflexionViewModel: ObservableObject {

    // Speichert, welche Bereiche der Ansicht aufgeklappt sind
    @Published var expanded: [Bool] = [true, true, true, true]

    // Erstellt ein Binding für einen bestimmten Abschnitt
    // Damit kann der UI-Status direkt mit dem Array verbunden werden
    func expandedBinding(_ index: Int) -> BindingProxy<Bool> {
        BindingProxy(
            get: { [weak self] in
                guard let self else { return false }
                return self.expanded.indices.contains(index) ? self.expanded[index] : false
            },
            set: { [weak self] newValue in
                guard let self else { return }
                guard self.expanded.indices.contains(index) else { return }
                self.expanded[index] = newValue
            }
        )
    }

    // Ort der Situation
    @Published var location1: String = ""
    
    // Auslösender Faktor
    @Published var cause1: String = ""
    
    // Intensität der Belastung auf einer Skala
    @Published var intensity1: Double = 5

    // Vordefinierte Symptomliste
    @Published var symptomOptions: [String] = ["Schwindel", "Kurzatmigkeit", "Herzrasen"]
    
    // Ausgewählte Symptome
    @Published var selectedSymptoms: Set<String> = []
    
    // Texteingabe für ein neues Symptom
    @Published var newSymptomText: String = ""

    // Ausgewählte Gefühle
    @Published var selectedFeelings: Set<String> = []

    // Vordefinierte Gefühlsoptionen mit Schlüssel und Anzeige
    let feelingOptions: [(key: String, emoji: String, label: String)] = [
        ("wut", "😠", "Wut"),
        ("panikAngst", "😨", "Panik/Angst"),
        ("hilflosigkeit", "🧍", "Hilflosigkeit")
    ]

    // Fügt ein Symptom hinzu oder entfernt es aus der Auswahl
    func toggleSymptom(_ item: String) {
        if selectedSymptoms.contains(item) {
            selectedSymptoms.remove(item)
        } else {
            selectedSymptoms.insert(item)
        }
    }

    // Entfernt ein Symptom komplett aus der Liste und Auswahl
    func deleteSymptom(_ item: String) {
        symptomOptions.removeAll { $0 == item }
        selectedSymptoms.remove(item)
    }

    // Fügt ein neues Symptom hinzu, wenn es gültig und noch nicht vorhanden ist
    // Gibt true zurück, wenn das Hinzufügen erfolgreich war
    func addSymptomIfPossible() -> Bool {
        let cleaned = newSymptomText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return false }

        let exists = symptomOptions.contains { $0.lowercased() == cleaned.lowercased() }
        guard !exists else {
            newSymptomText = ""
            return false
        }

        symptomOptions.append(cleaned)
        selectedSymptoms.insert(cleaned)
        newSymptomText = ""
        return true
    }

    // Fügt ein Gefühl hinzu oder entfernt es aus der Auswahl
    func toggleFeeling(_ key: String) {
        if selectedFeelings.contains(key) {
            selectedFeelings.remove(key)
        } else {
            selectedFeelings.insert(key)
        }
    }

    // Bewertung, wie hilfreich eine Strategie war
    @Published var skillEffectiveness: Double = 5
    
    // Notiz für zukünftige Situationen
    @Published var nextTimeText: String = ""

    // Kurze persönliche Reflexion
    @Published var shortReflection: String = ""

    /*
     Hilfsstruktur, um eigene Bindings zu erstellen.
     Wird genutzt, um Getter und Setter manuell zu definieren.
    */
    struct BindingProxy<Value> {
        let get: () -> Value
        let set: (Value) -> Void
    }
}
