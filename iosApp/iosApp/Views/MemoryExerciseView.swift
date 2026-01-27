import SwiftUI


struct MemoryCard: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp = false
    var isMatched = false
}


struct MemoryExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    @Environment(\.dismiss) var dismiss
    
    @State private var showCheckpoint = false
    @State private var cards: [MemoryCard] = []
    @State private var firstSelectedIndex: Int?
    
    // Timer & Progress States
    @State private var secondsRemaining = 60
    @State private var timerActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let emojis = ["🧠", "☀️", "🌿", "🧘", "💧", "☁️"] // 6 Paare = 12 Karten
    
    var matchedPairs: Int {
        cards.filter { $0.isMatched }.count / 2
    }
    
    var totalPairs: Int {
        emojis.count
    }
    
    var allMatched: Bool {
        matchedPairs == totalPairs && !cards.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - HEADER
                HStack(spacing: 20) {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)).frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(petrolColor)
                                .frame(width: geo.size.width * CGFloat(Double(matchedPairs) / Double(totalPairs)), height: 12)
                                .animation(.spring(), value: matchedPairs)
                        }
                    }
                    .frame(height: 12)
                    
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray.opacity(0.2))
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // MARK: - TIME DISPLAY
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(timeString(from: secondsRemaining))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Min")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 30)
                
                Spacer()
                
                // MARK: - GRID
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        let card = cards[index]
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card.isFaceUp || card.isMatched ? Color.white : Color(red: 0.9, green: 0.93, blue: 0.94))
                            
                            if card.isFaceUp || card.isMatched {
                                Text(card.content)
                                    .font(.system(size: 35))
                            }
                        }
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(card.isMatched ? petrolColor.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            choose(index)
                        }
                    }
                }
                .padding(.horizontal, 25)
                
                Spacer()
                
                Text("Decke die Memory-Karten auf und finde alle Paare.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                ExerciseFooter {
                    goToNextStep()
                }
            }
        }
        .onAppear { setupGame() }
        .onReceive(timer) { _ in
            if timerActive && secondsRemaining > 0 {
                secondsRemaining -= 1
            } else if secondsRemaining == 0 {
                timerActive = false
                goToNextStep()
            }
        }
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    // MARK: - LOGIK
    private func setupGame() {
        let gameContent = (emojis + emojis).shuffled()
        cards = gameContent.map { MemoryCard(content: $0) }
    }
    
    private func choose(_ index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched || firstSelectedIndex == index { return }
        
        if let chosenIndex = firstSelectedIndex {
            withAnimation(.spring(response: 0.3)) {
                cards[index].isFaceUp = true
            }
            
            if cards[index].content == cards[chosenIndex].content {
                cards[index].isMatched = true
                cards[chosenIndex].isMatched = true
                if allMatched {
                    timerActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { goToNextStep() }
                }
            }
            firstSelectedIndex = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    for i in cards.indices {
                        if !cards[i].isMatched { cards[i].isFaceUp = false }
                    }
                }
            }
        } else {
            for i in cards.indices { if !cards[i].isMatched { cards[i].isFaceUp = false } }
            cards[index].isFaceUp = true
            firstSelectedIndex = index
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    func goToNextStep() {
        withAnimation(.spring()) {
            showCheckpoint = true
        }
    }
}
// d
struct MemoryExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryExerciseView(isShowing: .constant(true), currentStep: .constant(3))
    }
}
