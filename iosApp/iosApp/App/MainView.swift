import SwiftUI
import Shared

struct MainView: View {
    @StateObject private var vm = MainViewModelWrapper()

    // Student-style tab selection (0..3 + 99 placeholder)
    @State private var selectedTab: Int = 0

    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    @State private var showingEmergencyOverlay = false

    var body: some View {
        ZStack {
            if #available(iOS 17.0, *) {
                TabView(selection: $selectedTab) {
                    
                    // 0) Start
                    NavigationStack {
                        HomeView(
                            showSoundPlayer: $showSoundPlayer,
                            currentSoundTitle: $currentSoundTitle
                        )
                    }
                    .tabItem { Label("Start", systemImage: "house.fill") }
                    .tag(0)
                    
                    // 1) Tagebuch (bei euch aktuell: Reflection/Journal)
                    NavigationStack {
                        ReflectionView()
                    }
                    .tabItem { Label("Tagebuch", systemImage: "book.closed") }
                    .tag(1)
                    
                    // 99) Center placeholder for floating SOS button
                    Color.clear
                        .tabItem { Text("") }
                        .tag(99)
                    
                    // 2) Mein Plan (bei euch könnte das später der SOS-Plan/Config sein)
                    NavigationStack {
                        // falls ihr schon einen Plan-Screen habt: hier rein
                        SosView()
                    }
                    .tabItem { Label("Mein Plan", systemImage: "checklist") }
                    .tag(2)
                    
                    // 3) Profil
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem { Label("Profil", systemImage: "person") }
                    .tag(3)
                }
                .accentColor(Color.primary500)
                .onChange(of: selectedTab) { _, newValue in
                    // verhindert, dass man den leeren Platzhalter "anwählt"
                    if newValue == 99 {
                        selectedTab = 0
                    }
                }
            } else {
                // Fallback on earlier versions
            }

            // MARK: - Global Mini Player (wie zuvor)
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

            // MARK: - Floating SOS Button (centered)
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

            // MARK: - Student Emergency Overlay
            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}
