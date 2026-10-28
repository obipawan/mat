pragma Singleton
import QtQuick
import Quickshell

/**
 * MetricTokens.qml — Density-Adaptive Dimensions, Spacing Grid, State Alphas, Hit Targets & Wayland Constants
 */
Singleton {
    id: root

    property string densityMode: "comfortable" // "compact" | "comfortable" | "spacious"
    property real textScale: 1.0               // Mirrors Tokens.textScale so bar chrome grows with Large Text
    property bool highContrast: false          // Mirrors Tokens.highContrast

    readonly property real chromeScale: 1.0 + (textScale - 1.0) * 0.6

    // 4px Base Spacing Scale
    readonly property int spaceXxs: 2
    readonly property int spaceXs: 4
    readonly property int spaceSm: 8
    readonly property int spaceMd: 12
    readonly property int spaceLg: 16
    readonly property int spaceXl: 20
    readonly property int spaceXxl: 24
    readonly property int spaceXxxl: 32

    // Icon Sizes
    readonly property int iconXs: 14
    readonly property int iconSm: 16
    readonly property int iconMd: 20
    readonly property int iconLg: 24
    readonly property int iconXl: 32
    readonly property int iconHero: 48

    // Density-Adaptive Bar Defaults (SC-01). Each bar stores its own thickness; these seed new bars and presets.
    readonly property int barThickness: Math.round((densityMode === "compact" ? 32 : (densityMode === "spacious" ? 48 : 40)) * chromeScale)
    readonly property int dockThickness: Math.round((densityMode === "compact" ? 52 : (densityMode === "spacious" ? 76 : 64)) * chromeScale)
    readonly property int islandThickness: Math.round(56 * chromeScale)
    readonly property int appIconSize: densityMode === "compact" ? 36 : (densityMode === "spacious" ? 52 : 44) // M3AppIcon default; the apps widget sizes wells from bar thickness
    readonly property int barPadding: densityMode === "compact" ? 4 : 5
    readonly property int barPillHeight: barThickness - 2 * barPadding // pill size for a default-thickness bar
    readonly property int barSectionGap: densityMode === "compact" ? 4 : 8
    readonly property int barThicknessMin: 28
    readonly property int barThicknessMax: 96
    readonly property int verticalBarThicknessMin: 44
    readonly property int verticalBarThicknessMax: 120
    readonly property int maxBarsPerEdge: 2
    readonly property real maxReservedShare: 0.25 // per axis, per screen
    readonly property int barRevealStrip: 4
    readonly property int barRevealDwellMs: 120
    readonly property int screenMargin: densityMode === "compact" ? 6 : (densityMode === "spacious" ? 12 : 8)

    // Settings window (SC-16)
    readonly property int settingsNavWidth: 248
    readonly property int settingsContentMaxWidth: 760
    readonly property int settingsCompactBreakpoint: 760
    readonly property int settingsRowMinHeight: 56

    // Pointer Target Contract (WCAG 2.5.8 floor is 24px)
    readonly property int minPointerTarget: densityMode === "compact" ? 24 : 32
    readonly property int minIconButtonTarget: 36

    // Popover & Modal Standard Widths
    readonly property int controlCenterWidth: densityMode === "compact" ? 360 : (densityMode === "spacious" ? 424 : 392)
    readonly property int notificationWidth: 380
    readonly property int calendarWeatherWidth: 680
    readonly property int mediaPopoverWidth: 360
    readonly property int osdPillWidth: 260
    readonly property int osdPillHeight: 52
    readonly property int launcherWidth: 640
    readonly property int launcherMaxHeight: 520
    readonly property int polkitModalWidth: 420

    // M3 State Layer Opacities
    readonly property real stateHoverAlpha: 0.08
    readonly property real stateFocusAlpha: 0.12
    readonly property real statePressAlpha: 0.12
    readonly property real stateDragAlpha: 0.16
    readonly property real disabledContentAlpha: 0.38
    readonly property real disabledContainerAlpha: 0.12

    // Modal Scrim (M3Scrim, Widget Peek, Overlay modals)
    readonly property real scrimAlpha: 0.42

    // Focus Ring Contract
    readonly property int focusRingWidth: highContrast ? 3 : 2
    readonly property int focusRingOffset: 2

    // Wheel Accumulation Contract (one logical step per notch or per touchpad travel distance)
    readonly property int wheelStepAngle: 120
    readonly property int touchpadStepPixels: 40

    // Compositor Blur Contract (for frosted_tonal_glass mode)
    readonly property int glassBlurRadius: 64
    readonly property real glassNoiseStrength: 0.02
}
