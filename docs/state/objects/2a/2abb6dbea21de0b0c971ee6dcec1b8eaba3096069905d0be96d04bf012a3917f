# Interactions 01 — Cross-Surface Choreography, Mutual Exclusion & Shared-Origin Morphing

> **Module**: `design-system/interactions/01-choreography-and-morphing.md`
> **Singleton Contract**: `ShellState.qml`

---

## 1. Global `ShellState` Mutual Exclusion State Machine

In a desktop environment with 15 distinct layer-shell surfaces, opening one popover or modal without coordinating others causes overlapping panels, stuck keyboard grabs, and visual clutter. `ShellState.qml` enforces a strict **3-Lane Surface Orchestration Contract**:

```text
LANE 1: PERSISTENT BARS & AMBIENT HUDs (Coexist simultaneously)
  • 01-Bars × N (user-configured, any edge, bar or island mode; per-bar visibility) + M3ScreenCorners
  • 04-NotificationToasts (auto-hides when Fullscreen Modal or LockScreen active)
  • 07-OsdHuds (always renders on Overlay layer with keyboardFocus: None)
  • 15-DesktopWidgets (WlrLayer.Background; vivid / calm / hidden per SC-15)

LANE 2: BAR POPOVERS (Mutually Exclusive — max 1 active at any time; open from any bar's widget)
  • "control_center"  (03-ControlCenter)
  • "notifications"   (04-NotificationCenter)
  • "calendar"        (05-CalendarWeatherPanel)
  • "media"           (06-MediaPopover)

LANE 3: EXCLUSIVE OVERLAY MODALS (Mutually Exclusive — opening any closes Lane 2 Popovers)
  • "launcher"        (08-AppCommandLauncher)
  • "overview"        (09-WorkspaceOverview)
  • "power"           (11-PowerSessionMenu)
  • "polkit"          (12-PolkitDialog — highest modal priority, preempts launcher/overview)
  • "capture"         (13-ScreenCaptureHud)
  • "theme_studio"    (14-WallpaperThemePicker)
  • "widget_peek"     (15-DesktopWidgets raised to Overlay by Super+D)

OUTSIDE THE LANES: 16-Settings is a normal application window (xdg toplevel). Opening it closes
any Lane 2 popover and Lane 3 modal (except "polkit"), then it coexists with Lane 1 like any app.
```

### 1.1 State Transition Priority Rules
1. **Popover-to-Popover Handoff (`Lane 2 -> Lane 2`)**:
   - If `"control_center"` is open and the user clicks a bar's `clock` widget (`"calendar"`), `"control_center"` exits with `durationShort3` (`150ms` fast accelerate) while `"calendar"` unfolds immediately via `Tokens.motion.springDefaultSpatial` — **zero double-click required**.
2. **Modal Preemption (`Lane 3` overrides `Lane 2`)**:
   - Pressing `Super` to open `"launcher"` while `"control_center"` is open immediately closes `"control_center"` (`activePopover = ""`) and opens `"launcher"` (`activeModal = "launcher"`).
3. **System Security Preemption (`Polkit` & `LockScreen`)**:
   - When a Polkit privilege prompt arrives (`SC-12`), it preempts every other modal and popover.
   - **Security modal protection**: While `"polkit"` is active, `toggleModal()`, `openModal()`, and `togglePopover()` for anything else are ignored. A stray `Super` press can never hide an authentication prompt; only the prompt's own result (authenticate, cancel, timeout) closes it.
   - When `sessionLocked = true` (`SC-10`), **both** `activePopover` and `activeModal` reset to `""` before `WlSessionLock` engages, ensuring no open menus remain visible upon unlock. A pending Polkit request is cancelled through its agent (`CancelAuthentication`) first, so no orphaned request remains.
4. **Origin Registry**: Bar widgets call `ShellState.registerTrigger(name, item)` on creation and `unregisterTrigger` on destruction. A widget may exist on several bars and screens, so the registry keeps every instance. Clicks pass the clicked instance; keyboard/IPC opens (`triggerItem === null`) use the first instance on the focused screen, in bar order. With no instance anywhere, the popover opens in the top-end corner inside `BarService.insets` (`popoverOriginEdge = "none"`).
5. **Origin Edge**: `togglePopover()` records `popoverOriginEdge` from the trigger's `barEdge`, so `M3Popover` places and grows the card away from that bar (`04-menus-popovers-and-tooltips.md` §1.1).

---

## 2. Shared-Origin Pill-to-Popover Morphing Contract

When a bar widget (`M3BarPill`, on a bar at any edge) opens a `Lane 2` popover (shown here for a top bar; other edges mirror it along the bar's normal):

```text
t = 0ms (Click)                t = 80ms (Mid-Flight)               t = 320ms (Settled)
╭──────────────────╮           ╭──────────────────────────╮        ╭────────────────────────────────────╮
│ 󰤨  󰂯  󰕾 72%  󰁹 │ ────────► │  Morphing Container      │ ─────► │ Control Center Bento Grid          │
╰──────────────────╯           │  radius: 15px -> 24px    │        │ [Wi-Fi] [BT] [DND] [Night Light]   │
                               ╰──────────────────────────╯        ╰────────────────────────────────────╯
```

| Phase | Time Window | Animated Properties | Spring / Curve Token |
|---|---|---|---|
| **1. Trigger Pill Lock** | `0ms – 120ms` | Trigger pill background shifts to `Tokens.color.primaryContainer`, corner radius morphs `15px -> 12px` | `Tokens.motion.springFastEffects` |
| **2. Container Unfold** | `0ms – 350ms` | Popover card `scale: 0.88 -> 1.0`, offset along the bar's normal from `innerEdge - 8` to `innerEdge + screenMargin`, `radius: 15px -> 24px` (`xl`), aligned to `popoverOriginRect` along the bar axis | `Tokens.motion.springDefaultSpatial` (`damping: 0.72`, `spring: 4.5`) |
| **3. Inner Content Cascade** | `50ms – 230ms` | Inner bento rows translate `y: -8px -> 0px` and fade `opacity: 0.0 -> 1.0` with `25ms` row stagger | `Tokens.motion.springFastEffects` |
| **4. Dismiss Collapse** | `0ms – 160ms` | Card scales `1.0 -> 0.92`, `opacity: 1.0 -> 0.0`; trigger pill restores `surfaceTier(2)` and `radius: full` | `curveEmphasizedAccelerate` (`160ms`) |

---

## 3. Canonical `ShellState.qml` Singleton Implementation

```qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string activePopover: ""     // "" | "control_center" | "notifications" | "calendar" | "media"
    property string activeModal: ""       // "" | "launcher" | "overview" | "power" | "polkit" | "capture" | "theme_studio" | "widget_peek"
    property string launcherMode: "apps"  // "apps" | "win" | "calc" | "clip" | "cmd" | "emoji"
    property bool sessionLocked: false
    property bool dndEnabled: false
    property bool barFocusActive: false   // Bar Focus Mode: every bar on the focused screen accepts keyboard focus
    property rect popoverOriginRect: Qt.rect(0, 0, 120, 30)
    property string popoverOriginEdge: "none" // "top" | "right" | "bottom" | "left" | "none" (no hosting bar)
    property Item popoverTrigger: null        // the instance the popover grew from (widgets highlight only that one)
    property var triggerItems: ({})           // name -> [Item], every instance on every bar and screen

    readonly property bool widgetPeekActive: activeModal === "widget_peek"
    readonly property bool securityModalActive: activeModal === "polkit"

    function registerTrigger(name: string, item: Item): void {
        triggerItems[name] = (triggerItems[name] ?? []).concat([item])
        item.Component.destruction.connect(() => unregisterTrigger(name, item))
    }

    function unregisterTrigger(name: string, item: Item): void {
        triggerItems[name] = (triggerItems[name] ?? []).filter(i => i !== item)
        if (popoverTrigger === item) popoverTrigger = null
    }

    // First instance on the focused screen, in bar order (BarService sorts instances by config order)
    function resolveTrigger(name: string): Item {
        const items = triggerItems[name] ?? []
        return items.find(i => i.QsWindow.window?.screen === CompositorService.focusedScreen) ?? items[0] ?? null
    }

    function togglePopover(name: string, triggerItem: Item): void {
        if (sessionLocked || securityModalActive) return
        activeModal = ""
        if (activePopover === name && (!triggerItem || triggerItem === popoverTrigger)) {
            activePopover = ""
            return
        }
        const origin = triggerItem ?? resolveTrigger(name)
        popoverTrigger = origin
        popoverOriginEdge = origin?.barEdge ?? "none"
        if (origin) {
            const pos = origin.mapToGlobal(0, 0)
            popoverOriginRect = Qt.rect(pos.x, pos.y, origin.width, origin.height)
        }
        activePopover = name
    }

    // Settings (SC-16) is an xdg toplevel outside the lanes; opening it clears popovers and modals
    signal settingsRequested(string page)
    function openSettings(page: string): void {
        if (sessionLocked || securityModalActive) return
        activePopover = ""
        activeModal = ""
        barFocusActive = false
        settingsRequested(page || "")
    }

    function closeActivePopover(): void {
        activePopover = ""
    }

    function toggleModal(name: string): void {
        if (sessionLocked) return
        if (securityModalActive && name !== "polkit") return   // never hide an authentication prompt
        activePopover = ""
        activeModal = (activeModal === name) ? "" : name
    }

    function openModal(name: string): void {
        if (sessionLocked) return
        if (securityModalActive && name !== "polkit") return
        activePopover = ""
        activeModal = name
    }

    function closeActiveModal(): void {
        activeModal = ""
    }

    function openLauncherMode(mode: string): void {
        launcherMode = mode
        openModal("launcher")
    }

    function lockSession(): void {
        activePopover = ""
        activeModal = ""
        barFocusActive = false
        sessionLocked = true
    }

    // Quickshell IPC so compositor keybinds (`qs ipc call shell ...`) work out of the box
    IpcHandler {
        target: "shell"
        function toggleLauncher(): void { root.toggleModal("launcher") }
        function openLauncherMode(mode: string): void { root.openLauncherMode(mode) }
        function toggleOverview(): void { root.toggleModal("overview") }
        function toggleControlCenter(): void { root.togglePopover("control_center", null) }
        function toggleNotifications(): void { root.togglePopover("notifications", null) }
        function toggleCalendar(): void { root.togglePopover("calendar", null) }
        function toggleMedia(): void { root.togglePopover("media", null) }
        function togglePower(): void { root.toggleModal("power") }
        function toggleCapture(): void { root.toggleModal("capture") }
        function toggleThemeStudio(): void { root.toggleModal("theme_studio") }
        function toggleWidgetPeek(): void { root.toggleModal("widget_peek") }
        function openSettings(page: string): void { root.openSettings(page) } // e.g. "bars/top", "keybindings"
        function focusBar(): void {
            if (root.sessionLocked || root.securityModalActive) return
            root.barFocusActive = true
            Tokens.keyboardModality = true
        }
        function setA11y(name: string, value: string): void {
            if (name === "reducedMotion") Tokens.reducedMotion = value === "true"
            else if (name === "reducedTransparency") Tokens.reducedTransparency = value === "true"
            else if (name === "highContrast") Tokens.highContrast = value === "true"
            else if (name === "textScale") Tokens.setTextScale(parseFloat(value))
            else if (name === "expressiveSprings") Tokens.expressiveSprings = value === "true"
        }
        function lock(): void { root.lockSession() }
    }
}
```
