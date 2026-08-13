# UX-02 bounded-execution incident

Date: 2026-08-13
Lane: `codex/golden-s1-ux-02-godot`
Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-ux-02-godot`

## Observed command

The UX-02 import controller launched the certified Godot executable with:

`Godot_v4.6.3-stable_win64.exe --editor --path D:\CodexData\worktrees\ascendant-realms-golden-s1-ux-02-godot\production\ascendant-realms-godot --import --quit --log-file D:\CodexData\logs\golden-s1-ux02-import-rerun.log`

The controller returned without a structured child result while the owned Godot child remained alive. The audited child was PID 29808, started at `2026-08-13 17:25:24`, with the exact lane path and log path in its command line. The log contained import progress but no completion marker and the expected authored `.godot/imported/*.scn` files were still absent. A later ownership check found that PID had exited; no unrelated Godot process was terminated. The unrelated combat-lane Godot PID 24028 was explicitly left untouched.

## Classification and repair

Classification: `UNBOUNDED_COMMAND_EXECUTION_SUBPROCESS_HANG_UX02`.

The failure was caused by the prior synchronous capture/import invocation not owning and supervising the child after return. The lane now contains `tools/codex/runBounded.mjs`, an owned-process lease contract, `tools/codex/studio_watchdog.ps1`, and disposable progress/hang fixtures. The active P1-R2 runner is being migrated to the bounded runner; historical tooling is not being retrofitted in this checkpoint.

No production gameplay state, protected checkout, remote branch, or unrelated process was changed.
