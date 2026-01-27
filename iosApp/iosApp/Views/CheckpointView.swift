import SwiftUI

struct CheckpointView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @State private var showExercise = false
    
    
    @State private var animatedStep: Int = 0
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - PROGRESS BAR
                HStack(spacing: 0) {
                    ForEach(0..<sosSteps.count, id: \.self) { index in
                        
                        let isActive = animatedStep == index
                        let isCompleted = index < animatedStep
                        
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? petrolColor : Color.white)
                                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: isActive ? 10 : 0)
                                
                                Circle()
                                    .stroke(isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.2)), lineWidth: isActive ? 2.5 : 1)
                                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                                
                                Image(systemName: sosSteps[index].icon)
                                    .font(.system(size: isActive ? 28 : 18, weight: isActive ? .bold : .medium))
                                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray))
                            }
                            .frame(width: 70, height: 70)
                            
                            ZStack {
                                if isActive {
                                    Text(sosSteps[index].name)
                                        .font(.caption.bold())
                                        .foregroundColor(petrolColor)
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.8).combined(with: .opacity).animation(.spring().delay(0.2)),
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
                                    .frame(width: index < animatedStep ? 25 : 0, height: 2)
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.top, 60).padding(.horizontal)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animatedStep)
                
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
        .onAppear {
            // Beim Erscheinen setzen wir animatedStep zuerst auf den ALTEN Schritt
            animatedStep = currentStep
            
            // Nach einer kurzen Verzögerung triggern wir die Lupen-Animation zum NÄCHSTEN Schritt
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animatedStep = currentStep + 1
                }
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
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
