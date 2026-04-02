import SwiftUI

/// A persistent mini-player for background audio.
/// Displays the active track title and provides play/pause and dismiss controls.
struct SoundPlayerMini: View {
    /// The dynamic title of the currently playing audio track.
    let title: String
    
    @State private var isPlaying: Bool = true
    
    /// Callback triggered when the player is dismissed by the user.
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // MARK: - TRACK ARTWORK PLACEHOLDER
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 45, height: 45)
                .padding(8)
            
            HStack(spacing: 15) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Spacer()
                
                // MARK: - CONTROLS
                Button {
                    withAnimation(.spring()) {
                        isPlaying.toggle()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Button {
                    // NOTE: Spring animation ensures a smooth transition when the player disappears.
                    withAnimation(.spring()) {
                        onClose()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.88, green: 0.94, blue: 0.96))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
