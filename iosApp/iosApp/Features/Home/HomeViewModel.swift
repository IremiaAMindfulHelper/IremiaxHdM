import Foundation
import Shared

class HomeViewModel: ObservableObject {
    // Holt die Daten direkt aus dem Kotlin-Framework
    @Published var exercises: [WellnessExercise] = WellnessRepository.shared.exercises
    @Published var mantras: [WellnessMantra] = WellnessRepository.shared.mantras
    @Published var sounds: [WellnessSound] = WellnessRepository.shared.sounds
}
