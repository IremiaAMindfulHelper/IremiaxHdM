import SwiftUI
import AVFoundation

private struct ResponseItem: Identifiable {
    let id = UUID()
    let text: String
}

struct EmergencyVoiceView: View {
    @StateObject private var viewModel = EmergencyWatchViewModel()
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @StateObject private var monitor = MicLevelMonitor()
    @State private var responseItem: ResponseItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            backgroundCircle
            content
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $responseItem) { item in
            EmergencyResponseView(text: item.text) {
                responseItem = nil
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    dismiss()
                }
            }
        }
        .onAppear {
            AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        }
        .onDisappear { monitor.stop() }
        .onChange(of: viewModel.state) { newState in
            switch newState {
            case .recording:
                monitor.start()
            case .responding(let text):
                monitor.stop()
                responseItem = ResponseItem(text: text)
            default:
                monitor.stop()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            idleView
        case .recording:
            recordingView
        case .processing:
            ProgressView()
                .tint(Color.iremiaLabel)
                .scaleEffect(0.9)
        case .responding:
            EmptyView()
        }
    }

    private var backgroundCircle: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color.iremiaPetrol.opacity(0.18))
                .frame(width: geo.size.width, height: geo.size.width)
                .position(x: geo.size.width / 2, y: geo.size.height * 0.82)
        }
        .ignoresSafeArea()
    }

    private var idleView: some View {
        VStack(spacing: 10) {
            Spacer()
            Button { viewModel.tapped() } label: {
                ZStack {
                    Circle().fill(Color.iremiaPetrol)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.iremiaLabel)
                }
                .frame(width: 60, height: 60)
            }
            .buttonStyle(.plain)
            Text("Tap to speak")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
            Spacer()
            Button { dismiss() } label: {
                Text("Cancel")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.iremiaLabel)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var recordingView: some View {
        VStack(spacing: 0) {
            Text("Listening...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.iremiaLabel)
                .padding(.top, 8)

            if !connectivity.liveTranscript.isEmpty {
                Text(connectivity.liveTranscript)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.iremiaLabel.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 5) {
                LeftWaveformBars(level: monitor.level)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Button { viewModel.tapped() } label: {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.iremiaPetrol)
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
                RightWaveformBars(level: monitor.level)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 6)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Response screen

private struct EmergencyResponseView: View {
    let text: String
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DecorativeCirclesView(mood: .bad).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 0)
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.iremiaResponseText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                Button { onDismiss() } label: {
                    Text("Done")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.iremiaPetrol)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.iremiaLabel))
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: appeared)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { appeared = true }
    }
}
