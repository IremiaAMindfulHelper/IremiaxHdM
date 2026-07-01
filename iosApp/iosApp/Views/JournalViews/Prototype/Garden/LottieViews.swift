import SwiftUI
import Lottie
import Shared

// =============================================================================
// iOS Lottie playback, matching Android's Compottie usage.
//
// The .lottie (dotLottie) files ship inside the shared moko-resources bundle.
// Each `LottieAsset` exposes its `fileResource.url`, which lottie-ios 4.x can
// load directly via `DotLottieFile`.
// =============================================================================

/// Resolves the on-disk URL of a shared `LottieAsset`'s .lottie file.
private func lottieURL(for asset: LottieAsset) -> URL? {
    asset.fileResource.url
}

/// Plays a dotLottie file. Loads asynchronously (DotLottieFile is async) and
/// drives playback with the given loop mode. `play` toggles a one-shot start.
struct LottieFileView: UIViewRepresentable {
    let asset: LottieAsset
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1.0
    var onFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.backgroundBehavior = .pauseAndRestore

        guard let url = lottieURL(for: asset) else { return view }
        DotLottieFile.loadedFrom(url: url) { result in
            switch result {
            case .success(let dotLottie):
                view.loadAnimation(from: dotLottie)
                view.play { finished in
                    if finished { onFinished?() }
                }
            case .failure:
                break
            }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed
    }
}

/// Convenience growth animation: plays the plant/tree growth Lottie once.
struct GrowthLottieView: View {
    let asset: LottieAsset
    var speed: CGFloat = 1.0
    var onFinished: (() -> Void)? = nil

    var body: some View {
        LottieFileView(asset: asset, loopMode: .playOnce, speed: speed, onFinished: onFinished)
    }
}
