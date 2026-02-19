import SwiftUI
import Shared // Importiert den Kotlin Code

class CalculationViewModel: ObservableObject {
    private let engine = CalculationEngine()

    @Published var questionIndex: Int = 0
    @Published var currentQuestion: QuestionData?
    @Published var selectedAnswer: Int? = nil
    @Published var isLocked: Bool = false
    @Published var eliminatedOptions: Set<Int> = []
    @Published var wrongFlashAnswer: Int? = nil
    @Published var showCheckpoint = false

    let totalQuestions = 3

    init() {
        startNewQuestion()
    }

    func startNewQuestion() {
        isLocked = false
        selectedAnswer = nil
        wrongFlashAnswer = nil
        eliminatedOptions = []

        // Holt die Logik aus der Kotlin Engine
        self.currentQuestion = engine.generateQuestion()
    }

    func processTap(_ option: Int, onComplete: @escaping () -> Void) {
        guard !isLocked, let question = currentQuestion else { return }

        if Int32(option) == question.correctAnswer {
            selectedAnswer = option
            isLocked = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if self.questionIndex < self.totalQuestions - 1 {
                    self.questionIndex += 1
                    self.startNewQuestion()
                } else {
                    onComplete()
                }
            }
        } else {
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
