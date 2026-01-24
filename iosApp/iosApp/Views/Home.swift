import SwiftUI

// MARK: - 1. DATENMODELL
struct UbungItem: Identifiable {
    let id = UUID()
    let kategorie: String
    let titel: String
    let dauer: String
    let beschreibung: String
}

// MARK: - 2. HAUPT-APP STRUKTUR
struct MyWellnessApp: View {
    @State private var selectedTab = 0
    @State private var showingEmergencyOverlay = false
    @State private var showSoundPlayer = false
    @State private var currentSoundTitle = ""

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)
                }
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(0)
                
                NavigationStack { Text("Tagebuch") }
                .tabItem { Label("Tagebuch", systemImage: "book.closed") }
                .tag(1)
                
                Color.clear.tabItem { Text("") }.tag(99)
                
                NavigationStack { Text("Mein Plan") }
                .tabItem { Label("Mein Plan", systemImage: "checklist") }
                .tag(2)
                
                NavigationStack { Text("Profil") }
                .tabItem { Label("Profil", systemImage: "person") }
                .tag(3)
            }
            .accentColor(Color(red: 0.2, green: 0.45, blue: 0.55))

            // Automatisch erscheinender Mini Player
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
                    .padding(.bottom, 65)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }

            // SOS Button
            VStack {
                Spacer()
                Button {
                    // HIER: Das Overlay aktivieren und Animation starten
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingEmergencyOverlay = true
                    }
                    // Optional: Den Tab-Zustand zurücksetzen, damit kein leerer Tab aktiv bleibt
                    selectedTab = 0
                } label: {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 60, height: 60).shadow(radius: 6)
                        Image("NotfallButton").resizable().scaledToFit().frame(width: 50, height: 50)
                    }
                }
                .offset(y: -5)
            }.zIndex(5)

            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}

// MARK: - 3. HOME VIEW
struct HomeView: View {
    @State private var selectedFilter = "Alle"
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                FilterBar(selectedFilter: $selectedFilter)

                // Übungen Sektion
                if selectedFilter == "Alle" || selectedFilter == "Übungen" {
                    sectionHeader("Übungen")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                        ForEach(WellnessData.exercises) { item in
                            ExerciseCard(exercise: item)
                        }
                    }
                }

                // Mantras Sektion
                if selectedFilter == "Alle" || selectedFilter == "Mantras" {
                    sectionHeader("Mantras")
                    VStack(spacing: 12) {
                        ForEach(WellnessData.mantras) { item in
                            MantraRow(mantra: item)
                        }
                    }
                }

                // Sounds Sektion
                if selectedFilter == "Alle" || selectedFilter == "Sounds" {
                    sectionHeader("Sounds")
                    VStack(spacing: 15) {
                        ForEach(WellnessData.sounds) { item in
                            SoundRow(sound: item, currentSoundTitle: $currentSoundTitle, showSoundPlayer: $showSoundPlayer)
                        }
                    }
                }

                Color.clear.frame(height: 150)
            }
            .padding(.horizontal)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Dashboard").font(.system(size: 14)).foregroundColor(.gray)
            HStack {
                Text("Hi User!").font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.6))
            }
        }.padding(.top, 10)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.title2).bold().padding(.top, 10)
    }
}
// MARK: - HILFSKOMPONENTEN (CARDS & ROWS)
// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.2)).frame(height: 110)
            HStack {
                Text(exercise.kategorie).font(.system(size: 12)).foregroundColor(.gray)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(exercise.dauer)
                }.font(.system(size: 12)).foregroundColor(.gray)
            }
            Text(exercise.titel).font(.system(size: 16, weight: .bold))
            Text(exercise.beschreibung).font(.system(size: 12)).foregroundColor(.gray).lineLimit(2)
        }
    }
}

// MARK: - Mantra Row
struct MantraRow: View {
    let mantra: Mantra
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mantra.titel).font(.headline)
                Text("\"\(mantra.spruch)\"").font(.subheadline).italic().foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.4))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Sound Row
struct SoundRow: View {
    let sound: Sound
    @Binding var currentSoundTitle: String
    @Binding var showSoundPlayer: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(width: 85, height: 85)
            VStack(alignment: .leading, spacing: 5) {
                Text(sound.titel).font(.headline).bold()
                Text(sound.beschreibung).font(.subheadline).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
            Button(action: {
                currentSoundTitle = sound.titel
                withAnimation(.spring()) { showSoundPlayer = true }
            }) {
                Image(systemName: "play.circle.fill").font(.system(size: 32)).foregroundColor(.black)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - SONSTIGE VIEWS (UNVERÄNDERT)

struct FilterBar: View {
    @Binding var selectedFilter: String
    let categories = ["Übungen", "Mantras", "Sounds"]
    var body: some View {
        HStack(spacing: 12) {
            if selectedFilter == "Alle" {
                filterButton("Alle", isActive: true)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { filter in
                            filterButton(filter, isActive: false)
                        }
                    }
                }
            } else {
                HStack(spacing: 10) {
                    Text(selectedFilter).font(.system(size: 15, weight: .medium)).padding(.horizontal, 22).padding(.vertical, 10).background(Color(red: 0.2, green: 0.45, blue: 0.55)).foregroundColor(.white).cornerRadius(25)
                    Button(action: { withAnimation(.spring()) { selectedFilter = "Alle" } }) {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).padding(10).background(Color(red: 0.2, green: 0.45, blue: 0.55)).foregroundColor(.white).clipShape(Circle())
                    }
                }
            }
        }
    }
    func filterButton(_ title: String, isActive: Bool) -> some View {
        Button(action: { withAnimation(.spring()) { selectedFilter = title } }) {
            Text(title).font(.system(size: 15, weight: .medium)).padding(.horizontal, 20).padding(.vertical, 10).background(isActive ? Color(red: 0.2, green: 0.45, blue: 0.55) : Color.white).foregroundColor(isActive ? .white : .black).cornerRadius(25).overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray.opacity(0.3), lineWidth: isActive ? 0 : 1))
        }
    }
}

struct MyWellnessApp_Previews: PreviewProvider {
    static var previews: some View {
        MyWellnessApp()
    }
}
