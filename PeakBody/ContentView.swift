import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var localization: AppLocalization

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .settingsAccessButton()
            }
            .tabItem {
                Label(localization.text(.calendar), systemImage: "calendar")
            }

            NavigationStack {
                DashboardView()
                    .settingsAccessButton()
            }
            .tabItem {
                Label(localization.text(.dashboard), systemImage: "chart.xyaxis.line")
            }
        }
        .environment(\.locale, localization.locale)
        .peakScreenBackground()
    }
}
