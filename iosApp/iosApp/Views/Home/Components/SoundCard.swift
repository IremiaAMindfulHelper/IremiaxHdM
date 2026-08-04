import SwiftUI
import shared

/// A row component representing an audio track.
/// Allows the user to trigger a sound and displays its title and short description.
struct SoundCard: View {
    let sound: WellnessSound
    @Binding var currentSoundTitle: String
    @Binding var showSoundPlayer: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)).frame(width: 75, height: 75)
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.titel).font(.system(size: 16, weight: .bold))
                Text(sound.beschreibung).font(.system(size: 13)).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
            Button(action: {
                currentSoundTitle = sound.titel
                withAnimation(.spring()) { showSoundPlayer = true }
            }) {
                Image(systemName: "play.circle.fill").font(.system(size: 32)).foregroundColor(.black)
            }
        }
        .padding(10).background(Color.white).cornerRadius(18).shadow(color: .black.opacity(0.05), radius: 8)
    }
}
