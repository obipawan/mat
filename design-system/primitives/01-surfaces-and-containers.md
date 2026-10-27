# Primitives 01 — Surfaces, Containers, Cards, Dividers, Scrims & Screen Corners

> **Module**: `design-system/primitives/01-surfaces-and-containers.md`
> **Dependencies**: `Tokens.color`, `Tokens.shape`, `Tokens.motion`, `Tokens.metrics`

---

## 1. `M3Surface` — Base Tonal & Glass Container

`M3Surface` is the foundational container primitive used by every panel, card, and bar in the desktop environment. It automatically adapts to `Tokens.surfaceMode` (`"frosted_tonal_glass"` vs. `"opaque_tonal"`), renders the 1px structural outline, and provides optional interactive state-layer and focus-ring overlays.

### 1.1 Property API Contract

| Property | Type | Default | Description |
|---|---|---|---|
| `tier` | `int` (`0..4`) | `1` | Surface hierarchy tier (`0=ShellRoot`, `1=ElevatedGroup`, `2=InteractiveControl`, `3=InsetWell`, `4=AccentActive`) |
| `customColor` | `color` | `"transparent"` | Optional explicit color override (e.g., `Tokens.color.errorContainer`); when `"transparent"`, resolves `Tokens.color.surfaceTier(tier)` |
| `contentColor` | `color` | `Tokens.color.onSurface` | Foreground content color used for child text/icons and state layer tint |
| `cornerRadius` | `real` | `Tokens.shape.lg` (`16px`) | Base corner radius (`0..9999`) |
| `interactive` | `bool` | `false` | Enables `HoverHandler`, `TapHandler`, keyboard activation, state layer overlay, and corner radius morphing |
| `active` | `bool` | `false` | Marks the surface as selected/toggled |
| `accessibleName` | `string` | `""` | Screen-reader name (falls back to `tooltipText`). **Required** for icon-only interactive surfaces |
| `accessibleDescription` | `string` | `""` | Live value for assistive tech (e.g., `"Volume 72 percent"`) |
| `tooltipText` | `string` | `""` | Shows an `M3Tooltip` after `450ms` of hover or keyboard focus |
| `hitTopExtension` / `hitBottomExtension` / `hitSideExtension` | `real` | `0` | Extends the pointer hit area beyond the visual bounds (edge hit extension, minimum target size) |

### 1.2 Canonical QML Implementation (`M3Surface.qml`)

```qml
import QtQuick
import MatShell.Tokens

Rectangle {
    id: root

    property int tier: 1
    property color customColor: "transparent"
    property color contentColor: tier === 4 ? Tokens.color.onPrimary : Tokens.color.onSurface
    property real cornerRadius: Tokens.shape.lg
    property bool interactive: false
    property bool active: false
    property string accessibleName: ""
    property string accessibleDescription: ""
    property string tooltipText: ""
    property real hitTopExtension: 0
    property real hitBottomExtension: 0
    property real hitSideExtension: 0

    property bool keyPressed: false
    readonly property bool hovered: hoverHandler.hovered
    readonly property bool pressed: tapHandler.pressed || keyPressed
    readonly property bool focusVisible: activeFocus && Tokens.keyboardModality

    signal clicked()
    signal rightClicked()
    signal middleClicked()

    activeFocusOnTab: interactive
    color: customColor.a > 0 ? customColor : Tokens.color.surfaceTier(active ? 4 : tier)
    radius: interactive
        ? (pressed ? Tokens.shape.md : (hovered ? Math.min(height / 2, cornerRadius + 4) : cornerRadius))
        : cornerRadius
    border.width: tier === 4 ? 0 : 1
    border.color: active ? Tokens.color.primary : Tokens.color.surfaceBorder(tier)
    scale: (interactive && pressed) ? 0.97 : 1.0

    Accessible.role: interactive ? Accessible.Button : Accessible.Pane
    Accessible.name: accessibleName !== "" ? accessibleName : tooltipText
    Accessible.description: accessibleDescription
    Accessible.onPressAction: if (interactive) root.clicked()

    Behavior on color {
        ColorAnimation { duration: Tokens.motion.springDefaultEffects.durationMs }
    }
    Behavior on radius {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
        }
    }
    Behavior on scale {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
        }
    }

    // Keyboard activation: Enter/Space click, Menu or Shift+F10 opens the context menu
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab
                || (event.key >= Qt.Key_Left && event.key <= Qt.Key_Down)) {
            Tokens.keyboardModality = true
        }
        if (!root.interactive) return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.keyPressed = true
            event.accepted = true
        } else if (event.key === Qt.Key_Menu || (event.key === Qt.Key_F10 && (event.modifiers & Qt.ShiftModifier))) {
            root.rightClicked()
            event.accepted = true
        }
    }
    Keys.onReleased: (event) => {
        if (root.keyPressed && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
            root.keyPressed = false
            root.clicked()
            event.accepted = true
        }
    }

    // M3 State Layer Overlay
    Rectangle {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        visible: root.interactive
        color: Tokens.color.stateLayer(root.contentColor, root.hovered, root.pressed, root.focusVisible, false)
        Accessible.ignored: true

        Behavior on color {
            ColorAnimation { duration: Tokens.motion.springFastEffects.durationMs }
        }
    }

    // Keyboard Focus Ring (2px — 3px in High Contrast — solid primary with 2px offset), keyboard modality only
    Rectangle {
        id: focusRing
        anchors.fill: parent
        anchors.margins: -(Tokens.metrics.focusRingOffset + Tokens.metrics.focusRingWidth)
        radius: parent.radius + Tokens.metrics.focusRingOffset + Tokens.metrics.focusRingWidth
        color: "transparent"
        border.width: Tokens.metrics.focusRingWidth
        border.color: Tokens.color.primary
        visible: root.focusVisible
        Accessible.ignored: true
    }

    // Pointer hit area may extend beyond the visual bounds (Fitts edge extension, minimum target size)
    Item {
        id: hitArea
        anchors.fill: parent
        anchors.topMargin: -root.hitTopExtension
        anchors.bottomMargin: -root.hitBottomExtension
        anchors.leftMargin: -root.hitSideExtension
        anchors.rightMargin: -root.hitSideExtension

        HoverHandler {
            id: hoverHandler
            enabled: root.interactive
            cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        }

        TapHandler {
            id: tapHandler
            enabled: root.interactive
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressedChanged: if (pressed) Tokens.keyboardModality = false
            onTapped: (eventPoint, button) => {
                if (button === Qt.LeftButton) root.clicked()
                else if (button === Qt.RightButton) root.rightClicked()
                else if (button === Qt.MiddleButton) root.middleClicked()
            }
        }
    }

    M3Tooltip {
        target: root
        text: root.tooltipText
        shown: root.tooltipText !== "" && (root.hovered || root.focusVisible)
    }
}
```

---

## 2. `M3Card` — Bento & Content Card Variants

| Variant | `tier` | Background Token | Border | Corner Radius | Primary Use Case |
|---|---|---|---|---|---|
| `"elevated"` | `1` | `surfaceTier(1)` (`surfaceContainerHigh`) | `1px` `surfaceBorder(1)` | `Tokens.shape.xl` (`24px`) | Weather card, Notification bundle, Media player card |
| `"filled"` | `2` | `surfaceTier(2)` (`surfaceContainerHighest`) | `0px` | `Tokens.shape.lg` (`16px`) | Telemetry stat card, Quick Settings sub-sheet, Agenda event item |
| `"outlined"` | `0` | `surfaceTier(0)` (`surfaceContainer`) | `1px` `outlineVariant` @ `40%` | `Tokens.shape.lg` (`16px`) | Polkit details box, Clipboard history item, Theme preview card |

---

## 3. `M3Divider` & `M3Scrim`

- **`M3Divider`**: `1px` horizontal or vertical rule using `Tokens.color.withAlpha(Tokens.color.outlineVariant, 0.24)`. Insets by `16px` (`spaceLg`) when dividing list rows inside a card, or `0px` when dividing full modal sections.
- **`M3Scrim`**: Full-screen backdrop dimmer for `Overlay` modals and Widget Peek (`AppCommandLauncher`, `PowerSessionMenu`, `PolkitDialog`, `DesktopWidgetsLayer` peek). Uses `Tokens.color.withAlpha(Tokens.color.scrim, Tokens.metrics.scrimAlpha)` (`42%`, the single scrim strength for every modal) with `fadeDuration: Tokens.motion.springDefaultEffects.durationMs` (`220ms`). Clicking `M3Scrim` emits `dismissed()`.

---

## 4. `M3ScreenCorners` — Concave Monitor Corner Rounder

Gives the entire monitor a cohesive M3 physical bezel appearance (or seamlessly joins any bar flush with its edge — edge gap `0` — with the screen edges) by drawing 4 concave corner masks (`radius: Tokens.shape.xl = 24px`) on `WlrLayer.Overlay` with an empty input mask (`mask: Region {}`) so 100% of clicks pass through.

---

## 5. `M3PolygonSurface` — Scalloped, Clover, Flower, Hexagon & Diamond Container

`M3PolygonSurface` renders the six sampled M3 Expressive shapes (`scallop_12`, `clover_4`, `flower_8`, `hexagon`, `diamond`, `rounded_triangle`) using QtQuick `Canvas` and morphs them smoothly toward a circle (`morphProgress`: `0.35` on hover, `1.0` while pressed, via `Tokens.motion.springFastSpatial`). `slanted_pill` is not sampled: it is an `M3Surface` capsule with a `-10°` skew transform and its label counter-skewed by `+10°`.

Placement and content rules live in `03-motion-and-morphing.md` §5. This primitive enforces them structurally:
- **Safe content circle**: children are laid out inside `contentContainer`, a centred square sized to the shape's inscribed circle (`width × 0.92 × Tokens.shape.polygonSafeContentRatio(kind)`), so text can never collide with lobes or corners.
- **Outline-only rotation**: `slowRotate` turns the `Canvas` outline only. Content stays upright, and rotation runs only while the item is visible and `Tokens.motion.decorativeMotionEnabled` is true.
- **Keyboard & screen reader parity** with `M3Surface` (`Enter` / `Space`, focus-visible ring, `Accessible.name`).

### 5.1 Canonical QML Implementation (`M3PolygonSurface.qml`)

```qml
import QtQuick
import MatShell.Tokens

Item {
    id: polyRoot
    property string polygonKind: Tokens.shape.polygonScallop12 // "scallop_12" | "clover_4" | "flower_8" | "hexagon" | "diamond" | "rounded_triangle"
    property color fillColor: Tokens.color.secondaryContainer
    property color contentColor: Tokens.color.onSecondaryContainer
    property bool interactive: true
    property bool slowRotate: false            // Only while content is live (e.g., media playing)
    property string accessibleName: ""         // Required when interactive
    default property alias content: contentContainer.data

    readonly property bool hovered: hoverHandler.hovered
    readonly property bool pressed: tapHandler.pressed
    readonly property bool focusVisible: activeFocus && Tokens.keyboardModality
    readonly property real safeContentSize: width * 0.92 * Tokens.shape.polygonSafeContentRatio(polygonKind) * Math.SQRT1_2
    property real morphProgress: pressed ? 1.0 : (hovered ? 0.35 : 0.0)

    signal clicked()

    implicitWidth: 96
    implicitHeight: 96
    scale: pressed ? 0.94 : (hovered ? 1.04 : 1.0)

    activeFocusOnTab: interactive
    Accessible.role: interactive ? Accessible.Button : Accessible.Graphic
    Accessible.name: accessibleName
    Accessible.onPressAction: if (interactive) polyRoot.clicked()
    Keys.onPressed: (event) => {
        if (interactive && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
            polyRoot.clicked()
            event.accepted = true
        }
    }

    Behavior on morphProgress {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
        }
    }
    Behavior on scale {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
        }
    }
    onMorphProgressChanged: shapeCanvas.requestPaint()
    onFillColorChanged: shapeCanvas.requestPaint()
    onPolygonKindChanged: shapeCanvas.requestPaint()

    Canvas {
        id: shapeCanvas
        anchors.fill: parent
        antialiasing: true
        Accessible.ignored: true

        // Rotates the outline only; contentContainer is a sibling, so content never rotates
        RotationAnimator on rotation {
            running: polyRoot.slowRotate && polyRoot.visible && Tokens.motion.decorativeMotionEnabled
            from: 0; to: 360
            duration: 28000
            loops: Animation.Infinite
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const pts = Tokens.shape.samplePolygonPoints(polyRoot.polygonKind, 128, polyRoot.morphProgress)
            if (pts.length === 0) return
            ctx.beginPath()
            for (let i = 0; i < pts.length; i++) {
                const px = (pts[i].x / 100.0) * width
                const py = (pts[i].y / 100.0) * height
                if (i === 0) ctx.moveTo(px, py)
                else ctx.lineTo(px, py)
            }
            ctx.closePath()
            ctx.fillStyle = polyRoot.fillColor.toString()
            ctx.fill()
        }
    }

    Item {
        id: contentContainer
        anchors.centerIn: parent
        width: polyRoot.safeContentSize
        height: polyRoot.safeContentSize
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -(Tokens.metrics.focusRingOffset + Tokens.metrics.focusRingWidth)
        radius: width / 2
        color: "transparent"
        border.width: Tokens.metrics.focusRingWidth
        border.color: Tokens.color.primary
        visible: polyRoot.focusVisible
        Accessible.ignored: true
    }

    HoverHandler {
        id: hoverHandler
        enabled: polyRoot.interactive
        cursorShape: polyRoot.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
    TapHandler {
        id: tapHandler
        enabled: polyRoot.interactive
        onPressedChanged: if (pressed) Tokens.keyboardModality = false
        onTapped: polyRoot.clicked()
    }
}
```

