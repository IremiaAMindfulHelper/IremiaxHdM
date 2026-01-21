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
    @State private var showJournalPopup = false
    @State private var rootMode: JournalRootMode = .emotions

    var body: some View {
        NavigationStack(path: $navigationPath) {

            ZStack {
                // ✅ Hintergrund: Journal Root Views
                Group {
                    switch rootMode {
                    case .emotions:
                        JournalMainViewEmotions(
                            rootMode: $rootMode,
                            onPlusButtonTapped: {          // farbiger Kreis -> Popup
                                withAnimation {
                                    showJournalPopup = true
                                }
                            },
                            onCreateEntry: {               // + -> JournalEntryView
                                navigationPath.append(AppRoute.journalEntry)
                            }
                        )

                    case .panicAttacks:
                        JournalMainViewPanicAttacks(
                            rootMode: $rootMode,
                            onPlusButtonTapped: {          // broken heart -> Popup
                                withAnimation {
                                    showJournalPopup = true
                                }
                            },
                            onCreateEntry: {               // + -> JournalEntryView
                                navigationPath.append(AppRoute.journalEntry)
                            }
                        )
                    }
                }

                // ✅ Overlay: Popup direkt über dem Kalender
                if showJournalPopup {
                    JournalMainPopUpView(
                        onEintragBearbeiten: {
                            showJournalPopup = false
                            navigationPath.append(AppRoute.journalEntry)
                        },
                        onDismiss: {
                            withAnimation {
                                showJournalPopup = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
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
            JournalDiaryView(onBack: { safePop() })

        case .panicReflection:
            PanicReflexion(onBack: { safePop() })

        case .questionCatalog:
            Text("Question Catalog")
        }
    }
}
