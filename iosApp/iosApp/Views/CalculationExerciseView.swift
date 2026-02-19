import SwiftUI
import Shared
struct CalculationExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    @StateObject private var viewModel = CalculationViewModel()
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)

    var body: some View {
        VStack(spacing: 30) {
            // Header... (identisch wie vorher)
            headerView
            
            if let question = viewModel.currentQuestion {
                // MARK: - QUESTION
                VStack(spacing: 10) {
                    Text("\(question.a) \(question.operation.symbol) \(question.b)")
                        .font(.system(size: 70, weight: .medium, design: .rounded))
                    Text("\(viewModel.questionIndex + 1) / \(viewModel.totalQuestions)")
                        .foregroundColor(.gray)
                }
                .padding(.top, 30).padding(.bottom, 60)

                // MARK: - ANSWERS
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

    // Hilfs-Views und Funktionen...
    private var headerView: some View {
        HStack(spacing: 20) {
            Button(action: { isShowing = false }) {
                Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
            }
            GeometryReader { geo in
                let progress = CGFloat(viewModel.questionIndex) / CGFloat(viewModel.totalQuestions)
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)).frame(height: 12)
                    RoundedRectangle(cornerRadius: 10).fill(petrolColor).frame(width: geo.size.width * progress, height: 12)
                }
            }.frame(height: 12)
            Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundColor(petrolColor.opacity(0.6))
        }.padding(.horizontal).padding(.top, 20)
    }

    private func buttonColor(for option: Int) -> Color {
        if viewModel.wrongFlashAnswer == option { return .red }
        if viewModel.eliminatedOptions.contains(option) { return Color.gray.opacity(0.3) }
        if viewModel.selectedAnswer == option { return .green }
        return petrolColor
    }

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
        // Wir brauchen @State Variablen für die Bindings
        CalculationExerciseView(
            isShowing: .constant(true),
            currentStep: .constant(1),
            isStandalone: true
        )
    }
}
