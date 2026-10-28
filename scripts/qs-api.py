#!/usr/bin/env python3
"""qs-api.py — does this Quickshell / Qt QML type or member really exist on this machine?

Usage:
  python3 scripts/qs-api.py PanelWindow                 # list the type's members (with inherited ones)
  python3 scripts/qs-api.py PanelWindow exclusionMode   # exit 0 when the member exists, 1 when it does not
  python3 scripts/qs-api.py --paths                     # show where it looked

It reads the *.qmltypes files installed with Quickshell and Qt (the same data qmllint uses), so the answer
reflects the installed version, not documentation or memory. Use it before any API that is not listed in
docs/lld/03-guardrails.md §5. "not found" means: do not use it.
"""
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

FALLBACK_DIRS = ["/usr/lib/qt6/qml", "/usr/lib64/qt6/qml", "/usr/lib/x86_64-linux-gnu/qt6/qml",
                 "/usr/lib/aarch64-linux-gnu/qt6/qml", "/usr/share/qt6/qml", "/run/current-system/sw/lib/qt-6/qml"]


def qml_dirs():
    dirs = [d for d in os.environ.get("QML_IMPORT_PATH", "").split(":") if d]
    dirs += [d for d in os.environ.get("QML2_IMPORT_PATH", "").split(":") if d]
    for tool in ("qtpaths6", "qtpaths", "qmake6", "qmake"):
        if shutil.which(tool):
            args = ["--query", "QT_INSTALL_QML"] if "qtpaths" in tool else ["-query", "QT_INSTALL_QML"]
            out = subprocess.run([tool, *args], capture_output=True, text=True).stdout.strip()
            if out:
                dirs.append(out)
    dirs += FALLBACK_DIRS
    seen = []
    for d in dirs:
        if Path(d).is_dir() and d not in seen:
            seen.append(d)
    return seen


def blocks(text, keyword):
    """Top-level `keyword { … }` blocks inside a qmltypes Module."""
    out = []
    for m in re.finditer(r"\b" + keyword + r"\s*\{", text):
        depth, i = 0, m.end() - 1
        while i < len(text):
            depth += {"{": 1, "}": -1}.get(text[i], 0)
            if depth == 0:
                out.append(text[m.end():i])
                break
            i += 1
    return out


def load():
    """{name: {"exports": [...], "prototype": str, "members": {member: kind}, "file": str}}"""
    types = {}
    for d in qml_dirs():
        for f in Path(d).rglob("*.qmltypes"):
            text = f.read_text(encoding="utf-8", errors="replace")
            for comp in blocks(text, "Component"):
                head = re.sub(r"\b(?:Property|Signal|Method|Enum)\s*\{.*", "", comp, flags=re.S)
                name = re.search(r'\bname:\s*"([^"]+)"', head)
                if not name:
                    continue
                proto = re.search(r'\bprototype:\s*"([^"]+)"', head)
                exports = re.findall(r'"([\w.]+/(\w+) [\d.]+)"', re.search(r"exports:\s*\[([^\]]*)\]", head).group(1)) \
                    if re.search(r"exports:\s*\[", head) else []
                attached = re.search(r'\battachedType:\s*"([^"]+)"', head)
                members = {}
                for kind in ("Property", "Signal", "Method", "Enum"):
                    for b in blocks(comp, kind):
                        n = re.search(r'\bname:\s*"([^"]+)"', b)
                        if n:
                            members.setdefault(n.group(1), kind.lower())
                types[name.group(1)] = {"exports": exports, "prototype": proto.group(1) if proto else None,
                                        "attached": attached.group(1) if attached else None,
                                        "members": members, "file": str(f)}
    return types


def find(types, qml_name):
    """C++ names whose QML export (or C++ name) matches; Quickshell modules first."""
    hits = [k for k, v in types.items() if any(e[1] == qml_name for e in v["exports"])] or \
           [k for k in types if k == qml_name]
    return sorted(hits, key=lambda k: "quickshell" not in types[k]["file"].lower())


def all_members(types, cpp):
    members, chain, seen = {}, [], set()
    while cpp and cpp in types and cpp not in seen:
        seen.add(cpp)
        chain.append(cpp)
        for m, kind in types[cpp]["members"].items():
            members.setdefault(m, (kind, cpp))
        cpp = types[cpp]["prototype"]
    return members, chain


def main(argv):
    if argv[1:2] == ["--paths"]:
        print("\n".join(qml_dirs()) or "no QML directories found")
        return
    if len(argv) < 2:
        print(__doc__)
        sys.exit(2)
    types = load()
    if not types:
        print("ERROR: no *.qmltypes files found. Run with --paths; set QML_IMPORT_PATH to Quickshell's QML directory.")
        sys.exit(2)
    hits = find(types, argv[1])
    if not hits:
        print(f"not found: no QML type named {argv[1]} is installed. Do not use it.")
        sys.exit(1)
    cpp = hits[0]
    members, chain = all_members(types, cpp)
    att = types[cpp]["attached"]
    if att and att in types:
        for m, kind in types[att]["members"].items():
            members.setdefault(m, (kind + " (attached)", att))
    module = ", ".join(e[0] for e in types[cpp]["exports"]) or cpp
    if len(argv) >= 3:
        member = argv[2]
        if member in members:
            kind, owner = members[member]
            print(f"found: {argv[1]}.{member} — {kind}, declared on {owner} ({module})")
            return
        close = [m for m in members if m.lower().startswith(member[:3].lower())][:12]
        print(f"not found: {argv[1]} has no member {member}. Do not use it." +
              (f" Similar: {', '.join(sorted(close))}" if close else ""))
        sys.exit(1)
    print(f"{argv[1]} ({module}); inherits {' → '.join(chain[1:]) or 'nothing'}")
    for m in sorted(members):
        kind, owner = members[m]
        print(f"  {kind:<20} {m}" + (f"   (from {owner})" if owner != cpp else ""))


if __name__ == "__main__":
    main(sys.argv)
