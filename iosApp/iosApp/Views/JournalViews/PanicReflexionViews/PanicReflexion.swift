import SwiftUI

struct PanicReflexion: View {
    let onBack: () -> Void
    let entryDate: Date

    @FocusState private var isKeyboardActive: Bool
    @StateObject private var vm = PanicReflexionViewModel()

    private let headerYellow = PanicTheme.yellow
    private let buttonYellow = PanicTheme.yellow

    private let pageSidePadding: CGFloat = 16
    private let sectionSpacing: CGFloat = 14

    var body: some View {
        ZStack {
            PanicTheme.pageBG.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: sectionSpacing) {
                    
                    PanicCategoryCard(
                        title: "Situation & Belastung",
                        isExpanded: binding(for: vm.expandedBinding(0)),
                        isDone: isCategory1Done
                    ) {
                        Category1Content(
                            location: $vm.location1,
                            intensity: $vm.intensity1,
                            cause: $vm.cause1,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    PanicCategoryCard(
                        title: "Mein Erleben",
                        isExpanded: binding(for: vm.expandedBinding(1)),
                        isDone: isCategory2Done
                    ) {
                        Category2Content(
                            vm: vm,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    PanicCategoryCard(
                        title: "Meine Unterstützung",
                        isExpanded: binding(for: vm.expandedBinding(2)),
                        isDone: isCategory3Done
                    ) {
                        Category3Content(
                            effectiveness: $vm.skillEffectiveness,
                            nextTimeText: $vm.nextTimeText,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    PanicCategoryCard(
                        title: "Einordnen & Loslassen",
                        isExpanded: binding(for: vm.expandedBinding(3)),
                        isDone: isCategory4Done
                    ) {
                        Category4Content(
                            shortReflection: $vm.shortReflection,
                            isKeyboardActive: $isKeyboardActive
                        )
                    }

                    Button { onBack() } label: {
                        Text("Eintrag abschließen")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(buttonYellow)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 8)
                    }
                    .padding(.horizontal, 50)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.top, 12)
                .padding(.horizontal, pageSidePadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(headerYellow, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar { toolbarContent }
        .onTapGesture { isKeyboardActive = false }
    }

    // MARK: - Logik
    private func filled(_ s: String) -> Bool { !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var isCategory1Done: Bool { filled(vm.location1) || filled(vm.cause1) || Int(vm.intensity1) != 5 }
    private var isCategory2Done: Bool { !vm.selectedSymptoms.isEmpty || !vm.selectedFeelings.isEmpty }
    private var isCategory3Done: Bool { filled(vm.nextTimeText) || Int(vm.skillEffectiveness) != 5 }
    private var isCategory4Done: Bool { filled(vm.shortReflection) }

    private func binding<T>(for proxy: PanicReflexionViewModel.BindingProxy<T>) -> Binding<T> {
        Binding(get: proxy.get, set: proxy.set)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.10)))
            }
            .buttonStyle(.plain)
        }
        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("Panik-Reflexion").font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundColor(.black)
                Text(DateFormatter.localizedString(from: entryDate, dateStyle: .medium, timeStyle: .none))
                    .font(.system(size: 12.5)).foregroundColor(.black.opacity(0.60))
            }
        }
    }
}

// MARK: - Sub-Views (Hier lagen die Fehler)

struct Category1Content: View {
    @Binding var location: String
    @Binding var intensity: Double
    @Binding var cause: String
    @FocusState.Binding var isKeyboardActive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LabeledField(title: "Ort") { RoundedTextField(placeholder: "…", text: $location, isKeyboardActive: $isKeyboardActive) }
            VStack(alignment: .leading, spacing: 8) {
                Text("Intensität").font(.subheadline)
                HStack(spacing: 12) {
                    Text("0").font(.footnote)
                    Slider(value: $intensity, in: 0...10, step: 1)
                    Text("10").font(.footnote)
                }
            }
            LabeledField(title: "Auslöser") { RoundedTextField(placeholder: "…", text: $cause, isKeyboardActive: $isKeyboardActive) }
        }.padding(.top, 8)
    }
}

struct Category2Content: View {
    @ObservedObject var vm: PanicReflexionViewModel
    @FocusState.Binding var isKeyboardActive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Symptome").font(.subheadline)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(vm.symptomOptions, id: \.self) { item in
                    SymptomRow(title: item, isSelected: vm.selectedSymptoms.contains(item)) { vm.toggleSymptom(item) }
                }
            }
            RoundedTextField(placeholder: "Symptom hinzufügen", text: $vm.newSymptomText, isKeyboardActive: $isKeyboardActive)
                .onSubmit { _ = vm.addSymptomIfPossible() }
            
            Text("Gefühle").font(.subheadline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(vm.feelingOptions, id: \.key) { f in
                        FeelingButton(emoji: f.emoji, label: f.label, isSelected: vm.selectedFeelings.contains(f.key)) { vm.toggleFeeling(f.key) }
                    }
                    FeelingPlusButton { }
                }
            }
        }.padding(.top, 8)
    }
}

struct Category3Content: View {
    @Binding var effectiveness: Double
    @Binding var nextTimeText: String
    @FocusState.Binding var isKeyboardActive: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Welche Strategien hast du genutzt?")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)).frame(width: 64, height: 50)
                        .overlay(Image(systemName: "wind").font(.system(size: 20, weight: .semibold)))
                    Text("Atemübung").font(.system(size: 10)).foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsdown").font(.footnote).foregroundStyle(.secondary)
                    Slider(value: $effectiveness, in: 0...10, step: 1)
                    Image(systemName: "hand.thumbsup").font(.footnote).foregroundStyle(.secondary)
                }
            }
            LabeledField(title: "Was hilft beim nächsten Mal?") {
                RoundedTextField(placeholder: "…", text: $nextTimeText, isKeyboardActive: $isKeyboardActive)
            }
        }.padding(.top, 8)
    }
}

struct Category4Content: View {
    @Binding var shortReflection: String
    @FocusState.Binding var isKeyboardActive: Bool
    var body: some View {
        LabeledField(title: "Kurze Reflexion") {
            RoundedTextField(placeholder: "…", text: $shortReflection, isKeyboardActive: $isKeyboardActive)
        }.padding(.top, 8)
    }
}

// MARK: - Reusable Helpers (Die fehlenden Teile)

struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).foregroundColor(.black)
            content
        }
    }
}

struct SymptomRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.primary.opacity(0.9)).frame(width: 32, height: 32)
                    Circle().fill(isSelected ? Color.primary.opacity(0.15) : Color(.systemBackground)).frame(width: 11, height: 11)
                }
                Text(title).font(.body).foregroundStyle(.primary)
                Spacer()
            }
        }.buttonStyle(.plain)
    }
}

struct FeelingButton: View {
    let emoji: String; let label: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color.black : Color.clear, lineWidth: 2))
                        .frame(width: 66, height: 50)
                    Text(emoji).font(.system(size: 24))
                }
                Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
        }.buttonStyle(.plain)
    }
}

struct FeelingPlusButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)).frame(width: 66, height: 50)
                    .overlay(Image(systemName: "plus").font(.system(size: 20, weight: .semibold)).foregroundStyle(.primary.opacity(0.8)))
                Text("Hinzufügen").font(.caption2).foregroundStyle(.secondary)
            }
        }.buttonStyle(.plain)
    }
}
