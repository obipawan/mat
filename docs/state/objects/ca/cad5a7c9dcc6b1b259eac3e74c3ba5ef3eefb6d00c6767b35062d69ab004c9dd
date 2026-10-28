import { test } from "node:test";
import assert from "node:assert/strict";
import { wheelStep } from "../../shell/lib/wheel.mjs";

const o = { stepAngle: 120, stepPixels: 40, physical: false };

test("wheelStep: one notch is one step", () => {
  assert.deepEqual(wheelStep(0, { angleDeltaY: 120, pixelDeltaY: 0, inverted: false }, o), { acc: 0, steps: 1 });
});

test("wheelStep: partial notches accumulate", () => {
  let w = { acc: 0 }; const got = [];
  for (let i = 0; i < 3; i++) { w = wheelStep(w.acc, { angleDeltaY: 40, pixelDeltaY: 0, inverted: false }, o); got.push(w.steps); }
  assert.deepEqual(got, [0, 0, 1]);
});

test("wheelStep: touchpad pixels use the pixel step", () => {
  assert.equal(wheelStep(0, { angleDeltaY: 0, pixelDeltaY: 39, inverted: false }, o).steps, 0);
  assert.equal(wheelStep(39, { angleDeltaY: 0, pixelDeltaY: 1, inverted: false }, o).steps, 1);
});

test("wheelStep: physical controls undo natural scrolling; others do not", () => {
  assert.equal(wheelStep(0, { angleDeltaY: 120, pixelDeltaY: 0, inverted: true }, { ...o, physical: true }).steps, -1);
  assert.equal(wheelStep(0, { angleDeltaY: 120, pixelDeltaY: 0, inverted: true }, o).steps, 1);
});

test("wheelStep: two notches down → -2", () => {
  assert.equal(wheelStep(0, { angleDeltaY: -240, pixelDeltaY: 0, inverted: false }, o).steps, -2);
});

// Contract details beyond the card (02-contracts.md §2.10)

test("wheelStep: the remainder is kept, with its sign", () => {
  assert.deepEqual(wheelStep(0, { angleDeltaY: -150, pixelDeltaY: 0, inverted: false }, o), { acc: -30, steps: -1 });
  assert.deepEqual(wheelStep(0, { angleDeltaY: -40, pixelDeltaY: 0, inverted: false }, o), { acc: -40, steps: 0 });
});
