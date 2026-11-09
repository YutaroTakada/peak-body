import SwiftUI

// 移行メモ（2026-11-09）: 黒×ネオンの PeakTheme は廃止予定。
// 新しい画面・部品は PeakBody/DesignSystem/ のトークン（PeakColor / PeakSpacing /
// PeakRadius / PeakShadow / PeakTypography）を使う。置き換えと
// `.preferredColorScheme(.dark)` の削除は docs/design/design-spec.md の移行計画 PR3〜PR4 で行い、
// すべての参照が無くなった時点でこのファイルを削除する。
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
            .background(PeakTheme.backgroundGradient.ignoresSafeArea())
            .foregroundStyle(PeakTheme.primaryText)
            .tint(PeakTheme.acidLime)
            .preferredColorScheme(.dark)
    }
}

struct PeakScrollableSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(PeakTheme.backgroundGradient)
    }
}

struct PeakNeonGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.label
                .font(.headline)
                .foregroundStyle(PeakTheme.primaryText)

            configuration.content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(PeakTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    PeakTheme.electricPurple.opacity(0.55),
                                    PeakTheme.neonBlue.opacity(0.3),
                                    PeakTheme.border
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: PeakTheme.electricPurple.opacity(0.18), radius: 18, y: 8)
        )
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
