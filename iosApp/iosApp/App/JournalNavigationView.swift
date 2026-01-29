import SwiftUI

enum AppRoute: Hashable {
    case journalEntry(date: Date)
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

    // ✅ Popup State: Datum + Bool (kein falscher Default-Header mehr)
    @State private var showJournalPopup = false
    @State private var popupDate: Date = Date()

    var body: some View {
        NavigationStack(path: $navigationPath) {

            Group {
                switch rootMode {

                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { date in
                            // ✅ Reihenfolge wichtig: erst Datum setzen, dann Sheet öffnen
                            popupDate = date
                            showJournalPopup = true
                        },
                        onCreateEntry: { date in
                            navigationPath.append(AppRoute.journalEntry(date: date))
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { date in
                            popupDate = date
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
        // ✅ Popup als Sheet
        .sheet(isPresented: $showJournalPopup) {
            JournalMainPopUpView(
                onEintragBearbeiten: {
                    showJournalPopup = false
                    navigationPath.append(AppRoute.journalEntry(date: popupDate))
                },
                onDismiss: {
                    showJournalPopup = false
                },
                dateHeader: makePopupHeader(from: popupDate)
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
                entryDate: date
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

    private func makePopupHeader(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE, dd.MM."
        return formatter.string(from: date).capitalized
    }
}
