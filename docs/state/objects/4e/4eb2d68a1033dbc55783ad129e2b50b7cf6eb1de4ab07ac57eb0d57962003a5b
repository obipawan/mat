# Material 3 Expressive Desktop Environment Design System for Quickshell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete, agent-native Material 3 Expressive Desktop Environment Design System for Quickshell, including machine-readable W3C tokens, executable Quickshell QML token singletons, 6 foundational guides, 4 primitive specifications, 14 desktop shell component specifications, 3 interaction/service choreography specs, and an interactive visual showcase.

**Architecture:** A modular, progressive-disclosure specification suite rooted at `AGENTS.md` and `design-system/INDEX.md`, backed by W3C JSON design tokens (`design-system/tokens/m3-tokens.json`) and canonical Qt6/Quickshell QML singletons (`design-system/tokens/qml/*.qml`). Visual exploration and token inspection are provided through both a native Cursor Canvas (`m3-quickshell-design-system.canvas.tsx`) and a standalone interactive desktop simulator (`showcase/index.html`), strictly isolated from QML specs via `AGENTS.md` rules.

**Tech Stack:** Quickshell (Qt6 / QtQuick / QML, `Quickshell.Wayland.WlrLayershell`, `Quickshell.Wayland.WlSessionLock`, `Quickshell.Services.*`), Material Design 3 HCT & Expressive Spring Physics, `matugen` dynamic color templates, W3C Design Tokens JSON, Cursor Canvas SDK (`cursor/canvas`), HTML5/CSS3/JS interactive simulator.

**Spec:** `docs/superpowers/specs/2026-10-26-m3-quickshell-desktop-design-system-design.md`

## Global Constraints

- Every shell component specification in `design-system/shell-components/` MUST include all 8 mandatory sections: (1) Purpose & Wayland Layer Config, (2) Adaptive Dual-Mode Behavior (`tiling` vs. `floating`), (3) Visual Anatomy & ASCII/Mermaid Layout, (4) Token Mapping Table, (5) Interactive State Matrix, (6) Motion & Morph Choreography, (7) Quickshell Service & IPC Bindings, and (8) Canonical QML Reference Skeleton.
- All dynamic numeric readouts (clock, battery %, volume %, network speed, timers) MUST specify `font.features: { "tnum": 1 }` (tabular numerals).
- Both surface modes (`opaque_tonal` and `frosted_tonal_glass`) and both desktop paradigms (`tiling` and `floating`) MUST be explicitly supported in the token singletons and component specs.
- Zero placeholders (`TBD`, `TODO`, `implement later`) are permitted in any specification, token file, QML singleton, or visual showcase.

---

### Task 1: Root Agent Router, Master Index, W3C Token JSON, Matugen Template & Canonical QML Token Singletons

**Files:**
- Create: `AGENTS.md`
- Create: `design-system/INDEX.md`
- Create: `design-system/tokens/m3-tokens.json`
- Create: `design-system/tokens/matugen-template.toml`
- Create: `design-system/tokens/qml/qmldir`
- Create: `design-system/tokens/qml/Tokens.qml`
- Create: `design-system/tokens/qml/ColorTokens.qml`
- Create: `design-system/tokens/qml/MotionTokens.qml`
- Create: `design-system/tokens/qml/ShapeTokens.qml`
- Create: `design-system/tokens/qml/TypographyTokens.qml`
- Create: `design-system/tokens/qml/MetricTokens.qml`

**Interfaces:**
- Consumes: Architectural spec (`docs/superpowers/specs/2026-10-26-m3-quickshell-desktop-design-system-design.md`)
- Produces:
  - `Tokens.color.<role>` (48 M3 HCT color roles + desktop semantic tokens + `resolveSurface(tier)` for `opaque_tonal` vs. `frosted_tonal_glass`)
  - `Tokens.motion.<springOrCurve>` (`springFastSpatial`, `springDefaultSpatial`, `springSlowSpatial`, `springFastEffects`, `springDefaultEffects`)
  - `Tokens.shape.<radius>` (`none`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `full`, morph helpers)
  - `Tokens.typography.<scale>` (`displayLarge`..`labelSmall` + `familySans`, `familyDisplay`, `familyMono`, `tabularFeatures`)
  - `Tokens.metrics.<metric>` (density modes `compact`/`comfortable`/`spacious`, bar heights, spacing scale, Z-layer constants)

- [x] **Step 1: Create `AGENTS.md` and `design-system/INDEX.md`**
  Define the AI agent context-loading protocol, strict QML vs. showcase isolation boundary, 9-phase DE implementation build order, and master component-to-token index table.

- [x] **Step 2: Create `design-system/tokens/m3-tokens.json` and `design-system/tokens/matugen-template.toml`**
  Define all 48 M3 HCT color roles across Dark and Light palettes (plus 6 seed themes: Aurora Violet, Cyber Emerald, Solar Amber, Sakura Rose, Glacier Cyan, Graphite Monochrome), surface tier alpha/blur tables, M3 Expressive spring physics parameters, typography scales, corner radii, and `matugen` dynamic wallpaper generation config.

- [x] **Step 3: Create the Quickshell QML Singleton Module (`design-system/tokens/qml/*`)**
  Implement `qmldir`, `Tokens.qml`, `ColorTokens.qml`, `MotionTokens.qml`, `ShapeTokens.qml`, `TypographyTokens.qml`, and `MetricTokens.qml` with `pragma Singleton` and reactive QtQuick properties for `darkMode`, `surfaceMode` (`"opaque_tonal"` | `"frosted_tonal_glass"`), `desktopMode` (`"tiling"` | `"floating"`), and `densityMode` (`"compact"` | `"comfortable"` | `"spacious"`).

- [x] **Step 4: Verify token JSON validity and QML singleton completeness**
  Run `python3 -m json.tool design-system/tokens/m3-tokens.json > /dev/null` and verify all 6 QML files are registered in `design-system/tokens/qml/qmldir`.

---

### Task 2: M3 Desktop Foundations Specification Suite (`design-system/foundations/`)

**Files:**
- Create: `design-system/foundations/01-color-and-surfaces.md`
- Create: `design-system/foundations/02-typography-and-iconography.md`
- Create: `design-system/foundations/03-motion-and-morphing.md`
- Create: `design-system/foundations/04-interaction-states-and-input.md`
- Create: `design-system/foundations/05-wayland-layershell-spatial.md`
- Create: `design-system/foundations/06-adaptive-desktop-modes.md`

**Interfaces:**
- Consumes: `Tokens.*` singletons from Task 1
- Produces: Foundational rules referenced by all primitives (Task 3) and shell components (Tasks 4 & 5)

- [x] **Step 1: Write `01-color-and-surfaces.md` and `02-typography-and-iconography.md`**
  Document HCT tonal elevation, the 5-tier Dual-Surface Engine (`opaque_tonal` vs. `frosted_tonal_glass`), dynamic album-art/wallpaper seeding, WCAG contrast guardrails, desktop type scale, `tnum` tabular numeral enforcement, and Material Symbols variable axes (`FILL`, `wght`, `GRAD`, `opsz`).

- [x] **Step 2: Write `03-motion-and-morphing.md` and `04-interaction-states-and-input.md`**
  Document M3 Expressive spatial vs. effects springs in QtQuick (`SpringAnimation` / `NumberAnimation`), interactive corner radius morphing (`radius.full` -> `radius.md`), shared container transforms, desktop state layers (`Hover 8%`, `Press 12%`, `Focus 12% + 2px ring`, `Drag 16%`), scroll wheel increments, and middle/right-click mappings.

- [x] **Step 3: Write `05-wayland-layershell-spatial.md` and `06-adaptive-desktop-modes.md`**
  Document `WlrLayershell` layer assignments (`Background`, `Bottom`, `Top`, `Overlay`), `WlSessionLock`, `exclusiveZone` calculations, `WlrKeyboardFocus` state machines, multi-monitor policies, and runtime layout adaptations between `tiling` mode (Hyprland/Niri/Sway) and `floating` mode (traditional desktop).

---

### Task 3: Atomic M3 QML Primitives Specification Suite (`design-system/primitives/`)

**Files:**
- Create: `design-system/primitives/01-surfaces-and-containers.md`
- Create: `design-system/primitives/02-buttons-and-chips.md`
- Create: `design-system/primitives/03-controls-sliders-and-inputs.md`
- Create: `design-system/primitives/04-menus-popovers-and-tooltips.md`

**Interfaces:**
- Consumes: `Tokens.*` (Task 1) and Foundations (Task 2)
- Produces: Reusable QML component specifications (`M3Surface`, `M3GlassPanel`, `M3Card`, `M3Divider`, `M3Scrim`, `M3ScreenCorners`, `M3Button`, `M3IconButton`, `M3SegmentedButton`, `M3FilterChip`, `M3BarPill`, `M3Switch`, `M3Slider`, `M3TextField`, `M3SearchField`, `M3CircularProgress`, `M3LinearProgress`, `M3Popover`, `M3ContextMenu`, `M3Tooltip`, `M3ScrollBar`)

- [x] **Step 1: Write `01-surfaces-and-containers.md` and `02-buttons-and-chips.md`**
  Specify prop APIs, anatomy, token tables, state matrices, corner morph rules, and canonical QML implementations for all surface containers, buttons, segmented controls, chips, and `M3BarPill`.

- [x] **Step 2: Write `03-controls-sliders-and-inputs.md` and `04-menus-popovers-and-tooltips.md`**
  Specify prop APIs, anatomy, token tables, state matrices, and canonical QML implementations for `M3Switch` (thumb icon morph), `M3Slider` (M3 Expressive thick split-track with `4px` thumb gap), text/search fields, progress indicators, `M3Popover`, `M3ContextMenu`, `M3Tooltip`, and `M3ScrollBar`.

---

### Task 4: Desktop Shell Components Part 1 — Bars, Dock, Control Center, Notifications, Calendar, Media & OSDs (`01`–`07`)

**Files:**
- Create: `design-system/shell-components/01-topbar.md`
- Create: `design-system/shell-components/02-bottom-bar-dock.md`
- Create: `design-system/shell-components/03-control-center.md`
- Create: `design-system/shell-components/04-notifications.md`
- Create: `design-system/shell-components/05-calendar-and-weather.md`
- Create: `design-system/shell-components/06-media-player-popover.md`
- Create: `design-system/shell-components/07-osd-huds.md`

**Interfaces:**
- Consumes: `Tokens.*` (Task 1), Foundations (Task 2), and Primitives (Task 3)
- Produces: Complete 8-section specifications for shell components `01` through `07`

- [x] **Step 1: Write `01-topbar.md`, `02-bottom-bar-dock.md`, and `03-control-center.md`**
  Include all 8 mandatory sections for the 3-zone Topbar (Island, Floating Pill, Edge-to-Edge modes), Adaptive Bottom Dock/Taskbar (Tiling smart-dodge pill dock vs. Floating dock/taskbar), and Quick Settings Control Center (dual-action split tiles, inline expandable sub-sheets, thick sliders).

- [x] **Step 2: Write `04-notifications.md`, `05-calendar-and-weather.md`, `06-media-player-popover.md`, and `07-osd-huds.md`**
  Include all 8 mandatory sections for Toast Notification Stack & Notification Center, Calendar/Weather Bento Popover, MPRIS Media Popover (dynamic album-art HCT seeding & waveform scrubber), and OSD HUDs (Volume, Brightness, Privacy Mic/Cam Pill, CapsLock, Workspace HUD).

---

### Task 5: Desktop Shell Components Part 2 — Launcher, Overview, Lock Screen, Power Menu, Polkit, Screen Capture & Theme Picker (`08`–`14`)

**Files:**
- Create: `design-system/shell-components/08-app-and-command-launcher.md`
- Create: `design-system/shell-components/09-workspace-and-window-overview.md`
- Create: `design-system/shell-components/10-lock-screen.md`
- Create: `design-system/shell-components/11-power-and-session-menu.md`
- Create: `design-system/shell-components/12-polkit-authentication-dialog.md`
- Create: `design-system/shell-components/13-screen-capture-and-recording.md`
- Create: `design-system/shell-components/14-wallpaper-and-theme-picker.md`

**Interfaces:**
- Consumes: `Tokens.*` (Task 1), Foundations (Task 2), and Primitives (Task 3)
- Produces: Complete 8-section specifications for shell components `08` through `14`

- [x] **Step 1: Write `08-app-and-command-launcher.md`, `09-workspace-and-window-overview.md`, `10-lock-screen.md`, and `11-power-and-session-menu.md`**
  Include all 8 mandatory sections for Unified App/Command Launcher (prefix modes `>`, `=`, `:`, `clip`, `win`), Workspace/Window Overview (Tiling strip/grid vs. Floating spatial expose), `WlSessionLockSurface` Lock Screen (PAM state machine & shape-morphing password dots), and Power/Session Modal (2-step morphing confirmation).

- [x] **Step 2: Write `12-polkit-authentication-dialog.md`, `13-screen-capture-and-recording.md`, and `14-wallpaper-and-theme-picker.md`**
  Include all 8 mandatory sections for Polkit Privilege Escalation Dialog, Screenshot/Screen Recording Overlay & Topbar Recording Pill, and Wallpaper/Material You Theme Studio.

---

### Task 6: Cross-Surface Choreography, Keyboard Navigation Graph & Quickshell Service Architecture (`design-system/interactions/`)

**Files:**
- Create: `design-system/interactions/01-choreography-and-morphing.md`
- Create: `design-system/interactions/02-keyboard-navigation-and-submaps.md`
- Create: `design-system/interactions/03-quickshell-service-architecture.md`

**Interfaces:**
- Consumes: Tasks 1–5
- Produces: Global `ShellState` orchestration contract, keyboard focus & submap graphs, and Quickshell service adapter patterns

- [x] **Step 1: Write `01-choreography-and-morphing.md`, `02-keyboard-navigation-and-submaps.md`, and `03-quickshell-service-architecture.md`**
  Document popover mutual exclusion state machine, shared-origin pill-to-panel morphing trajectories, global Escape-key dismissal stack, roving tabindex & arrow-key grid navigation, and canonical Quickshell bindings for `Pipewire`, `UPower`, `Mpris`, `SystemTray`, `Notifications`, `PamContext`, and `Hyprland`/`Niri`/Wayland IPC.

---

### Task 7: Interactive Visual Showcase (Cursor Canvas + Standalone Desktop Simulator) & Verification Suite

**Files:**
- Create: `/Users/pawan.kumarm/.cursor/projects/Users-pawan-kumarm-workspace-mat/canvases/m3-quickshell-design-system.canvas.tsx`
- Create: `showcase/index.html`
- Create: `scripts/verify-design-system.sh`

**Interfaces:**
- Consumes: All tokens, foundations, primitives, and 14 shell component specifications (Tasks 1–6)
- Produces:
  - Interactive Cursor Canvas beside the chat for exploring tokens, surface modes, component matrices, Wayland Z-layers, and live component states
  - Standalone interactive desktop environment simulator (`showcase/index.html`) demonstrating all 14 M3 Expressive desktop surfaces, live HCT palette switching, Opaque vs. Frosted Tonal Glass toggle, and Tiling vs. Floating mode toggle
  - Automated verification script (`scripts/verify-design-system.sh`) validating zero placeholders, valid JSON, complete file inventory, and all 8 mandatory sections across all 14 shell component specs

- [x] **Step 1: Create Cursor Canvas `/Users/pawan.kumarm/.cursor/projects/Users-pawan-kumarm-workspace-mat/canvases/m3-quickshell-design-system.canvas.tsx`**
  Build the interactive design system reference canvas using `cursor/canvas` components and hooks (`useHostTheme`), ensuring zero TypeScript diagnostics errors.

- [x] **Step 2: Create standalone interactive M3 Desktop Simulator (`showcase/index.html`)**
  Build the interactive desktop environment playground where users can click and test all 14 shell surfaces, switch HCT seed palettes, toggle Dark/Light, Opaque/Glass, and Tiling/Floating modes, and inspect QML tokens.

- [x] **Step 3: Create and run `scripts/verify-design-system.sh`**
  Verify every file, JSON schema, QML singleton, and markdown section requirement passes with zero errors.
