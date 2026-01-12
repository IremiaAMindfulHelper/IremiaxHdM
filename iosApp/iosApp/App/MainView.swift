import SwiftUI
import Shared

struct MainView: View {
    @StateObject private var vm = MainViewModelWrapper()

    var body: some View {
        ZStack {
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
                    .tabItem { Label(StringsKt.localized(res: SharedRes.strings().home).localized(), systemImage: "house") }
                    .tag(NavigationTarget.Home().route)

            
                JournalMainViewPanicAttacks()
                    .tabItem { Label(StringsKt.localized(res: SharedRes.strings().reflection).localized(), systemImage: "book") }
                    .tag(NavigationTarget.Reflection().route)

                SosView()
                    .tabItem { Label(StringsKt.localized(res: SharedRes.strings().sos).localized(), systemImage: "sos.circle.fill") }
                    .tag(NavigationTarget.SOS().route)

                ContactView()
                    .tabItem { Label(StringsKt.localized(res: SharedRes.strings().contacts).localized(), systemImage: "person.2") }
                    .tag(NavigationTarget.Contacts().route)

                ProfileView()
                    .tabItem { Label(StringsKt.localized(res: SharedRes.strings().profile).localized(), systemImage: "person.circle") }
                    .tag(NavigationTarget.Profile().route)
            }

            //Popup ÜBER der TabBar (weil außerhalb der TabView)
            if vm.currentTarget.route == NavigationTarget.Reflection().route {
                JournalMainPopUpView()
                    .ignoresSafeArea()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
