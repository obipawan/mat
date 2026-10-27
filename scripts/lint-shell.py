#!/usr/bin/env python3
"""lint-shell.py — mechanical guardrails for generated Mat Shell QML (docs/lld/03-guardrails.md).

Usage:
  python3 scripts/lint-shell.py [path ...]   # default: shell/ ; exit 1 on any error
  python3 scripts/lint-shell.py --self-test  # run scripts/lint-fixtures (each file declares `// expect: Gxx …`)

Suppress one finding on its line with `// lint-allow Gxx: <reason of 10+ chars>`; every suppression is
reported so reviewers see it. Rule IDs match the guardrail table; never weaken a rule to make code pass.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

ALLOWED_IMPORTS = {
    "QtQuick", "QtQuick.Layouts", "QtQuick.Effects", "QtQuick.Shapes", "QtQml", "QtQml.Models",
    "Quickshell", "Quickshell.Wayland", "Quickshell.Io", "Quickshell.Widgets", "Quickshell.Hyprland",
    "Quickshell.Services.Pipewire", "Quickshell.Services.UPower", "Quickshell.Services.Mpris",
    "Quickshell.Services.SystemTray", "Quickshell.Services.Notifications", "Quickshell.Services.Pam",
    "Quickshell.Services.Polkit", "Quickshell.Bluetooth",
    "MatShell.Tokens", "MatShell.Services", "MatShell.State", "MatShell.Primitives",
}
NON_SUPPRESSIBLE = {"G06", "G07", "G08", "G15", "G17", "G20"}  # architecture rules: fix the design, never silence them
SPATIAL = r"(?:x|y|width|height|implicitWidth|implicitHeight|scale|radius|cornerRadius|rotation)"
HTML_IDIOMS = r"(?:\bclassName\b|\bdocument\.|\bwindow\.addEventListener|\buseState\b|\bonClick\s*=|<div\b|\bpx['\"]|\bdisplay:\s*flex)"
SERVICE_NAMES = r"\b(?:ConfigService|AudioService|BatteryService|MediaService|NetworkService|NotificationService|CompositorService|BrightnessService|TelemetryService|AccessibilityService|ThemeService|KeybindService|BarWidgetRegistry)\b"


def strip_comments(line):
    """Drop // comments that are not inside a string (good enough for QML/JS)."""
    out, quote, i = [], None, 0
    while i < len(line):
        c = line[i]
        if quote:
            out.append(c)
            if c == "\\" and i + 1 < len(line):
                out.append(line[i + 1]); i += 2; continue
            if c == quote:
                quote = None
        elif c in "\"'`":
            quote = c; out.append(c)
        elif line.startswith("//", i):
            break
        else:
            out.append(c)
        i += 1
    return "".join(out)


def blocks(lines, type_pattern):
    """Yield (start_line_index, end_line_index, text) for each `Type {` object block."""
    rx = re.compile(r"^\s*(?:[\w.]+\s*:\s*)?(" + type_pattern + r")\s*\{")
    for i, raw in enumerate(lines):
        if not rx.match(strip_comments(raw)):
            continue
        depth, j = 0, i
        while j < len(lines):
            code = strip_comments(lines[j])
            depth += code.count("{") - code.count("}")
            if depth <= 0 and j >= i:
                break
            j += 1
        yield i, j, "\n".join(strip_comments(l) for l in lines[i:j + 1])


class Linter:
    def __init__(self):
        self.findings = []  # (path, line, rule, message, suppressed)

    def report(self, path, lineno, rule, msg, lines):
        raw = lines[lineno - 1] if 0 < lineno <= len(lines) else ""
        m = re.search(r"//\s*lint-allow\s+(G\d+)\s*:\s*(.+)$", raw)
        suppressed = bool(m and m.group(1) == rule and len(m.group(2).strip()) >= 10 and rule not in NON_SUPPRESSIBLE)
        self.findings.append((path, lineno, rule, msg, suppressed))

    def lint_file(self, path: Path):
        rel = path.relative_to(ROOT) if path.is_relative_to(ROOT) else path
        parts = set(Path(rel).parts)
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        in_tokens = "Tokens" in parts and "MatShell" in parts
        in_services = "Services" in parts and "MatShell" in parts
        in_primitives = "Primitives" in parts and "MatShell" in parts
        in_widgets = "widgets" in parts and "bar" in parts
        in_settings = "settings" in parts
        r = lambda n, rule, msg: self.report(rel, n, rule, msg, lines)

        if path.suffix == ".mjs":
            for n, raw in enumerate(lines, 1):
                code = strip_comments(raw)
                if re.search(r"\b(?:Qt|Quickshell|Tokens|console\.log)\b", code) or re.match(r"\s*import\s+Qt", code):
                    r(n, "G20", "lib/*.mjs must stay pure JS: no Qt, Quickshell, Tokens, or console.log (node must run it)")
            return

        for n, raw in enumerate(lines, 1):
            code = strip_comments(raw)
            m = re.match(r"\s*import\s+([A-Za-z][\w.]*)", code)
            if m and m.group(1) not in ALLOWED_IMPORTS:
                r(n, "G15", f"import {m.group(1)} is not on the allowlist (QtQuick.Controls / Material styles are banned)")
            if in_tokens:
                continue
            if re.search(r"[\"']#[0-9a-fA-F]{3,8}[\"']|\bQt\.(?:rgba|hsla|hsva|color|darker|lighter)\s*\(|\bcolor\s*:\s*[\"'](?!transparent[\"'])[a-z]+[\"']", code):
                r(n, "G01", "colour literal: bind to Tokens.color.<role>, surfaceTier(), or withAlpha()")
            if re.search(r"\b(?:radius|cornerRadius)\s*:\s*[1-9]\d*\s*$", code):
                r(n, "G02", "radius literal: use Tokens.shape.<token> or morphPillRadius()/morphTileRadius()")
            if re.search(r"\b(?:width|height|[a-z]+(?:Width|Height)|spacing|[a-z]*Spacing|margins|[a-z]*Margin|padding|[a-z]*Padding)\s*:\s*[1-9]\d*\s*$", code):
                r(n, "G03", "pixel literal: use Tokens.metrics.<token> (or derive from one)")
            if re.search(r"font\.pixelSize\s*:\s*\d|font\.family\s*:\s*[\"']|font\.pointSize\s*:", code):
                r(n, "G04", "font literal: use Tokens.typography.<role>.family / .pixelSize")
            if re.search(r"\bduration\s*:\s*[1-9]\d*\b", code):
                r(n, "G05", "duration literal: use Tokens.motion.* (durationMs, reducedMotionFadeMs, holdToConfirmMs …)")
            if re.search(r"\b(?:spring|damping|epsilon)\s*:\s*\d", code):
                r(n, "G05", "spring literal: use Tokens.motion.spring*Spatial/Effects .spring/.damping")
            if re.search(r"^\s*(?:Window|ApplicationWindow|QtObject\s*\{\s*//\s*window)\s*\{", code):
                r(n, "G07", "plain Window: shell surfaces are PanelWindow / PopupWindow / WlSessionLock (Settings alone is FloatingWindow)")
            if re.search(r"^\s*(?:\w+\s*:\s*)?FloatingWindow\s*\{", code) and not in_settings:
                r(n, "G07", "FloatingWindow is reserved for the Settings app (16-settings.md)")
            if re.search(r"^\s*(?:\w+\s*:\s*)?(?:Process|FileView|Socket|DBusInterface)\s*\{", code) and not in_services and not in_tokens:
                r(n, "G08", "Process / FileView / sockets live only in MatShell/Services; surfaces call a service function")
            if re.search(r"^\s*(?:\w+\s*:\s*)?MouseArea\s*\{", code) and not in_primitives:
                r(n, "G12", "raw MouseArea outside primitives: compose M3Button / M3IconButton / M3BarPill / M3StateLayer")
            if re.search(HTML_IDIOMS, code):
                r(n, "G16", "HTML/CSS/React idiom in QML: use QtQuick layouts, anchors, HoverHandler/TapHandler")
            if in_widgets and re.search(r"\boptions\.[A-Za-z_]", code):
                r(n, "G13", "widgets read options only through `opt` = BarWidgetRegistry.resolve(type, options, orientation)")
            if in_primitives and re.search(SERVICE_NAMES, code):
                r(n, "G17", "primitives must not depend on services (only Tokens, ShellState, BarService, KeyboardService)")
            if re.search(r"\bconsole\.log\s*\(", code):
                r(n, "G18", "console.log left in code: use console.warn/console.error with a 'mat-shell:' prefix, or remove")

        if in_tokens:
            return
        for i, j, block in blocks(lines, r"PanelWindow"):
            for prop in ("WlrLayershell.namespace", "WlrLayershell.layer", "WlrLayershell.keyboardFocus"):
                if prop not in block:
                    r(i + 1, "G06", f"PanelWindow without explicit {prop} (05-wayland-layershell-spatial.md)")
            m = re.search(r"WlrLayershell\.namespace\s*:\s*(.+)", block)
            if m and not re.search(r"[\"']mat-", m.group(1)):
                r(i + 1, "G06", "WlrLayershell.namespace must start with \"mat-\"")
        for i, j, block in blocks(lines, r"(?:NumberAnimation|PropertyAnimation|SmoothedAnimation)(?:\s+on\s+[\w.]+)?"):
            if re.match(r"\s*(?:[\w.]+\s*:\s*)?\w+\s+on\s+" + SPATIAL + r"\b", block) or re.search(r"\bproperty\s*:\s*[\"']" + SPATIAL + r"[\"']|\bproperties\s*:\s*[\"'][^\"']*\b" + SPATIAL + r"\b", block):
                r(i + 1, "G09", "spatial property animated with a curve: spatial motion uses SpringAnimation + Tokens.motion.spring*Spatial")
        for i, j, block in blocks(lines, r"Behavior\s+on\s+" + SPATIAL):
            if "spatialMotionEnabled" not in block:
                r(i + 1, "G10", "spatial Behavior must set `enabled: Tokens.motion.spatialMotionEnabled` (Reduced Motion)")
        for i, j, block in blocks(lines, r"Timer"):
            m = re.search(r"\brunning\s*:\s*([^;\n}]+)", block)
            if not m or m.group(1).strip() == "true":
                r(i + 1, "G11", "Timer must bind `running:` to a visible consumer (pollers pause without one)")
        for i, j, block in blocks(lines, r"Text"):
            t = re.search(r"\btext\s*:\s*(.+)", block)
            if t and re.search(r"formatDateTime|toFixed|Math\.round|percent|Percent|volume|count\b|Count\b|\+\s*\"%\"", t.group(1)) \
                    and "tabularFeatures" not in block:
                r(i + 1, "G14", "live number without `font.features: Tokens.typography.tabularFeatures` (tnum)")
        for i, j, block in blocks(lines, r"(?:M3IconButton|M3BarPill)"):
            if "accessibleName" not in block:
                r(i + 1, "G19", "icon-only control without accessibleName (and tooltip)")

    def run(self, targets):
        files = []
        for t in targets:
            p = Path(t)
            if not p.is_absolute():
                p = (Path.cwd() / p).resolve()
            if p.is_dir():
                keep_fixtures = "lint-fixtures" in p.parts
                files += sorted(x for x in p.rglob("*") if x.suffix in (".qml", ".mjs") and (keep_fixtures or "lint-fixtures" not in x.parts))
            elif p.exists():
                files.append(p)
        for f in files:
            self.lint_file(f)
        return files


def main(argv):
    if argv[1:2] == ["--self-test"]:
        fixtures = ROOT / "scripts" / "lint-fixtures"
        failures = 0
        files = sorted(x for x in fixtures.rglob("*") if x.suffix in (".qml", ".mjs"))
        for f in files:
            lint = Linter()
            lint.lint_file(f)
            got = sorted({rule for _, _, rule, _, sup in lint.findings if not sup})
            m = re.search(r"//\s*expect:\s*(.*)", f.read_text())
            want = sorted(m.group(1).split()) if m and m.group(1).strip() != "none" else []
            if got != want:
                failures += 1
                print(f"FAIL {f.relative_to(ROOT)}: expected {want or 'none'}, got {got or 'none'}")
        if failures:
            sys.exit(1)
        print(f"  ✓ lint-shell self-test: {len(files)} fixtures behave as declared")
        return
    targets = argv[1:] or [str(ROOT / "shell")]
    if not any(Path(t).exists() for t in targets):
        print("  ✓ lint-shell: no shell/ sources yet (nothing to lint)")
        return
    lint = Linter()
    files = lint.run(targets)
    errors = [f for f in lint.findings if not f[4]]
    for path, line, rule, msg, sup in lint.findings:
        print(f"{path}:{line}: {rule} {'(allowed) ' if sup else ''}{msg}")
    if errors:
        print(f"ERROR: {len(errors)} guardrail violation(s) in {len(files)} files")
        sys.exit(1)
    allowed = len(lint.findings)
    print(f"  ✓ lint-shell: {len(files)} files clean" + (f" ({allowed} reviewed suppressions)" if allowed else ""))


if __name__ == "__main__":
    main(sys.argv)
