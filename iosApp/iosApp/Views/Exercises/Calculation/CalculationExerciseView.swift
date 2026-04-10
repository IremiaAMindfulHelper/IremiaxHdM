import SwiftUI
import Shared

/// A view that presents a series of mathematical questions to the user.
struct CalculationExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    
    @StateObject private var viewModel = CalculationViewModel()
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)

    var body: some View {
        VStack(spacing: 30) {
            headerView
            
            if let question = viewModel.currentQuestion {
                // MARK: - QUESTION DISPLAY
                VStack(spacing: 10) {
                    Text("\(question.a) \(question.operation.symbol) \(question.b)")
                        .font(.system(size: 70, weight: .medium, design: .rounded))
                    
                    Text("\(viewModel.questionIndex + 1) / \(viewModel.totalQuestions)")
                        .foregroundColor(.gray)
                }
                .padding(.top, 30).padding(.bottom, 60)

                // MARK: - ANSWER GRID
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(question.answerOptions, id: \.self) { option in
                        let optInt = Int(truncating: option)
                        Button {
                            viewModel.processTap(optInt, onComplete: goToNextStep)
                        } label: {
                            Text("\(optInt)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).frame(height: 140)
                                .background(buttonColor(for: optInt))
                                .cornerRadius(20)
                        }
                        // NOTE: Interaction is disabled during transitions or for already failed options.
                        .disabled(viewModel.isLocked || viewModel.eliminatedOptions.contains(optInt))
                    }
                }
                .padding(.horizontal, 25)
            }

            Spacer()
            ExerciseFooter { goToNextStep() }
        }
        .background(Color.white.ignoresSafeArea())
        .fullScreenCover(isPresented: $viewModel.showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }

    /// Renders the top navigation bar with a progress indicator.
    private var headerView: some View {
        HStack(spacing: 20) {
            Button(action: { isShowing = false }) {
                Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
            }
            
            GeometryReader { geo in
                // NOTE: Local progress calculation ensures the bar animates smoothly regardless of engine speed.
                let progress = CGFloat(viewModel.questionIndex) / CGFloat(viewModel.totalQuestions)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)).frame(height: 12)
                    RoundedRectangle(cornerRadius: 10).fill(petrolColor).frame(width: geo.size.width * progress, height: 12)
                }
            }.frame(height: 12)
            
            Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundColor(petrolColor.opacity(0.6))
        }.padding(.horizontal).padding(.top, 20)
    }

    /// Determines the button color based on the current interaction state.
    /// - Parameter option: The answer value associated with the button.
    /// - Returns: A Color representing the state (Error, Success, Inactive, or Default).
    private func buttonColor(for option: Int) -> SwiftUI.Color {
        if viewModel.wrongFlashAnswer == option { return .red }
        if viewModel.eliminatedOptions.contains(option) { return Color.gray.opacity(0.3) }
        if viewModel.selectedAnswer == option { return .green }
        return petrolColor
    }

    /// Handles transition logic to the next exercise phase or closes the view.
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
            withAnimation(.spring()) { viewModel.showCheckpoint = true }
        }
    }
}
struct CalculationExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationExerciseView(
            isShowing: .constant(true),
            currentStep: .constant(1),
            isStandalone: true
        )
    }
}
