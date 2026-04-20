import SwiftUI
import Shared

struct MainView: View {
    // Falls du das Wrapper-VM noch brauchst (z.B. später), lassen wir es drin,
    // aber wir syncen die Tab-Auswahl NICHT über route.
    @StateObject private var vm = MainViewModelWrapper()

    // Mini player (falls genutzt)
    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    // SOS overlay (student style)
    @State private var showingEmergencyOverlay = false

    // Student tab layout uses Int tags
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {

                // 0) Start
                NavigationStack {
                    HomeView(
                        showSoundPlayer: $showSoundPlayer,
                        currentSoundTitle: $currentSoundTitle
                    )
                }
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().home).localized(),
                        systemImage: "house.fill"
                    )
                }
                .tag(0)

                // 1) Journal (wichtig: JournalNavigationView beibehalten)
                NavigationStack {
                    JournalNavigationView()
                }
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }
                .tag(1)

                // 99) Center placeholder (für den mittigen SOS Button)
                Color.clear
                    .tabItem { Text("") }
                    .tag(99)

                // 2) Mein Plan (hier ggf. euren echten View einsetzen)
                NavigationStack {
                    Text("Mein Plan")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.background)
                }
                .tabItem {
                    Label("Mein Plan", systemImage: "checklist")
                }
                .tag(2)

                // 3) Profil
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().profile).localized(),
                        systemImage: "person"
                    )
                }
                .tag(3)
            }

            // Mini Player
            VStack {
                Spacer()
                if showSoundPlayer {
                    HStack {
                        SoundPlayerMini(title: currentSoundTitle) {
                            withAnimation { showSoundPlayer = false }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 75)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }

            // Floating SOS Button (mittig)
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingEmergencyOverlay = true
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .shadow(radius: 6)

                            Image("NotfallButton")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        Text("SOS")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.primary500)
                    }
                }
                .buttonStyle(.plain)
                .offset(y: 5)
            }
            .zIndex(5)

            // SOS Overlay (student EmergencyPlanView)
            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
