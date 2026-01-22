import SwiftUI

enum AppRoute: Hashable {
    case journalEntry
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
                        onCreateEntry: {
                            navigationPath.append(AppRoute.journalEntry)
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: { header in
                            popupDateHeader = header
                            showJournalPopup = true
                        },
                        onCreateEntry: {
                            navigationPath.append(AppRoute.journalEntry)
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
                    showJournalPopup = false
                    navigationPath.append(AppRoute.journalEntry)
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
        case .journalEntry:
            JournalEntryView(
                onBack: { safePop() },
                onOpenDiary: { navigationPath.append(AppRoute.journalDiaryView) },
                onOpenPanicReflexion: { navigationPath.append(AppRoute.panicReflection) }
            )

        case .journalDiaryView:
            JournalDiaryView(
                onBack: { safePop() },
                onOpenQuestionCatalog: { navigationPath.append(AppRoute.questionCatalog) } // ✅ NEW
            )

        case .panicReflection:
            PanicReflexion(onBack: { safePop() })

        case .questionCatalog:
            QuestionCatalog(
                onBack: { safePop() }
            )

        }
    }
}
