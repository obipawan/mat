# Checkpoint 10 — Phase A (Tooling and Pure Logic)

Approved by: design owner (Claude session on the design machine), after an independent reviewer session — Tasks 4–10 reviewed with `docs/lld/05-agent-prompts.md` Prompt B.

## Review rounds

1. **Round 1:** every command passed, every task rejected.
   - Gate template: receipts lacked "Locked files changed".
   - Task 4: inherited names (`constructor`, `__proto__`); no warning for a wrong-typed legacy `margin`.
   - Task 5: `regions` stack slots counted hidden bars, so a shown bar lost its click-catcher.
   - Task 8: rounding the contract did not state.
   - Task 9: non-list binds threw or produced per-letter binds; chord text could inject lines into `binds.conf`.
   - Task 10: a null weather slot threw.
   - Risks raised for QML's engine: `localeCompare` follows `LC_COLLATE`; sequence wrappers; sort stability.
   - Fixed in owner seal 10. §1 gained the "Own keys only" and "Deterministic everywhere" conventions. Rounding and empty snippets were settled in the contract (§2.9, §2.11).
2. **Round 2:** Tasks 6–9 approved; Tasks 4, 5 and 10 rejected on the new conventions.
   - `__proto__` was written through the prototype setter.
   - Bar ids were not checked as own keys.
   - The name tie-break could return 0 and compared UTF-16 units.
   - Fixed in owner seal 11.
3. **Round 3:** Tasks 4–10 approved.
   - The reviewer also flagged the same `__proto__` class in Task 2 `deepEqual` and Task 6 overflow ids (overflow ids can be widget types from config).
   - Fixed in the owner seal that adds this file.

## State at approval

- `node --test "tests/lib/*.test.mjs"`: 193 tests pass, 0 skipped.
- `bash scripts/verify-design-system.sh`: ALL CHECKS PASSED.
- `python3 scripts/matstate.py verify`: chain intact.
- Every fix has a regression test appended to the end of the affected test file; the test lock confirms nothing earlier was edited.

## Notes for later tasks

- Services that hand QML lists to `lib/` functions convert them with `Array.from` (02-contracts.md §1).
- Task 11 (runtime spike) records the JavaScript level of QML's engine. If object spread, `??` or `?.` fail there, nothing in `lib/` uses them today, and the checkpoint-11 reviewer turns the result into a lint rule.
