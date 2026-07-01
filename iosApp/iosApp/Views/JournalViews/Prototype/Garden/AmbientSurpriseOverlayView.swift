import SwiftUI
import Lottie
import Shared

// =============================================================================
// Ambient surprise overlay — SwiftUI port of Android's AmbientSurpriseOverlay.
//
// A single weighted-random animation drifts across the FULL screen (leaves,
// birds, butterflies, deer, …). Mirrors the Android weights and motion so both
// platforms feel the same.
// =============================================================================

/// One ambient animation's path and visual scale (relative to screen size).
struct AmbientConfig: Equatable {
    let asset: LottieAsset
    let weight: Int
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let duration: Double
    let scale: CGFloat
    let loop: Bool

    static func == (lhs: AmbientConfig, rhs: AmbientConfig) -> Bool {
        lhs.asset == rhs.asset && lhs.startX == rhs.startX && lhs.startY == rhs.startY
    }
}

/// Weighted pool, matching AmbientSurpriseOverlay.kt.
let ambientConfigs: [AmbientConfig] = [
    AmbientConfig(asset: .leaves,      weight: 30, startX: 0.2, startY: -0.2, endX: 0.8, endY: 1.2, duration: 5.5, scale: 0.8, loop: true),
    AmbientConfig(asset: .birds,       weight: 25, startX: -0.3, startY: 0.3, endX: 1.3, endY: 0.1, duration: 4.5, scale: 0.55, loop: true),
    AmbientConfig(asset: .autumnFall,  weight: 20, startX: 0.6, startY: -0.2, endX: 0.2, endY: 1.2, duration: 6.0, scale: 0.8, loop: true),
    AmbientConfig(asset: .butterflies, weight: 15, startX: 1.3, startY: 0.5, endX: -0.3, endY: 0.3, duration: 6.5, scale: 0.6, loop: true),
    AmbientConfig(asset: .paperPlane,  weight: 8,  startX: 1.2, startY: 0.0, endX: -0.2, endY: 0.6, duration: 2.8, scale: 0.45, loop: true),
    AmbientConfig(asset: .deer,        weight: 5,  startX: -0.4, startY: 0.72, endX: 1.4, endY: 0.72, duration: 7.0, scale: 0.7, loop: true),
]

/// Picks a weighted-random config from the pool.
func selectRandomAmbient() -> AmbientConfig {
    let total = ambientConfigs.reduce(0) { $0 + $1.weight }
    var roll = Int.random(in: 0..<total)
    for config in ambientConfigs {
        roll -= config.weight
        if roll < 0 { return config }
    }
    return ambientConfigs[0]
}

/// Fullscreen overlay that plays a single ambient animation drifting across the
/// whole screen, then calls `onFinished` so the caller can remove it.
struct AmbientSurpriseOverlayView: View {
    let config: AmbientConfig
    let onFinished: () -> Void

    @State private var progress: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let size = w * config.scale
            let x = lerp(config.startX, config.endX, progress) * w
            let y = lerp(config.startY, config.endY, progress) * h

            LottieFileView(asset: config.asset, loopMode: config.loop ? .loop : .playOnce)
                .frame(width: size, height: size)
                .position(x: x, y: y)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: config.duration)) {
                progress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                onFinished()
            }
        }
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}
