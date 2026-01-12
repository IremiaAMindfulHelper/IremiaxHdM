import SwiftUI

struct PanicReflexion: View {
    @Environment(\.dismiss) private var dismiss

    // UI (auf/zu)
    @State private var expanded: [Bool] = [true, true, true, true]

    // Category 1 (UI-State)
    @State private var location1: String = ""
    @State private var cause1: String = ""
    @State private var intensity1: Double = 5

    // Category 2 (UI-State)
    @State private var selectedSymptoms: Set<String> = []
    @State private var newSymptomText: String = ""
    @State private var selectedFeelings: Set<String> = []

    // Category 3 (UI-State)
    @State private var skillEffectiveness: Double = 5
    @State private var nextTimeText: String = ""

    // Category 4 (UI-State)
    @State private var shortReflection: String = ""

    private let symptomOptions = ["dizziness", "shortness of breath", "rapid heartbeat"]
    private let feelingOptions: [(key: String, emoji: String, label: String)] = [
        ("anger", "😠", "anger"),
        ("panic fear", "😨", "panic fear"),
        ("helplessness", "🧍", "helplessness")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    HStack(alignment: .top, spacing: 12) {
                        ResultBar()
                            .padding(.top, 18)

                        VStack(spacing: 12) {

                            // CATEGORY 1
                            CategoryCard(
                                title: "Category 1",
                                dateText: "10.11.2025",
                                isExpanded: $expanded[0]
                            ) {
                                Category1Content(
                                    location: $location1,
                                    intensity: $intensity1,
                                    cause: $cause1
                                )
                            }

                            // CATEGORY 2
                            CategoryCard(
                                title: "Category 2",
                                dateText: "10.11.2025",
                                isExpanded: $expanded[1]
                            ) {
                                Category2Content(
                                    symptomOptions: symptomOptions,
                                    selectedSymptoms: $selectedSymptoms,
                                    newSymptomText: $newSymptomText,
                                    feelingOptions: feelingOptions,
                                    selectedFeelings: $selectedFeelings
                                )
                            }

                            // CATEGORY 3
                            CategoryCard(
                                title: "Category 3",
                                dateText: "10.11.2025",
                                isExpanded: $expanded[2]
                            ) {
                                Category3Content(
                                    effectiveness: $skillEffectiveness,
                                    nextTimeText: $nextTimeText
                                )
                            }

                            // CATEGORY 4 (NEU)
                            CategoryCard(
                                title: "Category 4",
                                dateText: "10.11.2025",
                                isExpanded: $expanded[3]
                            ) {
                                Category4Content(shortReflection: $shortReflection)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 10)

                    // Button + Update unter den Kategorien (nicht sticky)
                    VStack(spacing: 10) {
                        Button { } label: {
                            Text("Eintrag abschließen")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Text("update 00:00 alles gespeichert!")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 18)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Panik Reflexion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

// MARK: - Category 1 Content

private struct Category1Content: View {
    @Binding var location: String
    @Binding var intensity: Double
    @Binding var cause: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledField(title: "Location") {
                RoundedTextField(placeholder: "…", text: $location)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Intensity")
                    .font(.subheadline)

                HStack(alignment: .center, spacing: 10) {
                    Text("0").font(.title3)

                    VStack(spacing: 6) {
                        Slider(value: $intensity, in: 0...10, step: 1)
                        Text("\(Int(intensity))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Text("10").font(.title3)
                }
            }

            LabeledField(title: "Cause") {
                RoundedTextField(placeholder: "…", text: $cause)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Category 2 Content

private struct Category2Content: View {
    let symptomOptions: [String]
    @Binding var selectedSymptoms: Set<String>
    @Binding var newSymptomText: String

    let feelingOptions: [(key: String, emoji: String, label: String)]
    @Binding var selectedFeelings: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 10) {
                Text("Symptoms")
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(symptomOptions, id: \.self) { item in
                        SymptomRow(
                            title: item,
                            isSelected: selectedSymptoms.contains(item)
                        ) {
                            if selectedSymptoms.contains(item) {
                                selectedSymptoms.remove(item)
                            } else {
                                selectedSymptoms.insert(item)
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    RoundedTextField(placeholder: "add symptom", text: $newSymptomText)

                    Button { } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Feelings")
                    .font(.subheadline)

                HStack(spacing: 10) {
                    ForEach(feelingOptions, id: \.key) { f in
                        FeelingButton(
                            emoji: f.emoji,
                            label: f.label,
                            isSelected: selectedFeelings.contains(f.key)
                        ) {
                            if selectedFeelings.contains(f.key) {
                                selectedFeelings.remove(f.key)
                            } else {
                                selectedFeelings.insert(f.key)
                            }
                        }
                    }
                    FeelingPlusButton { }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Category 3 Content

private struct Category3Content: View {
    @Binding var effectiveness: Double
    @Binding var nextTimeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Which skills did you use and how well did they work?")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Button { } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.secondary.opacity(0.20))
                                .frame(width: 72, height: 56)

                            Image(systemName: "wind")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.primary.opacity(0.85))
                        }
                    }
                    .buttonStyle(.plain)

                    Text("Breathing Exercise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 86, alignment: .leading)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Image(systemName: "hand.thumbsdown")
                        .foregroundStyle(.secondary)

                    Slider(value: $effectiveness, in: 0...10, step: 1)

                    Image(systemName: "hand.thumbsup")
                        .foregroundStyle(.secondary)
                }
            }

            Button { } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.secondary.opacity(0.20))
                        .frame(width: 72, height: 56)

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.85))
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text("What would you do next time in a similar situation?")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)

                RoundedTextField(placeholder: "…", text: $nextTimeText)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Category 4 Content (NEU)

private struct Category4Content: View {
    @Binding var shortReflection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Short Reflexion")
                .font(.subheadline)

            RoundedTextField(placeholder: "…", text: $shortReflection)
        }
        .padding(.top, 8)
    }
}

// MARK: - Category Card (rechts Platz für Lasche)

private struct CategoryCard<Content: View>: View {
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    private let sideInset: CGFloat = 40

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content
                .padding(.trailing, sideInset)
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)

                if let dateText {
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, sideInset)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.secondary.opacity(0.18))
                .frame(width: sideInset),
            alignment: .trailing
        )
    }
}

// MARK: - Left Result Bar

private struct ResultBar: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<4) { i in
                ResultCheckbox()

                if i < 3 {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.35))
                        .frame(width: 4, height: 70)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.leading, 2)
    }
}

private struct ResultCheckbox: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .stroke(Color.secondary.opacity(0.6), lineWidth: 1.5)
            .frame(width: 24, height: 24)
    }
}

// MARK: - Reusable UI Bits

private struct SymptomRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.9))
                        .frame(width: 32, height: 32)

                    Circle()
                        .fill(isSelected ? Color.primary.opacity(0.15) : Color(.systemBackground))
                        .frame(width: 11, height: 11)
                }

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

private struct FeelingButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.secondary.opacity(isSelected ? 0.28 : 0.20))
                        .frame(width: 66, height: 50)

                    Text(emoji)
                        .font(.system(size: 24))
                }

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct FeelingPlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.secondary.opacity(0.20))
                        .frame(width: 66, height: 50)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.8))
                }

                Text(" ")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
            content
        }
    }
}

private struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.secondary.opacity(0.6), lineWidth: 2)
            )
    }
}

#Preview {
    PanicReflexion()
}
