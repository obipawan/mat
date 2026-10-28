import { test } from "node:test";
import assert from "node:assert/strict";
import { clamp, deepEqual, clone, pascalCase } from "../../shell/lib/util.mjs";

test("clamp: 5 in 0..3 → 3", () => {
  assert.equal(clamp(5, 0, 3), 3);
});

test("clamp: NaN → lo", () => {
  assert.equal(clamp(NaN, 1, 2), 1);
});

test("deepEqual: equal nested objects → true; reordered arrays → false", () => {
  assert.equal(deepEqual({ a: [1, 2] }, { a: [1, 2] }), true);
  assert.equal(deepEqual([1, 2], [2, 1]), false);
});

test("pascalCase: controlCenter → ControlCenter", () => {
  assert.equal(pascalCase("controlCenter"), "ControlCenter");
});

test("clone: changing the copy leaves the original unchanged", () => {
  const o = { a: { b: 1 } };
  const c = clone(o);
  c.a.b = 2;
  assert.equal(o.a.b, 1);
});

// Checkpoint 10 review fixes

test("deepEqual: a __proto__ key is an ordinary key", () => {
  assert.equal(deepEqual(JSON.parse('{"__proto__":{}}'), { x: 1 }), false);
  assert.equal(deepEqual(JSON.parse('{"__proto__":{}}'), JSON.parse('{"__proto__":{}}')), true);
});
