//
//  PanicReflexionViewModel.swift
//  iosApp
//
//  Created by Anke Raab on 23.02.26.
//
import Foundation

final class PanicReflexionViewModel: ObservableObject {

    // MARK: - Expand / Sections

    @Published var expanded: [Bool] = [true, true, true, true]

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

    // MARK: - Situation & Belastung

    @Published var location1: String = ""
    @Published var cause1: String = ""
    @Published var intensity1: Double = 5

    // MARK: - Symptome & Gefühle

    @Published var symptomOptions: [String] = ["Schwindel", "Kurzatmigkeit", "Herzrasen"]
    @Published var selectedSymptoms: Set<String> = []
    @Published var newSymptomText: String = ""

    @Published var selectedFeelings: Set<String> = []

    let feelingOptions: [(key: String, emoji: String, label: String)] = [
        ("wut", "😠", "Wut"),
        ("panikAngst", "😨", "Panik/Angst"),
        ("hilflosigkeit", "🧍", "Hilflosigkeit")
    ]

    func toggleSymptom(_ item: String) {
        if selectedSymptoms.contains(item) {
            selectedSymptoms.remove(item)
        } else {
            selectedSymptoms.insert(item)
        }
    }

    func deleteSymptom(_ item: String) {
        symptomOptions.removeAll { $0 == item }
        selectedSymptoms.remove(item)
    }

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

    func toggleFeeling(_ key: String) {
        if selectedFeelings.contains(key) {
            selectedFeelings.remove(key)
        } else {
            selectedFeelings.insert(key)
        }
    }

    // MARK: - Unterstützung

    @Published var skillEffectiveness: Double = 5
    @Published var nextTimeText: String = ""

    // MARK: - Reflexion

    @Published var shortReflection: String = ""

    // MARK: - Helpers

    struct BindingProxy<Value> {
        let get: () -> Value
        let set: (Value) -> Void
    }
}

