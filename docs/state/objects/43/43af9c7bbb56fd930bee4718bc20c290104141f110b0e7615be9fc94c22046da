# Shell Component 13 — Screenshot, Region Selector & Screen Recording HUD

> **Module**: `design-system/shell-components/13-screen-capture-and-recording.md`
> **Component ID**: `SC-13`
> **Primitives Used**: `M3Surface`, `M3SegmentedButton`, `M3IconButton`, `M3BarPill`, `M3FilterChip`

---

## 1. Purpose & Wayland Layer Config

The **Screen Capture & Recording Subsystem** (`Print` or `Super+Shift+S`) provides an integrated M3 Expressive overlay for capturing screenshots (`grim`) and high-framerate Wayland screen recordings (`wf-recorder` / `gpu-screen-recorder`) across three target modes (**Region**, **Window**, **Full Screen**), paired with a live **Recording Timer Pill** (the `recording` bar widget, `SC-02`) while recording is active.

| Property | Capture Overlay (`ScreenCaptureHud`) | Recording Pill (`recording` widget) |
|---|---|---|
| **`WlrLayershell.namespace`** | `"mat-capture"` | Embedded in every bar that hosts it (`"mat-bar-<id>"`); otherwise the `"mat-privacy-fallback"` pill (`SC-01` §2.1) |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` | `WlrLayer.Top` (fallback pill: `Overlay`) |
| **Anchors** | `top: true; bottom: true; left: true; right: true` | Wherever the user placed the widget |
| **`WlrLayershell.exclusiveZone`** | `-1` | Inherited from the host bar |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.Exclusive` | `WlrKeyboardFocus.None` |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Smart Window Snapping (`Window` Mode)** | Queries `Hyprland.toplevels` / `hyprctl clients -j` so hovering any tiled split automatically snaps the selection rectangle (`radius: 12px`) to that exact tile's geometry | Snaps selection rectangle to floating window bounds |
| **Keyboard Region Selection** | `1..9` selects window `1..9` on the current workspace; arrow keys nudge the region `1px` (`Shift`: `10px`); `Space` switches between `Screenshot` and `Record`; `Enter` captures immediately | Identical keyboard bindings in both modes, alongside pointer drag and click-to-select window |

---

## 3. Visual Anatomy & ASCII Layout

```text
   REGION SELECTION CANVAS + FLOATING BOTTOM CAPTURE BAR
╭───────────────────────────────────────────────────────────────────────────────────────────╮
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  Dimmed Scrim (45% alpha)
│  ░░░░░░░░░░░░░░┌─────────────────────────────────────────┐░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  Outside selection rect
│  ░░░░░░░░░░░░░░│                                         │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░░░░░░░░░░░░░░│       Clear Un-dimmed Capture Region    │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  2px primary border
│  ░░░░░░░░░░░░░░│                                         │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  + 8px corner handles
│  ░░░░░░░░░░░░░░└─────────────────────────────────────────┘░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░░░░░░░░░░░░░░  ╭───────────────────╮                    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ░░░░░░░░░░░░░░  │ 1280 × 720 px     │                    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │  Dimension Badge (tnum)
│  ░░░░░░░░░░░░░░  ╰───────────────────╯                    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│              ╭───────────────────────────────────────────────────────────────╮            │
│              │  ╭────────┬────────┬────────╮  ║  ╭─────╮╭─────╮  ║  ╭──────╮ │            │  Floating Capture Bar
│              │  │ 󰩭 Area │ 󰖯 Win  │ 󰍹 Full │  ║  │  󰄀  ││  󰕧  │  ║  │ 󰍬 󰕾  │ │            │  Height: 56px, Tier 0
│              │  ╰────────┴────────┴────────╯  ║  ╰─────╯╰─────╯  ║  ╰──────╯ │            │
│              ╰───────────────────────────────────────────────────────────────╯            │
╰───────────────────────────────────────────────────────────────────────────────────────────╯

   ACTIVE RECORDING PILL (`recording` bar widget, shown while wf-recorder is running)
   ╭─────────────────────────╮
   │  ●  02:14  •  󰓛 Stop    │  Background: errorContainer | Text: onErrorContainer (tnum)
   ╰─────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Border Token | Typography / Metric Token |
|---|---|---|---|
| **Outside Selection Mask** | `Tokens.color.scrim` @ `45%` alpha | Selection outline: `2px` `Tokens.color.primary` | Corner handles: `10px × 10px` `primary` circles |
| **Pixel Dimension Badge** | `Tokens.color.surfaceTier(0)` | `Tokens.color.onSurface` | `familyMono`, `12px`, **`tabularFeatures`** (`1280 × 720`) |
| **Floating Capture Toolbar** | `Tokens.color.surfaceTier(0)` | `1px` `Tokens.color.surfaceBorder(0)` | `height: 56px`, `radius: full`, `padding: 8px`, `bottomMargin: 32px` |
| **Capture / Record Trigger CTA** | Screenshot: `Tokens.color.primary`; Video: `Tokens.color.error` | `onPrimary` / `onError` | `40px × 40px`, `radius: full` (morphs to `12px` squircle on press) |
| **Active Recording Pill** (`recording` widget on any bar, or the fallback pill) | `Tokens.color.errorContainer` | `Tokens.color.onErrorContainer`; dot in `error` pulses (`2s` period) for the first `10s`, then holds steady (static from the start under Reduced Motion) | `height: 26px` (vertical bars: dot + stacked `mm`/`ss`), `labelMedium` (`tnum`), tooltip `"Recording — click to stop"` |

---

## 5. Interactive State Matrix

| State | Visual & Functional Behavior |
|---|---|
| **`SelectingRegion`** | Dragging pointer draws clear cutout rect inside `M3Scrim`; displays `x, y, width × height` pill (`tnum`) and a `4x` magnifier loupe at cursor for pixel-exact alignment. |
| **`Countdown` (`3s` / `10s`)** | Floating toolbar collapses into a centered `72px × 72px` circular countdown pill (`3..2..1` in `displaySmall` `tnum`). |
| **`RecordingActive`** | Capture overlay closes (`WlrKeyboardFocus.None`); every bar hosting the `recording` widget shows the pulsing `errorContainer` Recording Pill (`00:00`), or the fallback pill appears if none does. Clicking the pill stops `wf-recorder` and spawns a Notification Toast with video preview + `"Copy Path"` / `"Open Folder"`. |

---

## 6. Motion & Morph Choreography

1. **Window Snap Morph**: In `Window` capture mode, moving the cursor from one tiled window to another animates the selection cutout `x`, `y`, `width`, `height` smoothly between the two window geometries using `Tokens.motion.springFastSpatial` (`~200ms`).
2. **Shutter Flash**: Taking a screenshot flashes a full-screen `Tokens.color.onSurface` overlay from `opacity: 0.35 -> 0.0` over `180ms` (`springFastEffects`), then animates the captured frame shrinking toward the notification toast. Under Reduced Motion, the full-screen flash is replaced by a `2px` `Tokens.color.primary` border pulse around the captured region, which avoids a bright full-screen flash for photosensitive users.

---

## 7. Quickshell Service & IPC Bindings

- **Screenshot Pipeline (`Quickshell.Io.Process`)**:
  - `grim -g "<x>,<y> <w>x<h>" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png`
- **Screen Recording Pipeline (`Quickshell.Io.Process`)**:
  - `wf-recorder -g "<x>,<y> <w>x<h>" --audio -f ~/Videos/Recordings/$(date +%Y-%m-%d_%H-%M-%S).mp4`
  - Stopping sends `SIGINT` to the `wf-recorder` `Process`.

---

## 8. Canonical QML Reference Skeleton (`ScreenCaptureHud.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: captureWindow
    visible: ShellState.activeModal === "capture"
    WlrLayershell.namespace: "mat-capture"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property string targetMode: "region" // "region" | "window" | "screen"
    property bool isVideoMode: false
    property rect selectionRect: Qt.rect(320, 180, 640, 360)

    Keys.onEscapePressed: ShellState.closeActiveModal()

    // Selection Box Indicator
    Rectangle {
        x: captureWindow.selectionRect.x
        y: captureWindow.selectionRect.y
        width: captureWindow.selectionRect.width
        height: captureWindow.selectionRect.height
        color: "transparent"
        border.width: 2
        border.color: Tokens.color.primary
        radius: Tokens.shape.sm

        // Dimension Pill (tnum)
        M3Surface {
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 8
            implicitWidth: dimText.implicitWidth + 16
            implicitHeight: 26
            tier: 0
            cornerRadius: Tokens.shape.full

            Text {
                id: dimText
                anchors.centerIn: parent
                text: Math.round(captureWindow.selectionRect.width) + " × " + Math.round(captureWindow.selectionRect.height) + " px"
                font.family: Tokens.typography.familyMono
                font.pixelSize: 12
                font.features: Tokens.typography.tabularFeatures
                color: Tokens.color.onSurface
            }
        }
    }

    // Floating Bottom Capture Toolbar
    M3Surface {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 36
        implicitWidth: toolbarRow.implicitWidth + 20
        implicitHeight: 56
        tier: 0
        cornerRadius: Tokens.shape.full

        RowLayout {
            id: toolbarRow
            anchors.centerIn: parent
            spacing: Tokens.metrics.spaceSm

            Repeater {
                model: ListModel {
                    ListElement { modeId: "region"; label: "Region"; icon: "crop" }
                    ListElement { modeId: "window"; label: "Window"; icon: "web_asset" }
                    ListElement { modeId: "screen"; label: "Screen"; icon: "desktop_windows" }
                }
                delegate: M3Surface {
                    required property string modeId
                    required property string label
                    required property string icon
                    readonly property bool selected: captureWindow.targetMode === modeId

                    implicitWidth: 96; implicitHeight: 40
                    tier: selected ? 4 : 2
                    interactive: true
                    active: selected
                    cornerRadius: Tokens.shape.full
                    onClicked: captureWindow.targetMode = modeId

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: icon
                            font.family: Tokens.typography.familyIcons
                            font.pixelSize: 18
                            color: selected ? Tokens.color.onPrimary : Tokens.color.onSurface
                        }
                        Text {
                            text: label
                            font.family: Tokens.typography.labelLarge.family
                            font.pixelSize: Tokens.typography.labelLarge.pixelSize
                            color: selected ? Tokens.color.onPrimary : Tokens.color.onSurface
                        }
                    }
                }
            }
        }
    }
}
```
