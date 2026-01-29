import SwiftUI

struct JournalEntryView: View {

    let onBack: () -> Void
    let onOpenDiary: () -> Void
    let onOpenPanicReflexion: () -> Void

    /// ✅ Datum kommt vom Kalender
    let entryDate: Date

    @State private var ballPosition = CGPoint(x: 0, y: 0)
    @State private var isLocked = false
    @State private var activityMode: ActivityMode = .symbols
    @State private var selectedActivities: Set<ActivitySymbol> = []
    @State private var freeTextActivity: String = ""

    // ✅ Wasser jetzt in LITERN (z.B. 1 / 0.5 / 0.75)
    @State private var waterLiters: String = "0"

    @State private var sleepHours: String = "0"
    @State private var notes: String = ""

    // ✅ Keyboard focus
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
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

    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .frame(width: 40, alignment: .leading)

                Spacer()

                Text(formattedDate)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Color.clear.frame(width: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Divider()
        }
    }

    /// ✅ formatiert jetzt entryDate
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd.MM.yy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: entryDate)
    }

    private var lockButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLocked.toggle()
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }

    // MARK: - Mood Coordinate System
    private var moodCoordinateSystem: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let maxDistanceX: CGFloat = centerX - 70
            let maxDistanceY: CGFloat = centerY - 70

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: 70))
                    path.addLine(to: CGPoint(x: centerX, y: geo.size.height - 70))

                    path.move(to: CGPoint(x: 60, y: centerY))
                    path.addLine(to: CGPoint(x: geo.size.width - 60, y: centerY))
                }
                .stroke(Color.black, lineWidth: 2)

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
                .position(x: centerX, y: geo.size.height - 25)

                HStack(spacing: 4) {
                    VStack(spacing: 2) {
                        Text("😔")
                            .font(.system(size: 16))
                        Text("deprimiert")
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .offset(y: 6)
                    }
                }
                .position(x: 40, y: centerY)

                HStack(spacing: 4) {
                    VStack(spacing: 2) {
                        Text("😃")
                            .font(.system(size: 16))
                        Text("fröhlich")
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .offset(y: 6)
                    }
                }
                .position(x: geo.size.width - 40, y: centerY)

                Circle()
                    .frame(width: 30, height: 30)
                    .shadow(radius: 6, y: 2)
                    .overlay(
                        isLocked ?
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        : nil
                    )
                    .position(
                        x: centerX + ballPosition.x * maxDistanceX,
                        y: centerY - ballPosition.y * maxDistanceY
                    )
                    .gesture(
                        isLocked ? nil :
                            DragGesture()
                                .onChanged { value in
                                    let deltaX = value.location.x - centerX
                                    let deltaY = centerY - value.location.y

                                    var normalizedX = deltaX / maxDistanceX
                                    var normalizedY = deltaY / maxDistanceY

                                    normalizedX = max(-1.0, min(1.0, normalizedX))
                                    normalizedY = max(-1.0, min(1.0, normalizedY))

                                    ballPosition = CGPoint(x: normalizedX, y: normalizedY)
                                }
                    )
                    .opacity(isLocked ? 0.7 : 1.0)
            }
        }
    }

    // MARK: - Main View
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView

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

                // MARK: - Activities Section
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
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(ActivitySymbol.allCases) { activity in
                            Button(action: {
                                if selectedActivities.contains(activity) {
                                    selectedActivities.remove(activity)
                                } else {
                                    selectedActivities.insert(activity)
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: activity.rawValue)
                                        .font(.system(size: 24))
                                        .foregroundColor(.primary)
                                    Text(activity.label)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(selectedActivities.contains(activity) ? Color.black.opacity(0.2) : Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedActivities.contains(activity) ? Color.black : Color.clear, lineWidth: 2)
                                )
                            }
                        }

                        Button(action: {
                            // TODO: Add new activity functionality
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary, lineWidth: 1)
                                    .opacity(0.3)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                if activityMode == .freetext {
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
                    .padding(.top, 16)
                }

                // MARK: - Health Tracker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gesundheitstracker")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)

                    HStack(spacing: 40) {
                        // ✅ WATER (Liter statt ml)
                        VStack(spacing: 8) {
                            Text("\(waterLiters) Liter")
                                .font(.caption)
                                .foregroundColor(.primary)

                            Image(systemName: "waterbottle")
                                .font(.system(size: 40))
                                .foregroundColor(.primary)

                            HStack(spacing: 4) {
                                TextField("Liter", text: $waterLiters)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .waterLiters)
                            }
                        }

                        // ✅ SLEEP
                        VStack(spacing: 8) {
                            Text("\(sleepHours) Stunden")
                                .font(.caption)
                                .foregroundColor(.primary)

                            Image(systemName: "bed.double")
                                .font(.system(size: 40))
                                .foregroundColor(.primary)

                            HStack(spacing: 4) {
                                TextField("h", text: $sleepHours)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.center)
                                    .focused($focusedField, equals: .sleepHours)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                }

                // MARK: - Notes
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

                // MARK: - Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: onOpenDiary) {
                        ZStack(alignment: .bottomTrailing) {
                            Text("Tagebuch")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("4/6")
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
                    .foregroundColor(.primary)

                    Button(action: onOpenPanicReflexion) {
                        ZStack(alignment: .bottomTrailing) {
                            Text("Panik Reflexion")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("5/6")
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
                    .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Journal")
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    focusedField = nil
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        JournalEntryView(
            onBack: {},
            onOpenDiary: {},
            onOpenPanicReflexion: {},
            entryDate: Date()
        )
    }
}
