// Peak Body デザイントークン: 色
//
// 色の値は Meta Astryx の `neutral` テーマ
// （packages/native/apple/Sources/Astryx/Theme/Generated/NeutralTheme.swift、
//   コミット fe174dd）から、Peak Body で使う役割だけを抜き出して移植したもの。
// Astryx の Swift パッケージには依存しない。仕様の正本は docs/design/design-spec.md。
//
// Copyright (c) 2026 Meta Platforms, Inc.
// Licensed under the MIT License:
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI
import UIKit

/// 端末の外観設定（ライト／ダーク）に追従する色トークン。
/// 画面からは `Color` を直接作らず、必ずこの役割名を使う。
enum PeakColor {
    // MARK: 背景・面

    /// 画面全体の背景（Astryx: backgroundBody）
    static let background = dynamic(light: (0.945, 0.945, 0.945, 1), dark: (0.106, 0.106, 0.106, 1))
    /// カード・グループの面（Astryx: backgroundCard）
    static let surface = dynamic(light: (1, 1, 1, 1), dark: (0.106, 0.106, 0.106, 1))
    /// シート・ポップオーバーなど一段持ち上がった面（Astryx: backgroundSurface）
    static let surfaceRaised = dynamic(light: (1, 1, 1, 1), dark: (0.149, 0.149, 0.149, 1))
    /// 控えめな塗り（チップ、入力欄の下地など。Astryx: neutral）
    static let fillMuted = dynamic(light: (0, 0, 0, 0.059), dark: (1, 1, 1, 0.102))

    // MARK: 境界線

    /// 標準の境界線（Astryx: border）
    static let border = dynamic(light: (0, 0, 0, 0.078), dark: (1, 1, 1, 0.102))
    /// 強調した境界線・区切り（Astryx: borderEmphasized）
    static let borderEmphasized = dynamic(light: (0.831, 0.831, 0.831, 1), dark: (0.322, 0.322, 0.322, 1))

    // MARK: 文字

    /// 本文・数値（Astryx: textPrimary）
    static let textPrimary = dynamic(light: (0, 0, 0, 1), dark: (1, 1, 1, 1))
    /// 補足・ラベル（Astryx: textSecondary）
    static let textSecondary = dynamic(light: (0.278, 0.278, 0.278, 1), dark: (0.620, 0.620, 0.620, 1))
    /// 無効状態（Astryx: textDisabled）
    static let textDisabled = dynamic(light: (0.569, 0.569, 0.569, 1), dark: (0.322, 0.322, 0.322, 1))

    // MARK: アクセント（主要操作）

    /// 主要ボタンの塗り・選択状態（Astryx: accent）
    static let accent = dynamic(light: (0.106, 0.106, 0.106, 1), dark: (0.945, 0.945, 0.945, 1))
    /// accent 上の文字・アイコン（Astryx: onAccent）
    static let onAccent = dynamic(light: (1, 1, 1, 1), dark: (0.067, 0.067, 0.067, 1))
    /// 控えめな選択状態の塗り（Astryx: accentMuted）
    static let accentMuted = dynamic(light: (0.831, 0.831, 0.831, 1), dark: (0.278, 0.278, 0.278, 1))

    // MARK: 状態

    /// 成功（Astryx: success）
    static let success = dynamic(light: (0.098, 0.506, 0, 1), dark: (0.392, 0.686, 0.298, 1))
    /// 警告（Astryx: warning。light/dark 同値。文字色には textWarning 相当を使う）
    static let warning = dynamic(light: (1, 0.808, 0.184, 1), dark: (1, 0.808, 0.184, 1))
    /// 警告の文字（Astryx: textWarning）
    static let textWarning = dynamic(light: (0.514, 0.404, 0, 1), dark: (0.933, 0.769, 0.282, 1))
    /// エラー・削除（Astryx: error）
    static let error = dynamic(light: (0.788, 0.188, 0.227, 1), dark: (1, 0.439, 0.365, 1))
    /// エラーの文字（Astryx: textError）
    static let textError = dynamic(light: (0.753, 0.149, 0.173, 1), dark: (1, 0.682, 0.655, 1))
    /// 情報（Astryx: info）
    static let info = dynamic(light: (0, 0.455, 0.886, 1), dark: (0.427, 0.612, 0.996, 1))

    // MARK: 記録種別（グラフ・カレンダーの記録インジケーター。仮置き、PR3で確定）

    /// 体重（Astryx: dataCategoricalTeal）
    static let recordWeight = dynamic(light: (0.031, 0.639, 0.639, 1), dark: (0.031, 0.639, 0.639, 1))
    /// 食事（Astryx: dataCategoricalOrange）
    static let recordMeal = dynamic(light: (0.922, 0.431, 0, 1), dark: (0.922, 0.431, 0, 1))
    /// 筋トレ（Astryx: dataCategoricalBlue）
    static let recordWorkout = dynamic(light: (0.004, 0.443, 0.890, 1), dark: (0.004, 0.443, 0.890, 1))

    // MARK: 内部

    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    /// ライト／ダークの値を持つ動的カラーを作る。値は sRGB。
    static func dynamic(light: RGBA, dark: RGBA) -> Color {
        Color(uiColor: UIColor { traits in
            let value = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: value.red, green: value.green, blue: value.blue, alpha: value.alpha)
        })
    }
}
