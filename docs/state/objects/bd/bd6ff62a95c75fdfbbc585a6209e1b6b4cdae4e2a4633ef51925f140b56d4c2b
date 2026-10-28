# Shell Component 03 — Quick Settings & Control Center

> **Module**: `design-system/shell-components/03-control-center.md`
> **Component ID**: `SC-03`
> **Primitives Used**: `M3Popover`, `M3Surface`, `M3IconButton`, `M3Slider`, `M3SegmentedButton`, `M3Switch`

---

## 1. Purpose & Wayland Layer Config

The **Control Center** is the unified system control popover that grows out of the `controlCenter` bar widget (`SC-02`), on whichever bar and edge the user placed it. It provides M3 Expressive dual-action Quick Tiles (with inline accordion sub-sheets for Wi-Fi, Bluetooth, Audio Output/Input, and Power Profiles), thick split-track sliders for Master Audio and Display Brightness, and session action shortcuts.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-control-center"` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` |
| **Anchors** | `top: true; right: true; bottom: true; left: true` (full screen transparent click-catcher whose `mask` subtracts every bar, so another bar widget opens in one click) |
| **Card Position** | `M3Popover` origin-edge placement (`04-menus-popovers-and-tooltips.md` §1.1): docked `screenMargin` inside the trigger's bar, aligned to the `controlCenter` widget along the bar axis, clamped inside `BarService.insets`. Keyboard/IPC with no hosting bar: top-end corner |
| **Card Width** | `Tokens.metrics.controlCenterWidth` (`392px` comfortable, `360px` compact, `424px` spacious) |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.OnDemand` (`Exclusive` when Wi-Fi password input is focused) |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Desktop Mode Quick Tile** | Displays `"Tiling Mode • Hyprland"` (Active `primary` pill tile) + sub-sheet for Gaps/Animations/Layout (`Dwindle`/`Master`) | Displays `"Floating Desktop"` + sub-sheet with bar presets (`Top bar + Dock`, `Three islands`, …) and a `Configure bars…` link to Settings → Bars |
| **Keyboard Shortcut Hints** | Displays `[1]..[8]` numeric hotkeys on Quick Tiles whenever `Tokens.keyboardModality` is true | Identical: hotkeys, Tab, and arrow navigation work in both modes |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭──────────────────────────────────────────────────────────╮
│  ╭────╮ pawan@arch          󰁹 86% (4h 12m)  ╭───╮╭───╮╭───╮ │  Header Row (44px)
│  ╰────╯ up 6h 42m                           │ 󰒓 ││ 󰌾 ││ 󰐥 │ │  Settings | Lock | Power
│ ──────────────────────────────────────────────────────── │
│  ╭─────────────────────────╮  ╭─────────────────────────╮ │  2×3 M3 Expressive Quick Tile Grid
│  │  󰤨  Wi-Fi           │ 󰅀 │  │  󰂯  Bluetooth       │ 󰅀 │ │  Active Tile = radius.full (pill)
│  │     Home-5G         │   │  │     MX Master 3S    │   │ │  Inactive Tile = radius.lg (16px)
│  ╰─────────────────────────╯  ╰─────────────────────────╯ │  Split chevron expands sub-sheet
│  ╭─────────────────────────╮  ╭─────────────────────────╮ │
│  │  󰖔  Night Light         │  │  󰂛  Do Not Disturb      │ │
│  │     4200K Warm          │  │     Off                 │ │
│  ╰─────────────────────────╯  ╰─────────────────────────╯ │
│  ╭─────────────────────────╮  ╭─────────────────────────╮ │
│  │  󰓅  Power Profile   │ 󰅀 │  │  󰖯  Surface Mode        │ │
│  │     Balanced        │   │  │     Frosted Glass       │ │
│  ╰─────────────────────────╯  ╰─────────────────────────╯ │
│ ──────────────────────────────────────────────────────── │
│  [Optional Inline Expanded Sub-Sheet: Wi-Fi / Audio]     │  Animates height 0 -> 220px
│ ──────────────────────────────────────────────────────── │
│  ╭─────────────────────────────╮ ┃ ╭───────────────────╮ │  Master Volume M3Slider (28px)
│  │  󰕾  Sony WH-1000XM5     72% │ ┃ │                 • │ │  + Per-App Mixer Expand Button
│  ╰─────────────────────────────╯ ┃ ╰───────────────────╯ │
│  ╭─────────────────────────────────────╮ ┃ ╭───────────╮ │  Display Brightness M3Slider (28px)
│  │  󰃠  Built-in OLED               85% │ ┃ │         • │ │
│  ╰─────────────────────────────────────╯ ┃ ╰───────────╯ │
╰──────────────────────────────────────────────────────────╯
```

**Header actions** (left to right, each a `36px` `M3IconButton` with a tooltip): Accessibility (`accessibility_new`) · Theme Studio (`palette`, opens `SC-14`) · Settings · Lock · Power.

**Accessibility sub-sheet**: `M3Switch` rows plus a `M3SegmentedButton`, bound through `AccessibilityService` to `Tokens.reducedMotion`, `Tokens.reducedTransparency`, `Tokens.highContrast`, `Tokens.confirmByHold` ("Confirm by holding"; off = press twice), and `Tokens.textScale` (`Default | Large | Larger`). Changes apply live and persist to `config.json`.

---

## 4. Token Mapping Table

| Element | Inactive / Resting Token | Active / Toggled Token | Typography Token | Radius / Metric Token |
|---|---|---|---|---|
| **Root Popover Card** | `Tokens.color.surfaceTier(0)` | — | — | `width: 392px`, `radius: xl (24px)`, `padding: 16px` |
| **Quick Tile (Container)** | `Tokens.color.surfaceTier(1)` (`surfaceContainerHigh`) | `Tokens.color.primary` | — | `height: 60px`, Inactive: `radius: lg (16px)` <-> Active: `radius: full (30px)` |
| **Quick Tile (Title & Icon)** | `Tokens.color.onSurface` | `Tokens.color.onPrimary` | `labelLarge` (`13px`, `600`) | Icon `20px`, `FILL: active ? 1 : 0` |
| **Quick Tile (Subtitle)** | `Tokens.color.onSurfaceVariant` | `Tokens.color.onPrimary` @ `82%` | `labelSmall` (`11px`, `500`) | Single-line elided |
| **Dual-Action Divider Seam** | `outlineVariant` @ `30%` | `onPrimary` @ `24%` | — | `width: 1px`, `height: 28px`, right chevron zone `38px` wide |
| **Inline Sub-Sheet Card** | `Tokens.color.surfaceTier(2)` (`surfaceContainerHighest`) | — | Header: `titleSmall` (`13px`) | `radius: lg (16px)`, `padding: 12px`, max height `240px` |
| **Volume / Brightness Slider** | Inactive track: `secondaryContainer` | Active track: `primary` | `%` Badge: `labelMedium` (`tnum`) | `height: 28px`, thumb gap `6px` |

---

## 5. Interactive State Matrix

| Element | Idle | Hovered | Pressed | Active / Expanded |
|---|---|---|---|---|
| **Quick Tile (Left Body)** | `radius: 16px` (off) / `30px` (on) | +`8%` state layer | `radius: 12px` (`md`), `scale: 0.97` | Toggles underlying service (`nmcli`, `bluetoothctl`, DND) and morphs shape `16px <-> 30px` |
| **Quick Tile (Right Chevron)** | Chevron `0deg` | +`12%` highlight on right zone | `scale: 0.92` | Rotates chevron `180deg` and unfolds inline sub-sheet below its tile row |
| **Audio Slider Row** | `28px` thick split track | Thumb widens `4px -> 6px` | Thumb narrows `2px`, gap `4px`, shows live `%` (`tnum`) | Clicking trailing mixer icon expands per-application Pipewire stream sliders |

---

## 6. Motion & Morph Choreography

1. **Active Tile Shape Morph (`16px <-> 30px`)**: Toggling any Quick Settings tile animates its `radius` between `Tokens.shape.lg` (`16px` rounded rectangle) and `height / 2` (`30px` stadium capsule) using `Tokens.motion.springFastSpatial` while crossfading `color` via `springDefaultEffects` (`220ms`).
2. **Inline Accordion Sub-Sheet Unfold**: Clicking a tile's chevron (`Wi-Fi`, `Bluetooth`, `Audio Sink`, `Power Profile`) animates the sub-sheet's `implicitHeight` from `0` to `220px` with `clip: true` using `Tokens.motion.springDefaultSpatial` (`damping: 0.72`, `spring: 4.5`). Only one sub-sheet can be expanded at a time.

---

## 7. Quickshell Service & IPC Bindings

- **Audio (`Quickshell.Services.Pipewire`)**:
  - `Pipewire.defaultAudioSink.audio.volume` (`0.0..1.0`), `.muted`
  - Sink list: `Pipewire.nodes` filtered by `isSink && !isStream`
  - App stream mixer: `Pipewire.nodes` filtered by `isStream && isSink`
- **Power & Battery (`Quickshell.Services.UPower` & `powerprofilesctl`)**:
  - `UPower.displayDevice.percentage`, `.timeToEmpty`, `.timeToFull`
  - Power profile D-Bus (`net.hadess.PowerProfiles` or `powerprofilesctl set performance|balanced|power-saver`)
- **Network & Bluetooth**:
  - NetworkManager D-Bus (`org.freedesktop.NetworkManager`) or `nmcli -t -f SSID,SIGNAL,SECURITY,ACTIVE dev wifi`
  - BlueZ D-Bus (`org.bluez`)

---

## 8. Canonical QML Reference Skeleton (`ControlCenter.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import MatShell.Tokens

// M3Popover owns placement (any bar edge), the bar-aware click-catcher, and the grow-from-trigger morph
M3Popover {
    id: ccWindow
    name: "control_center"
    namespace: "mat-control-center"
    cardWidth: Tokens.metrics.controlCenterWidth
    cardHeight: mainCol.implicitHeight + (Tokens.metrics.spaceLg * 2)

    Item {
        id: panelCard
        anchors.fill: parent

        ColumnLayout {
            id: mainCol
            anchors.fill: parent
            anchors.margins: Tokens.metrics.spaceLg
            spacing: Tokens.metrics.spaceMd

            // Quick Tile 2-Column Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: Tokens.metrics.spaceSm
                columnSpacing: Tokens.metrics.spaceSm

                Repeater {
                    model: ListModel {
                        ListElement { title: "Wi-Fi"; subtitle: "Home-5G"; icon: "wifi"; active: true; hasSubsheet: true }
                        ListElement { title: "Bluetooth"; subtitle: "MX Master 3S"; icon: "bluetooth_connected"; active: true; hasSubsheet: true }
                        ListElement { title: "Night Light"; subtitle: "4200K"; icon: "nightlight"; active: false; hasSubsheet: false }
                        ListElement { title: "Do Not Disturb"; subtitle: "Off"; icon: "do_not_disturb_on"; active: false; hasSubsheet: false }
                    }
                    delegate: M3Surface {
                        required property string title
                        required property string subtitle
                        required property string icon
                        required property bool active
                        required property bool hasSubsheet

                        Layout.fillWidth: true
                        implicitHeight: 60
                        tier: active ? 4 : 1
                        interactive: true
                        active: active
                        accessibleName: title
                        accessibleDescription: (active ? "On, " : "Off, ") + subtitle
                        cornerRadius: Tokens.shape.morphTileRadius(height, active, pressed)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: icon
                                font.family: Tokens.typography.familyIcons
                                font.pixelSize: 20
                                color: active ? Tokens.color.onPrimary : Tokens.color.onSurface
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: title
                                    font.family: Tokens.typography.labelLarge.family
                                    font.pixelSize: Tokens.typography.labelLarge.pixelSize
                                    font.weight: Font.DemiBold
                                    color: active ? Tokens.color.onPrimary : Tokens.color.onSurface
                                }
                                Text {
                                    text: subtitle
                                    font.family: Tokens.typography.labelSmall.family
                                    font.pixelSize: Tokens.typography.labelSmall.pixelSize
                                    color: active ? Tokens.color.onPrimary : Tokens.color.onSurfaceVariant
                                }
                            }
                        }
                    }
                }
            }

            // Volume & Brightness M3 Expressive Sliders
            M3Slider {
                Layout.fillWidth: true
                icon: "volume_up"
                accessibleName: "Volume"
                value: Pipewire.defaultAudioSink?.audio?.volume ?? 0.72
                onMoved: (v) => {
                    if (Pipewire.defaultAudioSink?.audio) {
                        Pipewire.defaultAudioSink.audio.volume = v
                    }
                }
            }

            M3Slider {
                Layout.fillWidth: true
                icon: "brightness_high"
                accessibleName: "Display brightness"
                value: 0.85
            }
        }
    }
}
```
