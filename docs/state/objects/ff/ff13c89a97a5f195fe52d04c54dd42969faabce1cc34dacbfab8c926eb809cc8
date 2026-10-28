// expect: G06 G07 G08 G15 G16
import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.namespace: "power"
    WlrLayershell.layer: WlrLayer.Overlay
    Window { }
    Process { command: ["systemctl", "poweroff"] }
    Item { property string className: "power-card" }
}
