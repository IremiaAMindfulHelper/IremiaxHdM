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
                // MARK: - PROGRESS BAR (SOS Flow Icons)
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
                                }
                            }
                            .frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        
                        if index != sosSteps.count - 1 {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color.gray.opacity(0.15)).frame(width: 25, height: 2)
                                Rectangle().fill(petrolColor).frame(width: index < animatedStep ? 25 : 0, height: 2)
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
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(petrolColor)
                    
                    VStack(spacing: 8) {
                        Text(currentStep < sosSteps.count - 1 ? "Gute Arbeit." : "Geschafft!")
                            .font(.system(.title, design: .rounded)).bold()
                        
                        Text(currentStep < sosSteps.count - 1 ? "Du hast diesen Schritt geschafft.\nBereit für den nächsten?" : "Du hast alle SOS-Übungen erfolgreich abgeschlossen.")
                            .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // MARK: - BUTTONS
                VStack(spacing: 16) {
                    if currentStep < sosSteps.count - 1 {
                        Button(action: {
                            currentStep += 1
                            showExercise = true
                        }) {
                            Text("Nächste Übung")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 62)
                                .background(petrolColor).cornerRadius(31)
                        }
                    } else {
                        Button(action: {
                            withAnimation { isShowing = false }
                        }) {
                            Text("Übungen beenden")
                                .font(.headline).foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 62)
                                .background(Color.green).cornerRadius(31)
                        }
                    }
                    
                    Button(action: { showExercise = true }) {
                        Text("Wiederholen").font(.subheadline.bold()).foregroundColor(petrolColor)
                    }
                }
                .padding(.horizontal, 40).padding(.bottom, 50)
            }
        }
        .onAppear {
            animatedStep = currentStep
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    if currentStep < sosSteps.count - 1 { animatedStep = currentStep + 1 }
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
        // WICHTIG: isStandalone: false, damit der Checkpoint im SOS Flow wiederkommt
        switch step.type {
        case .calculation: CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .breathing: BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .memory: MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        default: Text("Mantra View")
        }
    }
}
