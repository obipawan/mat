# Foundation 02 — Desktop Typography, Tabular Numerals & Variable Iconography

> **Module**: `design-system/foundations/02-typography-and-iconography.md`
> **Token Singleton**: `Tokens.typography` (`design-system/tokens/qml/TypographyTokens.qml`)

---

## 1. Desktop Type Scale Adaptation

Mobile Material 3 uses `16sp` for `bodyLarge` and `14sp` for `bodyMedium`. On desktop monitors viewed at `50cm–75cm`, `16px` body text inside status bars, notifications, and control panels looks oversized and wastes horizontal space. Our desktop-adapted M3 type scale tunes `body` and `label` roles for crisp desktop information density while preserving expressive `display` and `headline` roles for hero moments (Lock Screen, Calendar Date header, Weather).

### 1.1 Complete 15-Role Desktop Type Scale

| Role Token | Font Family | Size (`px`) | Line Height (`px`) | Weight | Tracking (`px`) | Primary Desktop Shell Usage |
|---|---|---|---|---|---|---|
| `displayLarge` | `familyDisplay` (`Google Sans Flex`) | `57` | `64` | `600` (DemiBold) | `-0.25` | Lock Screen hero clock (`10-lock-screen.md`) |
| `displayMedium` | `familyDisplay` | `45` | `52` | `600` | `0.0` | Weather popover hero temperature (`05-calendar-and-weather.md`) |
| `displaySmall` | `familyDisplay` | `36` | `44` | `600` | `0.0` | Calendar popover current day/date hero |
| `headlineLarge` | `familyDisplay` | `32` | `40` | `600` | `0.0` | Welcome / Onboarding modal hero |
| `headlineMedium` | `familyDisplay` | `28` | `36` | `600` | `0.0` | Power Menu confirmation header (`11-power-and-session-menu.md`) |
| `headlineSmall` | `familyDisplay` | `24` | `32` | `600` | `0.0` | Calculator live result in Launcher (`08-app-and-command-launcher.md`) |
| `titleLarge` | `familyDisplay` | `20` | `28` | `600` | `0.0` | Popover section headers (Notification Center title, Theme Studio title) |
| `titleMedium` | `familySans` (`Google Sans Flex`) | `15` | `22` | `600` | `0.1` | Media player track title, Polkit dialog title, Launcher search input |
| `titleSmall` | `familySans` | `13` | `18` | `600` | `0.1` | Notification card title, Quick Settings sub-sheet header, Calendar month title |
| `bodyLarge` | `familySans` | `15` | `22` | `400` (Regular) | `0.15` | Launcher item title, Polkit description |
| `bodyMedium` | `familySans` | `13` | `18` | `400` | `0.15` | Notification body text, Settings list row, Clipboard preview |
| `bodySmall` | `familySans` | `12` | `16` | `400` | `0.2` | Secondary metadata, Media artist name, Weather condition subtitle |
| `labelLarge` | `familySans` | `13` | `18` | `600` | `0.1` | Bar widget pills (`clock`, `windowTitle`), Button labels, Quick Tile primary label, Settings category items |
| `labelMedium` | `familySans` | `12` | `16` | `500` (Medium) | `0.25` | Quick Tile secondary status (`Connected`), Filter chips, Tooltip text |
| `labelSmall` | `familySans` | `11` | `14` | `500` | `0.3` | Keyboard shortcut badges (`Super+D`), Notification timestamps (`2m ago`), Workspace numbers |

---

## 2. Mandatory Tabular Numerals (`tnum`) Rule

In a desktop environment, live numbers update every second (bar clock, Media elapsed time, Screen Recording timer, CPU/RAM/Network telemetry, Volume/Brightness OSD percentage). With proportional glyphs, `"1"` is narrower than `"8"`, causing adjacent widgets in a bar to shift every second.

### 2.1 Enforcement Rule
Every `Text` item displaying live or changing numbers **MUST** apply:
```qml
font.features: Tokens.typography.tabularFeatures // ({ "tnum": 1 })
```

### 2.2 Components Requiring `tnum`
1. **Bar `clock` Widget** (`02-bar-widgets.md`), including the stacked vertical variant
2. **Bar `telemetry` Widget** (CPU %, RAM GB, Net Up/Down KB/s)
3. **Bar `controlCenter` Battery / Volume Percentages** (`UPower`, `Pipewire` readouts) and `workspaces` numbers
4. **OSD Volume / Brightness Percentage** (`07-osd-huds.md`)
5. **MPRIS Media Elapsed / Total Duration** (`06-media-player-popover.md`)
6. **Screen Recording Timer Pill** (`00:00` in `13-screen-capture-and-recording.md`)
7. **Lock Screen Clock** (`10-lock-screen.md`)
8. **Desktop Widget Clocks, Telemetry Gauges & Battery Rings** (`15-desktop-widgets-layer.md`)

### 2.3 Large Text Scaling
Every role in `TypographyTokens` multiplies its `pixelSize` and `lineHeight` by `Tokens.textScale` (`1.0`, `1.15`, `1.3`). Default bar thicknesses (`barThickness`, `dockThickness`, `islandThickness`) grow with it through `MetricTokens.chromeScale`, and a user-set `bar.thickness` is raised to the minimum its widgets' text needs (`BarService.effectiveThickness(bar)`), so labels never clip. Components MUST read sizes from the type roles rather than hardcoding pixel sizes, or Large Text silently breaks.

### 2.4 Font Files and Licences

Every family is open-licensed, so the `mat-shell` package ships the files it needs (`packaging/dependencies.json` → `fonts`, pinned by commit and SHA-256; `python3 scripts/fetch-fonts.py` installs them for development).

| Token | Family | File | Licence | Source |
|---|---|---|---|---|
| `familySans`, `familyDisplay` | Google Sans Flex (variable: `wght`, `wdth`, `opsz`, `slnt`, `ROND`) | `GoogleSansFlex[ROND,opsz,slnt,wdth,wght].ttf` | SIL OFL 1.1, no Reserved Font Names | `google/fonts` `ofl/googlesansflex` |
| `familyEditorial` | Instrument Serif | `InstrumentSerif-Regular.ttf`, `InstrumentSerif-Italic.ttf` | SIL OFL 1.1 | `google/fonts` `ofl/instrumentserif` |
| `familyIcons` | Material Symbols Rounded (variable: `FILL`, `wght`, `GRAD`, `opsz`) | `MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf` | Apache 2.0 | `google/material-design-icons` `variablefont/` |
| `familyMono` | JetBrains Mono | — (Arch `ttf-jetbrains-mono`, a package dependency) | SIL OFL 1.1 | distribution package |

- Google Sans Flex replaces the earlier Google Sans / Google Sans Text pair, which could not be redistributed. One variable family serves both tokens; the two token names stay so roles keep their meaning.
- "Google", "Google Sans" and "Google Sans Flex" are Google trademarks (`TRADEMARKS.md` beside the font). Ship the font files unmodified, and never use the names in the product's own name or branding.
- Optical size: whether Qt applies `opsz` automatically from the pixel size on Linux is checked in Task 11 (runtime spike) with the gallery. Until then no role sets `font.variableAxes` for text; `ROND` and `wdth` stay at their defaults.

---

## 3. Material Symbols Variable Iconography

All shell icons use **Material Symbols Rounded** (`Tokens.typography.familyIcons`) rendered as variable font glyphs or Qt6 SVG paths with 4 variable axes:

| Variable Axis | CSS / OpenType Tag | Inactive / Resting State | Hovered State | Active / Toggled State | Pressed State |
|---|---|---|---|---|---|
| **Fill** | `FILL` (`0..1`) | `0` (Outlined) | `0` | `1` (Solid Filled) | `1` |
| **Weight** | `wght` (`100..700`) | `400` | `500` | `600` | `300` (Squish cue) |
| **Grade** | `GRAD` (`-25..200`) | `0` (Dark mode: `-25` to prevent halation) | `50` | `0` | `-25` |
| **Optical Size** | `opsz` (`20..48`) | Matches `Tokens.metrics.icon*` (`20` or `24`) | Matches size | Matches size | Matches size |

### 3.1 Canonical QML `M3Icon` Implementation
```qml
import QtQuick
import MatShell.Tokens

Text {
    id: iconRoot
    property string icon: "wifi"
    property bool filled: false
    property int iconSize: Tokens.metrics.iconMd // 20px
    property int iconWeight: filled ? Font.DemiBold : Font.Normal

    text: icon
    font.family: Tokens.typography.familyIcons
    font.pixelSize: iconSize
    font.weight: iconWeight
    font.variableAxes: ({
        "FILL": filled ? 1.0 : 0.0,
        "wght": iconWeight === Font.DemiBold ? 600 : 400,
        "GRAD": Tokens.darkMode ? -25 : 0,
        "opsz": Math.max(20, Math.min(48, iconSize))
    })
    color: Tokens.color.onSurface
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
```

---

## 4. Expressive Editorial & Layered Duotone Display Numerals

To achieve the signature Material 3 Expressive hero aesthetic on **Desktop Clocks (`SC-15`)**, **Lock Screen secondary outputs (`SC-10`)**, and **Date Badges** without compromising legibility:

1. **Editorial Serif Display (`Tokens.typography.displayEditorial`)**:
   - Uses `Tokens.typography.familyEditorial` (`"Instrument Serif"` / `"Newsreader"` / `"Playfair Display"`) at `54px` for sculpted polygon clock tiles (e.g., inside `hexagon` or `flower_8` frames) and hero greetings.
2. **Layered Duotone Hero Numerals (`Tokens.typography.displayExpressiveHero`, primitive `M3DuotoneClock`)**:
   - Hours and minutes are two separate groups divided by a clear gap of `duotoneGroupGapRatio × pixelSize` (`0.18`, about `17px` at `96px`). **Groups never overlap each other**; overlapping the hour and minute digits merges them into an ambiguous 4-digit number.
   - The duotone overlap happens *within* each group: a tonal back layer (`duotoneSecondaryAlpha: 0.78`) is offset by `duotoneLayerOffsetRatio × pixelSize` (`0.06`) on both axes beneath a fully opaque front layer. Hours use `primary` in front over `tertiary`; minutes swap the roles (`tertiary` over `primary`).
   - Hour/minute separation is carried by the gap and the role swap together, so it never depends on hue alone (safe for colour-vision deficiency).
   - Each clock exposes `Accessible.name: "HH:mm"`. The bar `clock` widget (wherever the user placed it) remains the canonical, always-readable time.
3. **Strict Boundary Rule**:
   - `familyEditorial` and duotone numerals are **restricted to hero display widgets (`>= 45px`)**. All status bars, notifications, launchers, and settings rows MUST use `familySans` (`Google Sans Flex`).
   - Bare hero text on the wallpaper follows the Wallpaper Legibility Guard (`01-color-and-surfaces.md` §5).
4. **Locale-Safe Dates**: Expressive date badges always pair the day number with an abbreviated month name from `Qt.locale().monthName(month, Locale.ShortFormat)` (`"26"` + `"Oct"`), ordered per `Qt.locale().dateFormat(Locale.ShortFormat)`. Purely numeric day/month badges (`[26][10]`) are forbidden because they read differently across locales.

---

## 5. Material You Monochrome Themed Application Icon Engine

Standard Linux `.desktop` icons mix clashing corporate brand colors (orange Firefox, blue Telegram, green Spotify, red YouTube) that break HCT tonal harmony in docks and taskbars (the bar `apps` widget).

When `Tokens.themedIcons === true` (Default):
1. **Symbolic Glyph Lookup**: First queries `<iconName>-symbolic` from the active icon theme; if unavailable, loads the standard icon into a QtQuick `MultiEffect` with `colorization: 1.0`, `colorizationColor: wellContentColor`, and `saturation: -1.0`. This luminance-preserving tint keeps the icon's internal detail; it must never collapse the icon into a flat single-colour silhouette.
2. **Tonal Well Pairing**:
   - **Unfocused App in the `apps` Widget**: Well uses `Tokens.color.surfaceTier(2)` (or `secondaryContainer`), icon glyph tinted to `Tokens.color.onSecondaryContainer`.
   - **Focused Active App**: Well morphs to `Tokens.color.primary` (`radius: lg` or `scallop_12`), icon glyph tinted to `Tokens.color.onPrimary`. Focus is signalled by shape and colour together.
3. **Scope — Chrome Harmonizes, Search Surfaces Recognize**: Themed tinting applies only to persistent chrome: the bar `apps` widget (dock or taskbar, on any bar) and Desktop Widgets. Recognition-critical surfaces always render the original full-colour icon, because brand colour is the fastest recognition cue when scanning: Launcher results and app grid (`SC-08`), Overview window badges (`SC-09`), Notifications (`SC-04`), Polkit requester (`SC-12`), and the Power Menu inhibitor list (`SC-11`).
4. **Name Disclosure**: Tinting removes colour cues, so every themed icon MUST expose the application name through an `M3Tooltip` (`450ms` hover delay) and `Accessible.name`.

