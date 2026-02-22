import SwiftUI
import Shared

class EmergencyPlanViewModel: ObservableObject {
    @Published var engine = BreathingEngine()
    @Published var startFirstExercise = false
    
    var sosSteps: [Shared.SOSStep] {
        return SOSFlowData.shared.steps
    }
    
    func tick() {
        engine.updateTimer(onIntroFinished: {
            DispatchQueue.main.async {
                self.startFirstExercise = true
            }
        })
        objectWillChange.send()
    }
}

