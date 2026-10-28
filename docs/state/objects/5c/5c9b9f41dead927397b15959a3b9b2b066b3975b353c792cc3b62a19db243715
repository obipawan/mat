pragma Singleton
import QtQuick
import Quickshell

/**
 * TypographyTokens.qml — Material 3 Desktop Type Scale & OpenType Feature Tokens
 *
 * Crucial Rule: All live numeric indicators (clock, battery, volume, CPU/RAM, timers)
 * MUST bind `font.features: Tokens.typography.tabularFeatures` to prevent width jitter.
 *
 * Every pixelSize / lineHeight is multiplied by `textScale` (Tokens.textScale: 1.0 | 1.15 | 1.3 Large Text).
 */
Singleton {
    id: root

    property real textScale: 1.0

    function scaled(px: int): int {
        return Math.round(px * textScale)
    }

    // Google Sans Flex (SIL OFL 1.1) is one variable family for both roles: its opsz axis covers text and display
    // sizes. Every font here ships with the mat-shell package (packaging/dependencies.json "fonts").
    readonly property string familySans: "Google Sans Flex"
    readonly property string familyDisplay: "Google Sans Flex"
    readonly property string familyEditorial: "Instrument Serif"
    readonly property string familyMono: "JetBrains Mono"
    readonly property string familyIcons: "Material Symbols Rounded"

    // Mandatory OpenType feature map for numeric counters
    readonly property var tabularFeatures: ({ "tnum": 1 })

    // Expressive Hero Scale (Desktop Widgets, Layered Duotone Clocks, Editorial Dates) — hero text only (>= 45px)
    readonly property QtObject displayExpressiveHero: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(96)
        readonly property int lineHeight: root.scaled(96)
        readonly property int weight: Font.Bold
        readonly property real letterSpacing: -2.0
        readonly property real duotoneLayerOffsetRatio: 0.06  // Back (tonal) layer offset, x and y, as a fraction of pixelSize
        readonly property real duotoneGroupGapRatio: 0.18     // Clear gap between the hour and minute groups (never overlap)
        readonly property real duotoneSecondaryAlpha: 0.78    // Back layer alpha
    }
    readonly property QtObject displayEditorial: QtObject {
        readonly property string family: root.familyEditorial
        readonly property int pixelSize: root.scaled(54)
        readonly property int lineHeight: root.scaled(58)
        readonly property int weight: Font.Normal
        readonly property real letterSpacing: -0.5
    }

    // Display Scale (Lock screen clock, oversized expressive hero numbers)
    readonly property QtObject displayLarge: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(57)
        readonly property int lineHeight: root.scaled(64)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: -0.25
    }
    readonly property QtObject displayMedium: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(45)
        readonly property int lineHeight: root.scaled(52)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }
    readonly property QtObject displaySmall: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(36)
        readonly property int lineHeight: root.scaled(44)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }

    // Headline Scale (Calendar date header, Weather temp, Modal titles)
    readonly property QtObject headlineLarge: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(32)
        readonly property int lineHeight: root.scaled(40)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }
    readonly property QtObject headlineMedium: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(28)
        readonly property int lineHeight: root.scaled(36)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }
    readonly property QtObject headlineSmall: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(24)
        readonly property int lineHeight: root.scaled(32)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }

    // Title Scale (Popover headers, Card titles, Launcher section headers)
    readonly property QtObject titleLarge: QtObject {
        readonly property string family: root.familyDisplay
        readonly property int pixelSize: root.scaled(20)
        readonly property int lineHeight: root.scaled(28)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.0
    }
    readonly property QtObject titleMedium: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(15)
        readonly property int lineHeight: root.scaled(22)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.1
    }
    readonly property QtObject titleSmall: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(13)
        readonly property int lineHeight: root.scaled(18)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.1
    }

    // Body Scale (Notification body, Launcher descriptions, Settings rows)
    readonly property QtObject bodyLarge: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(15)
        readonly property int lineHeight: root.scaled(22)
        readonly property int weight: Font.Normal
        readonly property real letterSpacing: 0.15
    }
    readonly property QtObject bodyMedium: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(13)
        readonly property int lineHeight: root.scaled(18)
        readonly property int weight: Font.Normal
        readonly property real letterSpacing: 0.15
    }
    readonly property QtObject bodySmall: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(12)
        readonly property int lineHeight: root.scaled(16)
        readonly property int weight: Font.Normal
        readonly property real letterSpacing: 0.2
    }

    // Label Scale (Bar widget pills, Quick tile labels, Chips, Shortcuts, Badges)
    readonly property QtObject labelLarge: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(13)
        readonly property int lineHeight: root.scaled(18)
        readonly property int weight: Font.DemiBold
        readonly property real letterSpacing: 0.1
    }
    readonly property QtObject labelMedium: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(12)
        readonly property int lineHeight: root.scaled(16)
        readonly property int weight: Font.Medium
        readonly property real letterSpacing: 0.25
    }
    readonly property QtObject labelSmall: QtObject {
        readonly property string family: root.familySans
        readonly property int pixelSize: root.scaled(11)
        readonly property int lineHeight: root.scaled(14)
        readonly property int weight: Font.Medium
        readonly property real letterSpacing: 0.3
    }
}
