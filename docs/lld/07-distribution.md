# LLD 07 — Distribution: Packaging and the Installer

**Status:** §3 is **adopted** (owner seal 14): its rules now live in `02-contracts.md` §1 ("Paths", "Declared commands"), `paths.mjs` (`02-contracts.md` §2.13), the service rows (`02-contracts.md` §3), lint G22–G23 and the plan (Task 11 (runtime spike) probes). The rest is design, not yet normative: it becomes plan tasks in Phases K and L (`docs/OBJECTIVE.md`), and until then it overrides nothing in `01`–`06`.

---

## 1. Reference Model (dux-shell)

What dux-shell does, from its repository (`github.com/duxlabs-dev/dux-shell`):

| Part | dux-shell | Mat Shell plan |
|---|---|---|
| One-line entry | `curl -fsSL https://install.duxlabs.dev \| sh`, which fetches a compiled installer | `curl -fsSL <url>/install.sh \| bash` (§5) |
| Installer | Go (`core/cmd/duxinstall`): a Bubble Tea text UI, or a headless run when `--compositor`/`--term` are given. Internal modules: `distros`, `deps`, `config`, `configfrag`, `backup`, `systemd`, `privesc` (sudo, doas or run0). Flags include `--replace-configs`, `--include-deps`/`--exclude-deps`, `-y`. Refuses to run as root | Bash first (§5.4); the same module split |
| Packages | Arch `extra` (`dux-shell`) and AUR (`dux-shell-git`); Fedora RPM specs, Debian packaging, Nix flake under `distro/` | `packaging/arch/` first; other distributions later under `packaging/<distro>/` |
| Login | Separate greetd greeter project | greetd + tuigreet first; our own greeter is out of scope (`docs/OBJECTIVE.md`) |

---

## 2. Install Layout

| Path | Contents | Written by |
|---|---|---|
| `/usr/share/mat-shell/` | A copy of `shell/`: `shell.qml`, `DebugIpc.qml`, `MatShell/`, `lib/`, `bar/`, `surfaces/`, `assets/` | the package |
| `/usr/bin/mat-shell` | Launcher: sets `QML_IMPORT_PATH=/usr/share/mat-shell` and starts Quickshell on that directory; `mat-shell doctor` checks dependencies (§4) | the package |
| `/usr/share/mat-shell/hypr/mat-shell.conf` | Compositor snippet: `exec-once = mat-shell`, `source` of the user's generated `binds.conf`, layer rules for the `mat-*` namespaces (blur) | the package |
| `$XDG_CONFIG_HOME/mat-shell/` (default `~/.config/mat-shell/`) | `config.json`, `theme.json`, `binds.conf`, `matugen/` | the shell, on first run (never the package) |
| `$XDG_CACHE_HOME/mat-shell/` (default `~/.cache/mat-shell/`) | `theme.prev.json`, `weather.json` | the shell |
| `~/.config/hypr/hyprland.conf` | One added line: `source = /usr/share/mat-shell/hypr/mat-shell.conf` | the installer, with a backup |
| `/etc/greetd/config.toml` | `command = "tuigreet --remember --cmd Hyprland"` (exact form verified in Phase L) | the installer, with a backup |

**How `qs -c mat-shell` finds an installed copy is not settled.** Every keybind snippet and IPC example uses `qs -c mat-shell ipc call …`, so the installed config must be reachable by that name. Candidate A: `/etc/xdg/quickshell/mat-shell` as a symlink to `/usr/share/mat-shell`, if Quickshell searches `$XDG_CONFIG_DIRS`. Candidate B: the launcher starts Quickshell by path, and IPC goes through the launcher (`mat-shell ipc …`). Task 11 (runtime spike) should probe A (§3 item 6), and the decision follows from it.

---

## 3. Install-Readiness Rules (Phase J: adopted)

These keep the generated code packageable, so Phase K is packaging and not a refactor. Where each one is enforced is named at its end.

1. **Everything the shell reads at runtime lives under `shell/`**, resolved from `Quickshell.shellDir`, never from `design-system/`, `scripts/` or `docs/`. Two places break this today:
   - the matugen `config.toml` and `theme.json.tpl` are copied from `design-system/tokens/matugen/` (Task 11 (runtime spike) Step 5; `01-architecture.md` §6);
   - the baseline theme exists only in `design-system/`.
   Fix (done): `scripts/gen-shell-data.py` copies `config.toml` and `theme.json.tpl` to `shell/assets/matugen/`, and `ThemeService` seeds `configDir/matugen/` from there when missing, rewriting `~/.config/mat-shell` with `paths.rebaseMatugenConfig` (`02-contracts.md` §3.2). The baseline theme is not needed at runtime: `ColorTokens` defaults mirror it.
2. **User files go through one place.** `ConfigService` exposes ro `homeDir`, `configDir` and `cacheDir` from `paths.userDirs` (`02-contracts.md` §2.13; `ConfigService` in `02-contracts.md` §3.1). Every other service builds its paths from them; G23 rejects `HOME`/`XDG_*` reads elsewhere. `ColorTokens.qml` (done) resolves the same folder itself, because tokens cannot import services.
3. **Every external command is declared.** `packaging/dependencies.json` lists each command a service runs (`nmcli`, `brightnessctl`, `matugen`, `grim`, `slurp`, `wf-recorder`, `qalc`, `cliphist`, `curl`, `hyprctl`, `systemctl`, `loginctl`, `busctl`, …). Each entry gives its package per distribution and says whether the shell needs it or can run without it. Lint G22 rejects an undeclared program (including inside `sh -c` scripts); `tests/lib/dependencies.test.mjs` checks the `session.mjs` command tables. The same file drives the package's dependency list, the installer's package list, and `mat-shell doctor` (seeded by `scripts/check-deps.py`).
4. **No repository paths in shell code.** Lint G23 rejects string literals naming `design-system/`, `scripts/`, `docs/`, `~/`, `/home/`, `/Users/`, `/root/`, the spelled-out config or cache folder, or a `../` that leaves `shell/`.
5. **The shell never needs root.** Session actions go through logind (`systemctl`, `loginctl`) and polkit, as the contracts already say; nothing calls `sudo` or `pkexec`.
6. **Probes in Task 11 (runtime spike)**, recorded in its receipt (now in its Step 7, with the font and optical-size checks):
   - `qs -c` discovery through `$XDG_CONFIG_DIRS`: make a probe config `mat-probe` under a temporary `XDG_CONFIG_DIRS` and run `qs -c mat-probe`;
   - whether `import qs.MatShell.Tokens` works without `QML_IMPORT_PATH`;
   - `pacman -Si` for every Arch package in `packaging/dependencies.json` (`python3 scripts/check-deps.py --pacman`).

---

## 4. Dependencies (initial; Arch names to verify with `pacman -Si` / the AUR)

| Need | Arch package (to verify) | Required? | Used by |
|---|---|---|---|
| Quickshell ≥ 0.3.0 | `quickshell` (`extra` or AUR) | yes | everything |
| Qt 6.8 modules | `qt6-declarative`, `qt6-wayland`, `qt6-svg`, `qt6-5compat` (if `QtQuick.Effects` needs it) | yes | QML |
| Compositor | `hyprland`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk` | yes (installer) | session |
| Login | `greetd`, `greetd-tuigreet` | installer only | session |
| Audio | `pipewire`, `pipewire-pulse`, `wireplumber` | yes | `AudioService` |
| Network / Bluetooth | `networkmanager`, `bluez`, `bluez-utils` | network yes; Bluetooth optional | `NetworkService`, `BluetoothService` |
| Power | `upower`, `power-profiles-daemon` | yes | `BatteryService` |
| Polkit | `polkit` (the shell is the agent) | yes | `PolkitService` |
| Theme | `matugen` (AUR) | yes (without it the theme stays at the baseline) | `ThemeService` |
| Capture | `grim`, `slurp`, `wf-recorder` | optional | `CaptureService` |
| Brightness | `brightnessctl` | optional | `BrightnessService` |
| Clipboard / calc | `wl-clipboard`, `cliphist`, `libqalculate` (`qalc`) | optional | `LauncherService` |
| Weather | `curl` | optional | `WeatherService` |
| Fonts | `ttf-jetbrains-mono` (package); Google Sans Flex, Instrument Serif and Material Symbols Rounded **ship inside `mat-shell`** (`packaging/dependencies.json` `fonts`, pinned by commit and SHA-256), installed to `/usr/share/fonts/mat-shell/` with their licence files | yes | `TypographyTokens` |
| Basics a minimal system lacks | `xdg-user-dirs`, `noto-fonts`, `noto-fonts-emoji`, a terminal (`foot` or `kitty`), a cursor theme | installer only | session |

---

## 5. The Installer

### 5.1 Modes

| Mode | For | Does |
|---|---|---|
| Package only | Users who already run Hyprland | `paru -S mat-shell-git` (later `pacman -S mat-shell`), then `mat-shell setup`, which adds the `source` line to `hyprland.conf` |
| Full desktop | A minimal Arch install with no desktop | §5.2 |

### 5.2 Full-desktop flow (`install.sh`)

1. **Preflight**:
   - refuse root;
   - require `/etc/arch-release`, network, and `sudo` (or `doas`/`run0`);
   - detect the GPU and offer the driver packages;
   - detect an existing desktop and stop unless `--force`.
2. **Plan**: print every package, service and file it will touch, then ask (`--yes` skips; `--dry-run` stops here).
3. **AUR helper**: install `base-devel` and `git`, then bootstrap `paru` when it is missing (needed for `matugen`, the fonts, and `mat-shell-git` until official packages exist).
4. **Packages**: install the §4 list from `packaging/dependencies.json`, filtered by flags.
5. **Services**:
   - system: `NetworkManager`, `bluetooth` (if chosen), `power-profiles-daemon`, `greetd`;
   - user: PipeWire and WirePlumber (socket-activated).
6. **Configs**: write greetd's config and the `hyprland.conf` `source` line. Every replaced file is backed up under `~/.local/state/mat-shell/install-backups/<timestamp>/`.
7. **Post-check**: `mat-shell doctor` (dependencies, versions, and a headless start), then offer to reboot.

Flags: `--dry-run`, `--yes`, `--no-greeter`, `--no-bluetooth`, `--git`, `--uninstall` (restores the latest backup and removes what the installer added, never user data). Log file: `~/.local/state/mat-shell/install.log`.

### 5.3 Idempotence

Every step checks before it acts (package installed, service enabled, `source` line present). A second run prints "nothing to do".

### 5.4 Language: Bash (decided)

A minimal Arch system has `bash`, `pacman` and `curl` (a `pacman` dependency), but no Python or Go toolchain. A single Bash script can be read and checked (`shellcheck`) before anyone pipes it into a shell. Keep distribution-specific code in functions per distribution, with package names coming only from `packaging/dependencies.json` (read with `jq`, which the installer installs first). Move to a compiled installer with a text UI, as dux-shell did, only if several distributions make Bash unwieldy.

---

## 6. Testing

| Tier | Where | What |
|---|---|---|
| P1 | any Linux machine with Docker or Podman | `shellcheck install.sh`; `makepkg` + `namcap` in an `archlinux` container; `install.sh --dry-run` in a container (the plan matches a recorded golden file) |
| P2 | QEMU VM from archiso, scripted | minimal `pacstrap` → run the installer → reboot → greetd → log in a test user → `qs -c mat-shell ipc call debug state` → screenshot; run the installer a second time (no changes); `--uninstall` (system diff is clean) |
| P3 | real hardware | the P2 steps by hand on a laptop (battery, backlight, Wi-Fi, Bluetooth) |

---

## 7. Open Decisions

| Decision | Options | Recommendation |
|---|---|---|
| Fonts | — | **Decided:** Google Sans Flex (SIL OFL 1.1, no Reserved Font Names) for `familySans` and `familyDisplay`, shipped inside the package with Instrument Serif (OFL) and Material Symbols Rounded (Apache 2.0); JetBrains Mono from `ttf-jetbrains-mono`. Ship the files unmodified; the Google names are trademarks (`foundations/02` §2.4) |
| Config discovery | candidate A or B (§2) | follow the Task 11 (runtime spike) probe |
| Login screen | — | **Decided:** greetd + tuigreet for the first release; our own Quickshell greeter later |
| Distribution channel | AUR `mat-shell-git` only; later an AUR release package; later Arch `extra` | AUR `-git` first, release package once versioned |
| Installer hosting | raw GitHub URL; a short domain | decide when the repository is public |
