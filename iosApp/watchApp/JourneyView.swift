import SwiftUI

struct JourneyView: View {
    @ObservedObject private var store = JourneyStore.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MoodChartView(entries: store.entries)
                    .frame(height: 90)
                    .padding(.top, 4)

                NavigationLink {
                    JournalEntriesView()
                } label: {
                    HStack(spacing: 4) {
                        Text("Access Journal Entries")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.iremiaEntryBg)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .background {
            LinearGradient(
                colors: [
                    Color.iremiaJourneyTeal.opacity(0.35),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Journey")
    }
}

// MARK: - Journal Entries List

struct JournalEntriesView: View {
    @ObservedObject private var store = JourneyStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.iremiaJourneyTeal.opacity(0.06),
                                    Color.iremiaJourneyTeal
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 36)

                    Text("Journal Entries")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.iremiaJourneyTitle)
                }

                if store.entries.isEmpty {
                    Text("No entries yet")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                } else {
                    ForEach(store.entries) { entry in
                        NavigationLink {
                            JournalEntryDetailView(entry: entry)
                        } label: {
                            JournalEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Return to streaks")
                            .font(.system(size: 11))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(Color.iremiaLabel)
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
            .padding(.horizontal, 8)
        }
        .background {
            LinearGradient(
                colors: [
                    Color.iremiaJourneyTeal.opacity(0.35),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Journey")
    }
}

// MARK: - Entry Row

private struct JournalEntryRow: View {
    let entry: JournalEntry

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    var body: some View {
        HStack {
            MoodIconView(mood: entry.moodLevel ?? .neutral, size: 20, tint: .iremiaBannerTeal)

            VStack(alignment: .leading, spacing: 2) {
                Text(Self.dateFormatter.string(from: entry.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)

                if let transcript = entry.transcript, !transcript.isEmpty {
                    Text(transcript)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                } else if let response = entry.response, !response.isEmpty {
                    Text(response)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.iremiaEntryBg)
        )
    }
}

// MARK: - Entry Detail

private struct JournalEntryDetailView: View {
    let entry: JournalEntry

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy – HH:mm"
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                MoodIconView(mood: entry.moodLevel ?? .neutral, size: 50)

                Text(entry.moodLevel?.label ?? "Neutral")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(entry.moodLevel?.color ?? .yellow)

                Text(Self.dateFormatter.string(from: entry.date))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                if let category = entry.category, let detail = entry.detail {
                    Text("You felt \(entry.moodLevel?.label.lowercased() ?? "this way") because of your \(category.lowercased()): \(detail.lowercased()).")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.iremiaLabel)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }

                if let response = entry.response, !response.isEmpty {
                    Text(response)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.iremiaResponseText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                        .padding(.horizontal, 4)
                }

                if let transcript = entry.transcript, !transcript.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You said:")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.iremiaLabel)
                        Text(transcript)
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 6)
                }

                if entry.category == nil && entry.transcript == nil {
                    Text("No mood details recorded")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 12)
        }
        .background {
            LinearGradient(
                colors: [
                    Color.iremiaJourneyTeal.opacity(0.35),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Mood Chart

private struct MoodChartView: View {
    let entries: [JournalEntry]

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                VStack(spacing: 0) {
                    MoodIconView(mood: .good, size: 14)
                    Spacer()
                    MoodIconView(mood: .neutral, size: 14)
                    Spacer()
                    MoodIconView(mood: .bad, size: 14)
                }
                .frame(width: 18)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    ZStack {
                        gridLines(width: w, height: h)

                        if !entries.isEmpty {
                            let sorted = entries.sorted { $0.date < $1.date }
                            let pts = points(for: sorted, width: w, height: h)

                            if pts.count >= 2 {
                                Path { path in
                                    path.move(to: pts[0])
                                    for p in pts.dropFirst() {
                                        path.addLine(to: p)
                                    }
                                }
                                .stroke(Color.iremiaLabel, lineWidth: 2)
                            }

                            ForEach(Array(pts.enumerated()), id: \.offset) { i, pt in
                                Circle()
                                    .fill(Color.iremiaBannerTeal)
                                    .frame(width: 6, height: 6)
                                    .position(pt)
                            }
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                Spacer().frame(width: 22)
                ForEach(monthLabels, id: \.self) { month in
                    Text(month)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.iremiaLabel)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func gridLines(width: CGFloat, height: CGFloat) -> some View {
        Path { path in
            for i in 0..<3 {
                let y = CGFloat(i) * height / 2
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color.iremiaLabel.opacity(0.15), lineWidth: 0.5)
    }

    private func points(for sorted: [JournalEntry], width: CGFloat, height: CGFloat) -> [CGPoint] {
        sorted.enumerated().map { i, entry in
            let x = sorted.count == 1
                ? width / 2
                : width * CGFloat(i) / CGFloat(sorted.count - 1)
            let yFraction: CGFloat
            switch entry.mood {
            case "good": yFraction = 0.0
            case "bad": yFraction = 1.0
            default: yFraction = 0.5
            }
            return CGPoint(x: x, y: yFraction * (height - 8) + 4)
        }
    }

    private var monthLabels: [String] {
        let cal = Calendar.current
        let formatter = DateFormatter()

        if entries.isEmpty {
            let now = cal.component(.month, from: Date())
            return (0..<3).map { offset in
                var m = now - 2 + offset
                if m < 1 { m += 12 }
                return formatter.shortMonthSymbols[m - 1].uppercased()
            }
        }

        let months = Set(entries.map { cal.component(.month, from: $0.date) }).sorted()
        return months.prefix(5).map { formatter.shortMonthSymbols[$0 - 1].uppercased() }
    }
}
