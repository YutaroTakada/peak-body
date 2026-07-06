#!/usr/bin/env bash
# 共通ヘルパー: agents.json の読み込み・ペルソナ注入プロンプトの組み立て
# bash 3.2 互換（連想配列を使わない）

# ワークスペースのルート（このスクリプトの1つ上）
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="$ROOT/agents.json"

die() { echo "エラー: $*" >&2; exit 1; }

[ -f "$REGISTRY" ] || die "agents.json が見つかりません: $REGISTRY"

# 役割が登録簿に存在するか確認
agent_exists() {
  jq -e --arg r "$1" '.agents[$r]' "$REGISTRY" >/dev/null 2>&1
}

# 登録簿から値を取り出す: field <role> <key>
field() {
  jq -r --arg r "$1" --arg k "$2" '.agents[$r][$k] // empty' "$REGISTRY"
}

# 利用可能な役割一覧
list_agents() {
  echo "利用可能なエージェント:"
  jq -r '.agents | to_entries[] | "  \(.key)\t\(.value.description)"' "$REGISTRY" \
    | while IFS=$'\t' read -r name desc; do printf "  %-14s %s\n" "$name" "$desc"; done
}

# ペルソナ + 共通ヘッダ + タスク を結合した起動プロンプトを stdout へ出力
# build_prompt <role> <task>
build_prompt() {
  local role="$1" task="$2"
  local persona_file
  persona_file="$ROOT/$(field "$role" persona)"
  [ -f "$persona_file" ] || die "ペルソナファイルが見つかりません: $persona_file"

  cat "$persona_file"
  printf '\n\n---\n'
  printf 'あなたは「Peak Body」リポジトリで稼働する「%s」エージェントです。\n' "$role"
  printf 'リポジトリ直下の AGENTS.md と、自分の入力元となる docs/ 配下の成果物を必ず読んでから着手してください。\n'
  printf '成果物は %s に保存し、完了後に docs/HANDOFF.md へ追記してください。\n' "$(field "$role" outputs)"
  if [ -n "$task" ]; then
    printf '\n# 今回のタスク\n%s\n' "$task"
  fi
}
