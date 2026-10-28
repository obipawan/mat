#!/usr/bin/env bash
# smoke-shell.sh — runtime smoke test on the Linux target (needs a running Wayland session, Hyprland preferred).
# Starts the shell, waits for IPC, replays tests/smoke/ipc-script.txt, then fails if the log contains QML errors.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO/tests/smoke/ipc-script.txt"
LOG="$(mktemp -t mat-shell-smoke.XXXXXX)"
QS=(qs -c mat-shell)

"${QS[@]}" kill >/dev/null 2>&1 || true
bash "$REPO/scripts/run-shell.sh" >"$LOG" 2>&1 &
SHELL_PID=$!
trap '"${QS[@]}" kill >/dev/null 2>&1 || kill "$SHELL_PID" 2>/dev/null || true' EXIT

for _ in $(seq 1 50); do
  if "${QS[@]}" ipc show >/dev/null 2>&1; then break; fi
  if ! kill -0 "$SHELL_PID" 2>/dev/null; then echo "ERROR: shell exited during startup"; cat "$LOG"; exit 1; fi
  sleep 0.2
done

calls=0
failed=0
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue ;; esac
  call="${line%% => *}"
  expect=""
  if [ "$call" != "$line" ]; then expect="${line#* => }"; fi
  # shellcheck disable=SC2086  # each line is "<target> <function> [args…] [=> <extended regex for stdout>]"
  if ! out="$("${QS[@]}" ipc call $call 2>&1)"; then
    echo "FAIL: ipc call $call → $out"; failed=1
  elif [ -n "$expect" ] && ! printf '%s' "$out" | grep -Eq -- "$expect"; then
    echo "FAIL: ipc call $call → '$out' does not match /$expect/"; failed=1
  fi
  calls=$((calls + 1))
  sleep 0.4
done < "$SCRIPT"
if [ "$failed" -ne 0 ]; then echo "ERROR: IPC expectations failed (log: $LOG)"; exit 1; fi
sleep 1

PATTERN='ReferenceError|TypeError|SyntaxError|is not a type|is not installed|Binding loop detected|Unable to assign|Cannot assign|Non-existent attached object|Cannot read property|mat-shell: ERROR'
if grep -E "$PATTERN" "$LOG"; then
  echo "ERROR: QML errors in $LOG after $calls IPC calls"
  exit 1
fi
echo "  ✓ smoke-shell: started cleanly and replayed $calls IPC calls with no QML errors (log: $LOG)"
