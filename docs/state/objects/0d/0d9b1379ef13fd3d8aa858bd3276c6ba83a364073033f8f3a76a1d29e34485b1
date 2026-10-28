# Foundation 06 — Adaptive Dual-Mode Desktop Paradigm (`tiling` vs. `floating`)

> **Module**: `design-system/foundations/06-adaptive-desktop-modes.md`
> **Token Switch**: `Tokens.desktopMode` (`"tiling"` | `"floating"`)

---

## 1. Dual-Mode Philosophy

Modern Linux desktop users span two distinct workflow paradigms—or switch between them when docking a laptop to an ultrawide monitor vs. using a trackpad on the go:
1. **Tiling Mode (`Tokens.desktopMode === "tiling"`)**: Designed for Hyprland, Niri, and Sway workflows. Windows automatically tile; workspaces are dynamic and central to navigation; keyboard submaps (`RESIZE`, `MOVE`, `PASSTHROUGH`) require prominent visual feedback; screen vertical real estate is sacred.
2. **Floating / Traditional Desktop Mode (`Tokens.desktopMode === "floating"`)**: Designed for traditional desktop workflows (GNOME / ChromeOS / macOS style) or floating workspace layouts. Users rely on an application launcher button, a persistent bottom dock or edge-to-edge taskbar showing minimized/running windows, and spatial window previews.

---

## 2. Component-by-Component Dual-Mode Adaptation Matrix

| Shell Component | Behavior in `tiling` Mode | Behavior in `floating` Mode |
|---|---|---|
| **01. Bars (any edge, any count)** | Bars with `visibility: "auto"` **smart-dodge**: they hide (`exclusiveZone: 0`) while tiled windows occupy their area and reveal on edge dwell (`4px`, `120ms`) or an empty workspace. Bars set to `always` stay pinned | `auto` bars stay **pinned** (reserve space); `dodge` bars hide only when a floating window intersects them |
| **02. `launcher` widget** | Compact `apps` glyph pill | Expressive **"Apps" pill** (glyph + label on horizontal bars) |
| **02. `windowTitle` widget** | **Focused tiled client capsule** (icon + title + floating/fullscreen/pinned badges) | **Active application menu pill** (icon + name + quick window actions) |
| **02. `workspaces` widget** | Full morphing strip (`1..10`) | Collapses to an Overview button when only one workspace exists |
| **02. `apps` widget (dock / taskbar)** | Click on the focused app cycles its windows | Click on the focused app minimizes it; minimized windows appear; `showLabels` gives a classic taskbar |
| **02. `submap` / `telemetry` widgets** | Submap badge appears on compositor submaps; telemetry is suggested in tiling presets | Submap badge stays hidden (no submaps); telemetry stays wherever the user placed it |
| **08. App & Command Launcher** | Opens directly in **Keyboard-First Command & Fuzzy List View** (`width: 640px`, 8 visible rows with instant keyboard accelerators `Alt+1..8`) | Opens in **Expressive App Grid + Pinned Favorites View** (`5×3` icon grid + category filter chips + top search bar), switching to list view on typing |
| **09. Workspace Overview** | **Tiling Geometry Strip / Matrix**: Renders exact proportional tiled split trees per workspace (or Niri horizontal scrolling strip) with keyboard `hjkl` window focus/swap | **Spatial Window Expose**: Scales floating windows into a collision-free expose grid with window close buttons, live search filter, and top workspace thumbnail strip |
| **07. OSD HUDs** | Includes **Workspace Switch HUD** (brief `350ms` M3 pill showing workspace number/name when switching workspaces via `Super+1..9`) | Omits Workspace Switch HUD (unless multiple desktops used); adds **Window Snap Preview Zone** overlay |
| **16. Settings** | Floats centred via compositor rule (never tiled); header without window buttons | Normal floating window with a client-side close button |
| **15. Desktop Widgets** | **Hidden** (rendering and polling paused) while any tiled window is on the workspace; **blooms** on empty workspaces; `Super+D` Widget Peek raises them above windows | **Vivid** while the desktop has focus; **calm** (desaturated, motion paused) while a window is focused; `Super+D` Widget Peek works identically |

---

## 3. Runtime Mode Switching Contract

Switching `Tokens.setDesktopMode("tiling")` or `Tokens.setDesktopMode("floating")` (via `ControlCenter` quick tile, `WallpaperThemePicker`, or CLI `qs ipc call mode set floating`) executes seamlessly at runtime:
1. Bar widgets swap their mode variants in place (`02-bar-widgets.md` §2); siblings reflow with `springFastSpatial` (`100ms` crossfade under Reduced Motion). The user's bar layout itself never changes with the mode.
2. Bars with `visibility: "auto"` update their `WlrLayershell.exclusiveZone` and slide into or out of smart-dodge via `Tokens.motion.springDefaultSpatial`.
3. Compositor IPC (optional hook): If running on Hyprland, toggling `floating` mode can optionally run `hyprctl keyword general:layout dwindle` vs. `floating` window rules via a configurable shell script hook.
4. Mode switching is always explicit (Control Center tile, Theme Studio, launcher `>` command, or IPC). It is never bound to scroll, modifier+scroll, or middle-click, because an accidental switch rearranges the whole shell.

---

## 4. Mode-Independent Input Rule

Desktop mode changes **layout and defaults**, never **which inputs work**:
- Arrow keys, `Enter`, `Space`, `Tab`, and `Escape` behave identically in both modes on every surface.
- Vim aliases (`h/j/k/l`, `[` / `]`, `n` / `p`) are additive and available in both modes; they never replace arrow keys.
- Pointer and keyboard paths both exist in both modes (a floating-mode user can drive the launcher entirely from the keyboard; a tiling-mode user can click anything).
- What may differ by mode: default launcher view (list vs. grid), the default Enter action (launch new vs. focus existing), and the dodge policy of bars set to `auto` visibility.
