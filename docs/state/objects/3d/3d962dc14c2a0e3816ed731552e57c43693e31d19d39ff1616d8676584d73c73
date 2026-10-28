# Shell Component 07 — On-Screen Display (OSD) HUDs & Privacy Indicators

> **Module**: `design-system/shell-components/07-osd-huds.md`
> **Component ID**: `SC-07`
> **Primitives Used**: `M3Surface`, `M3Slider`

---

## 1. Purpose & Wayland Layer Config

The **OSD HUD Subsystem** renders transient, non-focus-stealing M3 Expressive pills whenever hardware or compositor state changes via hotkeys:
- **Audio Volume / Mute / Overamplification (`>100%`) OSD**
- **Microphone Mute OSD**
- **Display Brightness & Keyboard Backlight OSD**
- **Caps Lock / Num Lock / Keyboard Layout (`EN` / `DE` / `JP`) OSD**
- **Tiling Workspace Switch HUD**

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-osd"` |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` (renders above fullscreen games/videos without stealing focus) |
| **Anchors** | `bottom: true` (horizontally centered, `bottomMargin: BarService.maxInsets(screen).bottom + spaceXxl`, so it clears every bottom bar, including auto-hidden ones that may reveal while the OSD is up) |
| **Dimensions** | `width: Tokens.metrics.osdPillWidth (260px)`, `height: Tokens.metrics.osdPillHeight (52px)` |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.None` (Mandatory — must never interrupt typing or games)** |
| **Input Mask (`mask`)** | Empty `Region {}` by default (click-through) |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Workspace Switch HUD** | Enabled (`350ms` transient capsule showing `[ Workspace 3 • 2 Windows ]` when switching via `Super+1..9`) | Disabled unless multiple virtual desktops are active |
| **Submap Mode Banner** | Persistent mini-pill at top-center when inside a non-default Hyprland submap (`RESIZE — Press Esc to exit`) | Not applicable |

---

## 3. Visual Anatomy & ASCII Layout

```text
   VOLUME / BRIGHTNESS OSD PILL (260px × 52px, radius: full)
   ╭───────────────────────────────────────────────────────────╮
   │  ╭──────╮   ╭───────────────────────╮ ┃ ╭───────╮   72%   │
   │  │  󰕾   │   │  Active Track         │ ┃ │     • │         │  Tabular numerals (tnum)
   │  ╰──────╯   ╰───────────────────────╯ ┃ ╰───────╯         │
   ╰───────────────────────────────────────────────────────────╯

   OVERAMPLIFICATION STATE (100% .. 150% Volume)
   ╭───────────────────────────────────────────────────────────╮
   │  ╭──────╮   ╭───────────────────────┳━━━━━━━╮ ┃ ╭─╮  125% │
   │  │  󰕾!  │   │  primary (0..100%)    ┃ error │ ┃ │•│       │  >100% segment uses Tokens.color.error
   │  ╰──────╯   ╰───────────────────────┻━━━━━━━╯ ┃ ╰─╯       │
   ╰───────────────────────────────────────────────────────────╯

   CAPS LOCK / KEYBOARD LAYOUT OSD PILL (196px × 48px)
   ╭───────────────────────────────────────────╮
   │  ╭──────╮   Caps Lock ON                  │  Icon well: tertiaryContainer
   │  │  󰪛   │   Uppercase Active              │
   │  ╰──────╯                                 │
   ╰───────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Normal State (`0%..100%`) | Muted / Off State | Overamplified (`>100%`) | Typography / Metric Token |
|---|---|---|---|---|
| **OSD Root Capsule** | `Tokens.color.surfaceTier(0)` | `Tokens.color.surfaceTier(0)` | `Tokens.color.surfaceTier(0)` + `1px` `error` border | `260px × 52px`, `radius: full` |
| **Leading Icon Well (`36×36`)** | `Tokens.color.primaryContainer` / `onPrimaryContainer` | `Tokens.color.errorContainer` / `onErrorContainer` | `Tokens.color.errorContainer` / `onErrorContainer` | `radius: full`, icon `20px` |
| **Slider Active Track** | `Tokens.color.primary` | `Tokens.color.outline` @ `40%` | `0..100%`: `primary`; `100..150%`: `error` | `height: 16px`, thumb gap `4px` |
| **Numeric Value Readout** | `Tokens.color.onSurface` | `Tokens.color.error` (`"Muted"`) | `Tokens.color.error` | `labelLarge` (`13px`, `600`, **`tabularFeatures`**) |

---

## 5. Interactive State Matrix

| State | Visual & Timing Response |
|---|---|
| **Hidden** | `visible: false`, `opacity: 0.0`, `scale: 0.85`, `translateY: +16px` |
| **Triggered (First Press)** | Animates in via `Tokens.motion.springFastSpatial` (`scale: 0.85 -> 1.0`, `translateY: 16 -> 0`) and starts `1800ms` auto-hide `Timer`. |
| **Rapid Key Repeat / Scrub** | Restarts the `1800ms` `Timer`; slider width updates smoothly via `springFastSpatial`; when hitting `0%` or `100%` boundary, pill executes a subtle `±3px` horizontal rubber-band nudge. |
| **Dismissing (`Timer` elapsed)** | Animates `opacity: 1.0 -> 0.0` and `scale: 1.0 -> 0.92` over `180ms` (`springFastEffects`), then sets `visible = false`. |

---

## 6. Motion & Morph Choreography

1. **Mode Morphing (Volume <-> Brightness <-> CapsLock)**: If Brightness is adjusted while the Volume OSD is still visible, the existing capsule stays open, morphs its width (`260px <-> 196px` via `springFastSpatial`), swaps the leading icon with a `scale: 0.5 -> 1.0` pop, and resets the `1800ms` timer.
2. **Boundary Rubber-Banding**: Pressing `XF86AudioRaiseVolume` when already at `100%` stretches the OSD pill width `260px -> 268px -> 260px` via `springFastSpatial` to give physical feedback that maximum volume has been reached. Under Reduced Motion, the readout briefly shows `"Max"` instead of stretching.

---

## 7. Quickshell Service & IPC Bindings

- **Audio (`Quickshell.Services.Pipewire`)**:
  - `Connections { target: Pipewire.defaultAudioSink?.audio; function onVolumeChanged() { osd.trigger("volume") } function onMutedChanged() { osd.trigger("volume") } }`
- **Brightness**:
  - `Quickshell.Io.FileView` watching `/sys/class/backlight/*/brightness`; compositor keys call `qs ipc call osd changeBrightness <±delta>` (the `IpcHandler { target: "osd" }` in the skeleton below).
- **Caps Lock & Layout**:
  - Hyprland `activelayout` event from `Quickshell.Hyprland.rawEvents` or ` /sys/class/leds/*::capslock/brightness`.

---

## 8. Canonical QML Reference Skeleton (`OsdHud.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import MatShell.Tokens

PanelWindow {
    id: osdWindow
    visible: opacity > 0.01
    WlrLayershell.namespace: "mat-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore   // offsets itself (05-wayland-layershell-spatial.md §4.4)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors.bottom: true
    // Clears every bottom bar, counting auto-hidden ones as shown so the OSD never jumps when a bar reveals
    margins.bottom: BarService.maxInsets(screen).bottom + Tokens.metrics.spaceXxl
    implicitWidth: Tokens.metrics.osdPillWidth + 24
    implicitHeight: Tokens.metrics.osdPillHeight + 24
    color: "transparent"

    // Click-through mask
    mask: Region {}

    property real currentValue: 0.72
    property bool isMuted: false
    property string currentIcon: isMuted ? "volume_off" : "volume_up"
    property bool showing: false

    opacity: showing ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation { duration: Tokens.motion.springFastEffects.durationMs }
    }

    function triggerVolume(): void {
        const audio = Pipewire.defaultAudioSink?.audio
        if (audio) {
            currentValue = audio.volume
            isMuted = audio.muted
        }
        showing = true
        hideTimer.restart()
        osdCapsule.Accessible.announce(isMuted ? "Muted" : "Volume " + Math.round(currentValue * 100) + " percent")
    }

    // Compositor keybinds: qs ipc call osd changeVolume 5 | changeBrightness -5 | toggleMute
    IpcHandler {
        target: "osd"
        function changeVolume(delta: int): void { AudioService.setVolume(AudioService.volume + delta / 100.0) }
        function toggleMute(): void { AudioService.toggleMute() }
        function changeBrightness(delta: int): void { BrightnessService.adjust(delta) }
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: osdWindow.showing = false
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        function onVolumeChanged() { osdWindow.triggerVolume() }
        function onMutedChanged() { osdWindow.triggerVolume() }
    }

    M3Surface {
        id: osdCapsule
        anchors.centerIn: parent
        width: Tokens.metrics.osdPillWidth
        height: Tokens.metrics.osdPillHeight
        tier: 0
        cornerRadius: Tokens.shape.full
        scale: osdWindow.showing ? 1.0 : 0.88

        Behavior on scale {
            enabled: Tokens.motion.spatialMotionEnabled
            SpringAnimation {
                spring: Tokens.motion.springFastSpatial.spring
                damping: Tokens.motion.springFastSpatial.damping
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 14
            spacing: 10

            Rectangle {
                width: 36; height: 36; radius: 18
                color: osdWindow.isMuted ? Tokens.color.errorContainer : Tokens.color.primaryContainer
                Text {
                    anchors.centerIn: parent
                    text: osdWindow.currentIcon
                    font.family: Tokens.typography.familyIcons
                    font.pixelSize: 20
                    color: osdWindow.isMuted ? Tokens.color.onErrorContainer : Tokens.color.onPrimaryContainer
                }
            }

            M3Slider {
                Layout.fillWidth: true
                value: osdWindow.currentValue
                muted: osdWindow.isMuted
            }

            Text {
                text: osdWindow.isMuted ? "Mute" : Math.round(osdWindow.currentValue * 100) + "%"
                font.family: Tokens.typography.labelLarge.family
                font.pixelSize: Tokens.typography.labelLarge.pixelSize
                font.weight: Font.DemiBold
                font.features: Tokens.typography.tabularFeatures
                color: osdWindow.isMuted ? Tokens.color.error : Tokens.color.onSurface
            }
        }
    }
}
```
