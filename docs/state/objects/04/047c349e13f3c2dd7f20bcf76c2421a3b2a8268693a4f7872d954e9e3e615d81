# Shell Component 05 — Calendar, Agenda & Weather Bento Center

> **Module**: `design-system/shell-components/05-calendar-and-weather.md`
> **Component ID**: `SC-05`
> **Primitives Used**: `M3Popover`, `M3Surface`, `M3Card`, `M3IconButton`, `M3SegmentedButton`

---

## 1. Purpose & Wayland Layer Config

The **Calendar, Agenda & Weather Center** is a two-column M3 Expressive bento popover triggered by clicking a `clock` bar widget (`SC-02`) on any bar. It combines an interactive monthly calendar, daily agenda/pomodoro timer, and a live weather forecast card.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-calendar"` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **Card Alignment** | `M3Popover` origin-edge placement: docked inside the clicked clock's bar, centred on that clock along the bar axis, clamped inside `BarService.insets` (a right-end clock gets a right-aligned card; a centred clock a centred card; a rail clock a card beside the rail) |
| **Card Width** | `Tokens.metrics.calendarWeatherWidth` (`680px` two-column bento) |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.OnDemand` |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Spatial Origin & Alignment** | Unfolds from the clicked `clock` widget, wherever it sits (same in both modes; placement follows the bar layout, not the desktop mode) | Same |
| **Keyboard Navigation** | Arrow keys (or Vim `h/j/k/l`) move across day cells; `PageUp`/`PageDown` (or `[` / `]`) switch months; `T` jumps to today | Identical bindings — keyboard behavior never depends on desktop mode |
| **Weather & Agenda Empty States** | Offline: weather card shows `cloud_off` + `"Weather unavailable — last updated 14:20"` + `Retry` text button (never a blank card); no calendar source: agenda shows `"No calendar connected"` + `Set up` button | Same |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭───────────────────────────────────────────────────────────────────────────────────╮
│  ╭─────────────────────────────────────╮  ╭─────────────────────────────────────╮ │
│  │  MONDAY, OCT 26                     │  │  󰖙  24°C               Bengaluru, IN │ │
│  │  17:53:42               ╭───╮ ╭───╮ │  │     Mostly Clear      H:28°  L:18°  │ │
│  │  October 2026           │ 󰅁 │ │ 󰅂 │ │  │  ─────────────────────────────────  │ │
│  │  Mo  Tu  We  Th  Fr  Sa  Su         │  │   18:00   19:00   20:00   21:00     │ │
│  │                  1   2   3   4      │  │    󰖙       󰖔       󰖔       󰖔       │ │
│  │   5   6   7   8   9  10  11         │  │   23°     21°     20°     19°       │ │
│  │  12  13  14  15  16  17  18         │  ╰─────────────────────────────────────╯ │
│  │  19  20  21  22  23  24  25         │  ╭─────────────────────────────────────╮ │
│  │ [26] 27  28  29  30  31             │  │  UPCOMING AGENDA  •  [Pomodoro 25m] │ │
│  │                                     │  │  ╭─────────────────────────────────╮│ │
│  │                                     │  │  │ ┃ 18:30  Design System Review   ││ │
│  │                                     │  │  ╰─────────────────────────────────╯│ │
│  ╰─────────────────────────────────────╯  ╰─────────────────────────────────────╯ │
╰───────────────────────────────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Radius / Metric Token |
|---|---|---|---|---|
| **Root Bento Popover** | `Tokens.color.surfaceTier(0)` | `Tokens.color.onSurface` | — | `width: 680px`, `radius: xl (24px)`, `padding: 16px` |
| **Calendar Card (Left)** | `Tokens.color.surfaceTier(1)` | `Tokens.color.onSurface` | Month title: `titleMedium` (`15px`) | `width: 320px`, `radius: xl (24px)`, `padding: 16px` |
| **Day Cell (`36px × 36px`)** | Idle: `"transparent"`; Selected: `secondaryContainer`; **Today**: `primary` | Idle: `onSurface`; Today: `onPrimary` | `labelLarge` (`13px`, `tnum`) | Idle: `radius: full`; Pressed: `radius: sm (8px)` |
| **Weather Bento Card** | `Tokens.color.primaryContainer` | `Tokens.color.onPrimaryContainer` | Hero Temp: `displaySmall` (`36px`, `tnum`) | `radius: xl (24px)`, `padding: 16px` |
| **Agenda / Timer Card** | `Tokens.color.surfaceTier(1)` | `Tokens.color.onSurface` | Event title: `bodyMedium` (`13px`) | `radius: xl (24px)`, `padding: 16px` |
| **Agenda Event Pill** | `Tokens.color.surfaceTier(2)` + `4px` left bar in `tertiary` | `onSurface` / `onSurfaceVariant` | Time: `labelSmall` (`tnum`) | `height: 44px`, `radius: md (12px)` |

---

## 5. Interactive State Matrix

| Element | Idle | Hovered | Pressed | Selected / Active |
|---|---|---|---|---|
| **Calendar Day Cell** | Transparent (`36×36`) | `onSurface` @ `8%` circle | Squishes to `radius: 8px` (`sm`) | `secondaryContainer` pill (or `primary` if Today); loads that date's agenda |
| **Month Prev/Next Button** | `M3IconButton` `"tonal"` | +`8%` state layer | `radius: 8px` | Slides month grid horizontally (`±24px`) with fade |
| **Today Reset Chip** | Visible when viewing non-current month | `primaryContainer` | `scale: 0.96` | Jumps back to current month/day with `springDefaultSpatial` |

---

## 6. Motion & Morph Choreography

1. **Shared-Origin Unfold from Clock Pill**: Scales from `0.90 -> 1.0` anchored to the Clock Pill (`Top` in Floating mode, `TopRight` in Tiling mode) using `Tokens.motion.springDefaultSpatial`.
2. **Month Grid Cross-Slide**: Navigating months translates the outgoing 42-cell grid `x: 0 -> -24px` (`opacity: 1 -> 0`) and incoming grid `x: +24px -> 0` (`opacity: 0 -> 1`) over `200ms` (`curveEmphasized`).

---

## 7. Quickshell Service & IPC Bindings

- **Clock (`Quickshell.Services.SystemClock`)**: `precision: SystemClock.Seconds` while the popover is visible (`SystemClock.Minutes` when hidden to save CPU wakeups).
- **Weather Cache (`Quickshell.Io.FileView` / `Process`)**: Reads `~/.cache/mat-shell/weather.json` refreshed every 30 minutes via `curl -s "wttr.in/?format=j1"` or Open-Meteo JSON API.
- **Calendar Events**: Reads local `khal` / `evolution-data-server` / `.ics` JSON cache via `Process`.

---

## 8. Canonical QML Reference Skeleton (`CalendarWeatherPanel.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

// M3Popover places the card against the clicked clock's bar (any edge) and grows it out of that clock
M3Popover {
    id: calWindow
    name: "calendar"
    namespace: "mat-calendar"
    cardWidth: Tokens.metrics.calendarWeatherWidth
    cardHeight: 380

    Item {
        id: bentoRoot
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.margins: Tokens.metrics.spaceLg
            spacing: Tokens.metrics.spaceMd

            // Left Column: Month Grid Card
            M3Surface {
                Layout.preferredWidth: 310
                Layout.fillHeight: true
                tier: 1
                cornerRadius: Tokens.shape.xl

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.metrics.spaceLg
                    spacing: Tokens.metrics.spaceSm

                    Text {
                        text: "October 2026"
                        font.family: Tokens.typography.titleMedium.family
                        font.pixelSize: Tokens.typography.titleMedium.pixelSize
                        font.weight: Font.DemiBold
                        color: Tokens.color.onSurface
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        Repeater {
                            model: 31
                            delegate: M3Surface {
                                required property int index
                                readonly property int dayNum: index + 1
                                readonly property bool isToday: dayNum === 26

                                implicitWidth: 36
                                implicitHeight: 36
                                tier: isToday ? 4 : 2
                                interactive: true
                                active: isToday
                                customColor: isToday ? Tokens.color.primary : "transparent"
                                cornerRadius: Tokens.shape.full

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.dayNum.toString()
                                    font.family: Tokens.typography.labelLarge.family
                                    font.pixelSize: Tokens.typography.labelLarge.pixelSize
                                    font.features: Tokens.typography.tabularFeatures
                                    color: parent.isToday ? Tokens.color.onPrimary : Tokens.color.onSurface
                                }
                            }
                        }
                    }
                }
            }

            // Right Column: Weather + Agenda
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Tokens.metrics.spaceMd

                M3Surface {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    customColor: Tokens.color.primaryContainer
                    contentColor: Tokens.color.onPrimaryContainer
                    cornerRadius: Tokens.shape.xl

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Tokens.metrics.spaceLg
                        Text {
                            text: "24°C"
                            font.family: Tokens.typography.displaySmall.family
                            font.pixelSize: Tokens.typography.displaySmall.pixelSize
                            font.weight: Font.DemiBold
                            font.features: Tokens.typography.tabularFeatures
                            color: Tokens.color.onPrimaryContainer
                        }
                        Text {
                            text: "Mostly Clear • H: 28°  L: 18°"
                            font.family: Tokens.typography.bodySmall.family
                            font.pixelSize: Tokens.typography.bodySmall.pixelSize
                            color: Tokens.color.onPrimaryContainer
                        }
                    }
                }

                M3Surface {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    tier: 1
                    cornerRadius: Tokens.shape.xl
                }
            }
        }
    }
}
```
