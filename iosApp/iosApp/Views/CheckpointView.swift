import SwiftUI
import Shared

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
                    // Wir nutzen den Index der Liste, damit 'index' direkt ein Int ist
                    ForEach(0..<viewModel.sosSteps.count, id: \.self) { index in
                        let step = viewModel.sosSteps[index]
                        let isActive = viewModel.animatedStep == index
                        let isCompleted = index < viewModel.animatedStep
                        
                        // Dein Icon
                        StepIconView(step: step, isActive: isActive, isCompleted: isCompleted, petrolColor: petrolColor)
                        
                        // Der Connector (nur wenn es nicht der letzte Schritt ist)
                        if index != viewModel.sosSteps.count - 1 {
                            ProgressConnector(isCompleted: index < viewModel.animatedStep, petrolColor: petrolColor)
                        }
                    }
                }
                .padding(.top, 60).padding(.horizontal)
                
                Spacer()
                
                // MARK: - CONTENT (Wolke)
                VStack(spacing: 20) {
                    Image("Cloud")
                        .resizable().scaledToFit().frame(width: 160)
                        .offset(y: isFloating ? -10 : 10)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { isFloating = true }
                        }
                    
                    VStack(spacing: 8) {
                        Text(currentStep < viewModel.sosSteps.count - 1 ? "Gute Arbeit." : "Geschafft!")
                            .font(.system(.title, design: .rounded)).bold()
                        
                        Text(currentStep < viewModel.sosSteps.count - 1 ? "Du hast diesen Schritt geschafft.\nBereit für den nächsten?" : "Du hast alle SOS-Übungen abgeschlossen.")
                            .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                // MARK: - BUTTONS
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
    
    @ViewBuilder
    func destinationView() -> some View {
        // Wir holen uns den Typ aus dem aktuellen Schritt
        let stepType = viewModel.sosSteps[currentStep].type
        
        switch stepType {
        case .calculation:
            CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .breathing:
            BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .memory:
            MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        case .mantra:
            MantraView(mantra: WellnessData.mantras[0], isShowing: $isShowing, currentStep: $currentStep, isStandalone: false)
        default:
            EmptyView()
        }
    }
}

// MARK: - HELPER VIEWS (Damit die Fehler verschwinden)

struct StepIconView: View {
    let step: SOSStep
    let isActive: Bool
    let isCompleted: Bool
    let petrolColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCompleted ? petrolColor : Color.white)
                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: isActive ? 10 : 0)
                
                Circle()
                    .stroke(isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.2)), lineWidth: isActive ? 2.5 : 1)
                    .frame(width: isActive ? 60 : 40, height: isActive ? 60 : 40)
                
                Image(systemName: step.icon)
                    .font(.system(size: isActive ? 28 : 18, weight: isActive ? .bold : .medium))
                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray))
            }
            .frame(width: 70, height: 70)
            
            if isActive {
                Text(step.name)
                    .font(.caption.bold())
                    .foregroundColor(petrolColor)
                    .transition(.opacity)
            } else {
                Text(" ").font(.caption) // Platzhalter
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProgressConnector: View {
    let isCompleted: Bool
    let petrolColor: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 25, height: 2)
            
            Rectangle()
                .fill(petrolColor)
                .frame(width: isCompleted ? 25 : 0, height: 2)
        }
        .padding(.bottom, 24)
    }
}
// MARK: - PREVIEW
#Preview("Mittelpunkt des Flows") {
    CheckpointView(
        isShowing: .constant(true),
        currentStep: .constant(1) // Zeigt z.B. nach der ersten Übung
    )
}

#Preview("Alles abgeschlossen") {
    CheckpointView(
        isShowing: .constant(true),
        currentStep: .constant(3) // Index des letzten Schritts (Mantra)
    )
}
