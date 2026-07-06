import SwiftUI

struct AppRootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            if isShowingSplash {
                PeakSplashView()
                    .transition(.opacity.combined(with: .scale(scale: 1.015)))
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(1300))
            withAnimation(.easeInOut(duration: 0.45)) {
                isShowingSplash = false
            }
        }
    }
}

struct PeakSplashView: View {
    var body: some View {
        ZStack {
            PeakTheme.backgroundGradient
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    PeakTheme.electricPurple.opacity(0.35),
                    PeakTheme.neonBlue.opacity(0.16),
                    .clear
                ],
                center: .bottom,
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()

            Image("SplashPeak06")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 22)
                .shadow(color: PeakTheme.electricPurple.opacity(0.55), radius: 26, y: 14)
                .accessibilityLabel("Peak Body")
        }
    }
}
