# Peak Body マルチエージェント環境

このリポジトリには、iOSアプリ開発に必要な8つのCodexエージェント（要件定義 / アーキテクト / デザイン / モーション / バックエンド / Swift / コードレビュー / QA）が含まれています。UI/UX・アニメーション重視のモダンなアプリを、企画から品質保証まで一気通貫で進められます。

## 前提

- `codex` CLIがインストールされ、ログイン済みであること
- `jq` がインストールされていること

確認:

```bash
codex --version
codex login status
jq --version
```

## エージェント

標準パイプライン: `requirements → architect → design → motion → backend → swift → code-reviewer → qa`

| role | 担当 | 主な出力先 |
|---|---|---|
| `requirements` | 要件定義、ユーザーストーリー、MVPスコープ | `docs/requirements/` |
| `architect` | アーキテクチャ・モジュール構成・技術選定（設計担当） | `docs/architecture/` |
| `design` | 画面設計、UIフロー、デザイン仕様 | `docs/design/` |
| `motion` | アニメーション、マイクロインタラクション、画面遷移 | `docs/motion/` |
| `backend` | バックエンド要否判断、API、データモデル | `docs/backend/` |
| `swift` | SwiftUIアプリとテストの実装 | Xcodeプロジェクト、`docs/ios/` |
| `code-reviewer` | Swift実装のレビュー（修正は依頼ベース） | `docs/reviews/` |
| `qa` | テスト設計、テストケース、不具合報告 | `docs/qa/` |

## Codex Desktopでの利用

`peak-body` をワークスペースとして開いてチャットを開始してください。ルートの `AGENTS.md` が共通ルールとして自動的に読み込まれます。

チャットでは、たとえば次のように依頼できます。

- 「requirementsエージェントを使って未確定要件を整理して」
- 「designとswiftエージェントを使って、ダッシュボード設計と実装方針を並行検討して」
- 「swiftエージェントで体重記録画面を実装して」

## CLIでの利用

役割一覧:

```bash
./scripts/agent.sh
```

対話モード:

```bash
./scripts/agent.sh requirements "既存要件の未確定事項を整理して"
./scripts/agent.sh design "MVPの画面設計を作成して"
./scripts/agent.sh swift
```

非対話実行:

```bash
./scripts/run.sh design "要件をもとに画面設計を作成して" --auto
```

順次実行:

```bash
./scripts/orchestrate.sh "Peak BodyのMVPを設計・実装する" --auto
```

必要な役割だけ実行:

```bash
./scripts/orchestrate.sh "ダッシュボードを具体化する" --auto --only requirements,design
```

## 協調方法

- 共通成果物は `docs/` に保存します。
- 引き継ぎや未決事項は `docs/HANDOFF.md` に記録します。
- 各エージェントの詳細な役割は `agents/<role>.md` にあります。
- モデルや推論強度は `agents.json` で変更できます。
- 非対話実行ログは `logs/` に保存されます。
