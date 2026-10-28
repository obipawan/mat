"""planlib.py — read task cards from the implementation plan (shared by check-scope.py and check-refs.py)."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLAN = ROOT / "docs" / "superpowers" / "plans" / "2026-10-27-mat-shell-implementation-plan.md"


def expand_braces(path):
    """`a/{b,c}.qml` -> [`a/b.qml`, `a/c.qml`] (one level per brace group, applied repeatedly)."""
    m = re.search(r"\{([^{}]*)\}", path)
    if not m:
        return [path]
    out = []
    for alt in m.group(1).split(","):
        out += expand_braces(path[:m.start()] + alt + path[m.end():])
    return out


def strip_remarks(text):
    """Drop parenthesised remarks that sit outside backticks: `a` (see `b/c`) -> `a`."""
    out, depth, in_tick = [], 0, False
    for c in text:
        if c == "`" and depth == 0:
            in_tick = not in_tick
        elif not in_tick and c == "(":
            depth += 1
            continue
        elif not in_tick and c == ")" and depth:
            depth -= 1
            continue
        if depth == 0:
            out.append(c)
    return "".join(out)


def phases(text):
    """[(start offset, "Phase X — Name", intro text before its first task)]"""
    out = []
    for m in re.finditer(r"^## (Phase [A-Z] — .*)$", text, flags=re.M):
        rest = text[m.end():]
        intro = re.split(r"^### Task |^## ", rest, maxsplit=1, flags=re.M)[0].strip()
        out.append((m.start(), m.group(1).strip(), intro))
    return out


def tasks(text=None):
    """{n: {"title", "body", "phase", "phase_intro", "commit", "done", "depends": [int],
            "files": {"create": [...], "modify": [...]}}}"""
    text = text if text is not None else PLAN.read_text(encoding="utf-8")
    phase_list = phases(text)
    starts = {int(m.group(1)): m.start() for m in re.finditer(r"^### Task (\d+):", text, flags=re.M)}
    found = {}
    parts = re.split(r"^### Task (\d+): (.*)$", text, flags=re.M)
    for i in range(1, len(parts), 3):
        n, title, body = int(parts[i]), parts[i + 1].strip(), re.split(r"^## ", parts[i + 2], flags=re.M)[0]
        files = {"create": [], "modify": []}
        block = re.search(r"^\*\*Files:\*\*\n((?:- .*\n)+)", body, flags=re.M)
        for line in (block.group(1).splitlines() if block else []):
            m = re.match(r"- (Create|Generated[^:]*|Modify[^:]*):\s*(.*)", line)
            if not m:
                continue
            kind = "modify" if m.group(1).startswith("Modify") else "create"
            for span in re.findall(r"`([^`]+)`", strip_remarks(m.group(2))):
                if "/" in span and not re.search(r"\s", span):
                    files[kind] += expand_braces(span)
        dep = re.search(r"^\*\*Depends on:\*\*\s*(.*)$", body, flags=re.M)
        depends = [int(x) for x in re.findall(r"\b(\d+)\b", strip_remarks(dep.group(1)))] if dep else []
        phase = [p for p in phase_list if p[0] < starts[n]][-1] if phase_list else (0, "", "")
        commit = re.findall(r"Commit\**:?\**\s*`([^`]+)`", body)
        boxes = re.findall(r"^\s*- \[([ x])\]", body, flags=re.M)
        found[n] = {"title": title, "body": body, "depends": depends, "files": files, "phase": phase[1],
                    "phase_intro": phase[2], "commit": commit[0] if commit else None,
                    "done": bool(boxes) and all(b == "x" for b in boxes)}
    return found


# Unattended runs (docs/lld/06-unattended-runbook.md)
LINUX_FROM = 11  # Tasks 11+ need the Linux target with Quickshell running
CHECKPOINTS = (10, 11, 15, 19, 22, 26, 29, 31, 34)  # the last task of each phase: stop for an outside review
SCREENSHOT_TASKS = set(range(16, 20)) | set(range(23, 35))  # tasks that hand in grim screenshots
HANDOFFS = ROOT / "docs" / "handoffs"
EVIDENCE = ROOT / "docs" / "evidence"
BLOCKED = HANDOFFS / "BLOCKED.md"


def receipt_path(n):
    return HANDOFFS / f"task-{n:02d}.md"


def checkpoint_path(n):
    return HANDOFFS / f"checkpoint-{n:02d}.md"


def next_task(cards):
    """The lowest-numbered unfinished task whose dependencies are finished (README §2 step 1)."""
    for n in sorted(cards):
        if not cards[n]["done"] and all(cards[d]["done"] for d in cards[n]["depends"]):
            return n
    return None


def pending_checkpoint(cards):
    """The finished checkpoint task that still waits for an outside review, if any."""
    for n in CHECKPOINTS:
        if cards[n]["done"] and not checkpoint_path(n).exists():
            return n
    return None
