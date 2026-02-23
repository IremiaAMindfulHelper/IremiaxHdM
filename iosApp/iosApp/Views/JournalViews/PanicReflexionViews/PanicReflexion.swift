import SwiftUI

struct PanicReflexion: View {
    let onBack: () -> Void
    let entryDate: Date

    @Environment(\.dismiss) private var dismiss

    // Steuert, ob ein Textfeld fokussiert ist (Keyboard an/aus).
    @FocusState private var isKeyboardActive: Bool

    // Steuert, welche Sektionen aufgeklappt sind.
    @State private var expanded: [Bool] = [true, true, true, true]

    // Eingaben für Situation und Belastung.
    @State private var location1: String = ""
    @State private var cause1: String = ""
    @State private var intensity1: Double = 5

    // Eingaben für Symptome und Gefühle.
    @State private var selectedSymptoms: Set<String> = []
    @State private var newSymptomText: String = ""
    @State private var selectedFeelings: Set<String> = []
    @State private var symptomOptions: [String] = ["Schwindel", "Kurzatmigkeit", "Herzrasen"]

    // Eingaben zur Unterstützung.
    @State private var skillEffectiveness: Double = 5
    @State private var nextTimeText: String = ""

    // Freitext zum Einordnen.
    @State private var shortReflection: String = ""

    private let feelingOptions: [(key: String, emoji: String, label: String)] = [
        ("wut", "😠", "Wut"),
        ("panikAngst", "😨", "Panik/Angst"),
        ("hilflosigkeit", "🧍", "Hilflosigkeit")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 12) {
                    CategoryCard(
                        title: "Situation & Belastung",
                        dateText: nil,
                        isExpanded: expandedBinding(0)
                    ) {
                        Category1Content(
                            location: $location1,
                            intensity: $intensity1,
                            cause: $cause1,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Mein Erleben",
                        dateText: nil,
                        isExpanded: expandedBinding(1)
                    ) {
                        Category2Content(
                            symptomOptions: $symptomOptions,
                            selectedSymptoms: $selectedSymptoms,
                            newSymptomText: $newSymptomText,
                            feelingOptions: feelingOptions,
                            selectedFeelings: $selectedFeelings,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Meine Unterstützung",
                        dateText: nil,
                        isExpanded: expandedBinding(2)
                    ) {
                        Category3Content(
                            effectiveness: $skillEffectiveness,
                            nextTimeText: $nextTimeText,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Einordnen & Loslassen",
                        dateText: nil,
                        isExpanded: expandedBinding(3)
                    ) {
                        Category4Content(
                            shortReflection: $shortReflection,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)

                Button { onBack() } label: {
                    Text("Eintrag abschließen")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.horizontal, 80)
                .padding(.top, 6)
                .padding(.bottom, 18)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
    }

    // Formatiert das Datum für die Toolbar.
    private var formattedPanicDate: String {
        Self.panicDateFormatter.string(from: entryDate)
    }

    private static let panicDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E. dd.MM.yy"
        return f
    }()

    // Liefert ein sicheres Binding auf den Expand-State einer Sektion.
    private func expandedBinding(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { expanded.indices.contains(index) ? expanded[index] : false },
            set: { newValue in
                guard expanded.indices.contains(index) else { return }
                expanded[index] = newValue
            }
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button { onBack() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            }
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("Panik-Reflexion")
                    .font(.headline)
                    .foregroundStyle(.black)

                Text(formattedPanicDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") { isKeyboardActive = false }
        }
    }
}

// MARK: - Category Contents

private struct Category1Content: View {
    @Binding var location: String
    @Binding var intensity: Double
    @Binding var cause: String

    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LabeledField(title: "Ort") {
                RoundedTextField(placeholder: "…", text: $location, isKeyboardActive: $isKeyboardActive)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Intensität")
                    .font(.subheadline)
                    .foregroundColor(.black)

                HStack(alignment: .center, spacing: 10) {
                    Text("0")
                        .font(.title3)
                        .foregroundColor(.black)

                    VStack(spacing: 6) {
                        Slider(value: $intensity, in: 0...10, step: 1)
                        Text("\(Int(intensity))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Text("10")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }

            LabeledField(title: "Auslöser") {
                RoundedTextField(placeholder: "…", text: $cause, isKeyboardActive: $isKeyboardActive)
            }
        }
        .padding(.top, 8)
    }
}

private struct Category2Content: View {
    @Binding var symptomOptions: [String]
    @Binding var selectedSymptoms: Set<String>
    @Binding var newSymptomText: String

    let feelingOptions: [(key: String, emoji: String, label: String)]
    @Binding var selectedFeelings: Set<String>

    @FocusState.Binding var isKeyboardActive: Bool

    private func addSymptomIfPossible() {
        let cleaned = newSymptomText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        let exists = symptomOptions.contains { $0.lowercased() == cleaned.lowercased() }
        guard !exists else {
            newSymptomText = ""
            isKeyboardActive = false
            return
        }

        symptomOptions.append(cleaned)
        selectedSymptoms.insert(cleaned)
        newSymptomText = ""
        isKeyboardActive = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Symptome")
                    .font(.subheadline)
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(symptomOptions, id: \.self) { item in
                        SymptomRow(title: item, isSelected: selectedSymptoms.contains(item)) {
                            if selectedSymptoms.contains(item) {
                                selectedSymptoms.remove(item)
                            } else {
                                selectedSymptoms.insert(item)
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                symptomOptions.removeAll { $0 == item }
                                selectedSymptoms.remove(item)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }

                RoundedTextField(
                    placeholder: "Symptom hinzufügen",
                    text: $newSymptomText,
                    isKeyboardActive: $isKeyboardActive
                )
                .submitLabel(.done)
                .onSubmit { addSymptomIfPossible() }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Gefühle")
                    .font(.subheadline)
                    .foregroundColor(.black)

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

private struct Category3Content: View {
    @Binding var effectiveness: Double
    @Binding var nextTimeText: String

    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Welche Strategien hast du genutzt – und wie gut haben sie geholfen?")
                .font(.subheadline)
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Button { } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.systemGray6))
                                .frame(width: 72, height: 56)

                            Image(systemName: "wind")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.primary.opacity(0.85))
                        }
                    }
                    .buttonStyle(.plain)

                    Text("Atemübung")
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
                        .fill(Color(.systemGray6))
                        .frame(width: 72, height: 56)

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.85))
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text("Was würdest du beim nächsten Mal in einer ähnlichen Situation tun?")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)

                RoundedTextField(placeholder: "…", text: $nextTimeText, isKeyboardActive: $isKeyboardActive)
            }
        }
        .padding(.top, 8)
    }
}

private struct Category4Content: View {
    @Binding var shortReflection: String
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Kurze Reflexion")
                .font(.subheadline)
                .foregroundColor(.black)

            RoundedTextField(placeholder: "…", text: $shortReflection, isKeyboardActive: $isKeyboardActive)
        }
        .padding(.top, 8)
    }
}

// MARK: - Local helpers (unique names, no duplicates)

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            content
        }
    }
}

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
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
                        )
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
                        .fill(Color(.systemGray6))
                        .frame(width: 66, height: 50)

                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.8))
                }

                Text("Hinzufügen")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PanicReflexion(onBack: {}, entryDate: Date())
    }
}
