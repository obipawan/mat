#!/usr/bin/env python3
"""gen-contracts.py — turn docs/lld/02-contracts.md into docs/lld/contracts.json (closed name lists).

Usage:
  python3 scripts/gen-contracts.py           # (re)write docs/lld/contracts.json
  python3 scripts/gen-contracts.py --check   # exit 1 when contracts.json is stale

02-contracts.md stays the source of truth. The JSON holds only names, for machines:
  lib:         { "<module path under shell/lib>": [export, …] }          (§2 tables with an Export column)
  singletons:  { "<Name>": { "file": "<path under shell>", "members": [...] } }  (§3.1, §3.2, §4)
  primitives:  [ "M3Surface", … ]                                         (§5)
  widgets:     { "<type>": "<PascalType>Widget.qml" }                     (§2.3 values table)
Lint rule G21 and tests/lib/contracts.test.mjs read it.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "lld" / "02-contracts.md"
OUT = ROOT / "docs" / "lld" / "contracts.json"


def cells(row):
    """Split a markdown table row on unescaped pipes."""
    return [c.strip() for c in re.split(r"(?<!\\)\|", row.strip().strip("|"))]


def top_spans(cell):
    """Backtick spans that are not inside a parenthesised remark: `a` (`not this`) `b` -> [a, b]."""
    spans, depth, i = [], 0, 0
    while i < len(cell):
        c = cell[i]
        if c == "`":
            j = cell.find("`", i + 1)
            if j < 0:
                break
            if depth == 0:
                spans.append(cell[i + 1:j])
            i = j + 1
            continue
        depth += c == "("
        depth -= c == ")" and depth > 0
        i += 1
    return spans


def lead(span, lower_only):
    m = re.match(r"([A-Za-z_]\w*)", span)
    if not m or (lower_only and not re.match(r"[a-z_]", m.group(1))):
        return None
    return m.group(1)


def pascal(s):
    return s[:1].upper() + s[1:]


def parse(text):
    out = {"lib": {}, "singletons": {}, "primitives": [], "widgets": {}}
    heading_mod, heading_name, header, module = None, None, None, None
    for line in text.splitlines():
        h = re.match(r"#{2,4}\s+(\S+)\s+(.*)", line)
        if h:
            mods = re.findall(r"`([\w/]+\.mjs)`", h.group(2))
            heading_mod = mods[0] if mods else None
            names = re.findall(r"`([A-Z]\w+)`", h.group(2))
            heading_name = names[0] if names else None
            header = None
            continue
        if not line.lstrip().startswith("|"):
            header = None
            continue
        row = cells(line)
        if all(re.fullmatch(r":?-+:?", c) for c in row if c):
            continue
        if header is None:
            header = [c.lower() for c in row]
            module = None
            continue
        col = dict(zip(header, row))
        if header[:2] == ["module", "export"] or header[0] == "export":
            if "module" in col:
                m = re.findall(r"`([\w/]+\.mjs)`", col["module"])
                module = m[0] if m else module
            mod = module if "module" in col else heading_mod
            names = [lead(s, False) for s in top_spans(col["export"])]
            out["lib"].setdefault(mod, []).extend(n for n in names if n)
        elif header[0] == "member":
            members = [lead(s, True) for s in top_spans(col["member"])]
            out["singletons"].setdefault(heading_name, []).extend(n for n in members if n)
        elif header[0] == "service":
            name = col["service"].strip("`")
            props = [lead(s, True) for s in top_spans(col[header[1]])]
            fns = [lead(s, True) for s in top_spans(col[header[2]]) if re.match(r"[a-z_]\w*\(", s)]
            out["singletons"].setdefault(name, []).extend(n for n in props + fns if n)
        elif header[0] == "primitive":
            out["primitives"].append(re.match(r"`?(\w+)", col["primitive"]).group(1))
        elif header[0] == "type" and "overflowpriority" in header:
            t = col["type"].strip("`")
            out["widgets"][t] = pascal(t) + "Widget.qml"
    out["lib"] = {k: sorted(set(v)) for k, v in sorted(out["lib"].items())}
    out["singletons"] = {
        k: {"file": ("MatShell/State/" if k == "ShellState" else "MatShell/Services/") + k + ".qml",
            "members": sorted(set(v))}
        for k, v in sorted(out["singletons"].items())
    }
    out["primitives"] = sorted(out["primitives"])
    return out


def problems(c):
    """Sanity checks so a doc edit that breaks parsing fails loudly instead of emptying a list."""
    errs = []
    if None in c["lib"]:
        errs.append("an Export table has no module (heading without `x.mjs` and no Module column)")
    for k, v in c["lib"].items():
        if not v:
            errs.append(f"lib {k}: no exports parsed")
    for k, v in c["singletons"].items():
        if not v["members"] and k != "AccessibilityService":
            errs.append(f"singleton {k}: no members parsed")
    if len(c["primitives"]) != 26:
        errs.append(f"expected 26 primitives in §5, parsed {len(c['primitives'])}")
    if len(c["widgets"]) != 20:
        errs.append(f"expected 20 widget types in §2.3, parsed {len(c['widgets'])}")
    return errs


def main(argv):
    contracts = parse(SRC.read_text(encoding="utf-8"))
    errs = problems(contracts)
    if errs:
        for e in errs:
            print("ERROR: gen-contracts: " + e)
        sys.exit(1)
    text = json.dumps(contracts, indent=2) + "\n"
    if "--check" in argv:
        if not OUT.exists() or OUT.read_text(encoding="utf-8") != text:
            print("ERROR: docs/lld/contracts.json is stale: run `python3 scripts/gen-contracts.py` after editing 02-contracts.md")
            sys.exit(1)
        n = sum(len(v) for v in contracts["lib"].values()) + sum(len(v["members"]) for v in contracts["singletons"].values())
        print(f"  ✓ contracts.json matches 02-contracts.md ({len(contracts['lib'])} modules, "
              f"{len(contracts['singletons'])} singletons, {n} names)")
        return
    OUT.write_text(text, encoding="utf-8")
    print(f"wrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main(sys.argv)
