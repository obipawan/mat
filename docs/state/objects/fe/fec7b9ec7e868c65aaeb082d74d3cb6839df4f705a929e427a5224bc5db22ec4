# Shell Component 11 — Power & Session Management Modal

> **Module**: `design-system/shell-components/11-power-and-session-menu.md`
> **Component ID**: `SC-11`
> **Primitives Used**: `M3Scrim`, `M3Surface`, `M3HoldToConfirm`, `M3AppIcon`

---

## 1. Purpose & Wayland Layer Config

The **Power & Session Management Modal** (`Super+Escape`, the Control Center power icon, or the `power` bar widget on any bar) presents six session actions as two rows of tiles. **It explains nothing in prose**: shape, colour, and motion carry the meaning, and every tile has exactly one word.
- **Top row — Lock, Sleep, Hibernate**: reversible, run on a single press. Tonal tiles, `primary` icons.
- **Bottom row — Log out, Restart, Power off**: confirmed by holding the tile (pointer or key) for `2s` while the fill sweeps across the tile itself (`M3HoldToConfirm`, `02-buttons-and-chips.md` §7). These tiles carry `error`-tinted icons and a thin **hold track** along their bottom edge, the empty gauge the fill travels, so "this one is held, and it's serious" reads at a glance. Letting go cancels. There is no second dialog, timer, or Cancel button.
- **No title, row labels, or status sentence.** A divider separates the rows. Key letters sit as small corner badges. A tap that's too short plays the **nudge** (the fill peeks and drains back) instead of printing a hint.
- **Apps blocking shutdown** (logind inhibitors) appear on open as one compact chip (`warning` icon + the app's own icon + its name), so the risk is visible *before* a hold starts. Details live in the chip's tooltip and accessible name.

Text that would otherwise be shown goes only to assistive technology (accessible names, descriptions, and announcements), so screen-reader users lose nothing.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-power"` |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **`WlrLayershell.exclusiveZone`** | `-1` |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.Exclusive`** |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Single-Key Mnemonics** | Tap `l` (Lock), `s` (Suspend), `h` (Hibernate) to run instantly; **hold** `e` (Logout), `r` (Reboot), or `p` (Poweroff) for `2s` to confirm | Identical mnemonics, arrow keys, and `Enter` / `Space` holds in both modes, plus pointer press-and-hold |
| **Logout Command Dispatch** | Executes compositor-clean exit (`hyprctl dispatch exit` or `niri msg action quit` or `loginctl terminate-user $USER`) | Executes session manager logout |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭──────────────────────────────────────────────────────────╮
│  ╭──────────────╮  ╭──────────────╮  ╭──────────────╮    │
│  │            L │  │            S │  │            H │    │  Top row: tap = run (tonal tiles, primary icons)
│  │      󰌾       │  │      󰤄       │  │      󰋊       │    │  Corner letter = key mnemonic
│  │     Lock     │  │    Sleep     │  │  Hibernate   │    │
│  ╰──────────────╯  ╰──────────────╯  ╰──────────────╯    │
│  ──────────────────────────────────────────────────────  │  Divider instead of row labels
│  ╭──────────────╮  ╭──────────────╮  ╭██████████────╮    │
│  │            E │  │            R │  │██████████  P │    │  Bottom row: error-tinted icons + hold track
│  │      󰍃       │  │      󰜉       │  │█████ 󰐥       │    │  Holding Power off: errorContainer fill
│  │   Log out    │  │   Restart    │  │███Power off  │    │  sweeps left -> right over 2s
│  │ ▁▁▁▁▁▁▁▁▁▁▁▁ │  │ ▁▁▁▁▁▁▁▁▁▁▁▁ │  │██████████▁▁▁ │    │  ▁ = hold track (the empty gauge)
│  ╰──────────────╯  ╰──────────────╯  ╰██████████────╯    │
│                                     ╭───────────────╮    │
│                                     │ ⚠ 󰈹 Firefox   │    │  Inhibitor chip, only when an app blocks
│                                     ╰───────────────╯    │
╰──────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Resting State | Hovered / Focused State | Holding (`M3HoldToConfirm.holding`) | Done (`confirmed()`, `350ms`) |
|---|---|---|---|---|
| **Action Tile (`136×120px`)** | `Tokens.color.surfaceTier(1)` (`radius: xl 24px`) | `Tokens.color.secondaryContainer` (`radius: xxl 28px`, `scale: 1.03`) | Base `surfaceTier(1)` + `errorContainer` fill at `width × progress` (linear, `holdToConfirmMs`); `scale: 0.98` | Full `errorContainer`, `radius: full`, tile widens (`flex 1.6`) |
| **Action Icon (`32px`)** | Instant: `Tokens.color.primary`; hold-gated: `Tokens.color.error` (`FILL: 0`) | `onSecondaryContainer` (`FILL: 1`) | `Tokens.color.onErrorContainer` (`FILL: 1`) | `onErrorContainer` |
| **Action Label (one word)** | `titleSmall` (`onSurface`): `Lock`, `Sleep`, `Hibernate`, `Log out`, `Restart`, `Power off` | `onSecondaryContainer` | `onErrorContainer` | Unchanged (the full pill + motion say "it's happening") |
| **Key Badge (corner)** | Top-end corner, bare letter (`L`, `S`, `H`, `E`, `R`, `P`), `labelSmall` `onSurfaceVariant` @ `70%` | `onSecondaryContainer` | `onErrorContainer` | — |
| **Hold Track** (hold-gated only) | `3px` bar inset `16px` along the bottom edge, `outlineVariant`, `radius: full` | `onSecondaryContainer` @ `38%` | Covered by the fill | — |
| **Row Divider** | `M3Divider`, `outlineVariant` @ `40%` | — | — | — |
| **Inhibitor Chip** | Only when logind reports a `block` inhibitor: `32px` chip, `warning` icon (`Tokens.color.warning`) + the app's original icon (`M3AppIcon { themed: false }`) + app name; tooltip and `Accessible.name` carry the reason (`"Firefox is blocking shutdown: unsaved form on mail.example.com"`) | Tooltip | Stays visible | — |
| **Announcements** (not rendered) | `Accessible` live announcements replace the old status line: `"Hold 2 seconds to power off"` on a short tap, `"Release to cancel"` when a hold starts, `"Press again to power off"` when armed | — | — | `"Powering off"` |

---

## 5. Interactive State Matrix

| Action Type | Press / Tap | Hold `2s` (pointer, `Enter` / `Space`, or mnemonic) | Released Early | `Escape` |
|---|---|---|---|---|
| **Instant (`Lock`, `Suspend`, `Hibernate`)** | Executes immediately (`ShellState.lockSession()` / `systemctl suspend` / `systemctl hibernate`) and closes the modal | N/A (runs on press) | N/A | Closes Power Menu |
| **Hold-gated (`Log out`, `Restart`, `Power off`)** | A tap (released before `15%`) plays the nudge (fill peeks to `15%` and drains; the hold track pulses once; a `±3px` shake unless Reduced Motion) and does nothing else; screen readers hear `"Hold 2 seconds to power off"` | Fill reaches `100%`, the card morphs to its done state, then the command runs | Fill drains back over `200ms`; nothing happens | Cancels an active hold; otherwise closes the modal |
| **Press-twice fallback** (`Tokens.confirmByHold: false`, screen readers) | First press arms (full fill, icon swaps to `check`; `"Press again to power off"` is announced, not shown); second press runs. Hold tracks are hidden in this mode | — | — | Disarms; otherwise closes |
| **Blocked by an app** (logind `block` inhibitor) | Same as above | Hold still confirms (explicit intent), and the inhibitor chip stays visible throughout the hold | Same | Same |

---

## 6. Motion & Morph Choreography

1. **Card Staggered Entrance**: All 6 action cards scale from `0.86 -> 1.0` with a `25ms` radial stagger using `Tokens.motion.springDefaultSpatial`.
2. **Hold Fill**: The `errorContainer` layer grows linearly from the card's leading edge over `Tokens.motion.holdToConfirmMs` (`2000ms`). Linear on purpose: the fill is a clock the user reads, so it must not ease. It is never shortened by Reduced Motion.
3. **Release Drain**: Releasing early animates the fill back to `0` over `Tokens.motion.holdDrainMs` (`200ms`, `OutCubic`; a `100ms` crossfade under Reduced Motion).
4. **Done Morph**: At `100%` the tile widens (`136px -> 204px`) and its radius morphs to a full pill via `Tokens.motion.springFastSpatial`; the command dispatches `350ms` later (instant under Reduced Motion). The label does not change: the morph itself is the confirmation.
5. **Nudge (tap too short)**: The fill rises to `holdTapHintThreshold` (`15%`) over `springFastEffects.durationMs`, then drains over `holdDrainMs`. The hold track brightens to `onSurfaceVariant` and back, and the tile shakes `±3px` twice (`springFastSpatial`). Under Reduced Motion the shake is dropped; the fill peek stays, because it is the information.

---

## 7. Quickshell Service & IPC Bindings

- **Systemd / Logind (`Quickshell.Io.Process`)**:
  - Lock: `ShellState.lockSession()`
  - Suspend: `systemctl suspend`
  - Hibernate: `systemctl hibernate`
  - Logout: `hyprctl dispatch exit` (fallback: `loginctl terminate-user $USER`)
  - Reboot: `systemctl reboot`
  - Shutdown: `systemctl poweroff`
- **Inhibitors (logind)**: `systemd-inhibit --list --no-pager --no-legend` (or `org.freedesktop.login1.Manager.ListInhibitors` over D-Bus), queried **when the modal opens**; entries with mode `block` populate the inhibitor chip.

---

## 8. Canonical QML Reference Skeleton (`PowerSessionMenu.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import MatShell.Tokens

PanelWindow {
    id: powerWindow
    visible: ShellState.activeModal === "power"
    WlrLayershell.namespace: "mat-power"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property var blockingInhibitors: []   // [{ appId, appName, why }] from systemd-inhibit, queried when the modal opens

    function execute(actionId: string): void {
        ShellState.closeActiveModal()
        // dispatch ShellState.lockSession() / systemctl / compositor exit for actionId (§7)
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.color.withAlpha(Tokens.color.scrim, Tokens.metrics.scrimAlpha)
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.closeActiveModal()
        }
    }

    // No visible prose: titles, row labels, and hints exist only as accessible names / announcements
    M3Surface {
        id: sheet
        anchors.centerIn: parent
        implicitWidth: content.implicitWidth + Tokens.metrics.spaceXl * 2
        implicitHeight: content.implicitHeight + Tokens.metrics.spaceXl * 2
        tier: 0
        cornerRadius: Tokens.shape.xxl
        accessibleName: "Power and session"
        Keys.onEscapePressed: ShellState.closeActiveModal()

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: Tokens.metrics.spaceMd

            PowerRow {
                actions: [
                    { id: "lock", label: "Lock", key: "L", icon: "lock" },
                    { id: "suspend", label: "Sleep", key: "S", icon: "bedtime" },
                    { id: "hibernate", label: "Hibernate", key: "H", icon: "downloading" }
                ]
            }

            M3Divider { Layout.fillWidth: true }

            PowerRow {
                holdGated: true
                actions: [
                    { id: "logout", label: "Log out", key: "E", icon: "logout", verb: "log out" },
                    { id: "reboot", label: "Restart", key: "R", icon: "restart_alt", verb: "restart" },
                    { id: "shutdown", label: "Power off", key: "P", icon: "power_settings_new", verb: "power off" }
                ]
            }

            // Inhibitor chip: icon + app icon + name; the reason lives in the tooltip / accessible name
            Row {
                Layout.alignment: Qt.AlignRight
                visible: powerWindow.blockingInhibitors.length > 0
                spacing: Tokens.metrics.spaceSm
                Repeater {
                    model: powerWindow.blockingInhibitors
                    delegate: M3Surface {
                        required property var modelData
                        tier: 2
                        cornerRadius: Tokens.shape.full
                        implicitHeight: 32
                        implicitWidth: chipRow.implicitWidth + Tokens.metrics.spaceMd * 2
                        accessibleName: modelData.appName + " is blocking shutdown: " + modelData.why
                        tooltipText: modelData.why
                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: Tokens.metrics.spaceXs
                            Text { text: "warning"; font.family: Tokens.typography.familyIcons; font.pixelSize: Tokens.metrics.iconSm; color: Tokens.color.warning; Accessible.ignored: true }
                            M3AppIcon { iconName: modelData.appId; appName: modelData.appName; themed: false; implicitWidth: Tokens.metrics.iconMd; implicitHeight: Tokens.metrics.iconMd }
                            Text { text: modelData.appName; font.family: Tokens.typography.labelLarge.family; font.pixelSize: Tokens.typography.labelLarge.pixelSize; color: Tokens.color.onSurface; Accessible.ignored: true }
                        }
                    }
                }
            }
        }
    }

    // PowerRow.qml (inline component) — three tiles; hold-gated rows add the hold track, error icons, and the nudge
    component PowerRow: RowLayout {
        id: row
        required property var actions
        property bool holdGated: false
        spacing: Tokens.metrics.spaceMd

        Repeater {
            model: row.actions
            delegate: M3Surface {
                id: tile
                required property var modelData
                readonly property bool engaged: row.holdGated && (hold.holding || hold.armed || done)
                property bool done: false
                property real nudge: 0            // peek progress for a too-short tap
                property real shake: 0

                Layout.preferredWidth: done ? 204 : 136
                implicitHeight: 120
                tier: 1
                interactive: true
                clip: true
                accessibleName: modelData.label
                accessibleDescription: row.holdGated
                    ? (Tokens.confirmByHold ? "Hold 2 seconds to " + modelData.verb : "Press twice to " + modelData.verb)
                    : "Shortcut " + modelData.key
                customColor: hovered && !engaged ? Tokens.color.secondaryContainer : Tokens.color.surfaceTier(1)
                cornerRadius: done ? height / 2 : Tokens.shape.xl
                transform: Translate { x: tile.shake }

                M3HoldToConfirm {
                    id: hold
                    onHoldingChanged: if (holding) tile.Accessible.announce("Release to cancel")
                    onArmedChanged: if (armed) tile.Accessible.announce("Press again to " + tile.modelData.verb)
                    onConfirmed: { tile.done = true; doneDelay.restart() }
                    onTappedTooShort: { nudgeAnim.restart(); tile.Accessible.announce("Hold 2 seconds to " + tile.modelData.verb) }
                }
                Timer {
                    id: doneDelay
                    interval: Tokens.motion.spatialMotionEnabled ? 350 : 0
                    onTriggered: powerWindow.execute(tile.modelData.id)
                }
                ParallelAnimation {
                    id: nudgeAnim
                    SequentialAnimation {
                        NumberAnimation { target: tile; property: "nudge"; to: Tokens.motion.holdTapHintThreshold; duration: Tokens.motion.springFastEffects.durationMs; easing.type: Easing.OutCubic }
                        NumberAnimation { target: tile; property: "nudge"; to: 0; duration: Tokens.motion.holdDrainMs; easing.type: Easing.OutCubic }
                    }
                    SequentialAnimation {
                        loops: Tokens.motion.decorativeMotionEnabled ? 2 : 0
                        NumberAnimation { target: tile; property: "shake"; to: 3; duration: 40 }
                        NumberAnimation { target: tile; property: "shake"; to: -3; duration: 80 }
                        NumberAnimation { target: tile; property: "shake"; to: 0; duration: 40 }
                    }
                }

                onPressedChanged: if (row.holdGated) pressed ? hold.begin() : hold.end()
                onClicked: if (!row.holdGated) powerWindow.execute(modelData.id)
                Accessible.onPressAction: row.holdGated ? hold.activate() : powerWindow.execute(modelData.id)

                // Hold track: the empty gauge the fill will travel (the "this is held" cue)
                Rectangle {
                    visible: row.holdGated && Tokens.confirmByHold
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: Tokens.metrics.spaceLg }
                    height: 3
                    radius: height / 2
                    color: tile.nudge > 0 ? Tokens.color.onSurfaceVariant : (tile.hovered ? Tokens.color.withAlpha(Tokens.color.onSecondaryContainer, 0.38) : Tokens.color.outlineVariant)
                    Accessible.ignored: true
                }
                // Progress fill on the tile itself (straight leading edge; the tile clips the corners)
                Rectangle {
                    visible: row.holdGated
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: parent.width * Math.max(hold.progress, tile.nudge)
                    color: Tokens.color.errorContainer
                    Accessible.ignored: true
                }

                Behavior on Layout.preferredWidth {
                    enabled: Tokens.motion.spatialMotionEnabled
                    SpringAnimation { spring: Tokens.motion.springFastSpatial.spring; damping: Tokens.motion.springFastSpatial.damping }
                }

                // Corner key badge
                Text {
                    anchors { top: parent.top; right: parent.right; margins: Tokens.metrics.spaceMd }
                    text: tile.modelData.key
                    font.family: Tokens.typography.labelSmall.family
                    font.pixelSize: Tokens.typography.labelSmall.pixelSize
                    color: tile.engaged ? Tokens.color.onErrorContainer : Tokens.color.onSurfaceVariant
                    opacity: tile.engaged ? 1 : 0.7
                    Accessible.ignored: true
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.metrics.spaceXs
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: hold.armed ? "check" : tile.modelData.icon
                        font.family: Tokens.typography.familyIcons
                        font.pixelSize: Tokens.metrics.iconXl
                        color: tile.engaged ? Tokens.color.onErrorContainer : (row.holdGated ? Tokens.color.error : Tokens.color.primary)
                        Accessible.ignored: true
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: tile.modelData.label
                        font.family: Tokens.typography.titleSmall.family
                        font.pixelSize: Tokens.typography.titleSmall.pixelSize
                        font.weight: Font.DemiBold
                        color: tile.engaged ? Tokens.color.onErrorContainer : Tokens.color.onSurface
                        Accessible.ignored: true
                    }
                }
            }
        }
    }
}
```

Mnemonic keys are routed at window level: `keydown` (non-repeat) calls `begin()` on the matching card's `hold`, `keyup` calls `end()`, and instant mnemonics execute on `keydown`.
