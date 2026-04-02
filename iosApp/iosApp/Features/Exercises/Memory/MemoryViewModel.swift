import SwiftUI
import Shared

/// Manages the state of the Memory game, bridging the Swift UI with the Kotlin `MemoryEngine`.
/// Handles card selection logic, mismatch timeouts, and game timer synchronization.
class MemoryViewModel: ObservableObject {
    @Published var engine = MemoryEngine()
    
    /// Provides a Swift-compatible array of card objects for easier view iteration.
    var cards: [WellnessMemoryCard] {
        return engine.cards as? [WellnessMemoryCard] ?? []
    }
    
    /// Processes card selection and handles matching logic via the Kotlin engine.
    /// - Parameter index: The position of the selected card in the grid.
    func selectCard(at index: Int) {
        // NOTE: Preventing further selection if two cards are already visible to avoid logic conflicts.
        let faceUpCount = cards.filter { $0.isFaceUp && !$0.isMatched }.count
        if faceUpCount >= 2 { return }

        let isMatch = engine.handleSelection(index: Int32(index))
        
        objectWillChange.send()
        
        // NOTE: If no match is found, we provide a short delay.
        if !isMatch && engine.firstSelectedIndex == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.engine.clearNonMatchedCards()
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    /// Synchronizes the local UI state with the Kotlin engine's internal timer.
    func tick() {
        engine.updateTimer()
        objectWillChange.send()
    }
    
    /// Formats the remaining time for the UI.
    /// - Returns: A string in "M:SS" format.
    func timeString() -> String {
        let seconds = engine.secondsRemaining
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
