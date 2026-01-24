import SwiftUI

struct MemoryExerciseView: View {
    @Binding var isShowing: Bool   // Um die SOS-Session ganz zu beenden
    @Binding var currentStep: Int // Um zum nächsten Checkpoint zu springen
    
    @State private var backToCheckpoint = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Memory Übung 🧠")
                .font(.largeTitle.bold())
            
            // Spiel-Grid Platzhalter
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(80)), count: 3), spacing: 15) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.1))
                        .frame(height: 80)
                        .overlay(Text("?").font(.largeTitle))
                }
            }
            .padding()

            Spacer()
            
            Button("Fertig & Weiter") {
                goToNextStep()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.2, green: 0.45, blue: 0.55))
            .cornerRadius(15)
            .padding(.horizontal, 40)
        }
        .padding()
        // Öffnet den Checkpoint neu mit dem nächsten Index
        .fullScreenCover(isPresented: $backToCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }

    func goToNextStep() {
        if currentStep < sosSteps.count - 1 {
            currentStep += 1
            backToCheckpoint = true
        } else {
            // Wenn alles fertig ist, schließe das gesamte SOS-Overlay
            isShowing = false
        }
    }
}
