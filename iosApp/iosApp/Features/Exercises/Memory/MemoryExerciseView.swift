import SwiftUI
import Shared

// MARK: - MAIN VIEW
struct MemoryExerciseView: View {
    @Binding var isShowing: Bool
    @Binding var currentStep: Int
    var isStandalone: Bool = false
    
    @StateObject private var viewModel = MemoryViewModel()
    @State private var showCheckpoint = false
    
    private let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - HEADER
            HStack(spacing: 20) {
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark").font(.title2).foregroundColor(.gray)
                }
                
                GeometryReader { geo in
                    let progress = CGFloat(Double(viewModel.engine.getMatchedPairsCount()) / Double(viewModel.engine.getTotalPairsCount()))
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
            
            // TIMER
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(viewModel.timeString()).font(.system(size: 24, weight: .bold, design: .rounded))
                Text("Min").font(.system(size: 16)).foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 25).padding(.top, 30)
            
            Spacer()
            
            // MARK: - GRID (Altes Design)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(0..<viewModel.cards.count, id: \.self) { index in
                    let card = viewModel.cards[index]
                    
                    ZStack {
                        // Die Karten-Fläche
                        RoundedRectangle(cornerRadius: 12)
                            .fill(card.isFaceUp || card.isMatched ? Color.white : Color(red: 0.9, green: 0.93, blue: 0.94))
                        
                        // Der Inhalt (nur wenn aufgedeckt oder gematcht)
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
                        viewModel.selectCard(at: index)
                    }
                }
            }
            .padding(.horizontal, 25)
            
            Spacer()
            
            // Footer
            ExerciseFooter { goToNextStep() }
        }
        .background(Color.white.ignoresSafeArea())
        .onReceive(timer) { _ in
            viewModel.tick()
            if viewModel.engine.isGameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    goToNextStep()
                }
            }
        }
        .fullScreenCover(isPresented: $showCheckpoint) {
            CheckpointView(isShowing: $isShowing, currentStep: $currentStep)
        }
    }
    
    private func goToNextStep() {
        if isStandalone {
            withAnimation { isShowing = false }
        } else {
            showCheckpoint = true
        }
    }
}
// MARK: - PREVIEWS

struct MemoryExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MemoryExerciseView(
                isShowing: .constant(true),
                currentStep: .constant(1),
                isStandalone: false
            )
            .previewDisplayName("SOS-Flow Modus")
        }
    }
}
