# Mat Shell — Instructions for the Linux Session

This folder holds a Material 3 desktop shell for Quickshell (QML, Wayland, Hyprland). Tasks 1–10 (pure logic) are done and reviewed. Tasks 11–34 are built here, on Linux, one at a time, by an agent that follows Parts 1 and 2. The scripts in `scripts/` decide what the next task is, check the work, and stop the agent when a human is needed.

The agent does everything, including setting up the machine. The human only copies the folder and starts the agent:

```text
Read instruction.md in this folder and follow it exactly.
```

Start a **new** agent session after every checkpoint, and whenever the agent starts repeating itself; send the same first message.

- **Part 1** (agent): set up the machine. Every session, before any task.
- **Part 2** (agent): build the tasks.
- **Part 3** (human): what to do when the agent stops.

---

## Part 1 — Set Up the Machine (agent, every session)

1. Run `bash scripts/bootstrap-linux.sh`. It is safe to run every time: it skips what is already done. It:
   - installs every package in `packaging/dependencies.json` that is missing (pacman, plus the AUR through `paru` for `quickshell` and `matugen` when the repositories do not have them; it builds `paru` itself if needed);
   - downloads the fonts the shell ships (`python3 scripts/fetch-fonts.py`);
   - checks that this session runs inside Hyprland, then that every required tool works (`python3 scripts/check-deps.py --strict`).
2. If it prints `READY`, go to Part 2.
3. If your command runner timed out (building AUR packages can take several minutes), run it again. Do this at most three times.
4. If it prints `STOP (environment): …`, stop. Show the human exactly what it printed (the message says what they need to do), and end the session.

Never install, remove or configure system packages any other way, and never run `sudo` yourself: only this script does that.

---

## Part 2 — Agent Instructions

You implement the plan **one task at a time**. You never choose the task, plan ahead, or judge your own work done: the scripts do that.

### 2.1 The loop

1. Run `python3 scripts/next-task.py`.
2. Read everything it prints. It names the task number `N`, the files you may touch, the contract you must follow, the tests to write, and a **RULES** section. The RULES are mandatory.
3. Write the task's tests first. Copy the assertions from the brief **verbatim**.
4. Run `python3 scripts/task-gate.py N --red`. The tests must fail now (nothing is implemented yet).
5. Implement only the files the brief lists.
6. Run `python3 scripts/task-gate.py N`. If it reports a problem, fix the **cause** in the task's own files and run it again. When every check passes, it asks you to fill each `<fill …>` line in `docs/handoffs/task-NN.md` (Agent notes, Manual checks). Do the manual checks for real and record the results honestly, then run `python3 scripts/task-gate.py N` once more. It **seals** the task.
7. Go back to step 1.

Use `bash scripts/<name>.sh` for shell scripts (a copied folder may lose executable bits).

### 2.2 When to stop

`next-task.py` and `task-gate.py` exit with:

| Exit code / message | You do |
|---|---|
| `0` and a task brief | Work on that task (2.1) |
| `2` — `CHECKPOINT after Task N` | Run the command it prints (usually `bash scripts/checkpoint.sh N`). Then **stop**, show the human exactly what was printed, and end the session |
| `3` — `STOP (environment)` | Run `bash scripts/bootstrap-linux.sh` once (Part 1). If it prints `READY`, run `python3 scripts/next-task.py` again; otherwise stop as Part 1 says |
| `3` — any other `STOP (...)` | Do what the message says if it gives you one command to run, and nothing else. Then **stop**, show the human exactly what was printed, and end the session |

If you cannot finish a task without a decision (the spec is unclear, an API does not exist, a needed program is not declared, two documents disagree), run:

```bash
python3 scripts/task-gate.py N --stuck "<what you tried> / <what failed> / <what you need decided>"
```

then run the command it prints (`bash scripts/checkpoint.sh --blocked N`) and stop. Asking is always cheaper than guessing.

### 2.3 Rules that never change

1. **One task per seal.** Touch only the files the brief lists. No refactors of earlier tasks, no "improvements" elsewhere.
2. **Never** edit sealed tests, `scripts/lint-fixtures/`, `docs/lld/`, `design-system/`, `docs/state/`, `packaging/`, `scripts/`, or this file. Never seal, revert, or restore files yourself; only `task-gate.py` seals.
3. **Names come from `docs/lld/02-contracts.md`.** Do not add public members, functions, files, or parameters. Helpers are private and start with `_`.
4. **Quickshell and Qt APIs:** use only those in `docs/lld/03-guardrails.md` §5. For anything else, run `python3 scripts/qs-api.py <Type> <member>` first; "not found" means do not use it.
5. **Programs and paths:** a service may run only programs listed in `packaging/dependencies.json` (lint G22). Build every file path from `ConfigService.configDir`, `cacheDir` or `homeDir`; never write `~/`, `/home/`, or a repository path in shell code (lint G23).
6. **Never** weaken a test, skip a check, add `lint-allow` to an architecture rule, or work around a STOP. Fix the cause or ask with `--stuck`.
7. **No new dependencies** (npm packages, Qt modules, command-line tools), and no `sudo`: system packages come only from `bash scripts/bootstrap-linux.sh`.
8. Do not open `showcase/index.html`; it is a browser mock-up, not a QML reference.

### 2.4 Where things are (read only what the brief points you to)

| Need | File |
|---|---|
| What to do now | `python3 scripts/next-task.py` (always first) |
| Workflow, decisions, stop-and-ask | `docs/lld/README.md` |
| Exact names and signatures | `docs/lld/02-contracts.md` |
| Lint and review rules (G01–G23, R01–R25) | `docs/lld/03-guardrails.md` |
| How tests and the smoke run work | `docs/lld/04-testing.md` |
| The full task plan | `docs/superpowers/plans/2026-10-27-mat-shell-implementation-plan.md` |
| Visual and behavioural specs | `design-system/` (the brief cites the sections) |

### 2.5 Your final message in a session

When you stop, end with exactly this, filled in:

```text
Last sealed task: <N or none this session>
Stopped because: <CHECKPOINT / STOP (...) / --stuck / finished Task 34>
Script output:
<paste what next-task.py or task-gate.py printed, unchanged>
Archive written: <path printed by checkpoint.sh, or none>
```

---

## Part 3 — When the Agent Stops (human)

| It said | Do |
|---|---|
| `CHECKPOINT after Task N` | Bring the archive it wrote (`../mat-checkpoint-NN.tar.gz`, next to this folder) to the design machine for review. When the reviewed folder comes back, move the old folder aside, put the reviewed one in its place, and start a new agent session with the same first message |
| `STOP (blocked)` | Bring `../mat-blocked-NN.tar.gz` to the design machine; the question is in `docs/handoffs/BLOCKED.md` |
| `STOP (environment): … NOPASSWD: /usr/bin/pacman …` | Installing packages needs root, and an unattended agent cannot type a password. Run the one line it printed (once per machine), or install the listed packages yourself; then start a new session |
| `STOP (environment): … not running inside Hyprland …` | The agent can install Hyprland but cannot log in for you. Log in on a TTY, run `Hyprland`, open a terminal with Super+Q, `cd` into this folder, and start the agent there |
| Any other `STOP (environment)` | The message names what failed; `/tmp/mat-bootstrap.log` has the details |
| `STOP (history)` | Files changed outside the gate. Bring the folder (or `bash scripts/checkpoint.sh --blocked N`) to the design machine; do not fix it by hand |

Checkpoints come after Tasks **11, 15, 19, 22, 26, 29, 31, 34**. The first one, after Task 11, also records the install-readiness probes (fonts, packages, config discovery), so expect it soon.

Details for every case: `docs/lld/06-unattended-runbook.md`.
