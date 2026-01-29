import SwiftUI

struct BreathingExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isIntroActive = true
    @State private var timeLeft = 180
    @State private var cloudOffset: CGFloat = 0
    @State private var showCheckpoint = false
    
   
    @State private var points = 0
    @State private var hasCountedInhale = false
    @State private var hasCountedExhale = false
    
    let totalTime = 180.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [petrolColor.opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // HEADER
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                    }
                    GeometryReader { geo in
                        let progress = CGFloat((totalTime - Double(timeLeft)) / totalTime)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)).frame(height: 8)
                            RoundedRectangle(cornerRadius: 10).fill(petrolColor).frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundColor(petrolColor.opacity(0.6))
                }
                .padding(.horizontal).padding(.top, 20)
                
                // TIMER & PUNKTE
                HStack(alignment: .lastTextBaseline) {
                    if !isIntroActive {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(timeString(time: timeLeft)).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(petrolColor)
                            Text("Min").font(.system(size: 16)).foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(points)").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(petrolColor).contentTransition(.numericText())
                        Text("Punkt\(points == 1 ? "" : "e")").font(.system(size: 16, weight: .medium)).foregroundColor(petrolColor)
                    }
                }
                .padding(.horizontal, 25).padding(.top, 25)
                
                Spacer()
                
                // CLOUD & TEXT
                ZStack {
                    if !isIntroActive {
                        Text("Einatmen").font(.system(size: 28, weight: .light, design: .rounded)).foregroundColor(petrolColor).offset(y: -240).opacity(cloudOffset < -30 ? 0 : 1)
                    }
                    
                    if isIntroActive {
                        Text("Bewege die Wolke passend zu deiner Atmung.").font(.system(size: 22, weight: .medium, design: .rounded)).multilineTextAlignment(.center).padding(.horizontal, 40).foregroundColor(petrolColor).offset(y: -140)
                    }
                    
                    Image("Cloud")
                        .resizable().scaledToFit()
                        .frame(width: 180, height: 180)
                        .scaleEffect(1.0 + (abs(cloudOffset) / 800))
                        .offset(y: cloudOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isIntroActive {
                                        let limit: CGFloat = 180
                                        self.cloudOffset = min(max(value.translation.height, -limit), limit)
                                        
                                        // EINATMEN (Nach oben ziehen)
                                        if cloudOffset < -100 && !hasCountedInhale {
                                            points += 1
                                            hasCountedInhale = true
                                            hasCountedExhale = false
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                        
                                        // AUSATMEN (Nach unten ziehen)
                                        if cloudOffset > 100 && !hasCountedExhale {
                                            points += 1
                                            hasCountedExhale = true
                                            hasCountedInhale = false
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    // Wir behalten die Sperre für die aktuelle Richtung bei,
                                    // setzen aber das Inhale/Exhale nicht zurück, damit man
                                    // beim nächsten Mal wieder von vorne starten muss.
                                    hasCountedInhale = false
                                    hasCountedExhale = false
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { self.cloudOffset = 0 }
                                }
                        )
                    
                    if !isIntroActive {
                        Text("Ausatmen").font(.system(size: 28, weight: .light, design: .rounded)).foregroundColor(petrolColor).offset(y: 240).opacity(cloudOffset > 30 ? 0 : 1)
                    }
                }
                
                Spacer()
                
                ExerciseFooter { goToNextStep() }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { isIntroActive = false }
            }
        }
        .onReceive(timer) { _ in
            if !isIntroActive && timeLeft > 0 {
                timeLeft -= 1
            } else if !isIntroActive && timeLeft == 0 {
                goToNextStep()
            }
        }
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    private func timeString(time: Int) -> String {
        String(format: "%d:%02d", time / 60, time % 60)
    }
    
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
            withAnimation(.spring()) { showCheckpoint = true }
        }
    }
}

struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView(isShowing: .constant(true), currentStep: .constant(1))
    }
}
