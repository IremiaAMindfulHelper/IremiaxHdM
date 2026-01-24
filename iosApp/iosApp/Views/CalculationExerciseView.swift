import SwiftUI

struct CalculationExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @Environment(\.dismiss) var dismiss

    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let totalQuestions = 3

    @State private var questionIndex: Int = 0
    @State private var a: Int = 0
    @State private var b: Int = 0
    @State private var op: Op = .plus
    @State private var correctAnswer: Int = 0
    @State private var answerOptions: [Int] = []
    @State private var selectedAnswer: Int? = nil
    @State private var isLocked: Bool = false
    @State private var eliminatedOptions: Set<Int> = []
    
    @State private var wrongFlashAnswer: Int? = nil
    
    @State private var showCheckpoint = false

    enum Op: CaseIterable {
        case plus, minus
        var symbol: String { self == .plus ? "+" : "−" }
        func compute(_ a: Int, _ b: Int) -> Int { self == .plus ? a + b : a - b }
    }

    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack(spacing: 20) {
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                }
                
                GeometryReader { geo in
                    let progress = CGFloat(questionIndex) / CGFloat(totalQuestions)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.15)).frame(height: 12)
                        RoundedRectangle(cornerRadius: 10).fill(petrolColor).frame(width: geo.size.width * progress, height: 12)
                    }
                }.frame(height: 12)

                Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundColor(petrolColor.opacity(0.6))
            }
            .padding(.horizontal).padding(.top, 20)

            VStack(spacing: 10) {
                Text("\(a) \(op.symbol) \(b)").font(.system(size: 70, weight: .medium, design: .rounded))
                Text("\(questionIndex + 1) / \(totalQuestions)").foregroundColor(.gray)
            }
            .padding(.top, 30).padding(.bottom, 60)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(answerOptions, id: \.self) { option in
                    Button { handleTap(option) } label: {
                        Text("\(option)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 140)
                            .background(buttonColor(for: option))
                            .cornerRadius(20)
                            // Sanfte Animation für den Farbumschlag zu Grau
                            .animation(.easeInOut(duration: 0.3), value: eliminatedOptions)
                    }
                    .disabled(isLocked || eliminatedOptions.contains(option))
                }
            }
            .padding(.horizontal, 25)

            Spacer()
            
            Button("Überspringen") { goToNextStep() }.foregroundColor(.gray).padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear { startNewQuestion() }
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }

    private func handleTap(_ option: Int) {
        guard !isLocked else { return }
        
        if option == correctAnswer {
            selectedAnswer = option
            isLocked = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if questionIndex < totalQuestions - 1 {
                    questionIndex += 1
                    startNewQuestion()
                } else {
                    goToNextStep()
                }
            }
        } else {
            // Falsche Antwort Logik
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                wrongFlashAnswer = option
            }
            
            // Nach 0.4 Sekunden: Rot-Leuchten beenden und in die "Eliminiert"-Liste schieben
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    wrongFlashAnswer = nil
                    eliminatedOptions.insert(option)
                }
            }
        }
    }

    private func buttonColor(for option: Int) -> Color {
        // 1. Wenn die Antwort gerade als falsch markiert wurde (Leuchten)
        if wrongFlashAnswer == option {
            return .red
        }
        
        // 2. Wenn die Antwort bereits eliminiert wurde (Grau)
        if eliminatedOptions.contains(option) {
            return Color.gray.opacity(0.3)
        }
        
        // 3. Wenn die richtige Antwort ausgewählt wurde (Grün)
        if selectedAnswer == option && option == correctAnswer {
            return .green
        }
        
        // Standardfarbe
        return petrolColor
    }

    private func startNewQuestion() {
        isLocked = false
        selectedAnswer = nil
        wrongFlashAnswer = nil
        eliminatedOptions = []
        op = Op.allCases.randomElement()!
        a = Int.random(in: 5...20)
        b = Int.random(in: 1...a)
        correctAnswer = op.compute(a, b)
        var options = Set([correctAnswer])
        while options.count < 4 { options.insert(correctAnswer + Int.random(in: -5...5)) }
        answerOptions = Array(options).shuffled()
    }

    private func goToNextStep() {
        
        withAnimation(.spring()) {
            showCheckpoint = true 
        }
    }
}
struct CalculationExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationExerciseView(isShowing: .constant(true), currentStep: .constant(0))
    }
}


