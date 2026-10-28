// expect: none
import QtQuick
import MatShell.Tokens
import MatShell.Primitives
import MatShell.Services

M3BarPill {
    id: pill
    property var options: ({})
    property bool vertical: false
    readonly property var opt: BarWidgetRegistry.resolve("clock", pill.options, vertical ? "vertical" : "horizontal")
    accessibleName: Qt.formatDateTime(clock.date, "dddd d MMMM, HH:mm")
    tooltipText: accessibleName

    Text {
        text: Qt.formatDateTime(clock.date, "HH:mm")
        font.family: Tokens.typography.labelLarge.family
        font.pixelSize: Tokens.typography.labelLarge.pixelSize
        font.features: Tokens.typography.tabularFeatures
        color: pill.contentColor
    }
    Behavior on width {
        enabled: Tokens.motion.spatialMotionEnabled
        SpringAnimation { spring: Tokens.motion.springFastSpatial.spring; damping: Tokens.motion.springFastSpatial.damping }
    }
    Timer { interval: 1000; running: pill.visible && pill.opt.showSeconds; repeat: true }
    SystemClock { id: clock; precision: SystemClock.Minutes }
}
