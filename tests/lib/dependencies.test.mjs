// packaging/dependencies.json against the code: lib/ command tables (which G22 lets services run without a
// literal) use declared programs, and every token font family ships or comes from a declared package.
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { ACTION_COMMANDS, logoutCommand } from "../../shell/lib/session.mjs";

const root = new URL("../../", import.meta.url);
const deps = JSON.parse(readFileSync(new URL("packaging/dependencies.json", root), "utf8"));

test("session.mjs commands start with declared programs", () => {
  const cmds = [...Object.values(ACTION_COMMANDS), ...["hyprland", "niri", "other"].map((c) => logoutCommand(c, "u"))];
  const undeclared = cmds.map((c) => c[0]).filter((p) => !Object.prototype.hasOwnProperty.call(deps.commands, p));
  assert.deepEqual(undeclared, []);
});

test("every TypographyTokens family is shipped or packaged", () => {
  const qml = readFileSync(new URL("design-system/tokens/qml/TypographyTokens.qml", root), "utf8");
  const families = [...qml.matchAll(/property string family\w+: "([^"]+)"/g)].map((m) => m[1]);
  assert.equal(families.length, 5);
  const shipped = new Set(deps.fonts.map((f) => f.family));
  if (deps.packages.some((p) => p.arch === "ttf-jetbrains-mono")) shipped.add("JetBrains Mono");
  assert.deepEqual(families.filter((f) => !shipped.has(f)), []);
});

test("font entries pin a commit and a checksum", () => {
  for (const f of deps.fonts) {
    assert.match(f.sha256, /^[0-9a-f]{64}$/);
    assert.match(f.url, /^https:\/\/raw\.githubusercontent\.com\/[\w.-]+\/[\w.-]+\/[0-9a-f]{40}\//);
  }
});
