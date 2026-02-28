import SwiftUI
import Shared

/// An interactive view that guides the user through a breathing exercise.
/// The exercise is controlled by dragging a cloud in sync with the breathing rhythm.
struct BreathingExerciseView: View {
    // MARK: - Bindings & Properties
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    @StateObject private var viewModel = BreathingViewModel()
    @State private var cloudOffset: CGFloat = 0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let totalTime = 180.0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - HEADER
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    GeometryReader { geo in
                        // NOTE: Progress is calculated locally to ensure smooth UI transitions.
                        let progress = CGFloat((totalTime - Double(viewModel.timeLeft)) / totalTime)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 10)
                                .fill(petrolColor)
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // MARK: - TIMER & POINTS
                HStack(alignment: .lastTextBaseline) {
                    if !viewModel.isIntroActive {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(viewModel.timeString())
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(petrolColor)
                            Text("Min")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(viewModel.points)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(petrolColor)
                            .contentTransition(.numericText())
                        Text("Punkt\(viewModel.points == 1 ? "" : "e")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(petrolColor)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                Spacer()
                
                // MARK: - INTERACTION AREA
                ZStack {
                    if !viewModel.isIntroActive {
                        Text("Einatmen")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(petrolColor)
                            .offset(y: -240)
                            // NOTE: Fade out text when the cloud enters the text area to prevent overlap.
                            .opacity(cloudOffset < -30 ? 0 : 1)
                    }
                    
                    if viewModel.isIntroActive {
                        Text("Bewege die Wolke passend zu deiner Atmung.")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .foregroundColor(petrolColor)
                            .offset(y: -140)
                    }
                    
                    Image("Cloud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        // OPTIMIZE: Consider moving scaleEffect to a drawingGroup if performance drops during heavy animations.
                        .scaleEffect(1.0 + (abs(cloudOffset) / 800))
                        .offset(y: cloudOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !viewModel.isIntroActive {
                                        let limit: CGFloat = 180
                                        self.cloudOffset = min(max(value.translation.height, -limit), limit)
                                        viewModel.processMovement(offset: cloudOffset)
                                    }
                                }
                                .onEnded { _ in
                                    viewModel.resetGesture()
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        self.cloudOffset = 0
                                    }
                                }
                        )
                    
                    if !viewModel.isIntroActive {
                        Text("Ausatmen")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(petrolColor)
                            .offset(y: 240)
                            .opacity(cloudOffset > 30 ? 0 : 1)
                    }
                }
                
                Spacer()
                
                ExerciseFooter { goToNextStep() }
            }
        }
        .onAppear {
            // TODO: Control intro duration dynamically via Shared logic instead of hardcoded 3 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    viewModel.endIntro()
                }
            }
        }
        .onReceive(timer) { _ in
            viewModel.tick()
        }
        .fullScreenCover(isPresented: $viewModel.showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    /// Navigates to the next step or closes the view if in standalone mode.
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
            withAnimation(.spring()) {
                viewModel.showCheckpoint = true
            }
        }
    }
}
// MARK: - Preview
struct BreathingExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        BreathingExerciseView(
            isShowing: .constant(true),
            currentStep: .constant(1),
            isStandalone: true
        )
    }
}
