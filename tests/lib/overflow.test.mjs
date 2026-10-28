import { test } from "node:test";
import assert from "node:assert/strict";
import { planOverflow } from "../../shell/lib/overflow.mjs";

const items = [{ id: "title", priority: 1, widths: [260, 160, 40] }, { id: "tele", priority: 5, widths: [120, 0] }, { id: "clock", priority: null, widths: [100] }];

test("planOverflow: everything fits → all at step 0", () => {
  assert.deepEqual(planOverflow(items, 1000, 4), { steps: { title: 0, tele: 0, clock: 0 }, hidden: [] });
});

test("planOverflow: the highest priority number collapses first; hidden items add no gap", () => {
  assert.deepEqual(planOverflow(items, 450, 4), { steps: { title: 0, tele: 1, clock: 0 }, hidden: ["tele"] });
  assert.deepEqual(planOverflow(items, 300, 4), { steps: { title: 1, tele: 1, clock: 0 }, hidden: ["tele"] });
});

test("planOverflow: stops when nothing can advance; null priority never collapses", () => {
  assert.deepEqual(planOverflow(items, 50, 4), { steps: { title: 2, tele: 1, clock: 0 }, hidden: ["tele"] });
});

test("planOverflow: ties collapse the later item first", () => {
  const tie = [{ id: "a", priority: 4, widths: [50, 0] }, { id: "b", priority: 4, widths: [50, 0] }];
  assert.deepEqual(planOverflow(tie, 60, 4).hidden, ["b"]);
});

// Contract details beyond the card (02-contracts.md §2.7)

test("planOverflow: no items → nothing to do", () => {
  assert.deepEqual(planOverflow([], 0, 4), { steps: {}, hidden: [] });
});

test("planOverflow: hidden lists ids in item order", () => {
  const all = [{ id: "a", priority: 2, widths: [50, 0] }, { id: "b", priority: 3, widths: [50, 0] }];
  assert.deepEqual(planOverflow(all, 10, 4).hidden, ["a", "b"]);
});

// Checkpoint 10 review fixes

test("planOverflow: an id such as __proto__ is an ordinary id", () => {
  const r = planOverflow([{ id: "__proto__", priority: 5, widths: [50, 0] }, { id: "b", priority: null, widths: [50] }], 60, 4);
  assert.ok(Object.prototype.hasOwnProperty.call(r.steps, "__proto__"));
  assert.equal(r.steps.__proto__, 1);
  assert.deepEqual(r.hidden, ["__proto__"]);
});
