#!/usr/bin/env bash
# bootstrap-linux.sh — prepare this Linux machine for the Mat Shell agent (instruction.md Part 1).
#
# Usage:
#   bash scripts/bootstrap-linux.sh             # install what is missing, fetch fonts, check the session
#   bash scripts/bootstrap-linux.sh --dry-run   # print what it would do; change nothing
#
# Exit 0: ready (run python3 scripts/next-task.py). Exit 3: STOP, the message says what is needed.
# Safe to re-run: every step checks before it acts, so after a timeout just run it again.
# Packages come only from packaging/dependencies.json (scripts/check-deps.py --bootstrap-list).
# It writes nothing inside this folder; its log is /tmp/mat-bootstrap.log.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 3
exec > >(tee -a /tmp/mat-bootstrap.log) 2>&1

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

stop() {
  echo "STOP (environment): $*"
  exit 3
}
run() {
  echo "+ $*"
  [[ $DRY -eq 1 ]] || "$@"
}
lines() {  # lines <array-name> <command…>: read a command's output lines into an array
  local name=$1 line
  shift
  eval "$name=()"
  while IFS= read -r line; do
    [[ -n $line ]] && eval "$name+=(\"\$line\")"
  done < <("$@" 2>/dev/null)
}

echo "== Mat Shell bootstrap ($(date -Iseconds))"
[[ "$(uname -s)" == "Linux" ]] || stop "this machine is not Linux."
[[ $EUID -ne 0 ]] || stop "do not run this as root; run it as the user who will use the shell."
[[ -f /etc/arch-release ]] || stop "automatic setup supports Arch Linux only. Install the packages listed in packaging/dependencies.json (dev, packages, commands) and Python >= 3.11 / Node >= 22, then run python3 scripts/check-deps.py."

# --- root access for pacman, without a password prompt ------------------------------------------
SUDO=()
need_sudo() {
  [[ ${#SUDO[@]} -gt 0 ]] && return 0
  if sudo -n /usr/bin/pacman -V >/dev/null 2>&1; then
    SUDO=(sudo -n)
  elif [[ -t 0 ]] && sudo -v; then
    SUDO=(sudo)
  else
    echo "Installing packages needs root, and this session cannot answer a sudo password prompt."
    echo "Missing packages: $*"
    stop "one time, in any terminal on this machine, run:
  echo \"$USER ALL=(root) NOPASSWD: /usr/bin/pacman\" | sudo tee /etc/sudoers.d/90-mat-shell-pacman && sudo chmod 440 /etc/sudoers.d/90-mat-shell-pacman
then start the agent again. (This lets $USER run pacman as root without a password, which is root-equivalent; delete the file when the project is done.) Or install the missing packages yourself."
  fi
}

# --- Python first: the package list is read with it ----------------------------------------------
if ! pacman -T python >/dev/null 2>&1; then
  need_sudo python
  run "${SUDO[@]}" /usr/bin/pacman -Syu --needed --noconfirm python || stop "pacman could not install python (see /tmp/mat-bootstrap.log)."
fi

lines WANT python3 scripts/check-deps.py --bootstrap-list
[[ ${#WANT[@]} -gt 0 ]] || stop "could not read packaging/dependencies.json."
lines MISSING pacman -T "${WANT[@]}"

if [[ ${#MISSING[@]} -eq 0 ]]; then
  echo "  ✓ all ${#WANT[@]} packages installed"
else
  echo "Missing: ${MISSING[*]}"
  need_sudo "${MISSING[@]}"
  # Arch does not support partial upgrades: sync and upgrade once, then install.
  run "${SUDO[@]}" /usr/bin/pacman -Syu --noconfirm || stop "pacman -Syu failed (see /tmp/mat-bootstrap.log)."
  REPO=() AUR=()
  for p in "${MISSING[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then REPO+=("$p"); else AUR+=("$p"); fi
  done
  if [[ ${#REPO[@]} -gt 0 ]]; then
    run "${SUDO[@]}" /usr/bin/pacman -S --needed --noconfirm "${REPO[@]}" || stop "pacman could not install: ${REPO[*]} (see /tmp/mat-bootstrap.log)."
  fi
  if [[ ${#AUR[@]} -gt 0 ]]; then
    echo "From the AUR: ${AUR[*]} (building can take several minutes; if the command times out, run this script again)"
    HELPER=""
    command -v paru >/dev/null && HELPER=paru
    [[ -z $HELPER ]] && command -v yay >/dev/null && HELPER=yay
    if [[ -z $HELPER ]]; then
      run "${SUDO[@]}" /usr/bin/pacman -S --needed --noconfirm base-devel git || stop "could not install base-devel and git."
      BUILD="$(mktemp -d /tmp/mat-paru.XXXXXX)"
      run git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$BUILD/paru-bin" || stop "could not fetch paru-bin from the AUR."
      (cd "$BUILD/paru-bin" && run makepkg -si --noconfirm) || stop "could not build paru-bin (see /tmp/mat-bootstrap.log)."
      HELPER=paru
    fi
    if [[ $HELPER == paru ]]; then
      run paru -S --needed --noconfirm --skipreview "${AUR[@]}" || stop "paru could not install: ${AUR[*]} (see /tmp/mat-bootstrap.log)."
    else
      run yay -S --needed --noconfirm --answerdiff None --answerclean None "${AUR[@]}" || stop "yay could not install: ${AUR[*]} (see /tmp/mat-bootstrap.log)."
    fi
  fi
  if [[ $DRY -eq 0 ]]; then
    lines STILL pacman -T "${WANT[@]}"
    [[ ${#STILL[@]} -eq 0 ]] || stop "still missing after install: ${STILL[*]}. A name in packaging/dependencies.json may be wrong for this system; report it."
  fi
fi

# --- fonts the shell ships -------------------------------------------------------------------------
if python3 scripts/fetch-fonts.py --check >/dev/null 2>&1; then
  echo "  ✓ shipped fonts installed"
else
  run python3 scripts/fetch-fonts.py || stop "could not download the fonts (needs network to raw.githubusercontent.com)."
fi

# --- the session -----------------------------------------------------------------------------------
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  stop "this session is not running inside Hyprland, and the shell can only be tested there. Hyprland is installed: log in on a TTY, run Hyprland, open a terminal with Super+Q (kitty), and start the agent again from this folder in that terminal."
fi
echo "  ✓ inside a Hyprland session"

[[ $DRY -eq 1 ]] && { echo "dry run: nothing changed"; exit 0; }
python3 scripts/check-deps.py --strict || stop "required tools are still missing (listed above)."
echo "READY: run python3 scripts/next-task.py"
