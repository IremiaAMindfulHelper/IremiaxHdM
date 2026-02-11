import SwiftUI

enum AppRoute: Hashable {
    case journalEntry(date: Date)
    case journalDiaryView(date: Date)
    case panicReflection(date: Date)
    case questionCatalog
}

enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

enum JournalPopupKind: Hashable {
    case moodA
    case moodB
    case panic
}

struct JournalPopupItem: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let kind: JournalPopupKind
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var rootMode: JournalRootMode = .emotions

    // Steuert, ob ein Popup-Sheet angezeigt wird und welche Daten es bekommt.
    @State private var popupItem: JournalPopupItem?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            rootContent
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .sheet(item: $popupItem) { item in
            popupSheet(for: item)
        }
    }

    // Zeigt abhängig vom Root-Mode die passende Kalenderansicht.
    private var rootContent: some View {
        Group {
            switch rootMode {
            case .emotions:
                JournalMainViewEmotions(
                    rootMode: $rootMode,
                    onPlusButtonTapped: { date, mark in
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
    }

    // Baut das Popup-Sheet mit Header und Chip-Style.
    private func popupSheet(for item: JournalPopupItem) -> some View {
        let header = Self.popupHeaderFormatter.string(from: item.date).capitalized
        let style = popupStyle(for: item.kind, date: item.date)

        return JournalMainPopUpView(
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

    // Navigiert einen Schritt zurück, wenn möglich.
    private func safePop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    // Liefert die View für eine Route im NavigationStack.
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

    // Formatiert den Header-Text für das Popup.
    private static let popupHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter
    }()

    // Liefert den Text und den Farbverlauf für den Chip im Popup.
    private func popupStyle(
        for kind: JournalPopupKind,
        date: Date
    ) -> (chipText: String, gradient: LinearGradient) {

        func moodAStyle() -> (String, LinearGradient) {
            (
                "deprimiert, fröhlich",
                LinearGradient(
                    colors: [Color.red.opacity(0.95), Color.blue.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        func moodBStyle() -> (String, LinearGradient) {
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
            return moodAStyle()

        case .moodB:
            return moodBStyle()

        case .panic:
            let day = Calendar(identifier: .gregorian).component(.day, from: date)
            if day == 6 { return moodAStyle() }
            if day == 7 { return moodBStyle() }
            return moodBStyle()
        }
    }
}
