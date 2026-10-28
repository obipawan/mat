# Shell Component 10 — Session Lock Screen (`WlSessionLockSurface`)

> **Module**: `design-system/shell-components/10-lock-screen.md`
> **Component ID**: `SC-10`
> **Primitives Used**: `M3Surface`, `M3TextField`, `M3IconButton`, `M3BarPill`

---

## 1. Purpose & Wayland Layer Config

The **Session Lock Screen** secures the Wayland session using the protocol-level `ext-session-lock-v1` extension (`Quickshell.Wayland.WlSessionLock`). Unlike a regular overlay window, `WlSessionLock` instructs the Wayland compositor to blank all client windows and render exclusively the lock surfaces on every connected output, guaranteeing zero desktop frame leakage even if a monitor is hotplugged while locked.

| Property | Value |
|---|---|
| **Quickshell Root Type** | `Quickshell.Wayland.WlSessionLock` + `WlSessionLockSurface` |
| **Per-Monitor Coverage** | Automatically spawns one `WlSessionLockSurface` per connected monitor (`locked: ShellState.sessionLocked`) |
| **Interactive Auth Output** | Rendered on primary/focused monitor; secondary monitors show dimmed wallpaper + synchronized M3 Expressive Clock |
| **Authentication Backend** | `Quickshell.Services.Pam.PamContext` (`config: "login"` or `"system-auth"`) |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Immediate Typing UX** | **Zero-Click Blind Typing**: The password `TextInput` holds active focus immediately upon lock; typing the first character shifts the hero clock upward (`translateY: -36px`) and reveals the M3 Expressive morphing password dot pill | Shows the User Avatar + Password Field card at rest. The field still holds focus from the moment of lock, so the first keystroke is always captured (never swallowed by a "press a key to reveal" step) |
| **Caps Lock & Layout** | `KeyboardService.capsLock` shows `keyboard_capslock` + `"Caps Lock is on"` below the password pill, next to the active layout code (`EN`) | Same |
| **Session Power Buttons** | `Suspend` acts immediately; `Reboot` and `Power off` are `M3HoldToConfirm` controls (hold `2s`, progress fills the button, release cancels), because both end the locked session's unsaved work | Same |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭───────────────────────────────────────────────────────────────────────────────────────────╮
│                                    󰁹 86%   •   󰖙 24°C   •   EN                            │  Top Status Pill
│                                                                                           │
│                                         17:53                                             │  Expressive Hero Clock
│                                   Monday, October 26                                      │  (displayLarge 88px, tnum)
│                                                                                           │
│                                        ╭──────╮                                           │
│                                        │  󰀄   │                                           │  User Avatar (64×64px)
│                                        ╰──────╯                                           │
│                                      Pawan Kumar                                          │
│                            ╭──────────────────────────────╮                               │
│                            │   ✦  ■  ●  ▲  ✦  ●       ╭─╮ │                               │  M3 Morphing Password Dots
│                            │                          │→│ │                               │  (Geometric shapes morph!)
│                            ╰──────────────────────────────╯                               │
│                                 ⇪ Caps Lock is on  •  EN                                   │  Supporting line (caps / error)
│                            ╭──────────────────────────────╮                               │  Compact MPRIS Media Pill
│                            │  󰎆  Midnight City — M83   󰏤  │                               │  (Read-only / Play-Pause)
│                            ╰──────────────────────────────╯                               │
│                                                                    ╭───╮  ╭───╮  ╭───╮    │
│                                                                    │ 󰤄 │  │ 󰜉 │  │ 󰐥 │    │  Suspend | Reboot | Off
╰───────────────────────────────────────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Radius / Metric Token |
|---|---|---|---|---|
| **Wallpaper Scrim** | Blurred active wallpaper (`blur: 48px`) + `scrim` @ `45%` | — | — | Full output |
| **Hero Clock Display** | `"transparent"` | `Tokens.color.primaryFixed` | `familyDisplay`, `88px`, `weight: 700`, **`tabularFeatures`** | Animates `scale: 0.85` when typing |
| **Date Subtitle** | `"transparent"` | `Tokens.color.onSurface` | `titleLarge` (`20px`, `500`) | — |
| **Password Input Pill** | `Tokens.color.surfaceTier(1)` (`errorContainer` on PAM failure) | `Tokens.color.onSurface` (`onErrorContainer` on error) | — | `width: 280px`, `height: 48px`, `radius: full`, border `2px` `primary` |
| **M3 Expressive Password Dots** | Odd indices: `Tokens.color.primary`; Even indices: `Tokens.color.tertiary` | — | — | `12px × 12px`; each typed char pops in as a squircle (`radius: 3px`) then morphs to circle (`radius: 6px`) |
| **Submit Arrow Button** | `Tokens.color.primary` | `Tokens.color.onPrimary` | Icon `20px` (`"arrow_forward"`) | `36px × 36px`, `radius: full`, `accessibleName: "Unlock"` |
| **Supporting Line** | `"transparent"` | Error: `Tokens.color.error`; Caps Lock: `Tokens.color.tertiary`; layout code: `onSurfaceVariant` | `bodySmall` (`12px`) | Centered `8px` below the password pill; error text takes priority |
| **Session Power Buttons** | `Tokens.color.surfaceTier(1)` with an `errorContainer` hold fill on Reboot/Off | `onSurface` (`onErrorContainer` while holding) | Tooltip `"Hold to restart"` / `"Hold to power off"` + `accessibleName` | `40px × 40px`, `radius: full`; the fill sweeps around the button over `2s` (`M3HoldToConfirm`), release drains it |
| **Secondary Outputs** | Blurred wallpaper + `scrim` @ `45%` | `M3DuotoneClock` (`onWallpaper: true`) | `displayExpressiveHero` | No input; mirrors the primary output's time |

---

## 5. Interactive State Matrix (PAM Authentication Machine)

| PAM State | Visual & Spatial Response |
|---|---|
| **`Idle` (0 chars typed)** | Hero clock at `scale: 1.0`, `y: 26%`; password pill shows subtle placeholder `"Enter password…"`. |
| **`Typing` (1+ chars)** | Hero clock glides upward (`translateY: -28px`, `scale: 0.88`) via `springDefaultSpatial`; each typed character spawns an M3 geometric dot that pops (`scale: 0 -> 1.25 -> 1.0`) and morphs from diamond/squircle to circle. |
| **`Authenticating` (`pam.active`)** | Submit button morphs into an indeterminate `M3CircularProgress` spinner; password dots pulse sequentially in a wave. |
| **`Error` (`PamResult.Error` / `AuthFailed`)** | Password pill flashes `Tokens.color.errorContainer` with `2px` `Tokens.color.error` border, clears the input buffer, and always displays `"Incorrect password — try again"` in the supporting line (announced to screen readers). A damped horizontal spring shake (`translateX: -14 -> +12 -> -8 -> +4 -> 0`) is added only when `Tokens.motion.decorativeMotionEnabled`. |
| **`Success` (`PamResult.Success`)** | Password pill morphs into a `48px` `Tokens.color.successContainer` circle with `"check"`, lock screen scales `1.0 -> 1.06` with `opacity: 1 -> 0` over `200ms`, then sets `sessionLock.locked = false`. |

---

## 6. Motion & Morph Choreography

1. **M3 Expressive Geometric Password Dots (Android 15 PIN Style)**: When a character is appended to the password buffer, its indicator dot spawns with `scale: 0.2 -> 1.0`, `rotation: 45deg -> 0deg`, and `radius: 2px -> 6px` over `350ms` via `Tokens.motion.springFastSpatial`. Backspacing shrinks the removed dot `scale: 1.0 -> 0.0` over `120ms`.
2. **Error Horizontal Spring Shake**: Driven by a `SequentialAnimation` of 4 decreasing horizontal displacements (`-14px`, `+12px`, `-8px`, `0px`, `50ms` per segment). Skipped under Reduced Motion; the error colour and text carry the message on their own.

---

## 7. Quickshell Service & IPC Bindings

- **Session Lock (`Quickshell.Wayland.WlSessionLock`)**: `locked` boolean bound to `ShellState.sessionLocked`.
- **PAM Authentication (`Quickshell.Services.Pam.PamContext`)**:
  - `pam.start()` begins authentication conversation.
  - `onResponseRequiredChanged`: when `pam.responseRequired`, calling `pam.respond(passwordBuffer)` submits the password. Never call `respond()` synchronously after `start()`; the request arrives asynchronously.
  - `onCompleted(result)`: checks `result === PamResult.Success` to unlock `sessionLock.locked = false`.
- **Keyboard State (`KeyboardService`)**: `capsLock`, `layoutCode` for the supporting line.

---

## 8. Canonical QML Reference Skeleton (`LockScreen.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import MatShell.Tokens

WlSessionLock {
    id: sessionLock
    locked: ShellState.sessionLocked

    WlSessionLockSurface {
        id: lockSurface
        color: Tokens.color.surfaceContainerLowest

        property string passwordBuffer: ""
        property bool authError: false

        PamContext {
            id: pam
            config: "login"
            // PAM asks for the password asynchronously after start()
            onResponseRequiredChanged: if (responseRequired) respond(lockSurface.passwordBuffer)
            onCompleted: (result) => {
                passwordInput.text = ""
                if (result === PamResult.Success) {
                    ShellState.sessionLocked = false
                } else {
                    lockSurface.authError = true
                    if (Tokens.motion.decorativeMotionEnabled) shakeAnim.restart()
                    supportingLine.Accessible.announce(supportingLine.text)
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Tokens.metrics.spaceXl

            // Expressive Hero Clock
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(lockClock.date, "HH:mm")
                font.family: Tokens.typography.displayLarge.family
                font.pixelSize: 88
                font.weight: Font.Bold
                font.features: Tokens.typography.tabularFeatures
                color: Tokens.color.primaryFixed
                scale: lockSurface.passwordBuffer.length > 0 ? 0.90 : 1.0

                Behavior on scale {
                    enabled: Tokens.motion.spatialMotionEnabled
                    SpringAnimation {
                        spring: Tokens.motion.springDefaultSpatial.spring
                        damping: Tokens.motion.springDefaultSpatial.damping
                    }
                }
            }

            // Password Input Pill with Morphing Geometric Dots
            M3Surface {
                id: pwPill
                Layout.alignment: Qt.AlignHCenter
                width: 280
                height: 48
                tier: 1
                customColor: lockSurface.authError ? Tokens.color.errorContainer : Tokens.color.surfaceTier(1)
                cornerRadius: Tokens.shape.full
                border.width: 2
                border.color: lockSurface.authError ? Tokens.color.error : Tokens.color.primary

                SequentialAnimation on x {
                    id: shakeAnim
                    running: false
                    NumberAnimation { to: pwPill.x - 14; duration: 45 }
                    NumberAnimation { to: pwPill.x + 12; duration: 45 }
                    NumberAnimation { to: pwPill.x - 8; duration: 45 }
                    NumberAnimation { to: pwPill.x; duration: 45 }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: lockSurface.passwordBuffer.length
                        delegate: Rectangle {
                            width: 12; height: 12
                            radius: 6
                            color: (index % 2 === 0) ? Tokens.color.primary : Tokens.color.tertiary
                        }
                    }
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    focus: true
                    opacity: 0
                    echoMode: TextInput.Password
                    Accessible.role: Accessible.EditableText
                    Accessible.passwordEdit: true
                    Accessible.name: "Password"
                    onTextChanged: {
                        if (text.length > 0) lockSurface.authError = false
                        lockSurface.passwordBuffer = text
                    }
                    onAccepted: if (!pam.active && text.length > 0) pam.start()
                }
            }

            // Supporting line: error text has priority over the Caps Lock warning
            Text {
                id: supportingLine
                Layout.alignment: Qt.AlignHCenter
                text: lockSurface.authError
                    ? "Incorrect password — try again"
                    : (KeyboardService.capsLock ? "Caps Lock is on  •  " + KeyboardService.layoutCode : KeyboardService.layoutCode)
                font.family: Tokens.typography.bodySmall.family
                font.pixelSize: Tokens.typography.bodySmall.pixelSize
                color: lockSurface.authError
                    ? Tokens.color.error
                    : (KeyboardService.capsLock ? Tokens.color.tertiary : Tokens.color.onSurfaceVariant)
            }
        }

        SystemClock {
            id: lockClock
            precision: SystemClock.Minutes
        }
    }
}
```
