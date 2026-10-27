#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# ripgrep when available, grep otherwise (a missing rg must never turn these checks into silent passes)
search() { if command -v rg >/dev/null; then rg -n "$@"; else grep -rnE "$@"; fi; }

echo "=== Verifying Material 3 Expressive Quickshell Design System ==="

# 1. Verify JSON Token Schema Validity
echo "[1/7] Validating W3C m3-tokens.json..."
python3 -m json.tool design-system/tokens/m3-tokens.json > /dev/null
echo "  ✓ design-system/tokens/m3-tokens.json is valid JSON"

# 2. Verify QML Singleton Inventory & qmldir Registration
echo "[2/7] Checking Quickshell QML Singleton Module..."
QML_FILES=(
  "Tokens.qml"
  "ColorTokens.qml"
  "MotionTokens.qml"
  "ShapeTokens.qml"
  "TypographyTokens.qml"
  "MetricTokens.qml"
)
for qml in "${QML_FILES[@]}"; do
  test -f "design-system/tokens/qml/$qml"
  grep -q "pragma Singleton" "design-system/tokens/qml/$qml"
  grep -q "$qml" "design-system/tokens/qml/qmldir"
done
echo "  ✓ All 6 QML singletons exist, declare pragma Singleton, and are registered in qmldir"

# 3. Verify Foundations & Primitives Inventory
echo "[3/7] Checking Foundations (01..06) and Primitives (01..04)..."
FOUNDATION_FILES=(
  "design-system/foundations/01-color-and-surfaces.md"
  "design-system/foundations/02-typography-and-iconography.md"
  "design-system/foundations/03-motion-and-morphing.md"
  "design-system/foundations/04-interaction-states-and-input.md"
  "design-system/foundations/05-wayland-layershell-spatial.md"
  "design-system/foundations/06-adaptive-desktop-modes.md"
)
for f in "${FOUNDATION_FILES[@]}"; do
  test -s "$f"
done

PRIMITIVE_FILES=(
  "design-system/primitives/01-surfaces-and-containers.md"
  "design-system/primitives/02-buttons-and-chips.md"
  "design-system/primitives/03-controls-sliders-and-inputs.md"
  "design-system/primitives/04-menus-popovers-and-tooltips.md"
)
for p in "${PRIMITIVE_FILES[@]}"; do
  test -s "$p"
done
echo "  ✓ All 6 Foundation specs and 4 Primitive specs are present and non-empty"

# 4. Verify all 16 Shell Components & Mandatory 8-Part Agent Contract
echo "[4/7] Verifying all 16 Shell Component Specs and 8-section agent contracts..."
COMPONENT_FILES=(
  "design-system/shell-components/01-bar-system.md"
  "design-system/shell-components/02-bar-widgets.md"
  "design-system/shell-components/03-control-center.md"
  "design-system/shell-components/04-notifications.md"
  "design-system/shell-components/05-calendar-and-weather.md"
  "design-system/shell-components/06-media-player-popover.md"
  "design-system/shell-components/07-osd-huds.md"
  "design-system/shell-components/08-app-and-command-launcher.md"
  "design-system/shell-components/09-workspace-and-window-overview.md"
  "design-system/shell-components/10-lock-screen.md"
  "design-system/shell-components/11-power-and-session-menu.md"
  "design-system/shell-components/12-polkit-authentication-dialog.md"
  "design-system/shell-components/13-screen-capture-and-recording.md"
  "design-system/shell-components/14-wallpaper-and-theme-picker.md"
  "design-system/shell-components/15-desktop-widgets-layer.md"
  "design-system/shell-components/16-settings.md"
)

for c in "${COMPONENT_FILES[@]}"; do
  test -s "$c"
  grep -q "## 1. Purpose & Wayland Layer Config" "$c"
  grep -q "## 2. Adaptive Dual-Mode Behavior" "$c"
  grep -q "## 3. Visual Anatomy" "$c"
  grep -q "## 4." "$c"
  grep -q "## 5. Interactive State Matrix" "$c"
  grep -q "## 6. Motion & Morph Choreography" "$c"
  grep -q "## 7. Quickshell Service & IPC Bindings" "$c"
  grep -q "## 8. Canonical QML Reference Skeleton" "$c"
done
echo "  ✓ All 16 Shell Component specs pass the 8-section contract check"

# 5. Verify Interactions & Zero Placeholders
echo "[5/7] Verifying Interaction Specs & Zero Placeholder Policy..."
INTERACTION_FILES=(
  "design-system/interactions/01-choreography-and-morphing.md"
  "design-system/interactions/02-keyboard-navigation-and-submaps.md"
  "design-system/interactions/03-quickshell-service-architecture.md"
)
for i in "${INTERACTION_FILES[@]}"; do
  test -s "$i"
done

if search "\b(TBD|TODO|FIXME|implement later)\b" AGENTS.md design-system/ showcase/; then
  echo "ERROR: Found forbidden placeholder in design-system!"
  exit 1
fi
echo "  ✓ Zero placeholders (TBD/TODO/FIXME) across AGENTS.md, design-system/, and showcase/"

# 6. Verify the Usability & Accessibility Contract
echo "[6/7] Verifying Usability & Accessibility Contract..."
require() {
  local pattern="$1" file="$2"
  if ! grep -q -- "$pattern" "$file"; then
    echo "ERROR: '$pattern' missing from $file"
    exit 1
  fi
}
forbid() {
  local pattern="$1"
  if search -F -- "$pattern" AGENTS.md design-system/; then
    echo "ERROR: Regression '$pattern' reintroduced"
    exit 1
  fi
}

for switch in reducedMotion reducedTransparency highContrast textScale keyboardModality; do
  require "property .* $switch" design-system/tokens/qml/Tokens.qml
done
require "spatialMotionEnabled" design-system/tokens/qml/MotionTokens.qml
require "decorativeMotionEnabled" design-system/tokens/qml/MotionTokens.qml
require "\"rounded_triangle\"" design-system/tokens/qml/ShapeTokens.qml
require "polygonSafeContentRatio" design-system/tokens/qml/ShapeTokens.qml
require "minPointerTarget" design-system/tokens/qml/MetricTokens.qml
require "Pointer Accelerator Safety Rules" design-system/foundations/04-interaction-states-and-input.md
require "Edge Hit Extension" design-system/foundations/04-interaction-states-and-input.md
require "Accessibility Modes" design-system/foundations/04-interaction-states-and-input.md
require "Wallpaper Legibility Guard" design-system/foundations/01-color-and-surfaces.md
require "Accessible.name" design-system/primitives/01-surfaces-and-containers.md
require "Tokens.keyboardModality" design-system/primitives/01-surfaces-and-containers.md
require "securityModalActive" design-system/interactions/01-choreography-and-morphing.md
require "widget_peek" design-system/interactions/01-choreography-and-morphing.md
require "toggleWidgetPeek" design-system/interactions/02-keyboard-navigation-and-submaps.md
require "focusBar" design-system/interactions/02-keyboard-navigation-and-submaps.md

forbid "Close focused window on that workspace"
forbid "Tokens.widgetPeekActive"
forbid "duotoneOverlapRatio"
forbid "spacing: -14"
forbid "15s countdown"
forbid "60s countdown"
require "holdToConfirmMs" design-system/tokens/qml/MotionTokens.qml
require "property bool confirmByHold" design-system/tokens/qml/Tokens.qml
require "M3HoldToConfirm" design-system/primitives/02-buttons-and-chips.md
require "M3HoldToConfirm" design-system/shell-components/11-power-and-session-menu.md
require "Hold to confirm, never confirm-twice" design-system/foundations/04-interaction-states-and-input.md

# Configurable bars: no fixed Topbar/Dock API may come back; every surface positions relative to BarService
for legacy in isThreeIslandBottom barLayout topbarStyle dockStyle preferredDockStyle setBarLayout \
              topbarHeight topbarPillHeight dockHeight dockIconSize islandHeight islandBottomMargin barStripHeight \
              01-topbar.md 02-bottom-bar-dock.md; do
  forbid "$legacy"
done
if search 'bar\.margin\b' AGENTS.md design-system/; then
  echo "ERROR: single bar.margin reintroduced (bars use marginHorizontal / marginVertical)"
  exit 1
fi
require "property bool expressiveSprings" design-system/tokens/qml/Tokens.qml
require "overshootEnabled" design-system/tokens/qml/MotionTokens.qml
require "maxBarsPerEdge" design-system/tokens/qml/MetricTokens.qml
require "popoverOriginEdge" design-system/interactions/01-choreography-and-morphing.md
require "openSettings" design-system/interactions/01-choreography-and-morphing.md
require "openSettings" design-system/interactions/02-keyboard-navigation-and-submaps.md
require "BarService.regions" design-system/foundations/05-wayland-layershell-spatial.md
require "ExclusionMode.Ignore" design-system/foundations/05-wayland-layershell-spatial.md
require "Origin-Edge Placement" design-system/primitives/04-menus-popovers-and-tooltips.md
require "barEdge" design-system/primitives/02-buttons-and-chips.md
require "Configuration Guardrails" design-system/shell-components/01-bar-system.md
require "FloatingWindow" design-system/shell-components/16-settings.md
python3 - <<'PY'
import json, re, sys
tokens = json.load(open("design-system/tokens/m3-tokens.json"))
bars = tokens["modes"]["bars"]
catalog = open("design-system/shell-components/02-bar-widgets.md").read()
registry = catalog[catalog.index("### 1.1"):catalog.index("### 1.2")]
documented = set(re.findall(r"^\| `(\w+)` \|", registry, re.M)) - {"type"}  # "type" is the registry table's header cell
errors = []
if set(bars["widgetTypes"]) != documented:
    errors.append(f"widgetTypes vs SC-02 registry differ: {sorted(set(bars['widgetTypes']) ^ documented)}")
for name, preset in bars["presets"].items():
    edges = {}
    for bar in preset["bars"]:
        if bar["position"] not in bars["positions"] or bar["mode"] not in bars["modes"] or bar["visibility"] not in bars["visibility"]:
            errors.append(f"preset {name}/{bar['id']}: invalid position, mode, or visibility")
        vertical = bar["position"] in ("left", "right")
        lo, hi = bars["guardrails"]["thicknessPx"]["vertical" if vertical else "horizontal"]
        if not lo <= bar["thickness"] <= hi:
            errors.append(f"preset {name}/{bar['id']}: thickness {bar['thickness']} outside {lo}..{hi}")
        if "margin" in bar:
            errors.append(f"preset {name}/{bar['id']}: legacy single 'margin' (use marginHorizontal / marginVertical)")
        for axis in ("horizontal", "vertical"):
            key = "margin" + axis.capitalize()
            mlo, mhi = bars["guardrails"]["marginPx"][axis]
            if key not in bar or not mlo <= bar[key] <= mhi:
                errors.append(f"preset {name}/{bar['id']}: {key} missing or outside {mlo}..{mhi}")
        edges[bar["position"]] = edges.get(bar["position"], 0) + 1
        for section, widgets in bar["sections"].items():
            if section not in bars["sections"]:
                errors.append(f"preset {name}/{bar['id']}: unknown section {section}")
            unknown = [w for w in widgets if w not in bars["widgetTypes"]]
            if unknown:
                errors.append(f"preset {name}/{bar['id']}: unknown widgets {unknown}")
    if any(n > bars["guardrails"]["maxBarsPerEdge"] for n in edges.values()):
        errors.append(f"preset {name}: more than maxBarsPerEdge bars on one edge")
if errors:
    print("ERROR: " + "\n       ".join(errors))
    sys.exit(1)
print(f"  ✓ {len(bars['presets'])} bar presets use only catalogued widgets ({len(documented)}) within guardrails")
PY
# Widget options contract (SC-02 §1.2): schema-driven, rendered generically by Settings
require "WidgetOptionsForm" design-system/shell-components/16-settings.md
require "optionsSchema" design-system/interactions/03-quickshell-service-architecture.md
forbid "options\.format"
python3 - <<'PY'
import json, re, sys
bars = json.load(open("design-system/tokens/m3-tokens.json"))["modes"]["bars"]
catalog = open("design-system/shell-components/02-bar-widgets.md").read()
kinds = set(bars["widgetOptionKinds"])
schemas = {k: v for k, v in bars["widgetOptions"].items() if not k.startswith("$")}
# §1.1 registry rows: | `type` | Name | Function | Opens | Customisable | ...
registry = catalog[catalog.index("### 1.1"):catalog.index("### 1.2")]
customisable = {m.group(1) for m in re.finditer(r"^\| `(\w+)` \|[^|]*\|[^|]*\|[^|]*\| Yes \|", registry, re.M)}
errors = []
if set(schemas) != customisable:
    errors.append(f"widgetOptions vs SC-02 §1.1 'Customisable: Yes' differ: {sorted(set(schemas) ^ customisable)}")
for t in ("privacy", "recording", "power"):
    if t in schemas:
        errors.append(f"{t}: security/core widgets must not declare options (E4)")
for wtype, fields in schemas.items():
    if wtype not in bars["widgetTypes"]:
        errors.append(f"widgetOptions.{wtype}: unknown widget type")
    keys = [f.get("key") for f in fields]
    if len(keys) != len(set(keys)):
        errors.append(f"{wtype}: duplicate option keys")
    if len({f["group"] for f in fields if "group" in f}) > 3:
        errors.append(f"{wtype}: more than 3 groups")
    if f"**`{wtype}`**" not in catalog:
        errors.append(f"{wtype}: missing from the SC-02 §1.3 options catalog")
    for f in fields:
        where = f"{wtype}.{f.get('key')}"
        missing = [p for p in ("key", "kind", "label", "default") if p not in f]
        if missing:
            errors.append(f"{where}: missing {missing}"); continue
        if f["kind"] not in kinds:
            errors.append(f"{where}: unknown kind {f['kind']}")
        if f"`{f['key']}`" not in catalog:
            errors.append(f"{where}: key not documented in SC-02 §1.3")
        if len(f["label"].split()) > 3 or f["label"][0] != f["label"][0].upper():
            errors.append(f"{where}: label must be sentence case, at most 3 words")
        if f.get("orientations", "both") not in ("both", "horizontal", "vertical"):
            errors.append(f"{where}: invalid orientations")
        d = f["default"]
        if f["kind"] in ("choice", "multiChoice"):
            values = [c["value"] for c in f.get("choices", [])]
            if not values:
                errors.append(f"{where}: choices required")
            if f["kind"] == "choice" and d not in values:
                errors.append(f"{where}: default {d!r} not a choice")
            if f["kind"] == "multiChoice":
                if not isinstance(d, list) or any(v not in values for v in d):
                    errors.append(f"{where}: default must be a list of choices")
                elif not f.get("min", 0) <= len(d) <= f.get("max", len(values)):
                    errors.append(f"{where}: default outside min/max")
        elif f["kind"] == "number":
            if "min" not in f or "max" not in f or not f["min"] <= d <= f["max"]:
                errors.append(f"{where}: number needs min/max containing the default")
        elif f["kind"] == "toggle" and not isinstance(d, bool):
            errors.append(f"{where}: toggle default must be a bool")
        elif f["kind"] in ("text", "format"):
            if not isinstance(d, str) or "maxLength" not in f or len(d) > f["maxLength"]:
                errors.append(f"{where}: text/format need maxLength and a string default within it")
        elif f["kind"] == "appList" and not isinstance(d, list):
            errors.append(f"{where}: appList default must be a list")
        cond = f.get("visibleWhen")
        if cond:
            ops = [o for o in ("equals", "notEquals", "includes") if o in cond]
            if cond.get("key") not in keys or cond.get("key") == f["key"] or len(ops) != 1:
                errors.append(f"{where}: visibleWhen needs another key of this widget and exactly one of equals/notEquals/includes")
showcase = re.search(r"const WIDGET_OPTIONS = \{\n(.*?)\n    \};", open("showcase/index.html").read(), re.S)
mirrored = {k: json.loads(v) for k, v in re.findall(r"^\s+(\w+): (\[.*\]),?$", showcase.group(1), re.M)} if showcase else {}
if mirrored != schemas:
    errors.append("showcase WIDGET_OPTIONS drifted from m3-tokens.json modes.bars.widgetOptions (regenerate it from the JSON)")
for wtype in bars.get("widgetOptionMigrations", {}):
    if wtype not in schemas:
        errors.append(f"widgetOptionMigrations.{wtype}: widget has no options")
if errors:
    print("ERROR: " + "\n       ".join(errors))
    sys.exit(1)
print(f"  ✓ {len(schemas)} customisable widgets declare {sum(map(len, schemas.values()))} valid option fields")
PY
echo "  ✓ Accessibility modes, input safety, polygon catalog, configurable bars, and shell-state protections are in place"

# 7. Verify the matugen pipeline (template ↔ baseline ↔ ColorTokens adapter parity, non-interactive config)
echo "[7/7] Verifying matugen pipeline..."
forbid "matugen-template.toml"
python3 - <<'PY'
import json, re, sys, tomllib

base_dir = "design-system/tokens/matugen"
cfg = tomllib.load(open(f"{base_dir}/config.toml", "rb"))
errors = []
if cfg["config"].get("source_color_index") != 0:
    errors.append("config.toml must set source_color_index = 0 (matugen 4.x fails without a terminal otherwise)")
if "wallpaper" in cfg["config"]:
    errors.append("config.toml must not contain [config.wallpaper]; the shell sets the wallpaper")
if not cfg.get("templates"):
    errors.append("config.toml defines no templates")

# Role names matugen can render (material-colors Scheme roles + source_color + configured custom colours)
scheme_roles = """primary on_primary primary_container on_primary_container inverse_primary primary_fixed primary_fixed_dim
on_primary_fixed on_primary_fixed_variant secondary on_secondary secondary_container on_secondary_container secondary_fixed
secondary_fixed_dim on_secondary_fixed on_secondary_fixed_variant tertiary on_tertiary tertiary_container on_tertiary_container
tertiary_fixed tertiary_fixed_dim on_tertiary_fixed on_tertiary_fixed_variant error on_error error_container on_error_container
surface_dim surface surface_tint surface_bright surface_container_lowest surface_container_low surface_container
surface_container_high surface_container_highest on_surface on_surface_variant outline outline_variant inverse_surface
inverse_on_surface surface_variant background on_background shadow scrim""".split()
valid = set(scheme_roles) | {"source_color"}
for name in cfg["config"].get("custom_colors", {}):
    valid |= {name, f"on_{name}", f"{name}_container", f"on_{name}_container"}

tpl = open(f"{base_dir}/theme.json.tpl").read()
expressions = re.findall(r"\{\{colors\.([a-z_]+)\.(dark|light|default)\.hex\}\}", tpl)
unknown = sorted({n for n, _ in expressions if n not in valid})
if unknown:
    errors.append(f"theme.json.tpl uses keywords matugen does not emit: {unknown}")

rendered = json.loads(re.sub(r"\{\{[^}]+\}\}", "#000000", tpl))
baseline = json.load(open(f"{base_dir}/theme.baseline.json"))
qml = open("design-system/tokens/qml/ColorTokens.qml").read()
adapter = qml[qml.index("JsonAdapter"):qml.index("// matugen writes the file")]
dark_part, light_part = adapter.split("property JsonObject light")
adapter_dark = set(re.findall(r"property string (\w+):", dark_part.split("property JsonObject dark")[1]))
adapter_light = set(re.findall(r"property string (\w+):", light_part))
for mode, adapter_keys in (("dark", adapter_dark), ("light", adapter_light)):
    if set(rendered[mode]) != set(baseline[mode]) or set(rendered[mode]) != adapter_keys:
        errors.append(f"{mode}: template, baseline, and ColorTokens adapter keys differ")
    for role in rendered[mode]:
        if f"readonly property color {role}:" not in qml:
            errors.append(f"ColorTokens is missing a readonly binding for '{role}'")

if errors:
    print("ERROR: " + "\n       ".join(errors))
    sys.exit(1)
print(f"  ✓ matugen config is non-interactive; {len(rendered['dark'])} roles per polarity match across template, baseline, and ColorTokens")
PY
echo "=== ALL CHECKS PASSED SUCCESSFULLY ==="
