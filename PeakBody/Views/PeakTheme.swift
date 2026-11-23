import SwiftUI

// 移行メモ（2026-11-23）: 黒×ネオンの PeakTheme は廃止予定。
// 新しい画面・部品は PeakBody/DesignSystem/ のトークン（PeakColor / PeakSpacing /
// PeakRadius / PeakShadow / PeakTypography）を使う。
// PR3 で画面の背景修飾子をトークンへ切り替え、`.preferredColorScheme(.dark)` を削除した。
// 残る参照はスプラッシュ（SplashView.swift）だけ。扱いは design-spec.md §8 PR6 で決め、
// 参照が無くなった時点でこのファイルを削除する。
enum PeakTheme {
    static let background = Color(red: 0.015, green: 0.017, blue: 0.025)
    static let surface = Color.white.opacity(0.055)
    static let elevatedSurface = Color.white.opacity(0.085)
    static let border = Color.white.opacity(0.14)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.68)
    static let electricPurple = Color(red: 0.66, green: 0.13, blue: 1.0)
    static let neonBlue = Color(red: 0.0, green: 0.78, blue: 1.0)
    static let acidLime = Color(red: 0.66, green: 1.0, blue: 0.0)

    static let neonGradient = LinearGradient(
        colors: [acidLime, electricPurple, neonBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color.black,
            background,
            Color(red: 0.035, green: 0.015, blue: 0.08)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct PeakScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PeakColor.background.ignoresSafeArea())
            .tint(PeakColor.accent)
    }
}

struct PeakScrollableSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(PeakColor.background)
    }
}

extension View {
    func peakScreenBackground() -> some View {
        modifier(PeakScreenBackground())
    }

    func peakScrollableSurface() -> some View {
        modifier(PeakScrollableSurface())
    }
}
