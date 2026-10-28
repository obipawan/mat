import { test } from "node:test";
import assert from "node:assert/strict";
import { parseProcStat, cpuPercent, parseMeminfo } from "../../shell/lib/telemetry.mjs";

test("parseProcStat: idle includes iowait; total is every field of the cpu line", () => {
  assert.deepEqual(parseProcStat("cpu  100 0 50 800 50 0 0 0 0 0\ncpu0 1 1 1 1 1 0 0 0 0 0\n"), { idle: 850, total: 1000 });
});

test("cpuPercent: busy share of the interval; no interval → 0", () => {
  assert.equal(cpuPercent({ idle: 850, total: 1000 }, { idle: 900, total: 1100 }), 50);
  assert.equal(cpuPercent({ idle: 1, total: 1 }, { idle: 1, total: 1 }), 0);
});

test("parseMeminfo: used share from MemTotal and MemAvailable", () => {
  assert.equal(parseMeminfo("MemTotal: 16000000 kB\nMemFree: 1 kB\nMemAvailable: 4000000 kB\n").usedPercent, 75);
});

// Contract details beyond the card (02-contracts.md §2.12; no throws on command output, §1)

test("parsers: missing data → zeros, never a throw", () => {
  assert.deepEqual(parseProcStat(""), { idle: 0, total: 0 });
  assert.deepEqual(parseMeminfo("garbage"), { totalKb: 0, availableKb: 0, usedPercent: 0 });
  assert.deepEqual(parseMeminfo("MemTotal: 8 kB\nMemAvailable: 2 kB\n"), { totalKb: 8, availableKb: 2, usedPercent: 75 });
});
