import SwiftUI
import Shared

/// Manages the state and logic for a calculation-based cognitive exercise.
/// Interfaces with the Kotlin `CalculationEngine` to retrieve randomized math problems.
class CalculationViewModel: ObservableObject {
    private let engine = CalculationEngine()

    @Published var questionIndex: Int = 0
    @Published var currentQuestion: QuestionData?
    @Published var selectedAnswer: Int? = nil
    @Published var isLocked: Bool = false
    @Published var eliminatedOptions: Set<Int> = []
    @Published var wrongFlashAnswer: Int? = nil
    @Published var showCheckpoint = false

    /// NOTE: Total questions are currently hardcoded for this exercise type.
    let totalQuestions = 3

    init() {
        startNewQuestion()
    }

    /// Resets the UI state and fetches a new mathematical problem from the Shared engine.
    func startNewQuestion() {
        isLocked = false
        selectedAnswer = nil
        wrongFlashAnswer = nil
        eliminatedOptions = []

        self.currentQuestion = engine.generateQuestion()
    }

    /// Validates the user's selection and manages the transition between questions.
    /// - Parameters:
    ///   - option: The integer value selected by the user.
    ///   - onComplete: Callback triggered when the final question is answered correctly.
    func processTap(_ option: Int, onComplete: @escaping () -> Void) {
        guard !isLocked, let question = currentQuestion else { return }

        if Int32(option) == question.correctAnswer {
            selectedAnswer = option
            isLocked = true
            
            // NOTE: Artificial delay provides visual confirmation of the correct answer before switching.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if self.questionIndex < self.totalQuestions - 1 {
                    self.questionIndex += 1
                    self.startNewQuestion()
                } else {
                    onComplete()
                }
            }
        } else {
            // NOTE: Visual feedback for incorrect answers.
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                wrongFlashAnswer = option
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    self.wrongFlashAnswer = nil
                    self.eliminatedOptions.insert(option)
                }
            }
        }
    }
}
