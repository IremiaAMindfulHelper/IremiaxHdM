import SwiftUI
import UIKit

// Diese View stellt einen täglichen Selbstcheck dar: Stimmung wird auf einem 2D-Feld gewählt, Aktivitäten (Symbole oder Freitext) erfasst,
// Gesundheitswerte (Wasser, Schlaf) eingegeben und Notizen gespeichert. Unten führen Buttons zu Tagebuch und Panik-Reflexion für das Datum.
struct JournalEntryView: View {
    let onBack: () -> Void
    let onOpenDiary: (_ date: Date) -> Void
    let onOpenPanicReflexion: (_ date: Date) -> Void
    let entryDate: Date

    // ViewModel hält den Zustand (Stimmung/Lock, Aktivitäten, Texteingaben, etc.)
    @StateObject private var vm = JournalEntryViewModel()

    // Fokussteuerung für Eingabefelder (z.B. um Tastatur zu schließen und Default-Werte zu setzen)
    @FocusState private var focusedField: Field?

    // Identifikatoren für die fokussierbaren Felder
    enum Field: Hashable {
        case freeTextActivity
        case waterLiters
        case sleepHours
        case notes
    }

    // Kürzere Typnamen für Enums aus dem ViewModel
    private typealias ActivitySymbol = JournalEntryViewModel.ActivitySymbol
    private typealias ActivityMode = JournalEntryViewModel.ActivityMode

    // Datum für die Anzeige formatieren
    private var formattedDate: String { Self.entryDateFormatter.string(from: entryDate) }
    private static let entryDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "E. dd.MM.yy"
        return f
    }()

    // Layout-Konstanten
    private let screenHPadding: CGFloat = 20
    private let cardCorner: CGFloat = 18

    // Farbschema
    private let primaryBlue = Color(red: 0.42, green: 0.56, blue: 0.85)

    // Farben für die Stimmungsfläche (oben/unten/links/rechts)
    private let moodTop = Color(red: 0.55, green: 0.95, blue: 0.60)
    private let moodLeft = Color(red: 0.98, green: 0.45, blue: 0.45)
    private let moodRight = Color(red: 0.45, green: 0.60, blue: 1.00)
    private let moodBottom = Color(red: 0.98, green: 0.93, blue: 0.50)

    // Einheitliche Schrift für Abschnittsüberschriften
    private var sectionTitleFont: Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }

    // Hauptlayout: scrollbarer Inhalt mit Topbar, Stimmung, Aktivitäten, Gesundheit, Notizen und Navigation
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, screenHPadding)
                    .padding(.top, 10)

                moodCard
                    .padding(.horizontal, screenHPadding)
                    .padding(.top, 18)

                activitiesSection
                    .padding(.top, 22)

                healthSection
                    .padding(.top, 26)

                notesSection
                    .padding(.top, 22)

                bottomNavButtons
                    .padding(.top, 26)

                Spacer(minLength: 80)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .onTapGesture { focusedField = nil }
        .onChange(of: focusedField) { applyDefaultNumberBehavior() }
        .toolbar { keyboardToolbar }
    }

    // Kopfbereich: Zurück-Button links, Titel und Datum zentriert
    private var topBar: some View {
        ZStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.80))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.black.opacity(0.05)))
                }
                .buttonStyle(.plain)

                Spacer()
            }

            VStack(spacing: 2) {
                Text("Selbstcheck")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.85))

                Text(formattedDate)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.55))
            }
        }
    }

    // Karte für die Stimmungs-Auswahl: Überschrift + Lock-Button + Koordinatensystem mit draggable Punkt
    private var moodCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Gib deine Stimmung an")
                    .font(sectionTitleFont)
                    .foregroundStyle(.black.opacity(0.55))

                Spacer()

                lockButton
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            moodCoordinateSystem
                .frame(height: 260)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }

    // Sperrt/entsperrt das Verschieben des Mood-Balls
    private var lockButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.toggleLock()
            }
        } label: {
            Image(systemName: vm.isLocked ? "lock.fill" : "lock.open")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.black.opacity(0.65))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.black.opacity(0.05)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(vm.isLocked ? "Stimmung gesperrt" : "Stimmung entsperrt")
    }

    // Koordinatensystem mit 4-Farben-Gradient, Achsen, Labels und dem Mood-Ball
    private var moodCoordinateSystem: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2

            // Abstand, den der Ball maximal in X/Y Richtung laufen darf (Padding für Rand/Labels)
            let maxDistanceX: CGFloat = centerX - 62
            let maxDistanceY: CGFloat = centerY - 62

            ZStack {
                // Hintergrundgradient wird weich über eine Maske in einen Kreis geschnitten
                moodBackgroundGradientCircle
                    .blur(radius: 10)
                    .saturation(2.6)
                    .contrast(1.35)
                    .brightness(0.04)
                    .opacity(1.0)
                    .mask {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(1.0),
                                        Color.white.opacity(1.0),
                                        Color.white.opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: min(geo.size.width, geo.size.height) * 0.52
                                )
                            )
                    }
                    .compositingGroup()
                    .padding(8)

                axes(centerX: centerX, centerY: centerY, size: geo.size)
                moodLabels(centerX: centerX, centerY: centerY, size: geo.size)
                moodBall(centerX: centerX, centerY: centerY, maxX: maxDistanceX, maxY: maxDistanceY)
            }
        }
    }

    // AngularGradient verteilt die 4 Stimmungsfarben gleichmäßig über die Quadranten
    private var moodBackgroundGradientCircle: some View {
        AngularGradient(
            stops: [
                .init(color: moodTop,    location: 0.00),
                .init(color: moodRight,  location: 0.25),
                .init(color: moodBottom, location: 0.50),
                .init(color: moodLeft,   location: 0.75),
                .init(color: moodTop,    location: 1.00)
            ],
            center: .center,
            angle: .degrees(-90)
        )
    }

    // Zeichnet die X- und Y-Achse im Koordinatensystem
    private func axes(centerX: CGFloat, centerY: CGFloat, size: CGSize) -> some View {
        Path { path in
            path.move(to: CGPoint(x: centerX, y: 48))
            path.addLine(to: CGPoint(x: centerX, y: size.height - 48))

            path.move(to: CGPoint(x: 44, y: centerY))
            path.addLine(to: CGPoint(x: size.width - 44, y: centerY))
        }
        .stroke(Color.black.opacity(0.70), lineWidth: 1.4)
    }

    // Beschriftungen an den vier Seiten: oben/unten Energie, links/rechts Stimmung
    private func moodLabels(centerX: CGFloat, centerY: CGFloat, size: CGSize) -> some View {
        ZStack {
            VStack(spacing: 4) {
                Text("energiegeladen")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.65))
            }
            .position(x: centerX, y: 20)

            VStack(spacing: 4) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.65))
                Text("müde")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
            }
            .position(x: centerX, y: size.height - 20)

            VStack(spacing: 2) {
                Text("😔").font(.system(size: 16))
                Text("deprimiert")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
            }
            .position(x: 26, y: centerY)

            VStack(spacing: 2) {
                Text("😃").font(.system(size: 16))
                Text("fröhlich")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.65))
            }
            .position(x: size.width - 26, y: centerY)
        }
    }

    // Der Punkt, der die aktuelle Stimmung repräsentiert, inklusive Farbe und Drag-Geste
    private func moodBall(centerX: CGFloat, centerY: CGFloat, maxX: CGFloat, maxY: CGFloat) -> some View {
        let currentColor = moodColorAtPosition(vm.ballPosition)

        return Circle()
            .fill(currentColor.opacity(0.35))
            .overlay(
                Circle().stroke(Color.black.opacity(0.45), lineWidth: 2)
            )
            .frame(width: 34, height: 34)
            .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
            .position(
                x: centerX + vm.ballPosition.x * maxX,
                y: centerY - vm.ballPosition.y * maxY
            )
            .gesture(vm.isLocked ? nil : moodDragGesture(centerX: centerX, centerY: centerY, maxX: maxX, maxY: maxY))
            .opacity(vm.isLocked ? 0.75 : 1.0)
    }

    // Normalisiert Drag-Position auf Wertebereich [-1, 1] und speichert sie im ViewModel
    private func moodDragGesture(centerX: CGFloat, centerY: CGFloat, maxX: CGFloat, maxY: CGFloat) -> some Gesture {
        DragGesture().onChanged { value in
            let deltaX = value.location.x - centerX
            let deltaY = centerY - value.location.y

            var nx = deltaX / maxX
            var ny = deltaY / maxY
            nx = max(-1.0, min(1.0, nx))
            ny = max(-1.0, min(1.0, ny))
            vm.ballPosition = CGPoint(x: nx, y: ny)
        }
    }

    // Ermittelt aus der Ball-Position eine Mischfarbe zwischen den vier Randfarben
    private func moodColorAtPosition(_ p: CGPoint) -> Color {
        let tx = (p.x + 1) / 2
        let ty = (1 - p.y) / 2

        let lr = moodLeft.mixed(with: moodRight, t: tx)
        let tb = moodTop.mixed(with: moodBottom, t: ty)
        return lr.mixed(with: tb, t: 0.5)
    }

    // Aktivitäten: Umschalter zwischen Symbolauswahl und Freitext
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Deine Aktivitäten")
                .font(sectionTitleFont)
                .foregroundStyle(.black.opacity(0.55))
                .padding(.horizontal, screenHPadding)

            SegmentedPill(
                leftTitle: "Symbole",
                rightTitle: "Freitext",
                selection: $vm.activityMode,
                leftValue: .symbols,
                rightValue: .freetext,
                activeColor: primaryBlue
            )
            .padding(.horizontal, screenHPadding)
            .padding(.top, 12)

            if vm.activityMode == .symbols {
                symbolsGrid
                    .padding(.horizontal, screenHPadding)
                    .padding(.top, 16)
            } else {
                freeTextEditor
                    .padding(.top, 16)
            }
        }
    }

    // Grid mit auswählbaren Aktivitäts-Symbolen (plus-Kachel als Platzhalter für später)
    private var symbolsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(ActivitySymbol.allCases) { activity in
                ActivityTile(
                    title: activity.label,
                    systemImage: activity.rawValue,
                    isSelected: vm.selectedActivities.contains(activity),
                    onTap: { vm.toggleActivity(activity) }
                )
            }

            ActivityTile(
                title: "",
                systemImage: "plus",
                isSelected: false,
                onTap: {}
            )
        }
    }

    // Freitext-Eingabe für Aktivitäten inkl. Placeholder
    private var freeTextEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $vm.freeTextActivity)
                .focused($focusedField, equals: .freeTextActivity)
                .frame(height: 150)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, screenHPadding)

            if vm.freeTextActivity.isEmpty {
                Text("Was hast du heute gemacht?")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.black.opacity(0.35))
                    .padding(.horizontal, screenHPadding + 14)
                    .padding(.top, 18)
                    .allowsHitTesting(false)
            }
        }
    }

    // Gesundheitstracker: Wasser (dezimal) und Schlaf (ganzzahlig) als zwei Eingabespalten
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Gesundheitstracker")
                .font(sectionTitleFont)
                .foregroundStyle(.black.opacity(0.55))
                .padding(.horizontal, screenHPadding)

            HStack(spacing: 40) {
                HealthInputColumn(
                    icon: "waterbottle",
                    text: $vm.waterLiters,
                    unit: "Liter",
                    keyboardType: .decimalPad,
                    focusedField: $focusedField,
                    field: .waterLiters
                )

                HealthInputColumn(
                    icon: "bed.double",
                    text: $vm.sleepHours,
                    unit: "Stunden",
                    keyboardType: .numberPad,
                    focusedField: $focusedField,
                    field: .sleepHours
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, screenHPadding)
        }
    }

    // Notizen: kurzer Textbereich
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notizen")
                .font(sectionTitleFont)
                .foregroundStyle(.black.opacity(0.55))
                .padding(.horizontal, screenHPadding)

            TextEditor(text: $vm.notes)
                .focused($focusedField, equals: .notes)
                .frame(height: 74)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.black.opacity(0.18), lineWidth: 1.5)
                )
                .padding(.horizontal, screenHPadding)
        }
    }

    // Navigation: Buttons öffnen Tagebuch oder Panik-Reflexion für das aktuelle Datum
    private var bottomNavButtons: some View {
        HStack(spacing: 14) {
            Button { onOpenDiary(entryDate) } label: {
                Text("Tagebuch")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(primaryBlue)
                    )
            }
            .buttonStyle(.plain)

            Button { onOpenPanicReflexion(entryDate) } label: {
                Text("Panik Reflexion")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.60))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.99, green: 0.88, blue: 0.55))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, screenHPadding)
    }

    // Toolbar über der Tastatur: schließt den Fokus (damit Tastatur verschwindet)
    @ToolbarContentBuilder
    private var keyboardToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Fertig") { focusedField = nil }
        }
    }

    // Setzt Default-Werte für numerische Felder: beim Fokus "0" leeren, beim Verlassen leere Eingabe wieder zu "0"
    private func applyDefaultNumberBehavior() {
        if focusedField == .waterLiters, vm.waterLiters == "0" { vm.waterLiters = "" }
        if focusedField == .sleepHours, vm.sleepHours == "0" { vm.sleepHours = "" }

        if focusedField != .waterLiters, vm.waterLiters.trimmed.isEmpty { vm.waterLiters = "0" }
        if focusedField != .sleepHours, vm.sleepHours.trimmed.isEmpty { vm.sleepHours = "0" }
    }
}

// Segmented Control im Pill-Style: zwei Buttons, die einen generischen Selection-Wert umschalten
private struct SegmentedPill<T: Hashable>: View {
    let leftTitle: String
    let rightTitle: String
    @Binding var selection: T
    let leftValue: T
    let rightValue: T
    let activeColor: Color

    var body: some View {
        HStack(spacing: 0) {
            segButton(title: leftTitle, isActive: selection == leftValue) { selection = leftValue }
            segButton(title: rightTitle, isActive: selection == rightValue) { selection = rightValue }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.05))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // Einzelner Segment-Button, der je nach Aktivzustand anders eingefärbt wird
    private func segButton(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(isActive ? .white : .black.opacity(0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isActive ? activeColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// Kachel für ein Aktivitäts-Symbol (auswählbar)
private struct ActivityTile: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.black.opacity(0.80))

                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.65))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 86)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.black.opacity(0.18) : Color.black.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.black.opacity(0.75) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// Spalte für eine Health-Eingabe: Icon, TextField, Einheit
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
                .foregroundColor(.black.opacity(0.75))

            TextField("", text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .frame(width: 110)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: field)

            Text(unit)
                .font(.caption)
                .foregroundColor(.black.opacity(0.45))
        }
    }
}

// Hilfsfunktion: Whitespace entfernen, um "leer" sauber prüfen zu können
private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

// Mischt zwei SwiftUI-Colors linear, indem beide in UIColor zerlegt und dann interpoliert werden
private extension Color {
    func mixed(with other: Color, t: CGFloat) -> Color {
        let t = max(0, min(1, t))
        let c1 = UIColor(self).rgba
        let c2 = UIColor(other).rgba

        return Color(
            red: c1.r + (c2.r - c1.r) * t,
            green: c1.g + (c2.g - c1.g) * t,
            blue: c1.b + (c2.b - c1.b) * t,
            opacity: c1.a + (c2.a - c1.a) * t
        )
    }
}

// Hilfsfunktion: extrahiert RGBA-Komponenten aus UIColor
private extension UIColor {
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
