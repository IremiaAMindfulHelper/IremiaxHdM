import SwiftUI

// 1. Das Enum MUSS definiert sein, bevor es in SOSStep genutzt wird
enum ExerciseType: String, CaseIterable {
    case calculation = "Rechnen"
    case breathing = "Atmen"
    case mantra = "Mantras"
    case memory = "Memory"
}

// 2. Die Struktur nutzt nun das oben definierte Enum
struct SOSStep {
    let type: ExerciseType
    let icon: String
    var name: String { type.rawValue }
}

// 3. Jetzt kann Swift '.calculation' korrekt zuordnen
let sosSteps: [SOSStep] = [
    SOSStep(type: .calculation, icon: "plus.forwardslash.minus"),
    SOSStep(type: .breathing, icon: "wind"),
    SOSStep(type: .mantra, icon: "leaf"),
    SOSStep(type: .memory, icon: "brain")
]
