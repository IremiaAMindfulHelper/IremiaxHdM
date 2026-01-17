import SwiftUI

struct CheckpointView: View {
    @Binding var isShowing: Bool
    @State var currentStep: Int = 0
    @State private var showExercise = false
    
    // Hier nutzen wir die globale Liste als Startpunkt für die Reihenfolge
    @State private var userOrder: [SOSStep] = sosSteps
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 1. ANIMIERTE PROGRESSBAR
                // 1. ANIMIERTE PROGRESSBAR
                HStack(spacing: 0) {
                    ForEach(0..<userOrder.count, id: \.self) { index in
                        let isActive = currentStep == index
                        
                        // Jedes Element bekommt eine feste Breite, damit nichts springt
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isActive ? Color(red: 0.2, green: 0.45, blue: 0.55) : Color.white)
                                    .frame(width: isActive ? 60 : 35, height: isActive ? 60 : 35)
                                    .shadow(color: .black.opacity(isActive ? 0.2 : 0), radius: 4)
                                
                                Circle()
                                    .stroke(isActive ? Color.clear : Color.gray.opacity(0.5), lineWidth: 1)
                                    .frame(width: isActive ? 60 : 35, height: isActive ? 60 : 35)
                                
                                Image(systemName: userOrder[index].icon)
                                    .font(.system(size: isActive ? 28 : 16))
                                    .foregroundColor(isActive ? .white : .gray.opacity(0.8))
                            }
                            .frame(width: 60, height: 60) // Fester Container für den Kreis
                            
                            // Der Text wird absolut positioniert, um das Layout nicht zu dehnen
                            if isActive {
                                Text(userOrder[index].name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55))
                                    .fixedSize() // Verhindert Zeilenumbruch
                                    .padding(.top, 4)
                            } else {
                                // Platzhalter, damit die Höhe gleich bleibt
                                Text("")
                                    .font(.system(size: 14))
                                    .frame(height: 20)
                            }
                        }
                        .frame(maxWidth: .infinity) // Verteilt die Icons gleichmäßig über die Breite
                        
                        // Die Verbindungslinie
                        if index != userOrder.count - 1 {
                            Rectangle()
                                .frame(width: 20, height: 1)
                                .foregroundColor(Color.gray.opacity(0.3))
                                .padding(.bottom, 28) // Zentriert die Linie vertikal zwischen den Kreisen
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // 2. HAUPT-CONTENT
                VStack(spacing: 30) {
                    Image("Cloud") // Dein Asset-Name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 150)
                        .padding(.bottom, 10)

                    VStack(spacing: 12) {
                        Text("Du bist sicher.")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .kerning(1.5) // Erhöht den Zeichenabstand für mehr Ästhetik
                            .foregroundColor(Color(red: 0.1, green: 0.25, blue: 0.35)) // Sanftes Dunkelblau statt hartem Schwarz
                        
                        Text("Atme tief durch und nimm dir Zeit.")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // 3. BUTTONS
                VStack(spacing: 20) {
                    Button(action: { showExercise = true }) {
                        Text("Weiter")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color(red: 0.2, green: 0.45, blue: 0.55))
                            .cornerRadius(30)
                    }
                    
                    Button(action: {
                        withAnimation { currentStep = 0 }
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Übung wiederholen")
                        }
                        .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55))
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
                BreathingExerciseView(isShowing: $isShowing, currentStep: $currentStep)
            case .memory:
                MemoryExerciseView(isShowing: $isShowing, currentStep: $currentStep)
            case .mantra:
                MantraPlaceholderView(isShowing: $isShowing, currentStep: $currentStep)
            }
        }
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
struct CheckpointView_Previews: PreviewProvider {
    static var previews: some View {
        CheckpointView(isShowing: .constant(true))
    }
}

