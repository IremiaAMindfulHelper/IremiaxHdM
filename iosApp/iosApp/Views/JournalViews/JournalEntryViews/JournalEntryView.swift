import SwiftUI

struct JournalEntryView: View {
    let onBack: () -> Void
    let onOpenDiary: (_ date: Date) -> Void
    let onOpenPanicReflexion: (_ date: Date) -> Void
    let entryDate: Date

    // Speichert die aktuelle Stimmung als normalisierte X/Y-Position (-1...1).
    @State private var ballPosition = CGPoint(x: 0, y: 0)

    // Sperrt das Verschieben der Stimmungskugel.
    @State private var isLocked = false

    // Umschalter zwischen Symbol-Auswahl und Freitext.
    @State private var activityMode: ActivityMode = .symbols

    // Speichert ausgewählte Aktivitäts-Symbole.
    @State private var selectedActivities: Set<ActivitySymbol> = []

    // Freitext-Aktivität, wenn der Modus auf Freitext steht.
    @State private var freeTextActivity: String = ""

    // Eingaben für Wasser und Schlaf (als String für TextFields).
    @State private var waterLiters: String = "0"
    @State private var sleepHours: String = "0"

    // Kurze Notizen zum Tag.
    @State private var notes: String = ""

    // Steuert Fokus (Keyboard) für verschiedene Felder.
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case freeTextActivity
        case waterLiters
        case sleepHours
        case notes
    }

    enum ActivitySymbol: String, CaseIterable, Identifiable {
        case football = "soccerball"
        case university = "graduationcap"
        case shopping = "cart"
        case train = "tram"

        var id: String { rawValue }

        var label: String {
            switch self {
            case .football: return "Fußball"
            case .university: return "Uni"
            case .shopping: return "Einkaufen"
            case .train: return "Zug"
            }
        }
    }

    enum ActivityMode: String, CaseIterable {
        case symbols = "Symbole"
        case freetext = "Freitext"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                selfCheckHeader
                activitiesSection
                healthSection
                notesSection
                bottomNavButtons
                Spacer(minLength: 100)
            }
        }
        .background(Color.white)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onTapGesture { focusedField = nil }
        .onChange(of: focusedField) {
            applyDefaultNumberBehavior()
        }
    }

    // Formatiert das Datum für die Toolbar.
    private var formattedDate: String {
        Self.entryDateFormatter.string(from: entryDate)
    }

    private static let entryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "E dd.MM.yy"
        return formatter
    }()

    // Baut die Toolbar (Back + Titel/Datum + Keyboard Done).
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
            }
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 2) {
                Text("Tagescheck")
                    .font(.headline)
                    .foregroundColor(.black)

                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
            }
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") { focusedField = nil }
        }
    }

    // Zeigt Überschrift + Mood-Coordinate-System inkl. Lock-Button.
    private var selfCheckHeader: some View {
        VStack(spacing: 0) {
            Text("Selbstcheck")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)

            HStack {
                Text("Stimmung")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                lockButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            moodCoordinateSystem
                .frame(height: 400)
                .padding(.horizontal, 20)
                .padding(.top, 20)
        }
    }

    // Sperrt/entsperrt das Verschieben der Kugel.
    private var lockButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLocked.toggle()
            }
        } label: {
            Image(systemName: isLocked ? "lock.fill" : "lock.open")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }

    // Zeichnet Achsen, Labels und die verschiebbare Stimmungskugel.
    private var moodCoordinateSystem: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let maxDistanceX: CGFloat = centerX - 70
            let maxDistanceY: CGFloat = centerY - 70

            ZStack {
                axes(centerX: centerX, centerY: centerY, size: geo.size)
                moodLabels(centerX: centerX, centerY: centerY, size: geo.size)
                moodBall(centerX: centerX, centerY: centerY, maxX: maxDistanceX, maxY: maxDistanceY)
            }
        }
    }

    // Zeichnet das Kreuz (X/Y Achsen).
    private func axes(centerX: CGFloat, centerY: CGFloat, size: CGSize) -> some View {
        Path { path in
            path.move(to: CGPoint(x: centerX, y: 70))
            path.addLine(to: CGPoint(x: centerX, y: size.height - 70))

            path.move(to: CGPoint(x: 60, y: centerY))
            path.addLine(to: CGPoint(x: size.width - 60, y: centerY))
        }
        .stroke(Color.black, lineWidth: 2)
    }

    // Platziert die vier Stimmungs-Labels rund um die Achsen.
    private func moodLabels(centerX: CGFloat, centerY: CGFloat, size: CGSize) -> some View {
        ZStack {
            VStack(spacing: 4) {
                Text("energiegeladen")
                    .font(.system(size: 12, weight: .medium))
                Image(systemName: "bolt.fill")
                    .font(.system(size: 16))
            }
            .position(x: centerX, y: 25)

            VStack(spacing: 4) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 16))
                Text("müde")
                    .font(.system(size: 12, weight: .medium))
            }
            .position(x: centerX, y: size.height - 25)

            VStack(spacing: 2) {
                Text("😔").font(.system(size: 16))
                Text("deprimiert")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .offset(y: 6)
            }
            .position(x: 40, y: centerY)

            VStack(spacing: 2) {
                Text("😃").font(.system(size: 16))
                Text("fröhlich")
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .offset(y: 6)
            }
            .position(x: size.width - 40, y: centerY)
        }
    }

    // Zeigt die Kugel an der passenden Position und erlaubt Dragging (wenn nicht gesperrt).
    private func moodBall(centerX: CGFloat, centerY: CGFloat, maxX: CGFloat, maxY: CGFloat) -> some View {
        Circle()
            .frame(width: 30, height: 30)
            .shadow(radius: 6, y: 2)
            .overlay {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            .position(
                x: centerX + ballPosition.x * maxX,
                y: centerY - ballPosition.y * maxY
            )
            .gesture(isLocked ? nil : moodDragGesture(centerX: centerX, centerY: centerY, maxX: maxX, maxY: maxY))
            .opacity(isLocked ? 0.7 : 1.0)
    }

    // Normalisiert Drag-Input in den Bereich -1...1.
    private func moodDragGesture(centerX: CGFloat, centerY: CGFloat, maxX: CGFloat, maxY: CGFloat) -> some Gesture {
        DragGesture().onChanged { value in
            let deltaX = value.location.x - centerX
            let deltaY = centerY - value.location.y

            var normalizedX = deltaX / maxX
            var normalizedY = deltaY / maxY

            normalizedX = max(-1.0, min(1.0, normalizedX))
            normalizedY = max(-1.0, min(1.0, normalizedY))

            ballPosition = CGPoint(x: normalizedX, y: normalizedY)
        }
    }

    // Zeigt Aktivitätsmodus + Symbolgrid oder Freitext.
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Aktivitäten")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)

            Picker("Aktivitätsmodus", selection: $activityMode) {
                ForEach(ActivityMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if activityMode == .symbols {
                symbolsGrid
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
            } else {
                freeTextEditor
                    .padding(.top, 16)
            }
        }
    }

    // Grid zum Auswählen von Aktivitäten per Icon.
    private var symbolsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(ActivitySymbol.allCases) { activity in
                ActivityTile(
                    title: activity.label,
                    systemImage: activity.rawValue,
                    isSelected: selectedActivities.contains(activity),
                    onTap: { toggleActivity(activity) }
                )
            }

            ActivityTile(
                title: "",
                systemImage: "plus",
                isSelected: false,
                onTap: {}
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 1)
                    .opacity(0.3)
            )
        }
    }

    // Schaltet ein Symbol an/aus in der Auswahl.
    private func toggleActivity(_ activity: ActivitySymbol) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }

    // Freitext-Eingabe für Aktivitäten inkl. Placeholder.
    private var freeTextEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $freeTextActivity)
                .focused($focusedField, equals: .freeTextActivity)
                .frame(height: 200)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )

            if freeTextActivity.isEmpty {
                Text("Was hast du heute gemacht?")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 20)
    }

    // Eingabefelder für Wasser und Schlaf.
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gesundheitstracker")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.top, 40)

            HStack(spacing: 40) {
                HealthInputColumn(
                    icon: "waterbottle",
                    text: $waterLiters,
                    unit: "Liter",
                    keyboardType: UIKeyboardType.decimalPad,
                    focusedField: $focusedField,
                    field: .waterLiters
                )

                HealthInputColumn(
                    icon: "bed.double",
                    text: $sleepHours,
                    unit: "Stunden",
                    keyboardType: UIKeyboardType.numberPad,
                    focusedField: $focusedField,
                    field: .sleepHours
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
    }

    // Kurze Notizen als TextEditor.
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notizen")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            TextEditor(text: $notes)
                .focused($focusedField, equals: .notes)
                .frame(height: 60)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        }
    }

    // Buttons zum Wechseln in Tagebuch und Panik-Reflexion.
    private var bottomNavButtons: some View {
        HStack(spacing: 16) {
            Button { onOpenDiary(entryDate) } label: {
                NavButtonLabel(title: "Tagebuch", progress: "4/6")
            }

            Button { onOpenPanicReflexion(entryDate) } label: {
                NavButtonLabel(title: "Panik Reflexion", progress: "5/6")
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // Setzt Default-Werte für Zahlfelder beim Fokus rein/raus.
    private func applyDefaultNumberBehavior() {
        if focusedField == .waterLiters, waterLiters == "0" { waterLiters = "" }
        if focusedField == .sleepHours, sleepHours == "0" { sleepHours = "" }

        if focusedField != .waterLiters, waterLiters.trimmed.isEmpty { waterLiters = "0" }
        if focusedField != .sleepHours, sleepHours.trimmed.isEmpty { sleepHours = "0" }
    }
}

private struct ActivityTile: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(.primary)

                if title.isEmpty == false {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.black.opacity(0.2) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HealthInputColumn: View {
    let icon: String
    @Binding var text: String
    let unit: String
    let keyboardType: UIKeyboardType
    @FocusState.Binding var focusedField: JournalEntryView.Field?
    let field: JournalEntryView.Field

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.primary)

            TextField("", text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: field)

            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct NavButtonLabel: View {
    let title: String
    let progress: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(progress)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    NavigationStack {
        JournalEntryView(
            onBack: {},
            onOpenDiary: { _ in },
            onOpenPanicReflexion: { _ in },
            entryDate: Date()
        )
    }
}
