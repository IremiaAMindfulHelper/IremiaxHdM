import SwiftUI

struct BreathingExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @Environment(\.dismiss) var dismiss
    
    @State private var isIntroActive = true
    @State private var timeLeft = 180
    @State private var cloudOffset: CGFloat = 0
    @State private var showCheckpoint = false
    
    let totalTime = 180.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            // Hintergrund-Verlauf
            LinearGradient(
                gradient: Gradient(colors: [petrolColor.opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(petrolColor)
                                .frame(width: geo.size.width * CGFloat((totalTime - Double(timeLeft)) / totalTime), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Timer Anzeige
                if !isIntroActive {
                    Text(timeString(time: timeLeft))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    Text("").font(.system(size: 16)).padding(.top, 20)
                }
                
                Spacer()
                
                // MARK: - ZENTRALER BEREICH
                ZStack {
                    if !isIntroActive {
                        Text("Einatmen")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(petrolColor)
                            .offset(y: -240)
                            .opacity(cloudOffset < -50 ? 0 : 1)
                            .animation(.easeInOut, value: cloudOffset)
                    }
                    
                    if isIntroActive {
                        Text("Bewege die Wolke 3 Minuten lang passend zu deiner Atmung.")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .foregroundColor(petrolColor)
                            .offset(y: -140)
                            .transition(.opacity)
                    }
                    
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .scaleEffect(1.0 + (abs(cloudOffset) / 700))
                        .offset(y: cloudOffset)
                        .zIndex(1)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isIntroActive {
                                        let limit: CGFloat = 180
                                        self.cloudOffset = min(max(value.translation.height, -limit), limit)
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        self.cloudOffset = 0
                                    }
                                }
                        )
                    
                    if !isIntroActive {
                        Text("Ausatmen")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(petrolColor)
                            .offset(y: 240)
                            .opacity(cloudOffset > 50 ? 0 : 1)
                            .animation(.easeInOut, value: cloudOffset)
                    }
                }
                
                Spacer()
                
                // MARK: - ZENTRALER FOOTER
                ExerciseFooter {
                    goToNextStep()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isIntroActive = false
                }
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
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d Min", minutes, seconds)
    }
    
    func goToNextStep() {
        withAnimation(.spring()) {
            showCheckpoint = true
        }
    }
}

struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView(isShowing: .constant(true), currentStep: .constant(1))
    }
}
