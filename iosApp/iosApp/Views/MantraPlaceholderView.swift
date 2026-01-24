import SwiftUI

// Kleiner Platzhalter für Mantras, damit der Code kompiliert
struct MantraPlaceholderView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var body: some View {
        VStack {
            Text("Mantra Übung kommt hier...")
            Button("Fertig") {
                if currentStep < sosSteps.count - 1 {
                    currentStep += 1
                } else {
                    isShowing = false
                }
            }
        }
    }
}

