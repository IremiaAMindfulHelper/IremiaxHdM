import SwiftUI

struct JournalMainPopUpView: View {

    let onEintragBearbeiten: () -> Void
    let onDismiss: () -> Void
    let dateHeader: String

    // Text und Gradient für den Mood-Chip auf der rechten Seite.
    let chipText: String
    let chipGradient: LinearGradient

    // ViewModel hält Drag-State + Dismiss-Entscheidung
    @StateObject private var vm = JournalMainPopUpViewModel()

    private let sheetCornerRadius: CGFloat = 26
    private let handleWidth: CGFloat = 56
    private let handleHeight: CGFloat = 6
    private let sheetHeightFactor: CGFloat = 0.4

    var body: some View {
        VStack(spacing: 0) {

            // Oberer Drag-Handle-Indikator.
            Capsule()
                .fill(Color.black.opacity(0.2))
                .frame(width: handleWidth, height: handleHeight)
                .padding(.top, 14)
                .padding(.bottom, 10)

            // Großes Datums-Label.
            Text(dateHeader)
                .font(.system(size: 36, weight: .regular, design: .rounded))
                .foregroundStyle(.black.opacity(0.9))
                .padding(.top, 12)
                .padding(.bottom, 6)

            HStack(spacing: 18) {

                // Linke Seite: Panik-Status mit Icon.
                HStack(spacing: 8) {
                    BrokenHeartIcon(size: 20, isActive: true)
                    Text("Panik")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.85))
                }

                Spacer()

                // Rechte Seite: Mood-Chip mit Farbverlauf.
                HStack(spacing: 10) {
                    Circle()
                        .fill(chipGradient)
                        .frame(width: 26, height: 26)

                    Text(chipText)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 16)

            // Button zum Bearbeiten des Eintrags.
            Button { onEintragBearbeiten() } label: {
                Text("Eintrag bearbeiten")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.42, green: 0.56, blue: 0.85),
                                        Color(red: 0.30, green: 0.44, blue: 0.75)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            
            
            .padding(.horizontal, 52)
            .padding(.top, 26)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * sheetHeightFactor)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: sheetCornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: sheetCornerRadius
            )
            .fill(Color.white)
        )
        .shadow(radius: 10)
        .offset(y: max(0, vm.dragOffset))
        .gesture(
            DragGesture()
                .onChanged { value in
                    vm.onDragChanged(translationY: value.translation.height)
                }
                .onEnded { value in
                    if vm.shouldDismiss(translationY: value.translation.height) {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            vm.resetDragOffset()
                        }
                    }
                }
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct BrokenHeartIcon: View {
    let size: CGFloat
    let isActive: Bool

    var body: some View {
        ZStack {
            Image(systemName: "heart")
                .font(.system(size: size))
                .foregroundStyle(.black.opacity(isActive ? 0.85 : 0.35))

            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundStyle(.black.opacity(isActive ? 0.85 : 0.35))
        }
    }
}
