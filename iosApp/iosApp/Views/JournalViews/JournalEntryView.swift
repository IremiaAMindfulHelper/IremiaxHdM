import SwiftUI

struct JournalEntryView: View {
    @State private var currentDate = Date()
    @State private var ballPosition = CGPoint(x: 0, y: 0)
    @State private var isLocked = false
    
    // MARK: - Selbstcheck & Stimmung
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // HEADER
                headerView
                
                Text("Selbstcheck")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                HStack {
                    Text("Stimmung")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    lockButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                moodCoordinateSystem
                    .frame(height: 400)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                HStack {
                    Text("Aktivitäten")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Journal")
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                .frame(width: 40, alignment: .leading)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                // Placeholder for space
                Color.clear.frame(width: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Divider()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd.MM.yy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: currentDate)
    }
    
    private var lockButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLocked.toggle()
            }
        }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Koordinatensystem
    private var moodCoordinateSystem: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let maxDistanceX: CGFloat = centerX - 70
            let maxDistanceY: CGFloat = centerY - 60
            
            ZStack {
                Path { path in
                    // Y-Achse
                    path.move(to: CGPoint(x: centerX, y: 60))
                    path.addLine(to: CGPoint(x: centerX, y: geo.size.height - 60))
                    
                    // X-Achse
                    path.move(to: CGPoint(x: 60, y: centerY))
                    path.addLine(to: CGPoint(x: geo.size.width - 60, y: centerY))
                }
                .stroke(Color.black, lineWidth: 2)
                
                // Labels
                VStack(spacing: 4) {
                    Text("energiegeladen")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                }
                .position(x: centerX, y: 25)
                
                VStack(spacing: 4) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 16))
                    Text("müde")
                        .font(.system(size: 12, weight: .medium))
                }
                .position(x: centerX, y: geo.size.height - 25)
                
                HStack(spacing: 4) {
                    VStack(spacing: 2) {
                        Text("😔")
                            .font(.system(size: 16))
                        Text("deprimiert")
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                            .offset(y: 6)
                    }
                }
                .position(x: 40, y: centerY)
                
                HStack(spacing: 4) {
                    VStack(spacing: 2) {
                        Text("😃")
                            .font(.system(size: 16))
                        Text("fröhlich")
                            .font(.system(size: 12, weight: .medium))
                            .multilineTextAlignment(.center)
                    .offset(y: 6)
                }
                }
                .position(x: geo.size.width - 40, y: centerY)
                
                // Daggable
                Circle()
                    .frame(width: 30, height: 30)
                    .shadow(radius: 6, y: 2)
                    .overlay(
                        isLocked ?
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        : nil
                    )
                    .position(
                        x: centerX + ballPosition.x * maxDistanceX,
                        y: centerY - ballPosition.y * maxDistanceY
                    )
                    .gesture(
                        // Unlocked Dragging
                        isLocked ? nil :
                        DragGesture()
                            .onChanged { value in
                                let deltaX = value.location.x - centerX
                                let deltaY = centerY - value.location.y
                                
                                var normalizedX = deltaX / maxDistanceX
                                var normalizedY = deltaY / maxDistanceY
                                
                                normalizedX = max(-1.0, min(1.0, normalizedX))
                                normalizedY = max(-1.0, min(1.0, normalizedY))
                                
                                ballPosition = CGPoint(x: normalizedX, y: normalizedY)
                            }
                    )
                    .opacity(isLocked ? 0.7 : 1.0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        JournalEntryView()
    }
}
