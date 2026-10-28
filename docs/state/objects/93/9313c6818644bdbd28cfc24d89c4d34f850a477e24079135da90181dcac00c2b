import { test } from "node:test";
import assert from "node:assert/strict";
import { CATALOG, catalogEntry, sourceFile } from "../../shell/lib/widgetCatalog.mjs";
import { WIDGET_TYPES } from "../../shell/lib/generated/barPresets.mjs";
import { WIDGET_OPTIONS } from "../../shell/lib/generated/widgetOptionsSchema.mjs";

test("CATALOG: one entry per widget type, in WIDGET_TYPES order", () => {
  assert.deepEqual(CATALOG.map((e) => e.type), WIDGET_TYPES);
});

test("catalogEntry: telemetry has overflow priority 5; privacy is a security widget", () => {
  assert.equal(catalogEntry("telemetry").overflowPriority, 5);
  assert.equal(catalogEntry("privacy").security, true);
});

test("catalogEntry: unknown type → null", () => {
  assert.equal(catalogEntry("nope"), null);
});

test("sourceFile: keyboardLayout → widgets/KeyboardLayoutWidget.qml", () => {
  assert.equal(sourceFile("keyboardLayout"), "widgets/KeyboardLayoutWidget.qml");
});

test("CATALOG: customisable exactly when the type has an options schema", () => {
  assert.deepEqual(CATALOG.filter((e) => e.customisable).map((e) => e.type).sort(), Object.keys(WIDGET_OPTIONS).sort());
});

test("catalogEntry: clock label is 'Clock & calendar'", () => {
  assert.equal(catalogEntry("clock").label, "Clock & calendar");
});
