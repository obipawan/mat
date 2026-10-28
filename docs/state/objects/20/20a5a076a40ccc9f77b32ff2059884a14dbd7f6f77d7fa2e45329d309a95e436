// expect: G22=5
// Declared programs pass (nmcli, mkdir, the sh -c pipeline of declared programs, a lib/ command table).
// Fails: an undeclared program, an undeclared program inside sh -c, sh -c with a non-literal script,
// a command whose program cannot be seen, and execDetached with an undeclared program.
pragma Singleton
import Quickshell
import Quickshell.Io
import "../../lib/session.mjs" as Session

Singleton {
    id: root
    property var _args: []

    function setSwitch(name: string, value: string): void {
        _a.command = ["mkdir", "-p", "/tmp/x"]
        _b.command = Session.ACTION_COMMANDS.suspend
        _c.command = root._args
        Quickshell.execDetached(["notify-send", "x"])
    }

    Process { id: _a; command: ["nmcli", "-t", "dev"] }
    Process { id: _b; command: ["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", root._args[0]] }
    Process { id: _c; command: ["iwctl", "station", "list"] }
    Process { id: _d; command: ["sh", "-c", "nmcli dev | grep wifi"] }
    Process {
        id: _e
        command: [
            "sh", "-c", root._args[1]
        ]
    }
}
