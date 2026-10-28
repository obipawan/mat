# Interactions 03 — Quickshell Service & Compositor IPC Architecture

> **Module**: `design-system/interactions/03-quickshell-service-architecture.md`
> **Quickshell Modules**: `Quickshell.Services.Pipewire`, `Quickshell.Services.UPower`, `Quickshell.Services.Mpris`, `Quickshell.Services.SystemTray`, `Quickshell.Services.Notifications`, `Quickshell.Services.Pam`, `Quickshell.Hyprland`, `Quickshell.Wayland`

---

## 1. Service Layer Architecture Overview

To keep UI components declarative and prevent null-pointer binding warnings during startup, all Quickshell native services and CLI processes are wrapped in **Reactive Service Singletons** under `shell/services/`:

```text
shell/services/
├── AudioService.qml        # Wraps Quickshell.Services.Pipewire + PwObjectTracker
├── BatteryService.qml      # Wraps Quickshell.Services.UPower + powerprofilesctl
├── MediaService.qml        # Wraps Quickshell.Services.Mpris + album-art palette (matugen --dry-run --json hex -t scheme-content)
├── NetworkService.qml      # Wraps nmcli / NetworkManager D-Bus + Bluetooth BlueZ state
├── NotificationService.qml # Wraps Quickshell.Services.Notifications.NotificationServer
├── CompositorService.qml   # Unified adapter for Hyprland, Niri, Sway/I3 & Wayland ToplevelManager
├── BrightnessService.qml   # Backlight read/write (brightnessctl or /sys/class/backlight) + keyboard backlight
├── TelemetryService.qml    # /proc/stat + /proc/meminfo sampler; sample(target) only called by visible consumers
├── KeyboardService.qml     # Caps Lock / Num Lock state (/sys/class/leds/*::capslock) & active layout code
├── AccessibilityService.qml # Loads config.json + GNOME a11y gsettings into Tokens.reducedMotion / reducedTransparency / highContrast / textScale
└── ThemeService.qml        # Sets wallpaper (swww), runs matugen non-interactively, keeps undo copy, wallpaper region luminance probe
                            # (ColorTokens.qml itself watches ~/.config/mat-shell/theme.json)
```

---

## 2. Critical Quickshell Service Gotchas & Mandatory Patterns

### 2.1 `Pipewire` Requires `PwObjectTracker`
**Gotcha**: In `Quickshell.Services.Pipewire`, reading `Pipewire.defaultAudioSink.audio.volume` returns `0` or `NaN` unless the `PwNode` is actively bound in a `PwObjectTracker`!
**Mandatory Pattern (`AudioService.qml`)**:
```qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // CRITICAL: Must track defaultAudioSink and defaultAudioSource so .audio properties populate
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    readonly property real volume: sink?.audio?.volume ?? 0.0
    readonly property bool muted: sink?.audio?.muted ?? false

    function setVolume(newVol: real): void {
        if (sink?.audio) {
            sink.audio.muted = false
            sink.audio.volume = Math.max(0.0, Math.min(1.5, newVol))
        }
    }

    function toggleMute(): void {
        if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted
        }
    }
}
```

### 2.2 `Mpris` Position Updates Require an Active-Only `Timer`
**Gotcha**: `MprisPlayer.position` does not emit change signals automatically during normal playback.
**Mandatory Pattern**: Run a `1000ms` `Timer` with `running: player !== null && player.playbackState === MprisPlaybackState.Playing && (mediaPopoverVisible || lockScreenVisible)` that calls `player.positionChanged()`. Never run the timer when no surface displaying elapsed seconds is visible.

### 2.3 Every Poller Pauses Without a Visible Consumer
**Rule**: The Mpris pattern above applies to every periodic source. Telemetry (`/proc/stat`, `/proc/meminfo`), weather refresh, `SystemClock.Seconds` precision, and screencopy previews run only while a visible, non-receded surface displays them. Hidden desktop widgets, closed popovers, and locked sessions cost zero wakeups, which keeps idle power draw low on laptops.

### 2.4 matugen Must Never Prompt (`ThemeService.qml`)
**Gotcha**: matugen ≥ 4.0 asks the user to pick a source colour when an image yields several candidates. Under Quickshell's `Process` there is no terminal, so it exits with *"Multiple source colors found … a terminal was not detected"* and the theme silently never updates.
**Mandatory Pattern**:
```qml
Process {
    id: matugenRun
    command: ["matugen", "image", root.pendingWallpaper,
              "-c", ConfigService.configDir + "/matugen/config.toml", // seeded at start (docs/lld/02-contracts.md §3.2)
              "-t", Tokens.schemeVariant,
              "--source-color-index", "0"]
        .concat(Tokens.highContrast ? ["--contrast", "1.0"] : [])
    stderr: StdioCollector { id: matugenErr }
    onExited: (exitCode) => {
        if (exitCode !== 0) root.themeFailed(matugenErr.text) // previous theme.json stays in place
    }
}
```
`ColorTokens` picks up the rewritten `theme.json` through its own `FileView`, so `ThemeService` never pushes colours manually.

### 2.5 Compositor Abstraction (`CompositorService.qml`)
To support both **Hyprland**, **Niri**, and generic **wlroots/Wayland** compositors seamlessly:
1. Detect active compositor at startup via `Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""` vs. `Quickshell.env("NIRI_SOCKET") !== ""`.
2. Expose unified properties:
   - `workspaces`: list of `{ id, name, focused, occupied, urgent, monitor }`
   - `activeWindowTitle`: bound to `ToplevelManager.activeToplevel?.title ?? "Desktop"`
   - `activeWindowAppId`: bound to `ToplevelManager.activeToplevel?.appId ?? ""`
   - `activeSubmap`: bound to Hyprland `submap` raw event
3. Expose unified methods:
   - `switchToWorkspace(id: int)`
   - `moveFocusedWindowToWorkspace(id: int)`
   - `toggleFloating()`

---

## 3. Complete Service-to-Component Binding Matrix

| Service Singleton | Bound Properties & Signals | Consuming Shell Components |
|---|---|---|
| **`ConfigService`** | `FileView` + `JsonAdapter` over `~/.config/mat-shell/config.json` (`watchChanges`, `atomicWrites`, `300ms` debounced writes): `appearance`, `theme`, `bars`, `widgets`, `notifications`, `keybinds`, `animations`, `accessibility`, `ui`; `set(path, value)`, `transaction(label, fn)`, `undo()`, `addBar()`, `updateBar(id, patch)`, `removeBar(id)`, `applyPreset(name)`, `removeWidget(barId, section, index)`, `error`, `lastGood` | `16-Settings` (all pages), `01-Bars` (via `BarService`), `Tokens` (switches bound to config values) |
| **`BarService`** | `instances` (`[{ bar, screen }]`, config order), `isVisible(barId, screen)`, `insets(screen)` (`{ top, right, bottom, left }`, visible bars), `maxInsets(screen)` (as if every bar were shown; for surfaces that must not jump when a bar reveals), `edgeGap(bar)` / `endGap(bar)` (screen-axis `marginHorizontal` / `marginVertical` resolved for the bar's orientation), `innerEdge(barId, screen)`, `regions(screen)` (rects for popover click-catcher subtraction), `hostsWidget(screen, type)`, `effectiveThickness(bar)`, `lengthPx()`, `alignOffset()`, `sectionOffset()`, `canPlace(screen, edge)`, `thicknessRange(position)`, `reservedShare(screen, axis)`, `setEdgeHover(barId, screen, hovered)` | `01-Bars`, `02-Bar Widgets`, `M3Popover` (origin-edge placement), `04-Toasts`, `07-OsdHuds`, `09-Overview`, `15-DesktopWidgets` (safe area), `16-Settings` (validation + live preview) |
| **`BarWidgetRegistry`** | `has(type)`, `source(type)`, `label(type)`, `description(type)`, `icon(type)`, `defaultOptions(type)`, `optionsSchema(type)` / `hasOptions(type)` (from `m3-tokens.json` `modes.bars.widgetOptions`), `resolve(type, options, orientation)` (defaults merged, values clamped, orientation applied), `diffFromDefaults(type, options)` (what Settings writes), `migrate(type, options)` (run on config load), `catalog` (the `SC-02` §1.1 table) | `01-Bars` (`BarWidgetLoader`, every widget via `resolve`), `16-Settings` (widget palette, chips, edit icon, generic options form) |
| **`KeybindService`** | `actions` (`[{ id, label, group, defaultChord, chord }]`), `conflictsWith(chord)`, `setChord(id, chord)`, `reset(id)`, `resetAll()`; writes `~/.config/mat-shell/binds.conf` (Hyprland `global, mat-shell:<id>`) and reloads the compositor; snippet export for Niri/Sway | `16-Settings` (Keybindings page), `08-Launcher` (shortcut hints) |
| **`AudioService`** | `volume`, `muted`, `micMuted`, `activeCaptureStreams`, `sinks`, `appStreams` | `02-Bar Widgets` (`controlCenter`, `privacy`), `03-ControlCenter` (Volume Slider + Mixer), `06-MediaPopover` (Sink Chip), `07-OsdHuds` |
| **`BatteryService`** | `percentage` (`0..1`), `isCharging`, `timeToEmptySec`, `powerProfile` (`"performance"` \| `"balanced"` \| `"power-saver"`) | `02-Bar Widgets` (`controlCenter`), `03-ControlCenter`, `10-LockScreen` |
| **`MediaService`** | `activePlayer`, `players`, `trackTitle`, `trackArtist`, `trackArtUrl`, `artPalette`, `position`, `length` | `02-Bar Widgets` (`media`), `06-MediaPopover`, `10-LockScreen` |
| **`NotificationService`** | `toastsModel`, `historyGroupsModel`, `unreadCount`, `dndEnabled`, `clearAll()` | `02-Bar Widgets` (`notifications` badge), `03-ControlCenter` (DND Tile), `04-Notifications` |
| **`CompositorService`** | `workspaces`, `focusedWorkspaceId`, `focusedScreen`, `activeWindowTitle`, `activeSubmap`, `clientsJson`, `windowsOverlap(rect, screen)` (for `dodge` bars) | `01-Bars` (dodge), `02-Bar Widgets` (`workspaces`, `windowTitle`, `submap`, `apps`), `07-OsdHuds`, `08-Launcher`, `09-WorkspaceOverview`, `13-ScreenCaptureHud` |
| **`ThemeService`** | `currentWallpaper`, `wallpapersList`, `applyWallpaper(path)`, `applyScheme(scheme)` (sets `Tokens.schemeVariant`, re-runs matugen), `regenerate()` (on `Tokens.highContrast` change), `undoLastTheme()`, `themeFailed(stderr)`, `regionLuma(rect)` | `03-ControlCenter`, `14-WallpaperThemePicker`, `15-DesktopWidgets` (colours reach every surface through `ColorTokens`) |
| **`BrightnessService`** | `brightness` (`0..1`), `adjust(deltaPercent)`, `set(value)` | `03-ControlCenter`, `07-OsdHuds` (`IpcHandler` target `"osd"`) |
| **`TelemetryService`** | `cpuPercent`, `ramPercent`, `sample(target)` (no internal timer — consumers drive it while visible) | `02-Bar Widgets` (`telemetry`), `15-DesktopWidgets` |
| **`KeyboardService`** | `capsLock`, `numLock`, `layoutCode` (`"EN"`, `"DE"`) | `07-OsdHuds`, `10-LockScreen`, `12-PolkitDialog`, `M3TextField` |
| **`AccessibilityService`** | Writes `Tokens.reducedMotion`, `reducedTransparency`, `highContrast`, `textScale`, `confirmByHold`, `expressiveSprings`; `setSwitch(name, value)` persists through `ConfigService` | `03-ControlCenter` (Accessibility sub-sheet), `16-Settings` (Animations + Accessibility pages), every surface via `Tokens` |
