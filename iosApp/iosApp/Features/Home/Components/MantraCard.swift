import SwiftUI
import Shared

/// A card component that displays a specific mantra.
/// Used within lists to show the mantra's title and its inspirational quote.
struct MantraCard: View {
    let mantra: WellnessMantra
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mantra.titel).font(.headline)
                Text("\"\(mantra.spruch)\"")
                    .font(.subheadline).italic().foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.3))
        }
        .padding().background(Color.white).cornerRadius(18).shadow(color: .black.opacity(0.05), radius: 5)
    }
}
