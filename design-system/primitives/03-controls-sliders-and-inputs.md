# Primitives 03 — Controls, M3 Expressive Sliders, Switches, Text Fields & Progress

> **Module**: `design-system/primitives/03-controls-sliders-and-inputs.md`
> **Dependencies**: `Tokens.color`, `Tokens.shape`, `Tokens.motion`, `Tokens.typography`, `Tokens.metrics`

---

## 1. `M3Switch` — Expressive Toggle Switch with Thumb Morph

Follows the official Material 3 switch specification with elastic thumb stretching on press/drag.

### 1.1 Dimensions & Token Table

| Element | Off (`checked === false`) | On (`checked === true`) | Pressed / Dragging Modifier |
|---|---|---|---|
| **Track Dimensions** | `52px × 32px`, `radius: 16px` | `52px × 32px`, `radius: 16px` | Unchanged |
| **Track Background** | `Tokens.color.surfaceTier(3)` (`surfaceContainerLow`) | `Tokens.color.primary` | +`12%` state layer |
| **Track Border** | `2px` `Tokens.color.outline` | `0px` | Unchanged |
| **Thumb Size** | `16px × 16px` (`24px × 24px` if `uncheckedIcon` set) | `24px × 24px` | Stretches to **`28px × 28px`** (`width: 32px` while mid-travel) |
| **Thumb Color** | `Tokens.color.outline` | `Tokens.color.onPrimary` | `primaryContainer` (Off) / `primaryFixed` (On) |
| **Thumb Icon (`16px`)** | Optional `"close"` (`surfaceContainerHighest`) | `"check"` (`onPrimaryContainer`) | Rotates `-15deg -> 0deg` via `springFastSpatial` |

---

## 2. `M3Slider` — Material 3 Expressive Split-Track Slider

Used for **Audio Volume**, **Display Brightness**, and **OSD HUDs**. Unlike legacy thin line sliders, the M3 Expressive slider uses a **thick split track (`20px`–`28px` height)** separated by a **`4px` transparent gap** around a vertical pill handle (`thumb`).

### 2.1 Visual Anatomy

```text
╭─────────────────────────╮   ╭───────────────────────╮
│  󰕾   Active Track       │ ┃ │   Inactive Track    • │  Height: 24px (compact) / 28px (comfortable)
╰─────────────────────────╯   ╰───────────────────────╯
  ▲                        ▲ ▲ ▲                     ▲
  outerRadius: 14px        │ │ │                     stopIndicator: 4px dot (outline)
                  innerGap: 4px (Thumb: 4px × 32px vertical bar in primary)
```

### 2.2 Token & State Specification

| Element | Resting State | Hovered State | Dragging / Pressed State | Muted / Disabled State |
|---|---|---|---|---|
| **Active Left Track** | `Tokens.color.primary` | `Tokens.color.primary` (+`8%` `onPrimary`) | `Tokens.color.primary` | `Tokens.color.onSurface` @ `38%` |
| **Active Track Corners** | Left: `height/2` (`14px`); Right (facing thumb): `4px` (`xs`) | Right corner: `4px` | Right corner: `2px` (`xxs`) | Left: `14px`, Right: `4px` |
| **Thumb Handle** | `4px × 32px` (`radius: 2px`), `Tokens.color.primary` | `6px × 34px` (`radius: 3px`) | **`2px × 36px`** (narrows on press per M3 spec) + value tooltip | `onSurface` @ `38%` |
| **Thumb Gap** | `6px` clear space left & right of thumb | `6px` | Compresses to `4px` via `springFastSpatial` | `6px` |
| **Inactive Right Track** | `Tokens.color.secondaryContainer` | `secondaryContainer` | `secondaryContainer` | `onSurface` @ `12%` |
| **Inactive Track Corners** | Left (facing thumb): `4px`; Right: `height/2` (`14px`) | Unchanged | Left: `2px` | Left: `4px`, Right: `14px` |
| **Leading Icon (`20px`)** | `Tokens.color.onPrimary` (or `onSecondaryContainer` when `< 18%`) | Morphs glyph (`volume_down` / `volume_up`) | Scales `1.08x` | `"volume_off"` (`onSurfaceVariant`) |

### 2.3 Canonical QML Implementation (`M3Slider.qml`)

```qml
import QtQuick
import MatShell.Tokens

Item {
    id: slider
    property real value: 0.65          // Normalized 0.0 .. 1.0 (or up to 1.5 for overamplification)
    property real maxValue: 1.0
    property string icon: "volume_up"
    property bool muted: false
    property string accessibleName: "Volume"
    property real wheelAccumulator: 0
    readonly property bool dragging: dragArea.pressed
    readonly property real keyStep: maxValue * 0.05

    signal moved(real newValue)

    function nudge(delta: real): void {
        const next = Math.max(0.0, Math.min(maxValue, value + delta))
        value = next
        moved(next)
    }

    implicitWidth: 280
    implicitHeight: 36

    // Keyboard, wheel & screen reader parity with pointer dragging
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: accessibleName
    Accessible.description: muted ? "Muted" : Math.round(value * 100) + " percent"
    Accessible.onIncreaseAction: nudge(keyStep)
    Accessible.onDecreaseAction: nudge(-keyStep)

    Keys.onPressed: (event) => {
        const fine = (event.modifiers & Qt.ShiftModifier) ? 0.2 : 1.0
        switch (event.key) {
        case Qt.Key_Right: case Qt.Key_Up: nudge(keyStep * fine); break
        case Qt.Key_Left: case Qt.Key_Down: nudge(-keyStep * fine); break
        case Qt.Key_PageUp: nudge(maxValue * 0.1); break
        case Qt.Key_PageDown: nudge(-maxValue * 0.1); break
        case Qt.Key_Home: nudge(-value); break
        case Qt.Key_End: nudge(maxValue - value); break
        default: return
        }
        Tokens.keyboardModality = true
        event.accepted = true
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            const usePixels = event.pixelDelta.y !== 0
            const raw = (usePixels ? event.pixelDelta.y : event.angleDelta.y) * (event.inverted ? -1 : 1)
            const threshold = usePixels ? Tokens.metrics.touchpadStepPixels : Tokens.metrics.wheelStepAngle
            slider.wheelAccumulator += raw
            while (Math.abs(slider.wheelAccumulator) >= threshold) {
                const step = slider.wheelAccumulator > 0 ? 1 : -1
                slider.wheelAccumulator -= step * threshold
                slider.nudge(step * slider.keyStep)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Tokens.metrics.focusRingOffset
        radius: height / 2
        color: "transparent"
        border.width: Tokens.metrics.focusRingWidth
        border.color: Tokens.color.primary
        visible: slider.activeFocus && Tokens.keyboardModality
        Accessible.ignored: true
    }

    readonly property real trackHeight: 28
    readonly property real thumbGap: dragging ? 4 : 6
    readonly property real thumbWidth: dragging ? 2 : (dragArea.containsMouse ? 6 : 4)
    readonly property real normalizedRatio: Math.max(0.0, Math.min(1.0, value / maxValue))
    readonly property real splitX: Math.max(thumbGap, Math.min(width - thumbGap, normalizedRatio * width))

    // Left Active Track
    Rectangle {
        id: activeTrack
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, slider.splitX - slider.thumbGap)
        height: slider.trackHeight
        radius: height / 2
        color: slider.muted ? Tokens.color.surfaceVariant : Tokens.color.primary
        topRightRadius: Tokens.shape.xs
        bottomRightRadius: Tokens.shape.xs

        Behavior on width {
            enabled: !slider.dragging
            SpringAnimation {
                spring: Tokens.motion.springFastSpatial.spring
                damping: Tokens.motion.springFastSpatial.damping
            }
        }
    }

    // Center Vertical Pill Thumb
    Rectangle {
        id: thumb
        x: slider.splitX - (width / 2)
        anchors.verticalCenter: parent.verticalCenter
        width: slider.thumbWidth
        height: slider.dragging ? 36 : 32
        radius: width / 2
        color: slider.muted ? Tokens.color.outline : Tokens.color.primary

        Behavior on width {
            SpringAnimation {
                spring: Tokens.motion.springFastSpatial.spring
                damping: Tokens.motion.springFastSpatial.damping
            }
        }
    }

    // Right Inactive Track
    Rectangle {
        id: inactiveTrack
        anchors.left: thumb.right
        anchors.leftMargin: slider.thumbGap - (slider.thumbWidth / 2)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: slider.trackHeight
        radius: height / 2
        topLeftRadius: Tokens.shape.xs
        bottomLeftRadius: Tokens.shape.xs
        color: Tokens.color.secondaryContainer
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: (mouse) => {
            if (pressed) {
                const nextVal = Math.max(0.0, Math.min(slider.maxValue, (mouse.x / width) * slider.maxValue))
                slider.value = nextVal
                slider.moved(nextVal)
            }
        }
        onPressed: (mouse) => {
            Tokens.keyboardModality = false
            const nextVal = Math.max(0.0, Math.min(slider.maxValue, (mouse.x / width) * slider.maxValue))
            slider.value = nextVal
            slider.moved(nextVal)
        }
    }
}
```

---

## 3. `M3SearchField` & `M3TextField`

- **`M3SearchField`**: Pill-shaped input container (`height: 48px` in Launcher, `36px` in sub-sheets; `radius: height / 2`, background `Tokens.color.surfaceTier(2)`). Includes leading `"search"` icon (`20px`, `onSurfaceVariant`), placeholder (`onSurfaceVariant` @ `70%`), active mode badge chip (e.g., `Calculator` when input starts with `=`), and trailing `"close"` clear button when `text.length > 0`.
- **`M3TextField` (Password / Polkit / Wi-Fi Passphrase)**: Rounded container (`height: 44px`, `radius: Tokens.shape.md = 12px`, background `Tokens.color.surfaceTier(3)`) with a visible label above the field (never placeholder-only). Focused state renders a `2px` `Tokens.color.primary` border.
  - **Error state**: `2px` `Tokens.color.error` border **plus** a supporting-text line below the field (`bodySmall`, `Tokens.color.error`, e.g., `"Incorrect password — 2 attempts left"`). The horizontal shake (`±8px`) is an extra cue that runs only when `Tokens.motion.decorativeMotionEnabled`.
  - **Caps Lock warning**: While focused with `echoMode: TextInput.Password` and `KeyboardService.capsLock === true`, the supporting line shows `keyboard_capslock` + `"Caps Lock is on"` in `Tokens.color.tertiary`, together with the active layout code (`EN`). The Caps Lock line takes priority over idle helper text but never hides an error.
  - **Reveal toggle**: Polkit and Wi-Fi passphrase fields include a trailing `visibility` / `visibility_off` `M3IconButton` (`36px` target, `accessibleName: "Show password"`). The Lock Screen omits it because the screen may be visible to others.
  - **Accessibility**: `Accessible.role: Accessible.EditableText`, `Accessible.passwordEdit: true` for password fields, and `Accessible.description` mirrors the supporting text so errors are announced.
