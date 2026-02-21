//
//  CheckpointViewModel.swift
//  iosApp
//
//  Created by Michael Jaufmann on 21.02.26.
//


import SwiftUI
import Shared

class CheckpointViewModel: ObservableObject {
    @Published var sosSteps: [SOSStep] = SOSFlowData.shared.steps
    @Published var animatedStep: Int = 0
    
    // Wir nutzen die Kotlin-Logik für den nächsten Schritt
    func prepareNextStep(currentStep: Int) {
        self.animatedStep = currentStep
        
        // Kleine Verzögerung für den visuellen Effekt
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.animatedStep = Int(SOSFlowData.shared.getNextStepIndex(currentIndex: Int32(currentStep)))
            }
        }
    }
}