pragma Singleton
import QtQuick
import Quickshell

/**
 * Tokens.qml — Root Unified Design System Singleton Facade
 *
 * Every Quickshell component imports this module and binds exclusively to:
 * - Tokens.color.<role>
 * - Tokens.motion.<springOrCurve>
 * - Tokens.shape.<radius>
 * - Tokens.typography.<scale>
 * - Tokens.metrics.<dimension>
 *
 * Runtime surface state (open popovers, modals, Widget Peek) lives in ShellState.qml, not here.
 */
Singleton {
    id: root

    // Global Runtime Mode Switches
    property bool darkMode: true
    property string surfaceMode: "frosted_tonal_glass" // "frosted_tonal_glass" | "opaque_tonal"
    property string desktopMode: "tiling"              // "tiling" | "floating"
    property string densityMode: "comfortable"         // "compact" | "comfortable" | "spacious"
    property string schemeVariant: "scheme-tonal-spot" // matugen -t: tonal-spot | vibrant | expressive | content | fidelity | rainbow | fruit-salad | neutral | monochrome
    property bool themedIcons: true                    // Monochrome HCT tinting for persistent chrome only (bar `apps` widgets, desktop widgets)
    // Bars are user data, not token switches: see ConfigService `bars[]` (SC-01) and Settings → Bars (SC-16)
    property bool desktopWidgetsEnabled: true          // SC-15 WlrLayer.Background expressive widgets
    property real widgetScale: 1.0                     // 0.75 | 0.9 | 1.0 | 1.25 | 1.5

    // Accessibility Modes — first-class switches every surface honors live (loaded from ~/.config/mat-shell/config.json)
    property bool reducedMotion: false                 // No spatial travel, overshoot or decorative loops; 100ms crossfades remain
    property bool reducedTransparency: false           // Every tier renders opaque and compositor blur is disabled
    property bool highContrast: false                  // Opaque tiers, full-strength `outline` borders, 3px focus ring
    property real textScale: 1.0                       // 1.0 | 1.15 | 1.3 (Large Text); scales type and bar chrome
    property bool keyboardModality: false              // Focus-visible heuristic: true after Tab/arrow keys, false after pointer press
    property bool confirmByHold: true                  // Destructive actions: hold 2s (true) or press twice (false, motor-accessibility fallback)
    property bool expressiveSprings: true              // Settings → Animations → Expressive bounce; false = critically damped springs (no overshoot)

    // Sub-token Singletons
    readonly property QtObject color: ColorTokens
    readonly property QtObject motion: MotionTokens
    readonly property QtObject shape: ShapeTokens
    readonly property QtObject typography: TypographyTokens
    readonly property QtObject metrics: MetricTokens

    // Mode Helpers
    readonly property bool isGlass: surfaceMode === "frosted_tonal_glass" && !reducedTransparency && !highContrast
    readonly property bool isTiling: desktopMode === "tiling"
    readonly property bool isFloating: desktopMode === "floating"

    // Sub-singletons always mirror the facade, however a switch was changed (IPC, config file, UI)
    Binding { target: ColorTokens; property: "darkMode"; value: root.darkMode }
    Binding { target: ColorTokens; property: "surfaceMode"; value: root.surfaceMode }
    Binding { target: ColorTokens; property: "schemeVariant"; value: root.schemeVariant }
    Binding { target: ColorTokens; property: "reducedTransparency"; value: root.reducedTransparency }
    Binding { target: ColorTokens; property: "highContrast"; value: root.highContrast }
    Binding { target: MotionTokens; property: "reducedMotion"; value: root.reducedMotion }
    Binding { target: MotionTokens; property: "expressiveSprings"; value: root.expressiveSprings }
    Binding { target: TypographyTokens; property: "textScale"; value: root.textScale }
    Binding { target: MetricTokens; property: "densityMode"; value: root.densityMode }
    Binding { target: MetricTokens; property: "textScale"; value: root.textScale }
    Binding { target: MetricTokens; property: "highContrast"; value: root.highContrast }

    function toggleDarkMode(): void {
        darkMode = !darkMode
    }

    function setSurfaceMode(mode: string): void {
        if (mode === "frosted_tonal_glass" || mode === "opaque_tonal") surfaceMode = mode
    }

    function setDesktopMode(mode: string): void {
        if (mode === "tiling" || mode === "floating") desktopMode = mode
    }

    function setDensityMode(mode: string): void {
        if (mode === "compact" || mode === "comfortable" || mode === "spacious") densityMode = mode
    }

    function setWidgetScale(scale: real): void {
        if ([0.75, 0.9, 1.0, 1.25, 1.5].indexOf(scale) !== -1) widgetScale = scale
    }

    function setTextScale(scale: real): void {
        if ([1.0, 1.15, 1.3].indexOf(scale) !== -1) textScale = scale
    }
}
