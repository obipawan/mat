# LLD 06 — Unattended Runbook (one agent on the Linux target, no git)

For running the plan with a single, smaller model on another machine, with no reviewer in the loop and **no git**: the project moves between machines as a plain folder copy. The scripts take every procedural decision away from the agent. It writes tests and code; the scripts decide what is next, run every check, write the hand-off, and seal the task. A stronger reviewer looks at the work only at checkpoints.

Everything the scripts know travels inside the folder:

| Where | What |
|---|---|
| `docs/superpowers/plans/…-implementation-plan.md` | Which tasks are done (their checkboxes, ticked by the gate) |
| `docs/state/` (`scripts/matstate.py`) | The project history: `manifest.json` (hash of every file at the last seal), `log.jsonl` (one hash-chained entry per seal), `objects/` (every sealed file version), `gate/` (red-run records, failure counters) |
| `docs/handoffs/` | Gate receipts `task-NN.md`, `BLOCKED.md`, the reviewer's `checkpoint-NN.md` and `review-task-NN.md` |
| `docs/evidence/task-NN/` | Screenshots for UI tasks |

**Copy the whole folder, every time.** If `docs/state/` is missing, `next-task.py` stops.

---

## 1. What the Scripts Enforce

| Risk with a smaller model | Guardrail | Where |
|---|---|---|
| Loses track of where it is after a long session or a restart | `next-task.py` derives the state from the plan and `docs/state/`, never from memory, and prints one task's brief | `scripts/next-task.py` |
| Skips tests-first, or skips tasks | The gate needs a `--red` run first, and only accepts the next task in order | `scripts/task-gate.py` |
| Claims checks passed that did not | The gate writes the hand-off (`docs/handoffs/task-NN.md`) from real command output; the agent fills only notes and manual results | `task-gate.py` |
| Edits files outside the task, between or during tasks | Every file is hashed at each seal. `next-task.py` and the gate compare the folder with the last seal and stop on changes outside the task | `matstate.py`, `check-scope.py` |
| Hand-edits the history to hide something | The log is hash-chained and the manifest is tied to the last entry; `matstate.py verify` (run by `next-task.py`, the gate and the verifier) stops on any mismatch | `matstate.py` |
| Weakens tests or guardrails | Test lock (checked against the sealed lock), plan-assertion check, lint G01–G23 | `check-scope.py` (inside the gate) |
| Invents Quickshell APIs | `qs-api.py` answers from the installed `*.qmltypes`; the rules say "not found → do not use it" | `scripts/qs-api.py` |
| Flails: repeated edits that do not fix the cause | After 5 failed gate runs for one task the gate writes `docs/handoffs/BLOCKED.md`; both scripts then refuse to continue | `task-gate.py` |
| Guesses when it should ask | `task-gate.py N --stuck "<question>"` blocks on purpose | `task-gate.py` |
| Drifts over many tasks | Work stops at the end of every phase until the reviewed folder comes back with `docs/handoffs/checkpoint-NN.md` | `next-task.py`, `scripts/checkpoint.sh` |
| Missing tools, wrong versions | `next-task.py` checks Python, Node, Linux, Quickshell ≥ 0.3.0, the Hyprland session, matugen, grim and the shipped fonts before the task | `next-task.py` |
| Runs an undeclared program or hard-codes a path | Lint G22 (`packaging/dependencies.json`) and G23 (no repository or home paths; only `ConfigService` reads `HOME`/`XDG_*`) | `lint-shell.py` (inside the gate) |
| A copy drops executable bits | `next-task.py` restores them, and every command runs scripts through `bash` | `next-task.py` |

Checkpoints (the last task of each phase): **10, 11, 15, 19, 22, 26, 29, 31, 34**.

The guardrails catch drift and shortcuts, not a determined forger: an agent that rewrote `docs/state/` consistently could hide work. The checkpoint review (§4) is the backstop, which is why reviewers verify the history first.

---

## 2. Set Up the Linux Machine

The agent sets up the machine itself (`instruction.md` Part 1): `bash scripts/bootstrap-linux.sh` installs every package in `packaging/dependencies.json` (pacman, plus `paru` for AUR packages, built if missing), fetches the shipped fonts, checks the Hyprland session and runs `check-deps.py --strict`. It is idempotent and writes nothing inside the folder (log: `/tmp/mat-bootstrap.log`).

The human:
1. Copies the whole `mat/` folder to the machine (any method that keeps it intact: `scp -r`, `rsync -a`, a `.tar.gz`, a USB stick). Git is not needed.
2. Starts the agent in the folder with `Read instruction.md in this folder and follow it exactly.` **Prompt S** (§6) is the longer alternative for tools that do not read files on request.

Two things the script cannot do for an unattended agent, so it stops and says so:
- **Root without a password.** If `sudo -n pacman` is not allowed, it prints a one-line sudoers rule (`NOPASSWD: /usr/bin/pacman` for this user; root-equivalent, delete it when the project is done) or the package list to install by hand.
- **Logging in to Hyprland.** If the session is not inside Hyprland, it installs Hyprland and stops; the human logs in, opens a terminal (Super+Q, kitty) and starts the agent there.

---

## 3. The Agent Loop

```text
python3 scripts/next-task.py           → read the brief (card, phase notes, contract excerpt, rules)
write the tests                          (copy the card's assertions verbatim)
python3 scripts/task-gate.py N --red   → must fail
implement the card's Files
python3 scripts/task-gate.py N         → fix what it reports; then fill docs/handoffs/task-NN.md notes; rerun → seals
python3 scripts/next-task.py           → next task, a checkpoint (exit 2), or a stop (exit 3)
```

The agent ends the session on exit code 2 or 3 and tells you what the script printed.

---

## 4. Checkpoints and Review (human + a stronger session)

At a checkpoint the agent runs `bash scripts/checkpoint.sh N`, which writes `../mat-checkpoint-NN.tar.gz` next to the folder.

1. Carry the archive to the review machine and unpack it in a fresh place (never on top of an older copy, so deleted files stay deleted):
   ```bash
   mkdir -p ~/review && tar -xzf mat-checkpoint-NN.tar.gz -C ~/review && cd ~/review/mat
   ```
2. Run `python3 scripts/matstate.py verify` and `python3 scripts/matstate.py log`. Then ask a stronger session to review each task sealed since the last checkpoint with **Prompt B** (`05-agent-prompts.md` §3): the receipt `docs/handoffs/task-NN.md` is the hand-off, `python3 scripts/matstate.py show N` is the diff, and screenshots are in `docs/evidence/task-NN/`.
3. For every rejected task, either fix it directly (small issues), or follow `05-agent-prompts.md` §4: write `docs/handoffs/review-task-NN.md` and revert the task with `python3 scripts/matstate.py revert N --owner "<who>: <reason>"`. Revert from the newest task back. The task comes up again, and `next-task.py` prints the review notes in its brief.
4. Approve: write `docs/handoffs/checkpoint-NN.md` (`Approved by: <who> — Tasks a–b reviewed; notes`).
5. Seal the review work as the design owner:
   ```bash
   python3 scripts/matstate.py seal --owner "<reviewer>: checkpoint NN review"
   ```
6. Carry the reviewed folder back: archive it (`tar -czf mat-reviewed-NN.tar.gz mat`), and on Linux replace the old folder with it. Move the old one aside rather than merging into it.

Only a reviewer writes `checkpoint-*` and `review-task-*` files, and only owner seals may change them; `next-task.py` stops when a task seal did.

---

## 5. When the Agent Stops

| It printed | Meaning | You do |
|---|---|---|
| `CHECKPOINT after Task N` (exit 2) | Phase finished | §4 |
| `STOP (blocked)` | 5 failed gate runs, or the agent asked a question with `--stuck` | The agent ran `bash scripts/checkpoint.sh --blocked N` (archive `../mat-blocked-NN.tar.gz`, unsealed work included). Review `docs/handoffs/BLOCKED.md`, the receipt, and `python3 scripts/matstate.py diff`. Decide in a review session: answer in `docs/handoffs/review-task-NN.md`, fix the contract, or finish the task. Delete `BLOCKED.md`, seal as owner, carry the folder back |
| `STOP (history)` | `docs/state/` does not match the folder, or files outside the task changed | Review with `python3 scripts/matstate.py status` / `diff`; keep the changes (owner seal) or restore the files from the last reviewed archive |
| `STOP (environment)` | A tool is missing | Install it |

Do not ask the agent to "work around" a stop. Every stop is cheaper to fix in review than after ten more tasks build on it.

The design owner seals every change they make by hand (`python3 scripts/matstate.py seal --owner "…"`), including edits on the design machine. An unsealed owner edit looks like a change outside the task, and the agent will stop on it.

---

## 6. Prompt S — Single-Agent Session

Paste this as the first message of every session on the Linux machine. Start a new session after every checkpoint, and whenever the agent starts repeating itself.

```text
You are implementing the Mat Shell plan in this folder, one task at a time, on the Linux target.

0. Run: bash scripts/bootstrap-linux.sh. If it does not end with READY, show me what it printed and stop.
   Never run sudo or install packages any other way.
1. Run: python3 scripts/next-task.py
2. Do exactly what it prints, for that one task. Its RULES section is mandatory.
3. Use only the scripts it names to test and finish a task. python3 scripts/task-gate.py N seals the
   task; never seal, revert, or restore files yourself, and never edit docs/state/.
4. When a check fails, fix the cause in the task's own files. Never edit tests that are already sealed,
   lint fixtures, docs/lld/, design-system/, or scripts/ that the task does not list.
5. Before using any Quickshell or Qt API that is not listed in docs/lld/03-guardrails.md §5, run
   python3 scripts/qs-api.py <Type> <member>. If it says "not found", do not use it.
6. If you cannot finish a task without a decision, run
   python3 scripts/task-gate.py N --stuck "<what you tried, what failed, what you need decided>" and stop.
7. After each seal, run python3 scripts/next-task.py again. If it exits with code 2 or 3, do what it
   says (it may ask you to run bash scripts/checkpoint.sh), then stop working, show me exactly what it
   printed, and end the session.

Do not plan ahead across tasks, do not refactor earlier tasks, and do not open showcase/index.html.
```
