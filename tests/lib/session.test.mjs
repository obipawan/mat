import { test } from "node:test";
import assert from "node:assert/strict";
import { ACTION_COMMANDS, logoutCommand, parseInhibitorsJson, blockingInhibitors } from "../../shell/lib/session.mjs";

test("blockingInhibitors: block-mode shutdown or sleep inhibitors only", () => {
  const inh = { type: "a(ssssuu)", data: [[["shutdown:sleep", "firefox", "Unsaved form", "block", 1000, 4242], ["idle", "mpv", "Playing", "block", 1000, 7]]] };
  assert.deepEqual(blockingInhibitors(parseInhibitorsJson(inh)).map(i => i.who), ["firefox"]);
});

test("parseInhibitorsJson: malformed → []", () => {
  assert.deepEqual(parseInhibitorsJson({}), []);
});

test("logoutCommand and ACTION_COMMANDS", () => {
  assert.deepEqual(logoutCommand("niri", "pawan"), ["niri", "msg", "action", "quit"]);
  assert.deepEqual(ACTION_COMMANDS.shutdown, ["systemctl", "poweroff"]);
});

// Contract details beyond the card (02-contracts.md §2.12)

test("logoutCommand: Hyprland and other compositors", () => {
  assert.deepEqual(logoutCommand("hyprland", "u"), ["hyprctl", "dispatch", "exit"]);
  assert.deepEqual(logoutCommand("other", "u"), ["loginctl", "terminate-user", "u"]);
});

test("parseInhibitorsJson: tuple fields become named fields; delay mode does not block", () => {
  const list = parseInhibitorsJson({ data: [[["sleep", "app", "why", "delay", 1, 2]]] });
  assert.deepEqual(list, [{ what: "sleep", who: "app", why: "why", mode: "delay", uid: 1, pid: 2 }]);
  assert.deepEqual(blockingInhibitors(list), []);
  assert.deepEqual(parseInhibitorsJson(null), []);
  assert.deepEqual(parseInhibitorsJson({ data: [[["short"]]] }), []);
});
