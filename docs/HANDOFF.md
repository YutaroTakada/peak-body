# HANDOFF — Peak Body エージェント間引き継ぎ

各エージェントは作業完了時に、このファイルの末尾へ引き継ぎを追記してください。

```md
## [YYYY-MM-DD HH:MM] <role> → <宛先 or all>
- 完了: <作成・更新内容とファイルパス>
- 依頼: <他エージェントへの依頼。なければ「なし」>
- 注意: <前提・未決事項・リスク>
```

---

## [2026-06-26 02:12] requirements → design / backend / swift
- 完了: Peak BodyのMVP要件、ユーザーストーリー、スコープを作成（docs/requirements/requirements.md, docs/requirements/user-stories.md, docs/requirements/scope.md）
- 依頼: designは4領域のナビゲーション・入力UI・統合ダッシュボードを仕様化、swiftはSwiftDataとSwift Chartsを前提に実装方針を検討、backendはMVPでは実装不要
- 注意: iOS 17以上、端末内保存、kg/kcal/g、食事はカロリー必須・PFC任意、グラフ期間は7/30/90日で仮置き。Apple Health、食品DB、バーコード、AI提案、クラウド同期はMVP対象外

## [2026-06-26 02:24] setup → all
- 完了: Peak Bodyリポジトリ内にマルチエージェント実行環境を整備（AGENTS.md, agents.json, agents/, scripts/）
- 依頼: 各担当は着手前にAGENTS.md、docs/HANDOFF.md、自分の入力元文書を読むこと
- 注意: 成果物の正本はdocs/配下。Swift実装コードはdocs/ios/ではなくXcodeプロジェクトへ配置する

## [2026-06-26 02:35] requirements → design / swift
- 完了: 画面構成、画面別の表示・操作・状態・入力短縮要件を定義（docs/requirements/screens.md）。1日の体重・食事内容・トレーニング実績をまとめるホームをMustへ追加し、requirements.md、user-stories.md、scope.mdへ反映
- 依頼: designはSCR-01を中心に4タブ、クイック追加、各入力画面の具体UIと遷移を設計。swiftは選択日の引き継ぎ、保存後の即時集計、セット値複製、入力中合計を実装可能な構造で検討
- 注意: 推移画面の配置、食事区分の推定時間帯、ホームカード順、最近使った種目・食品の再利用、体重差分はscreens.mdのSQ-01〜SQ-07として仮置き

## [2026-07-01 21:51] requirements / swift → design / swift / qa
- 完了: HealthKitをMustから外し、読み取り専用の任意参考表示として要件を更新（docs/requirements/requirements.md, docs/requirements/screens.md, docs/requirements/scope.md, docs/requirements/user-stories.md）。SwiftUIアプリの初期MVP縦切りを追加（PeakBody.xcodeproj, PeakBody/）。体重・食事・筋トレの登録/一覧/削除、選択日のホームサマリー、ローカルJSON保存、HealthKit参考カードを実装。iOS実装メモを作成（docs/ios/implementation.md）
- 依頼: designはホームのHealthKit参考カードを主記録より低優先で扱うUIを詰める。swiftは次に編集画面、削除確認、7/30/90日推移グラフ、SwiftData移行可否を検討。qaはXcode本体がある環境でSimulatorビルド、HealthKit権限拒否/許可/データなしを確認
- 注意: 現環境はCommand Line ToolsのみでiOS SDKとxcodebuildが利用不可。Swift構文typecheck、plist/pbxproj構文、xcscheme XML、git diff --checkは通過。HealthKitは初回表示では権限要求せず、ユーザー操作時のみ読み取り許可を求める

## [2026-07-02 02:59] requirements / swift → design / swift / qa
- 完了: 日本語・英語のアプリ内表示言語設定を要件化し、SwiftUI実装へ追加（PeakBody/Localization/AppLocalization.swift, PeakBody/Views/SettingsView.swift）。左下の歯車アイコンから設定画面を開き、表示言語を切り替え可能。既存主要画面のタブ名、見出し、ボタン、入力ラベル、エラー、空状態を共通ローカライズ定義へ移行。要件・画面要件・ユーザーストーリー・スコープ・iOS実装メモを更新
- 依頼: designは左下歯車ボタンが主要操作やタブバーと干渉しないか確認し、最終配置を指定。swiftは新言語追加時の辞書追加ルール、Info.plist権限文言のOS向け多言語化、Xcode実機/Simulatorビルドを継続確認。qaは日本語/英語切替後の全主要画面、再起動後の言語保持を確認
- 注意: 設定ボタン位置は SettingsAccessButtonModifier に集約。表示言語変更ではユーザー入力した食品名・種目名・メモは翻訳しない。RecordStore/HealthKitService/AppLocalizationはCLI検証安定性のためObservableObjectへ統一。swiftc typecheck、plist/pbxproj lint、xcscheme XML、git diff --checkは通過

## [2026-07-02 17:22] requirements / design / swift → design / swift / qa
- 完了: 参考画像の06案を `PeakBody/Resources/SplashPeak06.png` として切り出し、起動時スプラッシュを追加（PeakBody/Views/SplashView.swift）。黒基調＋ネオン紫/青/ライムの共通テーマを追加（PeakBody/Views/PeakTheme.swift）し、ホーム、List/Form、カード、設定ボタンへ適用。Xcodeプロジェクトへ新規SwiftファイルとPNGリソースを登録。要件・画面要件・ユーザーストーリー・スコープ・iOS実装メモを更新
- 依頼: designはスプラッシュのトリミング、表示時間、ネオン色の強さ、カード境界線の視認性を実機/Simulatorで確認。swiftはXcode本体環境で起動表示とホーム遷移、Bundle画像読み込みを確認。qaは起動直後のスプラッシュ、自動遷移、言語切替後のテーマ崩れを確認
- 注意: スプラッシュ表示は約1.3秒で仮置き。現環境ではiOS Simulatorビルド不可のため、swiftc typecheck、plist/pbxproj lint、xcscheme XML、git diff --checkまで確認済み

## [2026-07-07] design(UIUX計画) → PM / requirements / architect / design / swift / qa
- 完了: カレンダーホーム×ダッシュボードへのUI/UX再設計計画書を作成（docs/design/calendar-dashboard-uiux-plan.md）。新3タブ構成（カレンダーホーム/ダッシュボード/履歴ハブ）、日セル記録インジケーター、SCR-01v2/03/05/WGT-01の画面仕様、Phase 0-3のワークパッケージ分解（WP-01〜33、担当・依存・受け入れ条件付き）を定義
- 依頼: PMは計画書§11のQ-01〜Q-03（3タブ承認、ダッシュボードカード順、ストリーク定義）をユーザー確認後、Phase 0（WP-01 requirements文書更新、WP-02 architectデータ層設計、WP-03 designモック）から発注すること
- 注意: ウィジェット（Phase 3）はApp Group移行が前提。既存の入力・詳細・履歴画面は無変更で流用し、変更はContentView/HomeView/RecordStoreに限定する方針。screens.mdのSQ-01/SQ-02は本計画で決定内容が変わる（§10参照）

## [2026-11-09 22:13] design / swift → design / swift / qa / requirements
- 完了: デザイン一新のPR1。MetaのAstryx（neutralテーマ、コミット fe174dd、MIT）を参考にデザイン仕様を作成（docs/design/design-spec.md）。色（ライト／ダーク）・余白・角丸・影・文字の役割のトークン層を追加（PeakBody/DesignSystem/PeakColorTokens.swift, PeakLayoutTokens.swift, PeakTypography.swift）し、Xcodeプロジェクトの DesignSystem グループとSourcesへ登録。FR-8 / Q-18 ほか「黒×ネオン」「ダーク前提」の要件をニュートラル系のライト／ダーク両対応へ書き換え（docs/requirements/requirements.md, scope.md, screens.md, user-stories.md。2026-11-09 ユーザー承認）。カレンダー計画書にはビジュアルは design-spec.md に従う旨の注記のみ追加。PeakTheme.swift には移行コメントのみ追加
- 依頼: swiftはPR2で共通部品（カード、数値表示、空状態、ボタン、設定入口）をトークンだけで作る。PR3で外枠とホームを置き換え、.preferredColorScheme(.dark) を削除。designは記録種別の色（design-spec.md §2.5、仮置き）とスプラッシュ画像の扱いを決める。qaはPR3以降でライト／ダーク両方とDynamic Typeの表示を確認
- 注意: 本PRでは画面の見た目は変えていない（新トークンは未使用）。色はUIColorのdynamicProviderで実装（Asset Catalogは未使用）。Linux環境のためxcodebuild不可で、ビルド確認はCI（macOS）に依存。Astryxの値を移植したファイルにはMIT著作権表示を記載。PR3〜PR4の間は記録タブがライトで旧テーマのままになるため、その間はTestFlightへ配信しない仮置き

## [2026-11-18 01:45] requirements / design → swift / qa / design
- 完了: 画面構成のシンプル化を要件と計画へ反映（docsのみ、コード変更なし。2026-11-18 ユーザー承認）。4タブをカレンダー／ダッシュボードの2タブへ変更し、設定は左下歯車のまま（docs/requirements/requirements.md §6・FR-4・FR-5.1・FR-5.2・FR-5.3・NFR-3・NFR-5・Q-19、docs/requirements/screens.md §2.1・§2.2・SCR-01/02/10/20/30・SQ-01/02/06/08、docs/requirements/scope.md、docs/requirements/user-stories.md US-01/40/44/45）。カレンダー計画書は2タブで確定とし、ストリーク・ウィジェット（Phase 3）・履歴ハブを中止として記録（docs/design/calendar-dashboard-uiux-plan.md §3.1・§10・§11・§12）。デザイン移行計画をPR2〜PR6へ組み直し（docs/design/design-spec.md §8）
- 依頼: swiftはPR2（共通部品）→PR3（2タブ、月間カレンダー、日詳細、強制ダーク削除）→PR4（詳細・編集・削除確認、フォームと設定の移行、PeakTheme削除）→PR5（ダッシュボード、Swift Charts）の順で実装。qaはPR3以降でカレンダーの日付境界・週開始曜日・ライト／ダーク・Dynamic Type・HealthKit未連携時の表示を確認
- 注意: 消費カロリーはHealthKitのアクティブエネルギーを読み取るだけで、保存・端末外送信はしない。現行の `HealthKitService.isEnabled` は保存されず起動ごとに未連携へ戻るため、PR3で扱いを決める（連携状態フラグの保存はHealthKitの値の保存には当たらない想定、要確認）。編集・削除確認はMustのまま未実装でPR4で対応。種目別ベスト一覧と頻度ヒートマップの扱いは未決（仮置き: 作らない）。運動時間・睡眠時間の参考表示はShouldのまま残した

## [2026-11-23 17:41] swift / design → qa / swift / design
- 完了: design-spec.md §8 の PR2（共通部品）と PR3（2タブ、月間カレンダー、日詳細、外観の固定の削除）を1本のPRで実装（ブランチ feature/calendar-shell）。共通部品 `PeakCard` / `PeakPrimaryButtonStyle` / `PeakSecondaryButtonStyle` / `PeakIconButton` / `recordEntryDate(on:)` を追加し、`SummaryMetricView` / `EmptyRecordView` をトークンへ移行（PeakBody/Views/SharedComponents.swift）。タブをカレンダー／ダッシュボードの2つにし（PeakBody/ContentView.swift）、月間カレンダー（PeakBody/Views/MonthCalendarView.swift、新規）と日詳細（PeakBody/Views/HomeView.swift を置き換え）を作成。ダッシュボードは1文だけの仮画面（PeakBody/Views/DashboardView.swift、新規）。種類別の一覧は選択日の記録だけを表示し、追加時は選択日を引き継ぐ（Workout/Meal/BodyWeightViews.swift）。`RecordStore.recordFlags(in:)` と `DayRecordFlags` を追加（保存形式は変更なし）。`.preferredColorScheme(.dark)` を削除し、背景の修飾子をトークンへ切り替え（PeakBody/Views/PeakTheme.swift、未使用の `PeakNeonGroupBoxStyle` を削除）。設定ボタンを各タブのルート画面だけに置き、トークン化（PeakBody/Views/SettingsView.swift）。HealthKit連携のオン／オフだけを UserDefaults（`healthKit.isEnabled`）に保存（PeakBody/Services/HealthKitService.swift）。design-spec.md §2.5・§4.1・§8.0・§8.1 を更新
- 依頼: qa はカレンダーの週開始曜日（日曜／月曜）、月末・うるう年、未来日の無効、今日ボタン、記録の追加・削除後の印の即時反映、ライト／ダーク、Dynamic Type（最大はカレンダーだけ accessibility1 で頭打ち）、VoiceOver の日セル読み上げ、HealthKit 未連携・拒否・データなしの表示を確認。swift は PR4 で詳細・編集・削除確認とフォーム・設定の移行、PR5 でダッシュボード
- 注意: 消費カロリーは HealthKit から読み取るだけで、値は保存・送信しない。保存するのは連携のオン／オフだけ（2026-11-18 の「仮に決めたこと」4、#3 のマージで承認扱い）。日詳細の並びは screens.md SQ-06 の仮置き（体重、食事、筋トレ、消費カロリー）のまま。カレンダーの印は1色・位置で区別し、記録種別の3色は使っていない（PR5で扱いを決める）。一覧のスワイプ削除は確認なしのまま（PR4で削除確認を入れる）。スプラッシュは旧テーマのまま（PR6）。L10nKey の .home / .previousDay / .nextDay / .backToToday / .noXxxRecords は未使用になったが、差分を小さくするため残した
