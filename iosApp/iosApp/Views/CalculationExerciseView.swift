import SwiftUI

struct CalculationExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int // Verbindung zum Fortschritt im Checkpoint
    
    // Ermöglicht das Schließen dieses Screens, um zum Checkpoint zurückzukehren
    @Environment(\.dismiss) var dismiss
    
    let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        VStack(spacing: 30) {
            
            // MARK: - Header mit Progressbar
            HStack(spacing: 20) {
                // X-Button: Beendet die gesamte SOS-Sitzung
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // Fortschrittsbalken innerhalb der aktuellen Übung
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(petrolColor)
                        .frame(width: 120, height: 12) // Fortschritt-Breite
                }
                
                // Telefon-Icon (Notruf-Platzhalter)
                Button(action: { /* Notruf-Logik */ }) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // MARK: - Aufgabenstellung
            VStack(spacing: 10) {

                Text("5+10")
                    .font(.system(size: 70, weight: .medium, design: .rounded))
            }
            .padding(.top, 30)
            .padding(.bottom, 80)
            
            // MARK: - Antwort-Raster (Grid)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(["17", "25", "15", "11"], id: \.self) { answer in
                    Button(action: {
                        if answer == "15" {
                            goToNextStep()
                        }
                    }) {
                        Text(answer)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(petrolColor)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 25)
            
            Spacer()
            
            // MARK: - Footer (Überspringen)
            Button(action: {
                goToNextStep()
            }) {
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
    
    // MARK: - Navigations-Logik
    func goToNextStep() {
        // Prüfen, ob noch weitere Übungen in der Liste sind
        if currentStep < sosSteps.count - 1 {
            // Index erhöhen: Checkpoint bemerkt das und zeigt das nächste Icon groß an
            withAnimation(.spring()) {
                currentStep += 1
            }
            // Diesen Screen schließen -> Checkpoint wird wieder sichtbar
            dismiss()
        } else {
            // Letzte Übung beendet -> Gesamtes Overlay schließen
            isShowing = false
        }
    }
}

// Preview für die Entwicklung
struct CalculationExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationExerciseView(isShowing: .constant(true), currentStep: .constant(0))
    }
}
