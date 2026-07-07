#!/usr/bin/env bash
# 複数エージェントをパイプラインで順番に稼働させる
# 既定の流れ: requirements -> architect -> design -> motion -> backend -> swift -> code-reviewer -> qa
# 各エージェントは前段の成果物（docs/）を読んで作業する。
#
# 使い方:
#   ./scripts/orchestrate.sh "作りたいプロダクトの概要" [--auto|--full-auto] [--only role1,role2]
# 例:
#   ./scripts/orchestrate.sh "Peak Body の新機能" --auto
#   ./scripts/orchestrate.sh "ダッシュボード刷新" --auto --only design,motion,swift
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

BRIEF=""; AUTO_FLAG=""; PIPELINE="requirements architect design motion backend swift code-reviewer qa"
ARGS=("$@")
i=0
while [ $i -lt ${#ARGS[@]} ]; do
  a="${ARGS[$i]}"
  case "$a" in
    --auto) AUTO_FLAG="--auto" ;;
    --full-auto) AUTO_FLAG="--full-auto" ;;
    --only) i=$((i+1)); PIPELINE="$(echo "${ARGS[$i]}" | tr ',' ' ')" ;;
    *) if [ -z "$BRIEF" ]; then BRIEF="$a"; else BRIEF="$BRIEF $a"; fi ;;
  esac
  i=$((i+1))
done
[ -n "$BRIEF" ] || die "プロダクト概要を指定してください。"

echo "=== オーケストレーション開始 ===" >&2
echo "概要: $BRIEF" >&2
echo "実行順: $PIPELINE" >&2
echo "モード: ${AUTO_FLAG:-対話承認}" >&2
echo >&2

for ROLE in $PIPELINE; do
  agent_exists "$ROLE" || die "未知のエージェント: $ROLE"
  echo "────────────────────────────────────────" >&2
  echo "▶ フェーズ: $ROLE" >&2
  echo "────────────────────────────────────────" >&2
  TASK="プロダクト概要『${BRIEF}』について、あなたの担当領域の成果物を作成してください。前段エージェントの成果物が docs/ にあれば必ず参照してください。"
  if [ -n "$AUTO_FLAG" ]; then
    "$ROOT/scripts/run.sh" "$ROLE" "$TASK" "$AUTO_FLAG"
  else
    "$ROOT/scripts/run.sh" "$ROLE" "$TASK"
  fi
  echo >&2
done

echo "=== オーケストレーション完了 ===" >&2
echo "成果物は docs/ 配下、連携記録は docs/HANDOFF.md を確認してください。" >&2
