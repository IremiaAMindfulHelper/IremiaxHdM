import SwiftUI

struct EmergencyPlanView: View {
    @Binding var isShowing: Bool
    
    @State private var stepIndex = 0
    @State private var phaseTime: Double = 4.0
    @State private var startFirstExercise = false
    @State private var sliderOffset: CGFloat = 0
    @State private var internalStep: Int = 0
    
    private let sliderWidth: CGFloat = 300
    private let handleSize: CGFloat = 54
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    let previewIcons = ["plus.forwardslash.minus", "wind", "leaf", "brain"]
    
    let phases = [
        (title: "Atme ein", duration: 1.0),
        (title: "Halte", duration: 1.0),
        (title: "Atme aus", duration: 1.0)
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Obere Symbol-Kette (Vorschau)
                HStack(spacing: 0) {
                    ForEach(0..<previewIcons.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 45, height: 45)
                                Image(systemName: previewIcons[index])
                                    .font(.system(size: 18))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            Text("").frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        
                        if index != previewIcons.count - 1 {
                            Rectangle()
                                .frame(width: 20, height: 1)
                                .foregroundColor(Color.gray.opacity(0.2))
                                .padding(.bottom, 24)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // Atem-Bereich
                VStack(spacing: 20) {
                    Image(stepIndex == 1 ? "Wolkeein" : "Wolkeaus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .scaleEffect(calculateScale())
                        .frame(height: 200)
                    
                    Text(phases[stepIndex].title)
                        .font(.system(size: 34, weight: .bold))
                    
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
                
              
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(petrolColor)
                        .frame(width: sliderWidth, height: 64)
                    
                    Text("Abbrechen")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: sliderWidth)
                    
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 56, height: 56)
                        Image(systemName: "xmark")
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
                                    isShowing = false
                                } else {
                                    withAnimation { sliderOffset = 0 }
                                }
                            }
                    )
                }
                .padding(.bottom, 60)
            }
        }
        // DIREKTER SPRUNG ZUR ALLERERSTEN ÜBUNG (Index 0)
        .fullScreenCover(isPresented: $startFirstExercise) {
                    CalculationExerciseView(isShowing: $isShowing, currentStep: $internalStep)
                }
                
    }
    
    func advanceBreathing() {
        if stepIndex < phases.count - 1 {
            stepIndex += 1
            phaseTime = phases[stepIndex].duration
        } else {
            startFirstExercise = true
        }
    }
    
    func calculateScale() -> CGFloat {
        let minScale: CGFloat = 0.8
        let maxScale: CGFloat = 1.2
        let progress = (4.0 - phaseTime) / 4.0
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
