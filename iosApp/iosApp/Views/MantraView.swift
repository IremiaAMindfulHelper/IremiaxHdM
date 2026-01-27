import SwiftUI

struct MantraView: View {
    let mantra: Mantra
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @Environment(\.dismiss) var dismiss
    
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.9
    @State private var showCheckpoint = false // State für den Übergang zum Checkpoint
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [petrolColor.opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER (Einheitlich für alle Übungen)
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                    }
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)).frame(height: 8)
                        // Festgelegter Fortschritt für Mantras (z.B. 75% der Kette)
                        RoundedRectangle(cornerRadius: 10).fill(petrolColor).frame(width: 220, height: 8)
                    }
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - CONTENT
                VStack(spacing: 40) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 40))
                        .foregroundColor(petrolColor.opacity(0.3))
                    
                    VStack(spacing: 20) {
                        Text(mantra.titel)
                            .font(.system(size: 14, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(3)
                            .foregroundColor(.gray)
                        
                        Text(mantra.spruch)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .lineSpacing(8)
                            .opacity(opacity)
                            .scaleEffect(scale)
                    }
                    
                    Image(systemName: "quote.closing")
                        .font(.system(size: 40))
                        .foregroundColor(petrolColor.opacity(0.3))
                    
                    Text("Atme tief ein und wiederhole diesen Satz für dich.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
                
                // MARK: - ZENTRALER FOOTER (Überspringen-Logik)
                ExerciseFooter {
                    goToNextStep() // 
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
        }
        // Zeigt den Checkpoint nach Abschluss/Überspringen
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    func goToNextStep() {
        withAnimation(.spring()) {
            showCheckpoint = true
        }
    }
}

// MARK: - PREVIEW
struct MantraView_Previews: PreviewProvider {
    static var previews: some View {
        MantraView(
            mantra: WellnessData.mantras[0],
            isShowing: .constant(true),
            currentStep: .constant(2)
        )
    }
}
