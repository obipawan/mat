// expect: G21=6
// Valid: AudioService.volume, Tokens.color.primary, Geometry.insets. Ignored: names inside strings.
// Invalid (6): an invented service member, a private member, two missing tokens, a missing lib export, an unknown lib module.
import QtQuick
import MatShell.Tokens
import MatShell.Services
import MatShell.State
import "../../lib/barGeometry.mjs" as Geometry
import "../../lib/nope.mjs" as Nope

Item {
    readonly property real level: AudioService.volume
    readonly property color tint: Tokens.color.primary
    readonly property var pad: Geometry.insets([], [])
    readonly property string note: "AudioService.bogus and Tokens.color.bogus are only text"
    function bump() { AudioService.setVolumeLevel(0.5) }
    readonly property var items: ShellState._triggerItems
    readonly property color dim: Tokens.color.primaryFixedDimmer
    readonly property real gap: Tokens.spacing
    readonly property var pad2: Geometry.insetz([], [])
    readonly property var x2: Nope.anything
}
