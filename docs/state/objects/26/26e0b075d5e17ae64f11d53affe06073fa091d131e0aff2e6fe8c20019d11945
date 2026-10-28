# LLD 04 — Testing and Verification

## 1. Test Tiers

| Tier | What | Where it runs | Command | Gate |
|---|---|---|---|---|
| 1 | Unit tests for every `shell/lib/*.mjs` export | Any machine with Node ≥ 22 (macOS, CI, the target) | `node --test "tests/lib/*.test.mjs"` | Every commit |
| 2 | Static checks: contract manifest, cross-references, locked tests, lint, generated-data freshness, task scope | Any machine with Python ≥ 3.11 | `./scripts/verify-design-system.sh` (runs all but scope, plus Tier 1); `python3 scripts/check-scope.py --task N` | Every commit |
| 3 | Runtime smoke: the shell starts, IPC calls open and close every surface, and the log has no QML errors | Linux + Wayland (Hyprland) target | `./scripts/smoke-shell.sh` | Every QML task |
| 4 | Manual checks listed in the task (visual, keyboard, accessibility modes) | Target, by the implementer | the task's checklist | Every QML task; results go in the hand-off |

Tier 1 carries the logic; Tiers 3–4 check the wiring. If you find logic in a QML file that a Tier 1 test could cover, move it into `lib/` (D1).

---

## 2. Tier 1 Conventions (`tests/lib/<module>.test.mjs`)

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { resolve, diffFromDefaults } from "../../shell/lib/widgetOptions.mjs";

test("resolve: clock defaults on a horizontal bar", () => {
  assert.deepEqual(resolve("clock", {}, "horizontal"),
    { preset: "dateTime", hourCycle: "system", showSeconds: false, customFormat: "ddd d MMM  HH:mm" });
});
```

- One test file per module, named after it; one `test()` per behaviour; the name says the input and the expected result.
- Copy every assertion in the task's plan code block **verbatim** (whitespace may differ; `scripts/check-plan-tests.py` checks this). Wrap them in `test()` blocks and add more tests freely.
- Use only `node:test` and `node:assert/strict`. No npm packages, no mocks of time: pass `now` in.
- Values come from the specs or `m3-tokens.json`. Import generated data instead of re-typing schema values.
- A bug fix starts with a test that reproduces the bug.
- Tests are **append-only** once their task is sealed (`scripts/test-lock.py`): add new `test()` blocks at the end of a file; never edit or delete a locked one. `tests/lib/contracts.test.mjs` checks that each `shell/lib` module exports exactly its contract; it skips modules that do not exist yet.

---

## 3. Tier 3 Runtime Smoke

`scripts/smoke-shell.sh`:
1. Stops any running `mat-shell` instance.
2. Starts `scripts/run-shell.sh` and waits for `qs -c mat-shell ipc show`.
3. Replays `tests/smoke/ipc-script.txt` (`<target> <function> [args]` per line, 0.4s apart).
4. Fails when the log matches `ReferenceError|TypeError|SyntaxError|is not a type|is not installed|Binding loop detected|Unable to assign|Cannot assign|Non-existent attached object|Cannot read property|mat-shell: ERROR`.

Every task that adds a surface or an IPC function appends lines that open it and close it again (the file is append-only, like the unit tests):

```text
shell toggleControlCenter
shell toggleControlCenter
shell setA11y reducedMotion true
shell toggleControlCenter
shell toggleControlCenter
shell setA11y reducedMotion false
```

Services log real failures with `console.error("mat-shell: ERROR …")`, which the smoke test catches. Expected conditions (no battery, no backlight, offline weather) use `console.warn` and expose `available: false`.

### 3.1 Dev gallery (visual check of primitives)

`tests/gallery/shell.qml` is a separate Quickshell config: one `FloatingWindow` that shows every primitive in every state. Primitive tasks add their components to it. Run it with:

```bash
QML_IMPORT_PATH="$PWD/shell" qs -p tests/gallery
```

---

## 4. Tier 4 Manual Matrix

Each QML task lists the rows that apply. Record `pass`/`fail` per cell in the hand-off.

| Axis | Values |
|---|---|
| Bar edge | top, right, bottom, left (Settings → Bars → Position, or edit `config.json`) |
| Bar style / thickness | bar and island; minimum and maximum thickness of the orientation |
| Desktop mode | `qs -c mat-shell ipc call mode set tiling` / `floating` |
| Theme | dark and light; `frosted_tonal_glass` and `opaque_tonal` |
| Accessibility | `qs -c mat-shell ipc call shell setA11y <reducedMotion\|reducedTransparency\|highContrast> true`, `setA11y textScale 1.3` |
| Input | pointer only; keyboard only (Tab, arrows, Enter/Space, Escape, Menu); screen reader names (`Accessible.name` shown by Accerciser/Orca) |
| Screens | one monitor; two monitors (popover opens on the clicked screen) |

---

## 5. What Each Task Hands In

- Test output (`node --test "tests/lib/*.test.mjs"` summary line).
- `./scripts/verify-design-system.sh` final line.
- For QML tasks: `./scripts/smoke-shell.sh` final line and the filled manual rows.
- Lint suppressions (path:line rule reason).
