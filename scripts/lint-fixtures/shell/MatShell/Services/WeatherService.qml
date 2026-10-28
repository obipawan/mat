// expect: none
// Declares exactly its contract members; everything else is private (`_` prefix).
pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property var weather: _weather
    readonly property bool stale: false
    readonly property bool loading: _fetch.running
    readonly property string error: ""
    property var _weather: null

    function refresh(): void { _fetch.running = true }
    function _parse(text: string): var { return JSON.parse(text) }

    Process { id: _fetch; command: ["curl", "-s", "wttr.in/?format=j1"] }
}
