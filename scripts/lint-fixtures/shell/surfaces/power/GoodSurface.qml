// expect: none
import QtQuick
import Quickshell
import Quickshell.Wayland
import MatShell.Tokens
import MatShell.State
import MatShell.Services

PanelWindow {
    id: win
    visible: ShellState.activeModal === "power"
    WlrLayershell.namespace: "mat-power"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    Item {
        implicitWidth: 136 // lint-allow G03: SC-11 §4 action tile is 136x120 and has no metric token
        implicitHeight: Tokens.metrics.spaceXxl
    }
    function execute(id) { SessionService.run(id) }
}
