#!/usr/bin/env bash
# checkpoint.sh — package the project folder for an outside review (docs/lld/06-unattended-runbook.md §4–§5).
#   bash scripts/checkpoint.sh N            phase checkpoint after Task N: writes ../mat-checkpoint-NN.tar.gz
#   bash scripts/checkpoint.sh --blocked N  Task N is blocked: archives the folder as it is, unsealed work included,
#                                           to ../mat-blocked-NN.tar.gz
# The archive is the whole folder (docs/state/ holds the history), so no git is needed. Nothing is deleted.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

archive() {
  tar -czf "$1" --exclude='__pycache__' --exclude='.DS_Store' --exclude='.git' -C "$(dirname "$REPO")" "$(basename "$REPO")"
}

if [ "${1:-}" = "--blocked" ]; then
  N="${2:?usage: bash scripts/checkpoint.sh --blocked <task number>}"
  OUT="$(cd .. && pwd)/mat-blocked-$(printf '%02d' "$N").tar.gz"
  archive "$OUT"
  echo "  ✓ archive (Task $N blocked, unsealed work included): $OUT"
  echo "Tell the human: \"Task $N is blocked. Review archive: $OUT\". Then end the session."
  exit 0
fi

N="${1:?usage: bash scripts/checkpoint.sh <task number> | --blocked <task number>}"
NN="$(printf '%02d' "$N")"
if [ "$(python3 scripts/matstate.py status | tail -1 | cut -d' ' -f1)" != "0" ]; then
  echo "ERROR: unsealed changes. Finish the task with scripts/task-gate.py first (do not discard anything)."
  exit 1
fi
python3 scripts/matstate.py verify
bash scripts/verify-design-system.sh >/dev/null
OUT="$(cd .. && pwd)/mat-checkpoint-$NN.tar.gz"
archive "$OUT"
echo "  ✓ checkpoint $NN archive: $OUT"
echo "Tell the human: \"Checkpoint $NN reached. Review archive: $OUT\". Then end the session."
