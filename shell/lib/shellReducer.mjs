// The shell's lane state machine (docs/lld/02-contracts.md §2.8; spec interactions/01 §2–§3, interactions/02 §2–§3).
// Every function returns a new state, or the same object when nothing may change.

export const POPOVERS = ["control_center", "notifications", "calendar", "media"];
export const MODALS = ["launcher", "overview", "power", "polkit", "capture", "theme_studio", "widget_peek"];
export const LAUNCHER_MODES = ["apps", "win", "calc", "clip", "cmd", "emoji"];

export const INITIAL = { activePopover: "", activeModal: "", launcherMode: "apps", sessionLocked: false, barFocusActive: false };

function with_(s, patch) {
  return Object.assign({}, s, patch);
}

function cleared(s) {
  return with_(s, { activePopover: "", activeModal: "", barFocusActive: false });
}

export function securityModalActive(s) {
  return s.activeModal === "polkit";
}

export function togglePopover(s, name, closesSame) {
  if (s.sessionLocked || securityModalActive(s) || !POPOVERS.includes(name)) return s;
  const open = name === s.activePopover && closesSame ? "" : name;
  return with_(s, { activePopover: open, activeModal: "", barFocusActive: false });
}

export function closePopover(s) {
  return with_(s, { activePopover: "" });
}

export function toggleModal(s, name) {
  if (s.sessionLocked || !MODALS.includes(name) || securityModalActive(s) || name === "polkit") return s;
  return with_(s, { activePopover: "", barFocusActive: false, activeModal: s.activeModal === name ? "" : name });
}

export function openModal(s, name) {
  if (s.sessionLocked || !MODALS.includes(name)) return s;
  if (securityModalActive(s) && name !== "polkit") return s;
  return with_(s, { activeModal: name, activePopover: "", barFocusActive: false });
}

export function closeModal(s, byPolkit) {
  if (securityModalActive(s) && byPolkit !== true) return s;
  return with_(s, { activeModal: "" });
}

export function openLauncherMode(s, mode) {
  const next = openModal(s, "launcher");
  if (next === s) return s;
  return with_(next, { launcherMode: LAUNCHER_MODES.includes(mode) ? mode : "apps" });
}

export function lock(s) {
  return with_(cleared(s), { sessionLocked: true });
}

export function unlock(s) {
  return with_(s, { sessionLocked: false });
}

export function openSettings(s) {
  if (s.sessionLocked || securityModalActive(s)) return { state: s, emit: false };
  return { state: cleared(s), emit: true };
}

export function focusBar(s) {
  if (s.sessionLocked || securityModalActive(s)) return s;
  return with_(cleared(s), { barFocusActive: true });
}

export function escape(s, inlineDepth) {
  if (inlineDepth > 0) return { state: s, consumed: "inline" };
  if (securityModalActive(s)) return { state: s, consumed: "polkit" };
  if (s.activePopover || s.activeModal || s.barFocusActive) return { state: cleared(s), consumed: "surface" };
  return { state: s, consumed: "none" };
}
