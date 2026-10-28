// Session commands and logind inhibitors (docs/lld/02-contracts.md §2.12; spec 11-power-and-session-menu.md).

export const ACTION_COMMANDS = {
  suspend: ["systemctl", "suspend"],
  hibernate: ["systemctl", "hibernate"],
  reboot: ["systemctl", "reboot"],
  shutdown: ["systemctl", "poweroff"],
};

export function logoutCommand(compositor, user) {
  if (compositor === "hyprland") return ["hyprctl", "dispatch", "exit"];
  if (compositor === "niri") return ["niri", "msg", "action", "quit"];
  return ["loginctl", "terminate-user", user];
}

// `busctl --json=short call org.freedesktop.login1 … ListInhibitors`: data[0] is a list of (what, who, why, mode, uid, pid).
export function parseInhibitorsJson(json) {
  const rows = json && Array.isArray(json.data) && Array.isArray(json.data[0]) ? json.data[0] : [];
  return rows
    .filter((r) => Array.isArray(r) && r.length >= 6)
    .map(([what, who, why, mode, uid, pid]) => ({ what, who, why, mode, uid, pid }));
}

export function blockingInhibitors(list) {
  return list.filter((i) => i.mode === "block" && String(i.what).split(":").some((w) => w === "shutdown" || w === "sleep"));
}
