# Shell Component 08 — Unified Application & Command Launcher

> **Module**: `design-system/shell-components/08-app-and-command-launcher.md`
> **Component ID**: `SC-08`
> **Primitives Used**: `M3Scrim`, `M3Surface`, `M3SearchField`, `M3FilterChip`, `M3Button`, `M3ScrollBar`

---

## 1. Purpose & Wayland Layer Config

The **Unified Application & Command Launcher** (`Super` or `Super+Space`) is the central keyboard-driven command palette and app launcher for the desktop environment. It supports instant prefix-based mode switching across **Applications**, **Open Windows (`win`)**, **Calculator (`=`)**, **Clipboard History (`clip`)**, **System Commands (`>`)**, and **Emoji/Nerd Symbols (`:`)**.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-launcher"` |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **Modal Dimensions** | `width: Tokens.metrics.launcherWidth (640px)`, `maxHeight: Tokens.metrics.launcherMaxHeight (520px)`, positioned `18%` from top of screen |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.Exclusive` (Mandatory — traps all keyboard input until dismissed)** |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Default Initial View (Empty Query)** | **Compact Fuzzy Command & App List** (`8` visible rows, `52px` row height, instant `Alt+1..8` execution badges) | **Expressive App Grid (`5×3` Pinned & Frequent Apps)** + Category Filter Chips (`All`, `Dev`, `Media`, `System`), morphing to List View as soon as 1+ characters are typed |
| **Launch Action Modifiers** | `Enter`: Launch on active workspace; `Shift+Enter`: Launch floating; `Ctrl+1..9`: Launch silently on workspace `1..9` | `Enter`: Launch or focus existing window; `Ctrl+Enter`: Launch new instance |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭───────────────────────────────────────────────────────────────────────────────────╮
│  ╭─────────────────────────────────────────────────────────────────────────────╮  │
│  │  󰍉   [Apps]  Search apps, or type  > cmd   = math   : emoji   clip          │  │  Search Pill (height: 52px, Tier 2)
│  ╰─────────────────────────────────────────────────────────────────────────────╯  │
│  ╭──────────╮ ╭──────────────╮ ╭──────────────╮ ╭──────────────╮ ╭─────────────╮  │  Mode Filter Chips (height: 30px)
│  │ 󰣇 All  • │ │ 󰖯 Windows (6)│ │ 󰅌 Clipboard  │ │ 󰪚 Calculator │ │ 󰞷 Commands  │  │
│  ╰──────────╯ ╰──────────────╯ ╰──────────────╯ ╰──────────────╯ ╰─────────────╯  │
│  ───────────────────────────────────────────────────────────────────────────────  │
│  ╭─────────────────────────────────────────────────────────────────────────────╮  │  Selected Row (Tier 4: secondaryContainer)
│  │  ╭──────╮  WezTerm                                       Terminal   [Enter] │  │  Height: 54px, radius: full (27px)
│  │  │  󰆍   │  GPU-accelerated cross-platform terminal emulator                 │  │
│  │  ╰──────╯                                                                   │  │
│  ╰─────────────────────────────────────────────────────────────────────────────╯  │
│    ╭──────╮  Firefox Developer Edition                      Web Browser  Alt+2    │  Unselected Row (radius: lg 16px)
│    │  󰈹   │  Browse the World Wide Web                                            │
│    ╰──────╯                                                                       │
│  ───────────────────────────────────────────────────────────────────────────────  │
│   󰌌  ↑↓ Navigate   •   ↵ Launch   •   Tab Actions   •   Ctrl+P Pin   •   Esc Exit │  Footer Hint Bar (32px, Tier 3)
╰───────────────────────────────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Radius / Metric Token |
|---|---|---|---|---|
| **Full-Screen Backdrop** | `M3Scrim` (`Tokens.color.scrim` @ `Tokens.metrics.scrimAlpha` = `42%`) | — | — | Fade duration `220ms` |
| **Result App Icons** | `M3AppIcon` with `themed: false` (original full-colour icon — recognition surface) | — | — | `32px` in list rows, `48px` in the floating-mode grid |
| **Launcher Modal Shell** | `Tokens.color.surfaceTier(0)` | `Tokens.color.onSurface` | — | `width: 640px`, `radius: xxl (28px)`, `padding: 16px` |
| **Search Input Bar** | `Tokens.color.surfaceTier(2)` | `onSurface` (placeholder `onSurfaceVariant`) | `titleMedium` (`15px`, `500`) | `height: 52px`, `radius: full`, `2px` `primary` border on focus |
| **Prefix Mode Badge** | `Tokens.color.tertiaryContainer` | `Tokens.color.onTertiaryContainer` | `labelMedium` (`600`) | `height: 28px`, `radius: full`, `padding: 10px` |
| **Selected Result Row** | `Tokens.color.secondaryContainer` | `Tokens.color.onSecondaryContainer` | Title: `bodyLarge` (`600`); Subtitle: `bodySmall` | `height: 54px`, **`radius: full (27px)`** |
| **Unselected Result Row** | `"transparent"` (Hover: `surfaceTier(1)`) | Title: `onSurface`; Subtitle: `onSurfaceVariant` | Title: `bodyLarge` (`400`); Subtitle: `bodySmall` | `height: 54px`, `radius: lg (16px)` |
| **Keyboard Hint Footer** | `Tokens.color.surfaceTier(3)` | `Tokens.color.onSurfaceVariant` | `labelSmall` (`11px`, `tnum`) | `height: 32px`, `radius: md (12px)` |

---

## 5. Interactive State Matrix

| State / Mode | Visual & Functional Behavior |
|---|---|
| **Prefix `=` or Math Expression** (`= 48 * 1.18`) | Displays a hero **M3 Expressive Calculator Card** (`height: 96px`, `primaryContainer`, result in `headlineSmall` `tnum`); pressing `Enter` copies result to `wl-copy` and shows `"Copied!"` pill. |
| **Prefix `>` (`> dark`, `> lock`)** | Filters built-in Quickshell system commands (`Toggle Dark Mode`, `Switch to Frosted Glass`, `Switch to Tiling Mode`, `Lock Session`, `Reload Shell`). |
| **Prefix `clip`** | Queries `cliphist list`, displays clipboard text/image thumbnails; `Enter` pipes selected item to `cliphist decode \| wl-copy` and closes. |
| **`Tab` on Selected App** | Expands inline Desktop Entry sub-actions (`New Private Window`, `Profile Manager`, `Pin to Bar` (adds it to the first `apps` widget's pinned list), `Run on Dedicated GPU`). |
| **No Results** | Never an empty panel: shows `"No matches for 'xyz'"` plus three fallback rows (`Search files for 'xyz'`, `Run 'xyz' as command (>)`, `Calculate (=)` when the query is numeric). `Enter` executes the first fallback. |
| **Slow Source** (clipboard history, file search `> 300ms`) | Skeleton rows (`surfaceTier(1)` shimmer at `springDefaultEffects`) hold the list height so results never jump in. |

---

## 6. Motion & Morph Choreography

1. **Modal Entrance**: Scales from `0.94 -> 1.0` and translates `y: -16px -> 0px` using `Tokens.motion.springDefaultSpatial` while the `M3Scrim` fades in over `180ms`.
2. **Selection Highlight Pill Morph**: Moving selection with `Up`/`Down` arrow keys animates the selected row's corner radius from `16px` (`lg`) to `27px` (`full` stadium capsule) and glides a shared highlight indicator across rows via `Tokens.motion.springFastSpatial`.

---

## 7. Quickshell Service & IPC Bindings

- **Applications (`Quickshell.DesktopEntries`)**: `DesktopEntries.applications` model -> `.name`, `.genericName`, `.comment`, `.icon`, `.exec`, `.categories`, `.actions`, `.execute()`.
- **Open Windows (`Quickshell.Wayland.ToplevelManager`)**: `ToplevelManager.toplevels` -> `.title`, `.appId`, `.activate()`.
- **Clipboard & Calculator (`Quickshell.Io.Process`)**: Executes `cliphist list` and `qalc -t <expr>`.

---

## 8. Canonical QML Reference Skeleton (`AppCommandLauncher.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: launcherWindow
    visible: ShellState.activeModal === "launcher"
    WlrLayershell.namespace: "mat-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property int selectedIndex: 0
    property string queryText: ""

    Rectangle {
        anchors.fill: parent
        color: Tokens.color.withAlpha(Tokens.color.scrim, 0.38)
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.closeActiveModal()
        }
    }

    M3Surface {
        id: modalCard
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.18
        width: Tokens.metrics.launcherWidth
        implicitHeight: contentCol.implicitHeight + 32
        tier: 0
        cornerRadius: Tokens.shape.xxl

        Keys.onEscapePressed: ShellState.closeActiveModal()
        Keys.onDownPressed: selectedIndex = Math.min(4, selectedIndex + 1)
        Keys.onUpPressed: selectedIndex = Math.max(0, selectedIndex - 1)

        ColumnLayout {
            id: contentCol
            anchors.fill: parent
            anchors.margins: Tokens.metrics.spaceLg
            spacing: Tokens.metrics.spaceMd

            // Search Input Bar
            M3Surface {
                Layout.fillWidth: true
                implicitHeight: 52
                tier: 2
                cornerRadius: Tokens.shape.full

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    Text {
                        text: "search"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: 22
                        color: Tokens.color.primary
                    }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        focus: true
                        color: Tokens.color.onSurface
                        font.family: Tokens.typography.titleMedium.family
                        font.pixelSize: Tokens.typography.titleMedium.pixelSize
                        onTextChanged: launcherWindow.queryText = text
                    }
                }
            }

            // Results List
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ListModel {
                        ListElement { name: "WezTerm"; desc: "GPU-accelerated terminal emulator"; icon: "terminal"; badge: "Alt+1" }
                        ListElement { name: "Firefox Developer"; desc: "Web Browser"; icon: "language"; badge: "Alt+2" }
                        ListElement { name: "Neovim"; desc: "Hyperextensible Vim-based text editor"; icon: "code"; badge: "Alt+3" }
                        ListElement { name: "System Settings"; desc: "Configure Material 3 Quickshell DE"; icon: "tune"; badge: "Alt+4" }
                    }
                    delegate: M3Surface {
                        required property int index
                        required property string name
                        required property string desc
                        required property string icon
                        required property string badge
                        readonly property bool isSelected: index === launcherWindow.selectedIndex

                        Layout.fillWidth: true
                        implicitHeight: 54
                        interactive: true
                        customColor: isSelected ? Tokens.color.secondaryContainer : "transparent"
                        contentColor: isSelected ? Tokens.color.onSecondaryContainer : Tokens.color.onSurface
                        cornerRadius: isSelected ? 27 : Tokens.shape.lg
                        onClicked: launcherWindow.selectedIndex = index

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 16
                            spacing: 12

                            Text {
                                text: icon
                                font.family: Tokens.typography.familyIcons
                                font.pixelSize: 24
                                color: isSelected ? Tokens.color.onSecondaryContainer : Tokens.color.primary
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    text: name
                                    font.family: Tokens.typography.bodyLarge.family
                                    font.pixelSize: Tokens.typography.bodyLarge.pixelSize
                                    font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    color: isSelected ? Tokens.color.onSecondaryContainer : Tokens.color.onSurface
                                }
                                Text {
                                    text: desc
                                    font.family: Tokens.typography.bodySmall.family
                                    font.pixelSize: Tokens.typography.bodySmall.pixelSize
                                    color: isSelected ? Tokens.color.onSecondaryContainer : Tokens.color.onSurfaceVariant
                                }
                            }
                            Text {
                                text: badge
                                font.family: Tokens.typography.labelSmall.family
                                font.pixelSize: Tokens.typography.labelSmall.pixelSize
                                font.features: Tokens.typography.tabularFeatures
                                color: isSelected ? Tokens.color.onSecondaryContainer : Tokens.color.onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }
}
```
