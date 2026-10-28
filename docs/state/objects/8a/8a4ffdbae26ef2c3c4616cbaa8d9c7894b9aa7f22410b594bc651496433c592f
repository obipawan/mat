# Foundation 03 — Material 3 Expressive Motion Physics & Shape Morphing

> **Module**: `design-system/foundations/03-motion-and-morphing.md`
> **Token Singleton**: `Tokens.motion` (`MotionTokens.qml`) & `Tokens.shape` (`ShapeTokens.qml`)

---

## 1. The M3 Expressive Dual-Spring Philosophy

Material 3 Expressive replaces mechanical linear/bezier timing with **physics-based springs** split strictly into two categories based on what property is being animated:

### 1.1 Spatial Springs vs. Effects Springs

| Spring Category | Target QML Properties | Damping Ratio (`ζ`) | Stiffness | Overshoot? | Why? |
|---|---|---|---|---|---|
| **Spatial Springs** (`springFastSpatial`, `springDefaultSpatial`, `springSlowSpatial`) | `x`, `y`, `width`, `height`, `implicitWidth`, `implicitHeight`, `scale`, `radius`, `rotation` | `0.65` – `0.78` (Underdamped) | `260` – `700` | **Yes** (`3%–8%` natural bounce) | Gives physical mass, elasticity, and tactile responsiveness to pills, popovers, sliders, and workspace indicators. |
| **Effects Springs** (`springFastEffects`, `springDefaultEffects`) | `color`, `opacity`, `border.color`, `blurRadius` | `1.0` (Critically damped) | `600` – `1200` | **No** (`0%` overshoot) | Prevents visual artifacts (opacity must never bounce above `1.0` or below `0.0`; colors must not flash past their target hue). |

### 1.2 Spring Token Matrix

| Token Name | Damping (`damping`) | QtQuick `spring` | Settle Time (approx) | Canonical Shell Use Cases |
|---|---|---|---|---|
| `Tokens.motion.springFastSpatial` | `0.65` | `7.0` | `~250ms` | Workspace pill width expansion (`16px -> 36px`), Button/Tile press corner morph (`radius.full -> radius.md`), Switch thumb translation & width stretch |
| `Tokens.motion.springDefaultSpatial` | `0.72` | `4.5` | `~350ms` | Bar widget pill morphing into `ControlCenter` / `CalendarWeatherPanel` / `MediaPopover`, Quick Tile sub-sheet height accordion, bar reveal/hide and bar ↔ island morph |
| `Tokens.motion.springSlowSpatial` | `0.78` | `2.6` | `~500ms` | `WorkspaceOverview` zoom-out entrance, `LockScreen` hero clock vertical slide, `WallpaperPicker` card carousel |
| `Tokens.motion.springFastEffects` | `1.00` | `12.0` (`120ms`) | `120ms` | Pointer hover (`8%`) and press (`12%`) state-layer fade, keyboard focus ring appearance |
| `Tokens.motion.springDefaultEffects` | `1.00` | `6.0` (`220ms`) | `220ms` | Dynamic `matugen` theme recoloring, modal backdrop scrim fade, `opaque_tonal` <-> `frosted_tonal_glass` switch |

### 1.3 Reduced Motion Contract (`Tokens.reducedMotion`)

Expressive motion is opt-out, never mandatory. When the user enables Reduced Motion (config file, Control Center accessibility tile, or GNOME `enable-animations = false`):

| Motion Class | Normal Behavior | Reduced Motion Behavior | Binding |
|---|---|---|---|
| Spatial (`x`, `y`, `width`, `height`, `scale`, `rotation`, `radius`) | Underdamped springs | Jumps straight to the target value | `Behavior on x { enabled: Tokens.motion.spatialMotionEnabled; SpringAnimation { ... } }` |
| Effects (`opacity`, `color`, scrim) | `120ms` / `220ms` | `100ms` crossfade (`reducedMotionFadeMs`) | Automatic through `springFastEffects.durationMs` / `springDefaultEffects.durationMs` |
| Decorative loops (polygon rotation, seekbar wave, urgent pulses, launch bounces, bell swing, shutter flash) | Running | Stopped; replaced by a static state | `running: Tokens.motion.decorativeMotionEnabled && <condition>` |
| Error feedback (password shake) | Horizontal spring shake | Error colour + error text only | `shakeAnim.running: Tokens.motion.decorativeMotionEnabled` |

**Expressive Bounce (`Tokens.expressiveSprings`)**: A middle ground in Settings → Animations for users who like motion but not overshoot. When `false`, every spatial spring keeps its stiffness but becomes critically damped (`damping: 1.0`, via `MotionTokens.overshootEnabled`), so elements still travel but settle without bouncing. Effects, decorative loops, and Reduced Motion behave as above.

---

## 2. Interactive Corner Radius Morphing (Shape Expressiveness)

A defining hallmark of Material 3 Expressive on desktop is **dynamic shape morphing**: UI elements change their corner radius in response to pointer pressure, selection state, and grouping.

### 2.1 Shape Morphing Rules

```text
  [ RESTING CAPSULE ]          [ PRESSED SQUIRCLE ]          [ EXPANDED PANEL ]
   radius: height/2              radius: 12px (md)             radius: 24px (xl)
  ╭─────────────────╮           ╭─────────────────╮           ╭─────────────────────────╮
  │  󰤨  Wi-Fi  󰅀    │  ──Press─►│  󰤨  Wi-Fi  󰅀    │ ──Open──► │ Wi-Fi Networks          │
  ╰─────────────────╯           ╰─────────────────╯           │ • Home-5G (Connected)   │
                                                              ╰─────────────────────────╯
```

| Component Type | Idle / Inactive Radius | Hovered Radius | Pressed Radius (Squish) | Active / Toggled / Expanded Radius |
|---|---|---|---|---|
| **Bar Widget Pill (`M3BarPill`)** | `height / 2` (`full`) | `height / 2` | `Tokens.shape.md` (`12px`) | `Tokens.shape.lg` (`16px`) |
| **Quick Settings Tile** | `Tokens.shape.lg` (`16px`) | `Tokens.shape.lg + 4` (`20px`) | `Tokens.shape.md` (`12px`) | `height / 2` (`full` pill) |
| **M3 Button (`Filled` / `Tonal`)** | `height / 2` (`full`) | `height / 2` | `Tokens.shape.sm` (`8px`) | `Tokens.shape.md` (`12px`) |
| **Workspace Indicator Dot/Pill** | `height / 2` (`8px` circle) | `Tokens.shape.sm` (`8px`) | `Tokens.shape.xs` (`4px`) | `height / 2` (`36px × 14px` pill) |
| **Media Play/Pause Button** | `height / 2` (Circle when paused) | `Tokens.shape.lg` (`16px`) | `Tokens.shape.sm` (`8px`) | `Tokens.shape.md` (`12px` squircle when playing) |
| **Segmented Group Item** | Outer ends: `full`; Inner seam: `4px` (`xs`) | Inner seam: `8px` (`sm`) | All corners: `8px` (`sm`) | Selected item: `full` (`9999px`) |

---

## 3. Shared Container Transform (Pill-to-Popover Morphing)

When a user clicks a bar widget (such as the Control Center pill, Clock/Date pill, or Media pill, on any bar), the popover does not simply fade in detached from the bar. Instead, it executes a **Shared-Origin Container Transform**:

1. **Origin Anchor**: The popover's `transformOrigin` (or initial clipped rect `[originX, originY, originWidth, originHeight]`) starts aligned with the screen coordinates of the triggering `M3BarPill`, and the container unfolds away from that pill's bar edge toward the screen centre: downward from a top bar, upward from a bottom bar, sideways from a left or right rail (`ShellState.popoverOriginEdge`, `M3Popover` origin-edge placement). Popovers opened from the keyboard or IPC use the trigger rect registered in `ShellState.registerTrigger()`, so they still grow out of the correct pill.
2. **Spatial Unfold**:
   - `width`: animates from `triggerPill.width` to `panelTargetWidth` via `Tokens.motion.springDefaultSpatial`.
   - `height`: animates from `triggerPill.height` to `panelTargetHeight` via `Tokens.motion.springDefaultSpatial`.
   - `radius`: morphs from `triggerPill.height / 2` (`15px`) to `Tokens.shape.xl` (`24px`).
3. **Content Stagger**:
   - Pill summary contents fade out over `80ms` (`durationShort2`).
   - Popover internal bento cards fade in (`opacity: 0 -> 1`) and slide `8px -> 0px` vertically starting at `t = 60ms` over `180ms` (`curveEmphasizedDecelerate`).
4. **Reverse Collapse on Dismiss**:
   - Pressing `Escape` or clicking outside reverses the spring back toward the trigger pill while fading `opacity: 1 -> 0` over `150ms`.

---

## 4. Canonical QML Spring Behavior Snippet

```qml
import QtQuick
import MatShell.Tokens

Rectangle {
    id: expressivePill
    property bool hovered: false
    property bool pressed: false
    property bool active: false

    implicitWidth: active ? 44 : 24
    implicitHeight: 24
    radius: Tokens.shape.morphPillRadius(height, hovered, pressed, active)
    scale: pressed ? 0.96 : 1.0

    Behavior on implicitWidth {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
            epsilon: Tokens.motion.springFastSpatial.epsilon
        }
    }
    Behavior on radius {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
            epsilon: Tokens.motion.springFastSpatial.epsilon
        }
    }
    Behavior on scale {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation {
            spring: Tokens.motion.springFastSpatial.spring
            damping: Tokens.motion.springFastSpatial.damping
        }
    }
}
```

---

## 5. M3 Expressive Non-Rectangular Polygon Catalog & Placement Guardrails

Beyond rounded rectangles, Material 3 Expressive defines a library of **organic scalloped and geometric polygons** (`Tokens.shape.polygon*`). To prevent visual chaos or wasted desktop space, polygon shapes obey a strict **Expressive vs. Functional Placement Contract**:

### 5.1 The 7 Canonical M3 Expressive Polygons

```text
   SCALLOP_12 ("Cookie")      CLOVER_4 (4-Leaf)       FLOWER_8 (8-Petal)        HEXAGON / DIAMOND
      ╭─╭─╭─╭─╮               ╭───╮   ╭───╮             ╭──╭──╭──╮                 ╱‾‾‾‾‾╲
     ╭╯       ╰╮              │   ╰───╯   │            ╭╯        ╰╮               ╱       ╲
     │  10:09  │              ╰─╮ Album ╭─╯            │ 26  June │               │ 13:57 │
     ╰╮       ╭╯              ╭─╯  Art  ╰─╮            ╰╮        ╭╯               ╲       ╱
      ╰─╰─╰─╰─╯               │   ╭───╮   │             ╰──╰──╰──╯                 ╲_____╱
                              ╰───╯   ╰───╯
```

| Polygon Token | Geometry (`ShapeTokens.polygonGeometry`) | Safe Content Ratio | Pressed Morph Target | Approved Shell Placements | Forbidden Placements (Must Stay Rectangular/Pill) |
|---|---|---|---|---|---|
| `polygonScallop12` (`"scallop_12"`) | 12 round bumps, `depth: 0.10`, `sharpness: 0.5` ("cookie") | `0.88` | Circle via `springFastSpatial` | Media `Previous`/`Next` (`SC-06`), Weather badge, Battery ring & Widget Peek trigger (`SC-15`, `SC-02` `widgetPeek`) | Bar text capsules, Notification cards, Text inputs |
| `polygonClover4` (`"clover_4"`) | 4 round leaves with tight notches, `depth: 0.30`, `sharpness: 0.45` | `0.68` | Circle | Album art mask (`SC-06`, `SC-15`), primary Play/Pause, Lock Screen avatar (`SC-10`) | Multi-line text containers, Buttons with labels |
| `polygonFlower8` (`"flower_8"`) | 8 round petals, `depth: 0.20`, `sharpness: 0.5` | `0.78` | Circle | Desktop Date badge (`"26 Oct"`), Petal Media hero ring (`SC-15`) | List rows, Sliders, Context menus |
| `polygonHexagon` (`"hexagon"`) | Rounded flat-top hexagon, `sharpness: 18` | `0.88` | Circle | Editorial Clock tile & Events widget (`SC-15`), Polkit hero shield (`SC-12`) | Scrollable lists, Taskbar app chips |
| `polygonDiamond` (`"diamond"`) | Rounded rhombus (vertex at top), `sharpness: 9` | `0.74` | Circle | CPU/RAM gauges with values of 4 characters or fewer (`SC-15`), password dot entry frame (`SC-10`) | Primary navigation bars, any label longer than 4 characters |
| `polygonTriangle` (`"rounded_triangle"`) | Rounded triangle (vertex at top), `sharpness: 6` | `0.54` | Circle | **Icon-only** badges, e.g. the AI sparkle beside the Search widget (`SC-15` W8) | Any text, numbers, inputs, or multi-element clusters |
| `polygonSlantedPill` (`"slanted_pill"`) | Capsule with `-10°` horizontal skew (`M3Surface` + skew transform) | Text box unskewed by `+10°` | Unskews to `0°` on press | Desktop greeting & date tags (`SC-15`) — one short label each | Bar workspace strip, buttons inside bars |

### 5.2 Polygon Content & Motion Rules

1. **Safe content circle**: Content inside an `M3PolygonSurface` stays within a centred circle of diameter `width × 0.92 × safeContentRatio` (`Tokens.shape.polygonSafeContentRatio(kind)`). Text never runs into lobes, notches, or corners.
2. **Minimum size**: Interactive polygons are at least `40px`. Below that, lobes read as noise and the hit target becomes too small.
3. **Rotate the mask, never the content**: Slow rotation (`360° / 28s`) turns only the polygon outline or clipping mask. Album art, glyphs, and numbers stay upright and readable.
4. **Motion budget**: At most one continuously moving polygon per surface. It moves only while its content is live (media playing), the surface is visible and not receded, and `Tokens.motion.decorativeMotionEnabled` is true.
5. **Hit area**: The pointer hit area is the polygon's square bounding box, which is always more generous than the shape, so notches never swallow clicks.

