// Peak Body デザイントークン: 余白・角丸・サイズ・影
//
// 値は Meta Astryx の `neutral` テーマ
// （packages/native/apple/Sources/Astryx/Theme/Generated/NeutralTheme.swift、
//   コミット fe174dd）の space / radius / size / shadow を移植したもの。
// Astryx の Swift パッケージには依存しない。仕様の正本は docs/design/design-spec.md。
// Copyright (c) 2026 Meta Platforms, Inc. MIT License（全文は PeakColorTokens.swift を参照）。

import SwiftUI

/// 余白（4pt グリッド。Astryx: space）。padding / spacing にはこの値だけを使う。
enum PeakSpacing {
    /// 2pt（Astryx: s0_5）アイコンと文字の微調整のみ
    static let xxxs: CGFloat = 2
    /// 4pt（Astryx: s1）
    static let xxs: CGFloat = 4
    /// 8pt（Astryx: s2）
    static let xs: CGFloat = 8
    /// 12pt（Astryx: s3）
    static let sm: CGFloat = 12
    /// 16pt（Astryx: s4）カード内側・画面左右の標準
    static let md: CGFloat = 16
    /// 20pt（Astryx: s5）
    static let lg: CGFloat = 20
    /// 24pt（Astryx: s6）セクション間
    static let xl: CGFloat = 24
    /// 32pt（Astryx: s8）
    static let xxl: CGFloat = 32
    /// 48pt（Astryx: s12）
    static let xxxl: CGFloat = 48
}

/// 角丸（Astryx: radius）。continuous スタイルで使う。
enum PeakRadius {
    /// 6pt（Astryx: inner）カード内のチップ・小要素
    static let inner: CGFloat = 6
    /// 10pt（Astryx: element）ボタン・入力欄
    static let element: CGFloat = 10
    /// 12pt（Astryx: container）カード・グループ
    static let container: CGFloat = 12
    /// 28pt（Astryx: page）シートなど画面単位の面
    static let page: CGFloat = 28
    // 完全な丸（Astryx: full）は数値ではなく `Capsule()` / `Circle()` を使う。
}

/// サイズ（Astryx: size を iOS 向けに補正）。
enum PeakSize {
    /// 境界線の太さ（Astryx: borderWidth）
    static let borderWidth: CGFloat = 1
    /// タップ領域の最小値。Apple HIG の 44pt。Astryx の element サイズ（28〜36）は
    /// Web 向けのため採用せず、タップできる要素は必ずこの値以上にする。
    static let minTapTarget: CGFloat = 44
}

/// 影の1層。blur は CSS の値、SwiftUI の radius は blur / 2 で近似する。
struct PeakShadowLayer {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

/// 影（Astryx: shadow low / med / high）。近い層と遠い層の2層で重ねる。
/// 発光（色付き）影は使わない。
struct PeakShadow {
    let near: PeakShadowLayer
    let far: PeakShadowLayer

    /// カードなど（Astryx: low = 0 2 4 / 0 4 8）
    static let low = PeakShadow(
        near: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.051), dark: (0, 0, 0, 0.251)), radius: 2, y: 2),
        far: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.102), dark: (0, 0, 0, 0.400)), radius: 4, y: 4)
    )
    /// 浮いたボタン・メニュー（Astryx: med = 0 2 4 / 0 4 12）
    static let med = PeakShadow(
        near: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.051), dark: (0, 0, 0, 0.349)), radius: 2, y: 2),
        far: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.102), dark: (0, 0, 0, 0.502)), radius: 6, y: 4)
    )
    /// シート・ダイアログ（Astryx: high = 0 4 6 / 0 12 24）
    static let high = PeakShadow(
        near: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.102), dark: (0, 0, 0, 0.502)), radius: 3, y: 4),
        far: PeakShadowLayer(color: PeakColor.dynamic(light: (0, 0, 0, 0.149), dark: (0, 0, 0, 0.702)), radius: 12, y: 12)
    )
}

extension View {
    /// トークンの影を適用する。
    func peakShadow(_ shadow: PeakShadow) -> some View {
        self
            .shadow(color: shadow.near.color, radius: shadow.near.radius, x: 0, y: shadow.near.y)
            .shadow(color: shadow.far.color, radius: shadow.far.radius, x: 0, y: shadow.far.y)
    }
}
