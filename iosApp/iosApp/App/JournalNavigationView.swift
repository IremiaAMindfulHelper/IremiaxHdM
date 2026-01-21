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

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch rootMode {
                case .emotions:
                    JournalMainViewEmotions(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {
                        },
                        onCreateEntry: {
                            navigationPath.append(AppRoute.journalEntry)
                        }
                    )

                case .panicAttacks:
                    JournalMainViewPanicAttacks(
                        rootMode: $rootMode,
                        onPlusButtonTapped: {
                            // TODO: Später
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
