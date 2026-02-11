import SwiftUI

struct PanicReflexion: View {

    let onBack: () -> Void

    /// ✅ Datum aus JournalEntryView / Kalender
    let entryDate: Date

    @Environment(\.dismiss) private var dismiss

    // ✅ Keyboard Focus
    @FocusState private var isKeyboardActive: Bool

    // UI (auf/zu)
    @State private var expanded: [Bool] = [true, true, true, true]

    // Section 1 (UI-State)
    @State private var location1: String = ""
    @State private var cause1: String = ""
    @State private var intensity1: Double = 5

    // Section 2 (UI-State)
    @State private var selectedSymptoms: Set<String> = []
    @State private var newSymptomText: String = ""
    @State private var selectedFeelings: Set<String> = []

    // ✅ Wichtig: @State damit neue Symptome als Buttons entstehen
    @State private var symptomOptions: [String] = ["Schwindel", "Kurzatmigkeit", "Herzrasen"]

    // Section 3 (UI-State)
    @State private var skillEffectiveness: Double = 5
    @State private var nextTimeText: String = ""

    // Section 4
    @State private var shortReflection: String = ""

    // ✅ Alles auf Deutsch
    private let feelingOptions: [(key: String, emoji: String, label: String)] = [
        ("wut", "😠", "Wut"),
        ("panikAngst", "😨", "Panik/Angst"),
        ("hilflosigkeit", "🧍", "Hilflosigkeit")
    ]

    private var formattedPanicDate: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E. dd.MM.yy" // z.B. "Mi. 28.01.26"
        return f.string(from: entryDate)
    }

    // ✅ sichere Bindings für Array-Indizes
    private func expandedBinding(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { expanded.indices.contains(index) ? expanded[index] : false },
            set: { newValue in
                guard expanded.indices.contains(index) else { return }
                expanded[index] = newValue
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                VStack(spacing: 12) {

                    // ✅ Titles wie High-Fidelity Prototyp
                    CategoryCard(title: "Situation & Belastung", dateText: nil, isExpanded: expandedBinding(0)) {
                        Category1Content(
                            location: $location1,
                            intensity: $intensity1,
                            cause: $cause1,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(title: "Mein Erleben", dateText: nil, isExpanded: expandedBinding(1)) {
                        Category2Content(
                            symptomOptions: $symptomOptions,              // ✅ Binding!
                            selectedSymptoms: $selectedSymptoms,
                            newSymptomText: $newSymptomText,
                            feelingOptions: feelingOptions,
                            selectedFeelings: $selectedFeelings,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(title: "Meine Unterstützung", dateText: nil, isExpanded: expandedBinding(2)) {
                        Category3Content(
                            effectiveness: $skillEffectiveness,
                            nextTimeText: $nextTimeText,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(title: "Einordnen & Loslassen", dateText: nil, isExpanded: expandedBinding(3)) {
                        Category4Content(
                            shortReflection: $shortReflection,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)

                // Button wie Tagebuch
                VStack(spacing: 10) {
                    Button {
                        onBack()
                    } label: {
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
                }
                .padding(.horizontal, 80)
                .padding(.top, 6)
                .padding(.bottom, 18)
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // ✅ Back links
            ToolbarItem(placement: .topBarLeading) {
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }

            // ✅ Title + Date (wie Tagebuch)
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

            // ✅ Done Button in Keyboard
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") { isKeyboardActive = false }
            }
        }
        .onTapGesture { isKeyboardActive = false }
    }
}

// MARK: - Section 1 Content (Situation & Belastung)
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
                    Text("0").font(.title3).foregroundColor(.black)

                    VStack(spacing: 6) {
                        Slider(value: $intensity, in: 0...10, step: 1)
                        Text("\(Int(intensity))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Text("10").font(.title3).foregroundColor(.black)
                }
            }

            LabeledField(title: "Auslöser") {
                RoundedTextField(placeholder: "…", text: $cause, isKeyboardActive: $isKeyboardActive)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Section 2 Content (Mein Erleben)
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
        selectedSymptoms.insert(cleaned) // ✅ direkt markieren
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
                        // optional: long press löschen
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

                // ✅ WICHTIG: Einzeiliges Field -> onSubmit funktioniert auch am echten iPhone
                RoundedSingleLineTextField(
                    placeholder: "Symptom hinzufügen",
                    text: $newSymptomText,
                    isKeyboardActive: $isKeyboardActive
                )
                .submitLabel(.done)
                .onSubmit {
                    addSymptomIfPossible()
                }
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

// MARK: - Section 3 Content (Meine Unterstützung)
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

// MARK: - Section 4 Content (Einordnen & Loslassen)
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

// MARK: - Tagebuch Style Category Card
private struct CategoryCard<Content: View>: View {
    let title: String
    let dateText: String?
    @Binding var isExpanded: Bool
    @ViewBuilder var content: Content

    private let sideInset: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(.black)

                        if let dateText {
                            Text(dateText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, sideInset + 12)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .padding(.trailing, sideInset)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.4, green: 0.4, blue: 0.4))
                .frame(width: sideInset),
            alignment: .trailing
        )
        .overlay(
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
                .padding(.trailing, 12)
                .padding(.top, 12),
            alignment: .topTrailing
        )
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

private struct RoundedTextField: View {
    let placeholder: String
    @Binding var text: String
    var isKeyboardActive: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {
            if let isKeyboardActive {
                TextField(placeholder, text: $text, axis: .vertical)
                    .focused(isKeyboardActive)
            } else {
                TextField(placeholder, text: $text, axis: .vertical)
            }
        }
        .textFieldStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .lineLimit(1...6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black, lineWidth: 1)
        )
        .background(Color.white)
    }
}

/// ✅ Einzeiliges Feld: Return/Done triggert onSubmit auch am echten iPhone
private struct RoundedSingleLineTextField: View {
    let placeholder: String
    @Binding var text: String
    var isKeyboardActive: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {
            if let isKeyboardActive {
                TextField(placeholder, text: $text)
                    .focused(isKeyboardActive)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black, lineWidth: 1)
        )
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        PanicReflexion(onBack: {}, entryDate: Date())
    }
}
