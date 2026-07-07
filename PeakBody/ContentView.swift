import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var localization: AppLocalization

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(localization.text(.home), systemImage: "house.fill")
            }

            NavigationStack {
                WorkoutListView()
            }
            .tabItem {
                Label(localization.text(.workout), systemImage: "figure.strengthtraining.traditional")
            }

            NavigationStack {
                MealListView()
            }
            .tabItem {
                Label(localization.text(.meal), systemImage: "fork.knife")
            }

            NavigationStack {
                BodyWeightListView()
            }
            .tabItem {
                Label(localization.text(.bodyWeight), systemImage: "scalemass.fill")
            }
        }
        .environment(\.locale, localization.locale)
        .settingsAccessButton()
        .peakScreenBackground()
    }
}
