import SwiftUI

struct CheckpointView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @State private var showExercise = false
    
    // Wir führen einen lokalen State ein, der anzeigt, dass wir
    // gerade eine Übung erfolgreich beendet haben.
    @State private var isTransitioningToNext = true
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - PROGRESS BAR
                HStack(spacing: 0) {
                    ForEach(0..<sosSteps.count, id: \.self) { index in
                        // LOGIK-FIX:
                        // Das Icon ist "Completed", wenn der Index kleiner als currentStep + 1 ist.
                        // Die Lupe (isActive) springt sofort auf den NÄCHSTEN Index.
                        let displayActiveIndex = currentStep + 1
                        let isActive = displayActiveIndex == index
                        let isCompleted = index <= currentStep
                        
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? petrolColor : Color.white)
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: isActive ? 10 : 0)
                                
                                Circle()
                                    .stroke(isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.2)), lineWidth: isActive ? 2.5 : 1)
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                
                                Image(systemName: sosSteps[index].icon)
                                    .font(.system(size: isActive ? 24 : 14, weight: isActive ? .bold : .medium))
                                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray))
                            }
                            .frame(width: 65, height: 65)
                            .animation(.spring(response: 0.9, dampingFraction: 0.7), value: currentStep)
                            
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
                        
                        // Verbindungslinie
                        if index != sosSteps.count - 1 {
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 25, height: 2)
                                Rectangle()
                                    .fill(petrolColor)
                                    .frame(width: index <= currentStep ? 25 : 0, height: 2)
                            }
                            .padding(.bottom, 24)
                            .animation(.easeInOut(duration: 1.2), value: currentStep)
                        }
                    }
                }
                .padding(.top, 60).padding(.horizontal)
                
                Spacer()
                
                // MARK: - CONTENT
                VStack(spacing: 20) {
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                    
                    VStack(spacing: 8) {
                        Text("Gute Arbeit.")
                            .font(.system(.title, design: .rounded))
                            .bold()
                        Text("Du hast diesen Schritt geschafft.\nBereit für den nächsten?")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // MARK: - BUTTONS
                VStack(spacing: 16) {
                    Button(action: {
                        // Da wir die Anzeige oben schon manipuliert haben,
                        // müssen wir currentStep jetzt wirklich erhöhen, bevor die Übung startet.
                        currentStep += 1
                        showExercise = true
                    }) {
                        Text("Nächste Übung")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(petrolColor)
                            .cornerRadius(31)
                    }
                    
                    Button(action: {
                        // Wiederholen bedeutet: Wir bleiben im gleichen Step.
                        showExercise = true
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
            // Logik-Check: Wenn wir auf "Nächste" geklickt haben, ist currentStep bereits erhöht.
            // Wenn wir auf "Wiederholen" geklickt haben, ist er noch gleich.
            destinationView()
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        let step = sosSteps[currentStep]
        switch step.type {
        case .calculation: CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep)
        case .breathing: BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep)
        case .mantra:
            if let mantra = WellnessData.mantras.first {
                MantraView(mantra: mantra, isShowing: $isShowing, currentStep: $currentStep)
            }
        case .memory: MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
}
// MARK: - PREVIEW
struct CheckpointView_Previews: PreviewProvider {
    static var previews: some View {
        CheckpointView(isShowing: .constant(true), currentStep: .constant(2))
    }
}
