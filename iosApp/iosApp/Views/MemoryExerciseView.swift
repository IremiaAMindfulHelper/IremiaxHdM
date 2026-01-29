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
    var isStandalone: Bool = false
    
    @State private var showCheckpoint = false
    @State private var cards: [MemoryCard] = []
    @State private var firstSelectedIndex: Int?
    @State private var secondsRemaining = 60
    @State private var timerActive = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let emojis = ["🧠", "☀️", "🌿", "🧘", "💧", "☁️"]
    
    var matchedPairs: Int { cards.filter { $0.isMatched }.count / 2 }
    var totalPairs: Int { emojis.count }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 20) {
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                }
                
                GeometryReader { geo in
                    let progress = CGFloat(Double(matchedPairs) / Double(totalPairs))
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)).frame(height: 12)
                        RoundedRectangle(cornerRadius: 10).fill(petrolColor)
                            .frame(width: geo.size.width * progress, height: 12)
                    }
                }.frame(height: 12)
                
                Image(systemName: "phone.circle.fill").font(.system(size: 30))
                    .foregroundColor(Color.gray.opacity(0.2))
            }
            .padding(.horizontal).padding(.top, 20)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(timeString(from: secondsRemaining)).font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Min").font(.system(size: 16)).foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 25).padding(.top, 30)
            
            Spacer()
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(0..<cards.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(cards[index].isFaceUp || cards[index].isMatched ? Color.white : Color(red: 0.9, green: 0.93, blue: 0.94))
                        
                        if cards[index].isFaceUp || cards[index].isMatched {
                            Text(cards[index].content).font(.system(size: 35))
                        }
                    }
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(cards[index].isMatched ? petrolColor.opacity(0.5) : Color.clear, lineWidth: 2))
                    .onTapGesture { choose(index) }
                }
            }
            .padding(.horizontal, 25)
            
            Spacer()
            
            ExerciseFooter { goToNextStep() }
        }
        .background(Color.white.ignoresSafeArea())
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
    
    private func setupGame() {
        let gameContent = (emojis + emojis).shuffled()
        cards = gameContent.map { MemoryCard(content: $0) }
    }
    
    private func choose(_ index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched || firstSelectedIndex == index { return }
        
        if let chosenIndex = firstSelectedIndex {
            cards[index].isFaceUp = true
            if cards[index].content == cards[chosenIndex].content {
                cards[index].isMatched = true
                cards[chosenIndex].isMatched = true
                if matchedPairs == totalPairs {
                    timerActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { goToNextStep() }
                }
            }
            firstSelectedIndex = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    for i in cards.indices { if !cards[i].isMatched { cards[i].isFaceUp = false } }
                }
            }
        } else {
            cards[index].isFaceUp = true
            firstSelectedIndex = index
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
    
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
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
