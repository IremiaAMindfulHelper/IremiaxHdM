import SwiftUI
import shared

/// A grid-based card representing a single wellness exercise.
/// Handles the navigation logic to different exercise types like breathing, calculation, or memory.
struct ExerciseCard: View {
    let exercise: WellnessExercise
    @State private var showExercise = false
    @State private var dummyStep = 0
    
    var body: some View {
        Button(action: { showExercise = true }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.1))
                    Image(exercise.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width / 2 - 24, height: 110)
                        .clipped()
                        .cornerRadius(16)
                }.frame(height: 110)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(exercise.kategorie).font(.system(size: 11, weight: .medium)).foregroundColor(.gray)
                        Spacer()
                        if exercise.dauer != "-" {
                            HStack(spacing: 3) {
                                Image(systemName: "clock").font(.system(size: 10))
                                Text(exercise.dauer).font(.system(size: 11))
                            }.foregroundColor(.gray)
                        }
                    }
                    Text(exercise.titel).font(.system(size: 15, weight: .bold)).foregroundColor(.black).lineLimit(1)
                    Text(exercise.beschreibung).font(.system(size: 12)).foregroundColor(.gray).lineLimit(2)
                }
                .frame(height: 70, alignment: .top)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            switch exercise.type {
            case .calculation:
                CalculationExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .breathing:
                BreathingExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .memory:
                MemoryExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .mantra:
                MantraView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            default:
                EmptyView()
            }
        }
    }
}
