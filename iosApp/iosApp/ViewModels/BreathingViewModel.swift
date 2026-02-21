import SwiftUI
import Shared

class BreathingViewModel: ObservableObject {
    private var engine = BreathingEngine()
    
    @Published var timeLeft: Int = 180
    @Published var points: Int = 0
    @Published var isIntroActive: Bool = true
    @Published var showCheckpoint: Bool = false
    
    func tick() {
        engine.updateTimer()
        self.timeLeft = Int(engine.timeLeft)
        if engine.timeLeft == 0 { self.showCheckpoint = true }
    }
    
    func endIntro() {
        engine.isIntroActive = false
        self.isIntroActive = false
    }
    
    func processMovement(offset: CGFloat) {
        let didScore = engine.handleGesture(offset: Float(offset))
        if didScore {
            self.points = Int(engine.points)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func resetGesture() {
        engine.resetFlags()
    }
    
    func timeString() -> String {
        let time = engine.timeLeft
        return String(format: "%d:%02d", time / 60, time % 60)
    }
}
