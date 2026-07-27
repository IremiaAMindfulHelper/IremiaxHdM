import SwiftUI
import shared

// =============================================================================
// MainView — Custom frosted bottom navigation:
//   Start | Training | Journal | Wohlbefinden
// =============================================================================

/// The four tabs matching the current app navigation.
enum MainTab: Int, CaseIterable, Identifiable {
    case start = 0
    case training = 1
    case journal = 2
    case wellbeing = 3

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .start: return "Start"
        case .training: return "Training"
        case .journal: return "Journal"
        case .wellbeing: return "Wohlbefinden"
        }
    }

    var icon: String {
        switch self {
        case .start: return "house.fill"
        case .training: return "books.vertical.fill"
        case .journal: return "book.fill"
        case .wellbeing: return "figure.mind.and.body"
        }
    }
}

struct MainView: View {
    @State private var selectedTab: MainTab = .start

    // Mini player state (preserved from the original)
    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    // Shared notes state + capture flow, hosted at the shell so the "+" FAB works
    // on every tab and the Journal tab observes the same controller instance.
    @StateObject private var notesObservable = NotesObservable()
    // Shared garden state, so the home screen shows the same live garden preview.
    @StateObject private var gardenObservable = GardenObservable()
    @State private var showCaptureFlow = false
    @State private var openGardenSignal = false

    private func openCaptureFlow() {
        notesObservable.clearPlantResult()
        showCaptureFlow = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .start:
                    NavigationStack {
                        InsightHomeView(
                            garden: gardenObservable,
                            onOpenJournal: { selectedTab = .journal }
                        )
                    }

                case .training:
                    NavigationStack {
                        Text(Strings.training)
                            .font(IremiaText.h1)
                            .foregroundColor(IremiaColors.ink)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(IremiaColors.gray100)
                    }

                case .journal:
                    NavigationStack {
                        JournalPrototypeScreen(
                            notesObservable: notesObservable,
                            gardenObservable: gardenObservable,
                            openCaptureFlow: { openCaptureFlow() },
                            openGardenSignal: $openGardenSignal
                        )
                    }

                case .wellbeing:
                    NavigationStack {
                        Text(Strings.wellbeing)
                            .font(IremiaText.h1)
                            .foregroundColor(IremiaColors.ink)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(IremiaColors.gray100)
                    }
                }
            }

            if showSoundPlayer {
                HStack {
                    SoundPlayerMini(title: currentSoundTitle) {
                        withAnimation { showSoundPlayer = false }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 92)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Persistent "+" FAB — visible on every tab, above the glassy tab bar.
            Button(action: { openCaptureFlow() }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(IremiaColors.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(IremiaColors.teal700))
                    .shadow(color: SwiftUI.Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Strings.journal_fab)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, IremiaSpacing.screenGutter)
            .padding(.bottom, IremiaSpacing.bottomNavClearance)

            GlassyTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .ignoresSafeArea(.keyboard)
        }
        // Capture flow, hosted at the shell so the FAB works on any tab.
        .fullScreenCover(isPresented: $showCaptureFlow, onDismiss: { notesObservable.clearPlantResult() }) {
            EpisodeCaptureFlow(
                entryCount: notesObservable.entryCount,
                onClose: { showCaptureFlow = false },
                onFinished: { showCaptureFlow = false },
                onViewGarden: {
                    showCaptureFlow = false
                    // Switch to the Journal tab and ask it to open the garden.
                    selectedTab = .journal
                    openGardenSignal = true
                },
                onSaveEpisode: { draft in
                    notesObservable.addEntry(draft)
                },
                plantResult: notesObservable.lastPlantResult
            )
        }
    }
}

// MARK: - Glassy Tab Bar

private struct GlassyTabBar: View {
    @Binding var selectedTab: MainTab
    @Namespace private var selectionAnimation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                GlassyTabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: selectionAnimation
                ) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .frame(height: 68)
        .padding(.horizontal, 6)
        .background {
            ZStack {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)

                Capsule(style: .continuous)
                    .fill(SwiftUI.Color.white.opacity(0.74))

                Capsule(style: .continuous)
                    .stroke(SwiftUI.Color.black.opacity(0.10), lineWidth: 0.8)

                Capsule(style: .continuous)
                    .inset(by: 1)
                    .stroke(SwiftUI.Color.white.opacity(0.82), lineWidth: 1)
            }
        }
        .clipShape(Capsule(style: .continuous))
        .shadow(color: SwiftUI.Color.black.opacity(0.20), radius: 18, x: 0, y: 8)
        .shadow(color: SwiftUI.Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

private struct GlassyTabBarItem: View {
    let tab: MainTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(SwiftUI.Color.white.opacity(0.62))
                        .background(
                            Capsule(style: .continuous)
                                .fill(.regularMaterial)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(SwiftUI.Color.white.opacity(0.75), lineWidth: 0.7)
                        )
                        .shadow(color: SwiftUI.Color.black.opacity(0.07), radius: 10, x: 0, y: 4)
                        .matchedGeometryEffect(id: "selectedTabBackground", in: namespace)
                        .frame(width: 78, height: 48)
                }

                VStack(spacing: 0) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 25, weight: .heavy))
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(isSelected ? IremiaColors.teal700 : SwiftUI.Color.black.opacity(0.88))
                        .frame(height: 30)

                    Text(tab.label)
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(isSelected ? IremiaColors.teal700 : SwiftUI.Color.black.opacity(0.88))
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.label)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
