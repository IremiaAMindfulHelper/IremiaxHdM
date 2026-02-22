import SwiftUI
import Shared
// MARK: - FILTER BAR
struct FilterBar: View {
    @Binding var selectedFilter: String
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    
    let categories = ["Übungen", "Mantras", "Sounds"]
    let petrol = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: { withAnimation { selectedFilter = "Alle" } }) {
                    Text("Alle")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(selectedFilter == "Alle" ? petrol : Color.white)
                        .foregroundColor(selectedFilter == "Alle" ? .white : petrol)
                        .cornerRadius(25)
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(petrol, lineWidth: 1))
                }

                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: CategoryDetailView(category: category, showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)) {
                        Text(category)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Color.white)
                            .foregroundColor(petrol)
                            .cornerRadius(25)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(petrol, lineWidth: 1))
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }
}
