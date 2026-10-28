pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * ColorTokens.qml — Material 3 colour roles fed live by matugen + Dual-Surface Engine resolvers.
 *
 * Pipeline (01-color-and-surfaces.md §1): matugen >= 4.0 renders design-system/tokens/matugen/theme.json.tpl
 * into $XDG_CONFIG_HOME/mat-shell/theme.json (default ~/.config) with BOTH polarities. Dark/Light therefore switches instantly between
 * the two blocks without re-running matugen, and role bindings are never broken by file reloads.
 *
 * Defaults are matugen's own output for the M3 baseline seed #6750A4 (tokens/matugen/theme.baseline.json),
 * so the shell is fully themed before matugen runs and enabling matugen on the baseline causes no shift.
 */
Singleton {
    id: root

    property bool darkMode: true
    property string surfaceMode: "frosted_tonal_glass" // "frosted_tonal_glass" | "opaque_tonal"
    property string schemeVariant: "scheme-tonal-spot" // Mirrors Tokens.schemeVariant (the -t passed to matugen)
    property bool reducedTransparency: false           // Accessibility: forces opaque tiers
    property bool highContrast: false                  // Accessibility: opaque tiers + full-strength outline borders
    readonly property bool glassActive: surfaceMode === "frosted_tonal_glass" && !reducedTransparency && !highContrast

    readonly property QtObject activeScheme: darkMode ? theme.dark : theme.light
    readonly property string sourceColor: theme.sourceColor

    // matugen derives custom colours through the active variant, which drains them to gray under
    // scheme-monochrome / scheme-neutral; status colours then fall back to fixed, meaning-preserving hues.
    readonly property bool harmonizedStatus: schemeVariant !== "scheme-monochrome" && schemeVariant !== "scheme-neutral"

    // Same rule as paths.userDirs (docs/lld/02-contracts.md §2.13): an absolute $XDG_CONFIG_HOME, else $HOME/.config.
    // Repeated here because tokens cannot import services; ConfigService.configDir resolves to the same folder.
    readonly property string _configHome: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME")
        const home = Quickshell.env("HOME")
        if (typeof xdg === "string" && xdg.startsWith("/"))
            return xdg.replace(/\/+$/, "")
        return (typeof home === "string" && home.startsWith("/") ? home.replace(/\/+$/, "") : "") + "/.config"
    }

    FileView {
        id: themeFile
        path: root._configHome + "/mat-shell/theme.json"
        watchChanges: true
        blockLoading: true   // tiny file; avoids a startup flash of baseline colours
        onFileChanged: reloadDebounce.restart()

        // A missing or malformed file keeps the last good values (baseline on first start)
        JsonAdapter {
            id: theme
            property string sourceColor: "#6750A4"
            property JsonObject dark: JsonObject {
                property string primary: "#CFBDFE"
                property string onPrimary: "#36275D"
                property string primaryContainer: "#4D3D75"
                property string onPrimaryContainer: "#E9DDFF"
                property string inversePrimary: "#65558F"
                property string primaryFixed: "#E9DDFF"
                property string primaryFixedDim: "#CFBDFE"
                property string onPrimaryFixed: "#201047"
                property string onPrimaryFixedVariant: "#4D3D75"
                property string secondary: "#CBC2DB"
                property string onSecondary: "#332D41"
                property string secondaryContainer: "#4A4458"
                property string onSecondaryContainer: "#E8DEF8"
                property string secondaryFixed: "#E8DEF8"
                property string secondaryFixedDim: "#CBC2DB"
                property string onSecondaryFixed: "#1E192B"
                property string onSecondaryFixedVariant: "#4A4458"
                property string tertiary: "#EFB8C8"
                property string onTertiary: "#4A2532"
                property string tertiaryContainer: "#633B48"
                property string onTertiaryContainer: "#FFD9E3"
                property string tertiaryFixed: "#FFD9E3"
                property string tertiaryFixedDim: "#EFB8C8"
                property string onTertiaryFixed: "#31101D"
                property string onTertiaryFixedVariant: "#633B48"
                property string error: "#FFB4AB"
                property string onError: "#690005"
                property string errorContainer: "#93000A"
                property string onErrorContainer: "#FFDAD6"
                property string surfaceDim: "#141218"
                property string surface: "#141218"
                property string surfaceTint: "#CFBDFE"
                property string surfaceBright: "#3B383E"
                property string surfaceContainerLowest: "#0F0D13"
                property string surfaceContainerLow: "#1D1B20"
                property string surfaceContainer: "#211F24"
                property string surfaceContainerHigh: "#2B292F"
                property string surfaceContainerHighest: "#36343A"
                property string onSurface: "#E6E0E9"
                property string onSurfaceVariant: "#CAC4CF"
                property string outline: "#948F99"
                property string outlineVariant: "#49454E"
                property string inverseSurface: "#E6E0E9"
                property string inverseOnSurface: "#322F35"
                property string surfaceVariant: "#49454E"
                property string shadow: "#000000"
                property string scrim: "#000000"
                property string success: "#8FD5B0"
                property string onSuccess: "#003824"
                property string successContainer: "#005236"
                property string onSuccessContainer: "#AAF2CB"
                property string warning: "#FFB77F"
                property string onWarning: "#4E2600"
                property string warningContainer: "#6C3A08"
                property string onWarningContainer: "#FFDCC3"
            }
            property JsonObject light: JsonObject {
                property string primary: "#65558F"
                property string onPrimary: "#FFFFFF"
                property string primaryContainer: "#E9DDFF"
                property string onPrimaryContainer: "#4D3D75"
                property string inversePrimary: "#CFBDFE"
                property string primaryFixed: "#E9DDFF"
                property string primaryFixedDim: "#CFBDFE"
                property string onPrimaryFixed: "#201047"
                property string onPrimaryFixedVariant: "#4D3D75"
                property string secondary: "#625B71"
                property string onSecondary: "#FFFFFF"
                property string secondaryContainer: "#E8DEF8"
                property string onSecondaryContainer: "#4A4458"
                property string secondaryFixed: "#E8DEF8"
                property string secondaryFixedDim: "#CBC2DB"
                property string onSecondaryFixed: "#1E192B"
                property string onSecondaryFixedVariant: "#4A4458"
                property string tertiary: "#7E5260"
                property string onTertiary: "#FFFFFF"
                property string tertiaryContainer: "#FFD9E3"
                property string onTertiaryContainer: "#633B48"
                property string tertiaryFixed: "#FFD9E3"
                property string tertiaryFixedDim: "#EFB8C8"
                property string onTertiaryFixed: "#31101D"
                property string onTertiaryFixedVariant: "#633B48"
                property string error: "#BA1A1A"
                property string onError: "#FFFFFF"
                property string errorContainer: "#FFDAD6"
                property string onErrorContainer: "#93000A"
                property string surfaceDim: "#DED8E0"
                property string surface: "#FDF7FF"
                property string surfaceTint: "#65558F"
                property string surfaceBright: "#FDF7FF"
                property string surfaceContainerLowest: "#FFFFFF"
                property string surfaceContainerLow: "#F8F2FA"
                property string surfaceContainer: "#F2ECF4"
                property string surfaceContainerHigh: "#ECE6EE"
                property string surfaceContainerHighest: "#E6E0E9"
                property string onSurface: "#1D1B20"
                property string onSurfaceVariant: "#49454E"
                property string outline: "#7A757F"
                property string outlineVariant: "#CAC4CF"
                property string inverseSurface: "#322F35"
                property string inverseOnSurface: "#F5EFF7"
                property string surfaceVariant: "#E7E0EB"
                property string shadow: "#000000"
                property string scrim: "#000000"
                property string success: "#236A4C"
                property string onSuccess: "#FFFFFF"
                property string successContainer: "#AAF2CB"
                property string onSuccessContainer: "#005236"
                property string warning: "#89511F"
                property string onWarning: "#FFFFFF"
                property string warningContainer: "#FFDCC3"
                property string onWarningContainer: "#6C3A08"
            }
        }
    }

    // matugen writes the file in one pass; the debounce never reads a half-written file
    Timer {
        id: reloadDebounce
        interval: 150
        onTriggered: themeFile.reload()
    }

    // Primary Family
    readonly property color primary: activeScheme.primary
    readonly property color onPrimary: activeScheme.onPrimary
    readonly property color primaryContainer: activeScheme.primaryContainer
    readonly property color onPrimaryContainer: activeScheme.onPrimaryContainer
    readonly property color inversePrimary: activeScheme.inversePrimary
    readonly property color primaryFixed: activeScheme.primaryFixed
    readonly property color primaryFixedDim: activeScheme.primaryFixedDim
    readonly property color onPrimaryFixed: activeScheme.onPrimaryFixed
    readonly property color onPrimaryFixedVariant: activeScheme.onPrimaryFixedVariant

    // Secondary Family
    readonly property color secondary: activeScheme.secondary
    readonly property color onSecondary: activeScheme.onSecondary
    readonly property color secondaryContainer: activeScheme.secondaryContainer
    readonly property color onSecondaryContainer: activeScheme.onSecondaryContainer
    readonly property color secondaryFixed: activeScheme.secondaryFixed
    readonly property color secondaryFixedDim: activeScheme.secondaryFixedDim
    readonly property color onSecondaryFixed: activeScheme.onSecondaryFixed
    readonly property color onSecondaryFixedVariant: activeScheme.onSecondaryFixedVariant

    // Tertiary Family
    readonly property color tertiary: activeScheme.tertiary
    readonly property color onTertiary: activeScheme.onTertiary
    readonly property color tertiaryContainer: activeScheme.tertiaryContainer
    readonly property color onTertiaryContainer: activeScheme.onTertiaryContainer
    readonly property color tertiaryFixed: activeScheme.tertiaryFixed
    readonly property color tertiaryFixedDim: activeScheme.tertiaryFixedDim
    readonly property color onTertiaryFixed: activeScheme.onTertiaryFixed
    readonly property color onTertiaryFixedVariant: activeScheme.onTertiaryFixedVariant

    // Error Family
    readonly property color error: activeScheme.error
    readonly property color onError: activeScheme.onError
    readonly property color errorContainer: activeScheme.errorContainer
    readonly property color onErrorContainer: activeScheme.onErrorContainer

    // Neutral & Surface Container Hierarchy
    readonly property color surfaceDim: activeScheme.surfaceDim
    readonly property color surface: activeScheme.surface
    readonly property color surfaceTint: activeScheme.surfaceTint
    readonly property color surfaceBright: activeScheme.surfaceBright
    readonly property color surfaceContainerLowest: activeScheme.surfaceContainerLowest
    readonly property color surfaceContainerLow: activeScheme.surfaceContainerLow
    readonly property color surfaceContainer: activeScheme.surfaceContainer
    readonly property color surfaceContainerHigh: activeScheme.surfaceContainerHigh
    readonly property color surfaceContainerHighest: activeScheme.surfaceContainerHighest
    readonly property color onSurface: activeScheme.onSurface
    readonly property color onSurfaceVariant: activeScheme.onSurfaceVariant
    readonly property color inverseSurface: activeScheme.inverseSurface
    readonly property color inverseOnSurface: activeScheme.inverseOnSurface
    readonly property color surfaceVariant: activeScheme.surfaceVariant

    // Outline, Shadow & Scrim
    readonly property color outline: activeScheme.outline
    readonly property color outlineVariant: activeScheme.outlineVariant
    readonly property color shadow: activeScheme.shadow
    readonly property color scrim: activeScheme.scrim

    // Desktop Status Extensions — matugen custom colours (harmonized toward the wallpaper hue)
    readonly property color success: harmonizedStatus ? activeScheme.success : (darkMode ? "#73DC82" : "#006B29")
    readonly property color onSuccess: harmonizedStatus ? activeScheme.onSuccess : (darkMode ? "#003912" : "#FFFFFF")
    readonly property color successContainer: harmonizedStatus ? activeScheme.successContainer : (darkMode ? "#3AA451" : "#118738")
    readonly property color onSuccessContainer: harmonizedStatus ? activeScheme.onSuccessContainer : (darkMode ? "#001403" : "#F7FFF2")
    readonly property color warning: harmonizedStatus ? activeScheme.warning : (darkMode ? "#FFCB8A" : "#835400")
    readonly property color onWarning: harmonizedStatus ? activeScheme.onWarning : (darkMode ? "#462B00" : "#FFFFFF")
    readonly property color warningContainer: harmonizedStatus ? activeScheme.warningContainer : "#F9A825"
    readonly property color onWarningContainer: harmonizedStatus ? activeScheme.onWarningContainer : "#674100"

    // Privacy indicator: fixed, never wallpaper-derived — it must stay unmistakably green in every scheme
    readonly property color privacyMicCam: darkMode ? "#5CE68A" : "#146C32"
    readonly property color onPrivacyMicCam: darkMode ? "#003919" : "#FFFFFF"

    /**
     * Resolves the background color (including alpha for frosted_tonal_glass vs opaque_tonal)
     * for one of the 5 canonical Desktop Surface Tiers:
     * - Tier 0: Shell Root (bars, islands, Popover roots, Settings window) -> surfaceContainer @ 78% (glass) or 100% (opaque)
     * - Tier 1: Elevated Group (Bento cards, inactive tiles, toast root) -> surfaceContainerHigh @ 90% (glass) or 100% (opaque)
     * - Tier 2: Interactive Control (Search field, nested buttons, hover surface) -> surfaceContainerHighest @ 96% (glass) or 100% (opaque)
     * - Tier 3: Inset Well (Workspace trough, slider inactive track) -> surfaceContainerLow @ 84% (glass) or 100% (opaque)
     * - Tier 4: Accent Active (Active quick tile, focused workspace pill) -> primary @ 100% (always opaque for WCAG contrast)
     * reducedTransparency and highContrast force every tier to 100% regardless of surfaceMode.
     */
    function surfaceTier(tier: int): color {
        const isGlass = glassActive
        switch (tier) {
            case 0:
                return withAlpha(surfaceContainer, isGlass ? 0.78 : 1.0)
            case 1:
                return withAlpha(surfaceContainerHigh, isGlass ? 0.90 : 1.0)
            case 2:
                return withAlpha(surfaceContainerHighest, isGlass ? 0.96 : 1.0)
            case 3:
                return withAlpha(surfaceContainerLow, isGlass ? 0.84 : 1.0)
            case 4:
                return primary
            default:
                return surfaceContainer
        }
    }

    /**
     * Resolves the structural 1px border color for a given Desktop Surface Tier.
     * highContrast replaces every tonal hairline with a full-strength `outline` border.
     */
    function surfaceBorder(tier: int): color {
        if (highContrast) return tier === 4 ? "transparent" : outline
        const isGlass = glassActive
        switch (tier) {
            case 0:
                return withAlpha(outlineVariant, isGlass ? 0.28 : 0.16)
            case 1:
                return withAlpha(outlineVariant, isGlass ? 0.18 : 0.12)
            case 2:
                return withAlpha(outlineVariant, isGlass ? 0.08 : 0.0)
            case 3:
                return withAlpha(outlineVariant, isGlass ? 0.14 : 0.10)
            default:
                return "transparent"
        }
    }

    /**
     * Resolves an M3 state-layer overlay color given the content color and interaction state.
     */
    function stateLayer(contentColor: color, hovered: bool, pressed: bool, focused: bool, dragged: bool): color {
        if (dragged) return withAlpha(contentColor, 0.16)
        if (pressed) return withAlpha(contentColor, 0.12)
        if (focused) return withAlpha(contentColor, 0.12)
        if (hovered) return withAlpha(contentColor, 0.08)
        return "transparent"
    }

    function withAlpha(baseColor: color, alpha: real): color {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha)
    }
}
