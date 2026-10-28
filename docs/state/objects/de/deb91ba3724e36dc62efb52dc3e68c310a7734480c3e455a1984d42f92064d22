#!/usr/bin/env python3
"""test-lock.py — stop later tasks from weakening tests that earlier tasks shipped.

Usage:
  python3 scripts/test-lock.py --check    # default; also run by verify-design-system.sh
  python3 scripts/test-lock.py --update   # record the current tests (task-gate.py does this when it seals a task)

tests/test-lock.json records each protected file:
  append  tests/lib/*.test.mjs, tests/smoke/ipc-script.txt: new lines may be added at the end; locked bytes never change
  exact   scripts/lint-fixtures/**: never change
A file not yet in the lock (a test the current task is writing) is free to change until the task is sealed.
--check verifies the files against the lock on disk and against the lock in the last seal (docs/state,
scripts/matstate.py), so re-running --update cannot hide an edit to a locked test. A locked test changes only in a
task the design owner approved; the hand-off lists it under "Locked files changed".
"""
import hashlib
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # keep scripts/__pycache__ out of the working tree
sys.path.insert(0, str(Path(__file__).resolve().parent))
import matstate  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / "tests" / "test-lock.json"
PATTERNS = [("tests/lib/*.test.mjs", "append"), ("tests/smoke/ipc-script.txt", "append"), ("scripts/lint-fixtures/**/*", "exact")]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def current():
    entries = {}
    for pattern, mode in PATTERNS:
        for p in sorted(ROOT.glob(pattern)):
            if p.is_file() and p.name != ".DS_Store":
                data = p.read_bytes()
                entries[p.relative_to(ROOT).as_posix()] = {"mode": mode, "bytes": len(data), "sha256": sha(data)}
    return entries


def violations(lock, label):
    out = []
    for path, e in sorted(lock.items()):
        p = ROOT / path
        if not p.exists():
            out.append(f"{path}: locked by {label} but deleted")
            continue
        data = p.read_bytes()
        if e["mode"] == "exact" and sha(data) != e["sha256"]:
            out.append(f"{path}: locked by {label} and must not change")
        elif e["mode"] == "append" and (len(data) < e["bytes"] or sha(data[:e["bytes"]]) != e["sha256"]):
            out.append(f"{path}: locked lines changed (by {label}, only additions at the end are allowed)")
    return out


def sealed_lock():
    data = matstate.read_sealed("tests/test-lock.json")
    try:
        return json.loads(data) if data else None
    except json.JSONDecodeError:
        return None


def main(argv):
    if "--update" in argv:
        LOCK.parent.mkdir(parents=True, exist_ok=True)
        LOCK.write_text(json.dumps(current(), indent=2) + "\n", encoding="utf-8")
        print(f"locked {len(current())} test files in {LOCK.relative_to(ROOT)}")
        return
    errors = []
    if LOCK.exists():
        errors += violations(json.loads(LOCK.read_text(encoding="utf-8")), "tests/test-lock.json")
    base = sealed_lock()
    if base is not None:
        errors += violations(base, "the last seal's tests/test-lock.json")
    if errors:
        print("ERROR: a locked test was changed (README §4: never weaken a test to make code pass):")
        for e in dict.fromkeys(errors):
            print("       " + e)
        sys.exit(1)
    locked = len(json.loads(LOCK.read_text())) if LOCK.exists() else 0
    unlocked = len(set(current()) - set(json.loads(LOCK.read_text()) if LOCK.exists() else {}))
    print(f"  ✓ test-lock: {locked} locked test files intact" + (f", {unlocked} new (lock them at commit)" if unlocked else ""))


if __name__ == "__main__":
    main(sys.argv)
