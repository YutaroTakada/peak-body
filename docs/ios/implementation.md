# Peak Body iOS 実装メモ

## 2026-07-01 初期MVP実装

### 実装対象

- SwiftUIのiPhone向けアプリプロジェクトを追加。
- 4タブ構成:
  - ホーム
  - 筋トレ
  - 食事
  - 体重
- 体重、食事、筋トレの新規登録、一覧表示、削除。
- ホームで選択日の体重、食事、筋トレを日次サマリー表示。
- ホームから選択日を引き継いで各入力画面を開く。
- 入力中の食事合計、筋トレ総セット数・総ボリュームを表示。
- ローカルJSON保存によるオフライン永続化。
- HealthKitから運動時間、アクティブエネルギー、睡眠時間を読み取り専用で参考表示するサービスを追加。
- アプリ内表示言語設定を追加。日本語・英語を切り替え、主要画面文言を選択言語で表示。
- 画面左下の歯車アイコンから設定画面を表示。配置は `SettingsAccessButtonModifier` に集約。
- 黒基調＋ネオン紫/青/ライムの共通テーマを追加。
- 提供画像の06案を `SplashPeak06.png` として切り出し、起動時スプラッシュに使用。

### 保存方式

要件ではSwiftDataを第一候補としているが、現時点のリポジトリにはXcodeプロジェクトが存在しなかったため、初期実装では依存が少ないローカルJSON保存を採用した。

- 保存先: Application Support配下の `PeakBody/records.json`
- 書き込み: atomic write
- ファイル保護: `completeFileProtectionUnlessOpen`
- 保存失敗時: 画面上で保存済みに見えないよう、メモリ上の変更をロールバック

SwiftDataへ移行する場合も、`Models/Records.swift` の論理モデルと `RecordStore` の公開操作を境界にすれば置き換えやすい。

### HealthKit方針

- 初回起動時に権限要求しない。
- ユーザーがホームの連携操作を選んだ場合のみ読み取り許可を求める。
- 読み取り対象は、アクティブエネルギー、Apple Exercise Time、睡眠分析に限定。
- HealthKitの運動データを手入力の筋トレセッションへ自動変換しない。
- HealthKitの睡眠データは睡眠時間の参考表示のみ。睡眠スコアやステージ分析は行わない。

### 表示言語方針

- `AppLocalization` で対応言語、文言キー、翻訳辞書を集約する。
- View側は直書き文言ではなく `localization.text(...)` を参照する。
- 設定値は `UserDefaults` へ保存する。
- ユーザー入力値（食品名、種目名、メモ）は翻訳しない。
- 将来新言語を追加する場合は、`AppLanguage` と翻訳辞書を追加する。
- 設定入口の位置は `SettingsAccessButtonModifier` のみが持つ。配置変更時はこのmodifierを修正する。

### ブランドテーマ・スプラッシュ方針

- `PeakTheme` で背景、面、境界線、ネオンアクセント色を集約する。
- 主要画面は `peakScreenBackground`、List/Formは `peakScrollableSurface` を使って暗色背景へ統一する。
- ホームのカードは `PeakNeonGroupBoxStyle` で暗い面とネオン境界線に寄せる。
- スプラッシュは `AppRootView` が起動直後に約1.3秒表示し、その後 `ContentView` へフェード遷移する。
- スプラッシュ画像は `PeakBody/Resources/SplashPeak06.png` に配置し、Bundle Resourceとして登録する。

### 未実装・次に必要な作業

- 保存済み記録の編集画面。
- 削除確認ダイアログ。
- 7日 / 30日 / 90日の推移グラフ。
- SwiftData採用可否の再判断。
- Xcode本体がある環境でのiOS Simulatorビルド。
- HealthKit Capabilityの実機署名確認。
- Info.plist権限文言の多言語化。現在のアプリ内言語設定とは別に、OSの権限ダイアログ向けローカライズが必要。
- スプラッシュ表示時間、画像トリミング、ネオンテーマの可読性を実機/Simulatorで確認。

### 検証状況

- `plutil -lint` で `Info.plist`、entitlements、pbxprojの構文チェック済み。
- `swiftc -typecheck` でSwift構文レベルのチェック済み。
- この環境はCommand Line Toolsのみで、`xcodebuild` と `iphonesimulator` SDKが利用できないため、iOSビルドは未検証。
