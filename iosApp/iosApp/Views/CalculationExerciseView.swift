import SwiftUI

struct CalculationExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int

    @Environment(\.dismiss) var dismiss

    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let totalQuestions = 3

    // MARK: - Timing (bewusst langsam & verständlich)
    private let wrongFeedbackDelay: Double = 0.35
    private let correctFeedbackDelay: Double = 0.6
    private let eliminateAnimDuration: Double = 0.45

    // Quiz-State
    @State private var questionIndex: Int = 0

    @State private var a: Int = 0
    @State private var b: Int = 0
    @State private var op: Op = .plus
    @State private var correctAnswer: Int = 0

    @State private var answerOptions: [Int] = []
    @State private var fiftyFiftyActive: Bool = false
    @State private var eliminatedOptions: Set<Int> = []

    // Feedback / UI
    @State private var selectedAnswer: Int? = nil
    @State private var isLocked: Bool = false

    enum Op: CaseIterable {
        case plus, minus

        var symbol: String {
            self == .plus ? "+" : "−"
        }

        func compute(_ a: Int, _ b: Int) -> Int {
            self == .plus ? a + b : a - b
        }
    }

    var body: some View {
        VStack(spacing: 30) {

            // MARK: - Header
            HStack(spacing: 20) {
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                GeometryReader { geo in
                    let progress = CGFloat(questionIndex) / CGFloat(totalQuestions)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(petrolColor)
                            .frame(width: geo.size.width * progress, height: 12)
                    }
                }
                .frame(height: 12)

                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(petrolColor.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // MARK: - Aufgabe
            VStack(spacing: 10) {
                Text("\(a) \(op.symbol) \(b)")
                    .font(.system(size: 70, weight: .medium, design: .rounded))

                Text("\(questionIndex + 1) / \(totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 30)
            .padding(.bottom, 60)

            // MARK: - Antworten
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(answerOptions, id: \.self) { option in
                    Button {
                        handleTap(option)
                    } label: {
                        Text("\(option)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(textColor(for: option))
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(buttonColor(for: option))
                            .cornerRadius(20)
                            .opacity(buttonOpacity(for: option))
                    }
                    .disabled(isLocked || eliminatedOptions.contains(option))
                }
            }
            .padding(.horizontal, 25)

            Spacer()

            // MARK: - Überspringen
            Button(action: { goToNextStep() }) {
                HStack {
                    Text("Überspringen")
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            startNewQuestion()
        }
    }

    // MARK: - Styling
    private func buttonColor(for option: Int) -> Color {
        if eliminatedOptions.contains(option) {
            return Color.gray.opacity(0.25)
        }

        if let selected = selectedAnswer,
           selected == option,
           option == correctAnswer {
            return .green
        }

        if let selected = selectedAnswer,
           selected == option,
           option != correctAnswer {
            return .red.opacity(0.85)
        }

        return petrolColor
    }

    private func textColor(for option: Int) -> Color {
        eliminatedOptions.contains(option) ? .gray.opacity(0.7) : .white
    }

    private func buttonOpacity(for option: Int) -> Double {
        eliminatedOptions.contains(option) ? 0.4 : 1.0
    }

    // MARK: - Tap Logic
    private func handleTap(_ option: Int) {
        guard !isLocked else { return }
        guard !eliminatedOptions.contains(option) else { return }

        selectedAnswer = option

        if option == correctAnswer {
            isLocked = true

            DispatchQueue.main.asyncAfter(deadline: .now() + correctFeedbackDelay) {
                advanceAfterCorrect()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + wrongFeedbackDelay) {
                applyFiftyFiftyGrayOut(tappedWrong: option)
            }
        }
    }

    // MARK: - 50:50 (ausgrauen)
    private func applyFiftyFiftyGrayOut(tappedWrong: Int) {
        guard !fiftyFiftyActive else { return }
        fiftyFiftyActive = true

        let remainingWrongs = answerOptions.filter {
            $0 != correctAnswer && $0 != tappedWrong
        }
        let keptWrong = remainingWrongs.randomElement() ?? correctAnswer + 1

        let toEliminate = answerOptions.filter {
            $0 != correctAnswer && $0 != keptWrong
        }

        withAnimation(.easeInOut(duration: eliminateAnimDuration)) {
            eliminatedOptions = Set(toEliminate)
        }
    }

    // MARK: - Weiter
    private func advanceAfterCorrect() {
        if questionIndex < totalQuestions - 1 {
            questionIndex += 1
            startNewQuestion()
        } else {
            goToNextStep()
        }
    }

    // MARK: - Neue Frage
    private func startNewQuestion() {
        isLocked = false
        selectedAnswer = nil
        fiftyFiftyActive = false
        eliminatedOptions = []

        generateQuestion()
        answerOptions = makeOptions(correct: correctAnswer)
    }

    private func generateQuestion() {
        op = [.plus, .minus].randomElement() ?? .plus

        var aa = Int.random(in: 3...15)
        var bb = Int.random(in: 3...15)

        if op == .minus, bb > aa {
            swap(&aa, &bb)
        }

        a = aa
        b = bb
        correctAnswer = op.compute(a, b)
    }

    private func makeOptions(correct: Int) -> [Int] {
        var set: Set<Int> = [correct]

        while set.count < 4 {
            let delta = Int.random(in: -8...8)
            let candidate = correct + delta
            if candidate >= 0 && delta != 0 {
                set.insert(candidate)
            }
        }

        return Array(set).shuffled()
    }

    // MARK: - Navigation
    private func goToNextStep() {
        if currentStep < sosSteps.count - 1 {
            currentStep += 1
            dismiss()
        } else {
            isShowing = false
        }
    }
}

struct CalculationExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationExerciseView(isShowing: .constant(true), currentStep: .constant(0))
    }
}
