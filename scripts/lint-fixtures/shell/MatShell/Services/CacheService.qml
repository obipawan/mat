// expect: G21=1
// A service file that 02-contracts.md §3 does not define.
pragma Singleton
import Quickshell

Singleton {
    id: root
    property var entries: ({})
}
