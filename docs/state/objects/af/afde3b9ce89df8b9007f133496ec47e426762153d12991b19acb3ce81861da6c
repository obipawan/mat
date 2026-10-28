# LLD 05 — Agent Prompts

Fixed prompts for running the plan with agents, when an orchestrator can dispatch a fresh implementer and a stronger reviewer per task. With a single agent and no reviewer, use `06-unattended-runbook.md` and its Prompt S instead; the reviewer prompt below is then used at checkpoints. The orchestrator fills the `{…}` fields and sends the text unchanged: no extra context, no summaries of other tasks, no advice. Everything an agent needs is in the files the prompt names.

---

## 1. Orchestration Loop

1. Pick the task (README §2 step 1). Send **Prompt A** to a fresh implementer.
2. When the hand-off arrives, send **Prompt B** to a fresh reviewer. Use the most capable model you have for review; the implementer can be smaller.
3. `APPROVE` → next task. `REJECT` → follow **§4**: the reviewer's notes go in a file, the task is reverted, and a fresh implementer redoes it.
4. After two rejected rounds on one task, or any `STOP` from either agent, stop and hand the task to a human with the last hand-off and findings.

One task at a time. Never give an agent two tasks, and never let an implementer see the reviewer's prompt.

Worked example: Tasks 1–3 were done exactly this way. Read `shell/lib/widgetOptions.mjs` and `tests/lib/widgetOptions.test.mjs` before your first task; §5 is the hand-off of Task 3 (widgetOptions).

---

## 2. Prompt A — Implementer

```text
You are implementing Task {N} ("{TITLE}") of the Mat Shell plan in /path/to/mat.

Read, in this order and nothing else:
  1. docs/lld/README.md
  2. docs/lld/01-architecture.md
  3. The "### Task {N}" card in docs/superpowers/plans/2026-10-27-mat-shell-implementation-plan.md
     (and its Global Constraints section)
  4. The docs/lld/02-contracts.md sections and spec sections the card cites (only those sections)
  5. docs/lld/03-guardrails.md
For a worked example, read shell/lib/widgetOptions.mjs and tests/lib/widgetOptions.test.mjs.

Rules:
  - Follow the card's steps in order. Write the failing test first and run it; it must fail
    for the reason the card says.
  - Copy every assertion in the card verbatim into the test files; you may add more tests.
  - Touch only the card's Files. Use only names from 02-contracts.md; helpers you add start with `_`
    (QML) or are not exported (lib).
  - Never edit a sealed test, a lint fixture, docs/lld/*, design-system/*, docs/state/*, or the plan
    (except ticking this task's checkboxes).
  - If a rule in README §4 applies, stop: write STOP and your question in the hand-off.

Finish with python3 scripts/task-gate.py {N} (README §2 step 7), then reply with only the contents
of docs/handoffs/task-{NN}.md.
```

---

## 3. Prompt B — Reviewer

```text
You are reviewing Task {N} ("{TITLE}") of the Mat Shell plan in /path/to/mat. The implementer's
hand-off is below. You do not fix code; you approve or reject it.

Read: the "### Task {N}" card in docs/superpowers/plans/2026-10-27-mat-shell-implementation-plan.md,
docs/lld/03-guardrails.md, and the 02-contracts.md sections the card cites. Then run:
  python3 scripts/matstate.py verify
  python3 scripts/check-scope.py --task {N} --sealed
  bash scripts/verify-design-system.sh
  node --test "tests/lib/*.test.mjs"
and read the full diff (`python3 scripts/matstate.py show {N}`).

Reject when any of these is true (cite file:line and the rule id):
  R-a  A command above fails, or its output differs from what the hand-off claims.
  R-b  A name, signature, return shape, or file path differs from 02-contracts.md / 01-architecture.md.
  R-c  Behaviour the contract states is missing or different, even if no test covers it.
  R-d  A lint suppression without a spec citation, or a G/R rule from 03-guardrails.md is broken.
  R-e  Code beyond the task: extra exports, options, files, TODOs, commented-out code, placeholders.
  R-f  A test asserts less than the card (looser comparison, fewer cases, try/catch around asserts).
  R-g  QML task: the hand-off lacks the smoke result or manual rows from the Linux target.
  R-h  The hand-off misses a field, or a "Spec conflicts met" entry has no C-id and no question.

Reply in exactly this form:
  VERDICT: APPROVE | REJECT | STOP
  FINDINGS:
  - <rule id> <file>:<line> <what is wrong> → <what the contract or card requires>
  (write "none" when approving; STOP means a contract or spec question only the design owner can answer)

HAND-OFF:
{HANDOFF}
```

---

## 4. After a Rejection

The orchestrator (as design owner), not an implementer:

1. Writes the reviewer's FINDINGS to `docs/handoffs/review-task-NN.md`.
2. Reverts the task: `python3 scripts/matstate.py revert N --owner "<who>: rejected, see review-task-NN.md"`. The plan's checkboxes for the task untick, so it is the next task again.
3. Seals the notes: `python3 scripts/matstate.py seal --owner "<who>: review notes for Task N"`.
4. Sends **Prompt A** to a fresh implementer. `next-task.py` prints the review notes in the brief, under "REVIEWER NOTES".

A revert works only while no later seal changed the same files, so review each task before the next one starts, or review a whole checkpoint and revert from the newest task back.

---

## 5. Example Hand-off: Task 3 (widgetOptions)

```text
Task: 3 widgetOptions.mjs
Files: created shell/lib/widgetOptions.mjs, tests/lib/widgetOptions.test.mjs; modified tests/test-lock.json, plan checkboxes
Tests: node --test "tests/lib/*.test.mjs" → tests 53, pass 39, fail 0, skipped 14 (contracts of unbuilt modules)
Verify: ./scripts/verify-design-system.sh → ALL CHECKS PASSED
Scope: python3 scripts/check-scope.py --task 3 → ✓ check-scope: Task 3 changed 3 files, all in its Files list
Lint suppressions: 0
Locked files changed: none
Spec conflicts met: none; new ones: the contract did not say how resolve() treats toggle/text/format values.
  Resolved by the design owner before the task (commit "docs(lld): define resolve() for toggle, text and format fields").
Not done / follow-ups: none
```
