import SwiftUI
import Shared

struct MainView: View {
    // ViewModel-Wrapper für Tab-Navigation aus dem Shared-Modul.
    @StateObject private var vm = MainViewModelWrapper()

    var body: some View {
        TabView(selection: tabSelectionBinding) {

            HomeView()
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().home).localized(),
                        systemImage: "house"
                    )
                }
                .tag(NavigationTarget.Home().route)

            JournalNavigationView()
                .tabItem {
                    Label("Journal", systemImage: "book.circle")
                }
                .tag(NavigationTarget.Reflection().route)

            SosView()
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().sos).localized(),
                        systemImage: "sos.circle.fill"
                    )
                }
                .tag(NavigationTarget.SOS().route)

            ContactView()
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().contacts).localized(),
                        systemImage: "person.2"
                    )
                }
                .tag(NavigationTarget.Contacts().route)

            ProfileView()
                .tabItem {
                    Label(
                        StringsKt.localized(res: SharedRes.strings().profile).localized(),
                        systemImage: "person.circle"
                    )
                }
                .tag(NavigationTarget.Profile().route)
        }
    }

    // Verbindet die SwiftUI-Tab-Auswahl mit dem aktuellen Shared-Navigation-Target.
    private var tabSelectionBinding: Binding<ResourcesStringResource> {
        Binding(
            get: { vm.currentTarget.route },
            set: { route in
                handleTabSelection(route: route)
            }
        )
    }

    // Leitet die Tab-Auswahl an das ViewModel weiter.
    private func handleTabSelection(route: ResourcesStringResource) {
        switch route {
        case NavigationTarget.Home().route:
            vm.onTabSelected(NavigationTarget.Home())

        case NavigationTarget.Reflection().route:
            vm.onTabSelected(NavigationTarget.Reflection())

        case NavigationTarget.SOS().route:
            vm.onTabSelected(NavigationTarget.SOS())

        case NavigationTarget.Contacts().route:
            vm.onTabSelected(NavigationTarget.Contacts())

        case NavigationTarget.Profile().route:
            vm.onTabSelected(NavigationTarget.Profile())

        default:
            break
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
