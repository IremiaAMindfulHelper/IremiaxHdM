import SwiftUI
import shared

#if canImport(Lottie)
import Lottie
#endif

// =============================================================================
// iOS Lottie playback for shared .lottie assets.
//
// When lottie-ios is linked, this renders the actual dotLottie files. The fallback
// keeps the build running and still drives visible motion from the same assets.
// =============================================================================

enum LottiePlaybackMode {
    case playOnce
    case loop
}

/// Resolves the on-disk URL of a shared `LottieAsset`'s .lottie file.
private func lottieURL(for asset: LottieAsset) -> URL? {
    asset.fileResource.url
}

/// Plays a shared dotLottie file when lottie-ios is available. Without that
/// package, a lightweight SwiftUI placeholder animation is shown so the garden
/// feature still builds and visibly reacts to the same `LottieAsset` values.
struct LottieFileView: View {
    let asset: LottieAsset
    var loopMode: LottiePlaybackMode = .playOnce
    var speed: CGFloat = 1.0
    var fromProgress: CGFloat = 0
    /// Wall-clock seconds the played segment should take, independent of the
    /// animation's own length. When set, it overrides `speed`: the player derives
    /// the required speed from the loaded composition's real duration.
    ///
    /// NOTE: Prefer this over `speed` for anything that must match Android, which
    /// drives its Lottie by an explicit duration (see GardenScene). A fixed `speed`
    /// silently depends on however long the asset happens to be.
    var duration: TimeInterval? = nil
    var onFinished: (() -> Void)? = nil

    var body: some View {
        #if canImport(Lottie)
        LottiePlayerRepresentable(
            asset: asset,
            loopMode: loopMode,
            speed: speed,
            fromProgress: fromProgress,
            duration: duration,
            onFinished: onFinished
        )
        .clipped()
        #else
        LottieFallbackView(asset: asset, loopMode: loopMode, speed: speed, onFinished: onFinished)
        #endif
    }
}

#if canImport(Lottie)
private struct LottiePlayerRepresentable: UIViewRepresentable {
    let asset: LottieAsset
    var loopMode: LottiePlaybackMode
    var speed: CGFloat
    var fromProgress: CGFloat
    var duration: TimeInterval?
    var onFinished: (() -> Void)?

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = mappedLoopMode
        view.animationSpeed = speed
        view.backgroundBehavior = .pauseAndRestore

        guard let url = lottieURL(for: asset) else { return view }
        DotLottieFile.loadedFrom(url: url) { result in
            switch result {
            case .success(let dotLottie):
                view.loadAnimation(from: dotLottie)
                // With an explicit duration, derive the speed from the composition's
                // actual length so playback takes the requested wall-clock time
                // regardless of how long the asset itself is.
                if let duration, duration > 0, let animation = view.animation {
                    let segment = max(0, 1 - fromProgress)
                    let playedSeconds = animation.duration * TimeInterval(segment)
                    view.animationSpeed = playedSeconds > 0
                        ? CGFloat(playedSeconds / duration)
                        : speed
                }
                view.play(fromProgress: fromProgress, toProgress: 1, loopMode: mappedLoopMode) { finished in
                    if finished { onFinished?() }
                }
            case .failure:
                onFinished?()
            }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        uiView.loopMode = mappedLoopMode
        // Only take over the speed when no duration is driving it; otherwise this
        // would clobber the duration-derived speed computed at load time.
        if duration == nil {
            uiView.animationSpeed = speed
        }
    }

    /// Without this, SwiftUI falls back to `LottieAnimationView.intrinsicContentSize`,
    /// which reports the animation's native artboard size (often far larger than any
    /// `.frame()` set from outside) and silently overrides it. Returning the proposed
    /// size here makes the view honor the caller's `.frame(width:height:)`.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: LottieAnimationView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width,
               height: proposal.height ?? uiView.intrinsicContentSize.height)
    }

    private var mappedLoopMode: LottieLoopMode {
        switch loopMode {
        case .playOnce: return .playOnce
        case .loop: return .loop
        }
    }
}
#else
private struct LottieFallbackView: View {
    let asset: LottieAsset
    var loopMode: LottiePlaybackMode
    var speed: CGFloat
    var onFinished: (() -> Void)?

    @State private var animate = false

    private var cycleDuration: Double {
        max(0.45, 1.2 / Double(max(speed, 0.1)))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(IremiaColors.garden100.opacity(0.55))
                .scaleEffect(animate ? 1.0 : 0.45)
                .opacity(animate ? 0.08 : 0.45)

            Image(systemName: symbolName)
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(IremiaColors.garden700)
                .scaleEffect(animate ? 1.0 : 0.72)
                .rotationEffect(.degrees(animate ? 8 : -8))
                .opacity(0.92)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: cycleDuration).repeatForever(autoreverses: true)) {
                animate = true
            }
            if loopMode == .playOnce {
                DispatchQueue.main.asyncAfter(deadline: .now() + cycleDuration) {
                    onFinished?()
                }
            }
        }
    }

    private var symbolName: String {
        let name = asset.name.lowercased()
        if name.contains("bird") { return "bird.fill" }
        if name.contains("leaf") || name.contains("fall") { return "leaf.fill" }
        if name.contains("plane") { return "paperplane.fill" }
        if name.contains("deer") { return "hare.fill" }
        return "tree.fill"
    }
}
#endif

/// Convenience growth animation: plays the plant/tree growth animation once,
/// skipping the slow sprouting intro so the tree shoots up fast.
struct GrowthLottieView: View {
    let asset: LottieAsset
    var speed: CGFloat = 1.0
    /// Wall-clock seconds for the growth segment. Overrides `speed` when set.
    var duration: TimeInterval? = nil
    var onFinished: (() -> Void)? = nil

    var body: some View {
        LottieFileView(
            asset: asset,
            loopMode: .playOnce,
            speed: speed,
            fromProgress: 0.2,
            duration: duration,
            onFinished: onFinished
        )
    }
}
