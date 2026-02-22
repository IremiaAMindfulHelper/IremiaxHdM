import SwiftUI
import Shared

struct IremiaMainView: View {
    @State private var selectedTab = 0
    @State private var showingEmergencyOverlay = false
    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    var body: some View {
        ZStack {
            // MARK: - TABS (DIE HAUPTSEITEN)
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)
                }
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(0)
                
                NavigationStack { Text("Tagebuch") }
                .tabItem { Label("Tagebuch", systemImage: "book.closed") }
                .tag(1)
                
                Color.clear.tabItem { Text("") }.tag(99) // Platzhalter für SOS
                
                NavigationStack { Text("Mein Plan") }
                .tabItem { Label("Mein Plan", systemImage: "checklist") }
                .tag(2)
                
                NavigationStack { Text("Profil") }
                .tabItem { Label("Profil", systemImage: "person") }
                .tag(3)
            }
            .accentColor(Color(red: 0.2, green: 0.45, blue: 0.55))

            // MARK: - MINI PLAYER
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

            // MARK: - SOS BUTTON
            VStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingEmergencyOverlay = true
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color.white).frame(width: 60, height: 60).shadow(radius: 6)
                            Image("NotfallButton").resizable().scaledToFit().frame(width: 50, height: 50)
                        }
                        Text("SOS").font(.system(size: 12, weight: .bold)).foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55))
                    }
                }
                .offset(y: +5)
            }.zIndex(5)

            // MARK: - SOS OVERLAY
            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}
