import SwiftUI
import Shared

/**
 * A view that displays a daily mantra or affirmation.
 * Fetches data from the Shared Kotlin module and selects a random entry.
 */
struct MantraView: View {
    // MARK: - State & Properties
    @State private var mantra: WellnessMantra? = nil
    
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.9
    @State private var showCheckpoint = false
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ZStack {
            // MARK: - BACKGROUND
            LinearGradient(
                gradient: Gradient(colors: [petrolColor.opacity(0.1), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrolColor.opacity(0.6))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - MANTRA CONTENT
                if let mantra = mantra {
                    VStack(spacing: 40) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 40))
                            .foregroundColor(petrolColor.opacity(0.3))
                        
                        VStack(spacing: 20) {
                            // NOTE: 'titel' and 'spruch' are properties defined in the Kotlin WellnessMantra class
                            Text(mantra.titel)
                                .font(.system(size: 14, weight: .bold))
                                .textCase(.uppercase)
                                .tracking(3)
                                .foregroundColor(.gray)
                            
                            Text(mantra.spruch)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .opacity(opacity)
                                .scaleEffect(scale)
                        }
                        
                        Image(systemName: "quote.closing")
                            .font(.system(size: 40))
                            .foregroundColor(petrolColor.opacity(0.3))
                    }
                }
                
                Spacer()
                ExerciseFooter { goToNextStep() }
            }
        }
        .onAppear {
            // MARK: - INITIALIZATION
            // Select a random mantra from the shared repository if not already set
            if mantra == nil {
                mantra = WellnessRepository.shared.mantras.randomElement()
            }
            
            // NOTE: A slow ease-out animation matches the calm nature of the content
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
        }
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    /**
     * Handles the transition to the next step or dismisses the exercise.
     */
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
            showCheckpoint = true
        }
    }
}


