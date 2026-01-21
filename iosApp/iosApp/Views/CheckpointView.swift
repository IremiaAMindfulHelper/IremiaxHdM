import SwiftUI

struct CheckpointView: View {
    @Binding var isShowing: Bool
    @State var currentStep: Int = 0
    @State private var showExercise = false
    
    // Die Farbe aus deinem Design
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    @State private var userOrder: [SOSStep] = sosSteps
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // 1. ANIMIERTE PROGRESSBAR (Lupen-Effekt)
                HStack(spacing: 0) {
                    ForEach(0..<userOrder.count, id: \.self) { index in
                        let isActive = currentStep == index      // Aktuelle Übung (Groß & Weiß)
                        let isCompleted = index < currentStep   // Erledigt (Blau & Klein)
                        
                        VStack(spacing: 8) {
                            ZStack {
                                // Hintergrund-Kreis
                                Circle()
                                    // Nur fertige Übungen sind ausgefüllt, die aktuelle bleibt weiß
                                    .fill(isCompleted ? petrolColor : Color.white)
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                    .shadow(color: .black.opacity(isActive ? 0.15 : 0), radius: 6)
                                
                                // Rand-Logik
                                Circle()
                                    .stroke(
                                        isActive ? petrolColor : (isCompleted ? Color.clear : Color.gray.opacity(0.3)),
                                        lineWidth: isActive ? 2.5 : 1
                                    )
                                    .frame(width: isActive ? 58 : 35, height: isActive ? 58 : 35)
                                
                                // Icon
                                Image(systemName: userOrder[index].icon)
                                    .font(.system(size: isActive ? 26 : 16, weight: .medium))
                                    // Icon ist weiß auf blauem Grund (fertig) oder petrol auf weißem Grund (aktiv)
                                    .foregroundColor(isCompleted ? .white : (isActive ? petrolColor : .gray.opacity(0.5)))
                            }
                            .frame(width: 65, height: 65)
                            // Langsamere Animation (0.8 Sekunden statt 0.4)
                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: currentStep)
                            
                            // Text-Label unter der Lupe
                            if isActive {
                                Text(userOrder[index].name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(petrolColor)
                                    .fixedSize()
                                    .transition(.opacity.combined(with: .scale))
                            } else {
                                Text("")
                                    .frame(height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Verbindungslinie
                        if index != userOrder.count - 1 {
                            Rectangle()
                                .frame(width: 25, height: 1.5)
                                // Linie wird erst blau, wenn die Übung davor fertig ist
                                .foregroundColor(index < currentStep ? petrolColor : Color.gray.opacity(0.2))
                                .padding(.bottom, 24)
                                .animation(.easeInOut(duration: 0.6), value: currentStep)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // 2. HAUPT-CONTENT
                VStack(spacing: 30) {
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 150)
                        .padding(.bottom, 10)

                    VStack(spacing: 12) {
                        Text("Du bist sicher.")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .kerning(1.5)
                            .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.35))
                        
                        Text("Atme tief durch und nimm dir Zeit.")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // 3. BUTTONS
                VStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            showExercise = true
                        }
                    }) {
                        Text("Weiter")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(petrolColor)
                            .cornerRadius(30)
                            .shadow(color: petrolColor.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) { currentStep = 0 }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Übung wiederholen")
                        }
                        .foregroundColor(petrolColor)
                        .font(.subheadline.weight(.medium))
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            let currentExercise = userOrder[currentStep]
            
            switch currentExercise.type {
            case .calculation:
                CalculationExerciseView(isShowing: $isShowing, currentStep: $currentStep)
            case .breathing:
                EmergencyPlanView(isShowing: $isShowing)
            case .memory:
                MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep)
            case .mantra:
                MantraPlaceholderView(isShowing: $isShowing, currentStep: $currentStep)
            }
        }
    }
}

// Preview
struct CheckpointView_Previews: PreviewProvider {
    static var previews: some View {
        CheckpointView(isShowing: .constant(true))
    }
}



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

