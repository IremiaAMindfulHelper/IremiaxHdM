import SwiftUI
import Shared

// MARK: - VIEW MODEL
class MemoryViewModel: ObservableObject {
    @Published var engine = MemoryEngine()
    
    // Hilfs-Property für Swift-Array Zugriff
    var cards: [WellnessMemoryCard] {
        return engine.cards as? [WellnessMemoryCard] ?? []
    }
    
    func selectCard(at index: Int) {
        // Sicherstellen, dass nicht mehr als 2 Karten gleichzeitig "offen" (aber nicht gematcht) sind
        let faceUpCount = cards.filter { $0.isFaceUp && !$0.isMatched }.count
        if faceUpCount >= 2 { return }

        let isMatch = engine.handleSelection(index: Int32(index))
        
        // UI sofort aktualisieren (Karte wird aufgedeckt)
        objectWillChange.send()
        
        // Wenn kein Match gefunden wurde und es die zweite Karte war
        if !isMatch && engine.firstSelectedIndex == nil {
            // Warte kurz, damit der User sich die Karte merken kann
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // Karten in Kotlin wieder zudecken
                self.engine.clearNonMatchedCards()
                // UI mit Animation aktualisieren
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func tick() {
        engine.updateTimer()
        objectWillChange.send()
    }
    
    func timeString() -> String {
        let seconds = engine.secondsRemaining
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
