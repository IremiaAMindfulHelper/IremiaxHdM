import SwiftUI
import Shared

// MARK: - CATEGORY DETAIL VIEW
struct CategoryDetailView: View {
    let category: String
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if category == "Übungen" {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            ExerciseCard(exercise: exercise)
                        }
                    }
                } else if category == "Sounds" {
                    VStack(spacing: 15) {
                        ForEach(viewModel.sounds, id: \.id) { sound in
                            SoundCard(sound: sound, currentSoundTitle: $currentSoundTitle, showSoundPlayer: $showSoundPlayer)
                        }
                    }
                } else if category == "Mantras" {
                    VStack(spacing: 12) {
                        ForEach(viewModel.mantras, id: \.id) { mantra in
                            MantraCard(mantra: mantra)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
    }
}
