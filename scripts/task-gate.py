#!/usr/bin/env python3
"""task-gate.py — the only way a task gets sealed (docs/lld/06-unattended-runbook.md). No git needed.

Usage:
  python3 scripts/task-gate.py N --red   # after writing the tests, before implementing: they must fail
  python3 scripts/task-gate.py N         # after implementing: run every check, write the receipt, seal
  python3 scripts/task-gate.py N --stuck "question"   # you cannot finish without a decision: block and stop

Sealing records the task's files in docs/state (scripts/matstate.py): the snapshot later tasks are checked
against, and the history a reviewer reads with `python3 scripts/matstate.py show N`.

The gate writes docs/handoffs/task-NN.md from real command output. You fill only its "Agent notes" and
"Manual checks" sections, then run the gate again. After MAX_FAILURES failed runs of the checks for one
task it writes docs/handoffs/BLOCKED.md and every later run stops until a human removes it.
"""
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # keep scripts/__pycache__ out of the working tree
sys.path.insert(0, str(Path(__file__).resolve().parent))
import matstate  # noqa: E402
import planlib  # noqa: E402

ROOT = planlib.ROOT
PLAN = planlib.PLAN
MAX_FAILURES = 5
FILL = "<fill"


def run(cmd, timeout=600):
    try:
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, timeout=timeout,
                           shell=isinstance(cmd, str))
        return p.returncode, (p.stdout + p.stderr).strip()
    except subprocess.TimeoutExpired:
        return 124, f"timed out after {timeout}s: {cmd}"


def state_dir():
    matstate.GATE.mkdir(parents=True, exist_ok=True)
    return matstate.GATE


def last_line(text, pattern=None):
    lines = [l for l in text.splitlines() if l.strip()]
    if pattern:
        lines = [l for l in lines if re.search(pattern, l)] or lines
    return lines[-1].strip() if lines else ""


def on_target():
    return sys.platform.startswith("linux") and shutil.which("qs") is not None


def unit_tests(card):
    return [p for p in card["files"]["create"] + card["files"]["modify"] if p.startswith("tests/lib/") and p.endswith(".test.mjs")]


def smoke_task(card):
    return "tests/smoke/ipc-script.txt" in card["files"]["create"] + card["files"]["modify"]


def stop(msg, code=3):
    print(msg)
    sys.exit(code)


def preconditions(n, cards):
    if planlib.BLOCKED.exists():
        stop(f"STOP: {planlib.BLOCKED.relative_to(ROOT)} exists. A human must resolve it; do not change code.")
    broken = matstate.verify()
    if broken:
        stop("STOP: the history in docs/state is damaged; do not change code. Tell the human:\n  " + "\n  ".join(broken))
    if n not in cards:
        stop(f"STOP: the plan has no Task {n}.")
    if cards[n]["done"]:
        stop(f"STOP: Task {n} is already done. Run python3 scripts/next-task.py.")
    nxt = planlib.next_task(cards)
    if nxt != n:
        stop(f"STOP: the next task is Task {nxt}, not Task {n}. Run python3 scripts/next-task.py.")
    cp = planlib.pending_checkpoint(cards)
    if cp is not None:
        stop(f"STOP: checkpoint after Task {cp} waits for review. Run python3 scripts/next-task.py.")
    if n >= planlib.LINUX_FROM and not on_target():
        stop(f"STOP: Task {n} needs the Linux target with Quickshell (`qs`) on PATH.")


def red(n, card):
    if unit_tests(card):
        rc, out = run(["node", "--test", *unit_tests(card)])
    elif n >= planlib.LINUX_FROM and smoke_task(card):
        rc, out = run(["bash", "scripts/smoke-shell.sh"], timeout=300)
    else:
        print(f"  ✓ Task {n} has no tests to run red; implement it, then run python3 scripts/task-gate.py {n}")
        (state_dir() / f"task-{n}.red").write_text("not applicable (no tests in this task)\n")
        return
    if rc != 0:
        lines = out.splitlines()
        first = next((l.strip() for rx in (r"Cannot find|AssertionError|Expected|FAIL:", r"ERR_\w+|ERROR")
                      for l in lines if re.search(rx, l)), "")
        note = "FAIL as expected before implementation: " + (first or last_line(out))[:200]
        print("  ✓ red run: " + note)
    else:
        note = "WARNING: the tests PASSED before implementation (were they written after the code?)"
        print("  ! red run: " + note + "\n    This is recorded in the receipt for the reviewer.")
    (state_dir() / f"task-{n}.red").write_text(note + "\n")


def preserved(path, heading, default):
    if not path.exists():
        return default
    m = re.search(rf"^## {re.escape(heading)}\n(.*?)(?=^## |\Z)", path.read_text(encoding="utf-8"), flags=re.M | re.S)
    return m.group(1).strip() if m else default


def write_receipt(n, card, results, red_note):
    path = planlib.receipt_path(n)
    path.parent.mkdir(parents=True, exist_ok=True)
    notes = preserved(path, "Agent notes", "\n".join([
        "- Spec conflicts met: <fill: C-ids from 03-guardrails.md §3, or none>",
        "- Questions for the design owner: <fill, or none>",
        "- Not done / follow-ups: <fill, or none>",
    ]))
    manual_default = ("- none (pure logic task)" if n < planlib.LINUX_FROM else
                      "- <fill: one line per manual check in the task card: `pass — what you saw` or `fail — what you saw`>")
    manual = preserved(path, "Manual checks", manual_default)
    diff = matstate.changes()
    files = [("A " if old is None else "D " if new is None else "M ") + p for p, (old, new) in diff.items()
             if not p.startswith("docs/handoffs/")]
    added = []
    for p, (old, new) in diff.items():
        if new and p.endswith((".qml", ".mjs")):
            before = set((matstate.read_object(old) or b"").decode("utf-8", "replace").splitlines())
            added += [l for l in (ROOT / p).read_text(encoding="utf-8", errors="replace").splitlines() if l not in before]
    suppressions = [l.strip() for l in added if "lint-allow" in l]
    lines = [
        f"# Task {n}: {card['title']} — gate receipt",
        "",
        "Written by `scripts/task-gate.py` from real command output. Edit only the last two sections.",
        "",
        "## Hand-off",
        "",
        "```text",
        f"Task: {n} {card['title']}",
        "Files: " + ("; ".join(files) or "none"),
        f"Red run: {red_note}",
    ]
    lines += [f"{name}: {summary}" for name, (_, summary, _) in results.items()]
    lines += [f"Lint suppressions: {len(suppressions)}"] + [f"  {s}" for s in suppressions]
    lines += ["Locked files changed: none (the scope check refuses a change to a locked test)"]
    lines += ["```", "", "## Agent notes", "", notes, "", "## Manual checks", "", manual, ""]
    path.write_text("\n".join(lines), encoding="utf-8")
    return notes, manual


def tick(n):
    text = PLAN.read_text(encoding="utf-8")
    m = re.search(rf"^### Task {n}:.*?(?=^### Task |^## |\Z)", text, flags=re.M | re.S)
    PLAN.write_text(text[:m.start()] + m.group(0).replace("- [ ]", "- [x]") + text[m.end():], encoding="utf-8")


def fail(n, problems, counted):
    print(f"ERROR: Task {n} did not pass the gate:")
    for name, out in problems:
        print(f"--- {name} ---")
        print("\n".join(out.splitlines()[-25:]))
    if not counted:
        return sys.exit(1)
    counter = state_dir() / f"task-{n}.failures"
    count = int(counter.read_text()) + 1 if counter.exists() else 1
    counter.write_text(str(count))
    if count >= MAX_FAILURES:
        planlib.BLOCKED.parent.mkdir(parents=True, exist_ok=True)
        planlib.BLOCKED.write_text("\n".join(
            [f"# BLOCKED on Task {n}: {cards_title(n)}", "",
             f"The gate failed {count} times. The agent stopped here; a human (or a stronger review session) decides next.",
             "Delete this file only after the cause is fixed.", ""] +
            [f"## {name}\n\n```text\n" + "\n".join(out.splitlines()[-40:]) + "\n```\n" for name, out in problems]),
            encoding="utf-8")
        stop(f"STOP: {count} failed gate runs for Task {n}. Wrote {planlib.BLOCKED.relative_to(ROOT)}; do not change code.\n"
             f"Run `bash scripts/checkpoint.sh --blocked {n}`, tell the human the archive path it prints, and end the session.")
    print(f"\nFailed gate runs for Task {n}: {count} of {MAX_FAILURES}. Fix the cause in your own files "
          "(never by editing tests, fixtures, or guardrails), then run the gate again.")
    sys.exit(1)


def cards_title(n):
    return planlib.tasks()[n]["title"]


def gate(n, card):
    red_file = state_dir() / f"task-{n}.red"
    if (unit_tests(card) or (n >= planlib.LINUX_FROM and smoke_task(card))) and not red_file.exists():
        stop(f"STOP: run `python3 scripts/task-gate.py {n} --red` after writing the tests and before implementing.", 1)
    red_note = red_file.read_text().strip() if red_file.exists() else "not applicable"
    results = {}  # name -> (ok, one-line summary, full output)

    def step(name, cmd, pattern=None, timeout=600):
        rc, out = run(cmd, timeout)
        results[name] = (rc == 0, last_line(out, pattern), out)

    step("Scope", ["python3", "scripts/check-scope.py", "--task", str(n)], r"check-scope|ERROR")
    if (ROOT / "tests" / "lib").exists():
        rc, out = run(["node", "--test", "tests/lib/*.test.mjs"])
        counts = " ".join(re.findall(r"^ℹ ((?:tests|pass|fail|skipped) \d+)", out, flags=re.M))
        results["Tests"] = (rc == 0, counts or last_line(out), out)
    step("Verify", ["bash", "scripts/verify-design-system.sh"], r"ALL CHECKS|ERROR|FAIL")
    if n >= planlib.LINUX_FROM:
        step("Smoke", ["bash", "scripts/smoke-shell.sh"], r"smoke-shell|ERROR|FAIL", timeout=300)
        qml = [p for p in card["files"]["create"] + card["files"]["modify"] if p.endswith(".qml") and (ROOT / p).exists()]
        if shutil.which("qmllint") and qml:
            rc, out = run(["qmllint", "-I", "shell", *qml])
            results["qmllint (advisory)"] = (True, f"exit {rc}; " + (last_line(out) or "no output"), out)
    if n in planlib.SCREENSHOT_TASKS:
        shots = sorted((planlib.EVIDENCE / f"task-{n:02d}").glob("*.png"))
        results["Screenshots"] = (bool(shots), f"{len(shots)} in docs/evidence/task-{n:02d}/" if shots else
                                  f"none: save `grim docs/evidence/task-{n:02d}/<what>.png` for every new surface or state", "")
    notes, manual = write_receipt(n, card, results, red_note)
    failed = [(name, r[2] or r[1]) for name, r in results.items() if not r[0]]
    if failed:
        fail(n, failed, counted=True)
    receipt = planlib.receipt_path(n).relative_to(ROOT)
    if FILL in notes or FILL in manual:
        fail(n, [("Receipt", f"All checks pass. Now fill every `<fill …>` line in {receipt} (Agent notes and "
                             "Manual checks), then run the gate again.")], counted=False)
    if n >= planlib.LINUX_FROM and re.search(r"(^|\W)fail(\W|$)", manual, flags=re.I):
        fail(n, [("Manual checks", f"{receipt} records a failed manual check. Fix it; if you cannot, write the "
                                   "question under Agent notes and stop.")], counted=False)
    tick(n)
    run(["python3", "scripts/test-lock.py", "--update"])
    entry = matstate.seal("task", card["commit"], task=n)
    (state_dir() / f"task-{n}.failures").unlink(missing_ok=True)
    print(f"  ✓ Task {n} passed the gate and is sealed (seal {entry['seal']}, {len(entry['changed'])} files). "
          "Now run python3 scripts/next-task.py")


def main(argv):
    if len(argv) < 2 or not argv[1].isdigit():
        print(__doc__)
        sys.exit(2)
    n = int(argv[1])
    cards = planlib.tasks()
    preconditions(n, cards)
    if "--stuck" in argv:
        question = " ".join(argv[argv.index("--stuck") + 1:]).strip()
        if len(question) < 20:
            stop('STOP: describe the problem: --stuck "<what you tried, what failed, what decision you need>"', 1)
        planlib.BLOCKED.parent.mkdir(parents=True, exist_ok=True)
        planlib.BLOCKED.write_text(f"# BLOCKED on Task {n}: {cards[n]['title']}\n\nThe agent stopped and asks:\n\n> {question}\n",
                                   encoding="utf-8")
        stop(f"Wrote {planlib.BLOCKED.relative_to(ROOT)}. Run `bash scripts/checkpoint.sh --blocked {n}`, "
             "tell the human the archive path it prints, and end the session.")
    if "--red" in argv:
        return red(n, cards[n])
    gate(n, cards[n])


if __name__ == "__main__":
    main(sys.argv)
