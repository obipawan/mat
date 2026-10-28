import { test } from "node:test";
import assert from "node:assert/strict";
import { WIDGET_OPTIONS, WIDGET_OPTION_MIGRATIONS } from "../../shell/lib/generated/widgetOptionsSchema.mjs";
import { BAR_PRESETS, BAR_GUARDRAILS, WIDGET_TYPES } from "../../shell/lib/generated/barPresets.mjs";

test("generated schema mirrors m3-tokens.json", () => {
  assert.equal(Object.keys(WIDGET_OPTIONS).length, 13);
  assert.ok(!("$spec" in WIDGET_OPTIONS));
  assert.equal(WIDGET_OPTION_MIGRATIONS.clock.length, 3);
  assert.equal(WIDGET_TYPES.length, 20);
  assert.equal(BAR_PRESETS.top_and_dock.default, true);
  assert.equal(BAR_GUARDRAILS.maxBarsPerEdge, 2);
  assert.deepEqual(BAR_GUARDRAILS.thicknessPx.vertical, [44, 120]);
});
