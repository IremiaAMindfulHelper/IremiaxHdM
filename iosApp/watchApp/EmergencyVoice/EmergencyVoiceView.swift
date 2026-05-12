import SwiftUI

struct EmergencyVoiceView: View {
    @StateObject private var viewModel = EmergencyWatchViewModel()
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                tapButton
                statusText
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Iremia")
    }

    private var tapButton: some View {
        Button(action: { viewModel.tapped() }) {
            ZStack {
                Circle()
                    .fill(Color.iremiaPrimary)
                    .frame(width: 110, height: 110)
                    .scaleEffect(pulse && viewModel.state == .recording ? 1.08 : 1.0)
                    .animation(
                        viewModel.state == .recording
                            ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                            : .default,
                        value: pulse
                    )
                icon
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .onAppear { pulse = true }
    }

    @ViewBuilder
    private var icon: some View {
        switch viewModel.state {
        case .idle:
            Image(systemName: "mic.fill")
        case .recording:
            Image(systemName: "stop.fill")
        case .processing:
            ProgressView().tint(.white)
        case .responding:
            Image(systemName: "arrow.clockwise")
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.state {
        case .idle:
            Text("Tap to speak")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .recording:
            VStack(spacing: 4) {
                Text("Listening …")
                    .font(.caption)
                    .foregroundStyle(Color.iremiaPrimary)
                if !connectivity.liveTranscript.isEmpty {
                    Text(connectivity.liveTranscript)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
            }
        case .processing:
            Text("Processing …")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .responding(let text):
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
        }
    }
}
