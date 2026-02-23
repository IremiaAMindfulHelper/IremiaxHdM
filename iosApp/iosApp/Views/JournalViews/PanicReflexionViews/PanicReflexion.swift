import SwiftUI

struct PanicReflexion: View {
    let onBack: () -> Void
    let entryDate: Date

    // UI-only
    @FocusState private var isKeyboardActive: Bool

    // State + Logik
    @StateObject private var vm = PanicReflexionViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 12) {

                    CategoryCard(
                        title: "Situation & Belastung",
                        dateText: nil,
                        isExpanded: binding(for: vm.expandedBinding(0))
                    ) {
                        Category1Content(
                            location: $vm.location1,
                            intensity: $vm.intensity1,
                            cause: $vm.cause1,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Mein Erleben",
                        dateText: nil,
                        isExpanded: binding(for: vm.expandedBinding(1))
                    ) {
                        Category2Content(
                            vm: vm,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Meine Unterstützung",
                        dateText: nil,
                        isExpanded: binding(for: vm.expandedBinding(2))
                    ) {
                        Category3Content(
                            effectiveness: $vm.skillEffectiveness,
                            nextTimeText: $vm.nextTimeText,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    CategoryCard(
                        title: "Einordnen & Loslassen",
                        dateText: nil,
                        isExpanded: binding(for: vm.expandedBinding(3))
                    ) {
                        Category4Content(
                            shortReflection: $vm.shortReflection,
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

    // BindingProxy -> SwiftUI.Binding
    private func binding<T>(for proxy: PanicReflexionViewModel.BindingProxy<T>) -> Binding<T> {
        Binding(get: proxy.get, set: proxy.set)
    }

    private var formattedPanicDate: String {
        Self.panicDateFormatter.string(from: entryDate)
    }

    private static let panicDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E. dd.MM.yy"
        return f
    }()

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
    @ObservedObject var vm: PanicReflexionViewModel
    @FocusState.Binding var isKeyboardActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Symptome")
                    .font(.subheadline)
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(vm.symptomOptions, id: \.self) { item in
                        SymptomRow(title: item, isSelected: vm.selectedSymptoms.contains(item)) {
                            vm.toggleSymptom(item)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                vm.deleteSymptom(item)
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                        }
                    }
                }

                RoundedTextField(
                    placeholder: "Symptom hinzufügen",
                    text: $vm.newSymptomText,
                    isKeyboardActive: $isKeyboardActive
                )
                .submitLabel(.done)
                .onSubmit {
                    _ = vm.addSymptomIfPossible()
                    isKeyboardActive = false
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Gefühle")
                    .font(.subheadline)
                    .foregroundColor(.black)

                HStack(spacing: 10) {
                    ForEach(vm.feelingOptions, id: \.key) { f in
                        FeelingButton(
                            emoji: f.emoji,
                            label: f.label,
                            isSelected: vm.selectedFeelings.contains(f.key)
                        ) {
                            vm.toggleFeeling(f.key)
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

// MARK: - Local helpers

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
