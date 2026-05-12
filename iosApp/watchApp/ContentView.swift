import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeMenuView()
        }
    }
}

private struct HomeMenuView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let mic: CGFloat = min(w, h) * 0.46
            let small: CGFloat = min(w, h) * 0.34

            ZStack {
                NavigationLink {
                    EmergencyVoiceView()
                } label: {
                    BubbleButton(
                        icon: "mic.fill",
                        title: "Talk",
                        size: mic,
                        color: .iremiaPrimary,
                        emphasized: true
                    )
                }
                .buttonStyle(.plain)
                .position(x: w * 0.5, y: h * 0.32)

                NavigationLink {
                    ContactsListView()
                } label: {
                    BubbleButton(
                        icon: "person.2.fill",
                        title: "Contacts",
                        size: small,
                        color: .iremiaPetrol,
                        emphasized: false
                    )
                }
                .buttonStyle(.plain)
                .position(x: w * 0.28, y: h * 0.74)

                NavigationLink {
                    BreathingPlaceholderView()
                } label: {
                    BubbleButton(
                        icon: "wind",
                        title: "Breathe",
                        size: small,
                        color: .iremiaPetrol,
                        emphasized: false
                    )
                }
                .buttonStyle(.plain)
                .position(x: w * 0.74, y: h * 0.78)
            }
        }
    }
}

private struct BubbleButton: View {
    let icon: String
    let title: String
    let size: CGFloat
    let color: Color
    let emphasized: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .shadow(color: color.opacity(emphasized ? 0.5 : 0.25), radius: emphasized ? 8 : 3)
                Image(systemName: icon)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.caption2)
                .foregroundStyle(.primary)
        }
    }
}

private struct BreathingPlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "wind")
                .font(.system(size: 34))
                .foregroundStyle(Color.iremiaPrimary)
            Text("Breathing")
                .font(.headline)
            Text("Coming soon")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Breathe")
    }
}
