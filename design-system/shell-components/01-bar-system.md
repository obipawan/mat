# Shell Component 01 — Configurable Bar System

> **Module**: `design-system/shell-components/01-bar-system.md`
> **Component ID**: `SC-01`
> **Primitives Used**: `M3Surface`, `M3BarPill`, `M3Tooltip`, `M3ContextMenu`
> **Widgets**: `02-bar-widgets.md` (`SC-02`) · **Configured in**: `16-settings.md` (`SC-16`, Settings → Bars)

---

## 1. Purpose & Wayland Layer Config

A **bar** is a content-agnostic, always-on-top strip anchored to one screen edge. There is no hardcoded Topbar or Dock: the familiar "top bar + dock" is simply the default **preset** of two bars. Users create as many bars as they like and configure each one's **edge** (`top`, `right`, `bottom`, `left`), **dimensions**, **mode** (continuous `bar` or detached `island`), **visibility**, and **widgets**. Every bar has three alignment sections — **start**, **center**, **end** — which also define the island groups in island mode.

| Property | Value (per bar, per screen) |
|---|---|
| **Quickshell Type** | `PanelWindow`, one per `(bar, screen)` pair (`Variants { model: BarService.instances }`) |
| **`WlrLayershell.namespace`** | `"mat-bar-" + bar.id` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` — always above normal windows. Fullscreen clients (video, games) still cover bars, which is intended |
| **Anchors** | `top` → `top, left, right`; `bottom` → `bottom, left, right`; `left` → `left, top, bottom`; `right` → `right, top, bottom`. The window is flush with the screen edge; the visual bar is inset by `edgeGap` inside it (edge hit extension) and by `endGap` at both ends (§1.1) |
| **`WlrLayershell.exclusiveZone`** | `bar.reserveSpace && visibleNow && bar.visibility !== "autohide" ? bar.thickness + edgeGap : 0`. Bars on the same edge stack outward-to-inward in config order; the compositor places each later bar inside earlier bars' exclusive zones |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.None` (`OnDemand` while `ShellState.barFocusActive` — Bar Focus Mode, `Ctrl+Alt+Tab`) |
| **Input Mask** | Bar mode: the bar strip from the screen edge to its inner edge. Island mode: the union of island columns, each extended to the screen edge; gaps between islands stay click-through. Auto-hidden: a `4px` reveal strip |

### 1.1 Bar Configuration Schema (`~/.config/mat-shell/config.json` → `bars[]`, owned by `ConfigService`)

| Field | Type / Values | Default | Notes |
|---|---|---|---|
| `id` | `string` | generated | Stable identity (namespaces, Settings deep links) |
| `name` | `string` | `"Bar 1"` | Shown in Settings and in the bar's context menu |
| `enabled` | `bool` | `true` | Disabled bars keep their config |
| `screens` | `"all"` \| `string[]` (output names) | `"all"` | Per-monitor placement |
| `position` | `"top"` \| `"right"` \| `"bottom"` \| `"left"` | `"top"` | Horizontal bars: top/bottom; vertical bars: left/right |
| `mode` | `"bar"` \| `"island"` | `"bar"` | Island: each non-empty section becomes its own capsule |
| `thickness` | `int` px | `Tokens.metrics.barThickness` (`40`) | Clamped to `barThicknessMin..barThicknessMax` (`28..96`; vertical `44..120`) |
| `length` | `"full"` \| `"fit"` \| `int` (`10..100` %) | `"full"` | `fit` hugs content (dock-like); percent of the edge length |
| `alignment` | `"start"` \| `"center"` \| `"end"` | `"center"` | Where a non-full bar sits along its edge |
| `marginHorizontal` | `int` px (`0..24`) | `Tokens.metrics.screenMargin` (`8`) | Left/right gap in screen axes. Top/bottom bars: the gap at both ends of the bar. Left/right bars: the gap to their screen edge |
| `marginVertical` | `int` px (`0..24`) | `Tokens.metrics.screenMargin` (`8`) | Top/bottom gap in screen axes. Top/bottom bars: the gap to their screen edge (and to the bar below on the same edge). Left/right bars: the gap at both ends |

**Derived gaps** (`BarService.edgeGap(bar)` / `endGap(bar)`): for horizontal bars `edgeGap = marginVertical` and `endGap = marginHorizontal`; for vertical bars the reverse. `edgeGap` feeds the exclusive zone, same-edge stacking, and edge hit extension. `endGap` insets the bar from the screen corners (and from bars reserved on the perpendicular edges). Margins stay screen-relative, so moving a bar to another edge never swaps what "horizontal" means. `edgeGap: 0` gives an edge-to-edge bar; a config with the legacy single `margin` migrates it into both fields.
| `visibility` | `"always"` \| `"autohide"` \| `"dodge"` \| `"auto"` | `"always"` | `dodge` hides while windows overlap the bar area; `auto` = `dodge` in tiling, `always` in floating |
| `reserveSpace` | `bool` | `true` | Whether windows tile around the bar (exclusive zone) |
| `sections` | `{ start: Widget[], center: Widget[], end: Widget[] }` | per preset | `Widget = { type: string, options?: object }` from the catalog in `SC-02` |

```json
{
  "schemaVersion": 1,
  "bars": [
    {
      "id": "top", "name": "Top bar", "position": "top", "mode": "bar",
      "thickness": 40, "length": "full", "marginHorizontal": 8, "marginVertical": 8, "visibility": "always", "reserveSpace": true,
      "sections": {
        "start":  [{ "type": "launcher" }, { "type": "workspaces", "options": { "count": 6 } }, { "type": "submap" }],
        "center": [{ "type": "windowTitle" }, { "type": "media" }],
        "end":    [{ "type": "recording" }, { "type": "privacy" }, { "type": "tray" }, { "type": "controlCenter" },
                   { "type": "clock", "options": { "preset": "weekdayTime" } }, { "type": "notifications" }]
      }
    },
    {
      "id": "dock", "name": "Dock", "position": "bottom", "mode": "island",
      "thickness": 64, "length": "fit", "marginHorizontal": 8, "marginVertical": 8, "visibility": "auto", "reserveSpace": true,
      "sections": { "start": [], "center": [{ "type": "apps", "options": { "pinned": ["firefox.desktop", "org.gnome.Nautilus.desktop"] } }], "end": [] }
    }
  ]
}
```

### 1.2 Presets (Settings → Bars → Presets)

| Preset | Bars |
|---|---|
| **Top bar + Dock** (default) | The two bars above |
| **Three islands** | One bottom `island` bar (`thickness: 56`, `marginHorizontal: 8`, `marginVertical: 10`): start `power, workspaces, widgetPeek` · center `search, apps` · end `recording, privacy, media, tray, controlCenter, clock, notifications` |
| **Top bar only** | The top bar with `apps` appended to its center section |
| **Left rail** | One `left` bar (`thickness: 56`, `marginHorizontal: 8`, `marginVertical: 8`): start `launcher, workspaces` · center `apps` · end `privacy, tray, controlCenter, clock, notifications, power` |
| **Minimal** | One top `island` bar, `length: "fit"`, `visibility: "autohide"`: center `workspaces, clock, controlCenter` |

Applying a preset replaces the current bars and shows an `Undo` snackbar for `8s`.

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **`visibility: "auto"`** | Behaves as `dodge`: the bar hides while any tiled window occupies its area, and reveals on an empty workspace or after a `120ms` dwell on its `4px` edge strip | Behaves as `always` (pinned, reserves space) |
| **Workspace / Window widgets** | `workspaces` shows the full strip; `windowTitle` shows tiling flags | `workspaces` may collapse to an Overview button with a single workspace; `windowTitle` shows the app menu |
| **Keyboard** | Identical in both modes (`06-adaptive-desktop-modes.md` §4) | Identical |

### 2.1 Configuration Guardrails (Flexibility Without Breaking the Desktop)

1. **Security indicators can't disappear**: If no **visible** bar on a screen shows `privacy` (or `recording`), either because none hosts it or because the hosting bar is auto-hidden or dodged, `BarService` shows a fallback pill on `WlrLayer.Overlay` in that screen's top-end corner (inside `BarService.insets`) while the mic, camera, or recorder is active. Settings explains this when the last instance is removed.
2. **Core actions stay reachable**: With zero bars, or bars without `launcher` / `power`, the launcher (`Super`), Settings (`Super+,`), and Power Menu (`Super+Escape`) remain bound. Settings shows that reminder whenever a bar config lacks them.
3. **Space budget**: At most 2 bars per edge per screen, and total reserved space per axis is capped at 25% of the screen dimension. Settings disables the controls that would exceed either limit and says why.
4. **Thickness bounds**: Horizontal `28..96px`, vertical `44..120px`, so every widget keeps at least `Tokens.metrics.minPointerTarget`.
5. **Vertical bars adapt widgets**: Text-heavy widgets switch to compact variants (window title → icon with tooltip; media → art well; clock → stacked `HH` / `mm`), defined per widget in `SC-02`.
6. **Overflow**: When a section can't fit, widgets collapse in reverse priority (`SC-02` §2.1) into a trailing overflow chevron menu. Nothing is clipped or hidden silently.
7. **Duplicates are allowed**: The same widget may appear on several bars (e.g., a clock on every monitor's bar). Popovers grow out of the instance that was clicked; keyboard/IPC-opened popovers use the first instance on the focused screen.
8. **Live and safe**: Edits apply immediately with spring reflow. Invalid combinations are prevented in the UI rather than rejected after saving.

---

## 3. Visual Anatomy & ASCII Layout

```text
   BAR MODE (position: top, length: full) — one continuous Tier 0 surface; sections align start | center | end
╭──────────────────────────────────────────────────────────────────────────────────────────────╮
│ [launcher][1 2 (3) 4][RESIZE]          [Design Spec — Firefox][Midnight City]     [●][⌃][wifi vol 86%][Mon 26 17:53][🔔3] │
╰──────────────────────────────────────────────────────────────────────────────────────────────╯
   ▲ start                                  ▲ center (always truly centered)                  ▲ end

   ISLAND MODE (same sections) — each non-empty section becomes its own capsule; empty sections vanish
╭──────────────────────╮                ╭──────────────────────────────╮                ╭─────────────────────────────╮
│ [launcher][1 2 (3) 4] │                │ [Design Spec — Firefox][Media] │                │ [●][⌃][wifi vol][17:53][🔔3] │
╰──────────────────────╯                ╰──────────────────────────────╯                ╰─────────────────────────────╯

   VERTICAL BAR (position: left, mode: bar)       FIT-LENGTH ISLAND (position: bottom, length: fit) — the classic dock
   ╭────╮                                         ╭──────────────────────────────╮
   │ ⊞  │  start: launcher                        │  [wez] [ff] [code] [files]   │   center: apps
   │ 1  │         workspaces (vertical strip)     ╰──────────────────────────────╯
   │(2) │
   │ 3  │
   │    │
   │ ▣  │  center: apps (vertical)
   │ ▣  │
   │    │
   │ ⌃  │  end: tray, controlCenter,
   │ 17 │       clock (stacked HH / mm)
   │ 53 │
   ╰────╯
```

### 3.1 Layout Rules
- **Orientation**: `top` / `bottom` lay sections out on a row; `left` / `right` on a column (start = top end of the edge).
- **Center stays centered**: In bar mode the center section is centered on the bar regardless of start/end widths; start and end grow toward it and overflow (§2.1 rule 6) before they can collide.
- **Island geometry**: Capsule thickness = `bar.thickness`, radius = `thickness / 2`, gap between islands and to the screen ends = `endGap` (minimum `8px` between islands). A `fit` island bar with a single non-empty section renders exactly one capsule (the dock).
- **Bar-mode shape**: radius = `Tokens.shape.full` when `edgeGap > 0`; `0` when `edgeGap === 0` (flush with its edge, paired with `M3ScreenCorners`). A flush bar may still keep an `endGap` (e.g. `marginVertical: 0`, `marginHorizontal: 16` for a top bar that stops short of the corners).
- **Widget sizing**: Widget pills are `thickness − 2 × Tokens.metrics.barPadding` tall (horizontal) or wide (vertical); app wells scale with thickness (`SC-02`).

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Border Token | Metric Token |
|---|---|---|---|
| **Bar Surface (bar mode)** | `Tokens.color.surfaceTier(0)` | `1px` `Tokens.color.surfaceBorder(0)` | `thickness` (default `Tokens.metrics.barThickness` = `40px`), radius `full` or `0` |
| **Island Capsule** | `Tokens.color.surfaceTier(0)` | `1px` `Tokens.color.surfaceBorder(0)` | `thickness` (preset `Tokens.metrics.islandThickness` = `56px`), radius `thickness / 2` |
| **Section Gap** | — | — | `Tokens.metrics.barSectionGap` (`8px`) between widgets; `Tokens.metrics.barPadding` (`5px`) inside the surface |
| **Overflow Chevron** | `Tokens.color.surfaceTier(2)` | `onSurfaceVariant` | `minPointerTarget` square, `M3ContextMenu` lists hidden widgets |
| **Reveal Strip (auto-hidden)** | transparent | — | `4px` along the bar's edge, `120ms` dwell |
| **Edit Highlight (Settings preview)** | `Tokens.color.primary` @ `16%` overlay | `2px` `Tokens.color.primary` outline | Shown on the live bar while it is selected in Settings → Bars |

---

## 5. Interactive State Matrix

| State | Visual & Behavioral Response |
|---|---|
| **Shown** | Bar at rest; widgets interactive; exclusive zone applied when `reserveSpace`. |
| **Auto-Hidden / Dodged** | Slides out past its edge (`springDefaultSpatial`), exclusive zone `0`, input mask shrinks to the `4px` reveal strip. |
| **Revealing** | Edge dwell `120ms` or a workspace becoming empty slides the bar back in; it hides again `600ms` after the pointer leaves (autohide) or when windows return (dodge). |
| **Bar Focus Mode** | `Ctrl+Alt+Tab`: keyboard focus enters the first bar on the focused screen; `Tab` moves between sections (and to the next bar); arrows move between widgets; `Escape` exits. |
| **Right-Click on Empty Bar Area** | `M3ContextMenu`: `Configure "<name>"…` (opens Settings → Bars with this bar selected), `Add widget…`, `Bar ↔ Island`, `Hide this bar`. |
| **Selected in Settings** | Edit highlight outline on the live bar; changes reflow live. |
| **Disabled / Removed** | Fades out (`springDefaultEffects`); windows reflow into the freed space. |

---

## 6. Motion & Morph Choreography

1. **Reveal / Hide**: Translates along the bar's normal axis by `thickness + edgeGap + 16` using `Tokens.motion.springDefaultSpatial` (`enabled: Tokens.motion.spatialMotionEnabled`; a `100ms` fade under Reduced Motion).
2. **Bar ↔ Island Morph**: Switching mode splits the continuous surface at section boundaries. The capsules shrink to their content widths and round their ends with `springDefaultSpatial` while the gaps fade in, and joining runs the reverse.
3. **Edge Change**: Moving a bar to another edge fades it out at the old edge (`120ms`) and springs it in at the new one; vertical/horizontal widget variants swap during the fade.
4. **Widget Reflow**: Adding, removing, or reordering widgets animates siblings with `Move` transitions on `springFastSpatial`; a removed widget scales to `0.8` and fades.

---

## 7. Quickshell Service & IPC Bindings

- **`ConfigService`** (`~/.config/mat-shell/config.json`, `FileView` + `JsonAdapter`): `bars[]`, `addBar()`, `updateBar(id, patch)`, `removeBar(id)` (with undo), `applyPreset(name)`. Writes are debounced (`300ms`) and atomic (`FileView.atomicWrites`).
- **`BarService`**:
  - `instances`: `(bar, screen)` pairs for enabled bars
  - `insets(screen)`: `{ top, right, bottom, left }`, the space covered by visible bars on each edge, reserved or not (used by toasts, widgets, popovers); `maxInsets(screen)` counts hidden bars as shown (used by the OSD so it never jumps)
  - `edgeGap(bar)` / `endGap(bar)`: the screen-axis margins resolved for the bar's orientation (§1.1)
  - `innerEdge(barId, screen)`: distance from the screen edge to the bar's inner edge (popover anchor)
  - `regions(screen)`: bar rects for popover click-catcher subtraction (`05-wayland-layershell-spatial.md` §3.3)
  - `hostsWidget(screen, type, visibleOnly)`: with `visibleOnly`, drives the privacy / recording fallback (§2.1 rule 1)
- **`ShellState`**: `togglePopover(name, triggerItem)` records the trigger rect **and its bar's edge** (`popoverOriginEdge`), so popovers open toward the screen center from any edge (`M3Popover`, `04-menus-popovers-and-tooltips.md` §1). `qs ipc call shell openSettings bars` opens Settings → Bars.

---

## 8. Canonical QML Reference Skeleton (`Bar.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

Variants {
    model: BarService.instances // [{ bar, screen }]

    PanelWindow {
        id: barWindow
        required property var modelData
        readonly property var bar: modelData.bar
        readonly property bool vertical: bar.position === "left" || bar.position === "right"
        readonly property bool shown: BarService.isVisible(bar.id, modelData.screen)
        readonly property int extent: bar.thickness + BarService.edgeGap(bar)

        screen: modelData.screen
        WlrLayershell.namespace: "mat-bar-" + bar.id
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: bar.reserveSpace && shown && bar.visibility !== "autohide" ? extent : 0
        WlrLayershell.keyboardFocus: ShellState.barFocusActive ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: bar.position !== "bottom"
            bottom: bar.position !== "top"
            left: bar.position !== "right"
            right: bar.position !== "left"
        }
        implicitHeight: vertical ? 0 : extent
        implicitWidth: vertical ? extent : 0

        mask: Region { item: shown ? hitStrip : revealStrip }

        // Inset visual area: edgeGap toward the screen edge, endGap at both ends, sized by `length` along the edge
        Item {
            id: hitStrip
            anchors.fill: parent
        }
        Item {
            id: revealStrip
            width: barWindow.vertical ? 4 : parent.width
            height: barWindow.vertical ? parent.height : 4
            x: bar.position === "right" ? parent.width - 4 : 0
            y: bar.position === "bottom" ? parent.height - 4 : 0
            HoverHandler { onHoveredChanged: BarService.setEdgeHover(bar.id, barWindow.screen, hovered) }
        }

        BarLayout {
            id: layout
            bar: barWindow.bar
            vertical: barWindow.vertical
            // Slides past the edge when hidden
            transform: Translate {
                x: barWindow.shown ? 0 : (bar.position === "left" ? -barWindow.extent - 16 : bar.position === "right" ? barWindow.extent + 16 : 0)
                y: barWindow.shown ? 0 : (bar.position === "top" ? -barWindow.extent - 16 : bar.position === "bottom" ? barWindow.extent + 16 : 0)
                Behavior on x { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springDefaultSpatial.spring; damping: Tokens.motion.springDefaultSpatial.damping } }
                Behavior on y { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springDefaultSpatial.spring; damping: Tokens.motion.springDefaultSpatial.damping } }
            }
        }
    }
}

// BarLayout.qml — one continuous surface (bar mode) or one capsule per non-empty section (island mode)
Item {
    id: root
    required property var bar
    required property bool vertical
    readonly property var sectionNames: ["start", "center", "end"]

    // Screen-axis margins resolved for this bar's orientation (§1.1)
    readonly property int edgeGap: BarService.edgeGap(bar)
    readonly property int endGap: BarService.endGap(bar)

    anchors.fill: parent
    anchors.topMargin: bar.position === "top" ? edgeGap : (vertical ? endGap : 0)
    anchors.bottomMargin: bar.position === "bottom" ? edgeGap : (vertical ? endGap : 0)
    anchors.leftMargin: bar.position === "left" ? edgeGap : (vertical ? 0 : endGap)
    anchors.rightMargin: bar.position === "right" ? edgeGap : (vertical ? 0 : endGap)

    // Bar mode: single Tier 0 surface spanning `length`
    M3Surface {
        id: barSurface
        visible: root.bar.mode === "bar"
        tier: 0
        cornerRadius: root.edgeGap > 0 ? Tokens.shape.full : 0
        width: root.vertical ? root.bar.thickness : BarService.lengthPx(root.bar, root.width, sections.implicitWidth)
        height: root.vertical ? BarService.lengthPx(root.bar, root.height, sections.implicitHeight) : root.bar.thickness
        x: root.vertical ? 0 : BarService.alignOffset(root.bar, root.width, width)
        y: root.vertical ? BarService.alignOffset(root.bar, root.height, height) : 0
    }

    // Sections: start / center (truly centered) / end
    Repeater {
        id: sections
        model: root.sectionNames
        delegate: Item {
            id: section
            required property string modelData
            readonly property var widgets: root.bar.sections[modelData]
            visible: widgets.length > 0
            width: root.vertical ? root.bar.thickness : flow.implicitWidth + Tokens.metrics.barPadding * 2
            height: root.vertical ? flow.implicitHeight + Tokens.metrics.barPadding * 2 : root.bar.thickness
            x: root.vertical ? 0 : BarService.sectionOffset(root.bar, modelData, barSurface, width)
            y: root.vertical ? BarService.sectionOffset(root.bar, modelData, barSurface, height) : 0

            // Island mode: every non-empty section is its own capsule
            M3Surface {
                anchors.fill: parent
                visible: root.bar.mode === "island"
                tier: 0
                cornerRadius: root.bar.thickness / 2
            }

            GridLayout {
                id: flow
                anchors.centerIn: parent
                flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
                rows: root.vertical ? -1 : 1
                columns: root.vertical ? 1 : -1
                rowSpacing: Tokens.metrics.barSectionGap
                columnSpacing: Tokens.metrics.barSectionGap

                Repeater {
                    model: section.widgets
                    delegate: BarWidgetLoader {         // SC-02 registry: type -> component
                        required property var modelData
                        type: modelData.type
                        options: modelData.options ?? ({})
                        bar: root.bar
                        vertical: root.vertical
                    }
                }
            }
        }
    }
}
```
