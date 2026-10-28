// expect: G01 G02 G03 G04 G05 G09 G10 G11 G12 G13 G14 G18 G19
import QtQuick
import MatShell.Primitives

M3BarPill {
    id: pill
    property var options: ({})
    color: "#6750A4"
    radius: 12
    width: 120
    Text {
        text: Qt.formatDateTime(new Date(), pill.options.format)
        font.pixelSize: 14
    }
    Behavior on x { SpringAnimation { spring: 4.5; damping: 0.72 } }
    NumberAnimation on width { to: 200; duration: 200 }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: console.log("tick") }
    MouseArea { anchors.fill: parent }
}
