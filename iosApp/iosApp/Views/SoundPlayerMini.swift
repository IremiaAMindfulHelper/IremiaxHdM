import SwiftUI

struct SoundPlayerMini: View {
    @State private var isPlaying: Bool = false
    let onClose: () -> Void   // 👈 kommt vom Parent
    
    var body: some View {
        HStack(spacing: 0) {
            // Cover
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 45, height: 45)
                .padding(8)
            
            HStack(spacing: 15) {
                Text("Meeresrauschen")
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Spacer()
                
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
                    withAnimation(.spring()) {
                        onClose()   // 👈 HIER schließt er sich wirklich
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
