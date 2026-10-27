# Shell Component 02 — Bar Widget Catalog

> **Module**: `design-system/shell-components/02-bar-widgets.md`
> **Component ID**: `SC-02`
> **Primitives Used**: `M3BarPill`, `M3AppIcon`, `M3PolygonSurface`, `M3Surface`, `M3Divider`, `M3Tooltip`, `M3ContextMenu`
> **Hosted by**: `01-bar-system.md` (`SC-01`) · **Picked in**: `16-settings.md` (`SC-16`, Settings → Bars → Widgets)

---

## 1. Purpose & Wayland Layer Config

Bar widgets are the building blocks users place into a bar's **start / center / end** sections. A widget is not a window: it renders inside its host bar's `PanelWindow` and inherits that bar's layer (`WlrLayer.Top`), namespace (`mat-bar-<id>`), keyboard focus policy, and input mask. Each widget adapts to the host bar's **orientation** (horizontal on top/bottom bars, vertical on left/right bars) and **thickness**, and opens its popover or overlay from its own position (`ShellState.togglePopover(name, item)`).

### 1.1 Widget Registry

| `type` | Name in Settings | Function | Opens | Customisable (§1.3) | Vertical Variant | Overflow Priority |
|---|---|---|---|---|---|---|
| `launcher` | Launcher | App/command launcher trigger | `SC-08` Launcher | Yes | Same | Never hidden |
| `search` | Search | Search field pill (`width: 148px`) | `SC-08` Launcher | Yes | Collapses to the search icon | 2 |
| `workspaces` | Workspaces | Morphing workspace strip (§3.1) | Overview (middle-click) | Yes | Column strip; the focused pill grows in height | Never hidden |
| `submap` | Keybinding mode | Transient compositor submap badge (`RESIZE`) | — | No | Rotated to a `tertiary` dot with tooltip | Never hidden (transient) |
| `windowTitle` | Window title | Focused app icon + title + tiling flags (floating: app menu) | App context menu | Yes | Icon only, title in tooltip | 1 (elides `260 → 160 → icon`) |
| `media` | Media | MPRIS title pill / art well with progress ring | `SC-06` Media | Yes | Art well only | 3 (collapses to icon well) |
| `clock` | Clock & calendar | Date and time pill (`tnum`) | `SC-05` Calendar & Weather | Yes | Stacked `HH` / `mm` | Drops the date, then the weekday |
| `controlCenter` | Control center | Quick-settings capsule (Wi-Fi, BT, volume, battery glyphs) | `SC-03` Control Center | Yes | Glyph column, no percentages | Never hidden |
| `notifications` | Notifications | Bell with unread count; middle-click toggles Do Not Disturb | `SC-04` Notification Center | Yes | Same | Never hidden |
| `tray` | System tray | StatusNotifier items | Item menus | Yes | Column of icons | 4 (collapses to chevron) |
| `privacy` | Privacy indicator | Mic/camera/screen-share pill (transient) | Privacy popover | No (security) | Green dot pill | **Never hidden** (security) |
| `recording` | Recording indicator | Active recording timer pill (transient) | `SC-13` stop/controls | No (security) | Red dot with stacked timer | **Never hidden** (security) |
| `telemetry` | System monitor | CPU / RAM / GPU / disk / network pill (`tnum`) | Control Center telemetry page | Yes | Stacked values | 5 (hidden first) |
| `keyboardLayout` | Keyboard layout | Current layout code (`EN`) | Layout menu | Yes | Same | 4 |
| `power` | Power | Power button | `SC-11` Power Menu | No | Same | Never hidden |
| `apps` | Apps (dock / taskbar) | Pinned + running app wells with indicators (§3.2) | Window previews, app menus | Yes | Column of wells | Trailing overflow chevron (icons never shrink below `iconSm`) |
| `widgetPeek` | Desktop widgets | `scallop_12` Widget Peek trigger (only when desktop widgets are enabled) | `SC-15` Widget Peek | No | Same | 3 |
| `settings` | Settings | Gear button | `SC-16` Settings | No | Same | 4 |
| `separator` | Separator | `1px` divider between groups | — | No | Horizontal rule | — |
| `spacer` | Spacer | Gap inside a section | — | Yes | Same | — |

Unknown `type` values (e.g., from a newer config) render nothing, log a warning, and are preserved on save.

### 1.2 Widget Options Contract — How to Make a Widget Customisable

Every customisable widget follows one contract, so options look and behave the same everywhere and Settings never needs widget-specific UI code. A widget **declares** its options as a schema; Settings **renders** them generically (`16-settings.md` §3.2, the widget options panel); the widget **reads** them through one resolver.

**Step 1: Pass the eligibility test.** A widget gets options (and an edit icon in Settings) only if **all** of these hold:

| # | Test | Fails → |
|---|---|---|
| E1 | The variation is something users reasonably want to differ **per bar or per screen** (what a control center shows, how a clock reads). | It belongs in a global Settings page, not in the widget (e.g. Do Not Disturb, theme). |
| E2 | It changes **content or presentation**, not what the widget *is* or does on click. | Make it a different widget type. |
| E3 | Every value can be **previewed live** on the real bar. | Redesign the option or drop it. |
| E4 | No value can hide or weaken a **security or core signal** (privacy, recording, the power path). | The widget gets no options (`privacy`, `recording`, `power`). |
| E5 | The widget has at least one option that passes E1–E4. | No edit icon (`submap`, `widgetPeek`, `settings`, `separator`). |

**Step 2: Declare a schema** in `BarWidgetRegistry` (`optionsSchema`: an ordered array of fields). Each field:

| Property | Required | Meaning |
|---|---|---|
| `key` | yes | Stable camelCase key in `options` (never reuse a removed key) |
| `kind` | yes | One of the field kinds below; no other UI is allowed |
| `label` | yes | Sentence case, at most 3 words ("Shown items", "Time format") |
| `default` | yes | Value used when the key is absent; must itself be valid |
| `help` | no | One short line under the label, only when the label can't carry it |
| `choices` | `choice`, `multiChoice` | `[{ value, label, icon? }]`; icons strongly preferred for `multiChoice` |
| `min` / `max` / `step` / `unit` | `number`; `min` / `max` also for `multiChoice` | Bounds; `multiChoice` must set `min ≥ 1` when an empty selection would leave the widget empty |
| `maxLength` | `text`, `format` | Character limit, enforced while typing |
| `visibleWhen` | no | Condition on another key (`{ key, equals \| notEquals \| includes }`), evaluated on the **resolved** values for the bar's orientation; hidden fields keep their values |
| `orientations` | no | `"both"` (default), `"horizontal"`, or `"vertical"`. On the other orientation the field is shown **disabled** with the reason ("Horizontal bars only"), never hidden, so it never looks like the setting vanished; the resolver returns its `default` there |
| `group` | no | Heading for related fields (max 3 groups per widget) |

**Field kinds** (the complete set; each maps to one primitive):

| `kind` | Value | Control | Rules |
|---|---|---|---|
| `toggle` | `bool` | `M3Switch` row | Label states the "on" meaning ("Show percentages") |
| `choice` | one `value` | `M3SegmentedButton` (≤ 4 choices) or a select menu (5+) | Choices are mutually exclusive presentations |
| `multiChoice` | ordered `value[]` | Checklist with icons; checked items reorder with drag or `Alt+↑/↓`; order = display order on the bar | Honour `min` / `max`; unchecking the last allowed item is disabled with a reason |
| `number` | `number` | `M3Slider` + value label (`tnum`) | Always bounded; unit shown |
| `text` | `string` | `M3TextField` | `maxLength`; applied after `300ms` idle |
| `format` | `string` (Qt date/time pattern) | Text field + live sample of the result + token reference in its tooltip | Usually paired with a preset `choice` and `visibleWhen: preset = custom`; an invalid pattern keeps the last valid one and shows the error under the field |
| `appList` | `string[]` (desktop IDs) | Reorderable list + "Add app" picker (launcher search) | Same data as Pin / Unpin in the app context menu |

**Step 3: Read options through the resolver.** The widget never reads `options.x` directly; it uses `BarWidgetRegistry.resolve(type, options, orientation)`. The resolver merges defaults, drops unknown keys from the *view* (they are still preserved on save), clamps out-of-range values, and applies the field's orientation. Settings writes **only values that differ from the default**, so configs stay small and future default improvements reach users who never changed a field.

**Step 4: Meet the rendering rules.** Every valid combination of options must:
- fit the bar's thickness bounds on both orientations, and keep `minPointerTarget`;
- keep the widget's overflow priority (options may make it wider, never "never hidden");
- use `tnum` on every live number, and never change width on hover;
- update live, within one frame, when Settings changes a value (no reload, no restart).

**Step 5: Version it.** Renaming or reshaping a key requires an entry in `BarWidgetRegistry.migrations[type]` (old config → new config), run when `config.json` loads. Example: `clock.showDate: false` → `clock.preset: "time"`.

### 1.3 Options Catalog

| Widget | Field (`key` · `kind`) | Choices / range | Default |
|---|---|---|---|
| **`controlCenter`** | Shown items (`items` · `multiChoice`, `min: 1`) | `network`, `bluetooth`, `volume`, `microphone`, `brightness`, `battery`, `powerProfile`, `dnd`, `nightLight`, `vpn` | `network, bluetooth, volume, battery` |
| | Show percentages (`showPercentages` · `toggle`, horizontal) | — | `true` |
| **`telemetry`** | Shown stats (`metrics` · `multiChoice`, `min: 1`, `max: 4`) | `cpu`, `ram`, `gpu`, `temperature`, `disk`, `netDown`, `netUp`, `swap` | `cpu, ram` |
| | Labels (`labelStyle` · `choice`) | Icons, Text (`CPU`), None | Icons |
| | Update every (`interval` · `choice`) | `1s`, `2s`, `5s` | `2s` |
| | Disk (`diskMount` · `text`, `visibleWhen: metrics includes disk`) | Mount point | `/` |
| **`clock`** | Format (`preset` · `choice`, horizontal) | `time` · `weekdayTime` · `dateTime` · `fullDate` · `custom` | `dateTime` |
| | Hours (`hourCycle` · `choice`, `visibleWhen: preset ≠ custom`) | `system`, `24h`, `12h` | `system` |
| | Show seconds (`showSeconds` · `toggle`, `visibleWhen: preset ≠ custom`) | — | `false` |
| | Custom pattern (`customFormat` · `format`, `visibleWhen: preset = custom`) | Qt pattern with live sample | `ddd d MMM  HH:mm` |
| **`workspaces`** | Style (`style` · `choice`) | Numbers, Dots, Pills, App icons | Numbers |
| | Count (`count` · `number`) | `1..10` | `5` |
| | Show empty (`showEmpty` · `toggle`) | — | `true` |
| | Scope (`scope` · `choice`) | This screen, All screens | This screen |
| **`apps`** | Pinned apps (`pinned` · `appList`) | Desktop IDs | `[]` (the distribution's set is written on first run) |
| | Show running apps (`showRunning` · `toggle`) | — | `true` |
| | Window titles (`showLabels` · `toggle`, horizontal) | — | `false` |
| | Icon size (`iconSize` · `choice`) | Auto, Small, Medium, Large | Auto |
| **`media`** | Content (`content` · `choice`) | Title + artist, Title, Art only | Title + artist |
| | Inline controls (`showControls` · `toggle`, horizontal) | Previous / Play / Next | `false` |
| **`windowTitle`** | Content (`content` · `choice`) | Title, App name, Both | Title |
| | Max width (`maxWidth` · `number`, horizontal) | `120..400 px` | `260` |
| **`notifications`** | Unread count (`showCount` · `toggle`) | — | `true` |
| **`tray`** | Layout (`mode` · `choice`) | Inline, Drawer (chevron) | Inline |
| **`keyboardLayout`** | Display (`display` · `choice`) | Code (`EN`), Name (`English`) | Code |
| **`launcher`** | Icon (`icon` · `choice`) | Apps, Grid, Search, Distro logo | Apps |
| | Label (`showLabel` · `toggle`, horizontal) | — | `true` |
| **`search`** | Placeholder (`placeholder` · `text`) | ≤ 24 characters | `Search…` |
| **`spacer`** | Size (`size` · `number`) | `4..64 px` | `12` |

The same catalog is machine-readable in `tokens/m3-tokens.json` → `modes.bars.widgetOptions` (migrations in `widgetOptionMigrations`), which `scripts/verify-design-system.sh` checks against these rules: known kinds, valid defaults and bounds, `visibleWhen` targets, label length, and that exactly the widgets marked **Yes** in §1.1 declare options.

### 1.4 Adding Options to a Widget — Checklist

1. Run the eligibility test (§1.2 Step 1); record a failed test in the §1.1 *Customisable* column ("No (security)").
2. Add the fields to `modes.bars.widgetOptions.<type>` and to the §1.3 table, in display order.
3. Read every value through `BarWidgetRegistry.resolve()` and render each combination on all four edges at minimum and maximum thickness.
4. Add a migration for every renamed or reshaped key.
5. Run `scripts/verify-design-system.sh`.

No Settings code changes: the edit icon appears on the widget's chip as soon as its schema is non-empty (`16-settings.md` §3.2 item 8).

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Widget | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **`launcher`** | `options.icon` glyph only, tooltip `"Apps (Super)"` | `options.icon` glyph + `"Apps"` label (when `showLabel`) on horizontal bars with thickness ≥ `40` |
| **`workspaces`** | Full strip | Collapses to an Overview button when only one workspace exists |
| **`windowTitle`** | Title + tiling flags (floating / pseudo / fullscreen) | Focused app icon + name; click opens the app menu |
| **`apps`** | Click on the focused app cycles its windows | Click on the focused app minimizes it (cycles with several windows); end cap shows minimized windows |
| **`clock`** | Unchanged | Unchanged |

### 2.1 Overflow Order

When a bar section runs out of room, widgets degrade in ascending priority number (`1` first) from §1.1, and each step reverts as soon as space returns. Widgets marked **Never hidden** keep their place, and the overflow chevron (`SC-01` §2.1 rule 6) lists anything collapsed. Security indicators (`privacy`, `recording`) never collapse and never defer their appearance.

---

## 3. Visual Anatomy & ASCII Layout

```text
 HORIZONTAL VARIANTS (bar thickness 40)                                   VERTICAL VARIANTS (bar thickness 56)
 ╭────╮ ╭───────────────────────╮ ╭──────────╮ ╭──────────────────────╮    ╭──────╮
 │ 󰣇  │ │ (1) (2) [  3 •  ] (4) │ │ 󰩨 RESIZE │ │ 󰈹 Design Spec — Fire… │    │  󰣇   │ launcher
 ╰────╯ ╰───────────────────────╯ ╰──────────╯ ╰──────────────────────╯    │ (1)  │ workspaces
  launcher   workspaces              submap        windowTitle             │ ┃3┃  │   (focused grows in height)
 ╭──────────────╮ ╭───────────────╮ ╭──────────────╮ ╭─────╮ ╭────╮         │ (4)  │
 │ 󰎆 Midnight C… │ │ 󰤨 󰂯 󰕾 72% 󰁹 │ │ Mon 26 17:53 │ │ 󰍬•  │ │ 󰂚 3│         │  󰈹   │ windowTitle (icon only)
 ╰──────────────╯ ╰───────────────╯ ╰──────────────╯ ╰─────╯ ╰────╯         │ ◐󰎆   │ media (art well + ring)
   media            controlCenter      clock          privacy notifications │ 󰤨 󰕾 │ controlCenter (glyph column)
                                                                            │  17  │ clock (stacked)
 apps (island, fit length — "the dock")                                     │  53  │
 ╭──────────────────────────────────────────────────╮                       │ 󰂚 3  │ notifications
 │ ╭────╮  ╭────╮  ╭────╮  ╭────╮  ║  ╭────╮         │                       ╰──────╯
 │ │ 󰈹  │  │ 󰨞  │  │ 󰙯  │  │ 󰉋  │  ║  │ 󰓇  │         │
 │ ╰────╯  ╰────╯  ╰────╯  ╰────╯  ║  ╰────╯         │
 │ [━━━━]   ••      •               ║   •            │  pinned ║ running-unpinned
 ╰──────────────────────────────────────────────────╯
```

### 3.1 Workspace Strip Anatomy (`workspaces`)
- **Empty Workspace**: `8px` dot (`outlineVariant` @ `50%`), shown only with `showEmpty`.
- **Occupied Inactive**: `16 × 20px` pill (`secondaryContainer`, `labelSmall` with `tnum`).
- **Focused**: expands along the bar axis to a `36 × 20px` capsule (`primary` / `onPrimary`); in vertical bars to `20 × 36px`. Focus is carried by size and colour together.
- **Urgent**: `20px` squircle (`radius: 6px`, `tertiaryContainer`) that pulses `1.0 ↔ 1.08` three times, then holds a static `tertiary` badge (no pulse under Reduced Motion).
- **Hit Cells**: contiguous cells `max(visual + 6px, 24px)` along the bar axis, spanning the full bar thickness plus the edge margin; no dead gaps.

### 3.2 Apps Anatomy (`apps` — dock or taskbar)
- **Wells**: `M3AppIcon`, size `auto` = `bar.thickness − 2 × barPadding − 8` (clamped `iconSm..56px`), themed per `Tokens.themedIcons`.
- **Indicators** (on the side facing the screen centre): focused = `16 × 4px` `primary` pill; running = `5 × 4px` `secondary` dot; 2+ windows = two dots (`3px` gap).
- **Taskbar labels**: `showLabels` adds the window title beside each well on horizontal bars (max `160px`), turning the widget into a classic taskbar.
- **Order**: pinned apps, then a divider, then running unpinned apps; minimized windows show in floating mode.

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Metric Token |
|---|---|---|---|---|
| **Generic Widget Pill** | `Tokens.color.surfaceTier(2)` (`primaryContainer` when its popover is open) | `onSurface` (`onPrimaryContainer` when open) | `labelLarge` / `labelMedium` (`tnum` on live numbers) | `height: barPillHeight` (`thickness − 2 × barPadding`), `radius: morphPillRadius` |
| **Workspace Trough** | `Tokens.color.surfaceTier(3)` | `onSurfaceVariant` | `labelSmall` (`tnum`) | `barPillHeight`, `radius: full`, `padding: 4px` |
| **Focused Workspace** | `Tokens.color.primary` | `Tokens.color.onPrimary` | `labelSmall` (`600`, `tnum`) | `36 × 20px` (vertical `20 × 36px`) |
| **Submap Badge** | `Tokens.color.tertiaryContainer` | `onTertiaryContainer` | `labelSmall` (`600`) | `height: 24px`, `radius: sm` |
| **Privacy Pill** | `Tokens.color.privacyMicCam` | `Tokens.color.onPrivacyMicCam` | `labelMedium` (`600`) | `height: 26px`, `radius: full` |
| **Recording Pill** | `Tokens.color.errorContainer` | `onErrorContainer` | `labelMedium` (`tnum`) | `height: 26px`, `radius: full` |
| **App Well (hover / press)** | `Tokens.color.surfaceTier(2)` | State layer `onSurface` `8%` / `12%` | — | `radius: morphTileRadius` |
| **Focused App Indicator** | `Tokens.color.primary` | — | — | `16 × 4px`, `radius: full` |
| **Running Indicator** | `Tokens.color.secondary` | — | — | `5 × 4px`, `radius: full` |
| **Window Preview Card** | `Tokens.color.surfaceTier(1)` | `onSurface`, `1px` `surfaceBorder(1)` | `labelMedium` header | `200 × 136px`, `radius: lg` |
| **Tooltips** | `Tokens.color.inverseSurface` | `inverseOnSurface` | `labelMedium` | Placed on the side facing the screen centre |

---

## 5. Interactive State Matrix

| Widget | Idle | Hovered | Pressed | Active (popover open) | Scroll Wheel (accumulated) |
|---|---|---|---|---|---|
| **`launcher`** | `surfaceTier(2)` | `+8%` state layer, tooltip `"Apps (Super)"` | `radius: md`, `scale: 0.96` | `primary` / `onPrimary` | — |
| **`workspaces`** | Trough `surfaceTier(3)` | Hovered pill scales `1.2×` inside its fixed cell | Pill squishes to `radius: sm`; middle-click toggles Overview | Focused pill grows | Previous / next workspace per notch (natural scrolling respected) |
| **`media`** | Album-art tinted `secondaryContainer` | Rich tooltip with artist and album (width unchanged) | `radius: md` | Morphs into `SC-06` | Player volume `±5%` (physical direction) |
| **`controlCenter`** | Live glyphs (signal, mute, charging) | Tooltip `"Wi-Fi Home-5G · Volume 72% · Battery 86%, 4h 12m"` | `radius: md` | Morphs into `SC-03` | Master volume `±2%` with OSD (physical direction) |
| **`clock`** | `surfaceTier(2)` | Tooltip with the full date | `radius: md` | Morphs into `SC-05` | — |
| **`notifications`** | Unread count badge (`tertiary`) | Bell swings `±12°` once (static under Reduced Motion) | `radius: md` | Opens `SC-04` | — ; middle-click toggles DND with OSD confirmation |
| **`apps` well** | Icon `1.0×`, indicator | Lifts `4px` toward the screen centre and scales `1.08×` (neighbours never move); tooltip after `450ms`, live preview after `350ms` for running apps | `radius: md`, `scale: 0.94` | Preview/menu open | — |
| **`power`** | `surfaceTier(2)` | Tooltip `"Power & session (Super+Esc)"` | `radius: md` | Opens `SC-11` | — |

Right-clicking any widget opens its context menu (`04-interaction-states-and-input.md` §2.1), which always ends with `Configure bar…` and `Remove from bar` (with an Undo snackbar). Middle-click and scroll are accelerators only, never destructive.

---

## 6. Motion & Morph Choreography

1. **Workspace Morph**: On focus change, the old pill contracts `36 → 16px` and the new pill expands `16 → 36px` along the bar axis via `Tokens.motion.springFastSpatial`.
2. **Privacy Pill**: Appears immediately on capture start and expands to `"󰍬 Mic in use • Firefox"` (`springDefaultSpatial`), holds `3000ms`, then compacts to a `32px` icon pill. The collapse is deferred while the pointer is inside the section so nothing moves under the cursor.
3. **Running Indicator**: Dot-to-pill morph (`5 → 16px`, `secondary → primary`) when an app gains focus (`springFastSpatial` + `springFastEffects`).
4. **Launch Bounce**: Two damped hops of `12px` toward the screen centre on launch; under Reduced Motion the indicator just fades in.
5. **Submap Entrance**: Pops in `scale 0.6 → 1.0` (`springFastSpatial`).

---

## 7. Quickshell Service & IPC Bindings

- **`workspaces` / `windowTitle`**: `Quickshell.Hyprland.workspaces`, `.focusedWorkspace`, `.focusedMonitor`; `ToplevelManager.activeToplevel.title` / `.appId` (Niri/Sway equivalents via `CompositorService`).
- **`media`**: `Mpris.players` → `.trackTitle`, `.trackArtist`, `.trackArtUrl`, `.position`, `.togglePlaying()`.
- **`controlCenter`**: `NetworkService`, `BluetoothService`, `AudioService` (`Pipewire.defaultAudioSink`), `UPower.displayDevice`.
- **`privacy` / `recording`**: `Pipewire.nodes` capture streams; `CaptureService.recording`.
- **`tray`**: `SystemTray.items` → `.icon`, `.activate()`, `.secondaryActivate()`, `.menu`.
- **`apps`**: `DesktopEntries` (pinned IDs), `ToplevelManager.toplevels` (running), `ScreencopyView` (previews, only while visible); pinned order persists in the widget's `options.pinned`.
- **Popover origin**: Every popover-opening widget calls `ShellState.registerTrigger(name, item)` once per instance; `togglePopover(name, item)` passes the clicked instance so the popover grows out of it toward the screen centre (`SC-01` §7).

---

## 8. Canonical QML Reference Skeleton (`BarWidgetLoader.qml` & `ClockWidget.qml`)

```qml
import QtQuick
import Quickshell
import MatShell.Tokens

// BarWidgetLoader.qml — resolves a config entry to its widget component
Loader {
    id: root
    required property string type
    required property var options
    required property var bar
    required property bool vertical

    // Pill size follows the bar's own thickness; edge reach spans from the pill to the physical screen edge
    readonly property real pillSize: bar.thickness - 2 * Tokens.metrics.barPadding
    readonly property real crossSlack: Tokens.metrics.barPadding
    readonly property real edgeReach: BarService.edgeGap(bar) + crossSlack // edgeGap = the screen-axis margin facing the bar's edge

    active: BarWidgetRegistry.has(type)
    source: BarWidgetRegistry.source(type) // e.g. "widgets/ClockWidget.qml"
    onLoaded: {
        item.options = Qt.binding(() => root.options)
        item.vertical = Qt.binding(() => root.vertical)
        item.barEdge = Qt.binding(() => root.bar.position)
        item.edgeReach = Qt.binding(() => root.edgeReach)
        item.crossSlack = Qt.binding(() => root.crossSlack)
        item.pillSize = Qt.binding(() => root.pillSize)
    }
    Component.onCompleted: if (!active) console.warn("mat-shell: unknown bar widget", type)
}

// BarWidgetRegistry.qml (excerpt) — one entry per type; optionsSchema is loaded from m3-tokens.json modes.bars.widgetOptions
//   clock: {
//       source: "widgets/ClockWidget.qml", icon: "schedule", label: "Clock & calendar",
//       optionsSchema: [
//           { key: "preset", kind: "choice", label: "Format", default: "dateTime", orientations: "horizontal", choices: [/* time … custom */] },
//           { key: "hourCycle", kind: "choice", label: "Hours", default: "system", visibleWhen: { key: "preset", notEquals: "custom" }, choices: [/* … */] },
//           { key: "showSeconds", kind: "toggle", label: "Show seconds", default: false, visibleWhen: { key: "preset", notEquals: "custom" } },
//           { key: "customFormat", kind: "format", label: "Custom pattern", default: "ddd d MMM  HH:mm", visibleWhen: { key: "preset", equals: "custom" } }
//       ]
//   }
// resolve(type, options, orientation): defaults ← options (known keys only), numbers clamped, multiChoice trimmed to min/max,
// fields excluded by `orientations` reset to their default. Pure and cheap: widgets bind to it directly.

// widgets/ClockWidget.qml
M3BarPill {
    id: clockPill
    property var options: ({})
    property bool vertical: false
    // barEdge / edgeReach / crossSlack / pillSize are M3BarPill properties: the hit area extends toward barEdge

    // Never read options.x directly (§1.2 Step 3)
    readonly property var opt: BarWidgetRegistry.resolve("clock", options, vertical ? "vertical" : "horizontal")
    readonly property bool twelveHour: opt.hourCycle === "12h"
        || (opt.hourCycle === "system" && /a/i.test(Qt.locale().timeFormat(Locale.ShortFormat)))
    readonly property string timePattern: (twelveHour ? "h:mm" : "HH:mm") + (opt.showSeconds ? ":ss" : "") + (twelveHour ? " AP" : "")
    readonly property string pattern: ({
        time: timePattern,
        weekdayTime: "ddd  " + timePattern,
        dateTime: "ddd d MMM  " + timePattern,
        fullDate: "dddd d MMMM  " + timePattern,
        custom: opt.customFormat
    })[opt.preset]

    accessibleName: Qt.formatDateTime(systemClock.date, "dddd d MMMM, " + timePattern)
    tooltipText: Qt.formatDateTime(systemClock.date, "dddd, d MMMM yyyy")
    popoverOpen: ShellState.activePopover === "calendar" && ShellState.popoverTrigger === clockPill
    onClicked: ShellState.togglePopover("calendar", clockPill)
    Component.onCompleted: ShellState.registerTrigger("calendar", clockPill)

    Text {
        visible: !clockPill.vertical
        text: Qt.formatDateTime(systemClock.date, clockPill.pattern)
        font.family: Tokens.typography.labelLarge.family
        font.pixelSize: Tokens.typography.labelLarge.pixelSize
        font.weight: Tokens.typography.labelLarge.weight
        font.features: Tokens.typography.tabularFeatures
        color: clockPill.contentColor
        Accessible.ignored: true
    }
    Column {
        visible: clockPill.vertical
        Repeater {
            // Vertical: stacked time only (preset is horizontal-only); hour cycle and seconds still apply
            model: [Qt.formatDateTime(systemClock.date, clockPill.twelveHour ? "h" : "HH"), Qt.formatDateTime(systemClock.date, "mm")]
                .concat(clockPill.opt.showSeconds ? [Qt.formatDateTime(systemClock.date, "ss")] : [])
            delegate: Text {
                required property string modelData
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData
                font.family: Tokens.typography.labelLarge.family
                font.pixelSize: Tokens.typography.labelLarge.pixelSize
                font.weight: Font.DemiBold
                font.features: Tokens.typography.tabularFeatures
                color: clockPill.contentColor
                Accessible.ignored: true
            }
        }
    }

    SystemClock {
        id: systemClock
        precision: clockPill.opt.showSeconds || /s/.test(clockPill.pattern) ? SystemClock.Seconds : SystemClock.Minutes
    }
}

// widgets/AppsWidget.qml (excerpt) — the dock is just this widget in a fit-length island bar
GridLayout {
    id: apps
    property var options: ({})
    property bool vertical: false
    property string barEdge: "bottom"
    property real edgeReach: 0
    property real pillSize: Tokens.metrics.barPillHeight
    readonly property var opt: BarWidgetRegistry.resolve("apps", options, vertical ? "vertical" : "horizontal")
    readonly property int wellSize: Math.max(Tokens.metrics.iconSm, Math.min(56, pillSize - 8))

    flow: vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    rows: vertical ? -1 : 1
    columns: vertical ? 1 : -1
    rowSpacing: Tokens.metrics.barSectionGap
    columnSpacing: Tokens.metrics.barSectionGap

    Repeater {
        model: AppsModel { pinned: apps.opt.pinned; showRunning: apps.opt.showRunning }
        delegate: M3AppIcon {
            id: well
            required iconName
            required appName
            required runningCount
            required property bool focused
            implicitWidth: apps.wellSize
            implicitHeight: apps.wellSize
            appFocused: focused
            themed: Tokens.themedIcons
            barEdge: apps.barEdge // also places the running indicator on the side facing the screen centre
            edgeReach: apps.edgeReach
            // Hover lift toward the screen centre, via transform so the layout never moves neighbours
            transform: Translate {
                readonly property real lift: well.hovered && Tokens.motion.spatialMotionEnabled ? 4 : 0
                x: apps.barEdge === "left" ? lift : apps.barEdge === "right" ? -lift : 0
                y: apps.barEdge === "top" ? lift : apps.barEdge === "bottom" ? -lift : 0
                Behavior on x { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springFastSpatial.spring; damping: Tokens.motion.springFastSpatial.damping } }
                Behavior on y { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springFastSpatial.spring; damping: Tokens.motion.springFastSpatial.damping } }
            }
        }
    }
}
```
