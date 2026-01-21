//
//  JournalMainPopUpView.swift
//  iosApp
//
//  Created by Anke Raab on 09.01.26.
//  Anke
//

import SwiftUI

struct JournalMainPopUpView: View {

    let onEintragBearbeiten: () -> Void
    let onDismiss: () -> Void          // ✅ NEU (damit Overlay geschlossen werden kann)

    @State private var dragOffset: CGFloat = 0

    // MARK: - Tuning
    private let sheetCornerRadius: CGFloat = 26
    private let handleWidth: CGFloat = 56
    private let handleHeight: CGFloat = 6

    // 40% der Screenhöhe
    private let sheetHeightFactor: CGFloat = 0.4

    // ab dieser Drag-Höhe schließen wir das Popup
    private let dismissDragThreshold: CGFloat = 120

    var body: some View {
        ZStack(alignment: .bottom) {

            // Dimmed Background (liegt jetzt über dem Kalender)
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        onDismiss()
                    }
                }

            // Sheet
            VStack(spacing: 0) {

                // Grabber
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: handleWidth, height: handleHeight)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                // Date Title
                Text("Mi 12.11.25")
                    .font(.system(size: 36, weight: .regular, design: .rounded))
                    .foregroundStyle(.black.opacity(0.9))
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                // Row: Icon + Labels
                HStack(spacing: 18) {

                    // Left: Panic label
                    HStack(spacing: 8) {
                        BrokenHeartIcon(size: 20, isActive: true)
                        Text("Panik")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(.black.opacity(0.85))
                    }

                    Spacer()

                    // Right: Mood chip
                    HStack(spacing: 10) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.95),
                                        Color.blue.opacity(0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 26, height: 26)

                        Text("energiegeladen, fröhlich")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(.black.opacity(0.85))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 16)

                // Button
                Button {
                    onEintragBearbeiten()
                } label: {
                    Text("Eintrag bearbeiten")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundStyle(.black.opacity(0.95))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.85), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 52)
                .padding(.top, 26)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            // Sheet nimmt ~40% des Screens ein
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
            .offset(y: max(0, dragOffset))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = max(0, value.translation.height)
                    }
                    .onEnded { value in
                        if value.translation.height > dismissDragThreshold {
                            withAnimation {
                                onDismiss()
                            }
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .ignoresSafeArea(edges: .bottom)
        }
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

struct JournalMainPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        JournalMainPopUpView(
            onEintragBearbeiten: {},
            onDismiss: {}        // ✅ NEU
        )
    }
}
