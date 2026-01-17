import SwiftUI

struct EmergencyPlanView: View {
    @Binding var isShowing: Bool
    
    // Atem-Logik States
    @State private var stepIndex = 0
    @State private var phaseTime = 4
    @State private var dragOffset = CGSize.zero
    @State private var startCalculation = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Die Icons für die statische Vorschau oben
    let previewIcons = ["wind", "plus.forwardslash.minus", "leaf", "brain"]
    
    // Atemphasen Definition
    let phases = [
        (title: "Atme ein", duration: 4, emoji: "😮‍💨"),
        (title: "Halten", duration: 4, emoji: "😌"),
        (title: "Atme aus", duration: 4, emoji: "🌬️")
    ]

    var body: some View {
        ZStack {
            // 1. Einfacher weißer Hintergrund
            Color.white.ignoresSafeArea()
            
            // Den GeometryReader mit der Canvas-Komponente haben wir entfernt,
            // um das Punkt-Raster zu löschen.

            VStack(spacing: 30) {
                // Obere Symbol-Kette (Statisch)
                HStack(spacing: 0) {
                    ForEach(previewIcons, id: \.self) { icon in
                        Circle()
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                            .frame(width: 45, height: 45)
                            .overlay(Image(systemName: icon).font(.system(size: 18)))
                        
                        if icon != previewIcons.last {
                            Rectangle()
                                .frame(width: 20, height: 1)
                                .foregroundColor(.black.opacity(0.4))
                        }
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Atemübung Anzeige
                VStack(spacing: 20) {
                    Text(phases[stepIndex].emoji)
                        .font(.system(size: 110))
                        .id(stepIndex)
                        .transition(.scale.combined(with: .opacity))
                    
                    Text(phases[stepIndex].title)
                        .font(.custom("Marker Felt", size: 32))
                        .foregroundColor(.black)
                    
                    Text("\(phaseTime)")
                        .font(.system(size: 110, weight: .thin, design: .rounded))
                        .foregroundColor(.blue)
                }
                .onReceive(timer) { _ in
                    if phaseTime > 1 {
                        phaseTime -= 1
                    } else {
                        advanceBreathing()
                    }
                }

                Spacer()
                
                // Abbrechen-Button
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 160, height: 160)
                        
                        VStack(spacing: 5) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .background(Circle().fill(.white))
                                .offset(dragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            let x = max(0, gesture.translation.width)
                                            let y = min(0, gesture.translation.height)
                                            dragOffset = CGSize(width: x, height: y)
                                        }
                                        .onEnded { gesture in
                                            if gesture.translation.width > 80 || gesture.translation.height < -80 {
                                                isShowing = false
                                            } else {
                                                withAnimation(.spring()) { dragOffset = .zero }
                                            }
                                        }
                                )
                            Text("Zum\nAbbrechen\nWischen")
                                .font(.custom("Marker Felt", size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.leading, 30)
                    .padding(.bottom, 50)
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $startCalculation) {
            CheckpointView(isShowing: $isShowing)
        }
    }
    
    // Logik für den automatischen Übergang nach der Atmung
    func advanceBreathing() {
        if stepIndex < phases.count - 1 {
            stepIndex += 1
            phaseTime = phases[stepIndex].duration
        } else {
            // Wenn Atemübung beendet, starte Rechenaufgabe
            withAnimation(.easeInOut) {
                startCalculation = true
            }
        }
    }
}
struct EmergencyPlan_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyPlanView(isShowing: .constant(true))
    }
}
