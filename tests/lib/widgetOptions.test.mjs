import { test } from "node:test";
import assert from "node:assert/strict";
import {
  hasOptions, optionsSchema, fieldApplies, resolve, diffFromDefaults, migrate,
  isFieldVisible, toggleListItem, moveListItem, limitNote,
} from "../../shell/lib/widgetOptions.mjs";
import { WIDGET_OPTIONS, WIDGET_OPTION_MIGRATIONS } from "../../shell/lib/generated/widgetOptionsSchema.mjs";

const items = optionsSchema("controlCenter")[0], metrics = optionsSchema("telemetry")[0];

test("resolve: clock with no options on a horizontal bar → schema defaults", () => {
  assert.deepEqual(resolve("clock", {}, "horizontal"),
    { preset: "dateTime", hourCycle: "system", showSeconds: false, customFormat: "ddd d MMM  HH:mm" });
});

test("resolve: horizontal-only preset on a vertical bar → default", () => {
  assert.equal(resolve("clock", { preset: "custom" }, "vertical").preset, "dateTime");
});

test("resolve: number above max → max; non-number → default", () => {
  assert.equal(resolve("workspaces", { count: 99 }, "horizontal").count, 10);
  assert.equal(resolve("workspaces", { count: "x" }, "horizontal").count, 5);
});

test("resolve: multiChoice drops duplicates and unknown values, then cuts to max", () => {
  assert.deepEqual(resolve("telemetry", { metrics: ["cpu", "cpu", "bogus", "gpu", "disk", "ram", "swap"] }, "horizontal").metrics,
    ["cpu", "gpu", "disk", "ram"]);
});

test("resolve: multiChoice below min → default", () => {
  assert.deepEqual(resolve("telemetry", { metrics: [] }, "horizontal").metrics, ["cpu", "ram"]);
});

test("resolve: unknown keys are not in the result", () => {
  assert.ok(!("future" in resolve("clock", { future: 1 }, "horizontal")));
});

test("resolve: toggle that is not a boolean → default", () => {
  assert.equal(resolve("notifications", { showCount: "yes" }, "horizontal").showCount, true);
});

test("resolve: text that is not a string → default; longer than maxLength → cut", () => {
  assert.equal(resolve("search", { placeholder: 42 }, "horizontal").placeholder, "Search…");
  assert.equal(resolve("search", { placeholder: "x".repeat(30) }, "horizontal").placeholder, "x".repeat(24));
});

test("resolve: every field resolves to its default when nothing is stored", () => {
  for (const [type, fields] of Object.entries(WIDGET_OPTIONS)) {
    for (const f of fields) {
      if (fieldApplies(f, "horizontal")) assert.deepEqual(resolve(type, {}, "horizontal")[f.key], f.default, `${type}.${f.key}`);
    }
  }
});

test("diffFromDefaults: keeps changed values and unknown keys, drops defaults", () => {
  assert.deepEqual(diffFromDefaults("clock", { preset: "dateTime", showSeconds: true, future: 1 }), { showSeconds: true, future: 1 });
});

test("migrate: clock showDate false → preset time", () => {
  assert.deepEqual(migrate("clock", { showDate: false }).options, { preset: "time" });
});

test("migrate: clock format → custom preset with that pattern", () => {
  assert.deepEqual(migrate("clock", { format: "HH:mm" }).options, { preset: "custom", customFormat: "HH:mm" });
});

test("migrate: clock showDate true → removed", () => {
  assert.deepEqual(migrate("clock", { showDate: true }).options, {});
});

test("migrate: every rule in widgetOptionMigrations maps its `from` to its `to`", () => {
  const fill = (o) => JSON.parse(JSON.stringify(o).split("<pattern>").join("HH:mm"));
  for (const [type, rules] of Object.entries(WIDGET_OPTION_MIGRATIONS)) {
    for (const rule of rules) assert.deepEqual(migrate(type, fill(rule.from)).options, diffFromDefaults(type, fill(rule.to)), JSON.stringify(rule.from));
  }
});

test("migrate: options that are not an object → {} and one warning", () => {
  const r = migrate("clock", "junk");
  assert.deepEqual(r.options, {});
  assert.equal(r.warnings.length, 1);
});

test("isFieldVisible: diskMount shows only when metrics include disk", () => {
  const disk = optionsSchema("telemetry").find(f => f.key === "diskMount");
  assert.equal(isFieldVisible(disk, { metrics: ["cpu"] }), false);
  assert.equal(isFieldVisible(disk, { metrics: ["disk"] }), true);
});

test("toggleListItem: a change that breaks min or max → null", () => {
  assert.equal(toggleListItem(items, ["network"], "network"), null);
  assert.equal(toggleListItem(metrics, ["cpu", "ram", "gpu", "disk"], "swap"), null);
});

test("toggleListItem: adding a value appends it", () => {
  assert.deepEqual(toggleListItem(metrics, ["cpu"], "gpu"), ["cpu", "gpu"]);
});

test("moveListItem: moves an item; out-of-range target → unchanged copy", () => {
  assert.deepEqual(moveListItem(["a", "b", "c"], 2, 0), ["c", "a", "b"]);
  assert.deepEqual(moveListItem(["a"], 0, 5), ["a"]);
});

test("limitNote: at max and at min", () => {
  assert.equal(limitNote(metrics, ["cpu", "ram", "gpu", "disk"]), "Up to 4 items · drag to reorder");
  assert.equal(limitNote(items, ["network"]), "At least 1 item · drag to reorder");
});

test("hasOptions and optionsSchema: power has none; unknown type → []", () => {
  assert.equal(hasOptions("power"), false);
  assert.deepEqual(optionsSchema("nope"), []);
});

// Checkpoint 10 review fixes

test("optionsSchema: inherited object names are unknown types", () => {
  assert.deepEqual(optionsSchema("constructor"), []);
  assert.equal(hasOptions("toString"), false);
  assert.deepEqual(resolve("constructor", {}, "horizontal"), {});
});

test("diffFromDefaults and migrate: a __proto__ option key is kept as an ordinary key", () => {
  const d = diffFromDefaults("clock", JSON.parse('{"__proto__":{"a":1},"zz":1}'));
  assert.deepEqual(Object.keys(d).sort(), ["__proto__", "zz"]);
  assert.equal(Object.getPrototypeOf(d), Object.prototype);
  const m = migrate("clock", JSON.parse('{"__proto__":{"a":1}}')).options;
  assert.ok(Object.prototype.hasOwnProperty.call(m, "__proto__"));
});
