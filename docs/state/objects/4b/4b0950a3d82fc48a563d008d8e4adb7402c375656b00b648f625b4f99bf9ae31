# Shell Component 15 — M3 Expressive Desktop Wallpaper Widgets & "Widget Peek"

> **Module**: `design-system/shell-components/15-desktop-widgets-layer.md`
> **Component ID**: `SC-15`
> **Primitives Used**: `M3PolygonSurface`, `M3DuotoneClock`, `M3Surface`, `M3SearchField`, `M3AppIcon`, `M3Scrim`

---

## 1. Purpose & Wayland Layer Config

The **M3 Expressive Desktop Wallpaper Widget Suite** brings rich, organic Material 3 Expressive widgets to the desktop background (`WlrLayer.Background`): layered duotone and scalloped clocks, petal media controls, diamond hardware gauges, editorial date and greeting clusters, weather badges, and a search launcher. It is designed around three usability promises:
1. **Never a distraction**: widgets recede (calm) or disappear (hidden) while the user works, so no motion or ticking numbers sit in peripheral vision.
2. **Always reachable**: they bloom back on empty workspaces, and `Super+D` **Widget Peek** raises them above windows in both desktop modes.
3. **Always legible**: content on an arbitrary wallpaper follows the Wallpaper Legibility Guard (`01-color-and-surfaces.md` §5).

| Property | Background Mode (Default) | Widget Peek Mode (`ShellState.widgetPeekActive`, `Super+D`) |
|---|---|---|
| **`WlrLayershell.namespace`** | `"mat-desktop-widgets"` | `"mat-desktop-widgets-peek"` |
| **`WlrLayershell.layer`** | `WlrLayer.Background` | **`WlrLayer.Overlay`** above windows with `M3Scrim` (`Tokens.metrics.scrimAlpha` = `42%`) |
| **Anchors** | `top: true; bottom: true; left: true; right: true` | `top: true; bottom: true; left: true; right: true` |
| **`WlrLayershell.exclusiveZone`** | `-1` | `-1` |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.None` | `WlrKeyboardFocus.OnDemand` (`Escape`, `Super+D`, or a scrim click exits Peek) |
| **Input Mask (`mask`)** | Union of visible widget bounding boxes; **empty** while hidden | Full screen (clicking the scrim exits Peek) |
| **Shell Lane** | Lane 1 (ambient) | Lane 3 modal `"widget_peek"` — opening the launcher, overview, or any modal closes Peek |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

### 2.1 Three-State Visibility Model

| State | When | Opacity / Scale | Motion & Polling |
|---|---|---|---|
| **Vivid** | Tiling: the focused workspace has no windows. Floating: no window has focus (desktop focused). Any mode: Widget Peek | `1.0` / `Tokens.widgetScale` | Decorative motion on (album outline rotation while playing); telemetry every `2.5s` |
| **Calm** | Floating mode while a window has focus | `0.9` with `MultiEffect { saturation: -0.6 }` (muted, still legible) | Decorative motion paused; telemetry every `10s`; clock keeps minute precision |
| **Hidden** | Tiling mode while `>= 1` tiled window is on the workspace (windows cover the wallpaper) | Fades to `0.0`, then `visible: false` | No rendering, no polling, empty input mask: zero wakeups behind work |

| Feature | `Tokens.desktopMode === "tiling"` (Hyprland / Niri / Sway) | `Tokens.desktopMode === "floating"` (Traditional Desktop) |
|---|---|---|
| **Default Behavior** | **Hidden** behind tiled windows; **blooms** to Vivid on empty workspaces | **Calm** while a window is focused; **Vivid** when the desktop is focused |
| **`Super+D` Widget Peek** | Raises the suite to `WlrLayer.Overlay` above tiled windows so the user can use media controls, search, or weather without leaving the tiled workflow | Identical — `Super+D` always means Widget Peek, never "show desktop" |

---

## 3. Visual Anatomy & ASCII Layout (8 Widgets × 3 Expressive Styles)

```text
╭───────────────────────────────────────────────────────────────────────────────────────────────╮
│  LEFT CLUSTER (Personal & Time)                    RIGHT CLUSTER (Media, Telemetry & Weather) │
│                                                                                               │
│   13  45   ◄── [W1: Layered Duotone Clock]          ╭─╭─╭─╭─╮      ╭─────────────────────╮ ▲  │
│   G(26)(Oct)D ◄── [W2: Date & Greeting]           ╭╯  󰎆    ╰╮     │ 󰍉  Search or ask…   │╱✦╲ │
│   ╭────────────╮ ╭─────────╮                      │  Clover │     ╰─────────────────────╯‾‾‾ │
│   │ Afternoon  │ │ ✦ pawan │  (Slanted Pills)     ╰╮  Art  ╭╯      ▲ [W8: Search pill + ▲ AI │
│   ╰────────────╯ ╰─────────╯                       ╰─╰─╰─╰─╯          triangle badge, icon-only]│
│                                                  ╭───╮ ╭───╮ ╭───╮                            │
│   ╭──╭──╭──╮    ╭──────────────╮                 │ 󰒮 │ │ 󰏤 │ │ 󰒭 │ ◄── [W3: Petal Media]      │
│  ╭╯ 13:57  ╰╮   │  󰁹 86%       │                 ╰───╯ ╰───╯ ╰───╯     (scallop_12 buttons)   │
│  │  26 Oct  │   │  Charging    │                                                              │
│  ╰╮  Serif ╭╯   ╰──────────────╯                  ╱‾‾‾╲   ╱‾‾‾╲    ╭─╭─╭─╭─╮                  │
│   ╰──╰──╰──╯     ▲ [W6: Battery Ring]            ⟨ 43% ⟩ ⟨ 14% ⟩  ╭╯ 24°C  ╰╮                 │
│   ▲ [Alt Style:                                   ╲___╱   ╲___╱   │Bengaluru│                 │
│      Hexagon/Flower]                             RAM     CPU      ╰─╰─╰─╰─╯                   │
│                                                  ▲ [W5: Diamonds]  ▲ [W4: Scallop Weather]    │
╰───────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 3.1 The 8 Canonical Widgets & Their 3 Style Presets
Every widget supports 3 switchable styles (`styleIndex: 0 | 1 | 2`) and 5 scale multipliers (`Tokens.widgetScale`: `0.75x`, `0.9x`, `1.0x`, `1.25x`, `1.5x`). Polygon placements follow `03-motion-and-morphing.md` §5:

| Widget ID | Name | Style 0: *Sculpted Polygon* | Style 1: *Duotone Expressive* | Style 2: *Bento Pill* |
|---|---|---|---|---|
| **`W1: clock`** | **Expressive Clock** | `scallop_12` ("Cookie") analog clock with thick `primary`/`tertiary` hands | `M3DuotoneClock` (`96px` layered duotone; hour and minute groups separated by a clear gap) | `hexagon` tile with `54px` `Instrument Serif` numerals |
| **`W2: date_greeting`** | **Date & Greeting** | `flower_8` badge with `26 Oct` in `displayEditorial` | `G[26][Oct]D` locale-aware scallop badges (day + month name, never numeric month) + `slanted_pill` `"Afternoon"` & `@user` tags | Compact horizontal `M3Surface` Tier 1 date capsule |
| **`W3: media`** | **Petal Media Player** | `clover_4` album-art mask (outline rotates while playing; artwork upright) with `scallop_12` `Prev`/`Next` and `clover_4` `Play` | Circular album art with translucent `tertiaryContainer` overlay controls | Wide waveform card with `10s` skip pills |
| **`W4: weather`** | **Weather & Sun Arc** | `scallop_12` badge (`"24°C"` + city) + 4-squircle metrics cluster (Humidity, Wind, Sunrise, Sunset) | Organic blob card with oversized `displayMedium` temperature | 3-day horizontal forecast bento card |
| **`W5: telemetry`** | **System Monitor** | Twin `diamond` gauges (`43%` RAM, `14%` CPU — values of 4 characters or fewer) + storage pill (`273GB Free`) | Twin circular progress rings with `tnum` center readouts | Compact 3-bar horizontal telemetry card |
| **`W6: battery`** | **Battery Status** | Circular `scallop_12` progress ring (`"86%"` + `"Charging"` label) | Vertical high-contrast `successContainer` pill with bolt glyph | Dual device battery card (Laptop + Bluetooth Headset) |
| **`W7: events`** | **Events & Countdown** | `hexagon` `"On This Day / Milestone"` card + `"7 days to go"` `scallop_12` badge | Dual-circle date badge (`[26][Oct]`) + event title pill | Compact agenda list card |
| **`W8: search_ai`** | **Search & AI Launcher** | `M3SearchField` pill (`"Search or ask…"`) + `48px` `rounded_triangle` AI sparkle badge (**icon-only**) + 3 `M3AppIcon` shortcuts | `slanted_pill` prompt bar (`"Ask AI or launch…"`) | Standard `M3SearchField` pill with voice/AI icon |

### 3.2 Legibility on Any Wallpaper
- Only hero text of `45px` or larger (W1 Style 1 digits, the `displayEditorial` greeting) may sit on the bare wallpaper, rendered with the protection shadow (`M3DuotoneClock { onWallpaper: true }`).
- Every other label (dates, values, city names, tags) sits on its polygon, pill, or Tier 1 card.
- `ThemeService.regionLuma(rect)` is re-sampled when the wallpaper or widget position changes. If a bare hero element would fall below `3:1`, it gains a Tier 1 backplate (`radius: Tokens.shape.xl`) until the wallpaper changes.

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography / Shape Token |
|---|---|---|---|
| **Duotone Clock Digits** | `"transparent"` (protection shadow on wallpaper) | Hours: `primary` front over `tertiary` @ `78%`; Minutes: `tertiary` front over `primary` @ `78%` | `displayExpressiveHero` (`96px`, layer offset `0.06em`, group gap `0.18em`, `tnum`) |
| **Editorial Clock / Date** | `Tokens.color.surfaceTier(1)` | `Tokens.color.onSurface` | `displayEditorial` (`Instrument Serif`, `54px`, `tnum`), `polygonHexagon` / `polygonFlower8` |
| **Greeting Slanted Pills** | Pill 1: `tertiaryContainer`; Pill 2: `secondaryContainer` | `onTertiaryContainer` / `onSecondaryContainer` | `titleMedium` (`15px`, `600`), `polygonSlantedPill` (`-10deg` skew, label counter-skewed) |
| **Petal Media Album Art** | Album texture inside a `polygonClover4` mask | Overlay icon: `onPrimaryContainer` | `128px × 128px`; mask outline rotates `360deg / 28s` only while Vivid and playing |
| **Petal Media Buttons** | Play: `primary` (`clover_4`); Prev/Next: `secondaryContainer` (`scallop_12`) | `onPrimary` / `onSecondaryContainer` | `44px × 44px` (Play `56px`), morph to circle on press, `accessibleName` required |
| **Diamond Telemetry Tile** | `Tokens.color.surfaceTier(1)` | Value: `primary`; Label: `onSurfaceVariant` | `92px × 92px`, `polygonDiamond`, `titleMedium` (`tnum`) |
| **Scalloped Weather Badge** | `Tokens.color.primaryContainer` | `Tokens.color.onPrimaryContainer` | `124px × 124px`, `polygonScallop12`, `headlineMedium` (`tnum`) |
| **AI Triangle Badge** | `Tokens.color.tertiaryContainer` | `Tokens.color.onTertiaryContainer` | `48px × 48px`, `polygonTriangle`, single `20px` glyph only |
| **Widget Peek Scrim** | `M3Scrim` (`scrim` @ `42%`) | — | Fade `springDefaultEffects` |

---

## 5. Interactive State Matrix

| State | Visual & Spatial Response |
|---|---|
| **Vivid** | Full opacity (`1.0`), `scale: Tokens.widgetScale`, interactive. |
| **Calm** (floating, window focused) | Crossfades to `opacity: 0.9` and `saturation: -0.6` over `220ms` (`springDefaultEffects`); decorative motion pauses; widgets stay clickable around windows. |
| **Hidden** (tiling, windows present) | Fades to `opacity: 0.0` over `220ms`, then `visible: false`; input mask empty; pollers stopped. |
| **`Super+D` Widget Peek Active** | Elevates to `WlrLayer.Overlay`, fades in `M3Scrim` (`42%`), scales `0.96 -> 1.0` via `springDefaultSpatial`, and enables full pointer/keyboard interaction (`Tab` cycles interactive widgets). |
| **Polygon Widget Pressed** | `M3PolygonSurface.morphProgress` animates `0.0 -> 1.0` via `springFastSpatial` (smoothing scallops/petals into a circle while pressed). |
| **Edit / Pin Mode (from `SC-14`)** | Shows `16px` snap grid, scale handle (`0.75x..1.5x`), style cycle chip (`Style 1/2/3`), and `"Remove"` pill badge; `Undo` snackbar after each removal. |

---

## 6. Motion & Morph Choreography

1. **Clover Album Outline Rotation & Pause Morph**: While `MprisPlayer.playbackState === MprisPlaybackState.Playing` **and** the suite is Vivid **and** `Tokens.motion.decorativeMotionEnabled`, the `clover_4` mask outline rotates continuously (`12.8 deg/sec`); the artwork never rotates. Pausing decelerates the rotation and morphs the outline (`morphProgress: 0 -> 0.5`) while the Play button morphs to a circle.
2. **Workspace Bloom Transition**: Switching from an occupied tiled workspace to an empty one blooms the suite from `scale: 0.96, opacity: 0.0` to `scale: 1.0, opacity: 1.0` using `Tokens.motion.springSlowSpatial` (`damping: 0.78`, `spring: 2.6`). Under Reduced Motion, this is a `100ms` crossfade with no scale.

---

## 7. Quickshell Service & IPC Bindings

- **Clock & Date (`Quickshell.Services.SystemClock`)**: `precision: SystemClock.Minutes` (never seconds on the desktop). Drives `M3DuotoneClock`, analog hands, locale-aware date badges (`Qt.locale().monthName(m, Locale.ShortFormat)`), and greeting period (`Morning` `<12h`, `Afternoon` `12..17h`, `Evening` `>=17h`).
- **Media (`Quickshell.Services.Mpris`)**: Binds the Petal Media Controller to `Mpris.players.values[0]`.
- **System Telemetry (`Quickshell.Io.FileView` / `Process`)**: Reads `/proc/meminfo` and `/proc/stat` every `2500ms` while Vivid, every `10000ms` while Calm, and never while Hidden (`03-quickshell-service-architecture.md` §2.3).
- **Focus Signals**: Tiling emptiness from `Hyprland.focusedWorkspace.toplevels`; floating Calm from `ToplevelManager.activeToplevel !== null`.
- **Legibility Probe (`ThemeService.regionLuma(rect)`)**: Recomputed on wallpaper change and widget move.
- **IPC Peek Handler**: `qs ipc call shell toggleWidgetPeek` calls `ShellState.toggleModal("widget_peek")`, so Peek obeys the same mutual exclusion as every Lane 3 modal.

---

## 8. Canonical QML Reference Skeleton (`DesktopWidgetsLayer.qml`)

```qml
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import MatShell.Tokens

PanelWindow {
    id: widgetsWindow
    visible: Tokens.desktopWidgetsEnabled
    WlrLayershell.namespace: ShellState.widgetPeekActive ? "mat-desktop-widgets-peek" : "mat-desktop-widgets"
    WlrLayershell.layer: ShellState.widgetPeekActive ? WlrLayer.Overlay : WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: ShellState.widgetPeekActive ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    readonly property bool workspaceEmpty: (Hyprland.focusedWorkspace?.toplevels?.values?.length ?? 0) === 0
    // "peek" | "vivid" | "calm" | "hidden"  (§2.1)
    readonly property string visibilityState: ShellState.widgetPeekActive ? "peek"
        : (Tokens.isTiling ? (workspaceEmpty ? "vivid" : "hidden")
                           : (ToplevelManager.activeToplevel ? "calm" : "vivid"))
    readonly property bool vivid: visibilityState === "vivid" || visibilityState === "peek"

    mask: Region {
        item: widgetsWindow.visibilityState === "peek" ? peekScrim
            : (widgetsWindow.visibilityState === "hidden" ? noInput : widgetRoot)
    }
    Item { id: noInput; width: 0; height: 0 }

    M3Scrim {
        id: peekScrim
        anchors.fill: parent
        opacity: widgetsWindow.visibilityState === "peek" ? 1.0 : 0.0
        visible: opacity > 0.0
        onDismissed: ShellState.closeActiveModal()
    }

    Item {
        id: widgetRoot
        anchors.fill: parent
        visible: opacity > 0.01
        opacity: widgetsWindow.visibilityState === "hidden" ? 0.0 : (widgetsWindow.visibilityState === "calm" ? 0.9 : 1.0)
        scale: widgetsWindow.visibilityState === "hidden" && Tokens.motion.spatialMotionEnabled ? 0.96 : 1.0
        layer.enabled: widgetsWindow.visibilityState === "calm"
        layer.effect: MultiEffect { saturation: -0.6 }
        Keys.onEscapePressed: ShellState.closeActiveModal()

        Behavior on opacity {
            NumberAnimation { duration: Tokens.motion.springDefaultEffects.durationMs }
        }
        Behavior on scale {
            enabled: Tokens.motion.spatialMotionEnabled
            SpringAnimation {
                spring: Tokens.motion.springSlowSpatial.spring
                damping: Tokens.motion.springSlowSpatial.damping
            }
        }

        // Left Cluster: Layered Duotone Clock + Greeting + Locale-Aware Date
        ColumnLayout {
            id: leftCluster
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Tokens.metrics.spaceXxxl * 2
            anchors.leftMargin: Tokens.metrics.spaceXxxl * 2
            spacing: Tokens.metrics.spaceMd
            scale: Tokens.widgetScale
            transformOrigin: Item.TopLeft

            Item {
                id: clockBox
                implicitWidth: duotoneClock.implicitWidth + Tokens.metrics.spaceXxl
                implicitHeight: duotoneClock.implicitHeight + Tokens.metrics.spaceLg
                readonly property real regionLuma: ThemeService.regionLuma(Qt.rect(x, y, width, height))
                // Heuristic for ~3:1: luminance gap between the hero colour and the wallpaper region
                readonly property bool needsBackplate: Math.abs(regionLuma - Tokens.color.primary.hslLightness) < 0.35

                M3Surface {
                    anchors.fill: parent
                    tier: 1
                    cornerRadius: Tokens.shape.xl
                    visible: clockBox.needsBackplate
                }
                M3DuotoneClock {
                    id: duotoneClock
                    anchors.centerIn: parent
                    hoursText: Qt.formatDateTime(widgetClock.date, "HH")
                    minutesText: Qt.formatDateTime(widgetClock.date, "mm")
                    onWallpaper: !clockBox.needsBackplate
                }
            }

            M3Surface {
                // Slanted date pill: day + month name ordered per locale (never a numeric month)
                readonly property string shortFormat: Qt.locale().dateFormat(Locale.ShortFormat)
                implicitWidth: dateLabel.implicitWidth + Tokens.metrics.spaceXl * 2
                implicitHeight: Tokens.metrics.minIconButtonTarget
                customColor: Tokens.color.secondaryContainer
                cornerRadius: Tokens.shape.md
                transform: Matrix4x4 { matrix: Qt.matrix4x4(1, -0.17, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1) }
                Text {
                    id: dateLabel
                    anchors.centerIn: parent
                    transform: Matrix4x4 { matrix: Qt.matrix4x4(1, 0.17, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1) }
                    text: Qt.locale().toString(widgetClock.date,
                        parent.shortFormat.indexOf("M") < parent.shortFormat.indexOf("d") ? "ddd, MMM d" : "ddd, d MMM")
                    font.family: Tokens.typography.titleMedium.family
                    font.pixelSize: Tokens.typography.titleMedium.pixelSize
                    font.weight: Font.DemiBold
                    font.features: Tokens.typography.tabularFeatures
                    color: Tokens.color.onSecondaryContainer
                }
            }
        }

        // Right Cluster: Scallop Weather + Diamond Telemetry + Search with icon-only Triangle badge
        ColumnLayout {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Tokens.metrics.spaceXxxl * 2
            anchors.rightMargin: Tokens.metrics.spaceXxxl * 2
            spacing: Tokens.metrics.spaceLg
            scale: Tokens.widgetScale
            transformOrigin: Item.TopRight

            M3PolygonSurface {
                implicitWidth: 124; implicitHeight: 124
                polygonKind: Tokens.shape.polygonScallop12
                fillColor: Tokens.color.primaryContainer
                accessibleName: "Weather: 24 degrees, mostly clear"
                onClicked: ShellState.togglePopover("calendar", null)
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "24°"
                        font.family: Tokens.typography.headlineMedium.family
                        font.pixelSize: Tokens.typography.headlineMedium.pixelSize
                        font.weight: Font.Bold
                        font.features: Tokens.typography.tabularFeatures
                        color: Tokens.color.onPrimaryContainer
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Mostly Clear"
                        font.family: Tokens.typography.labelSmall.family
                        font.pixelSize: Tokens.typography.labelSmall.pixelSize
                        color: Tokens.color.onPrimaryContainer
                    }
                }
            }

            RowLayout {
                spacing: Tokens.metrics.spaceMd
                Repeater {
                    model: [ { label: "RAM", value: telemetry.ramPercent }, { label: "CPU", value: telemetry.cpuPercent } ]
                    delegate: M3PolygonSurface {
                        required property var modelData
                        implicitWidth: 92; implicitHeight: 92
                        polygonKind: Tokens.shape.polygonDiamond
                        fillColor: Tokens.color.surfaceTier(1)
                        interactive: false
                        accessibleName: modelData.label + " " + modelData.value + " percent"
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.value + "%"
                                font.family: Tokens.typography.titleMedium.family
                                font.pixelSize: Tokens.typography.titleMedium.pixelSize
                                font.weight: Font.Bold
                                font.features: Tokens.typography.tabularFeatures
                                color: Tokens.color.primary
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.family: Tokens.typography.labelSmall.family
                                font.pixelSize: Tokens.typography.labelSmall.pixelSize
                                color: Tokens.color.onSurfaceVariant
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: Tokens.metrics.spaceSm
                M3SearchField {
                    Layout.preferredWidth: 240
                    placeholderText: "Search or ask…"
                    onAccepted: (query) => ShellState.openLauncherMode("apps")
                }
                M3PolygonSurface {
                    implicitWidth: 48; implicitHeight: 48
                    polygonKind: Tokens.shape.polygonTriangle      // icon-only: safe content fits a single glyph
                    fillColor: Tokens.color.tertiaryContainer
                    accessibleName: "Ask AI"
                    onClicked: ShellState.openLauncherMode("cmd")
                    Text {
                        anchors.centerIn: parent
                        text: "auto_awesome"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: Tokens.metrics.iconSm
                        color: Tokens.color.onTertiaryContainer
                        Accessible.ignored: true
                    }
                }
            }
        }
    }

    QtObject {
        id: telemetry
        property int ramPercent: 43
        property int cpuPercent: 14
    }

    Timer {
        // Polls only while the suite is visible: 2.5s Vivid, 10s Calm, stopped while Hidden
        interval: widgetsWindow.vivid ? 2500 : 10000
        running: widgetsWindow.visible && widgetsWindow.visibilityState !== "hidden"
        repeat: true
        onTriggered: TelemetryService.sample(telemetry)
    }

    SystemClock {
        id: widgetClock
        precision: SystemClock.Minutes
    }
}
```
