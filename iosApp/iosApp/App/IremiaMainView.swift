import SwiftUI
import Shared

/// The root view of the Iremia application.
/// Manages the primary navigation via a TabView and handles global overlays like the SOS system and Mini Player.
struct IremiaMainView: View {
    // MARK: - Navigation State
    @State private var selectedTab = 0
    @State private var showingEmergencyOverlay = false
    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    var body: some View {
        ZStack {
            // MARK: - MAIN TAB NAVIGATION
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)
                }
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(0)
                
                NavigationStack { Text("Tagebuch") }
                .tabItem { Label("Tagebuch", systemImage: "book.closed") }
                .tag(1)
                
                // Placeholder for the central SOS button alignment
                Color.clear.tabItem { Text("") }.tag(99)
                
                NavigationStack { Text("Mein Plan") }
                .tabItem { Label("Mein Plan", systemImage: "checklist") }
                .tag(2)
                
                NavigationStack { Text("Profil") }
                .tabItem { Label("Profil", systemImage: "person") }
                .tag(3)
            }
            .accentColor(Color(red: 0.2, green: 0.45, blue: 0.55))

            // MARK: - GLOBAL MINI PLAYER
            VStack {
                Spacer()
                if showSoundPlayer {
                    HStack {
                        // NOTE: Floating mini player providing persistent audio controls across all tabs.
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

            // MARK: - PERSISTENT SOS BUTTON
            VStack {
                Spacer()
                Button {
                    // Trigger the emergency intervention flow with a spring animation.
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
                            .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55))
                    }
                }
                .offset(y: +5)
            }.zIndex(5)

            // MARK: - EMERGENCY INTERVENTION OVERLAY
            if showingEmergencyOverlay {
                // NOTE: Full-screen overlay providing immediate assistance when the SOS button is pressed.
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}
