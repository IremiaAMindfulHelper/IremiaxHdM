import SwiftUI
import Shared

struct ContentView: View {
    @State private var showContent = false

    var body: some View {
        VStack {
            Button("Click me!") {
                withAnimation {
                    showContent = !showContent
                }
            }

            if showContent {
                VStack(spacing: 16) {
                    Image(systemName: "swift")
                        .font(.system(size: 200))
                        .foregroundColor(.accentColor)
                    Text(StringsKt.localized(res: SharedRes.strings().welcome_title).localized())
                    Text(StringsKt.localized(res: SharedRes.strings().sos_button).localized())
                    Text(StringsKt.localized(res: SharedRes.strings().test_string).localized())
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

