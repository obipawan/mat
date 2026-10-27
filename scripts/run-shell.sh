#!/usr/bin/env bash
# run-shell.sh — start Mat Shell (docs/lld/README.md D2).
# Installs ~/.config/quickshell/mat-shell -> <repo>/shell once, puts <repo>/shell on QML_IMPORT_PATH so
# `import MatShell.Tokens` and friends resolve, then runs `qs -c mat-shell` with any extra arguments.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_LINK="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/mat-shell"

if [ ! -e "$CONFIG_LINK" ] && [ ! -L "$CONFIG_LINK" ]; then
  mkdir -p "$(dirname "$CONFIG_LINK")"
  ln -s "$REPO/shell" "$CONFIG_LINK"
fi
if [ "$(readlink -f "$CONFIG_LINK")" != "$(readlink -f "$REPO/shell")" ]; then
  echo "mat-shell: $CONFIG_LINK already exists and is not a link to $REPO/shell; refusing to touch it" >&2
  exit 1
fi

export QML_IMPORT_PATH="$REPO/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
exec qs -c mat-shell "$@"
