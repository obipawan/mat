#!/usr/bin/env python3
"""check-scope.py — a task's change touches only the files its plan card lists.

Usage:
  python3 scripts/check-scope.py --task N            # unsealed work vs the last seal (the gate runs this)
  python3 scripts/check-scope.py --task N --sealed   # reviewer: the change Task N's seal recorded

Allowed: the card's Create / Generated / Modify paths, tests/test-lock.json (checked by test-lock.py against
the sealed lock), the task's gate receipt and screenshots (docs/handoffs/task-NN.md, docs/evidence/task-NN/),
docs/handoffs/BLOCKED.md, and ticking checkboxes in the plan. Fails when a file outside that list changed,
when a Create path already existed before, when a Create path is missing, when a locked test changed, or
when a plan assertion is missing from the task's tests (check-plan-tests.py). No git needed: the baseline
is docs/state (scripts/matstate.py).
"""
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # keep scripts/__pycache__ out of the working tree
sys.path.insert(0, str(Path(__file__).resolve().parent))
import matstate  # noqa: E402
import planlib  # noqa: E402

ROOT = planlib.ROOT
PLAN_REL = planlib.PLAN.relative_to(ROOT).as_posix()
GUARDRAIL_PREFIXES = ("docs/lld/", "docs/handoffs/", "docs/state/", "design-system/", "scripts/lint-",
                      "scripts/gen-contracts.py", "scripts/test-lock.py", "scripts/check-", "scripts/planlib.py",
                      "scripts/matstate.py", "scripts/task-gate.py", "scripts/next-task.py", "scripts/qs-api.py",
                      "scripts/checkpoint.sh", "AGENTS.md")


def allowed_extra(n, changed):
    return ({f"docs/handoffs/task-{n:02d}.md", "docs/handoffs/BLOCKED.md", "tests/test-lock.json", PLAN_REL}
            | {c for c in changed if c.startswith(f"docs/evidence/task-{n:02d}/")})


def problems(n, sealed_mode=False):
    card = planlib.tasks().get(n)
    if not card:
        return [f"the plan has no Task {n}"], 0
    creates, modifies = set(card["files"]["create"]), set(card["files"]["modify"])
    if sealed_mode:
        entry = matstate.task_entry(n)
        if not entry:
            return [f"Task {n} has no seal yet"], 0
        diff = {p: tuple(v) for p, v in entry["changed"].items()}
        new_text = lambda p: (matstate.read_object(diff[p][1]) or b"").decode("utf-8", "replace")
    else:
        diff = matstate.changes()
        new_text = lambda p: (ROOT / p).read_text(encoding="utf-8") if (ROOT / p).exists() else ""
    changed = set(diff)
    errors = []
    for path in sorted(changed - creates - modifies - allowed_extra(n, changed)):
        tag = " (guardrail file: only a design-owner change may edit it)" if path.startswith(GUARDRAIL_PREFIXES) else ""
        errors.append(f"{path}: not in Task {n}'s Files list{tag}")
    if PLAN_REL in diff:
        old = (matstate.read_object(diff[PLAN_REL][0]) or b"").decode("utf-8", "replace")
        if old and old.replace("- [x]", "- [ ]") != new_text(PLAN_REL).replace("- [x]", "- [ ]"):
            errors.append(f"{PLAN_REL}: only checkboxes may change (edit the plan in a design-owner change)")
    for path in sorted(creates):
        if path in diff:
            old, new = diff[path]
            if old is not None:
                errors.append(f"{path}: listed as Create but already existed before (another task owns it)")
            if new is None:
                errors.append(f"{path}: listed as Create but missing")
        elif path not in matstate.sealed():
            errors.append(f"{path}: listed as Create but missing")
    if not sealed_mode:
        for script, args in (("test-lock.py", ["--check"]), ("check-plan-tests.py", ["--task", str(n)])):
            p = subprocess.run([sys.executable, str(ROOT / "scripts" / script), *args], cwd=ROOT, capture_output=True, text=True)
            if p.returncode != 0:
                errors += [l.strip() for l in p.stdout.splitlines() if l.strip() and not l.startswith("ERROR: a locked")]
    return errors, len(changed)


def main(argv):
    if "--task" not in argv:
        print(__doc__)
        sys.exit(2)
    n = int(argv[argv.index("--task") + 1])
    errors, count = problems(n, "--sealed" in argv)
    if errors:
        title = planlib.tasks().get(n, {}).get("title", "?")
        print(f"ERROR: Task {n} ({title}) is out of scope:")
        for e in errors:
            print("       " + e)
        sys.exit(1)
    print(f"  ✓ check-scope: Task {n} changed {count} files, all in its Files list")


if __name__ == "__main__":
    main(sys.argv)
