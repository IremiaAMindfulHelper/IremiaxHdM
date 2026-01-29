import SwiftUI

enum AppRoute: Hashable {
    case journalEntry(date: Date)   // ✅ Datum mit Route
    case journalDiaryView
    case panicReflection
    case questionCatalog
}

enum JournalRootMode: Hashable {
    case emotions
    case panicAttacks
}

struct JournalNavigationView: View {
    @State private var navigationPath = NavigationPath()
    @State private var rootMode: JournalRootMode = .emotions

    // ✅ Popup State
    @State private var showJournalPopup = false
    @State private var popupDateHeader: String = "Mittwoch, 20.01."

    var body: some View {
        NavigationStack(path: $navigationPath) {

            Group {
                switch rootMode {
                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { header in
                            popupDateHeader = header
                            showJournalPopup = true
                        },
                        onCreateEntry: { date in
                            navigationPath.append(AppRoute.journalEntry(date: date))
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { header in
                            popupDateHeader = header
                            showJournalPopup = true
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
        // ✅ Popup als Sheet => TabBar ist weg
        .sheet(isPresented: $showJournalPopup) {
            JournalMainPopUpView(
                onEintragBearbeiten: {
                    // Wenn du hier auch ein Datum brauchst, müsste das Popup das Datum (Date) liefern.
                    // Aktuell hast du nur einen String header -> deshalb lassen wir es wie vorher.
                    showJournalPopup = false
                    // navigationPath.append(AppRoute.journalEntry(date: Date()))
                },
                onDismiss: {
                    showJournalPopup = false
                },
                dateHeader: popupDateHeader
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
                onOpenDiary: { navigationPath.append(AppRoute.journalDiaryView) },
                onOpenPanicReflexion: { navigationPath.append(AppRoute.panicReflection) },
                entryDate: date // ✅ Datum oben anzeigen
            )

        case .journalDiaryView:
            JournalDiaryView(
                onBack: { safePop() },
                onOpenQuestionCatalog: { navigationPath.append(AppRoute.questionCatalog) }
            )

        case .panicReflection:
            PanicReflexion(onBack: { safePop() })

        case .questionCatalog:
            QuestionCatalog(onBack: { safePop() })
        }
    }
}
