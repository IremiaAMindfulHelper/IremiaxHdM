import SwiftUI
import Shared

/// This view demonstrates how to use shared Kotlin Multiplatform resources
/// (`SharedRes`) from SwiftUI. It mirrors the behavior of the Android `App()`
/// composable by toggling visibility of localized text and shared images.
///
/// - Features:
///   - Integration of shared strings and images generated via moko-resources.
///   - Example of localized text retrieval through `StringsKt.localized`.
///   - Animated show/hide transition using SwiftUI’s `withAnimation`.
///
/// - Design:
///   The structure uses a vertical stack with a toggle button and conditional
///   sub-content that animates from the top edge.
///
/// - Note: This file serves as an example for future feature screens
///   (SOS-plan, Skills, Reflections) and how shared logic is accessed on iOS.
struct HomeView: View {
    /// Tracks whether the secondary content (image + texts) is visible.
    @State private var showContent = false

    var body: some View {
        VStack {
            // NOTE: Toggle visibility with animation to demonstrate reactive UI updates.
            Button("Click me!") {
                withAnimation {
                    showContent.toggle()
                }
            }

            // Conditionally show localized shared resources.
            if showContent {
                VStack(spacing: 16) {
                    // SwiftUI system icon (for demo purposes)
                    Image(systemName: "swift")
                        .font(.system(size: 200))
                        .foregroundColor(.accentColor)

                    // NOTE: Text values pulled from shared string resources (moko-resources)
                    Text(Strings.welcome_title)
                    Text(Strings.sos_button)
                    Text(Strings.test_string)

                    // Shared image example (onboarding illustration)
                    let res = SharedRes.images().onboarding_2
                    Image(res.assetImageName, bundle: res.bundle)
                        .resizable()
                        .scaledToFit()
                }
                    // Smooth slide-and-fade transition when content toggles
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
            // Stretch to fill safe area and align at top
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

/// Xcode canvas preview.
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
