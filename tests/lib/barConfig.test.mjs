import { test } from "node:test";
import assert from "node:assert/strict";
import {
  BAR_DEFAULTS, FIRST_RUN_PIN_GROUPS, isVertical, thicknessRange, edgeGap, endGap, normalizeBar, defaultConfig,
  normalizeConfig, presetBars, barAppliesToScreen, placementProblems, firstRunPinned,
} from "../../shell/lib/barConfig.mjs";

test("normalizeBar: {} → defaults with id bar1 and name Bar 1", () => {
  const { bar } = normalizeBar({}, 0);
  assert.deepEqual(bar, { ...BAR_DEFAULTS, id: "bar1", name: "Bar 1" });
});

test("normalizeBar: legacy margin fills both margins and is removed", () => {
  const m = normalizeBar({ margin: 12 }, 0).bar;
  assert.equal(m.marginHorizontal, 12); assert.equal(m.marginVertical, 12); assert.ok(!("margin" in m));
});

test("normalizeBar: thickness is clamped to the orientation's range", () => {
  assert.equal(normalizeBar({ position: "left", thickness: 30 }, 0).bar.thickness, 44);
  assert.equal(normalizeBar({ thickness: 500 }, 0).bar.thickness, 96);
});

test("normalizeBar: an invalid enum → default and one warning", () => {
  const v = normalizeBar({ visibility: "sometimes" }, 0);
  assert.equal(v.bar.visibility, "always"); assert.equal(v.warnings.length, 1);
});

test("normalizeBar: percent length is clamped to 10..100; other strings → full", () => {
  assert.equal(normalizeBar({ length: 150 }, 0).bar.length, 100);
  assert.equal(normalizeBar({ length: 5 }, 0).bar.length, 10);
  assert.equal(normalizeBar({ length: "half" }, 0).bar.length, "full");
});

test("normalizeBar: string section entries become widgets with empty options", () => {
  assert.deepEqual(normalizeBar({ sections: { start: ["clock"] } }, 0).bar.sections.start, [{ type: "clock", options: {} }]);
});

test("normalizeBar: unknown widget types are kept with one warning", () => {
  const u = normalizeBar({ sections: { end: [{ type: "weatherRadar" }] } }, 0);
  assert.equal(u.bar.sections.end[0].type, "weatherRadar"); assert.equal(u.warnings.length, 1);
});

test("normalizeBar: widget options are migrated", () => {
  assert.deepEqual(normalizeBar({ sections: { end: [{ type: "clock", options: { showDate: false } }] } }, 0).bar.sections.end[0].options, { preset: "time" });
});

test("normalizeConfig: junk → defaultConfig()", () => {
  for (const junk of ["garbage", null, 42, []]) assert.deepEqual(normalizeConfig(junk).config, defaultConfig());
});

test("normalizeConfig: unknown top-level keys are preserved", () => {
  assert.deepEqual(normalizeConfig({ bars: [{}], extra: { a: 1 } }).config.extra, { a: 1 });
});

test("defaultConfig: bars come from the default preset (top, dock)", () => {
  assert.deepEqual(defaultConfig().bars.map(b => b.id), ["top", "dock"]);
});

test("edgeGap / endGap: swap with orientation", () => {
  const h = { ...BAR_DEFAULTS, marginVertical: 4, marginHorizontal: 10 };
  assert.equal(edgeGap(h), 4); assert.equal(endGap(h), 10);
  assert.equal(edgeGap({ ...h, position: "left" }), 10);
});

test("thicknessRange: vertical edges → [44, 120]", () => {
  assert.deepEqual(thicknessRange("right"), [44, 120]);
});

test("placementProblems: more than two bars on one edge of this screen", () => {
  const top = i => ({ ...BAR_DEFAULTS, id: "t" + i, position: "top" });
  assert.deepEqual(placementProblems([top(1), top(2), top(3)], "DP-1", { width: 1920, height: 1080 }), ["Only 2 bars fit on the top edge"]);
  assert.deepEqual(placementProblems([top(1), top(2), { ...top(3), screens: ["HDMI-A-1"] }], "DP-1", { width: 1920, height: 1080 }), []);
});

test("placementProblems: reserved space over 25% of an axis", () => {
  const fat = (id, position) => ({ ...BAR_DEFAULTS, id, position, thickness: 96 });
  assert.deepEqual(placementProblems([fat("a", "top"), fat("b", "top"), fat("c", "bottom")], "DP-1", { width: 1920, height: 1080 }),
    ["Bars may reserve at most 25% of the screen height"]);
});

test("barAppliesToScreen: a bar listing other screens does not apply", () => {
  assert.equal(barAppliesToScreen({ ...BAR_DEFAULTS, screens: ["HDMI-A-1"] }, "DP-1"), false);
});

test("firstRunPinned: the first existing id of each group", () => {
  assert.deepEqual(firstRunPinned([["a", "b"], ["c"]], id => id === "b"), ["b"]);
});

// Contract details beyond the card (02-contracts.md §2.5)

test("normalizeBar: wrong-typed values → defaults with a warning each; missing values never warn", () => {
  const r = normalizeBar({ enabled: "yes", screens: 3, sections: { start: "clock" } }, 1);
  assert.equal(r.bar.enabled, true);
  assert.equal(r.bar.screens, "all");
  assert.deepEqual(r.bar.sections.start, []);
  assert.equal(r.warnings.length, 3);
  assert.deepEqual(normalizeBar({}, 0).warnings, []);
});

test("normalizeBar: unknown keys, unknown sections and entries without a type are dropped with warnings", () => {
  const r = normalizeBar({ colour: "red", sections: { middle: [], end: [{ options: {} }, 7] } }, 0);
  assert.ok(!("colour" in r.bar));
  assert.ok(!("middle" in r.bar.sections));
  assert.deepEqual(r.bar.sections.end, []);
  assert.equal(r.warnings.length, 4);
});

test("normalizeBar: a non-object → defaults and a warning", () => {
  const r = normalizeBar("oops", 2);
  assert.equal(r.bar.id, "bar3");
  assert.equal(r.warnings.length, 1);
});

test("normalizeConfig: partial sections keep their missing defaults; a non-object section → default", () => {
  const r = normalizeConfig({ appearance: { darkMode: false }, notifications: "loud" });
  assert.equal(r.config.appearance.darkMode, false);
  assert.equal(r.config.appearance.surfaceMode, "frosted_tonal_glass");
  assert.deepEqual(r.config.notifications, defaultConfig().notifications);
  assert.equal(r.warnings.length, 1);
});

test("normalizeConfig: bars that are not an array → default preset with a warning", () => {
  const r = normalizeConfig({ bars: "top" });
  assert.deepEqual(r.config.bars.map(b => b.id), ["top", "dock"]);
  assert.equal(r.warnings.length, 1);
});

test("defaultConfig: a fresh object each call, with schemaVersion 1 and no keybind overrides", () => {
  const a = defaultConfig();
  a.bars.length = 0;
  assert.equal(defaultConfig().bars.length, 2);
  assert.equal(defaultConfig().schemaVersion, 1);
  assert.deepEqual(defaultConfig().keybinds, {});
});

test("presetBars: an unknown preset → []; isVertical follows the position", () => {
  assert.deepEqual(presetBars("nope"), []);
  assert.equal(isVertical({ position: "right" }), true);
  assert.equal(isVertical({ position: "bottom" }), false);
});

test("FIRST_RUN_PIN_GROUPS: browser, file manager, terminal", () => {
  assert.equal(FIRST_RUN_PIN_GROUPS.length, 3);
  assert.equal(FIRST_RUN_PIN_GROUPS[0][0], "firefox.desktop");
});

// Checkpoint 10 review fixes

test("normalizeBar: a legacy margin that is not a number warns and is ignored", () => {
  const r = normalizeBar({ margin: "12" }, 0);
  assert.equal(r.bar.marginHorizontal, 8);
  assert.equal(r.warnings.length, 1);
});

test("inherited object names are ordinary unknown keys", () => {
  assert.deepEqual(presetBars("constructor"), []);
  assert.deepEqual(presetBars("__proto__"), []);
  const r = normalizeConfig(JSON.parse('{"constructor":{"a":1},"toString":"x"}'));
  assert.deepEqual(r.config.constructor, { a: 1 });
  assert.equal(r.config.toString, "x");
});

test("normalizeConfig: an unknown __proto__ key is kept as an ordinary key, in sections too", () => {
  const r = normalizeConfig(JSON.parse('{"__proto__":{"x":2},"appearance":{"__proto__":{"y":3}}}'));
  assert.ok(Object.prototype.hasOwnProperty.call(r.config, "__proto__"));
  assert.equal(Object.getPrototypeOf(r.config), Object.prototype);
  assert.equal(r.config.x, undefined);
  assert.equal(Object.getPrototypeOf(r.config.appearance), Object.prototype);
  assert.ok(JSON.stringify(r.config).includes('"__proto__":{"x":2}'));
  assert.equal(Object.getPrototypeOf(normalizeConfig(JSON.parse('{"__proto__":null}')).config), Object.prototype);
});
