import SwiftUI

enum AppRoute: Hashable {
    case journalEntry(date: Date)
    case journalDiaryView(date: Date)
    case panicReflection(date: Date)   // ✅ Datum rein
    case questionCatalog
}


enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

// ✅ Welche “Art” Popup wird angezeigt?
enum JournalPopupKind: Hashable {
    case moodA   // rot/blau
    case moodB   // grün/blau
    case panic   // broken heart (soll aber gleichen Chip wie Emotionen kriegen)
}

// ✅ Identifiable Item für sheet(item:)
struct JournalPopupItem: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let kind: JournalPopupKind
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var rootMode: JournalRootMode = .emotions

    // ✅ stabiler Popup-State
    @State private var popupItem: JournalPopupItem? = nil

    var body: some View {
        NavigationStack(path: $navigationPath) {

            Group {
                switch rootMode {

                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { date, mark in
                            // mark kommt aus Emotions-View (.moodGradientA / .moodGradientB)
                            let kind: JournalPopupKind = (mark == .moodGradientA) ? .moodA : .moodB
                            popupItem = JournalPopupItem(date: date, kind: kind)
                        },
                        onCreateEntry: { date in
                            navigationPath.append(AppRoute.journalEntry(date: date))
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { date in
                            popupItem = JournalPopupItem(date: date, kind: .panic)
                        },
                        onCreateEntry: { date in
                            navigationPath.append(AppRoute.journalEntry(date: date))
                        }
                    )
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
        // ✅ Popup als Sheet
        .sheet(item: $popupItem) { item in
            let header = makePopupHeader(from: item.date)
            let style = popupStyle(for: item.kind, date: item.date)

            JournalMainPopUpView(
                onEintragBearbeiten: {
                    let date = item.date
                    popupItem = nil
                    navigationPath.append(AppRoute.journalEntry(date: date))
                },
                onDismiss: {
                    popupItem = nil
                },
                dateHeader: header,
                chipText: style.chipText,
                chipGradient: style.gradient
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.white)
        }
    }

    private func safePop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {

        case .journalEntry(let date):
            JournalEntryView(
                onBack: { safePop() },
                onOpenDiary: { diaryDate in
                    navigationPath.append(AppRoute.journalDiaryView(date: diaryDate))
                },
                onOpenPanicReflexion: { panicDate in
                    navigationPath.append(AppRoute.panicReflection(date: panicDate))
                },
                entryDate: date
            )

        case .journalDiaryView(let date):
            JournalDiaryView(
                onBack: { safePop() },
                onOpenQuestionCatalog: { navigationPath.append(AppRoute.questionCatalog) },
                entryDate: date
            )

        case .panicReflection(let date):
            PanicReflexion(
                onBack: { safePop() },
                entryDate: date
            )

        case .questionCatalog:
            QuestionCatalog(onBack: { safePop() })
        }
    }


    private func makePopupHeader(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter.string(from: date).capitalized
    }

    // ✅ Panic soll exakt den gleichen Chip-Style bekommen wie Emotionen (Demo: 6 -> moodA, 7 -> moodB)
    private func popupStyle(
        for kind: JournalPopupKind,
        date: Date
    ) -> (chipText: String, gradient: LinearGradient) {

        func moodA() -> (String, LinearGradient) {
            (
                "deprimiert, fröhlich",
                LinearGradient(
                    colors: [Color.red.opacity(0.95), Color.blue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        func moodB() -> (String, LinearGradient) {
            (
                "energiegeladen, fröhlich",
                LinearGradient(
                    colors: [Color.green.opacity(0.95), Color.blue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        switch kind {
        case .moodA:
            return moodA()

        case .moodB:
            return moodB()

        case .panic:
            // ✅ gleiche Darstellung wie Emotionen (für Demo anhand Tag)
            let cal = Calendar(identifier: .gregorian)
            let day = cal.component(.day, from: date)

            if day == 6 { return moodA() }
            if day == 7 { return moodB() }

            // Default: nimm moodB (oder moodA – wie du willst)
            return moodB()
        }
    }
}
