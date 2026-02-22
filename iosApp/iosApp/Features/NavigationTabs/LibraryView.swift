
import SwiftUI

struct LibraryView: View {
    let kategorien = ["Meditation", "Atemübungen", "Sounds"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(kategorien, id: \.self) { kat in
                    NavigationLink(destination: Text("Inhalt für \(kat)")) {
                        HStack(spacing: 15) {
                            // Kleines Vorschaubild-Icon
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 50, height: 50)
                                .overlay(Image(systemName: "leaf.fill").foregroundColor(.blue))
                            
                            VStack(alignment: .leading) {
                                Text(kat)
                                    .font(.headline)
                                Text("12 Übungen")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Bibliothek")
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
