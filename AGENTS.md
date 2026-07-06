# Peak Body — エージェント共通ルール

このファイルはリポジトリ直下にあり、すべてのCodexエージェントが自動的に読み込みます。
各役割の専門性は `agents/<role>.md`、実行設定は `agents.json` で定義します。

## プロダクト

Peak Bodyは、筋トレ・食事／栄養・体重を一括で記録し、それぞれの推移を統合ダッシュボードで確認できるiOSアプリです。

## ディレクトリ規約

- `agents/<role>.md` — エージェントの役割・専門性。
- `agents.json` — エージェント登録簿。
- `docs/requirements/` — 要件定義書、ユーザーストーリー、MVPスコープ。
- `docs/architecture/` — アーキテクチャ、モジュール構成、技術選定記録（ADR）。
- `docs/design/` — 画面設計、デザイン仕様、ユーザーフロー。
- `docs/motion/` — アニメーション、マイクロインタラクション、画面遷移の仕様。
- `docs/backend/` — API仕様、データモデル、バックエンド設計。MVPで不要な場合は判断記録のみ。
- `docs/ios/` — iOSアーキテクチャ、実装判断、テスト方針などの技術文書。
- `docs/reviews/` — コードレビュー所見（重大度別の指摘）。
- `docs/qa/` — テスト計画、テストケース、不具合報告。
- `docs/HANDOFF.md` — エージェント間の引き継ぎ掲示板。
- `tasks/` — 個別タスクの指示書。
- `logs/` — 非対話実行ログ。Git管理対象外。
- アプリ実装コード — Xcodeプロジェクトの既存構成に従う。`docs/ios/` に実装コードを置かない。

## 協調プロトコル

1. 着手前に `docs/HANDOFF.md` と、自分の入力元となる成果物を必ず読む。
2. 自分の担当領域のみ編集する。別領域の変更が必要なら `docs/HANDOFF.md` に依頼を書く。
3. 要件と実装が矛盾する場合は、実装都合で要件を黙って変更しない。
4. 不明点は「要確認」と明記し、作業を止める必要がなければ妥当な仮置きを併記して進める。
5. 完了時に `docs/HANDOFF.md` の末尾へ次の形式で追記する。

```md
## [YYYY-MM-DD HH:MM] <role> → <宛先 or all>
- 完了: <作成・更新内容とファイルパス>
- 依頼: <他エージェントへの依頼。なければ「なし」>
- 注意: <前提・未決事項・リスク>
```

## 役割ごとの入力と出力

- `requirements`: プロダクト構想と既存文書を読み、`docs/requirements/` を更新する。
- `architect`: `docs/requirements/` を読み、`docs/architecture/`（アーキ・モジュール構成・技術選定）を更新する。
- `design`: `docs/requirements/` を読み、`docs/design/` を更新する。
- `motion`: `docs/design/` と `docs/requirements/` を読み、`docs/motion/`（アニメ・遷移仕様）を更新する。
- `backend`: `docs/requirements/` と必要に応じて `docs/design/` を読み、`docs/backend/` を更新・実装する。
- `swift`: `docs/requirements/`、`docs/architecture/`、`docs/design/`、`docs/motion/`、必要に応じて `docs/backend/` を読み、Xcodeプロジェクトと `docs/ios/` を更新する。
- `code-reviewer`: 実装と `docs/architecture/` を読み、`docs/reviews/` に所見を残す（コードは書き換えない）。
- `qa`: `docs/requirements/` の受け入れ条件と実装・`docs/motion/` を読み、`docs/qa/` にテストと不具合報告を作る。

## 共通の作法

- 出力、コメント、ドキュメントは原則日本語。
- 既存ファイルのスタイル、命名、アーキテクチャを優先する。
- 指示されていない大規模リファクタや破壊的変更を行わない。
- ユーザーの既存変更を戻さない。
- 実装変更では、可能な範囲でビルドまたはテストを実行し、未検証事項を明記する。
- 健康関連データを扱うため、ログ、外部送信、権限、端末内保存の扱いを慎重にする。
