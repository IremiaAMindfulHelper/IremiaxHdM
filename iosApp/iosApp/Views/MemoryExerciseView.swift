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
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    private let emojis = ["🧠", "☀️", "🌿", "💧", "🧘", "☁️"]
    
    @State private var cards: [MemoryCard] = []
    @State private var firstSelectedIndex: Int?
    
    var allMatched: Bool {
        cards.allSatisfy { $0.isMatched } && !cards.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Memory Übung")
                .font(.system(.largeTitle, design: .rounded)).bold()
            
            Text(allMatched ? "Super gemacht!" : "Finde alle Paare, um dich zu fokussieren.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(0..<cards.count, id: \.self) { index in
                    ZStack {
                        let card = cards[index]
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(card.isFaceUp || card.isMatched ? Color.white : petrolColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(petrolColor.opacity(0.3), lineWidth: 2)
                            )
                        
                        if card.isFaceUp || card.isMatched {
                            Text(card.content)
                                .font(.system(size: 40))
                        }
                    }
                    .frame(height: 100)
                    .onTapGesture {
                        choose(index)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            if allMatched {
                ExerciseFooter {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(petrolColor)
                .cornerRadius(15)
                .padding(.horizontal, 40)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .onAppear { setupGame() }
    }
    
    private func setupGame() {
        let gameContent = (emojis + emojis).shuffled()
        cards = gameContent.map { MemoryCard(content: $0) }
    }
    
    private func choose(_ index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched { return }
        
        if let chosenIndex = firstSelectedIndex {
            cards[index].isFaceUp = true
            
            if cards[index].content == cards[chosenIndex].content {
                cards[index].isMatched = true
                cards[chosenIndex].isMatched = true
            }
            
            firstSelectedIndex = nil
            
            // Nach kurzer Zeit Karten wieder umdrehen, falls kein Match
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                for i in cards.indices {
                    if !cards[i].isMatched { cards[i].isFaceUp = false }
                }
            }
        } else {
            for i in cards.indices { cards[i].isFaceUp = false }
            cards[index].isFaceUp = true
            firstSelectedIndex = index
        }
    }
}
