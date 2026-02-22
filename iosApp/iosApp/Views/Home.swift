import SwiftUI
import Shared

// MARK: - 1. HAUPT-APP STRUKTUR (Bleibt fast gleich, nur Typ-Check)
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

            // Mini Player Overlay
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

            // SOS Button
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

            if showingEmergencyOverlay {
                EmergencyPlanView(isShowing: $showingEmergencyOverlay)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
}

// MARK: - 2. HOME VIEW
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedFilter = "Alle"
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    
    private let petrol = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    Text("Hi User!").font(.system(size: 34, weight: .bold, design: .rounded))
                    Spacer()
                    Image(systemName: "phone.circle.fill").font(.system(size: 30)).foregroundColor(petrol.opacity(0.6))
                }.padding(.top, 10)
                
                FilterBar(selectedFilter: $selectedFilter, showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)

                // Übungen Sektion
                if selectedFilter == "Alle" || selectedFilter == "Übungen" {
                    VStack(alignment: .leading, spacing: 15) {
                        sectionHeader(title: "Übungen", category: "Übungen")
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                            ForEach(viewModel.exercises.prefix(4), id: \.id) { item in
                                ExerciseCard(exercise: item)
                            }
                        }
                    }
                }

                // Mantras Sektion
                if selectedFilter == "Alle" || selectedFilter == "Mantras" {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Mantras").font(.title2).bold()
                        VStack(spacing: 12) {
                            ForEach(viewModel.mantras, id: \.id) { item in
                                MantraRow(mantra: item)
                            }
                        }
                    }
                }

                // Sounds Sektion
                if selectedFilter == "Alle" || selectedFilter == "Sounds" {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sounds").font(.title2).bold()
                        VStack(spacing: 15) {
                            ForEach(viewModel.sounds, id: \.id) { item in
                                SoundRow(sound: item, currentSoundTitle: $currentSoundTitle, showSoundPlayer: $showSoundPlayer)
                            }
                        }
                    }
                }

                Color.clear.frame(height: 150)
            }
            .padding(.horizontal)
        }
    }

    private func sectionHeader(title: String, category: String) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title).font(.title2).bold()
            Spacer()
            NavigationLink(destination: CategoryDetailView(category: category, showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)) {
                Text("Alle anzeigen").font(.system(size: 14, weight: .semibold)).foregroundColor(petrol).underline()
            }
        }
    }
}

// MARK: - 3. EXERCISE CARD
struct ExerciseCard: View {
    let exercise: WellnessExercise // NEUER TYP
    @State private var showExercise = false
    @State private var dummyStep = 0
    
    var body: some View {
        Button(action: { showExercise = true }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.1))
                    Image(exercise.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width / 2 - 24, height: 110)
                        .clipped()
                        .cornerRadius(16)
                }.frame(height: 110)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(exercise.kategorie).font(.system(size: 11, weight: .medium)).foregroundColor(.gray)
                        Spacer()
                        if exercise.dauer != "-" {
                            HStack(spacing: 3) {
                                Image(systemName: "clock").font(.system(size: 10))
                                Text(exercise.dauer).font(.system(size: 11))
                            }.foregroundColor(.gray)
                        }
                    }
                    Text(exercise.titel).font(.system(size: 15, weight: .bold)).foregroundColor(.black).lineLimit(1)
                    Text(exercise.beschreibung).font(.system(size: 12)).foregroundColor(.gray).lineLimit(2)
                }
                .frame(height: 70, alignment: .top)
            }
        }
        .fullScreenCover(isPresented: $showExercise) {
            switch exercise.type {
            case .calculation:
                CalculationExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .breathing:
                BreathingExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .memory:
                MemoryExerciseView(isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
            case .mantra:
                // Hier WellnessMantra nutzen
                if let firstMantra = WellnessRepository.shared.mantras.first {
                    MantraView(mantra: firstMantra, isShowing: $showExercise, currentStep: $dummyStep, isStandalone: true)
                }
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - 4. MANTRA ROW
struct MantraRow: View {
    let mantra: WellnessMantra // NEUER TYP (Kein Mantra_ mehr!)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mantra.titel).font(.headline)
                Text("\"\(mantra.spruch)\"") // .spruch aus Kotlin
                    .font(.subheadline).italic().foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.3))
        }
        .padding().background(Color.white).cornerRadius(18).shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - 5. SOUND ROW
struct SoundRow: View {
    let sound: WellnessSound // NEUER TYP
    @Binding var currentSoundTitle: String
    @Binding var showSoundPlayer: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)).frame(width: 75, height: 75)
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.titel).font(.system(size: 16, weight: .bold))
                Text(sound.beschreibung).font(.system(size: 13)).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
            Button(action: {
                currentSoundTitle = sound.titel
                withAnimation(.spring()) { showSoundPlayer = true }
            }) {
                Image(systemName: "play.circle.fill").font(.system(size: 32)).foregroundColor(.black)
            }
        }
        .padding(10).background(Color.white).cornerRadius(18).shadow(color: .black.opacity(0.05), radius: 8)
    }
}
// MARK: - FILTER BAR
struct FilterBar: View {
    @Binding var selectedFilter: String
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    
    let categories = ["Übungen", "Mantras", "Sounds"]
    let petrol = Color(red: 0.2, green: 0.45, blue: 0.55)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: { withAnimation { selectedFilter = "Alle" } }) {
                    Text("Alle")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(selectedFilter == "Alle" ? petrol : Color.white)
                        .foregroundColor(selectedFilter == "Alle" ? .white : petrol)
                        .cornerRadius(25)
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(petrol, lineWidth: 1))
                }

                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: CategoryDetailView(category: category, showSoundPlayer: $showSoundPlayer, currentSoundTitle: $currentSoundTitle)) {
                        Text(category)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Color.white)
                            .foregroundColor(petrol)
                            .cornerRadius(25)
                            .overlay(RoundedRectangle(cornerRadius: 25).stroke(petrol, lineWidth: 1))
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }
}

// MARK: - CATEGORY DETAIL VIEW
struct CategoryDetailView: View {
    let category: String
    @Binding var showSoundPlayer: Bool
    @Binding var currentSoundTitle: String
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if category == "Übungen" {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                        ForEach(viewModel.exercises, id: \.id) { exercise in
                            ExerciseCard(exercise: exercise)
                        }
                    }
                } else if category == "Sounds" {
                    VStack(spacing: 15) {
                        ForEach(viewModel.sounds, id: \.id) { sound in
                            SoundRow(sound: sound, currentSoundTitle: $currentSoundTitle, showSoundPlayer: $showSoundPlayer)
                        }
                    }
                } else if category == "Mantras" {
                    VStack(spacing: 12) {
                        ForEach(viewModel.mantras, id: \.id) { mantra in
                            MantraRow(mantra: mantra)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
    }
}
// MARK: - PREVIEWS

#Preview("Gesamte App (Startseite)") {
    MyWellnessApp()
}

#Preview("Home Inhalt") {
    // Da HomeView Bindings braucht, nutzen wir .constant
    HomeView(
        showSoundPlayer: .constant(false),
        currentSoundTitle: .constant("")
    )
}

#Preview("Übungs-Karte") {
    // Wir ziehen uns eine Beispiel-Übung aus dem Shared Repository
    if let exampleExercise = WellnessRepository.shared.exercises.first {
        ExerciseCard(exercise: exampleExercise)
            .padding()
            .frame(width: 200)
    } else {
        Text("Keine Daten im Repository")
    }
}

#Preview("Mantra Zeile") {
    if let exampleMantra = WellnessRepository.shared.mantras.first {
        MantraRow(mantra: exampleMantra)
            .padding()
    } else {
        Text("Keine Mantras vorhanden")
    }
}
