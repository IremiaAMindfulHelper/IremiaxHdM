import SwiftUI
import Shared

/// A horizontal selection bar used for dashboard filtering and navigation.
/// Features a primary "All" filter toggle and dynamic navigation links to content categories.
struct FilterBar: View {
    /// The currently active filter identifier on the parent view.
    @Binding var selectedFilter: String
    
    /// Controls the visibility of the global audio mini-player.
    @Binding var showSoundPlayer: Bool
    
    /// The title of the audio track currently in focus or playing.
    @Binding var currentSoundTitle: String
    
    /// NOTE: Categories correspond to the sections available in the WellnessRepository.
    let categories = ["Übungen", "Mantras", "Sounds"]
    let petrol = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // MARK: - DEFAULT FILTER (ALL)
                Button(action: {
                    withAnimation { selectedFilter = "Alle" }
                }) {
                    Text("Alle")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(selectedFilter == "Alle" ? petrol : Color.white)
                        .foregroundColor(selectedFilter == "Alle" ? .white : petrol)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(petrol, lineWidth: 1)
                        )
                }

                // MARK: - CATEGORY NAVIGATION
                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: CategoryDetailView(
                        category: category,
                        showSoundPlayer: $showSoundPlayer,
                        currentSoundTitle: $currentSoundTitle
                    )) {
                        Text(category)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .foregroundColor(petrol)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(petrol, lineWidth: 1)
                            )
                    }
                }
            }
            // NOTE: Padding avoids clipping of the button shadows/borders during scrolling.
            .padding(.vertical, 5)
        }
    }
}
