# Primitives 02 — Buttons, Icon Buttons, Segmented Controls, Chips & `M3BarPill`

> **Module**: `design-system/primitives/02-buttons-and-chips.md`
> **Dependencies**: `Tokens.color`, `Tokens.shape`, `Tokens.motion`, `Tokens.typography`, `Tokens.metrics`

---

## 1. `M3Button` — Standard & Expressive Push Buttons

### 1.1 Variants & Token Mapping

| Variant | Container Color | Content (`Text` & `Icon`) | Border | Resting Radius | Pressed Radius | Height (`compact` / `comfortable` / `spacious`) |
|---|---|---|---|---|---|---|
| `"filled"` | `Tokens.color.primary` | `Tokens.color.onPrimary` | `0px` | `height / 2` (`full`) | `Tokens.shape.sm` (`8px`) | `32px` / `38px` / `44px` |
| `"tonal"` | `Tokens.color.secondaryContainer` | `Tokens.color.onSecondaryContainer` | `0px` | `height / 2` (`full`) | `Tokens.shape.sm` (`8px`) | `32px` / `38px` / `44px` |
| `"outlined"` | `"transparent"` | `Tokens.color.primary` | `1px` `Tokens.color.outline` | `height / 2` (`full`) | `Tokens.shape.sm` (`8px`) | `32px` / `38px` / `44px` |
| `"text"` | `"transparent"` | `Tokens.color.primary` | `0px` | `height / 2` (`full`) | `Tokens.shape.sm` (`8px`) | `28px` / `34px` / `40px` |
| `"destructive"` | `Tokens.color.errorContainer` | `Tokens.color.onErrorContainer` | `1px` `error` @ `30%` | `height / 2` (`full`) | `Tokens.shape.sm` (`8px`) | `32px` / `38px` / `44px` |

### 1.2 Internal Padding & Spacing
- Label typography: `Tokens.typography.labelLarge` (`13px`, weight `600`).
- Horizontal padding: `16px` (`spaceLg`); when `leadingIcon !== ""` is present, leading padding is `12px` (`spaceMd`), icon-to-label gap is `8px` (`spaceSm`), trailing padding is `16px`.

---

## 2. `M3IconButton` — Circular / Squircle Morphing Icon Trigger

Used in Control Center header (Settings, Lock, Power), Media Player controls (Prev, Next, Shuffle), and Notification headers.

| Variant | Unselected Container | Selected / Active Container | Unselected Icon Color | Selected Icon Color | Resting Radius | Active/Pressed Radius |
|---|---|---|---|---|---|---|
| `"standard"` | `"transparent"` | `Tokens.color.surfaceContainerHighest` | `onSurfaceVariant` | `primary` | `height / 2` | `Tokens.shape.md` (`12px`) |
| `"tonal"` | `Tokens.color.surfaceTier(2)` | `Tokens.color.secondaryContainer` | `onSurfaceVariant` | `onSecondaryContainer` | `height / 2` | `Tokens.shape.md` (`12px`) |
| `"filled"` | `Tokens.color.surfaceTier(2)` | `Tokens.color.primary` | `onSurface` | `onPrimary` | `height / 2` | `Tokens.shape.md` (`12px`) |

---

## 3. `M3SegmentedButton` — Connected Multi-Segment Selector

Used in **Screen Capture HUD** (`Region | Window | Screen`), **Control Center Power Profile** (`Saver | Balanced | Performance`), and **Wallpaper Studio** (`Dark | Light`, `Glass | Opaque`).

### 3.1 Connected Asymmetric Shape Rule
Instead of a rigid uniform pill, `M3SegmentedButton` uses M3 Expressive connected corners:
- **Outer Left Edge** of first item and **Outer Right Edge** of last item: `height / 2` (`full` capsule).
- **Inner Adjacent Corners** of unselected items: `Tokens.shape.xs` (`4px`).
- **Selected Item**: All 4 corners morph to `height / 2` (`full` capsule) via `Tokens.motion.springFastSpatial`, detaching visually inside the trough (`Tokens.color.surfaceTier(3)`).

---

## 4. `M3BarPill` — The Signature Bar Widget Capsule

`M3BarPill` is the capsule primitive behind every bar widget in `02-bar-widgets.md` (`SC-02`): clock, control center, media, telemetry, privacy, submap, launcher, notifications, power. It works on bars at any edge (`01-bar-system.md`).

### 4.1 Anatomy & Behavior
```text
╭──────────────────────────────────────────╮
│ [10px] [Icon 16px] [6px] [Label 13px] [10px] │  Cross size: pillSize = bar.thickness − 2 × barPadding (30px on a 40px bar)
╰──────────────────────────────────────────╯
```
- **Cross Size**: `pillSize`, set by `BarWidgetLoader` from the host bar's thickness (default `Tokens.metrics.barPillHeight`). On horizontal bars it is the pill's height; on vertical bars its width, and the pill's height grows with content.
- **Resting Background**: `Tokens.color.surfaceTier(2)` (`surfaceContainerHighest` @ `96%` in glass mode), or `"transparent"` until hovered when the host bar is in `bar` mode and the widget is icon-only.
- **Expanded State** (`popoverOpen === true`): Background shifts to `Tokens.color.primaryContainer`, content shifts to `Tokens.color.onPrimaryContainer`, and corner radius morphs from `height / 2` (`15px`) to `Tokens.shape.lg` (`16px`, `ShapeTokens.morphPillRadius`).
- **Scroll & Multi-Button Support**: Exposes `scrolled(int step)` (accumulated wheel steps per `04-interaction-states-and-input.md` §2.3), `clicked()`, `middleClicked()`, and `rightClicked()`.
- **Wheel Direction**: Value pills (volume, brightness, media) set `physicalWheelDirection: true` so wheel-up always increases the value; navigation pills (workspace strip) leave it `false` so direction follows the system natural-scrolling preference.
- **Disclosure**: Icon-only pills MUST set `tooltipText` (also used as the screen-reader name). Hover never widens the pill; extra detail lives in the tooltip.
- **Edge Reach**: `BarWidgetLoader` passes `barEdge` (`top|right|bottom|left`), `edgeReach` (the bar's edge gap + cross slack), and `crossSlack`. The hit area extends by `edgeReach` toward the bar's screen edge and by `crossSlack` toward the screen centre, so the pill is clickable from the physical edge on any bar (`05-wayland-layershell-spatial.md` §3.2). On vertical bars both side extensions use `edgeReach`; the bar window's input mask bounds the inner side.
- **Tooltip Placement**: Tooltips open on the side facing the screen centre (below on top bars, to the right on left bars).

### 4.2 Canonical QML Implementation (`M3BarPill.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import MatShell.Tokens

M3Surface {
    id: pill
    property bool popoverOpen: false
    property bool physicalWheelDirection: false
    property color activeContainerColor: Tokens.color.primaryContainer
    property color activeContentColor: Tokens.color.onPrimaryContainer
    property real wheelAccumulator: 0
    // Host bar geometry (set by BarWidgetLoader, SC-02 §8)
    property string barEdge: "top"
    property real edgeReach: 0
    property real crossSlack: 0
    property real pillSize: Tokens.metrics.barPillHeight
    readonly property bool vertical: barEdge === "left" || barEdge === "right"
    default property alias content: contentGrid.data

    signal scrolled(int deltaStep)

    tier: 2
    interactive: true
    customColor: popoverOpen ? activeContainerColor : "transparent"
    contentColor: popoverOpen ? activeContentColor : Tokens.color.onSurface
    implicitHeight: vertical ? Math.max(contentGrid.implicitHeight + Tokens.metrics.spaceSm * 2, pillSize) : pillSize
    implicitWidth: vertical ? pillSize : Math.max(contentGrid.implicitWidth + Tokens.metrics.spaceMd * 2, Tokens.metrics.minPointerTarget)
    cornerRadius: Tokens.shape.morphPillRadius(Math.min(width, height), hovered, pressed, popoverOpen)

    hitTopExtension: vertical ? 0 : (barEdge === "top" ? edgeReach : crossSlack)
    hitBottomExtension: vertical ? 0 : (barEdge === "bottom" ? edgeReach : crossSlack)
    hitSideExtension: vertical ? edgeReach : 0

    onHoveredChanged: if (!hovered) wheelAccumulator = 0

    GridLayout {
        id: contentGrid
        anchors.centerIn: parent
        flow: pill.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: pill.vertical ? -1 : 1
        columns: pill.vertical ? 1 : -1
        rowSpacing: Tokens.metrics.spaceXs
        columnSpacing: Tokens.metrics.spaceSm - 2 // 6px internal gap
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            const usePixels = event.pixelDelta.y !== 0
            const raw = usePixels ? event.pixelDelta.y : event.angleDelta.y
            const threshold = usePixels ? Tokens.metrics.touchpadStepPixels : Tokens.metrics.wheelStepAngle
            pill.wheelAccumulator += (pill.physicalWheelDirection && event.inverted) ? -raw : raw
            while (Math.abs(pill.wheelAccumulator) >= threshold) {
                const step = pill.wheelAccumulator > 0 ? 1 : -1
                pill.wheelAccumulator -= step * threshold
                pill.scrolled(step)
            }
        }
    }
}
```

---

## 5. `M3AppIcon` — Material You Monochrome Themed Application Icon Well

`M3AppIcon` renders real application icons (from the active icon theme via the Desktop Entry `icon` key) inside a morphing tonal well. When `themed` is true (bound to `Tokens.themedIcons` on persistent chrome), it uses the `-symbolic` variant, or a luminance-preserving tint of the full-colour icon, so third-party icons harmonize with the HCT palette.

**Scope** (`02-typography-and-iconography.md` §5): the bar `apps` widget (dock or taskbar, any bar) and Desktop Widgets bind `themed: Tokens.themedIcons`. Launcher (`SC-08`), Overview (`SC-09`), Notifications (`SC-04`), Polkit (`SC-12`), and the Power Menu inhibitor list (`SC-11`) set `themed: false`, so brand colour stays available for recognition.

```qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import MatShell.Tokens

M3Surface {
    id: appIconWell
    property string iconName: "org.wezfurlong.wezterm"  // DesktopEntry.icon
    property string appName: "WezTerm"                   // DesktopEntry.name (tooltip + screen reader)
    property bool appFocused: false
    property int runningCount: 0
    property bool themed: Tokens.themedIcons
    // Host bar geometry (SC-02 `apps` widget): indicator sits on the side facing the screen centre
    property string barEdge: "bottom"
    property real edgeReach: 0
    readonly property string indicatorSide: barEdge === "top" ? "bottom" : barEdge === "left" ? "right" : barEdge === "right" ? "left" : "top"

    readonly property string symbolicPath: Quickshell.iconPath(iconName + "-symbolic", true)
    readonly property color glyphColor: appFocused ? Tokens.color.onPrimary : Tokens.color.onSecondaryContainer

    implicitWidth: Tokens.metrics.appIconSize
    implicitHeight: Tokens.metrics.appIconSize
    hitTopExtension: barEdge === "top" ? edgeReach : 0
    hitBottomExtension: barEdge === "bottom" ? edgeReach : 0
    hitSideExtension: barEdge === "left" || barEdge === "right" ? edgeReach : 0
    tier: 2
    interactive: true
    active: appFocused
    customColor: appFocused ? Tokens.color.primary : (themed ? Tokens.color.secondaryContainer : "transparent")
    cornerRadius: Tokens.shape.morphTileRadius(height, appFocused, pressed)
    tooltipText: appName
    accessibleName: appName
    accessibleDescription: appFocused ? "Focused" : (runningCount > 0 ? runningCount + " windows open" : "Not running")

    IconImage {
        anchors.centerIn: parent
        implicitSize: Math.round(appIconWell.height * 0.6)
        source: appIconWell.themed && appIconWell.symbolicPath !== ""
            ? appIconWell.symbolicPath
            : Quickshell.iconPath(appIconWell.iconName)
        layer.enabled: appIconWell.themed
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: appIconWell.glyphColor
            saturation: appIconWell.symbolicPath !== "" ? 0.0 : -1.0   // full-colour fallback keeps internal detail
        }
        Accessible.ignored: true
    }

    // Running state is shape-coded: focused = 16px pill, running = 1–2 dots (never colour alone).
    // Placed 3px outside the well on the side facing the screen centre; rotates for vertical bars.
    Grid {
        readonly property bool alongY: appIconWell.indicatorSide === "left" || appIconWell.indicatorSide === "right"
        x: appIconWell.indicatorSide === "right" ? parent.width + 3 : appIconWell.indicatorSide === "left" ? -width - 3 : (parent.width - width) / 2
        y: appIconWell.indicatorSide === "bottom" ? parent.height + 3 : appIconWell.indicatorSide === "top" ? -height - 3 : (parent.height - height) / 2
        rows: alongY ? -1 : 1
        columns: alongY ? 1 : -1
        spacing: 3
        Repeater {
            model: appIconWell.appFocused ? 1 : Math.min(appIconWell.runningCount, 2)
            delegate: Rectangle {
                readonly property real lengthPx: appIconWell.appFocused ? 16 : 5
                width: parent.alongY ? 4 : lengthPx
                height: parent.alongY ? lengthPx : 4
                radius: 2
                color: appIconWell.appFocused ? Tokens.color.primary : Tokens.color.secondary
            }
        }
    }
}
```

---

## 6. `M3DuotoneClock` — Layered Duotone Expressive Hero Numerals

Used in `SC-15 Desktop Widgets Layer` (W1 Style 1) and on `SC-10` secondary outputs. It renders the hour and minute groups as two separate layered numbers with a clear gap between them (`02-typography-and-iconography.md` §4):
- **Within each group**: a tonal back layer (`78%` alpha) offset by `duotoneLayerOffsetRatio × pixelSize` sits beneath an opaque front layer. That overlap is the duotone effect.
- **Between groups**: a `duotoneGroupGapRatio × pixelSize` gap. Hours put `primary` in front; minutes swap to `tertiary` in front, so the separation never relies on hue alone.
- **On the wallpaper**: set `onWallpaper: true` to apply the protection shadow (`01-color-and-surfaces.md` §5).

```qml
import QtQuick
import QtQuick.Effects
import MatShell.Tokens

Item {
    id: duotoneClock
    property string hoursText: "13"
    property string minutesText: "45"
    property bool onWallpaper: false

    readonly property QtObject hero: Tokens.typography.displayExpressiveHero
    readonly property real layerOffset: Math.round(hero.pixelSize * hero.duotoneLayerOffsetRatio)
    readonly property real groupGap: Math.round(hero.pixelSize * hero.duotoneGroupGapRatio)

    implicitWidth: hourGroup.width + groupGap + minuteGroup.width + layerOffset
    implicitHeight: hourGroup.height + layerOffset

    Accessible.role: Accessible.StaticText
    Accessible.name: hoursText + ":" + minutesText

    layer.enabled: onWallpaper
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Tokens.color.scrim
        shadowOpacity: 0.35
        shadowBlur: 0.6
        shadowVerticalOffset: 2
    }

    component DuotoneGroup: Item {
        id: group
        property string digits
        property color frontColor
        property color backColor
        property real layerOffset
        width: front.implicitWidth
        height: front.implicitHeight

        Text {
            x: group.layerOffset
            y: group.layerOffset
            text: group.digits
            font.family: Tokens.typography.displayExpressiveHero.family
            font.pixelSize: Tokens.typography.displayExpressiveHero.pixelSize
            font.weight: Tokens.typography.displayExpressiveHero.weight
            font.letterSpacing: Tokens.typography.displayExpressiveHero.letterSpacing
            font.features: Tokens.typography.tabularFeatures
            color: Tokens.color.withAlpha(group.backColor, Tokens.typography.displayExpressiveHero.duotoneSecondaryAlpha)
            Accessible.ignored: true
        }
        Text {
            id: front
            text: group.digits
            font.family: Tokens.typography.displayExpressiveHero.family
            font.pixelSize: Tokens.typography.displayExpressiveHero.pixelSize
            font.weight: Tokens.typography.displayExpressiveHero.weight
            font.letterSpacing: Tokens.typography.displayExpressiveHero.letterSpacing
            font.features: Tokens.typography.tabularFeatures
            color: group.frontColor
            Accessible.ignored: true
        }
    }

    DuotoneGroup {
        id: hourGroup
        digits: duotoneClock.hoursText
        frontColor: Tokens.color.primary
        backColor: Tokens.color.tertiary
        layerOffset: duotoneClock.layerOffset
    }
    DuotoneGroup {
        id: minuteGroup
        x: hourGroup.width + duotoneClock.groupGap
        digits: duotoneClock.minutesText
        frontColor: Tokens.color.tertiary
        backColor: Tokens.color.primary
        layerOffset: duotoneClock.layerOffset
    }
}
```

---

## 7. `M3HoldToConfirm` — Press-and-Hold Confirmation for Destructive Actions

Used by the Power Menu (`SC-11`) and the Lock Screen's Reboot / Power off buttons (`SC-10`). Instead of a confirm-then-confirm-again dialog, the user **holds** the control, and the progress fills **the control itself**. Intent is explicit in one gesture, and letting go is the cancel.

### 7.1 Behavior Contract

| Input | Behavior |
|---|---|
| Pointer press / touch long-press on the control | Starts the fill. Moving off the control or releasing before `100%` drains the fill back over `Tokens.motion.holdDrainMs` (`200ms`) and nothing happens |
| `Enter` / `Space` on the focused control, or its mnemonic key (`P`, `R`, `E`) | Same as the pointer: the key's auto-repeat is ignored, and key release before `100%` cancels |
| Fill reaches `100%` (`Tokens.motion.holdToConfirmMs` = `2000ms`, **linear**) | Emits `confirmed()`; the control morphs to its done state (full `errorContainer` pill, label `"Shutting down…"`) for `350ms`, then the action runs |
| Released before `15%` (a tap) | Emits `tappedTooShort()`; the host plays the **nudge**: the fill peeks to `15%` (`springFastEffects`) and drains back (`holdDrainMs`) while the hold track pulses once, so the gesture is learnable without any text. Assistive technology hears `"Hold for 2 seconds to shut down"` (announcement only, never shown) |
| `Escape` during a hold | Cancels and drains |
| Window loses focus during a hold | Cancels and drains (a stuck key can never confirm) |
| `Tokens.confirmByHold === false`, or an assistive-technology `Accessible.onPressAction` | **Press-twice fallback**: the first activation arms (full fill, icon swaps to `check`, announced as `"Press again to restart"`), a second activation confirms, and `Escape`, focus loss, or `8s` of inactivity disarms. Holding is hard for some motor impairments, and screen readers cannot hold |

- **Reduced Motion**: the fill is information, not decoration, so it still runs (linear width, no spring). Only the drain collapses to a `100ms` crossfade, and the done-state morph becomes instant.
- **Visual**: the fill is an `errorContainer` layer clipped to the control's shape, growing from the leading edge. Label, icon, and key badge switch to `onErrorContainer` when the hold starts, so they stay legible over both the filled and unfilled parts. At rest, a hold-gated control shows a thin **hold track** (`3px`, `outlineVariant`) along its bottom edge: the empty gauge the fill will travel, which is the visual cue that this control is held rather than tapped. The key badge stays a bare letter (`P`).
- **Never for reversible actions**: Lock, Suspend, and Hibernate run on a single press. Holding is reserved for actions that end the session or lose work.

### 7.2 Canonical QML Implementation (`M3HoldToConfirm.qml`)

```qml
import QtQuick
import MatShell.Tokens

// Behavior-only helper: the host control renders `progress` and routes its press / release into begin() / end().
QtObject {
    id: hold

    property bool armed: false            // press-twice fallback state
    property real progress: 0.0           // 0..1, drawn by the host as the fill width
    readonly property bool holding: fill.running

    signal confirmed()
    signal tappedTooShort()

    property NumberAnimation fill: NumberAnimation {
        target: hold; property: "progress"; to: 1.0
        easing.type: Easing.Linear
        onFinished: if (hold.progress >= 1.0) hold.confirmed()
    }
    property NumberAnimation drain: NumberAnimation {
        target: hold; property: "progress"; to: 0.0
        duration: Tokens.motion.holdDrainMs
        easing.type: Easing.OutCubic
    }
    property Timer disarm: Timer { interval: 8000; onTriggered: hold.cancel() }

    // Pointer / key press
    function begin(): void {
        if (!Tokens.confirmByHold) {
            activate()
            return
        }
        drain.stop()
        fill.duration = Tokens.motion.holdToConfirmMs * (1.0 - progress)
        fill.restart()
    }

    // Pointer / key release, pointer leaving the control, focus loss
    function end(): void {
        if (!fill.running) return
        fill.stop()
        if (progress < Tokens.motion.holdTapHintThreshold) tappedTooShort()
        drain.restart()
    }

    // Press-twice path (Tokens.confirmByHold === false, Accessible.onPressAction)
    function activate(): void {
        if (armed) { armed = false; disarm.stop(); confirmed(); return }
        armed = true
        progress = 1.0
        disarm.restart()
    }

    function cancel(): void {
        fill.stop()
        armed = false
        disarm.stop()
        drain.restart()
    }
}
```

**Host wiring** (any `M3Surface`-based control): bind `onPressedChanged: pressed ? hold.begin() : hold.end()` (`M3Surface.pressed` covers pointer and `Enter` / `Space`), set `Accessible.onPressAction: hold.activate()`, and draw the fill:

```qml
Rectangle {                                   // inside the host (clip: true), beneath its content
    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
    width: parent.width * hold.progress       // straight leading edge reads as a sweep, not a growing blob
    color: Tokens.color.errorContainer
    Accessible.ignored: true
}
```
The host must clip to its own rounded shape (`clip: true` plus a rounded `layer` mask, or `M3Surface`'s radius), so the fill's corners always follow the control.

