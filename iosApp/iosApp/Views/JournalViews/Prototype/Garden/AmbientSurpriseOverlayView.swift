import SwiftUI
import shared

// =============================================================================
// Ambient surprise overlay — SwiftUI port of Android's AmbientSurpriseOverlay.
//
// A single weighted-random animation drifts across the FULL screen (leaves,
// birds, deer, …). Mirrors the Android weights and motion so both platforms
// feel the same.
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
// All ambient animations share the same weight, so each is equally likely.
private let ambientWeight = 10

let ambientConfigs: [AmbientConfig] = [
    AmbientConfig(asset: .leaves,           weight: ambientWeight, startX: 0.5, startY: -0.2, endX: 0.5, endY: 1.2, duration: 5.5, scale: 1.1, loop: true),
    AmbientConfig(asset: .leaf,             weight: ambientWeight, startX: 0.5, startY: -0.2, endX: 0.5, endY: 1.2, duration: 6.0, scale: 0.9, loop: true),
    // Birds fly horizontally in the artwork, so the motion path is horizontal too
    // (equal start/end Y) to avoid the diagonal "hopping" look (Block 5).
    AmbientConfig(asset: .birds,            weight: ambientWeight, startX: -0.3, startY: 0.18, endX: 1.3, endY: 0.18, duration: 4.5, scale: 1.1, loop: true),
    AmbientConfig(asset: .bird,             weight: ambientWeight, startX: -0.3, startY: 0.22, endX: 1.3, endY: 0.22, duration: 5.0, scale: 1.0, loop: true),
    AmbientConfig(asset: .redBirds,         weight: ambientWeight, startX: 1.3, startY: 0.26, endX: -0.3, endY: 0.26, duration: 5.0, scale: 1.1, loop: true),
    AmbientConfig(asset: .transparentBirds, weight: ambientWeight, startX: -0.3, startY: 0.12, endX: 1.3, endY: 0.12, duration: 5.2, scale: 1.1, loop: true),
    AmbientConfig(asset: .autumnFall,       weight: ambientWeight, startX: 0.5, startY: -0.2, endX: 0.5, endY: 1.2, duration: 6.0, scale: 1.1, loop: true),
    AmbientConfig(asset: .paperPlane,       weight: ambientWeight, startX: -0.2, startY: 0.0, endX: 1.2, endY: 0.6, duration: 2.8, scale: 0.55, loop: true),
    AmbientConfig(asset: .deer,             weight: ambientWeight, startX: -0.4, startY: 0.72, endX: 1.4, endY: 0.72, duration: 7.0, scale: 1.2, loop: true),
]

/// Picks a random config from the pool (all equally likely). Optionally avoids
/// repeating `exclude`, so consecutive surprises feel varied.
func selectRandomAmbient(exclude: LottieAsset? = nil) -> AmbientConfig {
    let pool = ambientConfigs.filter { $0.asset != exclude }
    let source = pool.isEmpty ? ambientConfigs : pool
    return source[Int.random(in: 0..<source.count)]
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
