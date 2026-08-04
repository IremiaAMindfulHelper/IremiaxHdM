import SwiftUI
import shared

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedFilter = "Alle"

    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String

    init(
        showSoundPlayer: Binding<Bool> = .constant(false),
        currentSoundTitle: Binding<String> = .constant("")
    ) {
        self._showSoundPlayer = showSoundPlayer
        self._currentSoundTitle = currentSoundTitle
    }

    private let petrol = Color(red: 0.2, green: 0.45, blue: 0.55)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {

                HStack {
                    Text("Hi User!")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(petrol.opacity(0.6))
                }
                .padding(.top, 10)

                FilterBar(
                    selectedFilter: $selectedFilter,
                    showSoundPlayer: $showSoundPlayer,
                    currentSoundTitle: $currentSoundTitle
                )

                if selectedFilter == "Alle" || selectedFilter == "Übungen" {
                    VStack(alignment: .leading, spacing: 15) {
                        sectionHeader(title: "Übungen", category: "Übungen")

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                            spacing: 20
                        ) {
                            ForEach(viewModel.exercises.prefix(4), id: \.id) { item in
                                ExerciseCard(exercise: item)
                            }
                        }
                    }
                }

                if selectedFilter == "Alle" || selectedFilter == "Mantras" {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Mantras").font(.title2).bold()

                        VStack(spacing: 12) {
                            ForEach(viewModel.mantras, id: \.id) { item in
                                MantraCard(mantra: item)
                            }
                        }
                    }
                }

                if selectedFilter == "Alle" || selectedFilter == "Sounds" {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sounds").font(.title2).bold()

                        VStack(spacing: 15) {
                            ForEach(viewModel.sounds, id: \.id) { item in
                                SoundCard(
                                    sound: item,
                                    currentSoundTitle: $currentSoundTitle,
                                    showSoundPlayer: $showSoundPlayer
                                )
                            }
                        }
                    }
                }

                Color.clear.frame(height: 150)
            }
            .padding(.horizontal)
        }
    }

    private func sectionHeader(title: String, category: String) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title).font(.title2).bold()
            Spacer()

            NavigationLink(
                destination: CategoryDetailView(
                    category: category,
                    showSoundPlayer: $showSoundPlayer,
                    currentSoundTitle: $currentSoundTitle
                )
            ) {
                Text("Alle anzeigen")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(petrol)
                    .underline()
            }
        }
    }
}
