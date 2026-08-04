import Foundation
import shared

/// Provides the data for the main dashboard by interfacing with the `WellnessRepository`.
/// Maps Kotlin-native data structures to SwiftUI observable properties.
class HomeViewModel: ObservableObject {
    /// List of available exercises fetched from the Shared Kotlin repository.
    @Published var exercises: [WellnessExercise] = WellnessRepository.shared.exercises
    
    /// List of available mantras/affirmations.
    @Published var mantras: [WellnessMantra] = WellnessRepository.shared.mantras
    
    /// List of ambient sounds and audio tracks.
    @Published var sounds: [WellnessSound] = WellnessRepository.shared.sounds
}
