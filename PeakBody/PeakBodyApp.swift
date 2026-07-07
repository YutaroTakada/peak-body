import SwiftUI

@main
struct PeakBodyApp: App {
    @StateObject private var recordStore = RecordStore()
    @StateObject private var healthKitService = HealthKitService()
    @StateObject private var localization = AppLocalization()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(recordStore)
                .environmentObject(healthKitService)
                .environmentObject(localization)
                .peakScreenBackground()
        }
    }
}
