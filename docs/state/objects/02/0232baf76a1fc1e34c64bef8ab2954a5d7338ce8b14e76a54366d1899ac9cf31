# Material 3 Expressive Desktop Design System — Master Index (`INDEX.md`)

Welcome to the **Material 3 Expressive Desktop Environment Design System for Quickshell**. This index maps every token singleton, foundation rule, atomic primitive, desktop shell component, and interaction spec across the system.

---

## 1. Design Token Architecture (`design-system/tokens/`)

| Artifact | Path | Purpose |
|---|---|---|
| **W3C Token JSON** | `design-system/tokens/m3-tokens.json` | Machine-readable source of truth: 57 colour roles, the baseline + 6 seed palettes (Dark & Light, generated exactly as matugen would), 5 surface tiers, M3 Expressive springs, typography scale, corner radii, and density metrics. |
| **matugen Pipeline** | `design-system/tokens/matugen/` | `config.toml` (matugen ≥ 4.0, non-interactive, harmonized status colours), `theme.json.tpl` (both polarities, 55 roles each), `theme.baseline.json` (matugen output for `#6750A4`, mirrored by `ColorTokens` defaults). |
| **Unified QML Facade** | `design-system/tokens/qml/Tokens.qml` | Root `pragma Singleton` exposing `Tokens.color`, `Tokens.motion`, `Tokens.shape`, `Tokens.typography`, `Tokens.metrics`; global switches (`darkMode`, `surfaceMode`, `desktopMode`, `densityMode`, `schemeVariant`, `themedIcons`, `desktopWidgetsEnabled`, `widgetScale`); and first-class accessibility switches (`reducedMotion`, `reducedTransparency`, `highContrast`, `textScale`, `keyboardModality`, `confirmByHold`, `expressiveSprings`) mirrored into every sub-singleton via `Binding`. Bars are **not** token switches: they are user data in `config.json` (`SC-01`). |
| **Color Singleton** | `design-system/tokens/qml/ColorTokens.qml` | 57 read-only colour roles fed live from matugen's `theme.json` (47 M3 scheme roles + 8 harmonized `success` / `warning` roles + fixed `privacyMicCam` pair), and `surfaceTier(0..4)` / `surfaceBorder(0..4)` resolvers for `opaque_tonal` vs. `frosted_tonal_glass` (forced opaque under Reduced Transparency / High Contrast). |
| **Motion Singleton** | `design-system/tokens/qml/MotionTokens.qml` | M3 Expressive Spatial Springs (`springFastSpatial`, `springDefaultSpatial`, `springSlowSpatial`), Effects Curves (`springFastEffects`, `springDefaultEffects`, cubic-bezier arrays), Reduced Motion gates (`spatialMotionEnabled`, `decorativeMotionEnabled`, `reducedMotionFadeMs`), the Expressive Bounce gate (`overshootEnabled`), and hold-to-confirm timing. |
| **Shape Singleton** | `design-system/tokens/qml/ShapeTokens.qml` | Corner radius tokens (`none=0`, `xs=4`, `sm=8`, `md=12`, `lg=16`, `xl=24`, `xxl=28`, `full=9999`), morph helpers `morphPillRadius()` / `morphTileRadius()`, and the Expressive polygon catalog (`polygonGeometry`, `polygonRadius()`, `samplePolygonPoints()`, `polygonSafeContentRatio()`). |
| **Typography Singleton** | `design-system/tokens/qml/TypographyTokens.qml` | 17 type roles (15 M3 roles plus `displayExpressiveHero` and `displayEditorial`), desktop font stacks, `textScale` multiplier, and mandatory `tabularFeatures: ({ "tnum": 1 })`. |
| **Metrics Singleton** | `design-system/tokens/qml/MetricTokens.qml` | Density- and text-scale-adaptive dimensions (bar defaults and guardrails: `barThickness`, `dockThickness`, `islandThickness`, `barPadding`, thickness bounds, `maxBarsPerEdge`; Settings window metrics), spacing grid (`4px` base), icon sizes, pointer-target minimums, state layer opacities, `scrimAlpha`, focus ring, wheel accumulation, and Wayland constants. |

---

## 2. Foundations (`design-system/foundations/`)

| ID | Document | Key Concepts Covered |
|---|---|---|
| **F-01** | `foundations/01-color-and-surfaces.md` | HCT tonal hierarchy, `matugen` wallpaper extraction, 5-tier Dual-Surface Engine (`opaque_tonal` vs. `frosted_tonal_glass`), album-art dynamic accenting, WCAG contrast rules. |
| **F-02** | `foundations/02-typography-and-iconography.md` | Desktop type scale adjustments, tabular numerals (`tnum`), Material Symbols variable axes (`FILL 0..1`, `wght 300..700`, `opsz 20..48`) animated on hover/active state. |
| **F-03** | `foundations/03-motion-and-morphing.md` | M3 Expressive physics: Spatial vs. Effects springs, QtQuick `SpringAnimation` recipes, pill-to-squircle corner morphing, shared-container pill-to-popover expansion. |
| **F-04** | `foundations/04-interaction-states-and-input.md` | State layers, safe pointer accelerators (middle/right/scroll), wheel accumulation, focus-visible keyboard contract, hit targets & Fitts edge extension, layout stability, accessibility modes, screen reader contract, password-field safety. |
| **F-05** | `foundations/05-wayland-layershell-spatial.md` | `WlrLayershell` Z-ordering (`Background`, `Bottom`, `Top`, `Overlay`), `WlSessionLock`, `exclusiveZone` formulas, `WlrKeyboardFocus` modes, edge hit extension on any edge, bar-aware click-catcher masks, `BarService.insets` spatial contract, multi-monitor & fractional scaling. |
| **F-06** | `foundations/06-adaptive-desktop-modes.md` | Runtime behavioral matrix comparing **Tiling Mode** (Hyprland / Niri / Sway) vs. **Floating Mode** (Traditional Desktop): widget variants, `auto` bar visibility, launcher and overview defaults. |

---

## 3. Atomic M3 QML Primitives (`design-system/primitives/`)

| ID | Document | Primitives Specified |
|---|---|---|
| **P-01** | `primitives/01-surfaces-and-containers.md` | `M3Surface`, `M3PolygonSurface` (`scallop_12`, `clover_4`, `flower_8`, `hexagon`, `diamond`), `M3GlassPanel`, `M3Card`, `M3Divider`, `M3Scrim`, `M3ScreenCorners` |
| **P-02** | `primitives/02-buttons-and-chips.md` | `M3StateLayer`, `M3Button`, `M3IconButton`, `M3SegmentedButton`, `M3FilterChip`, `M3BarPill`, `M3AppIcon` (Monochrome Themed Icon Well), `M3DuotoneClock`, `M3HoldToConfirm` (press-and-hold for destructive actions) |
| **P-03** | `primitives/03-controls-sliders-and-inputs.md` | `M3Switch`, `M3Slider` (Expressive split-track with thumb gap), `M3TextField`, `M3SearchField`, `M3CircularProgress`, `M3LinearProgress` |
| **P-04** | `primitives/04-menus-popovers-and-tooltips.md` | `M3Popover` (origin-edge placement from any bar), `M3ContextMenu`, `M3Tooltip`, `M3ScrollBar` |

---

## 4. The 16 Desktop Environment Shell Components (`design-system/shell-components/`)

Every shell component specification adheres to the **8-Part Agent Contract**: (1) Wayland Layer Config, (2) Adaptive Dual-Mode Behavior, (3) Visual Anatomy, (4) Token Table, (5) State Matrix, (6) Motion Choreography, (7) Quickshell Service Bindings, and (8) Canonical QML Skeleton.

| ID | Document | Wayland Layer | Exclusive Zone | Keyboard Focus | Primary Quickshell Services |
|---|---|---|---|---|---|
| **SC-01** | `shell-components/01-bar-system.md` | `WlrLayer.Top` (one window per bar × screen) | `thickness + margin` when `reserveSpace`; `0` when auto-hidden | `None` (`OnDemand` in Bar Focus Mode) | `ConfigService`, `BarService`, `BarWidgetRegistry` |
| **SC-02** | `shell-components/02-bar-widgets.md` | Inherits the host bar | Inherits the host bar | Inherits the host bar | `Hyprland`/`Niri`, `Mpris`, `Pipewire`, `UPower`, `SystemTray`, `Notifications`, `ToplevelManager`, `DesktopEntries` |
| **SC-03** | `shell-components/03-control-center.md` | `WlrLayer.Top` | `-1` (`M3Popover`) | `OnDemand` | `Pipewire`, `UPower`, `NetworkManager`/D-Bus, `Bluetooth`/BlueZ |
| **SC-04** | `shell-components/04-notifications.md` | `WlrLayer.Top` | `-1` (offsets by `BarService.insets`) | `OnDemand` (inline reply) / `None` (toast) | `Quickshell.Services.Notifications` |
| **SC-05** | `shell-components/05-calendar-and-weather.md` | `WlrLayer.Top` | `-1` (`M3Popover`) | `OnDemand` | `SystemClock`, Weather JSON `Process`/`FileView` |
| **SC-06** | `shell-components/06-media-player-popover.md` | `WlrLayer.Top` | `-1` (`M3Popover`) | `OnDemand` | `Quickshell.Services.Mpris`, `Pipewire`, `matugen` art colour extractor |
| **SC-07** | `shell-components/07-osd-huds.md` | `WlrLayer.Overlay` | `-1` (offsets by `BarService.maxInsets`) | `None` | `Pipewire`, `Brightness` (`brightnessctl`/sysfs), `Hyprland` keyboard/workspace |
| **SC-08** | `shell-components/08-app-and-command-launcher.md` | `WlrLayer.Overlay` | `0` | `Exclusive` | `DesktopEntries`, `ToplevelManager`, `Process` (`cliphist`, `qalc`) |
| **SC-09** | `shell-components/09-workspace-and-window-overview.md` | `WlrLayer.Overlay` | `0` | `Exclusive` | `Hyprland`/`Niri` IPC, `Screencopy` / `ToplevelManager` |
| **SC-10** | `shell-components/10-lock-screen.md` | `WlSessionLock` | Full Screen | `Exclusive` | `WlSessionLock`, `PamContext`, `Mpris`, `UPower`, `SystemClock` |
| **SC-11** | `shell-components/11-power-and-session-menu.md` | `WlrLayer.Overlay` | `-1` | `Exclusive` | `Process` (`systemctl`, `loginctl`, `hyprctl dispatch exit`) |
| **SC-12** | `shell-components/12-polkit-authentication-dialog.md` | `WlrLayer.Overlay` | `-1` | `Exclusive` | Polkit Agent D-Bus / `PamContext` |
| **SC-13** | `shell-components/13-screen-capture-and-recording.md` | `WlrLayer.Overlay` | `-1` | `Exclusive` (selector) / `None` (pill) | `Process` (`grim`, `slurp`, `wf-recorder` / `gpu-screen-recorder`) |
| **SC-14** | `shell-components/14-wallpaper-and-theme-picker.md` | `WlrLayer.Top` | `0` | `Exclusive` | `Process` (`matugen`, `swww` / `hyprpaper`), `FileView` (`theme.json`) |
| **SC-15** | `shell-components/15-desktop-widgets-layer.md` | `WlrLayer.Background` (`Overlay` in `Super+D` Peek) | `-1` | `None` (`OnDemand` in Peek) | `SystemClock`, `Mpris`, `UPower`, `/proc/stat`, `Hyprland` workspace count |
| **SC-16** | `shell-components/16-settings.md` | xdg toplevel (`FloatingWindow`; documented layer-shell exception) | N/A | Normal window focus | `ConfigService`, `BarService`, `KeybindService`, `ThemeService`, `SettingsIndex` |

---

## 5. Interaction Choreography & Services (`design-system/interactions/`)

| ID | Document | Scope |
|---|---|---|
| **I-01** | `interactions/01-choreography-and-morphing.md` | Global `ShellState` state machine, popover mutual exclusion (incl. Widget Peek lane), security-modal protection, multi-instance trigger registry with origin edge, `openSettings` IPC, shared-container morph trajectories, scrim orchestration. |
| **I-02** | `interactions/02-keyboard-navigation-and-submaps.md` | Compositor keybind integration (`qs ipc call`), stock-binding conflicts, Escape-stack priority, mode-independent focus traversal, Bar Focus Mode, accessibility guardrails. |
| **I-03** | `interactions/03-quickshell-service-architecture.md` | Reactive QML service wrappers for Config, Bars, Bar Widget Registry, Keybinds, Audio, Battery, Media, Network, Notifications, Compositor, Brightness, Telemetry, Keyboard, Accessibility, and Theme; the "pause pollers without a visible consumer" rule. |
