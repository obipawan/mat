# Material 3 Expressive Desktop Environment Design System for Quickshell — Architectural Specification

- **Date**: 2026-10-26
- **Target Runtime**: Quickshell (Qt6 / QtQuick / QML on Wayland `wlr-layer-shell`, `ext-session-lock`, Hyprland / Niri / I3 / Wayland Toplevel IPC)
- **Design Language**: Material Design 3 (M3) + M3 Expressive + Dynamic Color (`matugen` HCT) adapted for Desktop Environments
- **Primary Consumer**: AI Coding Agents (for deterministic QML shell generation) and Human Designers/Developers (via documentation and interactive visual showcase)

---

## 1. Purpose & Design Goals

This project defines a complete, zero-ambiguity **Material 3 Desktop Environment Design System** engineered from scratch for **Quickshell**. While Material 3 was originally authored for mobile and web surfaces, desktop environments require unique paradigms: multi-monitor layer-shell orchestration, high-information-density status bars, pointer hover + keyboard-first submap navigation, adaptive tiling vs. floating workflows, and compositor blur/tonal surface duality.

### Core Objectives
1. **AI-Agent Determinism**: Structured as a modular, progressive-disclosure specification (`AGENTS.md` + `design-system/`) paired with canonical Quickshell QML Token Singletons (`Tokens.qml`, `ColorTokens.qml`, `MotionTokens.qml`, `ShapeTokens.qml`, `TypographyTokens.qml`, `MetricTokens.qml`) and W3C JSON tokens so an AI agent never invents token names, spacing, or state rules.
2. **Adaptive Dual-Mode Paradigm**: First-class support for both **Tiling Mode** (Hyprland / Niri / Sway keyboard-centric workspace pills, submap indicators, tiled overview) and **Floating / Traditional Desktop Mode** (GNOME / ChromeOS-style app menu, pinned/running dock or taskbar, spatial window expose).
3. **M3 Expressive + Configurable Surface Mode**: Combines wallpaper-derived HCT tonal palettes (`matugen`) and M3 Expressive spring physics / corner-radius morphing with a dual surface token engine supporting both **Opaque Tonal** (`opaque_tonal`) and **Frosted Tonal Glass** (`frosted_tonal_glass`) modes.
4. **Full 14-Surface DE Component Catalog**: Complete visual, structural, state-machine, and Quickshell service-binding specifications for every surface in a modern desktop environment.
5. **Interactive Visual Showcase**: A live, interactive visual companion (`.canvas.tsx` / web showcase) allowing humans to toggle dark/light themes, dynamic color seeds, Opaque vs. Glass surface modes, and Tiling vs. Floating desktop paradigms while inspecting component tokens and states.

---

## 2. Repository & Context Boundary Architecture

To prevent AI coding agents from confusing visual preview code (React/Canvas) with target Quickshell implementation patterns (QtQuick/QML), the workspace enforces a strict directory and instruction boundary:

```text
mat/
├── AGENTS.md                                  # Master AI Agent Router, Context Protocol & Build Order
├── docs/
│   └── superpowers/
│       ├── specs/
│       │   └── 2026-10-26-m3-quickshell-desktop-design-system-design.md
│       └── plans/
│           └── 2026-10-26-m3-quickshell-desktop-design-system-plan.md
├── design-system/                             # Canonical Quickshell + M3 Specification Suite
│   ├── INDEX.md                               # Master index, token cheatsheet & component matrix
│   ├── tokens/
│   │   ├── m3-tokens.json                     # W3C Design Token JSON (Color, Typography, Motion, Shape, Elevation, Metrics)
│   │   ├── matugen-template.toml              # Matugen wallpaper color generation configuration & template mapping
│   │   └── qml/                               # Executable Quickshell QML Singletons (pragma Singleton)
│   │       ├── qmldir                         # Module registration for Quickshell imports
│   │       ├── Tokens.qml                     # Unified singleton facade
│   │       ├── ColorTokens.qml                # 48 M3 HCT color roles + Opaque/Glass surface alpha resolvers
│   │       ├── MotionTokens.qml               # M3 Expressive spatial & effects springs + bezier curves
│   │       ├── ShapeTokens.qml                # Corner radii (none..full) & state-driven morph helpers
│   │       ├── TypographyTokens.qml           # Type scale roles, font families, tabular numeral features
│   │       └── MetricTokens.qml               # Density-aware spacing, bar heights, hit targets, Z-layers
│   ├── foundations/
│   │   ├── 01-color-and-surfaces.md           # HCT roles, Opaque Tonal vs. Frosted Tonal Glass, surface tinting
│   │   ├── 02-typography-and-iconography.md   # Desktop type scale, variable fonts, Material Symbols weight/fill
│   │   ├── 03-motion-and-morphing.md          # M3 Expressive spring physics, corner morphing, shared container transforms
│   │   ├── 04-interaction-states-and-input.md # Pointer hover, press ripple, keyboard focus rings, scroll & gestures
│   │   ├── 05-wayland-layershell-spatial.md   # WlrLayershell Z-ordering, exclusive zones, multi-monitor, scaling
│   │   └── 06-adaptive-desktop-modes.md       # Tiling Mode vs. Floating Mode runtime switching & layout rules
│   ├── primitives/
│   │   ├── 01-surfaces-and-containers.md      # M3Surface, M3GlassPanel, M3Card, M3Divider, M3Scrim
│   │   ├── 02-buttons-and-chips.md            # M3Button, M3IconButton, M3SegmentedButton, M3Chip, M3BarPill
│   │   ├── 03-controls-sliders-and-inputs.md  # M3Switch, M3Slider, M3TextField, M3SearchField, M3ProgressIndicator
│   │   └── 04-menus-popovers-and-tooltips.md  # M3Popover, M3ContextMenu, M3Tooltip, M3ScrollBar
│   ├── shell-components/
│   │   ├── 01-topbar.md                       # 3-zone status bar (Workspaces, Window/Media center, System/Clock tray)
│   │   ├── 02-bottom-bar-dock.md              # Adaptive Dock (Floating M3 Pill Dock <-> Edge-to-Edge Taskbar)
│   │   ├── 03-control-center.md               # Quick Settings bento grid, expandable sub-sheets, audio/brightness sliders
│   │   ├── 04-notifications.md                # Toast notification stack + Notification Center history panel
│   │   ├── 05-calendar-and-weather.md         # Date/Time bento popover, month calendar, agenda, weather card
│   │   ├── 06-media-player-popover.md         # MPRIS controller with album-art dynamic seed palette & waveform seekbar
│   │   ├── 07-osd-huds.md                     # Volume, Brightness, Mic/Cam Privacy Pill, CapsLock, Workspace Switch HUD
│   │   ├── 08-app-and-command-launcher.md     # Unified Launcher (App grid/list, Windows, Calculator, Clipboard, Emoji)
│   │   ├── 09-workspace-and-window-overview.md# Tiling Strip/Grid Overview + Floating Spatial Expose
│   │   ├── 10-lock-screen.md                  # WlSessionLockSurface (M3 Expressive clock, media widget, PAM auth)
│   │   ├── 11-power-and-session-menu.md       # Lock, Logout, Suspend, Hibernate, Reboot, Shutdown + confirmation morph
│   │   ├── 12-polkit-authentication-dialog.md # System privilege prompt modal with identity picker & error shake
│   │   ├── 13-screen-capture-and-recording.md # Region/Window/Screen capture bar +Topbar active recording pill
│   │   └── 14-wallpaper-and-theme-picker.md   # Live wallpaper switcher, matugen scheme selector, surface/mode toggles
│   └── interactions/
│       ├── 01-choreography-and-morphing.md    # Pill-to-panel morphing, popover mutual exclusion, scrim coordination
│       ├── 02-keyboard-navigation-and-submaps.md # Focus traversal, Escape chains, compositor submaps, accessibility
│       └── 03-quickshell-service-architecture.md # Pipewire, UPower, Mpris, SystemTray, Notifications, Hyprland/Niri IPC
└── m3-quickshell-de.canvas.tsx                # Interactive Cursor Canvas Visual Showcase & Token Inspector
```

---

## 3. Material 3 Desktop Foundations Specification

### 3.1 HCT Color Roles & Dynamic Wallpaper Pipeline (`matugen`)
- **48 Standard M3 Roles**:
  - Primary family: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `inversePrimary`, `primaryFixed`, `primaryFixedDim`, `onPrimaryFixed`, `onPrimaryFixedVariant`
  - Secondary family: `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `secondaryFixed`, `secondaryFixedDim`, `onSecondaryFixed`, `onSecondaryFixedVariant`
  - Tertiary family: `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`, `tertiaryFixed`, `tertiaryFixedDim`, `onTertiaryFixed`, `onTertiaryFixedVariant`
  - Error family: `error`, `onError`, `errorContainer`, `onErrorContainer`
  - Surface & Neutral family: `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `surfaceDim`, `surfaceBright`, `surfaceContainerLowest`, `surfaceContainerLow`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`, `inverseSurface`, `inverseOnSurface`
  - Outline & Utility: `outline`, `outlineVariant`, `shadow`, `scrim`
- **Desktop Semantic Extensions**:
  - `success`, `onSuccess`, `successContainer`, `onSuccessContainer` (harmonized green hue shifted toward primary via HCT)
  - `warning`, `onWarning`, `warningContainer`, `onWarningContainer` (harmonized amber hue shifted toward primary via HCT)
  - `privacyMicCam`, `onPrivacyMicCam` (high-visibility indicator token for active microphone/camera pill)
  - `urgentWorkspace`, `onUrgentWorkspace` (mapped to `tertiaryContainer` / `errorContainer` depending on notification vs. window urgency)

### 3.2 Configurable Dual-Surface Engine (`opaque_tonal` vs. `frosted_tonal_glass`)
Controlled globally via `Tokens.surfaceMode` (`"opaque_tonal"` | `"frosted_tonal_glass"`):

| Surface Tier | Role in Shell | `opaque_tonal` Resolution | `frosted_tonal_glass` Resolution | Border Token |
|---|---|---|---|---|
| **Tier 0: Shell Root** | Bar backgrounds, Dock shell, Popover root containers | `surfaceContainer` @ `100%` alpha | `surfaceContainer` @ `78%` alpha + `64px` compositor blur + `2%` luminance noise | `1px` `outlineVariant` @ `16%` (`opaque`) / `28%` (`glass`) |
| **Tier 1: Elevated Group** | Bento sections, Notification cards, Inactive quick tiles | `surfaceContainerHigh` @ `100%` alpha | `surfaceContainerHigh` @ `90%` alpha | `1px` `outlineVariant` @ `12%` |
| **Tier 2: Interactive Control** | Recessed search bars, Sliders, Nested list items, Hover cards | `surfaceContainerHighest` @ `100%` alpha | `surfaceContainerHighest` @ `96%` alpha | `0px` (or `1px` `outline` on focus) |
| **Tier 3: Inset Well** | Workspace track well, Switch track off, Scroll trough | `surfaceContainerLow` @ `100%` alpha | `surfaceContainerLow` @ `84%` alpha | `1px` inner `outlineVariant` @ `10%` |
| **Tier 4: Accent Active** | Active Quick Tile, Focused Workspace Pill, Primary Action | `primary` or `primaryContainer` @ `100%` alpha | `primary` or `primaryContainer` @ `100%` alpha (never translucent to preserve contrast) | `0px` |

### 3.3 M3 Expressive Motion & Shape Morphing
- **Two Spring Families**:
  - **Spatial Springs** (for position, width, height, scale, corner radius morphing — permits slight natural bounce):
    - `springFastSpatial`: damping ratio `0.65`, stiffness `700` (~`250ms` settle) — used for button press squish, workspace pill width morph, switch thumb.
    - `springDefaultSpatial`: damping ratio `0.72`, stiffness `450` (~`350ms` settle) — used for Topbar pill-to-popover expansion, Control Center sub-sheet unfold, Dock magnification.
    - `springSlowSpatial`: damping ratio `0.78`, stiffness `260` (~`500ms` settle) — used for Workspace Overview zoom, Lock Screen entrance, Wallpaper transition.
  - **Effects Springs / Curves** (for opacity, color, state layer alpha, blur radius — critically damped, zero overshoot):
    - `springFastEffects`: damping ratio `1.0`, stiffness `1200` (~`120ms`) — hover/press state layers.
    - `springDefaultEffects`: damping ratio `1.0`, stiffness `600` (~`220ms`) — color role transitions, scrim fade.
- **Interactive Shape Morphing Contract**:
  - Resting pills (`radius.full = 9999px`) morph to squircles (`radius.md = 12px` or `radius.lg = 16px`) when pressed or expanded into an active panel.
  - Adjacent segmented items or grouped quick-setting tiles use asymmetric radii (`topLeftRadius`, `topRightRadius`, `bottomLeftRadius`, `bottomRightRadius`) that dynamically sharpen (`4px` inner corners) when grouped and round (`24px`) when isolated or active.

### 3.4 Desktop Typography & Density Scale
- **Font Stack**:
  - UI & Body (`font.familySans`): `"Google Sans Text"`, `"Inter"`, `"Roboto Flex"`
  - Display & Expressive Headers (`font.familyDisplay`): `"Google Sans"`, `"Outfit"`, `"Inter Display"`
  - Monospace & System Metrics (`font.familyMono`): `"JetBrains Mono"`, `"Google Sans Mono"`
- **Mandatory OpenType Features**:
  - Any dynamic numeric readout (Topbar Clock, CPU/RAM/Network speed, Volume %, Media timestamps, Recording timer) MUST enforce `font.features: { "tnum": 1 }` (tabular numerals) so layout width never jitters on tick updates.
- **Density Modes**:
  - `compact` (Topbar `32px` height, base unit `4px`, ideal for tiling setups on 13"–16" laptops)
  - `comfortable` (Default: Topbar `40px` height, base unit `4px`, ideal for 1440p/4K desktops)
  - `spacious` (Topbar `48px` height, touch/HiDPI friendly)

### 3.5 Wayland `WlrLayershell` Spatial Z-Order Architecture
Every surface in the DE maps deterministically to a Wayland layer and keyboard focus policy:

| Layer (`WlrLayershell.layer`) | Surfaces Assigned | `exclusiveZone` | `keyboardFocus` (`WlrKeyboardFocus`) |
|---|---|---|---|
| `WlrLayer.Background` | Wallpaper Canvas, Desktop Clock/Quote Widgets | `-1` (ignores exclusive zones) | `None` |
| `WlrLayer.Bottom` | Workspace Overview Scrim & Background Dimmer | `0` | `None` |
| `WlrLayer.Top` | `Topbar`, `BottomDock` (pinned mode), `NotificationToasts`, `ControlCenter`, `CalendarWeatherPanel`, `MediaPopover`, `WallpaperPicker` | `Topbar`: `height + topMargin`; `BottomDock`: `height + bottomMargin` (or `0` in auto-hide); Popovers: `0` | Bars/Toasts: `None`; Popovers: `OnDemand` (or `Exclusive` when text input focused) |
| `WlrLayer.Overlay` | `OsdHud`, `AppCommandLauncher`, `WorkspaceOverview`, `PowerSessionMenu`, `PolkitDialog`, `ScreenCaptureHud`, `ScreenCorners` | `0` (`-1` for `ScreenCorners` & full-screen modals) | `OsdHud`/`ScreenCorners`: `None`; Modals/Launcher: `Exclusive` |
| `WlSessionLock` | `LockScreen` (per-output `WlSessionLockSurface`) | Session-locked full screen | `Exclusive` |

---

## 4. Component Specification Contract (Primitives + 14 Shell Surfaces)

### 4.1 Atomic Primitives (`design-system/primitives/`)
1. **Surfaces & Containers**: `M3Surface`, `M3GlassPanel`, `M3Card` (Elevated, Filled, Outlined), `M3Divider`, `M3Scrim`, `M3ScreenCorners`
2. **Buttons & Chips**: `M3Button` (Filled, Tonal, Outlined, Text), `M3IconButton` (Standard, Filled, Tonal, Outlined, Toggleable), `M3SegmentedButton`, `M3FilterChip`, `M3BarPill` (the signature Topbar interactive capsule)
3. **Controls, Sliders & Inputs**: `M3Switch` (with icon morph inside thumb), `M3Slider` (M3 Expressive thick track `16px–24px` with `4px` thumb gap and active/inactive track split), `M3TextField`, `M3SearchField`, `M3CircularProgress`, `M3LinearProgress`
4. **Menus, Popovers & Tooltips**: `M3Popover` (shared-origin morphing layer surface), `M3ContextMenu` (nested submenu support, keyboard accelerators), `M3Tooltip` (rich & plain), `M3ScrollBar`

### 4.2 The 14 Desktop Environment Shell Surfaces (`design-system/shell-components/`)
Each of the 14 shell component documents will contain all 8 mandatory sections (Wayland Layer Config, Dual-Mode Adaptation, Visual Anatomy Diagram, Token Table, State Matrix, Motion Choreography, Quickshell Service Bindings, and Canonical QML Skeleton):

1. **`01-topbar.md` (Topbar / Status Bar)**:
   - Three-zone layout (`Left`: Launcher/App-Menu pill + Workspace indicator capsule + Compositor Submap pill; `Center`: Active Window title pill OR Dynamic Media + Clock island; `Right`: Privacy indicator pill + System Tray drawer + Hardware Telemetry pill + Unified Quick Settings capsule [Network, BT, Audio, Battery] + Notification bell).
   - Supports **Island Mode** (floating detached M3 capsules), **Floating Pill Bar Mode** (single floating rounded bar with `8px` screen margins), and **Edge-to-Edge Bar Mode** (`0px` margin, inverted screen corner cutouts).
2. **`02-bottom-bar-dock.md` (Adaptive Bottom Bar / Dock)**:
   - Morphs between **Floating Expressive Dock** (pinned + running apps, active pill indicator width morphing `6px` dot -> `16px` pill on focused window, multi-instance dots, live hover preview tooltip, trash/overview end-cap) and **Edge-to-Edge Taskbar Mode** (window title chips, integrated workspace switcher).
   - Smart dodge / auto-hide state machine in Tiling Mode when a tiled window occupies the monitor.
3. **`03-control-center.md` (Quick Settings & Control Center)**:
   - Top header row (User avatar, Uptime, Settings shortcut, Lock, Power button).
   - Primary 2x3 or 2x4 M3 Expressive Quick Tile grid (Wi-Fi, Bluetooth, Audio Profile, DND, Night Light, Power Profile: Performance/Balanced/Saver, Caffeine, Screen Record). Tiles support **Dual-Action Split** (left tap toggles state; right chevron expands inline sub-sheet with spring height animation).
   - Thick M3 Expressive Sliders for Display Brightness and Master Audio Volume (with per-app mixer expansion toggle).
4. **`04-notifications.md` (Toast Popups & Notification Center)**:
   - **Toast Stack**: Top-right (or configurable corner) overlay stack, max 3 visible toasts + collapsed stack counter pill (`+4 more`), urgency styling (`Low` = `surfaceContainer`, `Normal` = `surfaceContainerHigh`, `Critical` = `errorContainer` with persistent timeout and `onErrorContainer` accent), circular or linear auto-dismiss countdown on hover pause, inline reply & action buttons.
   - **Notification Center**: Grouped by application (`appName`), expandable/collapsible bundles with stacked card depth effect, "Clear All" morphing button, and empty-state illustration.
5. **`05-calendar-and-weather.md` (Calendar, Clock & Weather Center)**:
   - Dual-column bento popover anchored to the Topbar Clock/Date pill (can be unified with Notification Center or standalone).
   - Left/Top: Large M3 Expressive Date header, interactive Month Grid (today highlighted in `primary` pill, event dots in `tertiary`), Upcoming Agenda timeline.
   - Right/Bottom: Weather card (current temp, condition glyph, 5-hour forecast strip), World Clocks / Pomodoro timer tab.
6. **`06-media-player-popover.md` (MPRIS Media Player)**:
   - Extracts live HCT palette from current track's `mpris:artUrl` to dynamically theme the card (`primaryContainer` background tint with blurred album art scrim).
   - Player source switcher chip strip (Spotify, Firefox, MPV), animated squiggly/waveform M3 Expressive progress scrubber, play/pause shape morph button (circle -> rounded square), and audio output sink routing pill.
7. **`07-osd-huds.md` (On-Screen Display HUDs)**:
   - Non-focus-stealing (`WlrKeyboardFocus.None`) transient overlays for Volume (with mute/overamplification `>100%` warning state), Brightness, Keyboard Backlight, Caps Lock / Num Lock, Keyboard Layout switcher, and Tiling Workspace Switch HUD.
   - Topbar **Privacy Pill**: Hardware/Pipewire microphone and camera active indicator in high-contrast `privacyMicCam` green/amber that collapses from `"Mic & Camera in use (Firefox)"` to a compact icon pill after `3000ms`.
8. **`08-app-and-command-launcher.md` (Unified Application & Command Launcher)**:
   - Centered `Overlay` modal (`WlrKeyboardFocus.Exclusive`) with instant prefix/mode routing:
     - Default: Fuzzy App Search (Grid or List view with category chips & pinned apps)
     - `>` or `cmd`: Shell/System Commands (Lock, Reload Quickshell, Toggle Dark Mode, Switch Surface Mode)
     - `=` or math expression: Live Calculator with one-Enter copy
     - `:` or `emoji`: Emoji & Nerd Font symbol picker
     - `clip`: Clipboard History manager (`cliphist` / `wl-paste` integration)
     - `win` or `Tab`: Open Window Switcher across workspaces
9. **`09-workspace-and-window-overview.md` (Workspace & Window Overview)**:
   - Adapts to `Tokens.desktopMode`:
     - **Tiling Mode**: Niri-style horizontal scrolling strip or Hyprland workspace matrix showing exact proportional tiled window geometry, live window icons/titles, and drag-to-move between workspaces.
     - **Floating Mode**: Spatial expose layout with top workspace thumbnail strip, live search filter, and middle-click to close window.
10. **`10-lock-screen.md` (`WlSessionLockSurface` Lock Screen)**:
    - Security-hardened per-monitor lock surface using `Quickshell.Wayland.WlSessionLock`.
    - Expressive oversized variable-weight clock (`displayLarge`, morphs upward when typing starts), compact weather & battery status pills, optional non-interactive MPRIS Now Playing card, user avatar, password field with animated M3 shape-morphing dots as characters are typed, and PAM failure horizontal spring shake + `errorContainer` state.
11. **`11-power-and-session-menu.md` (Power & Session Modal)**:
    - Full-screen dimmed `scrim` (`40%` alpha + `24px` blur) with 6 large M3 Expressive action cards (`Lock`, `Logout`, `Suspend`, `Hibernate`, `Reboot`, `Shutdown`).
    - Keyboard-first (`L`, `E`, `S`, `H`, `R`, `P` single-key shortcuts or arrow keys) + 2-step inline morphing confirmation with a `15s` auto-confirm countdown bar for destructive actions (`Reboot`, `Shutdown`, `Logout`).
12. **`12-polkit-authentication-dialog.md` (Privilege Escalation Prompt)**:
    - System modal triggered by Polkit agent requests. Displays requesting application icon, action description (`org.freedesktop.policykit.exec`), expandable technical details drawer, administrator identity selector chip, password field with visibility toggle, and PAM state machine.
13. **`13-screen-capture-and-recording.md` (Screenshot & Screen Recording HUD)**:
    - Floating bottom-center capture toolbar (`Region`, `Window`, `Full Screen` segmented toggle; `Screenshot` vs. `Video Record` mode switch; Audio source mic/system toggles; Delay timer chip `0s / 3s / 10s`).
    - Interactive crosshair region selector with magnifier loupe, pixel dimension badge (`1920 × 1080`), and post-capture toast with `Copy`, `Save`, `Edit/Annotate` actions.
    - When recording is active, docks a persistent pulsing red/tertiary **Recording Timer Pill** into the Topbar (`02:14 • Stop`).
14. **`14-wallpaper-and-theme-picker.md` (Wallpaper & Material You Theme Studio)**:
    - Slide-up carousel or bento modal for live desktop personalization:
      - Wallpaper grid with instant preview and multi-monitor target selector.
      - `matugen` Scheme Variant selector (`TonalSpot`, `Vibrant`, `Expressive`, `Fidelity`, `Content`, `Neutral`, `Monochrome`).
      - Live toggles for `Dark / Light Mode`, `Opaque Tonal / Frosted Tonal Glass`, `Tiling / Floating Mode`, and `Topbar Style` (`Island`, `Floating Pill`, `Edge-to-Edge`).

---

## 5. Interactive Visual Showcase Specification (`m3-quickshell-de.canvas.tsx`)

To give humans an immediate, tactile way to explore the design system alongside the AI-ready Markdown + QML specs, we will build a rich Cursor Canvas (`m3-quickshell-de.canvas.tsx`) featuring:
1. **Live Simulated Desktop Environment**:
   - Interactive **Topbar** (switchable between Island, Floating Pill, and Edge-to-Edge modes; interactive workspaces, submap badge, media pill, privacy pill, system tray, quick settings trigger, clock trigger).
   - Interactive **Popovers & Modals**: Click or toggle **Control Center** (with expandable Wi-Fi/Audio sub-sheets and M3 Expressive thick sliders), **Calendar & Notification Center** (with toast simulator), **MPRIS Media Popover**, **Unified App/Command Launcher** (with live search/calculator/clipboard tabs), **OSD HUDs** (Volume/Brightness/Workspace), **Workspace Overview**, **Lock Screen**, **Power Menu**, **Polkit Prompt**, **Screen Capture HUD**, and **Wallpaper/Theme Studio**.
   - Interactive **Adaptive Bottom Dock / Taskbar** (switches live between Tiling Compact/Auto-hide Pill Dock, Floating Expressive Dock, and Edge-to-Edge Taskbar).
2. **Real-Time M3 Token & Mode Control Bar**:
   - **Seed Palette Switcher**: 6 dynamic HCT wallpaper seeds (`Aurora Violet`, `Cyber Emerald`, `Solar Amber`, `Sakura Rose`, `Glacier Cyan`, `Graphite Monochrome`).
   - **Theme Polarity**: `Dark` vs. `Light`.
   - **Surface Engine**: `Frosted Tonal Glass` vs. `Opaque Tonal`.
   - **Desktop Paradigm**: `Tiling Mode (Hyprland/Niri)` vs. `Floating Mode (Desktop)`.
3. **Agent Spec & Token Inspector Drawer**:
   - Clicking an "Inspect Spec" toggle on any surface reveals its exact `WlrLayershell` configuration, `Tokens.*` color/motion/shape bindings, state matrix, and canonical Quickshell QML snippet.

---

## 6. Self-Review & Verification Checklist

- **Placeholder Scan**: Zero `TBD` or `TODO` items exist in this specification; all 14 shell surfaces, 4 primitive groups, 6 foundation documents, and 6 QML token singletons are explicitly defined.
- **Internal Consistency**: The file paths in Section 2 match the component and foundation breakdown in Sections 3, 4, and 5. Surface tiers (`Tier 0`–`Tier 4`) and Wayland layers (`Background`, `Bottom`, `Top`, `Overlay`, `WlSessionLock`) are consistently applied across all 14 components.
- **Scope & Decomposition**: Each markdown file is scoped to a single domain or component so AI agents can load individual specs cleanly without context bloat.
- **Ambiguity Check**: Numeric metrics, OpenType features (`tnum`), spring damping/stiffness parameters, and dual-mode behaviors (`tiling` vs. `floating`, `opaque_tonal` vs. `frosted_tonal_glass`) are concretely specified.
