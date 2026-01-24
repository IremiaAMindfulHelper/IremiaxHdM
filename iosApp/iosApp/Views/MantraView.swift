import SwiftUI

struct MantraView: View {
    let mantra: Mantra
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    
    // Ermöglicht das Schließen des FullScreenCovers
    @Environment(\.dismiss) var dismiss
    
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
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
                
                Text("Atme tief ein und wiederhole diesen Satz für dich.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                
                // MARK: - KORRIGIERTER BUTTON
                Button {
                    // WICHTIG: Kein currentStep += 1 mehr!
                    // Wir schließen nur die View, um zum Checkpoint zurückzukehren.
                    dismiss()
                } label: {
                    Text("Fertig") // "Fertig" passt besser zum neuen Ablauf
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
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
        }
    }
}
