import SwiftUI
import shared

/// ViewModel for the rapid-response Emergency Plan.
/// Synchronizes the initial breathing pace and triggers the transition to the SOS flow.
class EmergencyPlanViewModel: ObservableObject {
    @Published var engine = BreathingEngine()
    
    @Published var startFirstExercise = false
    
    /// Provides access to the predefined SOS steps from the Shared Kotlin data.
    var sosSteps: [SOSStep] {
        return SOSFlowData.shared.steps
    }
    
    /// Advances the internal engine timer and checks for phase completion.
    func tick() {
        engine.updateTimer(onIntroFinished: {
            DispatchQueue.main.async {
                self.startFirstExercise = true
            }
        })
        
        
        objectWillChange.send()
    }
}
