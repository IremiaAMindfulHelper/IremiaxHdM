import SwiftUI

struct BreathingExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    
    // Ermöglicht das Schließen dieses Screens, um zum Checkpoint zurückzukehren
    @Environment(\.dismiss) var dismiss
    
    @State private var animationValue: CGFloat = 0.8
    @State private var instructionText = "Einatmen"
    @State private var timerCount = 0
    
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        VStack(spacing: 30) {
            // MARK: - Header (Identisch mit Rechenübung)
            HStack(spacing: 20) {
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(petrolColor)
                        .frame(width: 180, height: 12)
                }
                
                Button(action: { /* Notruf-Logik */ }) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // MARK: - Atem-Animation
            VStack(spacing: 50) {
                ZStack {
                    Circle()
                        .fill(petrolColor.opacity(0.15))
                        .frame(width: 280, height: 280)
                        .scaleEffect(animationValue + 0.1)
                    
                    Circle()
                        .fill(petrolColor.opacity(0.6))
                        .frame(width: 200, height: 200)
                        .scaleEffect(animationValue)
                        .shadow(color: petrolColor.opacity(0.3), radius: 20)
                }
                .animation(.easeInOut(duration: 4), value: animationValue)
                
                Text(instructionText)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundColor(petrolColor)
                    .transition(.opacity)
                    .id(instructionText)
            }
            .onAppear {
                startAnimation()
            }
            .onReceive(timer) { _ in
                togglePhase()
            }
            
            Spacer()
            
            // MARK: - Footer
            Button(action: { goToNextStep() }) {
                HStack {
                    Text("Überspringen")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Logik
    private func startAnimation() {
        animationValue = 1.3
    }
    
    private func togglePhase() {
        timerCount += 1
        
        withAnimation(.easeInOut(duration: 4)) {
            if instructionText == "Einatmen" {
                instructionText = "Ausatmen"
                animationValue = 0.8
            } else {
                instructionText = "Einatmen"
                animationValue = 1.3
            }
        }
    }
    
    // MARK: - Navigation
    func goToNextStep() {
        if currentStep < sosSteps.count - 1 {
            // Index in der Hauptliste erhöhen
            withAnimation(.spring()) {
                currentStep += 1
            }
            // Diesen Screen schließen, um den aktualisierten Checkpoint zu zeigen
            dismiss()
        } else {
            // Alles fertig
            isShowing = false
        }
    }
}
