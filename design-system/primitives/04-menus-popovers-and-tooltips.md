# Primitives 04 — Popovers, Context Menus, Tooltips & Scrollbars

> **Module**: `design-system/primitives/04-menus-popovers-and-tooltips.md`
> **Dependencies**: `Tokens.color`, `Tokens.shape`, `Tokens.motion`, `Tokens.typography`, `Tokens.metrics`

---

## 1. `M3Popover` — Layer-Shell Anchored Morphing Container

`M3Popover` is the shared wrapper for **Control Center (`03`)**, **Calendar & Weather (`05`)**, **Media Popover (`06`)**, and **System Tray Overflow**.

### 1.1 Spatial & Choreographic Contract
- **Surface Tier**: Tier 0 (`Tokens.color.surfaceTier(0)` + `1px` `Tokens.color.surfaceBorder(0)`).
- **Corner Radius**: `Tokens.shape.xl` (`24px`).
- **Outer Screen Margin**: `Tokens.metrics.screenMargin` (`8px` comfortable) from the trigger's bar and from the screen edges.
- **Origin-Edge Placement (any bar, any edge)**: Bars are user-configured (`01-bar-system.md`), so popovers never assume a top bar. `ShellState.togglePopover(name, trigger)` records `popoverOriginEdge` (the trigger's bar position: `top|right|bottom|left`, or `"none"` for keyboard/IPC with no hosting bar) and `popoverOriginRect` (trigger rect in screen coordinates). `M3Popover` then:
  1. **Docks against the bar**: the card's edge facing the bar sits at `BarService.innerEdge(barId, screen) + screenMargin` from that screen edge.
  2. **Aligns along the bar**: centred on the trigger along the bar axis, clamped inside `BarService.insets(screen)` + `screenMargin` so it never runs off-screen or under another bar.
  3. **Grows toward the screen centre**: `transformOrigin` is the card point nearest the trigger (e.g. `Item.Top` under a top-bar pill, `Item.Left` beside a left-rail pill, `Item.BottomRight` above an end-section pill on a bottom bar).
  4. **Falls back** with `popoverOriginEdge === "none"` to the top-end corner inside the insets.
  Every Lane 2 popover inherits this, so no surface hardcodes an anchor edge.
- **Entrance / Exit Animation**:
  - `scale`: animates `0.92 -> 1.0` from the trigger pill's origin using `Tokens.motion.springDefaultSpatial` (`enabled: Tokens.motion.spatialMotionEnabled`).
  - `opacity`: animates `0.0 -> 1.0` over `Tokens.motion.springFastEffects.durationMs`; exit runs faster than entry (`curveEmphasizedAccelerate`, `160ms`).
- **Click-Outside Dismissal (One-Click Handoff)**: The `PanelWindow` covers the screen with a transparent `MouseArea` behind the card; clicking outside calls `ShellState.closeActivePopover()`. The window `mask` subtracts every bar on the screen (`BarService.regions(screen)`, `05-wayland-layershell-spatial.md` §3.3), so clicking a different bar pill opens its popover in a single click.
- **Focus Management**: When opened from the keyboard or IPC, focus moves to the first control in the card and `Tokens.keyboardModality` is set to `true`. When opened by pointer, nothing is pre-focused. On close, `WlrKeyboardFocus` returns to `None`, so the compositor hands focus back to the previously focused client.

### 1.2 Canonical QML Implementation (`M3Popover.qml`)

Surfaces declare only their name, width, namespace, and content. Placement, the bar-aware click-catcher, and the grow-from-trigger transform live here:

```qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: popover
    required property string name                 // ShellState lane-2 key, e.g. "control_center"
    property alias cardWidth: card.width
    property alias cardHeight: card.height                // bind to the content's implicit height
    property alias namespace: popover.WlrLayershell.namespace
    property var keyboardFocusMode: WlrKeyboardFocus.OnDemand
    default property alias content: card.data

    readonly property bool open: ShellState.activePopover === name
    readonly property string edge: ShellState.popoverOriginEdge  // top | right | bottom | left | none
    readonly property var insets: BarService.insets(screen)       // visible bars only
    readonly property int gap: Tokens.metrics.screenMargin
    readonly property point origin: mapFromGlobal(ShellState.popoverOriginRect.x, ShellState.popoverOriginRect.y)
    readonly property real originCx: origin.x + ShellState.popoverOriginRect.width / 2
    readonly property real originCy: origin.y + ShellState.popoverOriginRect.height / 2
    readonly property var barRects: BarService.regions(screen)

    function clamp(v, lo, hi) { return Math.max(lo, Math.min(v, hi)) }

    screen: ShellState.popoverTrigger?.QsWindow.window?.screen ?? CompositorService.focusedScreen
    visible: open || card.opacity > 0
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore   // cover the whole output (bars included); placement uses BarService.insets
    WlrLayershell.keyboardFocus: open ? keyboardFocusMode : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    // Click-catcher minus every bar (05-wayland-layershell-spatial.md §3.3): one-click handoff between widgets
    component BarHole: Region {
        required property int slot
        readonly property rect r: popover.barRects[slot] ?? Qt.rect(0, 0, 0, 0)
        intersection: Intersection.Subtract
        x: r.x; y: r.y; width: r.width; height: r.height
    }
    mask: Region {
        width: popover.open ? popover.width : 0
        height: popover.open ? popover.height : 0
        BarHole { slot: 0 } BarHole { slot: 1 } BarHole { slot: 2 } BarHole { slot: 3 }
        BarHole { slot: 4 } BarHole { slot: 5 } BarHole { slot: 6 } BarHole { slot: 7 }
    }
    MouseArea { anchors.fill: parent; onClicked: ShellState.closeActivePopover() }

    M3Surface {
        id: card
        tier: 0
        cornerRadius: Tokens.shape.xl
        // Dock against the trigger's bar; align on the trigger along the bar axis; stay inside all insets
        x: popover.edge === "left" ? popover.insets.left + popover.gap
         : popover.edge === "right" || popover.edge === "none" ? popover.width - popover.insets.right - popover.gap - width
         : popover.clamp(popover.originCx - width / 2, popover.insets.left + popover.gap, popover.width - popover.insets.right - popover.gap - width)
        y: popover.edge === "top" || popover.edge === "none" ? popover.insets.top + popover.gap
         : popover.edge === "bottom" ? popover.height - popover.insets.bottom - popover.gap - height
         : popover.clamp(popover.originCy - height / 2, popover.insets.top + popover.gap, popover.height - popover.insets.bottom - popover.gap - height)

        opacity: popover.open ? 1 : 0
        transform: Scale {
            // Grows out of the trigger: the scale origin is the card point nearest the trigger's centre
            origin.x: popover.clamp(popover.originCx - card.x, 0, card.width)
            origin.y: popover.clamp(popover.originCy - card.y, 0, card.height)
            xScale: popover.open ? 1 : 0.92
            yScale: xScale
            Behavior on xScale { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springDefaultSpatial.spring; damping: Tokens.motion.springDefaultSpatial.damping; epsilon: Tokens.motion.springDefaultSpatial.epsilon } }
        }
        Behavior on opacity { NumberAnimation { duration: popover.open ? Tokens.motion.springFastEffects.durationMs : 160; easing.type: popover.open ? Easing.OutCubic : Easing.InCubic } }
        MouseArea { anchors.fill: parent }       // clicks inside the card never reach the click-catcher
    }
}
```

---

## 2. `M3ContextMenu` — Desktop Right-Click & System Tray Menu

Used for `SystemTrayItem.menu` (`QsMenuOpener`), `apps` widget context menus, bar and widget right-click menus (`Configure bar…`), and Workspace right-click actions. Menus open from the clicked point toward the screen centre and flip at screen and bar insets.

### 2.1 Anatomy & Metrics
```text
╭──────────────────────────────────────────╮
│  󰐊  Launch New Window         Ctrl+Shift+N│  Row height: 34px, radius: 8px (sm)
│  󰐃  Pin to Bar                           │
│ ──────────────────────────────────────── │  M3Divider (margin: 4px vertical)
│  󰖯  Move to Workspace                  󰅂 │  Submenu chevron -> spawns child menu
│  󰅖  Close All Windows               Alt+F4│  Destructive item (Tokens.color.error)
╰──────────────────────────────────────────╯
  Width: min 200px, max 320px | Padding: 6px | Outer Radius: 16px (lg)
```

| Property | Token / Value |
|---|---|
| **Menu Container** | `M3Surface` Tier 1 (`surfaceContainerHigh`), `radius: Tokens.shape.lg` (`16px`), `padding: 6px` |
| **Menu Item Row** | `height: 34px`, `radius: Tokens.shape.sm` (`8px`), horizontal padding `10px` |
| **Hovered / Focused Item** | Background: `Tokens.color.secondaryContainer`; Text/Icon: `Tokens.color.onSecondaryContainer` |
| **Destructive Item** | Text/Icon: `Tokens.color.error`; Hovered background: `Tokens.color.errorContainer` |
| **Accelerator Label** | `Tokens.typography.labelSmall` (`11px`), `Tokens.color.onSurfaceVariant`, right-aligned |
| **Destructive Separation** | Destructive items sit in their own group below an `M3Divider`, never adjacent to the default action |

### 2.2 Keyboard Contract
- Opens at the pointer (right-click) or anchored to the focused element (`Menu` key / `Shift+F10`), with the first enabled row focused.
- `Up` / `Down` move between enabled rows (wrapping); `Home` / `End` jump; typing a letter jumps to the next row starting with it.
- `Right` opens a submenu, `Left` closes it; `Enter` / `Space` activate; `Escape` closes one menu level.
- `Accessible.role: Accessible.PopupMenu` on the container and `Accessible.MenuItem` on rows.

---

## 3. `M3Tooltip` — Plain & Rich Desktop Tooltips

- **API**: `M3Tooltip { target: <Item>; text: <string>; shown: <bool> }`. `M3Surface` instantiates one automatically from `tooltipText`, showing it on hover **or** keyboard focus.
- **Plain Tooltip**: Single-line capsule (`height: 28px`, `radius: Tokens.shape.sm = 8px`, padding `10px` horizontal) using `Tokens.color.inverseSurface` background and `Tokens.color.inverseOnSurface` text (`labelMedium`, `12px`). Appears after `450ms` hover or focus delay (`100ms` when scrubbing adjacent bar widgets). Positioned on the side away from the nearest screen edge: for bar widgets, the side facing the screen centre (below top-bar pills, above bottom-bar items, beside left/right rail items).
- **Rich Tooltip**: Multi-line card (`maxWidth: 280px`, `radius: Tokens.shape.md = 12px`, padding `12px`) using `M3Surface` Tier 2 (`surfaceContainerHighest`), used for `apps` widget window previews, media artist/album detail, Battery time-to-empty breakdown, and Hardware Telemetry graphs.
- **Required Coverage**: Every icon-only control in bars (bar or island mode) and popover headers has a tooltip. Tooltips never contain interactive content and close on `Escape`, pointer exit, or focus loss.

---

## 4. `M3ScrollBar` — Minimal Auto-Expanding Scroll Indicator

- **Idle Width**: `4px`, `radius: 2px`, `Tokens.color.withAlpha(Tokens.color.onSurfaceVariant, 0.28)`.
- **Hovered / Dragging Width**: Expands to `8px` (`radius: 4px`, `Tokens.color.primary`) via `Tokens.motion.springFastSpatial`.
- **Auto-Hide**: Fades to `opacity: 0.0` after `1200ms` of scroll inactivity.
- **Overflow Cue**: While content overflows, a `16px` gradient fade mask (`surface` → transparent) marks the scrollable edge, so users can tell a list scrolls even when the scrollbar is hidden. The scrollbar reappears on hover anywhere over the list.
