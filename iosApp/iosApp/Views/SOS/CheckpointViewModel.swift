import SwiftUI
import Shared

/// Manages the visual and logical progression between SOS exercise steps.
class CheckpointViewModel: ObservableObject {
    /// The list of steps defined in the Shared Kotlin module.
    @Published var sosSteps: [SOSStep] = SOSFlowData.shared.steps
    
    /// The current step index that is visually highlighted.
    @Published var animatedStep: Int = 0
    
    /// Prepares the transition to the next step index with a visual delay.
    /// - Parameter currentStep: The index of the exercise just completed.
    func prepareNextStep(currentStep: Int) {
        self.animatedStep = currentStep
        
        // NOTE: Artificial delay ensures the user perceives the completion
        // of the previous step before the progress bar advances.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                let nextIndex = SOSFlowData.shared.getNextStepIndex(currentIndex: Int32(currentStep))
                self.animatedStep = Int(nextIndex)
            }
        }
    }
}
