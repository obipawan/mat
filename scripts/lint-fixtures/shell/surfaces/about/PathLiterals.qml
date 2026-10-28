// expect: G23=6
// Repository folders, home paths, the spelled-out config folder, HOME outside ConfigService, and a relative
// path that leaves shell/ all fail. A URL with /docs/ and a relative import that stays inside shell/ pass.
import QtQuick
import Quickshell
import "../../lib/util.mjs" as Util
import "../../../tool.mjs" as Tool

Item {
    property string a: "design-system/tokens/qml"
    property string b: "~/Pictures/Screenshots"
    property string c: Quickshell.env("HOME") + "/x"
    property string d: "/home/u/.config/mat-shell/config.json"
    property string e: root.base + "/.config/mat-shell/x"
    property string ok: "https://quickshell.org/docs/v0.3.2/"
}
