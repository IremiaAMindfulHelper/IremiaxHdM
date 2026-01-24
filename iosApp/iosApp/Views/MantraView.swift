import SwiftUI

struct MantraView: View {
    let mantra: Mantra
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    
    // Animation States
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        ZStack {
            // Hintergrund mit sanftem Verlauf
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Dekoratives Element oben
                Image(systemName: "quote.opening")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.3))
                
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
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.3))
                
                Spacer()
                
                // Fortschritts-Anweisung
                Text("Atme tief ein und wiederhole diesen Satz für dich.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                
                // Button zum nächsten Schritt
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        // Prüfen ob es weitere Schritte im SOS Plan gibt
                        // sosSteps.count muss in deinem Scope erreichbar sein
                        // Falls du außerhalb der SOS-Logik bist, einfach isShowing = false
                        if currentStep < 3 { // Beispiel-Limit
                            currentStep += 1
                        } else {
                            isShowing = false
                        }
                    }
                } label: {
                    Text("Ich bin bereit für den nächsten Schritt")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.45, blue: 0.55))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding(.top, 60)
        }
        .onAppear {
            // Sanfte Einblende-Animation beim Erscheinen
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}
