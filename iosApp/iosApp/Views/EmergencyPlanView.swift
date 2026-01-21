import SwiftUI

struct EmergencyPlanView: View {
    @Binding var isShowing: Bool
    
    // MARK: - States
    @State private var stepIndex = 0
    @State private var phaseTime: Double = 4.0
    @State private var startCalculation = false // Steuert den Übergang zur nächsten Übung
    
    // States für den Petrol iOS Slider
    @State private var sliderOffset: CGFloat = 0
    private let sliderWidth: CGFloat = 300
    private let handleSize: CGFloat = 54
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let previewIcons = ["wind", "plus.forwardslash.minus", "leaf", "brain"]
    
    let phases = [
        (title: "Atme ein", duration: 4.0),
        (title: "Halte", duration: 4.0),
        (title: "Atme aus", duration: 4.0)
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - Obere Symbol-Kette
                HStack(spacing: 0) {
                    ForEach(0..<previewIcons.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 45, height: 45)
                                Circle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    .frame(width: 45, height: 45)
                                Image(systemName: previewIcons[index])
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray.opacity(0.8))
                            }
                            .frame(width: 45, height: 45)
                            Text("").frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        
                        if index != previewIcons.count - 1 {
                            Rectangle()
                                .frame(width: 20, height: 1)
                                .foregroundColor(Color.gray.opacity(0.3))
                                .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // MARK: - Atem-Bereich
                VStack(spacing: 20) {
                    ZStack {
                        // Wolken-Logik
                        Image(stepIndex == 1 ? "Wolkeein" : "Wolkeaus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180, height: 180)
                    }
                    .scaleEffect(calculateScale())
                    .frame(height: 200)
                    
                    Text(phases[stepIndex].title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(Int(phaseTime.rounded(.up)))")
                        .font(.system(size: 110, weight: .thin, design: .rounded))
                        .foregroundColor(petrolColor)
                }
                .onReceive(timer) { _ in
                    if phaseTime > 0.1 {
                        phaseTime -= 0.1
                    } else {
                        advanceBreathing()
                    }
                }
                
                Spacer()
                
                // MARK: - Slide to Cancel (Vollflächig Petrol)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(petrolColor)
                        .frame(width: sliderWidth, height: 64)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    
                    Text("Abbrechen")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: sliderWidth)
                        .offset(x: 20)
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(petrolColor)
                    }
                    .padding(.leading, 4)
                    .offset(x: sliderOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.width > 0 && sliderOffset <= (sliderWidth - handleSize - 8) {
                                    sliderOffset = gesture.translation.width
                                }
                            }
                            .onEnded { _ in
                                if sliderOffset > (sliderWidth * 0.75) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        sliderOffset = sliderWidth - handleSize - 8
                                        isShowing = false
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        sliderOffset = 0
                                    }
                                }
                            }
                    )
                }
                .padding(.bottom, 60)
            }
        }
        // Übergang zur nächsten Übung (CheckpointView)
        .fullScreenCover(isPresented: $startCalculation) {
            CheckpointView(isShowing: $isShowing)
        }
    }
    
    // MARK: - Logik Funktionen
    func advanceBreathing() {
        if stepIndex < phases.count - 1 {
            stepIndex += 1
            phaseTime = phases[stepIndex].duration
        } else {
            // Nach der letzten Phase (Ausatmen) zur nächsten Übung wechseln
            withAnimation(.easeInOut) {
                startCalculation = true
            }
        }
    }
    
    func calculateScale() -> CGFloat {
        let minScale: CGFloat = 0.6
        let maxScale: CGFloat = 1.3
        let duration: Double = 4.0
        let progress = (duration - phaseTime) / duration
        
        switch stepIndex {
        case 0: return minScale + (maxScale - minScale) * CGFloat(progress)
        case 1: return maxScale
        case 2: return maxScale - (maxScale - minScale) * CGFloat(progress)
        default: return minScale
        }
    }
}

// Preview
struct EmergencyPlan_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyPlanView(isShowing: .constant(true))
    }
}
