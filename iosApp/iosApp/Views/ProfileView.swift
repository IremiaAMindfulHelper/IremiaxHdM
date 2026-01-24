
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profilbild Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Max Mustermann")
                            .font(.title2).bold()
                        
                        Text("Mitglied seit Jan 2024")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mein Profil")
        }
    }


// Hilfs-View für die kleine Statistik-Karten


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
