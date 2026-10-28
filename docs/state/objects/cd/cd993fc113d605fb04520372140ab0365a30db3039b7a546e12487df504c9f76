# Foundation 01 — Material 3 HCT Color System & Dual-Surface Engine

> **Module**: `design-system/foundations/01-color-and-surfaces.md`
> **Token Singleton**: `Tokens.color` (`design-system/tokens/qml/ColorTokens.qml`)
> **W3C Source**: `design-system/tokens/m3-tokens.json`

---

## 1. HCT Perceptual Color Space & Dynamic Wallpaper Extraction

Material Design 3 uses the **HCT (Hue, Chroma, Tone)** color space, which guarantees perceptual luminance (`Tone 0..100`) regardless of hue or chroma. In a desktop environment where users frequently customize wallpapers, hardcoded static themes break visual cohesion.

### 1.1 Dynamic Extraction Pipeline (`matugen` ≥ 4.0)

Artifacts live in `design-system/tokens/matugen/` and install to `~/.config/mat-shell/matugen/`:

| File | Role |
|---|---|
| `config.toml` | matugen config: non-interactive source selection, fallback colour, harmonized status colours, one template |
| `theme.json.tpl` | Template that writes **both polarities** (`dark` + `light`, 55 roles each, camelCase keys) plus `sourceColor` |
| `theme.baseline.json` | Exactly what matugen writes for the M3 baseline seed (`matugen color hex "#6750A4" -t scheme-tonal-spot`); `ColorTokens` defaults mirror it |

1. The user applies a wallpaper in `WallpaperThemePicker` (`14-wallpaper-and-theme-picker.md`). `ThemeService` sets it with `swww` (the shell owns the transition), then runs:
   `matugen image <wallpaper> -c ~/.config/mat-shell/matugen/config.toml -t <Tokens.schemeVariant> --source-color-index 0 [--contrast 1.0]`
2. matugen extracts the source colour, generates the scheme for both polarities (plus the harmonized `success` / `warning` custom colours), and renders `theme.json.tpl` to `~/.config/mat-shell/theme.json`.
3. `ColorTokens.qml` watches that file (`FileView` + `JsonAdapter`, `150ms` debounce) and exposes every role as a **read-only binding** to the `dark` or `light` block. Toggling `Tokens.darkMode` swaps blocks instantly without re-running matugen, and reloads can never break a binding.
4. Colour changes are animated by consumers, never by the singleton: surfaces already carry `Behavior on color { ColorAnimation { duration: Tokens.motion.springDefaultEffects.durationMs } }`. Animating 57 singleton roles would re-evaluate every colour binding in the shell on each frame.

### 1.2 Supported M3 Scheme Variants (`-t`)
| Scheme Variant | Chroma Profile | Recommended Desktop Usage | Status Colours |
|---|---|---|---|
| `scheme-tonal-spot` | Moderate chroma (`C=36` primary, `C=16` secondary) | **Default** — balanced, low eye fatigue for long coding/desktop sessions | Harmonized |
| `scheme-vibrant` | High chroma, energetic secondary/tertiary | Colourful anime/digital art wallpapers | Harmonized |
| `scheme-expressive` | Hue-rotated primary/tertiary with energetic contrast | Creative workstations & M3 Expressive showcase | Harmonized |
| `scheme-content` / `scheme-fidelity` | Follows the source's own chroma | Photographic wallpapers; album art (`§4`) | Harmonized |
| `scheme-rainbow` / `scheme-fruit-salad` | Playful hue spreads | Experimental themes | Harmonized |
| `scheme-neutral` | Near-achromatic (`C=8–12`) subtle tint | Minimalist / distraction-free tiling setups | **Fixed fallback** |
| `scheme-monochrome` | Pure grayscale (`C=0`), luminance-only hierarchy | High-contrast monochrome setups | **Fixed fallback** |

### 1.3 matugen Integration Contract

1. **Version**: matugen ≥ 4.0 (template keywords `{{colors.<role>.<dark|light|default>.hex}}`, `--contrast`, `--source-color-index`, `--dry-run`). Verified against the matugen 4.2.0 sources.
2. **Never interactive**: When an image yields several candidate colours and no terminal is attached, matugen 4.x exits with *"Multiple source colors found … a terminal was not detected"*. `config.toml` sets `source_color_index = 0` (4.2+), and `ThemeService` always passes `--source-color-index 0` (4.0 / 4.1). On non-zero exit, `ThemeService` keeps the previous `theme.json` and shows a toast with matugen's stderr.
3. **Roles**: matugen emits 49 scheme roles; the template uses 47 (it skips the deprecated `background` / `on_background` aliases of `surface` / `on_surface`) plus `source_color` and 8 status roles. `scripts/verify-design-system.sh` checks template ↔ baseline ↔ `ColorTokens` key parity.
4. **Status colours**: `success` and `warning` are matugen `custom_colors` (`blend = true`), harmonized toward the wallpaper. matugen builds custom colours through the active variant, so under `scheme-monochrome` / `scheme-neutral` they would turn gray; `ColorTokens.harmonizedStatus` swaps in fixed fidelity-generated hues for those schemes. On a wallpaper of the same hue, `success` may match the accent, which is acceptable because status is never conveyed by colour alone (`04-interaction-states-and-input.md` §1).
5. **Privacy indicator**: `privacyMicCam` is fixed (never wallpaper-derived), so the mic/camera warning is always the same unmistakable green.
6. **Contrast**: `Tokens.highContrast` makes `ThemeService` regenerate with `--contrast 1.0` (Material's high-contrast level), in addition to the opaque tiers and `outline` borders.
7. **Wallpaper ownership**: `config.toml` has no `[config.wallpaper]` section; matugen never sets the wallpaper (avoids double transitions).
8. **Other apps**: Additional templates (GTK, terminals) may use `.default` and therefore need `-m dark|light`; `ThemeService` passes `-m` from `Tokens.darkMode` and re-runs matugen on polarity changes only when such templates are installed.

---

## 2. The 5-Tier Configurable Dual-Surface Engine

Desktop shells differ from mobile apps: shell panels float above arbitrary application windows (terminals, browsers, games, video players). Purely translucent panels suffer from catastrophic contrast loss over bright windows, whereas purely flat opaque panels can feel heavy over desktop wallpapers.

Our design system solves this with a **5-Tier Dual-Surface Engine** controlled by `Tokens.surfaceMode`:
- **`"frosted_tonal_glass"` (Default)**: Applies compositor background blur (`64px` radius + `2%` luminance noise) and `78%` alpha **ONLY to Tier 0 (the outermost shell container)**, while keeping inner cards (`Tier 1: 90%`), interactive controls (`Tier 2: 96%`), and active accents (`Tier 4: 100%`) nearly or fully opaque.
- **`"opaque_tonal"`**: Renders every tier at `100%` alpha using M3 tonal surface containers (`surfaceContainerLowest` through `surfaceContainerHighest`), matching ChromeOS Material You.
- **Accessibility override**: `Tokens.reducedTransparency` or `Tokens.highContrast` forces the `opaque_tonal` alphas and disables compositor blur regardless of `surfaceMode`; `highContrast` additionally swaps every tier hairline for a full-strength `outline` border (`ColorTokens.surfaceBorder()` handles both automatically).

### 2.1 Surface Tier Specification Table

| Tier | Token Helper | M3 Base Role | Dark Tone (`T`) | Light Tone (`T`) | `opaque_tonal` Alpha | `frosted_tonal_glass` Alpha | Compositor Blur | Border (`surfaceBorder(tier)`) | Assigned Shell Elements |
|---|---|---|---|---|---|---|---|---|---|
| **Tier 0** | `Tokens.color.surfaceTier(0)` | `surfaceContainer` | `T12` (`#211F24`) | `T94` (`#F2ECF4`) | `100%` | `78%` | `64px` + `2%` noise | `1px` `outlineVariant` @ `16%` (opaque) / `28%` (glass) | Root backgrounds: bars and islands, Control Center, Notification Center, Launcher, Popovers, Settings window |
| **Tier 1** | `Tokens.color.surfaceTier(1)` | `surfaceContainerHigh` | `T17` (`#2B292F`) | `T92` (`#ECE6EE`) | `100%` | `90%` | `0px` (inherits root) | `1px` `outlineVariant` @ `12%` (opaque) / `18%` (glass) | Bento section cards, Notification cards, Inactive Quick Settings tiles, Media player card, Calendar card |
| **Tier 2** | `Tokens.color.surfaceTier(2)` | `surfaceContainerHighest` | `T22` (`#36343A`) | `T90` (`#E6E0E9`) | `100%` | `96%` | `0px` | `0px` (`1px` `outlineVariant` @ `8%` in glass) | Search input fields, bar widget pills (`M3BarPill`), Inactive slider tracks, Expandable sub-sheets |
| **Tier 3** | `Tokens.color.surfaceTier(3)` | `surfaceContainerLow` | `T10` (`#1D1B20`) | `T96` (`#F8F2FA`) | `100%` | `84%` | `0px` | `1px` inner `outlineVariant` @ `10%` | Recessed wells: Workspace strip trough, Switch off-track, Segmented button trough, Code/log viewer box |
| **Tier 4** | `Tokens.color.surfaceTier(4)` | `primary` (or `primaryContainer`) | `T80` (`#CFBDFE`) | `T40` (`#65558F`) | `100%` | `100%` (Never translucent) | `0px` | `0px` | Active Quick Settings tile, Focused Workspace pill, Slider active track, Primary CTA button |

Hex examples are matugen's output for the baseline seed `#6750A4` (`tokens/matugen/theme.baseline.json`); at runtime every value comes from the wallpaper.

---

## 3. Complete Role-Pairing & Contrast Contract

**Non-Negotiable Rule**: Never pair a foreground text/icon role with an arbitrary surface. Always use the canonical `on*` partner role so contrast exceeds **WCAG AA (`4.5:1` for text, `3.0:1` for UI glyphs)** in both Dark and Light modes:

| Background Token | Primary Text / Active Icon | Secondary / Supporting Text | Border / Divider Token |
|---|---|---|---|
| `surface` / `surfaceContainer*` (Tiers 0–3) | `onSurface` | `onSurfaceVariant` | `outlineVariant` |
| `primary` (Tier 4 High Emphasis) | `onPrimary` | `onPrimary` @ `80%` alpha | None |
| `primaryContainer` (Tier 4 Tonal Emphasis) | `onPrimaryContainer` | `onPrimaryContainer` @ `80%` alpha | `primary` @ `25%` alpha |
| `secondaryContainer` (Selected Chip / Sub-item) | `onSecondaryContainer` | `onSecondaryContainer` @ `80%` alpha | None |
| `tertiaryContainer` (Submap Badge / Special Accent) | `onTertiaryContainer` | `onTertiaryContainer` @ `80%` alpha | None |
| `errorContainer` (Critical Toast / Destructive Confirm) | `onErrorContainer` | `onErrorContainer` @ `85%` alpha | `error` @ `40%` alpha |
| `inverseSurface` (Tooltips / Snackbar) | `inverseOnSurface` | `inversePrimary` (action link) | None |
| `successContainer` / `warningContainer` (Status Toasts, Battery Saver, Charging) | `onSuccessContainer` / `onWarningContainer` | Same role @ `85%` alpha | `success` / `warning` @ `40%` alpha |
| `privacyMicCam` (Hardware Mic/Camera Active Pill — fixed, never wallpaper-derived) | `onPrivacyMicCam` | `onPrivacyMicCam` | None |

---

## 4. Content-Driven Local Color Overrides (MPRIS Album Art)

While the global shell uses the wallpaper-derived `Tokens.color` singleton, **the Media Player Popover (`06-media-player-popover.md`) and the bar `media` widget** support a local scoped palette extracted from `mpris:artUrl`:
1. When `MprisPlayer.trackArtUrl` changes (download remote `https://` art to `~/.cache/mat-shell/art/` first), run via `Quickshell.Io.Process`:
   `matugen image <artPath> --dry-run --json hex -t scheme-content --source-color-index 0 -c ~/.config/mat-shell/matugen/config.toml`
   - `--dry-run` is mandatory: without it matugen also renders `theme.json` and would re-theme the whole shell on every track change.
   - `scheme-content` keeps the artwork's own hue and chroma (the Material recommendation for content-derived colour).
2. Parse stdout. matugen 4.x JSON shape: `colors.<snake_case_role>.<dark|light>.color` (for example `colors.primary_container.dark.color`). Bind the Media Card's local `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondaryContainer`, and `onSecondaryContainer` to the block matching `Tokens.darkMode`. Fall back to `Tokens.color.*` when there is no art or matugen fails.
3. Cache results per art URL (the same album must not re-run matugen) and animate local colour bindings with `ColorAnimation { duration: Tokens.motion.springDefaultEffects.durationMs }`.

---

## 5. Wallpaper Legibility Guard (Content Rendered Directly on the Wallpaper)

Desktop Widgets (`SC-15`) and the Lock Screen's secondary outputs (`SC-10`) draw some content straight onto an arbitrary user wallpaper, where no tonal surface guarantees contrast. These rules keep the expressive look without ever losing legibility:

1. **Container by default**: Only hero text of `45px` or larger (`displayEditorial`, `displayExpressiveHero`) may sit on the bare wallpaper. Every other label, value, date, or greeting MUST sit on a Tier 1/2 container, an `M3PolygonSurface`, or a pill.
2. **Protection shadow**: Bare hero text renders through `MultiEffect { shadowEnabled: true; shadowColor: Tokens.color.scrim; shadowOpacity: 0.35; shadowBlur: 0.6; shadowVerticalOffset: 2 }` so glyph edges stay defined over busy imagery.
3. **Luminance probe**: Whenever the wallpaper or a widget's position changes, `ThemeService` samples the wallpaper region beneath each bare-text widget:
   `magick <wallpaper> -crop <w>x<h>+<x>+<y> -resize 1x1 -format "%[fx:luminance]" info:` → `regionLuma` (`0..1`).
4. **Automatic backplate**: If the estimated contrast between the hero foreground and `regionLuma` falls below `3:1` (WCAG large-text floor), the widget switches to its backplate variant (`Tokens.color.surfaceTier(1)`, `radius: Tokens.shape.xl`) until the wallpaper changes. The user never has to fix illegible widgets by hand.

---

## 6. Canonical QML Usage Pattern

```qml
import QtQuick
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: controlCenterWindow
    color: "transparent"

    Rectangle {
        id: rootShellContainer
        anchors.fill: parent
        radius: Tokens.shape.xl
        // Automatically switches between 78% glass and 100% opaque tonal
        color: Tokens.color.surfaceTier(0)
        border.width: 1
        border.color: Tokens.color.surfaceBorder(0)

        Behavior on color {
            ColorAnimation { duration: Tokens.motion.springDefaultEffects.durationMs }
        }
    }
}
```
