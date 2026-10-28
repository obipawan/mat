#!/usr/bin/env python3
"""check-plan-tests.py — every assertion a plan task specifies appears, unweakened, in that task's tests.

Usage:
  python3 scripts/check-plan-tests.py --task N   # also run by check-scope.py
  python3 scripts/check-plan-tests.py --all      # every task whose test files exist

Takes each `assert…(…)` call from the task's ```js blocks and looks for it in the task's
tests/lib/*.test.mjs files, ignoring whitespace and the parentheses around a single arrow parameter.
Extra tests are welcome; missing or edited plan assertions fail.
"""
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # keep scripts/__pycache__ out of the working tree
sys.path.insert(0, str(Path(__file__).resolve().parent))
import planlib  # noqa: E402

ROOT = planlib.ROOT


def normalize(code):
    code = re.sub(r"//[^\n]*", "", code)
    code = re.sub(r"\((\w+)\)\s*=>", r"\1=>", code)
    return re.sub(r"\s+", "", code)


def assertions(code):
    """Each `assert.x(…)` / `assert(…)` call, up to its matching parenthesis."""
    out = []
    for m in re.finditer(r"\bassert(?:\.\w+)?\(", code):
        depth, i = 0, m.end() - 1
        while i < len(code):
            depth += {"(": 1, ")": -1}.get(code[i], 0)
            if depth == 0:
                out.append(code[m.start():i + 1])
                break
            i += 1
    return out


def check(n, card):
    tests = [p for p in card["files"]["create"] if p.startswith("tests/lib/") and p.endswith(".test.mjs")]
    blocks = "\n".join(re.findall(r"```js\n(.*?)```", card["body"], flags=re.S))
    wanted = assertions(blocks)
    if not wanted or not tests:
        return None, []
    existing = [ROOT / p for p in tests if (ROOT / p).exists()]
    if not existing:
        return None, []
    have = normalize("\n".join(p.read_text(encoding="utf-8") for p in existing))
    missing = [a for a in wanted if normalize(a) not in have]
    return len(wanted), missing


def main(argv):
    cards = planlib.tasks()
    if "--all" in argv:
        targets = sorted(cards)
    elif "--task" in argv:
        targets = [int(argv[argv.index("--task") + 1])]
    else:
        print(__doc__)
        sys.exit(2)
    failed = False
    for n in targets:
        count, missing = check(n, cards[n])
        if count is None:
            if "--task" in argv:
                print(f"  ✓ check-plan-tests: Task {n} specifies no unit-test assertions")
            continue
        if missing:
            failed = True
            print(f"ERROR: Task {n}: {len(missing)} of {count} plan assertions are missing or changed in its tests:")
            for a in missing:
                print("       " + " ".join(a.split()))
        else:
            print(f"  ✓ check-plan-tests: Task {n} tests contain all {count} plan assertions")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main(sys.argv)
