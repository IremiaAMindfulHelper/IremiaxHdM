import SwiftUI

enum ExerciseType: String, CaseIterable {
    case calculation = "Rechnen"
    case breathing = "Atmen"
    case mantra = "Mantras"
    case memory = "Memory"
}

struct SOSStep: Identifiable {
    let id = UUID()
    let type: ExerciseType
    let icon: String
    var name: String { type.rawValue }
}

//  zentrale Reihenfolge
let sosSteps: [SOSStep] = [
    SOSStep(type: .calculation, icon: "plus.forwardslash.minus"),
    SOSStep(type: .breathing, icon: "wind"),
    SOSStep(type: .mantra, icon: "leaf"),
    SOSStep(type: .memory, icon: "brain")
]
