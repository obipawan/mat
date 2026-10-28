#!/usr/bin/env python3
"""matstate.py — the project's own history, kept as plain files in docs/state/ (no git needed).

The folder travels by plain copy, so everything the scripts need to know travels inside it:
  docs/state/manifest.json   the sealed snapshot: {path: sha256} of every project file after the last seal
  docs/state/log.jsonl       one entry per seal (baseline, task, owner), each chained to the previous by hash
  docs/state/objects/        the content of every sealed file version (for diffs, reviews, and reverts)
  docs/state/gate/           task-gate.py's red-run records and failure counters

Only scripts/task-gate.py seals task work. A reviewer (the design owner) seals review work by hand.

Usage:
  python3 scripts/matstate.py status              # files changed since the last seal
  python3 scripts/matstate.py diff [path …]       # unified diff of unsealed changes
  python3 scripts/matstate.py log                 # every seal
  python3 scripts/matstate.py show N              # the diff Task N sealed (for review)
  python3 scripts/matstate.py verify              # the log chain, the manifest and the objects agree
  python3 scripts/matstate.py seal --owner "<who>: <message>"     # design owner / reviewer only
  python3 scripts/matstate.py revert N --owner "<who>: <reason>"  # undo Task N's seal (it must be the latest change to its files)
"""
import difflib
import hashlib
import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATE = ROOT / "docs" / "state"
MANIFEST = STATE / "manifest.json"
LOG = STATE / "log.jsonl"
OBJECTS = STATE / "objects"
GATE = STATE / "gate"
SKIP_DIRS = {".git", "__pycache__", "node_modules", ".qmlls"}
SKIP_FILES = {".DS_Store"}
MAX_OBJECT = 4 * 1024 * 1024  # larger files are tracked by hash only


def sha(data):
    return hashlib.sha256(data).hexdigest()


def tracked(path):
    rel = path.relative_to(ROOT)
    if rel.parts[:2] == ("docs", "state"):
        return False
    return not (set(rel.parts) & SKIP_DIRS) and path.name not in SKIP_FILES and not path.name.endswith(".pyc")


def scan():
    """{path: sha256} of every project file on disk now."""
    return {p.relative_to(ROOT).as_posix(): sha(p.read_bytes())
            for p in sorted(ROOT.rglob("*")) if p.is_file() and not p.is_symlink() and tracked(p)}


def manifest():
    return json.loads(MANIFEST.read_text(encoding="utf-8")) if MANIFEST.exists() else {"head": None, "files": {}}


def sealed():
    return manifest()["files"]


def changes(current=None, base=None):
    """{path: (old sha or None, new sha or None)} for every path that differs from the sealed snapshot."""
    current = scan() if current is None else current
    base = sealed() if base is None else base
    return {p: (base.get(p), current.get(p)) for p in sorted(set(base) | set(current)) if base.get(p) != current.get(p)}


def read_object(digest):
    if digest is None:
        return None
    p = OBJECTS / digest[:2] / digest
    return p.read_bytes() if p.exists() else None


def read_sealed(path):
    return read_object(sealed().get(path))


def entries():
    if not LOG.exists():
        return []
    return [json.loads(l) for l in LOG.read_text(encoding="utf-8").splitlines() if l.strip()]


def entry_hash(entry):
    body = {k: v for k, v in entry.items() if k != "hash"}
    return sha(json.dumps(body, sort_keys=True, ensure_ascii=False).encode("utf-8"))


def files_hash(files):
    return sha(json.dumps(files, sort_keys=True).encode("utf-8"))


def seal(kind, message, task=None):
    """Record the current files as the new sealed snapshot. kind: baseline | task | owner."""
    current = scan()
    diff = changes(current)
    for path, (_, new) in diff.items():
        if new is not None:
            data = (ROOT / path).read_bytes()
            if len(data) <= MAX_OBJECT:
                target = OBJECTS / new[:2] / new
                target.parent.mkdir(parents=True, exist_ok=True)
                if not target.exists():
                    target.write_bytes(data)
    log = entries()
    entry = {"seal": len(log), "kind": kind, "task": task, "message": message,
             "time": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "previous": log[-1]["hash"] if log else None,
             "files_sha": files_hash(current), "changed": {p: list(v) for p, v in diff.items()}}
    entry["hash"] = entry_hash(entry)
    STATE.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    MANIFEST.write_text(json.dumps({"head": entry["hash"], "files": current}, indent=1, sort_keys=True) + "\n",
                        encoding="utf-8")
    return entry


def verify():
    """Problems with the history: a broken chain, a hand-edited manifest, missing objects."""
    problems, prev = [], None
    log = entries()
    if not log:
        return ["docs/state/log.jsonl is missing or empty (the folder was copied without docs/state/)"]
    for e in log:
        if e.get("previous") != prev:
            problems.append(f"seal {e['seal']}: does not follow seal {e['seal'] - 1}")
        if entry_hash(e) != e.get("hash"):
            problems.append(f"seal {e['seal']}: its entry was edited after sealing")
        prev = e.get("hash")
    m = manifest()
    if m.get("head") != prev:
        problems.append("manifest.json does not belong to the last seal (edited by hand?)")
    if files_hash(m["files"]) != log[-1]["files_sha"]:
        problems.append("manifest.json file list differs from what the last seal recorded (edited by hand?)")
    missing = [p for p, d in m["files"].items() if read_object(d) is None and len((ROOT / p).read_bytes() if (ROOT / p).exists() else b"") <= MAX_OBJECT]
    if missing:
        problems.append(f"{len(missing)} sealed files have no stored copy (e.g. {missing[0]})")
    return problems


def text(data):
    try:
        return data.decode("utf-8").splitlines(keepends=True)
    except (UnicodeDecodeError, AttributeError):
        return None


def unified(path, old, new, old_label="sealed", new_label="now"):
    a = text(read_object(old)) if old else []
    b = text((ROOT / path).read_bytes()) if new_label == "now" and new else (text(read_object(new)) if new else [])
    if a is None or b is None:
        return f"Binary or unstored file {path} ({old_label} {str(old)[:12]} → {new_label} {str(new)[:12]})\n"
    return "".join(difflib.unified_diff(a, b, f"{old_label}/{path}", f"{new_label}/{path}"))


def task_entry(n):
    found = [e for e in entries() if e["kind"] == "task" and e["task"] == n]
    return found[-1] if found else None


def revert(n, message):
    e = task_entry(n)
    if not e:
        sys.exit(f"ERROR: no seal for Task {n}")
    later = [x for x in entries() if x["seal"] > e["seal"]]
    clash = sorted({p for x in later for p in x["changed"]} & set(e["changed"]))
    if clash:
        sys.exit(f"ERROR: later seals changed {', '.join(clash[:5])}; revert those first or fix by hand")
    if changes():
        sys.exit("ERROR: unsealed changes exist; seal or remove them first")
    for path, (old, _) in e["changed"].items():
        target = ROOT / path
        if old is None:
            target.unlink(missing_ok=True)
        else:
            data = read_object(old)
            if data is None:
                sys.exit(f"ERROR: no stored copy of {path} before Task {n}")
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    for record in GATE.glob(f"task-{n}.*"):  # the redo must run --red again and starts with a fresh failure count
        record.unlink()
    return seal("owner", f"{message} (reverts Task {n}, seal {e['seal']})")


def owner_message(argv):
    if "--owner" not in argv or len(" ".join(argv[argv.index("--owner") + 1:])) < 8:
        sys.exit('ERROR: owner seals need --owner "<who>: <message>" (design owner / reviewer only)')
    return " ".join(argv[argv.index("--owner") + 1:])


def main(argv):
    cmd = argv[1] if len(argv) > 1 else "status"
    if cmd == "status":
        diff = changes()
        for p, (old, new) in diff.items():
            print(("A " if old is None else "D " if new is None else "M ") + p)
        print(f"{len(diff)} files changed since seal {entries()[-1]['seal'] if entries() else '—'}")
    elif cmd == "diff":
        paths = argv[2:]
        for p, (old, new) in changes().items():
            if not paths or p in paths:
                sys.stdout.write(unified(p, old, new))
    elif cmd == "log":
        for e in entries():
            who = f"Task {e['task']}" if e["task"] else e["kind"]
            print(f"seal {e['seal']:>3}  {e['time']}  {who:<9} {len(e['changed']):>3} files  {e['message']}")
    elif cmd == "show":
        e = task_entry(int(argv[2]))
        if not e:
            sys.exit(f"no seal for Task {argv[2]}")
        print(f"seal {e['seal']}  Task {e['task']}  {e['message']}  ({e['time']})")
        for p, (old, new) in e["changed"].items():
            sys.stdout.write(unified(p, old, new, f"before-{e['seal']}", f"seal-{e['seal']}"))
    elif cmd == "verify":
        problems = verify()
        if problems:
            print("ERROR: docs/state history problems:\n  " + "\n  ".join(problems))
            sys.exit(1)
        print(f"  ✓ matstate: {len(entries())} seals, chain and manifest intact")
    elif cmd in ("seal", "init"):
        if cmd == "init" and entries():
            sys.exit("ERROR: docs/state already has history")
        e = seal("baseline" if cmd == "init" else "owner", owner_message(argv))
        print(f"  ✓ seal {e['seal']}: {len(e['changed'])} files")
    elif cmd == "revert":
        e = revert(int(argv[2]), owner_message(argv))
        print(f"  ✓ seal {e['seal']}: reverted Task {argv[2]} ({len(e['changed'])} files)")
    else:
        print(__doc__)
        sys.exit(2)


if __name__ == "__main__":
    main(sys.argv)
