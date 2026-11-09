# Peak Body デザイン仕様（デザイントークン）

作成日: 2026-11-09
ステータス: 承認済み方針（2026-11-09 ユーザー承認）に基づく初版
コードの正本: `PeakBody/DesignSystem/`（`PeakColorTokens.swift` / `PeakLayoutTokens.swift` / `PeakTypography.swift`）

---

## 1. 方針

- 黒×ネオン（紫・青・ライム、グラデーション、発光する影）をやめ、落ち着いたニュートラル系の見た目にする。
- 端末の外観設定に従い、ライトとダークの両方に対応する。色トークンは両モードの値を持つ。
- フォントはSF Pro（システムフォント）のまま。Dynamic Typeを壊さない。
- 参考にするのはMetaのデザインシステム [Astryx](https://github.com/meta/astryx)（MITライセンス、参照コミット `fe174dd`）。Astryxの部品やSwiftパッケージは依存に入れず、**トークンの語彙と値、使い方の原則だけ**を自前のSwiftUI層に移す。
  - 色・余白・角丸・影の値: `packages/native/apple/Sources/Astryx/Theme/Generated/NeutralTheme.swift`（`neutral` テーマ）
  - トークンの語彙: `packages/core/src/theme/tokens.stylex.ts`、`docs/architecture/theme-tokens.md`
  - 比較対象: `StoneTheme.swift`（`stone` テーマ）。stoneは状態色（success/error）まで灰色寄りで記録アプリの成功・削除が見分けにくいため、ベースはneutralにした。
- 値を移植したファイルにはAstryxのMIT著作権表示を記載している。

### 1.1 Astryx から移さないもの

- 部品（Button、Card など）のWeb実装。部品はPR2でSwiftUIで作る。
- フォントファミリー（Figtree / Montserrat）。SF Proを使う。
- 固定の文字サイズ（14px基準）。iOSのDynamic Typeのテキストスタイルに対応づける。
- 要素サイズ（28〜36px）。iOSではタップ領域44pt以上を優先する。
- シンタックスハイライト、data系の5段階パレット（必要になったら追加する）。

## 2. 色

画面からは `Color(red:...)` や `Color.white.opacity(...)` を直接書かず、`PeakColor` の役割名を使う。値はsRGB。

### 2.1 背景・面・境界線

| トークン | 役割 | ライト | ダーク | Astryx名 |
|---|---|---|---|---|
| `PeakColor.background` | 画面全体の背景 | `#F1F1F1` | `#1B1B1B` | backgroundBody |
| `PeakColor.surface` | カード・グループの面 | `#FFFFFF` | `#1B1B1B` | backgroundCard |
| `PeakColor.surfaceRaised` | シートなど一段上の面 | `#FFFFFF` | `#262626` | backgroundSurface |
| `PeakColor.fillMuted` | チップ・入力欄の下地 | `#000000` 6% | `#FFFFFF` 10% | neutral |
| `PeakColor.border` | 標準の境界線 | `#000000` 8% | `#FFFFFF` 10% | border |
| `PeakColor.borderEmphasized` | 強い区切り | `#D4D4D4` | `#525252` | borderEmphasized |

ダークではカードと背景が同じ色（`#1B1B1B`）になる。カードの輪郭は `border` で示す（Astryx neutralの設計どおり）。

### 2.2 文字

| トークン | 役割 | ライト | ダーク | Astryx名 |
|---|---|---|---|---|
| `PeakColor.textPrimary` | 本文・数値 | `#000000` | `#FFFFFF` | textPrimary |
| `PeakColor.textSecondary` | 補足・ラベル | `#474747` | `#9E9E9E` | textSecondary |
| `PeakColor.textDisabled` | 無効状態 | `#919191` | `#525252` | textDisabled |

### 2.3 アクセント（主要操作）

アクセントは色相を持たない（ライトでは黒に近く、ダークでは白に近い）。色で目立たせるのではなく、塗りとコントラストで主要操作を示す。

| トークン | 役割 | ライト | ダーク | Astryx名 |
|---|---|---|---|---|
| `PeakColor.accent` | 主要ボタンの塗り・選択状態・`tint` | `#1B1B1B` | `#F1F1F1` | accent |
| `PeakColor.onAccent` | accent上の文字・アイコン | `#FFFFFF` | `#111111` | onAccent |
| `PeakColor.accentMuted` | 控えめな選択状態 | `#D4D4D4` | `#474747` | accentMuted |

### 2.4 状態

| トークン | 役割 | ライト | ダーク | Astryx名 |
|---|---|---|---|---|
| `PeakColor.success` | 保存完了・目標達成 | `#198100` | `#64AF4C` | success |
| `PeakColor.warning` | 注意の塗り | `#FFCE2F` | `#FFCE2F` | warning |
| `PeakColor.textWarning` | 注意の文字 | `#836700` | `#EEC448` | textWarning |
| `PeakColor.error` | エラー・削除 | `#C9303A` | `#FF705D` | error |
| `PeakColor.textError` | エラー文言 | `#C0262C` | `#FFAEA7` | textError |
| `PeakColor.info` | 情報・HealthKit参考表示 | `#0074E2` | `#6D9CFE` | info |

### 2.5 記録種別（グラフ・カレンダーの記録インジケーター）

**仮置き。PR3でカレンダーと推移グラフを作るときに確定する。** 既存のライム／紫／青の割り当て（`calendar-dashboard-uiux-plan.md` §5.1）を置き換える。色だけに頼らず、位置やアイコンでも区別する。

| トークン | 記録 | 値（両モード同じ） | Astryx名 |
|---|---|---|---|
| `PeakColor.recordWeight` | 体重 | `#08A3A3` | dataCategoricalTeal |
| `PeakColor.recordMeal` | 食事 | `#EB6E00` | dataCategoricalOrange |
| `PeakColor.recordWorkout` | 筋トレ | `#0171E3` | dataCategoricalBlue |

## 3. 余白（`PeakSpacing`）

4ptグリッド。Astryx の `space` から使う段だけを名前付きで持つ。

| トークン | 値 | Astryx名 | 主な用途 |
|---|---|---|---|
| `xxxs` | 2 | s0_5 | アイコンと文字の微調整のみ |
| `xxs` | 4 | s1 | ラベルと値の間 |
| `xs` | 8 | s2 | 行内の要素間 |
| `sm` | 12 | s3 | カード内の項目間 |
| `md` | 16 | s4 | カードの内側、画面の左右 |
| `lg` | 20 | s5 | |
| `xl` | 24 | s6 | セクション間 |
| `xxl` | 32 | s8 | 大きな区切り |
| `xxxl` | 48 | s12 | 空状態の上下 |

## 4. 角丸（`PeakRadius`）

`RoundedRectangle(cornerRadius:style: .continuous)` で使う。

| トークン | 値 | Astryx名 | 用途 |
|---|---|---|---|
| `inner` | 6 | inner | カード内のチップ・小要素 |
| `element` | 10 | element | ボタン・入力欄 |
| `container` | 12 | container | カード・グループ |
| `page` | 28 | page | シートなど画面単位の面 |

完全な丸（Astryx: full）は数値ではなく `Capsule()` / `Circle()` を使う。今の `PeakTheme` の22や14は廃止する。

## 5. 影（`PeakShadow`）

色付きの影や発光は使わない。黒の影を2層重ねる。SwiftUIの `radius` はCSSのblurの半分で近似する。`view.peakShadow(.low)` で使う。

| トークン | 用途 | 層（y / blur） | ライトの不透明度 | ダークの不透明度 |
|---|---|---|---|---|
| `low` | カード（必要な場合のみ） | 2/4 + 4/8 | 5% + 10% | 25% + 40% |
| `med` | 浮いたボタン・メニュー | 2/4 + 4/12 | 5% + 10% | 35% + 50% |
| `high` | シート・ダイアログ | 4/6 + 12/24 | 10% + 15% | 50% + 70% |

基本はカードを境界線（`border`）で区切り、影は浮いている要素だけに使う。

## 6. 文字の役割（`PeakTypography`）

役割名はAstryxのタイプスケールに合わせ、サイズはDynamic Typeのテキストスタイルに対応づける。固定ポイントの `.font(.system(size:))` は使わない。

| トークン | テキストスタイル | ウェイト | Astryxの対応 | 用途 |
|---|---|---|---|---|
| `display` | largeTitle | bold | display3 | 画面の主役の数値・見出し |
| `title` | title2 | semibold | heading1 | 画面タイトル |
| `heading` | headline | （標準） | heading3 | カード・セクション見出し |
| `body` | body | regular | body | 本文 |
| `label` | subheadline | medium | label | ボタン・入力ラベル |
| `supporting` | footnote | regular | supporting | 補足・単位・日付 |
| `caption` | caption | regular | heading5 | 最小の注記 |
| `metric` | title3 | semibold・等幅数字 | large | 体重・kcal・重量などの数値 |

## 7. ルール

1. **トークン外のマジックナンバーを書かない。** 色・余白・角丸・影・文字サイズは `PeakColor` / `PeakSpacing` / `PeakRadius` / `PeakShadow` / `PeakTypography` を使う。足りない値が必要なら、先にこの文書とトークンに追加する。レイアウト上どうしても必要な一回限りの値（画像の縦横比など）は、理由をコメントに書く。
2. **色は役割で選ぶ。** 「黒い」「灰色」ではなく「本文」「補足」「境界線」で選ぶ。ライトとダークの両方で確認する。
3. **グラデーションと発光する影を使わない。** 強調は塗り（`accent`）、太さ、余白で示す。
4. **タップ領域は44pt以上**（`PeakSize.minTapTarget`）。見た目が小さいアイコンも `frame(minWidth:minHeight:)` か `contentShape` で領域を確保する。
5. **Dynamic Typeを壊さない。** 文字は `PeakTypography` のテキストスタイルを使い、固定の高さで文字を切らない。アクセシビリティサイズで折り返せるようにする。
6. **色だけで意味を伝えない。** 状態・記録種別はアイコン、文言、位置でも区別する。
7. **コントラスト。** 本文は `textPrimary`、補足は `textSecondary` を背景・面の上でだけ使う。`textDisabled` は無効状態以外に使わない。
8. **外観の固定をしない。** `.preferredColorScheme(.dark)` は移行完了（PR3）で削除し、以後は使わない。

## 8. 移行計画

各段階をPR1本で出す。各PRでCI（macOSのxcodebuild）が通ることを確認する。

| PR | 内容 | 見た目の変化 |
|---|---|---|
| PR1（本PR） | この文書、トークン層（`PeakBody/DesignSystem/`）、要件のFR-8 / Q-18の書き換え | なし（既存の `PeakTheme` をそのまま使う） |
| PR2 | 共通部品: カード、数値表示（`SummaryMetricView` 相当）、空状態、ボタン、設定入口ボタン。トークンだけで作る | なし（部品を追加するだけ。画面にはまだ使わない） |
| PR3 | アプリの外枠（タブ、`peakScreenBackground` / `peakScrollableSurface`）とホームを新部品へ置き換え、`.preferredColorScheme(.dark)` を削除してライト／ダーク対応にする。記録種別の色を確定 | あり（ここで見た目が切り替わる） |
| PR4 | 記録3タブ（筋トレ・食事・体重）と設定画面を置き換え。`PeakTheme` の参照を無くし、`PeakTheme.swift` を削除 | あり |
| PR5 | 残りのドキュメント整合（`calendar-dashboard-uiux-plan.md` の色の記述、`docs/ios/implementation.md`、スプラッシュ画像の扱い） | 判断次第 |

### 8.1 要確認

- スプラッシュ画像（`SplashPeak06.png`）はネオンの山型グラフで、新方針と合わない。差し替えるか、当面残すかはPR5までに決める（仮置き: 当面残す）。
- 記録種別の色（§2.5）はPR3で実機・Simulatorのライト／ダーク両方で確認して確定する。
- PR3で外観の固定を外すと、PR4までの間は記録3タブと設定がライトモードで旧テーマのまま表示される。PR3とPR4の間ではTestFlightへ配信しない（仮置き）。
