// expect: G21=6
// One invented public member (`level`) and five contract members missing.
pragma Singleton
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root
    readonly property bool present: UPower.displayDevice.isLaptopBattery
    readonly property real percentage: UPower.displayDevice.percentage
    readonly property int level: Math.round(percentage * 100)
}
