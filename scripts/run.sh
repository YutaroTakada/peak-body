#!/usr/bin/env bash
# 非対話モードでエージェントを1回実行する（codex exec）
# 使い方:
#   ./scripts/run.sh <role> "タスク内容" [--auto] [--full-auto]
# オプション:
#   --auto       承認なしで自動実行（sandbox=workspace-write のまま、approval=never）
#   --full-auto  サンドボックス無効＋承認なし（danger-full-access）。信頼できる用途のみ。
# 例:
#   ./scripts/run.sh requirements "ペット見守りアプリの要件をまとめて" --auto
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

ROLE="${1:-}"
if [ -z "$ROLE" ]; then
  list_agents
  echo
  echo "使い方: ./scripts/run.sh <role> \"タスク内容\" [--auto] [--full-auto]"
  exit 0
fi
shift || true
agent_exists "$ROLE" || { echo "未知のエージェント: $ROLE" >&2; echo; list_agents; exit 1; }

AUTO=0; FULL=0; TASK_PARTS=()
for arg in "$@"; do
  case "$arg" in
    --auto) AUTO=1 ;;
    --full-auto) FULL=1; AUTO=1 ;;
    *) TASK_PARTS+=("$arg") ;;
  esac
done
TASK="${TASK_PARTS[*]:-}"
[ -n "$TASK" ] || die "タスク内容を指定してください。"

MODEL="$(field "$ROLE" model)"
EFFORT="$(field "$ROLE" effort)"
SANDBOX="$(field "$ROLE" sandbox)"
PROMPT="$(build_prompt "$ROLE" "$TASK")"

TS="$(date +%Y%m%d-%H%M%S)"
LOG="$ROOT/logs/${ROLE}-${TS}.log"

# サンドポリシーの組み立て
# 注: codex exec は非対話モードのため承認プロンプトを出さない（サンドボックスで制御する）。
APPROVAL_ARGS=()
if [ "$FULL" -eq 1 ]; then
  # サンドボックス無効＋承認スキップ。信頼できる用途のみ。
  APPROVAL_ARGS=(--dangerously-bypass-approvals-and-sandbox)
else
  # --auto も既定も exec ではプロンプトなしで実行される。書き込み可能なサンドボックスで動かす。
  APPROVAL_ARGS=(-s "$SANDBOX")
fi

echo "▶ [$ROLE] を非対話実行 (model=$MODEL, effort=$EFFORT, auto=$AUTO, full=$FULL)" >&2
echo "  ログ: $LOG" >&2
set -x
codex exec \
  --cd "$ROOT" \
  --skip-git-repo-check \
  -m "$MODEL" \
  -c model_reasoning_effort="$EFFORT" \
  "${APPROVAL_ARGS[@]}" \
  "$PROMPT" 2>&1 | tee "$LOG"
