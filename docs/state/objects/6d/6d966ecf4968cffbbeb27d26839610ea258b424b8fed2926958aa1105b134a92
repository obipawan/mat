# Shell Component 09 — Workspace & Window Overview (Expose)

> **Module**: `design-system/shell-components/09-workspace-and-window-overview.md`
> **Component ID**: `SC-09`
> **Primitives Used**: `M3Scrim`, `M3Surface`, `M3SearchField`, `M3Card`, `M3IconButton`

---

## 1. Purpose & Wayland Layer Config

The **Workspace & Window Overview** (`Super+Tab` or 3-finger touchpad swipe up) provides a bird's-eye spatial view of all workspaces and open client windows, enabling rapid drag-and-drop window migration across workspaces, live window filtering, and keyboard-driven window selection.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-overview"` |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **`WlrLayershell.exclusiveZone`** | `-1` (covers entire screen including every bar) |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.Exclusive`** |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` (Hyprland / Niri) | `Tokens.desktopMode === "floating"` (Spatial Desktop) |
|---|---|---|
| **Primary Layout Geometry** | **2×5 Proportional Tiling Workspace Matrix** (or Niri horizontal scrolling strip): Each workspace cell (`280px × 158px`, `16:9` aspect) renders its exact tiled split tree (`x`, `y`, `width`, `height` scaled by `0.15x`) | **GNOME/macOS Spatial Window Expose**: Top strip displays workspace mini-thumbnails (`160px × 90px`), while the main stage spreads active workspace windows into a non-overlapping expose grid |
| **Keyboard Navigation** | `1..9`/`0` jumps directly to a workspace; arrow keys (or `h/j/k/l`) move window focus; `Shift+Arrow` moves the selected window to the adjacent workspace; typing filters windows; `Enter` activates | Identical bindings in both modes; only the layout geometry differs (matrix vs. expose grid) |

---

## 3. Visual Anatomy & ASCII Layout

```text
   TILING MODE: 2×5 PROPORTIONAL WORKSPACE MATRIX ("tiling")
╭───────────────────────────────────────────────────────────────────────────────────────────╮
│                         ╭─────────────────────────────────────────╮                       │
│                         │  󰍉  Filter open windows or workspaces…  │                       │  Top Search Pill
│                         ╰─────────────────────────────────────────╯                       │
│   ╭───────────────────────────╮   ╭═══════════════════════════╮   ╭───────────────────────────╮ │
│   │ WS 1 • Web                │   ║ WS 2 • Dev (Focused)      ║   │ WS 3 • Comms              │ │
│   │ ┌───────────────────────┐ │   ║ ┌───────────┬───────────┐ ║   │ ┌───────────┬───────────┐ │ │
│   │ │ 󰈹 Firefox             │ │   ║ │ 󰆍 WezTerm │ 󰨞 Neovim  │ ║   │ │ 󰒱 Slack   │ 󰙯 Discord │ │ │
│   │ │                       │ │   ║ │           ├───────────┤ ║   │ │           │           │ │ │
│   │ │                       │ │   ║ │           │ 󰆍 Cargo   │ ║   │ │           │           │ │ │
│   │ └───────────────────────┘ │   ║ └───────────┴───────────┘ ║   │ └───────────┴───────────┘ │ │
│   ╰───────────────────────────╯   ╰═══════════════════════════╯   ╰───────────────────────────╯ │
╰───────────────────────────────────────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Border / Foreground Token | Typography / Metric Token |
|---|---|---|---|
| **Overview Backdrop** | `Tokens.color.scrim` @ `55%` alpha + `32px` wallpaper blur | — | Fade duration `250ms` |
| **Workspace Card (Unfocused)** | `Tokens.color.surfaceTier(0)` | `1px` `Tokens.color.surfaceBorder(0)` | `16:9` ratio, `radius: xl (24px)`, `padding: 8px` |
| **Workspace Card (Focused)** | `Tokens.color.surfaceTier(1)` | **`2px` `Tokens.color.primary`** | `radius: xl (24px)`, `scale: 1.03` |
| **Window Tile Card** | `Tokens.color.surfaceTier(2)` (+ live `ScreencopyView` texture) | `1px` `outlineVariant` (Hover: `2px` `primary`) | `radius: md (12px)` |
| **Window App Title Badge** | `Tokens.color.surfaceTier(0)` @ `88%` pill at bottom of window | `Tokens.color.onSurface` | `labelMedium` (`12px`), `height: 26px`, `radius: full` |
| **Window Close Button (`󰅖`)** | `Tokens.color.errorContainer` (appears on window hover) | `Tokens.color.onErrorContainer` | `28px × 28px`, top-right of window card |

---

## 5. Interactive State Matrix

| Action | Response |
|---|---|
| **Left Click Window Card** | Focuses window (`Hyprland.dispatch("focuswindow address:...")`), zooms overview back into the selected workspace via `springSlowSpatial`, and closes Overview. |
| **Middle Click Window Card** | Closes that client window (`Toplevel.close()`) and reflows remaining windows immediately. |
| **Drag Window Card (`DragHandler`)** | Lifts window (`scale: 1.06`, `z: 50`, state layer `16%`); dropping onto another workspace cell dispatches `movetoworkspacesilent <targetWs>,address:<addr>`. |

---

## 6. Motion & Morph Choreography

1. **Desktop Zoom-Out Entrance**: Entering Overview scales the workspace grid from `1.25 -> 1.0` with `opacity: 0 -> 1` using `Tokens.motion.springSlowSpatial` (`damping: 0.78`, `spring: 2.6`).
2. **Drag-and-Drop Slot Reflow**: Dropping a window into a tiled workspace cell animates the target cell's proportional window rectangles to their new Hyprland geometries using `Tokens.motion.springDefaultSpatial`.

---

## 7. Quickshell Service & IPC Bindings

- **Hyprland / Compositor Geometry (`Quickshell.Hyprland`)**: Queries `hyprctl clients -j` via `Quickshell.Io.Process` (or `Hyprland.toplevels`) for exact `at: [x, y]`, `size: [w, h]`, `workspace.id`, `class`, and `title`.
- **Live Window Texture (`Quickshell.Wayland.ScreencopyView`)**: Binds `captureSource: toplevel` so each miniature window card shows live video/terminal output.

---

## 8. Canonical QML Reference Skeleton (`WorkspaceOverview.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import MatShell.Tokens

PanelWindow {
    id: overviewWindow
    visible: ShellState.activeModal === "overview"
    WlrLayershell.namespace: "mat-overview"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Tokens.color.withAlpha(Tokens.color.scrim, 0.55)
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.closeActiveModal()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Tokens.metrics.spaceXl
        Keys.onEscapePressed: ShellState.closeActiveModal()

        // Workspace Matrix (2 rows × 3 columns)
        GridLayout {
            columns: 3
            rowSpacing: Tokens.metrics.spaceLg
            columnSpacing: Tokens.metrics.spaceLg

            Repeater {
                model: 6
                delegate: M3Surface {
                    required property int index
                    readonly property int wsId: index + 1
                    readonly property bool isCurrent: (Hyprland.focusedWorkspace?.id ?? 1) === wsId

                    width: 320
                    height: 180
                    tier: isCurrent ? 1 : 0
                    interactive: true
                    active: isCurrent
                    cornerRadius: Tokens.shape.xl
                    border.width: isCurrent ? 2 : 1
                    border.color: isCurrent ? Tokens.color.primary : Tokens.color.surfaceBorder(0)

                    onClicked: {
                        Hyprland.dispatch("workspace " + wsId)
                        ShellState.closeActiveModal()
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 12
                        text: "Workspace " + parent.wsId
                        font.family: Tokens.typography.labelLarge.family
                        font.pixelSize: Tokens.typography.labelLarge.pixelSize
                        font.features: Tokens.typography.tabularFeatures
                        color: parent.isCurrent ? Tokens.color.primary : Tokens.color.onSurfaceVariant
                    }
                }
            }
        }
    }
}
```
