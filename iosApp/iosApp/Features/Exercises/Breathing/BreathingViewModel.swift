import SwiftUI
import Shared

/// Manages the breathing exercise logic and acts as a bridge to the Kotlin-based `BreathingEngine`.
/// It handles the exercise state, timer ticks, and scoring updates.
class BreathingViewModel: ObservableObject {
    private var engine = BreathingEngine()
    
    @Published var timeLeft: Int = 180
    @Published var points: Int = 0
    @Published var isIntroActive: Bool = true
    @Published var showCheckpoint: Bool = false
    
    /// Updates the exercise state. Should be called every second by an external timer.
    func tick() {
        engine.updateTimer(onIntroFinished: {
            DispatchQueue.main.async {
                self.isIntroActive = false
            }
        })
        
        self.timeLeft = Int(engine.timeLeft)
        
        if engine.timeLeft == 0 {
            self.showCheckpoint = true
        }
    }
    
    /// Ends the introduction phase immediately and starts the actual exercise timing.
    func endIntro() {
        engine.isIntroActive = false
        self.isIntroActive = false
    }
    
    /// Processes the physical movement of the cloud.
    /// - Parameter offset: The vertical displacement of the cloud from the UI.
    func processMovement(offset: CGFloat) {
        let didScore = engine.handleGesture(offset: Float(offset))
        if didScore {
            self.points = Int(engine.points)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    /// Resets the current gesture flags in the engine. Should be called when the user releases the cloud.
    func resetGesture() {
        engine.resetFlags()
    }
    
    /// Formats the remaining time for display.
    func timeString() -> String {
        let time = engine.timeLeft
        return String(format: "%d:%02d", time / 60, time % 60)
    }
}
