# Shell Component 14 — Wallpaper & Material You Theme Studio

> **Module**: `design-system/shell-components/14-wallpaper-and-theme-picker.md`
> **Component ID**: `SC-14`
> **Primitives Used**: `M3Surface`, `M3SegmentedButton`, `M3FilterChip`, `M3Button`, `M3ScrollBar`

---

## 1. Purpose & Wayland Layer Config

The **Wallpaper & Material You Theme Studio** (`Super+W`) is the live personalization drawer for the desktop environment. It lets the user browse wallpapers with an M3 Expressive horizontal carousel, preview and apply `matugen` HCT color schemes (`TonalSpot`, `Vibrant`, `Expressive`, `Content`, `Neutral`, `Monochrome`, and more), and toggle **Dark/Light Polarity**, **Frosted Glass vs. Opaque Tonal Surfaces**, **Tiling vs. Floating Desktop Mode**, and **bar presets** with zero restart. Detailed customisation of every setting lives in Settings (`SC-16`); the Studio is the quick, visual subset.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-theme-studio"` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` |
| **Anchors** | `bottom: true; left: true; right: true` |
| **Drawer Dimensions** | `width: min(920px, screenWidth - 32px)`, `height: 360px`, anchored `16px` above bottom screen edge |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.Exclusive`** |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Keyboard Carousel Navigation** | `Left`/`Right` (or `h`/`l`) scrolls the M3 Expressive asymmetric wallpaper carousel; `Enter` applies wallpaper via `swww` + runs `matugen`; `Tab` moves to the scheme chips (`TonalSpot`, `Vibrant`, `Expressive`, `Neutral`, `Monochrome`) | Identical keyboard bindings in both modes, alongside mouse click, drag-scroll carousel, and segmented toggles |
| **Compositor Border Sync** | Applying a wallpaper automatically updates Hyprland/Niri active window border color (`hyprctl keyword general:col.active_border "rgba(${primary}ee)"`) | Updates GTK4/Qt6 theme tokens and shell surfaces |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭───────────────────────────────────────────────────────────────────────────────────────────╮
│  󰸉  Wallpaper & Material You Studio          ╭───────────────╮ ╭────────────────────────╮ │
│                                              │ 󰖔 Dark│󰖙 Light│ │ 󰖯 Glass │ 󰝤 Opaque     │ │
│  ───────────────────────────────────────────────────────────────────────────────────────  │
│  ╭──────────────────────────╮  ╭──────────────╮  ╭──────────────╮  ╭──────────────╮       │  M3 Expressive Carousel
│  │                          │  │              │  │              │  │              │       │  Selected card expands
│  │   [Active Wallpaper]     │  │  [Preview 2] │  │  [Preview 3] │  │  [Preview 4] │       │  width: 240px -> 320px!
│  │    Aurora Mountain       │  │  Cyber Neon  │  │  Solar Dune  │  │  Sakura Mist │       │
│  │  ╭───┬───┬───┬───╮  󰄬    │  │  ╭──┬──┬──╮  │  │  ╭──┬──┬──╮  │  │  ╭──┬──┬──╮  │       │  4-quadrant HCT swatch
│  │  ╰───┴───┴───┴───╯       │  │  ╰──┴──┴──╯  │  │  ╰──┴──┴──╯  │  │  ╰──┴──┴──╯  │       │
│  ╰──────────────────────────╯  ╰──────────────╯  ╰──────────────╯  ╰──────────────╯       │
│  ───────────────────────────────────────────────────────────────────────────────────────  │
│  Scheme: ╭──────────────╮ ╭───────────╮ ╭──────────────╮ ╭───────────╮ ╭──────────────╮   │
│          │ ● Tonal Spot │ │  Vibrant  │ │  Expressive  │ │  Neutral  │ │  Monochrome  │   │
│          ╰──────────────╯ ╰───────────╯ ╰──────────────╯ ╰───────────╯ ╰──────────────╯   │
│  Paradigm: [ 󰖯 Tiling Mode (Hyprland) | 󰇄 Floating Desktop ]   Bars: [Preset ▾] [⚙ Edit…] │
│  ───────────────────────────────────────────────────────────────────────────────────────  │
│  DESKTOP WIDGETS & ICON STUDIO (SC-15 Manager)     Scale: [0.75x|0.9x|•1.0x|1.25x|1.5x]  │
│  ╭──────────────────────────────╮ ╭──────────────────────────────╮ ╭────────────────────╮ │
│  │ 󰥔 Clock       [Style 1/2/3]  │ │ 󰎆 Petal Media [Style 1/2/3]  │ │ 󰖙 Weather [1/2/3]  │ │
│  │   [✓ Applied]  [Remove]      │ │   [✓ Applied]  [Remove]      │ │   [✓ Applied]      │ │
│  ╰──────────────────────────────╯ ╰──────────────────────────────╯ ╰────────────────────╯ │
╰───────────────────────────────────────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Border Token | Typography / Metric Token |
|---|---|---|---|
| **Studio Root Drawer** | `Tokens.color.surfaceTier(0)` | `1px` `Tokens.color.surfaceBorder(0)` | `width: 920px`, `height: 360px`, `radius: xxl (28px)`, `padding: 20px` |
| **Carousel Item (Focused)** | Wallpaper image + bottom gradient scrim | **`3px` `Tokens.color.primary` border** | **`width: 280px`**, `height: 156px`, `radius: xl (24px)` |
| **Carousel Item (Adjacent)** | Wallpaper image @ `85%` opacity | `1px` `outlineVariant` | **`width: 160px`**, `height: 156px`, `radius: lg (16px)` |
| **4-Quadrant HCT Swatch Circle** | Q1: `primary`, Q2: `secondary`, Q3: `tertiary`, Q4: `surfaceContainerHighest` | `2px` `surface` border | `32px × 32px` circle anchored bottom-left of wallpaper card |
| **Scheme Variant Chip** | Selected: `secondaryContainer`; Idle: `surfaceTier(2)` | Selected: `onSecondaryContainer`; Idle: `onSurfaceVariant` | `height: 32px`, `radius: full`, `labelMedium` |

---

## 5. Interactive State Matrix

| User Action | Immediate Response |
|---|---|
| **Focus / Select Wallpaper Card** | Expands the focused card width `160px -> 280px` via `Tokens.motion.springDefaultSpatial` (M3 Carousel Hero Layout) and previews its palette on the drawer (`matugen image <path> --dry-run --json hex` — nothing is written). Applying (`Enter` or clicking the focused card) runs `swww img <path>` (the shell owns the transition), then the full `ThemeService` matugen command (§7). |
| **Click Scheme Variant Chip** | Sets `Tokens.schemeVariant` and re-runs matugen with `-t scheme-<variant>`. `ColorTokens` reloads `theme.json`; surfaces crossfade through their own `Behavior on color` (`springDefaultEffects`, `220ms`). Chips: `Tonal Spot`, `Vibrant`, `Expressive`, `Content`, `Neutral`, `Monochrome`, plus `Fidelity`, `Rainbow`, and `Fruit Salad` under **More**. |
| **Toggle Dark / Light** | Instant: `ColorTokens` switches between the `dark` and `light` blocks already in `theme.json`. matugen re-runs only if extra `.default` templates (GTK, terminals) are installed. |
| **Toggle `Frosted Glass` / `Opaque Tonal`** | Invokes `Tokens.setSurfaceMode(mode)` — every open panel and bar transitions its background alpha and border contrast live. |
| **Toggle `Tiling` / `Floating`** | Invokes `Tokens.setDesktopMode(mode)`; bar widgets swap their mode variants and `auto`-visibility bars switch dodge policy live. |
| **Bars Preset / Edit…** | The preset menu applies an `SC-01` §1.2 preset (with Undo); `Edit…` opens Settings → Bars (`ShellState.openSettings("bars")`) for full per-bar configuration. |
| **Undo Last Change** | Every applied wallpaper, scheme, polarity, surface, bar-layout, or icon change shows a `"Theme updated · Undo"` snackbar (`inverseSurface`, `8s`). `Undo` calls `ThemeService.undoLastTheme()`, restoring the previous wallpaper and `theme.json`, so experimenting is never risky. |
| **Preview vs. Apply** | `Space` (or a single click on a non-focused card) previews a wallpaper's palette on the Studio drawer only; `Enter` (or clicking the focused card) applies it system-wide. |

---

## 6. Motion & Morph Choreography

1. **M3 Expressive Multi-Browse Carousel**: As the user navigates across wallpapers, the focused item expands horizontally to `280px` (`radius: 24px`), immediate neighbors compress to `160px` (`radius: 16px`), and edge peek items compress to `72px` (`radius: 12px`) using `Tokens.motion.springDefaultSpatial`.
2. **Radial Wallpaper Wipe (`swww`)**: Triggering a wallpaper change coordinates a `120fps` circular grow transition centered at the clicked card's screen coordinates (`--transition-pos <normX>,<normY>`).

---

## 7. Quickshell Service & IPC Bindings

- **Wallpaper & Theme Generator (`Quickshell.Io.Process`)**:
  - `matugen image <wallpaperPath> -c ~/.config/mat-shell/matugen/config.toml -t <Tokens.schemeVariant> --source-color-index 0 [--contrast 1.0 when Tokens.highContrast] [-m <dark|light> only for extra .default templates]`
  - Requires matugen ≥ 4.0; the full integration contract is in `01-color-and-surfaces.md` §1.3. Non-zero exit keeps the previous `theme.json` and raises a toast with matugen's stderr.
  - Before each apply, `ThemeService` copies the current `theme.json` and wallpaper path to `~/.cache/mat-shell/theme.prev.json`, which `undoLastTheme()` restores.
- **Live Theme Watcher (`Quickshell.Io.FileView`)**:
  - Watches `~/.config/mat-shell/theme.json` (`watchChanges: true`), parsing JSON via `JsonAdapter` directly into `ColorTokens.qml`.

---

## 8. Canonical QML Reference Skeleton (`WallpaperThemePicker.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: studioWindow
    visible: ShellState.activeModal === "theme_studio"
    WlrLayershell.namespace: "mat-theme-studio"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property int focusedIndex: 0

    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.closeActiveModal()
    }

    M3Surface {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: Tokens.metrics.screenMargin + 8
        width: 880
        implicitHeight: 340
        tier: 0
        cornerRadius: Tokens.shape.xxl

        Keys.onEscapePressed: ShellState.closeActiveModal()
        Keys.onRightPressed: focusedIndex = Math.min(3, focusedIndex + 1)
        Keys.onLeftPressed: focusedIndex = Math.max(0, focusedIndex - 1)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: Tokens.metrics.spaceMd

            // Header + Mode Switches
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Wallpaper & Material You Studio"
                    font.family: Tokens.typography.titleLarge.family
                    font.pixelSize: Tokens.typography.titleLarge.pixelSize
                    font.weight: Font.DemiBold
                    color: Tokens.color.onSurface
                }
                Item { Layout.fillWidth: true }

                M3Surface {
                    implicitWidth: 132; implicitHeight: 34
                    tier: 2; interactive: true; cornerRadius: Tokens.shape.full
                    onClicked: Tokens.toggleDarkMode()
                    Text {
                        anchors.centerIn: parent
                        text: Tokens.darkMode ? "Dark Mode" : "Light Mode"
                        font.family: Tokens.typography.labelLarge.family
                        font.pixelSize: Tokens.typography.labelLarge.pixelSize
                        color: Tokens.color.onSurface
                    }
                }

                M3Surface {
                    implicitWidth: 156; implicitHeight: 34
                    tier: 2; interactive: true; cornerRadius: Tokens.shape.full
                    onClicked: Tokens.setSurfaceMode(Tokens.isGlass ? "opaque_tonal" : "frosted_tonal_glass")
                    Text {
                        anchors.centerIn: parent
                        text: Tokens.isGlass ? "Frosted Glass" : "Opaque Tonal"
                        font.family: Tokens.typography.labelLarge.family
                        font.pixelSize: Tokens.typography.labelLarge.pixelSize
                        color: Tokens.color.onSurface
                    }
                }
            }

            // M3 Expressive Asymmetric Carousel
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 164
                spacing: Tokens.metrics.spaceSm

                Repeater {
                    model: ListModel {
                        ListElement { title: "Aurora Violet"; seedColor: "#7C4DFF" }
                        ListElement { title: "Cyber Emerald"; seedColor: "#00C853" }
                        ListElement { title: "Solar Amber"; seedColor: "#FF8F00" }
                        ListElement { title: "Sakura Rose"; seedColor: "#FF4081" }
                    }
                    delegate: M3Surface {
                        required property int index
                        required property string title
                        required property string seedColor
                        readonly property bool isHero: index === studioWindow.focusedIndex

                        Layout.preferredWidth: isHero ? 280 : 170
                        Layout.fillHeight: true
                        interactive: true
                        customColor: seedColor
                        cornerRadius: isHero ? Tokens.shape.xl : Tokens.shape.lg
                        border.width: isHero ? 3 : 1
                        border.color: isHero ? Tokens.color.primary : Tokens.color.surfaceBorder(1)
                        onClicked: studioWindow.focusedIndex = index

                        Behavior on Layout.preferredWidth {
                            SpringAnimation {
                                spring: Tokens.motion.springDefaultSpatial.spring
                                damping: Tokens.motion.springDefaultSpatial.damping
                            }
                        }

                        Text {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.margins: 14
                            text: title
                            font.family: Tokens.typography.titleSmall.family
                            font.pixelSize: Tokens.typography.titleSmall.pixelSize
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }
                }
            }
        }
    }
}
```
