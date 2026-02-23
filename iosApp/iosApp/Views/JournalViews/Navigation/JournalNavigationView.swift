import SwiftUI

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

    // Eine einzige Kalenderansicht. Der Toggle in JournalMainView schaltet rootMode um,
    // aber wir bleiben auf derselben Seite.
    private var rootContent: some View {
        JournalMainView(
            rootMode: $rootMode,

            // Stimmung: Mood-Gradient-Tage öffnen Mood-Popup
            onPlusButtonTappedMood: { date, mark in
                let kind: JournalPopupKind = (mark == .moodGradientA) ? .moodA : .moodB
                popupItem = JournalPopupItem(date: date, kind: kind)
            },

            // Panik: Broken-Heart-Tage öffnen Panic-Popup
            onPlusButtonTappedPanic: { date in
                popupItem = JournalPopupItem(date: date, kind: .panic)
            },

            // Plus-Tage: Eintrag erstellen/öffnen
            onCreateEntry: { date in
                navigationPath.append(AppRoute.journalEntry(date: date))
            }
        )
    }

    // Baut das Popup-Sheet mit Header und Chip-Style.
    private func popupSheet(for item: JournalPopupItem) -> some View {
        let header = JournalPopupStyleProvider.headerFormatter.string(from: item.date).capitalized
        let style = JournalPopupStyleProvider.style(for: item.kind, date: item.date)

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
}
