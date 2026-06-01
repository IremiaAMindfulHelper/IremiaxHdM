import SwiftUI

enum MoodLevel: String, CaseIterable {
    case good, neutral, bad

    var emoji: String {
        switch self {
        case .good: return "😊"
        case .neutral: return "😐"
        case .bad: return "😞"
        }
    }

    var color: Color {
        switch self {
        case .good: return .green
        case .neutral: return .yellow
        case .bad: return .red
        }
    }

    var label: String {
        switch self {
        case .good: return "Good"
        case .neutral: return "Neutral"
        case .bad: return "Bad"
        }
    }
}

struct MoodFaceView: View {
    let mood: MoodLevel
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(mood.color)
            .frame(width: size, height: size)
            .overlay {
                VStack(spacing: size * 0.06) {
                    HStack(spacing: size * 0.22) {
                        Circle().fill(.white).frame(width: size * 0.14, height: size * 0.14)
                        Circle().fill(.white).frame(width: size * 0.14, height: size * 0.14)
                    }
                    MouthShape(mood: mood)
                        .stroke(.white, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                        .frame(width: size * 0.4, height: size * 0.2)
                }
                .offset(y: size * 0.02)
            }
    }
}

private struct MouthShape: Shape {
    let mood: MoodLevel

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY

        switch mood {
        case .good:
            path.move(to: CGPoint(x: rect.minX, y: midY - rect.height * 0.2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY - rect.height * 0.2),
                              control: CGPoint(x: midX, y: rect.maxY))
        case .neutral:
            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        case .bad:
            path.move(to: CGPoint(x: rect.minX, y: midY + rect.height * 0.2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY + rect.height * 0.2),
                              control: CGPoint(x: midX, y: rect.minY))
        }

        return path
    }
}

struct MoodCheckView: View {
    var onMoodSelected: (MoodLevel) -> Void
    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 12) {
            Text("How are you feeling?")
                .font(.headline)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(MoodLevel.allCases, id: \.self) { mood in
                    Button {
                        onMoodSelected(mood)
                    } label: {
                        VStack(spacing: 4) {
                            MoodFaceView(mood: mood, size: 36)
                            Text(mood.label)
                                .font(.caption2)
                                .foregroundStyle(mood.color)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

            Button {
                onDismiss()
            } label: {
                Text("Skip")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .onAppear { appeared = true }
    }
}
