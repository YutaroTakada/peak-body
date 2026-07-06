#!/usr/bin/env bash
# 対話モードでエージェントを起動する
# 使い方:
#   ./scripts/agent.sh <role> [初期タスク...]
#   ./scripts/agent.sh                       # 役割一覧を表示
# 例:
#   ./scripts/agent.sh requirements "ペット見守りアプリを作りたい"
#   ./scripts/agent.sh swift
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROLE="${1:-}"
if [ -z "$ROLE" ]; then
  list_agents
  echo
  echo "使い方: ./scripts/agent.sh <role> [初期タスク...]"
  exit 0
fi
shift || true
agent_exists "$ROLE" || { echo "未知のエージェント: $ROLE" >&2; echo; list_agents; exit 1; }

TASK="$*"
MODEL="$(field "$ROLE" model)"
EFFORT="$(field "$ROLE" effort)"
SANDBOX="$(field "$ROLE" sandbox)"
PROMPT="$(build_prompt "$ROLE" "$TASK")"

echo "▶ [$ROLE] を対話モードで起動 (model=$MODEL, effort=$EFFORT, sandbox=$SANDBOX)" >&2
exec codex \
  --cd "$ROOT" \
  -m "$MODEL" \
  -c model_reasoning_effort="$EFFORT" \
  -s "$SANDBOX" \
  "$PROMPT"
