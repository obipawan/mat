# Shell Component 16 — Settings (Two-Pane Desktop Customisation App)

> **Module**: `design-system/shell-components/16-settings.md`
> **Component ID**: `SC-16`
> **Primitives Used**: `M3Surface`, `M3Card`, `M3Button`, `M3IconButton`, `M3SegmentedButton`, `M3Switch`, `M3Slider`, `M3SearchField`, `M3TextField`, `M3ContextMenu`, `M3Tooltip`, `M3Divider`, `M3ScrollBar`
> **Edits**: `~/.config/mat-shell/config.json` via `ConfigService` · **Configures**: `SC-01` bars, `SC-02` widgets, tokens, keybindings

---

## 1. Purpose & Wayland Layer Config

**Settings** is where the user customises the whole desktop environment: appearance, theme and wallpaper, bars and their widgets, desktop widgets, notifications, keybindings, animations, accessibility, and system information. It is a two-pane window:
- The **left pane** lists categories, with a search field above them.
- The **right pane** shows the selected category's details.

Every change applies **live**, with no Save button and no restart. An **Undo** snackbar covers each destructive or structural change.

| Property | Value |
|---|---|
| **Quickshell Type** | `FloatingWindow` (`xdg_toplevel`), the documented exception to the layer-shell rule: Settings is an application window that users move, resize, and alt-tab to, not a shell panel |
| **Title** | `"Settings — Mat Shell"` (compositor rules match on the title) |
| **Size** | Default `1040 × 700`, minimum `720 × 520`; restores the last size and category |
| **Compositor Rule** | Hyprland: `windowrule = float, center, size 1040 700, title:^(Settings — Mat Shell)$` (installed with the shell config); Niri: `window-rule { match title="^Settings — Mat Shell$"; open-floating true; }` |
| **Instances** | Single instance: opening it again focuses the existing window and navigates to the requested page |
| **Keyboard Focus** | Normal toplevel focus; **never** opened over the lock screen or a security modal (`ShellState` Lane 0 wins) |

### 1.1 Entry Points
- **Keybinding**: `Super+,` (rebindable).
- **IPC**: `qs ipc call shell openSettings <page>[/<subpage>]`, e.g. `openSettings bars/top`, `openSettings keybindings`.
- **Bar context menu**: `Configure "<bar name>"…` deep-links to `bars/<id>` with that bar selected; `Add widget…` opens the widget palette of the clicked section.
- **Control Center header**: gear icon (`settings`).
- **Launcher**: typing "settings", or any setting name (e.g. "reduced motion"), lists matching settings that deep-link into the page (`SC-08` provider `settings`).
- **Bar widget**: the optional `settings` widget (`SC-02`).

### 1.2 Categories (Left Pane, in Order)

| Category | Icon | Contents |
|---|---|---|
| **Appearance** | `palette` | Colour scheme (Dark / Light / Follow time), Surface style (`opaque_tonal` / `frosted_tonal_glass`), Density (compact / comfortable / spacious), Desktop paradigm (`tiling` / `floating` / Auto from compositor), Themed app icons, Screen corners |
| **Theme & Wallpaper** | `wallpaper` | Wallpaper grid, scheme variant (Tonal spot, Content, Expressive, Fidelity, Vibrant, Neutral, Monochrome, Rainbow, Fruit salad), source colour picker, contrast; `Open Theme Studio` (`SC-14`) |
| **Bars** | `toolbar` | Live preview, bar list, presets, per-bar editor, sections editor, widget palette (§3.2) |
| **Desktop Widgets** | `widgets` | Enable widgets layer, manage placed widgets, Widget Peek shortcut (`SC-15`) |
| **Notifications** | `notifications` | Do Not Disturb + schedule, per-app rules, toast placement (`Auto` = clear of bars nearest the top-end corner), toast duration, lock-screen privacy |
| **Keybindings** | `keyboard` | Searchable list of shell actions with their bindings, record new shortcut, conflict detection, reset (§3.3) |
| **Animations** | `animation` | Reduced motion (Follow system / On / Off), Expressive bounce, Decorative animations, live motion preview tile |
| **Accessibility** | `accessibility_new` | High contrast, Reduced transparency, Text size (`textScale`), Hold to confirm (vs. press twice), Always show focus ring, Larger bar targets |
| **About** | `info` | Mat Shell, Quickshell, compositor, and matugen versions; config path; Export / Import config; Reset all settings (hold-to-confirm) |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Window Placement** | Floats centred via the compositor rule, never tiled, so the two-pane layout keeps its proportions | Opens centred at its last size; behaves as a normal window |
| **Window Header** | Title + search shortcut; no window buttons (`Super+Q` / `Ctrl+W` close it) | Client-side header with a close button (`M3IconButton`, `close`) and a drag area |
| **Bars Page Hints** | `Auto` visibility described as "Hides when windows tile under the bar" | `Auto` visibility described as "Always shown" |
| **Paradigm Switch** | Appearance → Desktop paradigm switches live; open pages re-describe mode-dependent options immediately | Same |

### 2.1 Compact Width (< `760px`)
The window collapses to **one pane**: the category list fills the window, choosing a category slides the detail page in, and a back arrow (`Alt+←`) returns to the list. Search stays at the top of the list.

---

## 3. Visual Anatomy & ASCII Layout

```text
╭─ Settings — Mat Shell ───────────────────────────────────────────────────────────────────────────────────────╮
│ ╭─ LEFT PANE (248px) ──────╮  ╭─ RIGHT PANE: Bars ─────────────────────────────────────────────────────────╮ │
│ │ ╭──────────────────────╮ │  │  Bars                                         [ Presets ▾ ]  [ + Add bar ]  │ │
│ │ │ 󰍉 Search settings    │ │  │  Always-on-top strips on any screen edge. Changes apply instantly.          │ │
│ │ ╰──────────────────────╯ │  │ ╭─ Live preview ───────────────────────────────────────────────────────╮    │ │
│ │  󰏘  Appearance           │  │ │  ╭────────────────────────────────────────────────────────────╮      │    │ │
│ │  󰸉  Theme & Wallpaper    │  │ │  │ ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔ Top bar (selected) ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔ │      │    │ │
│ │ ┃ 󰕮  Bars             ┃ │  │ │  │                                                            │      │    │ │
│ │  󰖲  Desktop Widgets      │  │ │  │                     ╭── Dock ──╮                           │      │    │ │
│ │  󰂚  Notifications        │  │ │  │                     ╰──────────╯                           │      │    │ │
│ │  󰌌  Keybindings          │  │ │  ╰────────────────────────────────────────────────────────────╯      │    │ │
│ │  󰶞  Animations           │  │ ╰────────────────────────────────────────────────────────────────────────╯    │ │
│ │  󰖂  Accessibility        │  │  ╭ Top bar · top · bar · 40px ─╮ ╭ Dock · bottom · island · 64px ─╮           │ │
│ │  󰋽  About                │  │  ╰─────────────────────────────╯ ╰────────────────────────────────╯           │ │
│ │                          │  │ ╭─ Top bar ──────────────────────────────────────────────── [⋮] ─╮          │ │
│ │                          │  │ │ Name        [ Top bar                ]   Enabled        [●━━] │          │ │
│ │                          │  │ │ Position    [ Top | Right | Bottom | Left ]                    │          │ │
│ │                          │  │ │ Style       [ Bar | Island ]          Screens   [ All ▾ ]    │          │ │
│ │                          │  │ │ Thickness   ━━━━━━●━━━━━━━  40 px                             │          │ │
│ │                          │  │ │ Horizontal margin ━━●━━━━  8 px   Vertical margin ━━●━━  8 px │          │ │
│ │                          │  │ │ Length      [ Full | Fit | Custom ]  ━━━━━━●━━  80 %         │          │ │
│ │                          │  │ │ Visibility  [ Always | Auto | Dodge | Autohide ]               │          │ │
│ │                          │  │ │ Reserve space for windows                          [●━━]     │          │ │
│ │                          │  │ ├─ Widgets ───────────────────────────────────────────────────┤          │ │
│ │                          │  │ │  START               CENTER                END              │          │ │
│ │                          │  │ │ ╭───────────────╮  ╭───────────────╮  ╭─────────────────╮   │          │ │
│ │                          │  │ │ │⠿ Launcher   ✎✕│  │⠿ Window tit…✎✕│  │⠿ Privacy       🔒│   │          │ │
│ │                          │  │ │ │⠿ Workspaces ✎✕│  │⠿ Media      ✎✕│  │⠿ System tray  ✎✕│   │          │ │
│ │                          │  │ │ │⠿ Keyb. mode  ✕│  │               │  │⠿ Control cent…✎✕│   │          │ │
│ │                          │  │ │ │ [ + Add ]     │  │ [ + Add ]     │  │⠿ Clock        ✎✕│   │          │ │
│ │                          │  │ │ ╰───────────────╯  ╰───────────────╯  │ [ + Add ]       │   │          │ │
│ │                          │  │ │                                       ╰─────────────────╯   │          │ │
│ │                          │  │ │ ▾ ✎ Workspaces · Start   Style [Numbers ▾]  Count ━━●━ 6  Show empty [●━━] │ │
│ │                          │  │ ╰──────────────────────────────────────────────────────────────╯          │ │
│ ╰──────────────────────────╯  ╰─────────────────────────────────────────────────────────────────────────────╯ │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
                                                         ╭───────────────────────────────────────╮
                                                         │ Removed "Media" from Top bar   [Undo] │  snackbar (8s)
                                                         ╰───────────────────────────────────────╯
```

### 3.1 Pane Rules
- **Left pane**: `248px` wide, a vertical list of category items (`56px` tall, `radius: full`, icon + `labelLarge`). The selected item uses `secondaryContainer` with an icon fill morph. Search filters across all pages.
- **Right pane**: scrollable column, max content width `760px` (centred beyond that), with a page title (`headlineSmall`), a one-line description (`bodyMedium`, `onSurfaceVariant`), and grouped `M3Card` (Tier 1) sections of setting rows.
- **Setting rows**: label (`bodyLarge`) + optional supporting text (`bodySmall`) on the start side, control on the end side; min height `56px`; the whole row is clickable for switches.
- **Search results**: typing replaces the category list with matching settings (`label · Category`). Choosing one navigates to the page, scrolls to the row, and highlights it (`primary` @ `12%` for `1.2s`, a static outline under Reduced Motion).

### 3.2 Bars Page
1. **Live Preview**: A scaled screen (`16:9` of the selected monitor, `screen` picker when there are several) draws every bar on that screen at true proportions. Click a bar to select it. Dragging a bar onto another edge moves it; the Position control is the keyboard path.
2. **Bar List**: One summary card per bar (`name · position · style · thickness`), with an overflow menu: `Duplicate`, `Move up / down` (stacking order on the same edge), `Disable`, `Delete` (Undo).
3. **Presets** (`SC-01` §1.2) replace all bars after a confirmation dialog, with Undo.
4. **Add bar**: creates a bar on the first edge with free capacity (`SC-01` §2.1 rule 3), pre-filled with `launcher`, `workspaces` | `clock` | `controlCenter`, and selects it.
5. **Bar Editor**: name, enabled, position (segmented `Top | Right | Bottom | Left`), style (segmented `Bar | Island`), screens, thickness slider (bounded by orientation), two independent margin sliders (`0..24` each): **Horizontal margin** (left/right gap) and **Vertical margin** (top/bottom gap). Margins are screen-relative; each slider's supporting text says what it does for the current edge (e.g. a top bar: "Gap at both ends" / "Gap to the top edge"), length (`Full | Fit | Custom` + percent slider), alignment (shown when length isn't Full), visibility, reserve space. Controls that would break a guardrail are disabled with an inline reason ("Only 2 bars fit on the left edge").
6. **Sections Editor**: three columns named for the orientation (`Start | Center | End` on horizontal bars, `Top | Middle | Bottom` on vertical bars). Each widget is a chip with a drag handle, its name, and a remove button.
   - **Drag**: Chips drag within and across columns; the drop slot opens with `springFastSpatial`.
   - **Keyboard**: `Alt+←/→` (horizontal) or `Alt+↑/↓` moves a chip; moving past a column's end carries it into the next column. `Delete` removes it, and `Enter` opens its options panel (item 8).
   - **Buttons**: Every chip's context menu has `Edit options…` (widgets with options only), `Move to Start / Center / End`, `Move earlier / later`, and `Remove`, so dragging is never the only path.
   - **Security widgets**: Removing the last `privacy` or `recording` widget explains the fallback indicator (`SC-01` §2.1 rule 1) instead of blocking it; the chip shows a lock glyph tooltip.
   - **Mode preview**: In island style, each column is drawn as a capsule in the live preview, making the grouping visible.
7. **Widget Palette** (`+ Add`): a searchable menu of the `SC-02` registry with icon, name, and one-line description. Adding appends to that section; widgets that are already on this bar show a `On this bar` hint (duplicates are allowed).
8. **Widget Options** (the generic renderer for the `SC-02` §1.2 contract; no widget-specific Settings code):
   - **Edit icon**: a chip shows an edit icon button (`tune`) between its name and the remove button **only** when `BarWidgetRegistry.hasOptions(type)`. Widgets without options get no icon (never a disabled one), so the icon itself says "this one can be customised". When the instance's options differ from the defaults, a `6px` `primary` dot sits on the icon's top-end corner.
   - **Opening**: the edit icon, `Enter` on a focused chip, or the chip menu's `Edit options…` opens the **options panel** for that instance. A plain click on the chip body only selects it (selection is for keyboard moves and never competes with dragging). One panel is open at a time: editing another chip swaps the panel's content, and the edited chip stays selected (`secondaryContainer`) so the link is visible.
   - **Panel**: an inline card directly under the sections editor, never a dialog, so the live preview and the real bar stay visible. The header has the widget icon and name, its location (`End · Top bar`, which tells two clocks apart), a `Reset` text button (enabled only when something differs from the defaults; Undo snackbar), and a close button. The body renders `optionsSchema` in order as standard setting rows (label, optional `help`, control at the end), under `group` headings when declared, using the primitive per field kind (`SC-02` §1.2 table).
   - **Live**: every change applies to the real bar and the miniature within a frame (`ConfigService.transaction`, one Undo entry per change; `text` / `format` after `300ms` idle). Settings writes only values that differ from the default (`BarWidgetRegistry.diffFromDefaults`); `Reset` removes the instance's `options` entirely.
   - **Conditional and orientation-bound fields**: `visibleWhen` fields expand and collapse in place. Fields that don't apply to the bar's orientation stay visible but disabled with the reason (`Horizontal bars only`); moving the bar to another edge updates the panel live.
   - **Limits**: a `multiChoice` at its `min` disables unchecking the last item, and at its `max` disables the unchecked items; the reason shows as supporting text (`At least 1 item`, `Up to 4 stats`).
   - **Closing**: `Escape`, the close button, removing the widget, or selecting another bar closes the panel and returns focus to the chip's edit icon. In compact windows (`§2.1`) the panel opens as a sub-page with a back arrow.

   ```text
   chip     ╭───────────────────────────────╮
            │ ⠿  󰥔 Clock           ✎•   ✕   │   ✎ edit options (only widgets with a schema) · • customised
            ╰───────────────────────────────╯
   panel    ╭─ 󰥔 Clock · End · Top bar ─────────────────────────────── [ Reset ]   ✕ ─╮
            │ Format                                          [ Weekday + time    ▾ ] │   5+ choices → select menu
            │ Hours                                     [ System | 24-hour | 12-hour ] │   ≤ 4 → segmented button
            │ Show seconds                                                     [○━━] │
            ╰──────────────────────────────────────────────────────────────────────────╯
   panel    ╭─ 󰒓 Control center · End · Top bar ────────────────────── [ Reset ]   ✕ ─╮
            │ Shown items                                                             │   multiChoice: checked first,
            │  ⠿ ☑ 󰤨 Network   ⠿ ☑ 󰂯 Bluetooth   ⠿ ☑ 󰕾 Volume   ⠿ ☑ 󰁹 Battery        │   drag (or Alt+↑/↓) = bar order
            │    ☐ 󰍬 Microphone  ☐ 󰃠 Brightness  ☐ 󰓅 Power profile  ☐ 󰂛 DND  …     │
            │ Show percentages                                                 [●━━] │
            ╰──────────────────────────────────────────────────────────────────────────╯
   ```

### 3.3 Keybindings Page
- A grouped list (Shell, Launcher & Overview, Windows, Workspaces, Media & Volume, Capture, Session) of `action · current shortcut` rows.
- **Record**: Activating a row starts recording; the next chord becomes the new shortcut and `Escape` cancels. A conflicting chord shows `Conflicts with "<action>"` with `Replace` / `Cancel`.
- **Reset** per row and `Reset all` (hold-to-confirm).
- Shell-owned actions are registered as compositor global shortcuts. `KeybindService` writes `~/.config/mat-shell/binds.conf` (Hyprland `bind = …, global, mat-shell:<action>`), which `hyprland.conf` sources, then reloads. On Niri and Sway, the page shows the generated snippet with `Copy` because those configs can't be rewritten safely.
- `Super`, `Super+,`, and `Super+Escape` can be rebound but not unbound (the core-reachability guardrail, `SC-01` §2.1 rule 2).

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Metric Token |
|---|---|---|---|---|
| **Window Root** | `Tokens.color.surfaceTier(0)` (frosted blur allowed per Dual-Surface Engine) | `onSurface` | — | `radius: Tokens.shape.xl` when the compositor rounds windows |
| **Left Pane** | transparent over Tier 0 | `onSurfaceVariant` | — | `width: 248px`, `padding: Tokens.metrics.spaceMd` |
| **Category Item (selected)** | `Tokens.color.secondaryContainer` | `onSecondaryContainer` | `labelLarge` (`600`) | `height: 56px`, `radius: full` |
| **Category Item (rest / hover)** | transparent / `onSurface` @ `8%` | `onSurfaceVariant` | `labelLarge` | `height: 56px`, `radius: full` |
| **Detail Card** | `Tokens.color.surfaceTier(1)` (≥ `90%` opacity) | `onSurface`, `1px` `surfaceBorder(1)` | — | `radius: Tokens.shape.xl`, `padding: Tokens.metrics.spaceLg` |
| **Page Title / Description** | — | `onSurface` / `onSurfaceVariant` | `headlineSmall` / `bodyMedium` | `spaceSm` gap |
| **Setting Row** | — | `onSurface` / supporting `onSurfaceVariant` | `bodyLarge` / `bodySmall` | `minHeight: 56px` |
| **Preview Screen** | `Tokens.color.surfaceTier(3)` | Bars drawn in `surfaceTier(0)`; selected bar outlined `2px` `primary` | `labelSmall` bar names | `radius: Tokens.shape.md` |
| **Section Column** | `Tokens.color.surfaceTier(2)` | `onSurfaceVariant` header | `labelMedium` (uppercase header) | `radius: Tokens.shape.lg`, `minHeight: 160px` |
| **Widget Chip** | `Tokens.color.surfaceTier(3)` (selected `secondaryContainer`) | `onSurface` | `labelLarge` | `height: 40px`, `radius: Tokens.shape.sm` → `md` on drag |
| **Chip Edit Button** | transparent; state layer `onSurface` `8%` / `12%` | `onSurfaceVariant` (`onSecondaryContainer` on a selected chip); customised dot `Tokens.color.primary` | — | icon `iconSm`, target `32px`, `radius: full`; dot `6px` |
| **Widget Options Panel** | `Tokens.color.surfaceTier(2)` | `onSurface`; header location `onSurfaceVariant`; disabled reason `onSurfaceVariant` | `titleSmall` header, `labelMedium` group headings (`primary`), rows as Setting Row | `radius: Tokens.shape.lg`, `padding: Tokens.metrics.spaceMd`, top gap `spaceSm` |
| **Drop Slot** | `Tokens.color.primary` @ `12%` | `1px` dashed `primary` | — | chip height |
| **Search Highlight** | `Tokens.color.primary` @ `12%` | — | — | `1.2s`, outline only under Reduced Motion |
| **Snackbar** | `Tokens.color.inverseSurface` | `inverseOnSurface`; action `inversePrimary` | `bodyMedium` / `labelLarge` | `radius: Tokens.shape.sm`, bottom-centre `spaceLg` |

---

## 5. Interactive State Matrix

| State | Visual & Behavioral Response |
|---|---|
| **Category Hover / Focus** | `8%` state layer; focus ring under `Tokens.keyboardModality`; `↑/↓` moves through categories, `Enter` / `→` moves focus into the detail pane. |
| **Category Selected** | Detail pane cross-fades to the page (`springDefaultEffects`) and the scroll position resets; the URL-like page key is persisted for next launch. |
| **Setting Changed** | Applied live immediately; `ConfigService` writes after `300ms` of quiet. Structural changes (remove widget/bar, preset, reset) raise the Undo snackbar; `Ctrl+Z` undoes the last change. |
| **Widget Chip Dragging** | Chip lifts (`scale 1.04`, `radius: md`, state layer `16%`); the drop slot opens; drop outside any column cancels with a spring return. |
| **Widget Options Open** | Edited chip stays selected; the panel's first control takes focus; `Tab` cycles the panel's fields, `Escape` closes it and returns focus to the chip's edit icon. Each change applies live and is undoable; the chip's customised dot appears or disappears as the options leave or return to their defaults. |
| **Guardrail Blocked** | Control disabled at `38%` opacity with supporting text explaining why; never a silent no-op. |
| **Config File Error** | External edit produced invalid JSON: banner `"config.json has an error on line N"` with `Open file` / `Restore last good`; the shell keeps running on the last valid config. |
| **External Change** | Hand edits to `config.json` reload into the open page without losing focus. |
| **Keyboard** | `Ctrl+F` search · `Ctrl+PgUp/PgDn` previous/next category · `F6` switch panes · `Ctrl+Z` undo · `Escape` clears search, then closes menus, then closes the window · `Ctrl+W` close. |

---

## 6. Motion & Morph Choreography

1. **Open**: Window scales `0.96 → 1.0` and fades in with `springDefaultSpatial` + `springDefaultEffects` (the compositor animates the toplevel when it owns window animations; the shell then skips its own).
2. **Category Switch**: The selected-item pill slides between categories (`springFastSpatial`); the detail page shifts `16px` along the vertical axis while cross-fading (`100ms` fade only under Reduced Motion).
3. **Live Bar Feedback**: Each edit morphs the real bar on screen (`SC-01` §6) and the miniature in sync, so cause and effect stay visible.
4. **Chip Reorder**: Siblings move with `Move` transitions (`springFastSpatial`); a removed chip scales to `0.8` and fades.
5. **Widget Options Panel**: Opens by growing its height from `0` (`springDefaultSpatial`) while the content fades in (`springDefaultEffects`); switching chips cross-fades the content and springs to the new height; `visibleWhen` rows expand and collapse with `springFastSpatial`. Under Reduced Motion all of these are `100ms` fades.
6. **Compact Mode Navigation**: Detail page slides in from the end edge; back slides it out (`springDefaultSpatial`).

---

## 7. Quickshell Service & IPC Bindings

- **`ConfigService`** (singleton): `FileView { path: "~/.config/mat-shell/config.json"; watchChanges: true; atomicWrites: true }` + `JsonAdapter` for `appearance`, `theme`, `bars`, `widgets`, `notifications`, `keybinds`, `animations`, `accessibility`. Exposes `set(path, value)`, `transaction(label, fn)` (one Undo entry per transaction), `undo()`, `lastGood`, `error`. Tokens bind their switches to `ConfigService` values (`Tokens.reducedMotion`, `confirmByHold`, `desktopMode`, …).
- **`BarService`**: validation helpers used by the Bars page: `canPlace(screen, edge)`, `thicknessRange(position)`, `reservedShare(screen, axis)`.
- **`KeybindService`**: action registry (`id`, `label`, `group`, `defaultChord`), conflict detection, `binds.conf` generation and compositor reload.
- **`ThemeService`**: wallpaper list, `applyScheme(variant)`, matugen runs (`01-color-and-surfaces.md` §1.3).
- **`ShellState`**: `openSettings(page)` IPC; Settings is refused while `ShellState.securityModalActive` or the session is locked.
- **`SettingsIndex`**: static keyword index (`label`, `keywords`, `page`, `anchorId`) shared by the in-app search and the Launcher's `settings` provider.

---

## 8. Canonical QML Reference Skeleton (`SettingsWindow.qml`, `BarSectionsEditor.qml` & `WidgetOptionsForm.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import MatShell.Tokens

FloatingWindow {
    id: settings
    title: "Settings — Mat Shell"
    implicitWidth: 1040
    implicitHeight: 700
    minimumSize: Qt.size(720, 520)
    color: Tokens.color.surfaceTier(0)

    property string page: ConfigService.ui.lastSettingsPage ?? "appearance"
    readonly property bool compact: width < 760
    property bool showDetail: !compact

    function open(target) {
        const [pageKey, sub] = (target || page).split("/")
        page = pageKey
        showDetail = true
        detail.item?.focusSubpage?.(sub)
        visible = true
        // FloatingWindow raise/activate goes through the compositor (xdg-activation)
    }

    Shortcut { sequences: ["Ctrl+F"]; onActivated: searchField.forceActiveFocus() }
    Shortcut { sequences: ["Ctrl+Z"]; onActivated: ConfigService.undo() }
    Shortcut { sequences: ["Ctrl+W"]; onActivated: settings.visible = false }
    Shortcut { sequences: ["Ctrl+PgDown"]; onActivated: nav.incrementCurrentIndex() }
    Shortcut { sequences: ["Ctrl+PgUp"]; onActivated: nav.decrementCurrentIndex() }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // LEFT PANE — search + categories
        ColumnLayout {
            visible: !settings.compact || !settings.showDetail
            Layout.preferredWidth: settings.compact ? settings.width : 248
            Layout.fillHeight: true
            Layout.margins: Tokens.metrics.spaceMd
            spacing: Tokens.metrics.spaceSm

            M3SearchField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search settings"
                accessibleName: "Search settings"
            }

            ListView {
                id: nav
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: searchField.text.length === 0
                model: SettingsIndex.categories // [{ key, label, icon }]
                currentIndex: SettingsIndex.indexOf(settings.page)
                keyNavigationEnabled: true
                activeFocusOnTab: true
                spacing: 2
                highlightMoveDuration: -1
                highlightFollowsCurrentItem: true
                highlight: Rectangle {
                    radius: height / 2
                    color: Tokens.color.secondaryContainer
                    Behavior on y { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { spring: Tokens.motion.springFastSpatial.spring; damping: Tokens.motion.springFastSpatial.damping } }
                }
                onCurrentIndexChanged: settings.page = model[currentIndex].key

                delegate: SettingsNavItem {   // M3Surface + M3StateLayer row, 56px, icon + labelLarge
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    icon: modelData.icon
                    label: modelData.label
                    selected: ListView.isCurrentItem
                    Accessible.role: Accessible.PageTab
                    Accessible.name: modelData.label
                    onActivated: { nav.currentIndex = index; settings.showDetail = true }
                }
            }

            SettingsSearchResults {           // replaces the list while searching
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: searchField.text.length > 0
                query: searchField.text
                onChosen: (entry) => { settings.open(entry.page + "/" + entry.anchorId); searchField.text = "" }
            }
        }

        // RIGHT PANE — selected category details
        Loader {
            id: detail
            visible: !settings.compact || settings.showDetail
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: "pages/" + SettingsIndex.pageFile(settings.page) // e.g. BarsPage.qml
            opacity: status === Loader.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Tokens.motion.springDefaultEffects.durationMs; easing.type: Easing.OutCubic } }
        }
    }

    SettingsSnackbar { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: Tokens.metrics.spaceLg }
}

// pages/bars/BarSectionsEditor.qml — Start/Center/End columns with drag, keyboard, and menu paths
GridLayout {
    id: editor
    required property var bar
    readonly property bool vertical: bar.position === "left" || bar.position === "right"
    readonly property var sectionKeys: ["start", "center", "end"]
    readonly property var sectionLabels: vertical ? ["Top", "Middle", "Bottom"] : ["Start", "Center", "End"]

    columns: 3
    columnSpacing: Tokens.metrics.spaceMd
    property var editing: null // { section, index } of the chip whose options panel is open

    function move(fromSection, fromIndex, toSection, toIndex) {
        ConfigService.transaction("Move widget", () => {
            const s = JSON.parse(JSON.stringify(editor.bar.sections))
            const [w] = s[fromSection].splice(fromIndex, 1)
            s[toSection].splice(Math.max(0, Math.min(toIndex, s[toSection].length)), 0, w)
            ConfigService.updateBar(editor.bar.id, { sections: s })
        })
    }

    Repeater {
        model: 3
        delegate: M3Surface {
            id: column
            required property int index
            readonly property string key: editor.sectionKeys[index]
            tier: 2
            cornerRadius: Tokens.shape.lg
            Layout.fillWidth: true
            Layout.minimumHeight: 160
            accessibleName: editor.sectionLabels[index] + " section, " + editor.bar.sections[key].length + " widgets"

            DropArea {
                anchors.fill: parent
                keys: ["mat-bar-widget"]
                onDropped: (drop) => editor.move(drop.source.section, drop.source.index, column.key, chips.indexAt(drop.y))
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Tokens.metrics.spaceSm
                spacing: Tokens.metrics.spaceXs

                Text {
                    text: editor.sectionLabels[column.index].toUpperCase()
                    font.family: Tokens.typography.labelMedium.family
                    font.pixelSize: Tokens.typography.labelMedium.pixelSize
                    font.weight: Tokens.typography.labelMedium.weight
                    color: Tokens.color.onSurfaceVariant
                }

                Repeater {
                    id: chips
                    model: editor.bar.sections[column.key]
                    delegate: WidgetChip {      // drag handle + name + edit + remove; Drag.keys: ["mat-bar-widget"]
                        required property var modelData
                        required property int index
                        section: column.key
                        label: BarWidgetRegistry.label(modelData.type)
                        locked: modelData.type === "privacy" || modelData.type === "recording"
                        editable: BarWidgetRegistry.hasOptions(modelData.type)       // no edit icon otherwise
                        customised: Object.keys(BarWidgetRegistry.diffFromDefaults(modelData.type, modelData.options ?? {})).length > 0
                        selected: editor.editing?.section === column.key && editor.editing?.index === index
                        onEditRequested: editor.editing = { section: column.key, index: index }
                        activeFocusOnTab: true
                        Accessible.name: label + ", " + (index + 1) + " of " + chips.count + " in " + editor.sectionLabels[column.index]
                        Keys.onPressed: (event) => {
                            const fwd = editor.vertical ? Qt.Key_Down : Qt.Key_Right
                            const back = editor.vertical ? Qt.Key_Up : Qt.Key_Left
                            if (event.modifiers & Qt.AltModifier && (event.key === fwd || event.key === back)) {
                                const step = event.key === fwd ? 1 : -1
                                const last = chips.count - 1
                                if (index + step >= 0 && index + step <= last) editor.move(column.key, index, column.key, index + step)
                                else if (column.index + step >= 0 && column.index + step <= 2)
                                    editor.move(column.key, index, editor.sectionKeys[column.index + step], step > 0 ? 0 : 999)
                                event.accepted = true
                            } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && editable) {
                                editRequested()
                                event.accepted = true
                            } else if (event.key === Qt.Key_Delete) {
                                ConfigService.transaction("Remove widget", () => ConfigService.removeWidget(editor.bar.id, column.key, index))
                                event.accepted = true
                            }
                        }
                    }
                }

                M3Button {
                    variant: "text"
                    text: "Add"
                    icon: "add"
                    accessibleName: "Add widget to " + editor.sectionLabels[column.index]
                    onClicked: widgetPalette.openFor(column.key, this)
                }
            }
        }
    }

    WidgetPalette { id: widgetPalette; bar: editor.bar } // searchable M3ContextMenu over BarWidgetRegistry

    WidgetOptionsForm {
        Layout.columnSpan: 3
        Layout.fillWidth: true
        visible: editor.editing !== null
        bar: editor.bar
        section: editor.editing?.section ?? ""
        index: editor.editing?.index ?? -1
        onClosed: editor.editing = null
    }
}

// pages/bars/WidgetOptionsForm.qml — renders any widget's optionsSchema; adding options to a widget never touches this file
M3Surface {
    id: form
    required property var bar
    required property string section
    required property int index
    signal closed()

    readonly property var entry: bar.sections[section]?.[index] ?? null
    readonly property string type: entry?.type ?? ""
    readonly property string orientation: bar.position === "left" || bar.position === "right" ? "vertical" : "horizontal"
    readonly property var schema: BarWidgetRegistry.optionsSchema(type)
    readonly property var values: BarWidgetRegistry.resolve(type, entry?.options ?? {}, orientation)

    tier: 2
    cornerRadius: Tokens.shape.lg
    accessibleName: BarWidgetRegistry.label(type) + " options"
    Keys.onEscapePressed: form.closed()

    function write(key, value) {
        ConfigService.transaction("Change " + BarWidgetRegistry.label(type), () => {
            const next = Object.assign({}, entry.options ?? {}, { [key]: value })
            ConfigService.setWidgetOptions(bar.id, section, index, BarWidgetRegistry.diffFromDefaults(type, next))
        })
    }
    function shown(field) {
        const c = field.visibleWhen
        if (!c) return true
        const v = values[c.key]
        return "equals" in c ? v === c.equals : "notEquals" in c ? v !== c.notEquals : (v ?? []).includes(c.includes)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.metrics.spaceMd

        WidgetOptionsHeader { // icon + name + location + Reset + close
            type: form.type
            location: BarWidgetRegistry.sectionLabel(form.section, form.orientation) + " · " + form.bar.name
            canReset: Object.keys(BarWidgetRegistry.diffFromDefaults(form.type, form.entry?.options ?? {})).length > 0
            onReset: ConfigService.transaction("Reset " + BarWidgetRegistry.label(form.type), () => ConfigService.setWidgetOptions(form.bar.id, form.section, form.index, {}))
            onClose: form.closed()
        }

        Repeater {
            model: form.schema
            delegate: OptionRow { // Setting Row; picks the primitive from field.kind (toggle → M3Switch, choice → M3SegmentedButton / select, …)
                required property var modelData
                field: modelData
                value: form.values[modelData.key]
                visible: form.shown(modelData)
                enabled: (modelData.orientations ?? "both") === "both" || modelData.orientations === form.orientation
                disabledReason: enabled ? "" : (modelData.orientations === "horizontal" ? "Horizontal bars only" : "Vertical bars only")
                onEdited: (v) => form.write(modelData.key, v)
            }
        }
    }
}
```
