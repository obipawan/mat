# Foundation 04 — Desktop Interaction States, Pointer Semantics, Input Handling & Accessibility

> **Module**: `design-system/foundations/04-interaction-states-and-input.md`
> **Token Singleton**: `Tokens.metrics` (`MetricTokens.qml`), `Tokens.color` (`ColorTokens.qml`) & the accessibility switches on `Tokens`

---

## 1. The M3 State Layer System on Desktop

In Material Design 3, interactive states (Hover, Focus, Press, Drag) are communicated by compositing a semi-transparent **State Layer** (using the component's foreground `on*` content color) directly over the container surface, combined with **M3 Expressive shape/scale cues**.

### 1.1 Universal State Matrix

| State | State Layer Color | State Layer Alpha | Shape / Scale / Border Modifier | Cursor Shape | Trigger Condition |
|---|---|---|---|---|---|
| **Idle (Enabled)** | `contentColor` | `0%` (`0.00`) | Resting token radius & `scale: 1.0` | `Qt.ArrowCursor` | Default interactive state |
| **Hovered** | `contentColor` | `8%` (`0.08`) | Corner radius morphs per `ShapeTokens`; icons shift `wght: 400 -> 500`. Width never changes (§5) | `Qt.PointingHandCursor` | `HoverHandler.hovered === true` |
| **Focused (Keyboard)** | `contentColor` | `12%` (`0.12`) | Outer `Tokens.metrics.focusRingWidth` (`2px`, `3px` in High Contrast) solid `Tokens.color.primary` ring with `2px` offset gap | `Qt.ArrowCursor` | `activeFocus && Tokens.keyboardModality` |
| **Pressed (Active)** | `contentColor` | `12%` (`0.12`) + Radial ripple from click point | Corner radius sharpens to `Tokens.shape.md` (`12px`); `scale: 0.97` | `Qt.PointingHandCursor` | Left mouse button down or `Space`/`Return` held |
| **Dragged** | `contentColor` | `16%` (`0.16`) | `scale: 1.04`, elevation shadow `+8px`, `z: 100` | `Qt.ClosedHandCursor` | Reordering `apps` widget icons and Settings widget chips, moving window in Overview, dragging slider thumb |
| **Selected / Toggled** | `onPrimary` (or `onSecondaryContainer`) | `0%` at rest (`8%` hover) | Container shifts to `primary` or `secondaryContainer` **and** shape/fill changes (pill radius, icon `FILL: 1`) | `Qt.PointingHandCursor` | Active Quick Tile, active Workspace pill, selected FilterChip |
| **Disabled** | `onSurface` | `0%` | Container: `onSurface` @ `12%` alpha; Content: `onSurface` @ `38%` alpha; tooltip explains why | `Qt.ArrowCursor` | `enabled === false` (e.g., Bluetooth tile when hardware radio killed) |

**Never colour alone**: Every selected, focused, urgent, or error state pairs colour with a second cue (shape morph, fill axis, text, or icon), so states remain distinguishable for colour-vision deficiency and in `scheme-monochrome`.

---

## 2. Desktop-Specific Pointer & Scroll Wheel Semantics

Linux desktop power users expect rich multi-button mouse and scroll wheel shortcuts across shell bars and panels. These are **accelerators**: fast paths that duplicate actions which also exist as visible controls.

### 2.1 Multi-Button & Wheel Interaction Contract

| Shell Target | Left Click (`Qt.LeftButton`) | Middle Click (`Qt.MiddleButton`) | Right Click (`Qt.RightButton`) | Scroll Wheel Up / Down (`WheelHandler`) |
|---|---|---|---|---|
| **Bar `workspaces` Widget** | Switch to clicked workspace | Toggle Workspace Overview (`SC-09`) | Workspace context menu (Move all windows, Rename) | Previous / next workspace (one step per accumulated notch, §2.3) |
| **Media Pill** | Toggle `MediaPopover` (`06-media-player-popover.md`) | Play / Pause current `MprisPlayer` | Context menu: Previous, Next, Switch player, Open player window | Player volume `±5%` (`Shift`: seek `±5s`) |
| **Audio / Quick Settings Pill** | Toggle `ControlCenter` (`03-control-center.md`) | Toggle master mute (OSD confirms) | Audio output quick menu | Master volume `±2%` (OSD shows level) |
| **Battery / Brightness Pill** | Toggle `ControlCenter` (Power section) | Cycle power profile (OSD names the new profile) | Power statistics menu | Display brightness `±5%` |
| **System Tray Icon** | `SystemTrayItem.activate()` (or `secondaryActivate` if menu-only) | `SystemTrayItem.secondaryActivate()` | `M3ContextMenu` bound to `SystemTrayItem.menu` | Forward `SystemTrayItem.scroll(delta, horizontal)` |
| **Bar `apps` Widget Item (dock / taskbar)** | Launch app, focus window, or cycle app's windows | Launch new instance (on a window thumbnail: close that window) | Desktop Entry / Window `M3ContextMenu` (Pin, Actions, Close) | Cycle through that application's windows |
| **Notification Toast** | Invoke default action & focus originating window | Dismiss | Context menu: Mute app, Notification settings, Dismiss | Scroll the stack when more than 3 are queued |
| **Notification Bell** | Toggle Notification Center (`SC-04`) | Toggle Do Not Disturb (OSD confirms) | Context menu: DND schedules, Clear all | None |

### 2.2 Pointer Accelerator Safety Rules

1. **Never the only path**: Every middle-click, right-click, scroll, or modifier action also exists as a visible control in the matching popover or context menu.
2. **Nothing destructive or session-wide on accelerators**: Closing windows, switching `desktopMode`, logging out, or clearing data is never bound to middle-click, scroll, or modifier+scroll on persistent bars. Middle-click is physically coupled to the scroll wheel, so accidental presses while scrolling are common.
3. **Right-click means menu**: Right-click always opens a context menu. It never performs a direct action such as skipping a track.
4. **Visible feedback**: Every accelerator that changes state confirms it immediately (OSD pill, pill state change, or toast).
5. **Hold to confirm, never confirm-twice dialogs**: Actions that end the session or lose work (Logout, Reboot, Shutdown) confirm by holding the control or its key for `2s` while progress fills the control itself (`M3HoldToConfirm`, `02-buttons-and-chips.md` §7). Releasing early cancels, and a tap plays a visual nudge (the fill peeks and drains) instead of showing explanatory text; screen readers get the "Hold for 2 seconds…" announcement. Reversible actions are never hold-gated. `Tokens.confirmByHold: false` (and screen readers) switch to press-twice confirmation.

### 2.3 Wheel Accumulation Contract

Touchpads emit many small wheel events; mice emit `120`-unit notches. Time-based debouncing either drops mouse notches or races on touchpads, so all shell wheel handling accumulates distance instead:
- Accumulate `event.angleDelta.y` and emit one logical step each time `|accumulator| >= Tokens.metrics.wheelStepAngle` (`120`).
- For high-resolution touchpads (`event.pixelDelta.y !== 0`), accumulate pixels and step every `Tokens.metrics.touchpadStepPixels` (`40px`).
- **Value controls** (volume, brightness, seek, sliders) follow the physical wheel: negate the delta when `event.inverted` is true, so wheel-up always means "more" (`M3BarPill.physicalWheelDirection: true`).
- **Navigation** (workspace strip, notification stack, carousel) uses the delta as delivered, so it follows the system natural-scrolling preference.
- Reset the accumulator when the pointer leaves the target.

---

## 3. Keyboard Focus, Activation & Traversal Contract

1. **Focus-Visible Heuristic (`Tokens.keyboardModality`)**:
   - The focus ring renders only when `activeFocus && Tokens.keyboardModality`. Surfaces set `Tokens.keyboardModality = true` on `Tab`, `Shift+Tab`, arrow keys, or `Ctrl+J/K/H/L`, and set it back to `false` on any pointer press. Mouse users never see stray rings; keyboard users always do.
2. **Activation Keys** (implemented once in `M3Surface`, inherited everywhere):
   - `Return` / `Enter` / `Space` → `clicked()`
   - `Menu` key / `Shift+F10` → `rightClicked()` (keyboard path to every context menu)
   - `Escape` → unwinds one level per `02-keyboard-navigation-and-submaps.md` §2
3. **Traversal Order**: `activeFocusOnTab: true` on every interactive primitive; Tab order follows visual reading order (left-to-right, top-to-bottom). Arrow keys move within a group (tile grid, workspace strip, menu rows).
4. **Mode Independence**: Keyboard bindings never depend on `Tokens.desktopMode`. Arrow keys, `Enter`, `Space`, `Tab`, and `Escape` work in both modes; Vim aliases (`h/j/k/l`, `[`/`]`) are additive in both modes. Desktop mode changes layout and defaults, never which keys work.

---

## 4. Hit Targets & Fitts's Law Contract

1. **Minimum Targets**:
   - Bar targets (pills, tray icons): at least `Tokens.metrics.minPointerTarget` wide (`24px` compact — the WCAG 2.5.8 floor — or `32px` otherwise) and the **full bar height** tall.
   - Dense repeated indicators (workspace cells) may use the `24px` floor in every density, because their hit height spans the full bar plus the edge extension and the cells are contiguous. This keeps the strip compact without shrinking the effective target.
   - Standalone icon buttons in popovers: `Tokens.metrics.minIconButtonTarget` (`36px × 36px`), even when the glyph is `20px`.
   - Quick Settings tiles: `176px × 60px` (`comfortable`).
2. **Visual Size ≠ Hit Size**: Small elegant visuals (an `8–16px` workspace dot, a `20px` glyph) sit centred inside a larger invisible hit cell. Adjacent cells in a bar are contiguous, with no dead gaps between targets.
3. **Edge Hit Extension**: Bars with a margin (any edge, bar or island mode, `fit`-length docks) keep the margin visually, but their input region and per-widget hit areas extend through the bar's edge gap (`BarService.edgeGap(bar)`: `marginVertical` for top/bottom bars, `marginHorizontal` for left/right bars) to the physical screen edge. Throwing the pointer against the edge (an "infinitely tall" Fitts target) still hits the pill underneath. Implementation pattern: `05-wayland-layershell-spatial.md` §3.2.
4. **Hover Intent**: Edge reveal strips (auto-hidden or dodged bars) require a `120ms` dwell, so passing over the edge never triggers a reveal.

---

## 5. Layout Stability Rule (No Targets Moving Under the Pointer)

1. **No hover width changes in bars**: Hovering a bar pill never changes its width. Extra detail (artist name, battery time remaining, full window title) appears in an `M3Tooltip` or rich tooltip instead.
2. **Deferred reflow**: Width changes the user did not cause (title changes, the Privacy Pill collapsing back to an icon, tray items appearing) are deferred while the pointer is inside that bar zone and applied `400ms` after it leaves.
3. **Security exception**: The *appearance* of the Privacy Pill and the Recording Pill is never deferred.
4. **Bounded attention cues**: Urgent pulses, launch bounces, and attention swings run at most 3 cycles, then hold a static urgent state (badge or `tertiaryContainer` fill).

---

## 6. Accessibility Modes & Assistive Technology Contract

### 6.1 First-Class Accessibility Modes

| Switch | What Changes | Source of Truth |
|---|---|---|
| `Tokens.reducedMotion` | Spatial springs disabled, decorative loops stopped, effects collapse to `100ms` crossfades (`03-motion-and-morphing.md` §1.3) | `~/.config/mat-shell/config.json`; mirrors GNOME `org.gnome.desktop.interface enable-animations` when present |
| `Tokens.reducedTransparency` | All tiers opaque, compositor blur off | `config.json` |
| `Tokens.highContrast` | Opaque tiers, full-strength `outline` borders, `3px` focus ring | `config.json`; mirrors `org.gnome.desktop.a11y.interface high-contrast` |
| `Tokens.textScale` (`1.0` / `1.15` / `1.3`) | All type roles and bar chrome scale together | `config.json`; mirrors `org.gnome.desktop.interface text-scaling-factor` |
| `Tokens.confirmByHold` (default `true`) | `false` replaces 2s press-and-hold with press-twice confirmation for destructive actions (for users who find holding difficult) | `config.json`; Control Center accessibility sub-sheet |

All four switches apply live with no shell restart, and are reachable from the Control Center accessibility sub-sheet and `qs ipc call shell setA11y <switch> <value>`.

### 6.2 Screen Reader Contract (AT-SPI / Orca via Qt Accessibility)

1. Every interactive primitive sets `Accessible.role`, `Accessible.name`, and `Accessible.onPressAction`. Icon-only controls (bar pills, tray icons, themed dock icons, polygon buttons) MUST provide a name.
2. Live values expose `Accessible.description` (e.g., `"Volume 72 percent"`, `"Battery 86 percent, 4 hours 12 minutes remaining"`).
3. Transient surfaces announce themselves without stealing focus: toasts and OSD changes call `Accessible.announce()` (Qt 6.8+); Critical toasts use `Accessible.role: Accessible.AlertMessage`.
4. Decorative layers (polygon outlines, duotone back layers, protection shadows) set `Accessible.ignored: true`.

### 6.3 Text Entry Safety (Password Fields)

Every password field (Lock Screen, Polkit, Wi-Fi passphrase) shows a **Caps Lock warning** (`"Caps Lock is on"` + `keyboard_capslock` icon in `tertiary`) and the active keyboard layout (`EN`, `DE`) while focused. Authentication errors always include text (`"Incorrect password — 2 attempts left"`), never colour or shake alone.
