import SwiftUI

struct EmergencyPlanView: View {
    @Binding var isShowing: Bool
    
    @State private var stepIndex = 0
    @State private var phaseTime: Double = 4.0
    @State private var dragOffset = CGSize.zero
    @State private var startCalculation = false
    
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
                        Image(stepIndex == 1 ? "Wolkeein" : "Wolkeaus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180, height: 180)
                    }
                    .scaleEffect(calculateScale())
                    .frame(height: 200)
                    
                    // SCHRIFTART ANGEPASST: Wie HeaderView
                    Text(phases[stepIndex].title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(Int(phaseTime.rounded(.up)))")
                        .font(.system(size: 110, weight: .thin, design: .rounded))
                        .foregroundColor(.blue)
                }
                .onReceive(timer) { _ in
                    if phaseTime > 0.1 {
                        phaseTime -= 0.1
                    } else {
                        advanceBreathing()
                    }
                }
                
                Spacer()
                
                // MARK: - Abbrechen-Button
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
                            
                            // SCHRIFTART ANGEPASST: Wie FilterBar
                            Text("Zum\nAbbrechen\nWischen")
                                .font(.system(size: 16, weight: .medium))
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
    }
    
    func advanceBreathing() {
        if stepIndex < phases.count - 1 {
            stepIndex += 1
            phaseTime = phases[stepIndex].duration
        } else {
            startCalculation = true
        }
    }
    
    func calculateScale() -> CGFloat {
        let minScale: CGFloat = 0.6
        let maxScale: CGFloat = 1.3
        let duration: Double = 4.0
        let progress = (duration - phaseTime) / duration
        
        switch stepIndex {
        case 0:
            return minScale + (maxScale - minScale) * CGFloat(progress)
        case 1:
            return maxScale
        case 2:
            return maxScale - (maxScale - minScale) * CGFloat(progress)
        default:
            return minScale
        }
    }
}
struct EmergencyPlan_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyPlanView(isShowing: .constant(true))
    }
}
