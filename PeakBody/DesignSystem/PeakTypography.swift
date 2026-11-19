// Peak Body デザイントークン: 文字の役割
//
// 役割の名前は Meta Astryx のタイプスケール（display / heading / body / label /
// supporting。packages/core/src/theme/tokens.stylex.ts）に合わせる。
// サイズは固定値ではなく iOS の Dynamic Type のテキストスタイルに対応づけ、
// フォントは SF Pro（システムフォント）を使う。仕様の正本は docs/design/design-spec.md。

import SwiftUI

/// 文字の役割。`.font(...)` には原則この役割だけを使う。
enum PeakTypography {
    /// 画面の主役になる大きな数値・見出し（Astryx: display3 相当）
    static let display = Font.system(.largeTitle, design: .default).weight(.bold)
    /// 画面タイトル（Astryx: heading1 相当）
    static let title = Font.system(.title2, design: .default).weight(.semibold)
    /// セクション・カードの見出し（Astryx: heading3 相当）
    static let heading = Font.system(.headline, design: .default)
    /// 本文（Astryx: body 相当）
    static let body = Font.system(.body, design: .default)
    /// ボタン・入力ラベル（Astryx: label 相当）
    static let label = Font.system(.subheadline, design: .default).weight(.medium)
    /// 補足説明・単位・日付（Astryx: supporting 相当）
    static let supporting = Font.system(.footnote, design: .default)
    /// 最小の注記（Astryx: heading5 / supporting の下限）
    static let caption = Font.system(.caption, design: .default)
    /// 体重・kcal・重量などの数値（桁揃え）。`.monospacedDigit()` と同等。
    static let metric = Font.system(.title3, design: .default).weight(.semibold).monospacedDigit()
}
