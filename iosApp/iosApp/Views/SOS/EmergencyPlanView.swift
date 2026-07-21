import SwiftUI
import shared

/// The entry point for the SOS workflow.
/// Guides the user through an initial breathing exercise and features a high-intent cancel slider.
struct EmergencyPlanView: View {
    @Binding var isShowing: Bool
    
    @StateObject private var viewModel = EmergencyPlanViewModel()
    @State private var sliderOffset: CGFloat = 0
    
    /// Internal step tracker for the subsequent exercise flow.
    @State private var internalStep: Int = 0
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    /// Timer for smooth breathing animations.
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - PROGRESS BAR
                HStack(spacing: 0) {
                    ForEach(0..<viewModel.sosSteps.count, id: \.self) { index in
                        let step = viewModel.sosSteps[index]
                        
                        // NOTE: Icons are displayed in a neutral state as this is the lead-in phase.
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: step.icon)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if index != viewModel.sosSteps.count - 1 {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 25, height: 2)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 60)
                
                // MARK: - BREATHING ANIMATION
                VStack(spacing: 20) {
                    // NOTE: 'getImageNameSuffix' determines if the 'Inhale' or 'Exhale' asset is shown.
                    Image("Wolke\(viewModel.engine.getImageNameSuffix())")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .scaleEffect(CGFloat(viewModel.engine.getScaleFactor()))
                        .frame(height: 200)
                    
                    Text(viewModel.engine.getCurrentPhase().title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    
                    Text("\(Int(viewModel.engine.currentPhaseTime.rounded(.up)))")
                        .font(.system(size: 110, weight: .thin, design: .rounded))
                        .foregroundColor(petrolColor)
                }
                .onReceive(timer) { _ in
                    viewModel.tick()
                }
                
                Spacer()
                
                // MARK: - CANCEL SLIDER
                cancelSlider
                    .padding(.bottom, 60)
            }
        }
        .fullScreenCover(isPresented: $viewModel.startFirstExercise) {
            // NOTE: Transitioning directly to the calculation phase after intro breathing.
            CalculationExerciseView(isShowing: $isShowing, currentStep: $internalStep, isStandalone: false)
        }
    }
    
    /// A slider component that requires a full horizontal swipe to dismiss the view.
    /// This prevents accidental exits during high-stress situations.
    private var cancelSlider: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(petrolColor)
                .frame(width: 300, height: 64)
            
            Text("Abbrechen")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 300)
            
            ZStack {
                Circle().fill(.white).frame(width: 56, height: 56)
                Image(systemName: "xmark").foregroundColor(petrolColor)
            }
            .padding(.leading, 4)
            .offset(x: sliderOffset)
            .gesture(
                DragGesture().onChanged { g in
                    if g.translation.width > 0 && sliderOffset <= 238 {
                        sliderOffset = g.translation.width
                    }
                }.onEnded { _ in
                    if sliderOffset > 200 {
                        isShowing = false
                    } else {
                        withAnimation { sliderOffset = 0 }
                    }
                }
            )
        }
    }
}
// Preview
struct EmergencyPlan_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyPlanView(isShowing: .constant(true))
    }
}
