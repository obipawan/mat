# Shell Component 06 — MPRIS Media Player Popover

> **Module**: `design-system/shell-components/06-media-player-popover.md`
> **Component ID**: `SC-06`
> **Primitives Used**: `M3Popover`, `M3Surface`, `M3IconButton`, `M3FilterChip`, `M3Slider`

---

## 1. Purpose & Wayland Layer Config

The **MPRIS Media Player Popover** provides rich media playback control across all active D-Bus `org.mpris.MediaPlayer2` instances (Spotify, Firefox, Chromium, MPV, Amberol). Following Android 14/15 and Material 3 Expressive media conventions, it dynamically extracts an HCT palette from the current track's album cover (`mpris:artUrl`), features an animated squiggly/waveform progress scrubber, and morphs the Play/Pause button between a circle and a rounded square.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-media"` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **Card Width** | `Tokens.metrics.mediaPopoverWidth` (`360px`) |
| **`WlrLayershell.exclusiveZone`** | `0` |
| **`WlrLayershell.keyboardFocus`** | `WlrKeyboardFocus.OnDemand` |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Keyboard Media Shortcuts** | While open: `Space` (Play/Pause), `←`/`→` or `h`/`l` (Seek `±5s`), `n`/`p` (Next/Prev), `Tab` (Switch active MPRIS player), `o` (Jump to the player window's workspace) | Identical bindings in both modes, alongside hardware media keys and pointer controls |
| **Origin Alignment** | `M3Popover` origin-edge placement: grows out of the clicked `media` widget on any bar, centred on it along the bar axis and clamped inside `BarService.insets`; `Super+M` with no `media` widget opens in the top-end corner | Same |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭──────────────────────────────────────────────────────────╮
│  ╭──────────────╮ ╭──────────────╮         ╭───────────╮ │  Player Selector Chips + Audio Sink Pill
│  │ 󰓇 Spotify  • │ │ 󰈹 YouTube    │         │ 󰋋 XM5   󰅀 │ │
│  ╰──────────────╯ ╰──────────────╯         ╰───────────╯ │
│  ╭──────────────╮  Midnight City                         │  Album Art (84×84px, radius: 16px)
│  │              │  M83                                   │  Title: titleMedium (15px DemiBold)
│  │  [Album Art] │  Hurry Up, We're Dreaming              │  Artist: bodyMedium (13px)
│  │   84 × 84px  │                                        │  Album: bodySmall (12px)
│  ╰──────────────╯                                        │
│  01:42  ♒♒♒♒♒♒♒♒♒♒♒♒♒♒┃──────────────  04:03            │  M3 Expressive Squiggly Scrubber (tnum)
│                                                          │
│       ╭─────╮    ╭─────╮    ╭─────────╮    ╭─────╮    ╭─────╮ │
│       │  󰒝  │    │  󰒮  │    │    󰏤    │    │  󰒭  │    │  󰑖  │ │  Play/Pause = 52×52px (Circle <-> Squircle)
│       ╰─────╯    ╰─────╯    ╰─────────╯    ╰─────╯    ╰─────╯ │
╰──────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table (Scoped Album-Art HCT Override)

When `MprisPlayer.trackArtUrl` is available, `artPalette` overrides the card's local tokens; otherwise it falls back to `Tokens.color.*`. `MediaService` builds `artPalette` with `matugen image <art> --dry-run --json hex -t scheme-content --source-color-index 0` (never without `--dry-run`, which would re-theme the whole shell) and reads `colors.<role>.<dark|light>.color` from stdout (`01-color-and-surfaces.md` §4):

| Element | Token / Dynamic Override | Typography / Metric Token |
|---|---|---|
| **Media Card Root** | `artPalette.primaryContainer` (or `Tokens.color.surfaceTier(1)`) + `25%` blurred album art backdrop | `width: 360px`, `radius: xl (24px)`, `padding: 16px` |
| **Active Player Chip** | `artPalette.primary` / `artPalette.onPrimary` | `height: 28px`, `radius: full`, `labelMedium` |
| **Output Sink Routing Pill** | `artPalette.secondaryContainer` / `onSecondaryContainer` | `height: 28px`, `radius: full`, `labelSmall` |
| **Album Art Thumbnail** | `84px × 84px`, `1px` `outlineVariant` @ `20%` | `radius: lg (16px)` OR a `polygonClover4` mask whose **outline** rotates `12.8 deg/s` while playing. The artwork stays upright and readable; rotation stops when paused, when the popover closes, or under Reduced Motion |
| **Play / Pause Hero Button** | `artPalette.primary` / `artPalette.onPrimary` | `52px × 52px`; Paused: `radius: 26px` (Circle); Playing: `radius: 16px` (Squircle) |
| **Prev / Next / Shuffle / Loop** | `artPalette.secondaryContainer` / `onSecondaryContainer` | `40px × 40px` `M3PolygonSurface` (`polygonScallop12` 12-lobe cookie badge; morphs to `10px` squircle on press) |
| **Squiggly Progress Scrubber** | Active wave: `artPalette.primary` (`amplitude: playing ? 3px : 0px`, `wavelength: 18px`); Inactive line: `onPrimaryContainer` @ `28%` | Timestamp labels: `labelSmall` (`font.features: tabularFeatures`) |

---

## 5. Interactive State Matrix

| Element | Idle (Paused) | Playing | Hovered | Pressed / Scrubbing |
|---|---|---|---|---|
| **Hero Play/Pause Button** | `radius: 26px` (Circle), `"play_arrow"` | `radius: 16px` (Squircle), `"pause"` | `scale: 1.05`, +`8%` `onPrimary` | `radius: 10px`, `scale: 0.94` |
| **Squiggly Seekbar** | Flat line (`amplitude: 0px`) | Animated sine wave (`amplitude: 3px`, phase velocity `2.5 rad/s`) | Wave flattens slightly; shows hover time preview | Thumb expands vertically to `24px`, seeks `MprisPlayer.position` |
| **Album Art Thumbnail** | `scale: 0.94`, `opacity: 0.85` | `scale: 1.0`, `opacity: 1.0` | Shows `"open_in_new"` overlay icon | Focuses the media player's client window |

---

## 6. Motion & Morph Choreography

1. **Play/Pause Circle-to-Squircle Morph**: Toggling playback state animates the `52px × 52px` button's `radius` between `26px` and `16px` via `Tokens.motion.springFastSpatial` while the wave amplitude on the seekbar animates between `0px` and `3px` over `250ms`.
2. **Track Change Crossfade**: When `trackTitle` or `trackArtUrl` changes, the album art and palette crossfade over `Tokens.motion.springDefaultEffects.durationMs` while the title/artist text slides `x: +14px -> 0px`.
3. **Reduced Motion**: The squiggly seekbar renders as a flat line (`amplitude: 0px`), the polygon outline stops rotating, and the title slide becomes a plain crossfade; playback state stays legible through the play/pause glyph and the circle ↔ squircle shape.

---

## 7. Quickshell Service & IPC Bindings

- **MPRIS Service (`Quickshell.Services.Mpris`)**:
  - `Mpris.players.values` list of active `MprisPlayer` objects.
  - Bound properties: `player.identity`, `player.playbackState` (`MprisPlaybackState.Playing`), `player.trackTitle`, `player.trackArtist`, `player.trackAlbum`, `player.trackArtUrl`, `player.position`, `player.length`, `player.canSeek`, `player.shuffle`, `player.loopState`.
  - Methods: `player.togglePlaying()`, `player.previous()`, `player.next()`, `player.seek(offset)`.
- **Position Polling `Timer`**: Since MPRIS does not emit D-Bus signals every second during playback, a QtQuick `Timer { interval: 1000; running: player.playbackState === MprisPlaybackState.Playing && mediaWindow.visible; repeat: true; onTriggered: player.positionChanged() }` keeps the seekbar and `tnum` timestamp synchronized.

---

## 8. Canonical QML Reference Skeleton (`MediaPopover.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import MatShell.Tokens

// M3Popover places the card against the clicked media widget's bar (any edge) and grows it out of that widget
M3Popover {
    id: mediaWindow
    name: "media"
    namespace: "mat-media"
    cardWidth: Tokens.metrics.mediaPopoverWidth
    cardHeight: 240

    property MprisPlayer activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing

    M3Surface {
        id: mediaCard
        anchors.fill: parent   // album-art tinted layer over the popover's Tier 0 card
        tier: 1
        customColor: Tokens.color.primaryContainer
        contentColor: Tokens.color.onPrimaryContainer
        cornerRadius: Tokens.shape.xl

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Tokens.metrics.spaceLg
            spacing: Tokens.metrics.spaceMd

            // Track Info + Album Art Row
            RowLayout {
                Layout.fillWidth: true
                spacing: Tokens.metrics.spaceMd

                Rectangle {
                    width: 76
                    height: 76
                    radius: Tokens.shape.lg
                    color: Tokens.color.surfaceContainerHighest
                    scale: mediaWindow.isPlaying ? 1.0 : 0.94

                    Behavior on scale {
                        SpringAnimation {
                            spring: Tokens.motion.springFastSpatial.spring
                            damping: Tokens.motion.springFastSpatial.damping
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "music_note"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: 32
                        color: Tokens.color.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: mediaWindow.activePlayer?.trackTitle || "Nothing Playing"
                        font.family: Tokens.typography.titleMedium.family
                        font.pixelSize: Tokens.typography.titleMedium.pixelSize
                        font.weight: Font.DemiBold
                        color: Tokens.color.onPrimaryContainer
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: mediaWindow.activePlayer?.trackArtist || "Select a media source"
                        font.family: Tokens.typography.bodyMedium.family
                        font.pixelSize: Tokens.typography.bodyMedium.pixelSize
                        color: Tokens.color.onPrimaryContainer
                        opacity: 0.82
                        elide: Text.ElideRight
                    }
                }
            }

            // Transport Controls Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Tokens.metrics.spaceMd

                M3Surface {
                    width: 38; height: 38
                    interactive: true
                    customColor: Tokens.color.secondaryContainer
                    cornerRadius: 19
                    onClicked: mediaWindow.activePlayer?.previous()
                    Text {
                        anchors.centerIn: parent
                        text: "skip_previous"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: 20
                        color: Tokens.color.onSecondaryContainer
                    }
                }

                // Morphing Play/Pause Hero Button (Circle <-> Squircle)
                M3Surface {
                    width: 52; height: 52
                    interactive: true
                    customColor: Tokens.color.primary
                    cornerRadius: mediaWindow.isPlaying ? Tokens.shape.lg : 26
                    onClicked: mediaWindow.activePlayer?.togglePlaying()

                    Text {
                        anchors.centerIn: parent
                        text: mediaWindow.isPlaying ? "pause" : "play_arrow"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: 26
                        color: Tokens.color.onPrimary
                    }
                }

                M3Surface {
                    width: 38; height: 38
                    interactive: true
                    customColor: Tokens.color.secondaryContainer
                    cornerRadius: 19
                    onClicked: mediaWindow.activePlayer?.next()
                    Text {
                        anchors.centerIn: parent
                        text: "skip_next"
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: 20
                        color: Tokens.color.onSecondaryContainer
                    }
                }
            }
        }
    }
}
```
