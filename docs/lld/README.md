# Mat Shell — Low-Level Design (LLD) for Code Generation

> **Audience**: AI coding agents (including smaller models) and human reviewers who turn the design system in `design-system/` into a running Quickshell desktop shell under `shell/`.
> **Status**: Normative. Where this LLD and a spec disagree, follow the precedence rule in §3.

The design system says **what** every surface looks like and does. This LLD says **how to build it**. It fixes the source tree, module boundaries, file names, function signatures, test commands, and the guardrails a reviewer will enforce. The goal is that two different agents given the same task card produce code with the same shape.

---

## 1. Documents

| File | Read it when | Contains |
|---|---|---|
| `README.md` (this file) | Always, first | Workflow, precedence, stop-and-ask rules, task card template |
| `01-architecture.md` | Always, before your first task | Source tree, module and import rules, runtime composition, window/layer matrix, name maps, config files, IPC surface |
| `02-contracts.md` | When your task names a module | Exact APIs: pure `lib/*.mjs` functions, service singletons, `ShellState`, primitives, bar widget and surface contracts |
| `03-guardrails.md` | Always, before you write code and again before you hand in | Lint-enforced rules G01–G20, review-only rules R01–R25, spec-conflict resolutions C01–C20, verified Quickshell API list, definition of done |
| `04-testing.md` | When you write tests or verify | Test tiers, file conventions, fakes, smoke script, manual matrix |
| `../superpowers/plans/2026-10-27-mat-shell-implementation-plan.md` | To pick and execute a task | 34 ordered tasks with files, interfaces, test cases, and commands |

Executable guardrails that ship with the LLD:

| Tool | Command | Gate |
|---|---|---|
| Design-system verifier | `./scripts/verify-design-system.sh` | Must pass before every commit (it also runs the next two) |
| QML/JS linter | `python3 scripts/lint-shell.py [paths]` | Zero unsuppressed findings; `--self-test` proves the rules |
| Unit tests | `node --test tests/lib/` | All pass; Node ≥ 22, no npm dependencies |
| Generated data | `python3 scripts/gen-shell-data.py --check` | Generated `shell/lib/generated/*.mjs` matches `m3-tokens.json` (created in Task 2) |
| Launcher | `./scripts/run-shell.sh` | Starts the shell with the module import path (validated on the target in Task 1) |
| Runtime smoke (Linux target only) | `./scripts/smoke-shell.sh` | No QML errors in the log after replaying `tests/smoke/ipc-script.txt` (validated in Task 1) |

---

## 2. Workflow for One Task

1. **Pick** the lowest-numbered unchecked task in the plan whose `Depends on` tasks are done. Never start two tasks in one change.
2. **Load context** in this order and nothing else: this README → `01-architecture.md` → the `02-contracts.md` sections your task names → the spec files your task names (only the cited sections) → `03-guardrails.md`.
3. **Write the failing test first** (Tier 1 for `lib/`, Tier 3 smoke step for QML; see `04-testing.md`). Run it and see it fail for the right reason.
4. **Implement** only the files listed under the task's `Files`. If you need another file, stop (§4).
5. **Verify**: run the task's commands, then `./scripts/verify-design-system.sh`. Paste the passing output in your hand-off.
6. **Self-review** against `03-guardrails.md` §6 (definition of done) and tick each line.
7. **Commit** with the task's message (`feat(<scope>): …`), one task per commit.

Hand-off message format (the reviewer reads only this and the diff):

```text
Task: <N> <name>
Files: <created/modified list>
Tests: <command> → <N passed>
Verify: ./scripts/verify-design-system.sh → ALL CHECKS PASSED
Lint suppressions: <count> (each line: path:line rule reason)
Spec conflicts met: <C-ids or "none">; new ones: <description or "none">
Not done / follow-ups: <list or "none">
```

---

## 3. Precedence (when sources disagree)

1. `03-guardrails.md` (G, R and C rules)
2. `02-contracts.md` (signatures and names)
3. `01-architecture.md` (placement and wiring)
4. Spec prose and tables in `design-system/**` §1–§7
5. Spec §8 "Canonical QML Reference Skeleton" code blocks. These are **illustrative**. They show shape and token usage, not final file boundaries. For example, a skeleton that runs `Process` inside a surface is overruled by G08: move the call into the named service.
6. `showcase/index.html`. It is a visual reference only; never port HTML/CSS/JS idioms from it (G16).

If two sources at the **same** level disagree and no C-rule covers it, stop (§4).

---

## 4. Stop and Ask (do not guess)

Stop, write the question in your hand-off, and leave the task unfinished when:

- You need a Quickshell or Qt API that is not in the verified list (`03-guardrails.md` §5) and you cannot cite its documentation page.
- You need a file, singleton, property, or IPC function that no contract defines.
- A spec value has no token and appears in more than one file (one file may use `// lint-allow G03: <spec §ref>`; two files need a new token in `design-system/tokens/qml/MetricTokens.qml` plus `m3-tokens.json`, which is its own task).
- Two same-level sources conflict and no C-rule resolves it.
- A test can only pass by weakening a guardrail, editing a fixture's `expect:` line, or deleting an assertion.
- The change would touch `design-system/tokens/qml/*` (the shell copy under `shell/MatShell/Tokens/` is generated from it; never hand-edit the copy).

---

## 5. Key Decisions in This LLD

| # | Decision | Why |
|---|---|---|
| D1 | All decision logic lives in pure ES modules `shell/lib/*.mjs`; QML files only bind and render | Testable with `node --test` on any machine; small models get logic right more often when it has unit tests |
| D2 | Four QML modules (`MatShell.Tokens`, `MatShell.Services`, `MatShell.State`, `MatShell.Primitives`); bar and surfaces are directory imports | Matches the `import MatShell.Tokens` used by every spec skeleton. Quickshell creates a plain `QQmlEngine`, so Qt's standard `QML_IMPORT_PATH=<repo>/shell` (set by `scripts/run-shell.sh`) resolves them. The config is installed as `~/.config/quickshell/mat-shell` and run with `qs -c mat-shell`; IPC is `qs -c mat-shell ipc call …` |
| D3 | Every external process, file, socket, or D-Bus call is owned by exactly one service | One place per side effect; surfaces stay declarative and testable |
| D4 | Schema data (widget options, bar presets) is generated from `m3-tokens.json` into `shell/lib/generated/` | One source of truth; a `--check` mode fails CI when the copy drifts |
| D5 | Non-bar layer surfaces use `exclusionMode: ExclusionMode.Ignore` and position themselves with `BarService.insets()` | Resolves the inconsistent `exclusiveZone: 0` vs `-1` values across specs (C01) |
| D6 | Keybinds: Hyprland uses `GlobalShortcut { appid: "mat-shell" }` (`bind = …, global, mat-shell:<actionId>`); other compositors and scripts use `qs ipc call shell <fn>` | One action-id list drives both paths (C09) |
| D7 | Target platform for runtime verification is Linux + Hyprland with **Quickshell ≥ 0.3.0** (tested on 0.3.2) and Qt ≥ 6.8; Niri/Sway support goes through `CompositorService` adapters and is verified second | Hyprland is the spec's primary target; Polkit needs Quickshell 0.3.0 and `Accessible.announce` needs Qt 6.8 |
