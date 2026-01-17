import SwiftUI

// MARK: - Haupt-App Struktur
struct MyWellnessApp: View {
    @State private var selectedTab = 0
    @State private var showingEmergencyOverlay = false
    @State private var showSoundPlayer = true

    var body: some View {
        ZStack {
            // 1. Haupt-Navigation
            TabView(selection: $selectedTab) {
                
                // HIER: NavigationStack hinzugefügt für Home
                NavigationStack {
                    HomeView()
                }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
                
                NavigationStack {
                    LibraryView()
                }
                .tabItem { Label("Übungen", systemImage: "book.closed") }
                .tag(1)
                
                // Notfall-Tab (unsichtbar)
                Color.clear
                    .tabItem { Text("") }
                    .tag(99)
                
                NavigationStack {
                    SettingsView()
                }
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(2)
                
                NavigationStack {
                    ProfileView()
                }
                .tabItem { Label("Profil", systemImage: "person") }
                .tag(3)
            }
            .accentColor(.blue)
            .onChange(of: selectedTab) { newValue in
                if newValue == 99 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingEmergencyOverlay = true
                    }
                    selectedTab = 0
                }
            }

            // 2. Mini Player
            VStack {
                Spacer()
                HStack {
                    if showSoundPlayer {
                        SoundPlayerMini {
                            showSoundPlayer = false
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 60)
            }
            .allowsHitTesting(!showingEmergencyOverlay)

            // 3. HERVORGEHOBENER NOTFALL-BUTTON
            VStack {
                Spacer()
                Button {
                    selectedTab = 99
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .shadow(radius: 6)
                        
                        // HIER DIE ÄNDERUNG:
                        // Wir nutzen Image("NameDeinesAssets") statt systemName
                        Image("NotfallButton")
                            .resizable() // Wichtig, damit das Bild die Größe annimmt
                            .scaledToFit() // Verhindert Verzerrung
                            .frame(width: 50, height: 50) // Gleiche Größe wie der alte blaue Kreis
                    }
                }
                .offset(y: -5)
            }
            .zIndex(5)

            // 4. FULLSCREEN EMERGENCY OVERLAY
            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
            }
        }
    }
}

// MARK: - Home Ansicht
struct HomeView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    HeaderView() // Hier sitzt der NavigationLink
                    FilterBar()
                    UbungenSection()
                    MantrasSection()
                    Color.clear.frame(height: 100)
                }
                .padding()
            }
        }
    }
}

// MARK: - Header mit funktionierendem Link
struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Hi, User").font(.system(size: 34, weight: .bold))
            
            Spacer()
            
            // Funktioniert jetzt, da HomeView im NavigationStack liegt
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
        }
    }
}


struct FilterBar: View {
    let filters = ["Alle", "Übungen", "Mantras", "Sounds"]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { item in
                    Text(item).fontWeight(.medium).padding(.horizontal, 20).padding(.vertical, 10).background(Color.white).cornerRadius(20).shadow(radius: 2)
                }
            }
        }
    }
}

struct UbungenSection: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        VStack(alignment: .leading) {
            HStack { Text("Übungen").font(.title2).bold(); Spacer(); Text("Mehr...").foregroundColor(.blue) }
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(0..<4) { _ in RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(height: 190).shadow(radius: 3) }
            }
        }
    }
}

struct MantrasSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Mantras").font(.title2).bold()
            HStack(spacing: -10) {
                RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)).frame(width: 60, height: 160)
                RoundedRectangle(cornerRadius: 20).fill(Color.white).frame(height: 200).shadow(radius: 5).overlay(Text("Atme tief ein...").italic())
                RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.2)).frame(width: 60, height: 160)
            }
        }
    }
}

struct MyWellnessApp_Previews: PreviewProvider {
    static var previews: some View {
        MyWellnessApp()
    }
}
