import SwiftUI
import Shared

struct MainView: View {
    @StateObject private var vm = MainViewModelWrapper()

    var body: some View {
        TabView(selection: Binding(
            get: { vm.currentTarget.route },
            set: { route in
                switch route {
                case NavigationTarget.Home().route: vm.onTabSelected(NavigationTarget.Home())
                case NavigationTarget.Reflection().route: vm.onTabSelected(NavigationTarget.Reflection())
                case NavigationTarget.SOS().route: vm.onTabSelected(NavigationTarget.SOS())
                case NavigationTarget.Contacts().route: vm.onTabSelected(NavigationTarget.Contacts())
                case NavigationTarget.Profile().route: vm.onTabSelected(NavigationTarget.Profile())
                default: break
                }
            })
        ) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(NavigationTarget.Home().route)

            ReflectionView()
                .tabItem { Label("Reflection", systemImage: "book") }
                .tag(NavigationTarget.Reflection().route)

            SosView()
                .tabItem { Label("SOS", systemImage: "sos.circle.fill") }
                .tag(NavigationTarget.SOS().route)

            ContactView()
                .tabItem { Label("Contacts", systemImage: "person.2") }
                .tag(NavigationTarget.Contacts().route)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
                .tag(NavigationTarget.Profile().route)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
