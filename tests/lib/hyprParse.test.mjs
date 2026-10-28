import { test } from "node:test";
import assert from "node:assert/strict";
import { parseClients, windowsOverlap } from "../../shell/lib/hyprParse.mjs";

const cl = parseClients([{ address: "0x1", title: "t", class: "firefox", workspace: { id: 2 }, monitor: 0, floating: false, fullscreen: 0, at: [0, 0], size: [800, 600] },
                         { address: "0x2", title: "f", class: "pavu", workspace: { id: 2 }, monitor: 0, floating: true, fullscreen: 0, at: [0, 0], size: [400, 300] }]);

test("parseClients: hyprctl fields become Client fields", () => {
  assert.equal(cl[0].appId, "firefox"); assert.equal(cl[0].workspaceId, 2); assert.equal(cl[0].fullscreen, false);
});

test("windowsOverlap: only tiled windows on that workspace count", () => {
  assert.equal(windowsOverlap(cl, { x: 0, y: 0, width: 1920, height: 48 }, 2), true);
  assert.equal(windowsOverlap(cl, { x: 0, y: 0, width: 1920, height: 48 }, 3), false);
  assert.equal(windowsOverlap(cl.slice(1), { x: 0, y: 0, width: 1920, height: 48 }, 2), false);
});

// Contract details beyond the card (02-contracts.md §2.12)

test("parseClients: geometry, fullscreen as a boolean, junk skipped", () => {
  const [c] = parseClients([{ address: "0x3", title: "v", class: "mpv", workspace: { id: 1 }, monitor: 1, floating: false, fullscreen: 2, at: [10, 20], size: [30, 40] }, 7, null]);
  assert.deepEqual(c, { address: "0x3", title: "v", appId: "mpv", workspaceId: 1, monitor: 1, floating: false, fullscreen: true, x: 10, y: 20, width: 30, height: 40 });
  assert.deepEqual(parseClients("nope"), []);
});

test("windowsOverlap: windows that only touch the bar's edge do not overlap", () => {
  const below = parseClients([{ address: "0x4", title: "", class: "a", workspace: { id: 1 }, monitor: 0, floating: false, fullscreen: 0, at: [0, 48], size: [800, 600] }]);
  assert.equal(windowsOverlap(below, { x: 0, y: 0, width: 1920, height: 48 }, 1), false);
});
