import SwiftUI

struct CheckpointView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @State private var showExercise = false
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack(spacing: 0) {
                    ForEach(0..<sosSteps.count, id: \.self) { index in
                        let isActive = currentStep == index
                        let isCompleted = index < currentStep
                        
                        // 1. ÜBUNGS-ICON (DIE LUPE)
                        VStack(spacing: 8) {
                            ZStack {
                                // Hintergrund-Kreis
                                Circle()
                                    .fill(isCompleted ? petrolColor : Color.white)
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: isActive ? 10 : 0)
                                
                                // Rand
                                Circle()
                                    .stroke(isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.2)), lineWidth: isActive ? 2.5 : 1)
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                
                                // Icon
                                Image(systemName: sosSteps[index].icon)
                                    .font(.system(size: isActive ? 24 : 14, weight: isActive ? .bold : .medium))
                                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray))
                            }
                            .frame(width: 65, height: 65)
                            // LUPEN-ANIMATION
                            .animation(.spring(response: 0.9, dampingFraction: 0.7), value: currentStep)
                            
                            // Label unter dem Icon
                            ZStack {
                                if isActive {
                                    Text(sosSteps[index].name)
                                        .font(.caption.bold())
                                        .foregroundColor(petrolColor)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring().delay(0.5)),
                                            removal: .opacity.animation(.easeInOut(duration: 0.2))
                                        ))
                                }
                            }
                            .frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // 2. VERBINDUNGSLINIE
                        if index != sosSteps.count - 1 {
                            ZStack(alignment: .leading) {
                                // Hintergrund-Schiene
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 25, height: 2)
                                
                                // Vordergrund-Faden
                                Rectangle()
                                    .fill(petrolColor)
                                    .frame(width: index < currentStep ? 25 : 0, height: 2)
                                    .shadow(color: petrolColor.opacity(index < currentStep ? 0.5 : 0), radius: 3)
                            }
                            .padding(.bottom, 24)
                            // LINIEN-ANIMATION
                            .animation(
                                .easeInOut(duration: 1.2)
                                .delay(0.2),
                                value: currentStep
                            )
                        }
                    }
                }
                .padding(.top, 60).padding(.horizontal)
                
                Spacer()
                
                // MARK: - CONTENT BEREICH
                VStack(spacing: 20) {
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        // Sanftes Schweben der Wolke
                        .offset(y: -5)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                    
                    VStack(spacing: 8) {
                        Text("Gute Arbeit.")
                            .font(.system(.title, design: .rounded))
                            .bold()
                        Text("Du hast den nächsten Schritt geschafft.\nGehen wir weiter.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // MARK: - BUTTON BEREICH
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation { showExercise = true }
                    }) {
                        Text("Nächste Übung")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(petrolColor)
                            .cornerRadius(31)
                            .shadow(color: petrolColor.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Button(action: {
                        // Zurücksetzen mit langsamer Rückwärts-Animation
                        withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                            currentStep = 0
                        }
                    }) {
                        Text("Wiederholen")
                            .font(.subheadline.bold())
                            .foregroundColor(petrolColor)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            destinationView()
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        let step = sosSteps[min(currentStep, sosSteps.count - 1)]
        switch step.type {
        case .calculation: CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep)
        case .breathing: BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep)
        case .mantra:
            // Wir nehmen hier beispielhaft das erste Mantra aus deinen WellnessData
            if let firstMantra = WellnessData.mantras.first {
                MantraView(mantra: firstMantra, isShowing: $isShowing, currentStep: $currentStep)
            } else {
                // Fallback, falls die Liste leer sein sollte
                Text("Kein Mantra verfügbar")
            }
        case .memory:
            VStack {
                Text("Memory View")
                Button("Schließen") { showExercise = false }
            }
        }
    }
}

// Preview für schnelles Testen
struct CheckpointView_Previews: PreviewProvider {
    static var previews: some View {
        CheckpointView(isShowing: .constant(true), currentStep: .constant(2))
    }
}
