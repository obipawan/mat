# Shell Component 12 — Polkit Privilege Escalation Dialog

> **Module**: `design-system/shell-components/12-polkit-authentication-dialog.md`
> **Component ID**: `SC-12`
> **Primitives Used**: `M3Scrim`, `M3Surface`, `M3TextField`, `M3Button`, `M3IconButton`, `M3FilterChip`

---

## 1. Purpose & Wayland Layer Config

The **Polkit Privilege Escalation Dialog** serves as the desktop environment's `org.freedesktop.PolicyKit1.Authority` authentication agent. When an application (`pkexec`, `gparted`, `systemctl`, Flatpak, NetworkManager) requests administrative privileges, this modal intercepts the request, displays the verified action metadata, and authenticates the selected administrator via PAM.

| Property | Value |
|---|---|
| **`WlrLayershell.namespace`** | `"mat-polkit"` |
| **`WlrLayershell.layer`** | `WlrLayer.Overlay` |
| **Anchors** | `top: true; bottom: true; left: true; right: true` |
| **Modal Width** | `Tokens.metrics.polkitModalWidth` (`420px`) |
| **`WlrLayershell.exclusiveZone`** | `-1` |
| **`WlrLayershell.keyboardFocus`** | **`WlrKeyboardFocus.Exclusive`** |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Originating Window Highlight** | Highlights the requesting client window behind the scrim with a `2px` `Tokens.color.tertiary` border so the user knows which terminal/app triggered the Polkit prompt | Centers the modal over the active monitor with full-screen `M3Scrim` |
| **Keyboard Flow** | Password input auto-focused; `Enter` submits; `Escape` cancels and returns `PolkitResult.Canceled` immediately; `Ctrl+D` toggles the technical details drawer | Identical keyboard flow in both modes, plus full pointer support |
| **Caps Lock & Layout** | While the password field is focused, `KeyboardService.capsLock` shows `"Caps Lock is on"` below the field and the active layout code (`EN`) sits at the field's trailing edge (`M3TextField` contract) | Same |

---

## 3. Visual Anatomy & ASCII Layout

```text
╭──────────────────────────────────────────────────────────╮
│                     ╭──────────╮                         │
│                     │   󰒃      │                         │  Hero Shield Icon Well (48×48px, tertiaryContainer)
│                     ╰──────────╯                         │
│               Authentication Required                    │  Title: titleLarge (20px DemiBold)
│    An application is attempting to perform an action     │  Message: bodyMedium (13px, centered)
│          that requires administrative privileges.        │
│                                                          │
│  ╭────────────────────────────────────────────────────╮  │  Expandable Action Details Card (Tier 3)
│  │  󰆍  Action: org.freedesktop.policykit.exec     󰅀   │  │  font.familyMono (11px)
│  │     PID: 48219 • Vendor: The systemd Project       │  │
│  ╰────────────────────────────────────────────────────╯  │
│  ╭──────────────────────────╮                            │
│  │  󰀄  pawan (wheel)      󰅀 │                            │  Admin Identity Chip
│  ╰──────────────────────────╯                            │
│  ╭────────────────────────────────────────────────────╮  │
│  │  󰌾   ••••••••••••                              󰈈   │  │  M3TextField Password Input + Reveal Toggle
│  ╰────────────────────────────────────────────────────╯  │
│                       ╭──────────────╮  ╭──────────────╮ │
│                       │    Cancel    │  │ Authenticate │ │  M3Button ("tonal" + "filled")
│                       ╰──────────────╯  ╰──────────────╯ │
╰──────────────────────────────────────────────────────────╯
```

---

## 4. Token Mapping Table

| Element | Surface / Fill Token | Foreground / Text Token | Typography Token | Radius / Metric Token |
|---|---|---|---|---|
| **Modal Container** | `Tokens.color.surfaceTier(0)` | `Tokens.color.onSurface` | — | `width: 420px`, `radius: xxl (28px)`, `padding: 24px` |
| **Hero Shield Badge** | `Tokens.color.tertiaryContainer` | `Tokens.color.onTertiaryContainer` | Icon `24px` (`"admin_panel_settings"`) | `48px × 48px`, `radius: lg (16px)` |
| **Dialog Title** | `"transparent"` | `Tokens.color.onSurface` | `titleLarge` (`20px`, `600`) | Centered |
| **Action Metadata Well** | `Tokens.color.surfaceTier(3)` | `Tokens.color.onSurfaceVariant` | `familyMono`, `11px` (`tnum` on PID) | `radius: md (12px)`, `padding: 10px` |
| **Password Input Field** | `Tokens.color.surfaceTier(2)` | `Tokens.color.onSurface` | `bodyLarge` (`15px`) | `height: 46px`, `radius: md (12px)`, `2px` `primary` focus border |
| **Cancel Button** | `Tokens.color.surfaceTier(2)` (`"tonal"`) | `Tokens.color.onSurface` | `labelLarge` (`13px`) | `height: 38px`, `radius: full` |
| **Authenticate CTA** | `Tokens.color.primary` (`"filled"`) | `Tokens.color.onPrimary` | `labelLarge` (`13px`, `600`) | `height: 38px`, `radius: full` |

---

## 5. Interactive State Matrix

| State | Visual & Functional Behavior |
|---|---|
| **`Prompting`** | Password field focused; `"Authenticate"` button disabled (`opacity: 0.38`) when `password.length === 0`. |
| **`Verifying`** | Password field and buttons lock (`enabled: false`); `"Authenticate"` button displays inline `16px` `M3CircularProgress`. |
| **`Failed Retry`** | Increments `attemptCount` (`1..3`); border turns `Tokens.color.error`; always displays `"Incorrect password (2 attempts remaining)"` in `Tokens.color.error` below the field (announced to screen readers); refocuses the field with its text selected. The horizontal spring shake is added only when `Tokens.motion.decorativeMotionEnabled`. |
| **`Canceled / Timeout`** | Dismisses modal and returns `CancelAuthentication` over D-Bus to the Polkit authority. |

---

## 6. Motion & Morph Choreography

1. **Modal Entrance**: Scales from `0.90 -> 1.0` via `Tokens.motion.springDefaultSpatial` while the shield badge pops `scale: 0.6 -> 1.0` (`springFastSpatial`).
2. **Technical Details Drawer Unfold**: Clicking the `actionId` pill animates the metadata well height from `36px -> 96px` via `Tokens.motion.springDefaultSpatial`.

---

## 7. Quickshell Service & IPC Bindings

- **Polkit D-Bus Agent (`org.freedesktop.PolicyKit1.AuthenticationAgent`)**:
  - Receives `BeginAuthentication(actionId, message, iconName, details, cookie, identities)`.
  - Spawns `polkit-agent-helper-1 <username>` via `Quickshell.Io.Process` (or `PamContext`) and writes the password to `stdin`.

---

## 8. Canonical QML Reference Skeleton (`PolkitDialog.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens

PanelWindow {
    id: polkitWindow
    visible: ShellState.activeModal === "polkit"
    WlrLayershell.namespace: "mat-polkit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    property string actionId: "org.freedesktop.policykit.exec"
    property string messageText: "Authentication is required to run '/usr/bin/pacman -Syu' as superuser."
    property bool detailsExpanded: false

    Rectangle {
        anchors.fill: parent
        color: Tokens.color.withAlpha(Tokens.color.scrim, 0.45)
    }

    M3Surface {
        anchors.centerIn: parent
        width: Tokens.metrics.polkitModalWidth
        implicitHeight: dialogCol.implicitHeight + 48
        tier: 0
        cornerRadius: Tokens.shape.xxl

        Keys.onEscapePressed: ShellState.closeActiveModal()

        ColumnLayout {
            id: dialogCol
            anchors.fill: parent
            anchors.margins: 24
            spacing: Tokens.metrics.spaceMd

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 48; height: 48
                radius: Tokens.shape.lg
                color: Tokens.color.tertiaryContainer
                Text {
                    anchors.centerIn: parent
                    text: "admin_panel_settings"
                    font.family: Tokens.typography.familyIcons
                    font.pixelSize: 26
                    color: Tokens.color.onTertiaryContainer
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Authentication Required"
                font.family: Tokens.typography.titleLarge.family
                font.pixelSize: Tokens.typography.titleLarge.pixelSize
                font.weight: Font.DemiBold
                color: Tokens.color.onSurface
            }

            Text {
                Layout.fillWidth: true
                text: polkitWindow.messageText
                font.family: Tokens.typography.bodyMedium.family
                font.pixelSize: Tokens.typography.bodyMedium.pixelSize
                color: Tokens.color.onSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            // Expandable Action ID Pill
            M3Surface {
                Layout.fillWidth: true
                implicitHeight: polkitWindow.detailsExpanded ? 64 : 34
                tier: 3
                interactive: true
                cornerRadius: Tokens.shape.md
                onClicked: polkitWindow.detailsExpanded = !polkitWindow.detailsExpanded

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    text: polkitWindow.actionId
                    font.family: Tokens.typography.familyMono
                    font.pixelSize: 11
                    color: Tokens.color.onSurfaceVariant
                }
            }

            // Password Input
            M3Surface {
                Layout.fillWidth: true
                implicitHeight: 46
                tier: 2
                cornerRadius: Tokens.shape.md
                border.width: 2
                border.color: Tokens.color.primary

                TextInput {
                    id: pwInput
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    echoMode: TextInput.Password
                    color: Tokens.color.onSurface
                    onAccepted: ShellState.closeActiveModal()
                }
            }

            // Action Buttons
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: Tokens.metrics.spaceSm

                M3Surface {
                    implicitWidth: 92; implicitHeight: 38
                    tier: 2; interactive: true
                    cornerRadius: Tokens.shape.full
                    onClicked: ShellState.closeActiveModal()
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.family: Tokens.typography.labelLarge.family
                        font.pixelSize: Tokens.typography.labelLarge.pixelSize
                        color: Tokens.color.onSurface
                    }
                }

                M3Surface {
                    implicitWidth: 124; implicitHeight: 38
                    tier: 4; interactive: true; active: true
                    cornerRadius: Tokens.shape.full
                    onClicked: ShellState.closeActiveModal()
                    Text {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        font.family: Tokens.typography.labelLarge.family
                        font.pixelSize: Tokens.typography.labelLarge.pixelSize
                        font.weight: Font.DemiBold
                        color: Tokens.color.onPrimary
                    }
                }
            }
        }
    }
}
```
