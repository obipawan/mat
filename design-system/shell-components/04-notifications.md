# Shell Component 04 — Notification Toast Popups & Notification Center

> **Module**: `design-system/shell-components/04-notifications.md`
> **Component ID**: `SC-04`
> **Primitives Used**: `M3Surface`, `M3Card`, `M3Button`, `M3IconButton`, `M3TextField`, `M3CircularProgress`

---

## 1. Purpose & Wayland Layer Config

The **Notification Subsystem** acts as the Wayland desktop's `org.freedesktop.Notifications` daemon via `Quickshell.Services.Notifications`. It comprises two distinct surfaces:
1. **Notification Toast Stack**: Non-intrusive transient cards in a corner of the active monitor (Settings → Notifications; default top-end), offset clear of every visible bar via `BarService.insets`.
2. **Notification Center Panel**: Grouped historical notification inbox with app bundling, inline reply, and DND toggle.

| Property | Toast Stack (`NotificationToasts`) | Notification Center (`NotificationCenter`) |
|---|---|---|
| **`WlrLayershell.namespace`** | `"mat-toasts"` | `"mat-notifications"` |
| **`WlrLayershell.layer`** | `WlrLayer.Top` (`Overlay` for `Critical` urgency when fullscreen app active) | `WlrLayer.Top` |
| **Anchors** | The configured corner (default `top: true; right: true`), margins `BarService.insets + screenMargin`, `ExclusionMode.Ignore` | `top: true; right: true; bottom: true; left: true` (`M3Popover` placement from the `notifications` widget) |
| **Width** | `Tokens.metrics.notificationWidth` (`380px`) | `400px` |
| **`WlrLayershell.exclusiveZone`** | `0` | `0` |
| **`WlrLayershell.keyboardFocus`** | `None` (`OnDemand` when user clicks "Reply") | `OnDemand` |
| **Input Mask (`mask`)** | **Mandatory tight `Region { item: toastStackColumn }`** | Full screen when open |

---

## 2. Adaptive Dual-Mode Behavior (`tiling` vs. `floating`)

| Feature | `Tokens.desktopMode === "tiling"` | `Tokens.desktopMode === "floating"` |
|---|---|---|
| **Click-to-Focus Behavior** | Clicking a toast's default action switches to the originating window's tiled workspace (`Hyprland.dispatch("focuswindow ...")`) and flashes its border in `primary` | Raises and activates the floating window (`Toplevel.activate()`) |
| **Fullscreen Tiling Inhibition** | When the focused tiled window is fullscreen (`fullscreen === true`), `Low` and `Normal` toasts silently queue into Notification Center; only `Critical` toasts break through | Standard DND rules apply |

---

## 3. Visual Anatomy & ASCII Layout

```text
   NOTIFICATION TOAST CARD (Width: 380px)
   ╭──────────────────────────────────────────────────────────╮
   │  ╭────╮  Slack • #design-system            2m ago  ╭───╮ │  Header: App Icon (20px) + AppName + Time (tnum) + Dismiss ring
   │  │ 󰒱  │  Sarah Chen                                │ 󰅖 │ │  Title: titleSmall (13px DemiBold)
   │  ╰────╯  Updated the M3 Expressive slider tokens   ╰───╯ │  Body: bodyMedium (13px, max 3 lines collapsed, 8 expanded)
   │          for Quickshell. Can you review?                 │
   │  ╭─────────────────╮  ╭────────────────╮                 │  Action Row: Tonal pill buttons (height: 30px)
   │  │   󰑚  Reply      │  │  Open Thread   │                 │
   │  ╰─────────────────╯  ╰────────────────╯                 │
   ╰──────────────────────────────────────────────────────────╯
   ╭──────────────────────────────────────────────────────────╮
   │  +3 more notifications (2 from GitHub, 1 from System)  󰅀 │  Collapsed Stack Pill when > 3 active toasts
   ╰──────────────────────────────────────────────────────────╯
```

---

## 4. Urgency & Token Mapping Table

| Urgency Level (`NotificationUrgency`) | Card Surface Token | Border Token | Accent / Icon Badge Token | Default Timeout |
|---|---|---|---|---|
| **`Low`** | `Tokens.color.surfaceTier(0)` (`surfaceContainer`) | `1px` `surfaceBorder(0)` | `Tokens.color.secondary` | `4000ms` |
| **`Normal`** | `Tokens.color.surfaceTier(1)` (`surfaceContainerHigh`) | `1px` `surfaceBorder(1)` | `Tokens.color.primary` | `6000ms` |
| **`Critical`** | `Tokens.color.errorContainer` (`100%` opaque) | `1px` `Tokens.color.error` @ `50%` | `Tokens.color.onErrorContainer` | **`0` (Persistent until dismissed or action clicked)** |

| Inner Element | Token Mapping |
|---|---|
| **App Icon** | `M3AppIcon` with `themed: false` (original full-colour icon — recognition surface), `20px` |
| **App Name & Timestamp** | `Tokens.typography.labelSmall` (`11px`, `font.features: tabularFeatures`), `onSurfaceVariant` |
| **Summary (Title)** | `Tokens.typography.titleSmall` (`13px`, `600`), `onSurface` (`onErrorContainer` if Critical) |
| **Body Text** | `Tokens.typography.bodyMedium` (`13px`, `400`), `onSurfaceVariant` (`Markup` HTML stripped/sanitized) |
| **Action Buttons** | `M3Button` `"tonal"` (`height: 30px`, `radius: full`, `secondaryContainer` / `onSecondaryContainer`) |

---

## 5. Interactive State Matrix

| State | Visual & Behavioral Response |
|---|---|
| **Idle (Counting Down)** | Circular progress ring around the `"close"` (`󰅖`) button sweeps from `1.0 -> 0.0` over `6000ms`. |
| **Hovered** | **Pauses auto-dismiss timer** and resets ring to `1.0`; expands body text from `3` lines to `8` lines via `springFastSpatial`; reveals close button at `100%` opacity. |
| **Swiped Right (`DragHandler`)** | Dragging horizontally `> 120px` dismisses the notification (`notification.dismiss()`) with velocity-matched slide-out. |
| **Inline Reply Active** | Clicking `"Reply"` morphs the action row into an `M3TextField` + `"Send"` icon button and elevates `WlrLayershell.keyboardFocus` to `OnDemand`. |
| **Right Click** | Opens an `M3ContextMenu`: `Mute <App>`, `Notification settings`, `Dismiss`. Muting shows an inline `Undo` snackbar for `6s`. |
| **Announced (Screen Reader)** | Each new toast card calls `toastCard.Accessible.announce(summary + ", " + appName)` (Qt 6.8+) without taking focus; Critical toasts use `Accessible.role: Accessible.AlertMessage`. |
| **Never Lost** | Every toast, including expired or DND-suppressed ones, is archived in the Notification Center, so short timeouts never cost the user information. |

---

## 6. Motion & Morph Choreography

1. **Toast Entrance**: Slides in from `x: +380px -> 0px` and `scale: 0.92 -> 1.0` using `Tokens.motion.springDefaultSpatial`.
2. **Stack Reflow**: When the top toast is dismissed, lower toasts glide upward via `Layout` / `Move` transition bound to `Tokens.motion.springFastSpatial`.
3. **App Group Bundling in Notification Center**: Multiple notifications from the same `appName` stack with a `6px` vertical peek card behind the top card (`scale: 0.96`, `opacity: 0.75`); clicking the header unfolds the stack into individual cards with a `40ms` per-item stagger.

---

## 7. Quickshell Service & IPC Bindings

- **Notification Server (`Quickshell.Services.Notifications.NotificationServer`)**:
  - Properties enabled: `bodySupported: true`, `actionsSupported: true`, `imageSupported: true`, `inlineReplySupported: true`, `persistenceSupported: true`.
  - Signals: `onNotification(notification)` -> appends to `activeToastsModel` (unless `ShellState.dndEnabled && notification.urgency !== NotificationUrgency.Critical`) and `historyModel`.
  - Notification item methods: `notification.dismiss()`, `notification.expire()`, `action.invoke()`.

---

## 8. Canonical QML Reference Skeleton (`NotificationToasts.qml`)

```qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import MatShell.Tokens

PanelWindow {
    id: toastWindow
    WlrLayershell.namespace: "mat-toasts"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore   // offsets itself by BarService.insets (05-wayland-layershell-spatial.md §4.4)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Corner from Settings → Notifications (default top-end), clear of every visible bar on that screen
    readonly property var insets: BarService.insets(screen)
    readonly property bool atBottom: ConfigService.notifications.toastCorner?.startsWith("bottom") ?? false
    readonly property bool atLeft: ConfigService.notifications.toastCorner?.endsWith("left") ?? false
    anchors { top: !atBottom; bottom: atBottom; right: !atLeft; left: atLeft }
    margins.top: insets.top + Tokens.metrics.screenMargin
    margins.bottom: insets.bottom + Tokens.metrics.screenMargin
    margins.right: insets.right + Tokens.metrics.screenMargin
    margins.left: insets.left + Tokens.metrics.screenMargin
    implicitWidth: Tokens.metrics.notificationWidth + 16
    implicitHeight: 540
    color: "transparent"

    // CRITICAL: Only capture clicks inside the visible toast cards
    mask: Region {
        item: toastCol
    }

    NotificationServer {
        id: notifServer
        bodySupported: true
        actionsSupported: true
        imageSupported: true
    }

    ColumnLayout {
        id: toastCol
        anchors.top: parent.top
        anchors.right: parent.right
        width: Tokens.metrics.notificationWidth
        spacing: Tokens.metrics.spaceSm

        Repeater {
            model: notifServer.trackedNotifications
            delegate: M3Surface {
                required property Notification modelData
                readonly property bool isCritical: modelData.urgency === NotificationUrgency.Critical

                Layout.fillWidth: true
                implicitHeight: cardCol.implicitHeight + 24
                tier: 1
                customColor: isCritical ? Tokens.color.errorContainer : "transparent"
                contentColor: isCritical ? Tokens.color.onErrorContainer : Tokens.color.onSurface
                cornerRadius: Tokens.shape.xl
                interactive: true

                ColumnLayout {
                    id: cardCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: modelData.appName || "System"
                            font.family: Tokens.typography.labelSmall.family
                            font.pixelSize: Tokens.typography.labelSmall.pixelSize
                            color: isCritical ? Tokens.color.onErrorContainer : Tokens.color.onSurfaceVariant
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "close"
                            font.family: Tokens.typography.familyIcons
                            font.pixelSize: 16
                            color: isCritical ? Tokens.color.onErrorContainer : Tokens.color.onSurfaceVariant
                            TapHandler { onTapped: modelData.dismiss() }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary
                        font.family: Tokens.typography.titleSmall.family
                        font.pixelSize: Tokens.typography.titleSmall.pixelSize
                        font.weight: Font.DemiBold
                        color: isCritical ? Tokens.color.onErrorContainer : Tokens.color.onSurface
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: modelData.body !== ""
                        text: modelData.body
                        font.family: Tokens.typography.bodyMedium.family
                        font.pixelSize: Tokens.typography.bodyMedium.pixelSize
                        color: isCritical ? Tokens.color.onErrorContainer : Tokens.color.onSurfaceVariant
                        wrapMode: Text.Wrap
                        maximumLineCount: hovered ? 8 : 3
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
```
