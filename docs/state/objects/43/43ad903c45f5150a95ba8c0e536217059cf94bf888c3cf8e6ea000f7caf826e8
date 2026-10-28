// Closed export lists: every shell/lib module exports exactly the names in docs/lld/02-contracts.md §2
// (via docs/lld/contracts.json). Modules that do not exist yet are skipped, not failed.
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";

const root = new URL("../../", import.meta.url);
const contracts = JSON.parse(readFileSync(new URL("docs/lld/contracts.json", root), "utf8"));
const libDir = new URL("shell/lib/", root);

for (const [mod, names] of Object.entries(contracts.lib)) {
  const url = new URL(mod, libDir);
  test(`${mod} exports exactly its contract`, { skip: !existsSync(url) && "not built yet" }, async () => {
    const actual = Object.keys(await import(url)).sort();
    assert.deepEqual(actual, [...names].sort(),
      `${mod}: exports must match 02-contracts.md §2; to change them, edit the contract (README §4)`);
  });
}

test("every shell/lib module has a contract", { skip: !existsSync(libDir) && "shell/lib not created yet" }, () => {
  const files = readdirSync(libDir, { recursive: true }).filter((f) => f.endsWith(".mjs")).map((f) => f.split("\\").join("/"));
  const unknown = files.filter((f) => !(f in contracts.lib));
  assert.deepEqual(unknown, [], "modules not in 02-contracts.md §2 (add a contract first, README §4)");
});
