# Interactions 02 — Global Keyboard Navigation Graph, Compositor Submaps & Accessibility

> **Module**: `design-system/interactions/02-keyboard-navigation-and-submaps.md`
> **Compositor Targets**: Hyprland (`hyprland.conf`), Niri (`config.kdl`), Sway (`config`)

---

## 1. Compositor Keybind Integration (`qs ipc call`)

Because Wayland restricts global hotkey capture to the compositor, the desktop environment exposes unified `IpcHandler` targets (`"shell"` in `ShellState.qml` and `"osd"` in `OsdHud.qml`) invoked via `qs ipc call`.

### 1.1 Canonical Compositor Keybind Table

| Shortcut | Quickshell IPC Command | Target Surface / Action |
|---|---|---|
| `Super` (Release) / `Super+Space` | `qs ipc call shell toggleLauncher` | Opens/closes `08-AppCommandLauncher` (`Apps` mode) |
| `Super+V` | `qs ipc call shell openLauncherMode clip` | Opens `08-AppCommandLauncher` directly in `Clipboard` mode |
| `Super+Period` | `qs ipc call shell openLauncherMode emoji` | Opens `08-AppCommandLauncher` directly in `Emoji` mode |
| `Super+Tab` | `qs ipc call shell toggleOverview` | Opens/closes `09-WorkspaceOverview` |
| `Super+A` | `qs ipc call shell toggleControlCenter` | Opens/closes `03-ControlCenter` |
| `Super+N` | `qs ipc call shell toggleNotifications` | Opens/closes `04-NotificationCenter` |
| `Super+M` | `qs ipc call shell toggleMedia` | Opens/closes `06-MediaPopover` |
| `Super+D` | `qs ipc call shell toggleWidgetPeek` | Raises/lowers `15-DesktopWidgets` (Widget Peek) in both desktop modes |
| `Super+W` | `qs ipc call shell toggleThemeStudio` | Opens/closes `14-WallpaperThemePicker` |
| `Print` / `Super+Shift+S` | `qs ipc call shell toggleCapture` | Opens `13-ScreenCaptureHud` (`Region` mode) |
| `Super+L` | `qs ipc call shell lock` | Engages `10-LockScreen` (`WlSessionLock`) |
| `Super+Escape` | `qs ipc call shell togglePower` | Opens `11-PowerSessionMenu` |
| `Super+Comma` | `qs ipc call shell openSettings` | Opens `16-Settings` (or focuses it); `openSettings bars/<id>` deep-links a page |
| `Ctrl+Alt+Tab` | `qs ipc call shell focusBar` | **Bar Focus Mode**: moves keyboard focus into the first bar on the focused screen (§3.1) |
| `XF86AudioRaiseVolume` / `Lower` | `qs ipc call osd changeVolume 5` / `-5` | Adjusts Pipewire sink volume & triggers `07-OsdHud` |
| `XF86AudioMute` | `qs ipc call osd toggleMute` | Toggles master mute & triggers `07-OsdHud` |
| `XF86MonBrightnessUp` / `Down` | `qs ipc call osd changeBrightness 5` / `-5` | Adjusts backlight & triggers `07-OsdHud` |

These are the defaults. Users rebind them in Settings → Keybindings (`16-settings.md` §3.3), which writes `~/.config/mat-shell/binds.conf` through `KeybindService`. `Super`, `Super+Comma`, and `Super+Escape` can be rebound but never left unbound, so the launcher, Settings, and Power Menu stay reachable whatever bars the user configures.

### 1.2 Stock Compositor Binding Conflicts

When generating the compositor config, remove stock bindings that collide with this table:
- Hyprland ships `Super+M` → `exit`. Remove it: logging out must stay behind the Power Menu confirmation, and a press meant for the media popover must never end the session.
- Hyprland ships `Super+V` → `togglefloating` and `Super+C` → `killactive`. Move `togglefloating` to `Super+Shift+Space`; keep `Super+C` unbound by the shell so existing kill-window muscle memory never collides with a shell surface.

---

## 2. Hierarchical `Escape` Key Dismissal Stack

Pressing `Escape` inside any open surface MUST unwind state one logical layer at a time rather than abruptly dumping the user out of a sub-task:

```text
[Level 3: Inline Sub-State]       e.g., Control Center Wi-Fi Sub-Sheet expanded,
      │ Escape                          Power Menu destructive confirmation active,
      ▼                                 Launcher query text non-empty, context menu open
[Level 2: Active Popover / Modal] Collapses sub-sheet / clears query / cancels confirmation
      │ Escape (when at root of popover/modal, Widget Peek, or Bar Focus Mode)
      ▼
[Level 1: Clean Desktop]          Calls ShellState.closeActivePopover() / closeActiveModal(),
                                  clears ShellState.barFocusActive, and returns
                                  WlrKeyboardFocus to the Wayland client window
```

---

## 3. Intra-Surface Keyboard Focus Traversal Contract

Every surface with `WlrKeyboardFocus.OnDemand` or `WlrKeyboardFocus.Exclusive` implements a deterministic 2D focus graph. **Bindings are identical in `tiling` and `floating` modes** (`06-adaptive-desktop-modes.md` §4): arrow keys always work, and Vim aliases (`h/j/k/l`, `Ctrl+J/K`) are additive in both modes.

| Surface | `Tab` / `Shift+Tab` | Arrow Keys (or `h/j/k/l`) | `Space` | `Enter / Return` |
|---|---|---|---|---|
| **Bar Focus Mode (01 / 02, any bar)** | Moves between sections (Start → Center → End), then on to the next bar on the screen in config order | Arrows along the bar axis (`←/→` on horizontal bars, `↑/↓` on vertical bars) move between widgets inside a section | Activates the focused pill (same as left click) | Activates the focused pill; `Menu` / `Shift+F10` opens its context menu |
| **03. Control Center** | Cycles Zone: `Header Buttons -> Quick Tile Grid -> Sliders` | Moves 2D focus across the `2×3` Quick Tile grid; on sliders, adjusts value `±5%` (`Shift`: `±1%`) | Toggles focused Quick Tile (`left action`) | Opens focused Quick Tile's accordion sub-sheet (`right action`) |
| **04. Notification Center** | Cycles `Header (DND, Clear all) -> App Groups -> Cards` | `↑/↓` moves between cards; `→` expands a group, `←` collapses it | Expands/collapses the focused card | Invokes the default action; `Delete` dismisses the focused card |
| **05. Calendar & Weather** | Cycles `Month Header -> Day Grid -> Agenda List` | Navigates `±1 day` (`←/→`) or `±7 days` (`↑/↓`); `PageUp`/`PageDown` (or `[`/`]`) switch month | Selects focused date | Opens new event entry for focused date |
| **06. Media Popover** | Cycles `Player Chips -> Transport Controls -> Seekbar` | On the seekbar `←/→` seeks `±5s`; elsewhere moves between controls | Play / Pause from anywhere in the card | Activates focused control; `n` / `p` next/previous track |
| **08. App Launcher** | Expands/collapses secondary actions for selected result while keeping `searchInput` focused | Moves `selectedIndex` up/down (or 2D across App Grid when query is empty) | Inserts space into `searchInput` | Executes primary action on `selectedIndex` |
| **09. Workspace Overview** | Cycles between Search Bar and Workspace Grid | Moves focus between windows; `Shift+Arrow` moves window to the adjacent workspace; `1..9` jumps to a workspace | Toggles floating state of focused window | Activates focused window and exits Overview |
| **11. Power Menu** | Cycles across the 6 action cards | Moves 2D across the `3×2` action grid; tap `L/S/H` to run instantly, **hold** `E/R/P` for `2s` to confirm | Instant card: runs. Destructive card: **hold** to confirm (release cancels) | Same as `Space` |
| **12. Polkit Dialog** | Cycles `Password -> Identity Chip -> Details -> Cancel -> Authenticate` | `↑/↓` selects an identity when the identity chip is open | Toggles the details drawer when focused | Submits the password |
| **13. Screen Capture** | Cycles `Mode Segments -> Actions -> Options` | Arrow keys nudge the selection by `1px` (`Shift`: `10px`); `1..9` selects a window in Window mode | Switches Screenshot ↔ Record | Captures immediately |
| **14. Theme Studio** | Cycles `Polarity / Surface toggles -> Carousel -> Scheme Chips -> Widget Manager` | `←/→` moves the carousel or chip focus | Previews the focused wallpaper | Applies the focused wallpaper or scheme |
| **15. Widget Peek** | Cycles between interactive widgets (media controls, search, weather) | Moves focus within the focused widget | Activates the focused widget control | Activates the focused widget control |
| **16. Settings** | Cycles `Search -> Category List -> Detail Pane` (`F6` jumps between panes) | `↑/↓` moves through categories; in the sections editor `Alt+Arrow` moves the focused widget chip (across sections at the ends) | Toggles the focused switch / chip selection | Opens the focused category or widget options; `Ctrl+Z` undoes the last change |

### 3.1 Bar Focus Mode

Persistent bars normally use `WlrKeyboardFocus.None`, so they never steal typing. `Ctrl+Alt+Tab` (`qs ipc call shell focusBar`) sets `ShellState.barFocusActive`, which switches every bar on the focused screen to `WlrKeyboardFocus.OnDemand` and focuses the first widget of the first bar (config order). Auto-hidden or dodged bars reveal while Bar Focus Mode is active. `Escape`, a pointer press outside the bar, or opening any popover/modal ends Bar Focus Mode. This gives keyboard-only and screen-reader users a complete path to every bar control (workspaces, tray, quick settings, clock, notifications).

---

## 4. Accessibility & Ergonomic Guardrails

1. **Focus Ring (Keyboard Only)**: Focused controls show a `Tokens.metrics.focusRingWidth` (`2px`; `3px` in High Contrast) `Tokens.color.primary` ring offset by `2px`, only while `Tokens.keyboardModality` is true (`04-interaction-states-and-input.md` §3).
2. **WCAG AA Minimum Contrast**:
   - All text roles (`onSurface`, `onPrimary`, `onPrimaryContainer`, `onSecondaryContainer`, `onErrorContainer`) maintain `>= 4.5:1` contrast ratio against their paired surface tier in both `opaque_tonal` and `frosted_tonal_glass` modes. Text over the wallpaper follows the Wallpaper Legibility Guard (`01-color-and-surfaces.md` §5).
3. **Accessibility Modes** (`Tokens.reducedMotion`, `reducedTransparency`, `highContrast`, `textScale`): toggled live from the Control Center accessibility sub-sheet or `qs ipc call shell setA11y <name> <value>`.
4. **Reduced Motion** disables the squiggly seekbar wave, polygon and album-art rotation, launch bounces, urgent pulses, bell swing, error shakes, and the capture shutter flash; spring travel becomes `100ms` opacity crossfades.
5. **Screen Readers**: Every interactive element exposes `Accessible.role` and `Accessible.name`; toasts and OSD changes are announced without stealing focus (`04-interaction-states-and-input.md` §6.2).
