# Foundation 05 — Wayland `WlrLayershell` Spatial Z-Order, Multi-Monitor & Scaling Architecture

> **Module**: `design-system/foundations/05-wayland-layershell-spatial.md`
> **Quickshell Imports**: `Quickshell`, `Quickshell.Wayland`

---

## 1. Wayland Layer-Shell Z-Order Hierarchy

In a Wayland desktop environment, shell surfaces do not live in the normal window tree; they bind to the `zwlr_layer_shell_v1` protocol (`Quickshell.Wayland.WlrLayershell`) and `ext_session_lock_v1` (`Quickshell.Wayland.WlSessionLock`).

```text
Z-INDEX (Top to Bottom)
=========================================================================================
[L5: WlSessionLock]     10-LockScreen (Blocks all compositor rendering when session locked)
-----------------------------------------------------------------------------------------
[L4: WlrLayer.Overlay]  11-PowerSessionMenu (scrim + cards)
                        12-PolkitDialog (scrim + modal)
                        13-ScreenCaptureHud (region crosshair + floating toolbar)
                        08-AppCommandLauncher (scrim + search modal)
                        09-WorkspaceOverview (full-screen expose)
                        07-OsdHuds (Volume, Brightness, Workspace HUD — keyboardFocus: None)
                        M3ScreenCorners (top/bottom screen bezel rounders — passthrough input)
-----------------------------------------------------------------------------------------
[L3: WlrLayer.Top]      04-NotificationToasts (corner stack, clear of bar insets)
                        03-ControlCenter | 05-CalendarWeather | 06-MediaPopover | 14-WallpaperPicker
                        01-Bars × N (user-configured, any edge; exclusiveZone: thickness + margin
                                     when reserveSpace, 0 when auto-hidden; same-edge bars stack inward)
-----------------------------------------------------------------------------------------
[L2: Tiled / Floating Client Windows]  (Managed by Hyprland / Niri / Sway / Wayland Compositor)
                        16-Settings (xdg toplevel FloatingWindow; app window, not layer-shell)
-----------------------------------------------------------------------------------------
[L1: WlrLayer.Bottom]   Desktop Scrim / Overview Dimmer
-----------------------------------------------------------------------------------------
[L0: WlrLayer.Background] Wallpaper Surface & 15-DesktopWidgets (raised to Overlay during Widget Peek)
=========================================================================================
```

---

## 2. Authoritative Surface Configuration Matrix

Every `PanelWindow` created by an AI agent MUST configure these exact `WlrLayershell` properties:

| Surface Component | `WlrLayershell.namespace` | `WlrLayershell.layer` | `anchors` | `exclusiveZone` | `WlrLayershell.keyboardFocus` | Input Mask (`mask`) |
|---|---|---|---|---|---|---|
| **Wallpaper Surface** | `"mat-wallpaper"` | `WlrLayer.Background` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.None` | None (empty `Region {}`) |
| **Desktop Widgets (`15`)** | `"mat-desktop-widgets"` | `WlrLayer.Background` (`WlrLayer.Overlay` while `ShellState.widgetPeekActive`) | `top, bottom, left, right` | `-1` | `None` (`OnDemand` during Widget Peek) | Union `Region` of visible widget bounding boxes (empty while hidden) |
| **Screen Corners** | `"mat-corners"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.None` | Empty `Region {}` (100% click-through) |
| **Bar** (`01`, one per `(bar, screen)`) | `"mat-bar-" + bar.id` | `WlrLayer.Top` | The bar's edge + both adjacent edges (`top` → `top, left, right`; `left` → `left, top, bottom`; …); the window is flush with the edge and the visual bar is inset by `edgeGap` (and by `endGap` at its ends) | `reserveSpace && shown && visibility !== "autohide" ? thickness + edgeGap : 0` | `WlrKeyboardFocus.None` (`OnDemand` in Bar Focus Mode) | Bar mode: strip from the screen edge to the bar's inner edge. Island mode: union of island columns, each extended to the edge. Hidden: the `4px` reveal strip |
| **Privacy Fallback Pill** (`01` §2.1) | `"mat-privacy-fallback"` | `WlrLayer.Overlay` | Top-end corner inside `BarService.insets` | `0` | `WlrKeyboardFocus.None` | The pill only; mapped only while capture is active and no bar on the screen hosts `privacy` / `recording` |
| **Control Center** (`03`) | `"mat-control-center"` | `WlrLayer.Top` | `top, bottom, left, right` (click-catcher); card placed by `M3Popover` origin-edge placement | `-1` (`ExclusionMode.Ignore`, §4.4) | `WlrKeyboardFocus.OnDemand` | Full screen minus `BarService.regions(screen)` while open (§3.3) |
| **Notification Toasts** (`04`) | `"mat-toasts"` | `WlrLayer.Top` | The configured corner (default top-end), offset by `BarService.insets(screen)` | `-1` (`ExclusionMode.Ignore`, §4.4) | `WlrKeyboardFocus.None` (`OnDemand` when inline reply active) | Tight `Region` around visible toast cards only |
| **Calendar & Weather** (`05`) | `"mat-calendar"` | `WlrLayer.Top` | `top, bottom, left, right` (click-catcher); card placed by `M3Popover` | `-1` (`ExclusionMode.Ignore`) | `WlrKeyboardFocus.OnDemand` | Full screen minus bar regions while open |
| **Media Popover** (`06`) | `"mat-media"` | `WlrLayer.Top` | `top, bottom, left, right` (click-catcher); card placed by `M3Popover` | `-1` (`ExclusionMode.Ignore`) | `WlrKeyboardFocus.OnDemand` | Full screen minus bar regions while open |
| **OSD HUD** (`07`) | `"mat-osd"` | `WlrLayer.Overlay` | `bottom` (centered, `margin: BarService.maxInsets(screen).bottom + spaceXxl`) | `-1` (`ExclusionMode.Ignore`) | `WlrKeyboardFocus.None` | Empty `Region {}` (unless interactive slider hovered) |
| **App/Command Launcher** (`08`) | `"mat-launcher"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `0` | `WlrKeyboardFocus.Exclusive` | Full screen |
| **Workspace Overview** (`09`) | `"mat-overview"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.Exclusive` | Full screen |
| **Lock Screen** (`10`) | `WlSessionLock` | Session Lock | Full output | N/A | `Exclusive` | Full output |
| **Power Menu** (`11`) | `"mat-power"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.Exclusive` | Full screen |
| **Polkit Dialog** (`12`) | `"mat-polkit"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.Exclusive` | Full screen |
| **Screen Capture HUD** (`13`) | `"mat-capture"` | `WlrLayer.Overlay` | `top, bottom, left, right` | `-1` | `WlrKeyboardFocus.Exclusive` | Full screen during selection |
| **Wallpaper & Theme** (`14`) | `"mat-theme-studio"` | `WlrLayer.Top` | `bottom, left, right` | `0` | `WlrKeyboardFocus.Exclusive` | Full screen when open |
| **Settings** (`16`) | — (`FloatingWindow`, title `"Settings — Mat Shell"`) | xdg toplevel (normal window stack) | Compositor-placed (float + centre rule) | N/A | Normal toplevel focus | N/A — documented exception: Settings is an application window, not a shell panel |

---

## 3. Input Region Masking (`PanelWindow.mask`) — Critical Anti-Bug Pattern

A common Quickshell bug occurs when a `PanelWindow` is sized larger than its visible card (to accommodate drop shadows, bounce overshoot, or toast animations) and accidentally blocks mouse clicks to underlying desktop windows.

### 3.1 Tight Masks for Partially Transparent Surfaces

**Mandatory Rule**: Any `PanelWindow` that remains mapped while partially transparent (such as `NotificationToasts`, any `fit`-length bar, or any bar in `island` mode) **MUST** bind `mask: Region { item: visibleContainer }` so transparent regions pass pointer events straight through to Wayland client windows:

```qml
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: toastLayerWindow
    WlrLayershell.namespace: "mat-toasts"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors { top: true; right: true }
    implicitWidth: 400
    implicitHeight: 600
    color: "transparent"

    // CRITICAL: Only capture pointer input inside the actual toast column
    mask: Region {
        item: toastColumn
    }

    Column {
        id: toastColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 8
    }
}
```

### 3.2 Edge Hit Extension Pattern (Floating Bars Keep Fitts's Edge)

A bar's visual margin must not create a dead strip at the screen edge, whichever edge the bar is on. Anchor the window flush to that edge, inset the visual surface by the bar's edge gap, and extend each widget's hit area toward the edge by `edgeReach = edgeGap + barPadding`. Margins are configured in screen axes (`marginHorizontal`, `marginVertical`); `BarService.edgeGap(bar)` picks the one facing the bar's edge and `endGap(bar)` the other (`01-bar-system.md` §1.1). `M3BarPill` and `M3AppIcon` do this from `barEdge` / `edgeReach` (`02-buttons-and-chips.md` §4–5). Qt Quick delivers pointer events to the extended handler area even though it lies outside the pill's visual bounds:

```qml
// Generic for any edge (SC-01 §8 has the full bar skeleton)
PanelWindow {
    id: barWindow
    required property var bar                         // { position, thickness, marginHorizontal, marginVertical, ... }
    readonly property bool vertical: bar.position === "left" || bar.position === "right"
    readonly property int edgeGap: vertical ? bar.marginHorizontal : bar.marginVertical   // BarService.edgeGap(bar)
    readonly property int endGap: vertical ? bar.marginVertical : bar.marginHorizontal    // BarService.endGap(bar)
    anchors {                                         // flush with the bar's edge
        top: bar.position !== "bottom"; bottom: bar.position !== "top"
        left: bar.position !== "right"; right: bar.position !== "left"
    }
    implicitHeight: vertical ? 0 : bar.thickness + edgeGap
    implicitWidth: vertical ? bar.thickness + edgeGap : 0
    WlrLayershell.exclusiveZone: bar.thickness + edgeGap
    color: "transparent"                              // mask = full strip, including the edge gap

    M3Surface {                                       // visual bar keeps its floating margins
        anchors.fill: parent
        anchors.topMargin: bar.position === "top" ? barWindow.edgeGap : (barWindow.vertical ? barWindow.endGap : 0)
        anchors.bottomMargin: bar.position === "bottom" ? barWindow.edgeGap : (barWindow.vertical ? barWindow.endGap : 0)
        anchors.leftMargin: bar.position === "left" ? barWindow.edgeGap : (barWindow.vertical ? 0 : barWindow.endGap)
        anchors.rightMargin: bar.position === "right" ? barWindow.edgeGap : (barWindow.vertical ? 0 : barWindow.endGap)
        tier: 0
        cornerRadius: barWindow.edgeGap > 0 ? Tokens.shape.full : 0

        M3BarPill {
            id: clockPill
            anchors.centerIn: parent
            barEdge: barWindow.bar.position
            crossSlack: Tokens.metrics.barPadding
            edgeReach: barWindow.edgeGap + Tokens.metrics.barPadding   // reaches the physical screen edge
            pillSize: barWindow.bar.thickness - 2 * Tokens.metrics.barPadding
            onClicked: ShellState.togglePopover("calendar", clockPill)
        }
    }
}
```

### 3.3 Popover Click-Catcher Mask (One-Click Pill-to-Pill Handoff)

Full-screen popover windows catch outside clicks for dismissal, but they MUST subtract **every bar on the screen**. Otherwise the first click on another widget only closes the current popover, and the user has to click a second time. With user-configured bars there can be several, on any edge, so the subtraction comes from `BarService.regions(screen)` (one rect per visible bar strip, edge reach included):

```qml
// At most 2 bars per edge (SC-01 §2.1) = 8 subtract slots; unused slots are zero-sized
readonly property var barRects: BarService.regions(popoverWindow.screen)

component BarHole: Region {                           // let clicks on any bar reach its widgets
    required property int slot
    readonly property rect r: popoverWindow.barRects[slot] ?? Qt.rect(0, 0, 0, 0)
    intersection: Intersection.Subtract
    x: r.x; y: r.y; width: r.width; height: r.height
}

mask: Region {
    width: popoverWindow.width
    height: popoverWindow.height
    BarHole { slot: 0 } BarHole { slot: 1 } BarHole { slot: 2 } BarHole { slot: 3 }
    BarHole { slot: 4 } BarHole { slot: 5 } BarHole { slot: 6 } BarHole { slot: 7 }
}
```

---

## 4. Multi-Monitor & Fractional Scaling Policy

1. **Per-Monitor Instantiation (`Variants` over `Quickshell.screens`)**:
   - `Wallpaper`, `M3ScreenCorners`, and `LockScreen` instantiate on **every connected `ShellScreen`** via `Variants { model: Quickshell.screens }`.
   - Bars instantiate per `(bar, screen)` pair from `BarService.instances`, honouring each bar's `screens` field (`"all"` or a list of output names). Hot-plugging a monitor creates its bars without a restart.
   - `SystemTray` items render in every `tray` widget instance (each with its own menus); users who want one tray place the widget on one bar only.
2. **Active Monitor Popover Routing**:
   - `AppCommandLauncher`, `OsdHud`, `PowerSessionMenu`, `PolkitDialog`, and `NotificationToasts` spawn on the **currently focused monitor** (resolved via `Hyprland.focusedMonitor` or pointer screen), ensuring the user never has to turn their head to another display to see an OSD or authentication prompt. Lane 2 popovers open on the screen of the widget that was clicked.
3. **Fractional HiDPI Crispness**:
   - Align all 1px borders (`border.width: 1`) with `antialiasing: true` and avoid half-pixel anchor offsets so borders remain razor-sharp at `1.25x`, `1.5x`, and `2.0x` Wayland fractional scale factors.
4. **Bar Insets (Shared Spatial Contract)**:
   - `BarService.insets(screen)` returns `{ top, right, bottom, left }`, the space covered by **every visible bar** on each edge, whether or not it reserves space (auto-hidden bars count only while revealed). Toasts, OSDs, desktop widgets, popovers, and the Overview layout offset from these insets instead of from fixed bar heights, so every surface stays clear of every bar configuration.
   - **No double counting**: A layer surface with `exclusiveZone: 0` is already moved by reserved bars' exclusive zones. Surfaces that offset by `BarService.insets` therefore set `exclusionMode: ExclusionMode.Ignore` (equivalent to `exclusiveZone: -1`) and do the whole offset themselves. That also keeps them clear of bars with `reserveSpace: false`, which the compositor does not account for.
