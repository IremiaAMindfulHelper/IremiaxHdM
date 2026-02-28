import SwiftUI
import Shared

/// A transition view shown between SOS exercises to provide positive reinforcement.
/// Displays a horizontal progress tracker and handles navigation to subsequent exercises.
struct CheckpointView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    
    @StateObject private var viewModel = CheckpointViewModel()
    @State private var showExercise = false
    @State private var isFloating = false
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - PROGRESS BAR
                HStack(spacing: 0) {
                    ForEach(0..<viewModel.sosSteps.count, id: \.self) { index in
                        let step = viewModel.sosSteps[index]
                        
                        StepIconView(
                            step: step,
                            isActive: viewModel.animatedStep == index,
                            isCompleted: index < viewModel.animatedStep,
                            petrolColor: petrolColor
                        )
                        
                        if index != viewModel.sosSteps.count - 1 {
                            ProgressConnector(
                                isCompleted: index < viewModel.animatedStep,
                                petrolColor: petrolColor
                            )
                        }
                    }
                }
                .padding(.top, 60).padding(.horizontal)
                
                Spacer()
                
                // MARK: - FEEDBACK CONTENT
                VStack(spacing: 20) {
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .offset(y: isFloating ? -10 : 10)
                        .onAppear {
                            // NOTE: Forever-looping animation to create a calming, living UI effect.
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                isFloating = true
                            }
                        }
                    
                    VStack(spacing: 8) {
                        Text(currentStep < viewModel.sosSteps.count - 1 ? "Gute Arbeit." : "Geschafft!")
                            .font(.system(.title, design: .rounded)).bold()
                        
                        Text(currentStep < viewModel.sosSteps.count - 1 ?
                             "Du hast diesen Schritt geschafft.\nBereit für den nächsten?" :
                             "Du hast alle SOS-Übungen abgeschlossen.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // MARK: - NAVIGATION BUTTONS
                VStack(spacing: 16) {
                    if currentStep < viewModel.sosSteps.count - 1 {
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
                        Button(action: { withAnimation { isShowing = false } }) {
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
            viewModel.prepareNextStep(currentStep: currentStep)
        }
        .fullScreenCover(isPresented: $showExercise) {
            destinationView()
        }
    }
    
    /// Factory method to determine which exercise view to present based on the current step type.
    @ViewBuilder
    func destinationView() -> some View {
        let stepType = viewModel.sosSteps[currentStep].type
        
        switch stepType {
        case .calculation:
            CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .breathing:
            BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .memory:
            MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .mantra:
            MantraView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        default:
            EmptyView()
        }
    }
}
// MARK: - PREVIEW
#Preview("Mittelpunkt des Flows") {
    CheckpointView(
        isShowing: .constant(true),
        currentStep: .constant(1)
    )
}

#Preview("Alles abgeschlossen") {
    CheckpointView(
        isShowing: .constant(true),
        currentStep: .constant(3)
    )
}
