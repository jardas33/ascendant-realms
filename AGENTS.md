# Ascendant Realms agent map

This repository contains the Ascendant Realms production game in Godot plus a legacy browser prototype. Read this file before changing anything.

## Canonical production runtime

- Production game: `production/ascendant-realms-godot`
- Engine: Godot 4.6.3 stable
- Certified executable: `D:/CodexData/tools/godot-4.6.3-stable/Godot_v4.6.3-stable_win64.exe`
- Main scene: `res://scenes/main.tscn`
- Runtime identity and launch contract: [`docs/current/CANONICAL_RUNTIME.md`](docs/current/CANONICAL_RUNTIME.md)
- The repository-root `src/` Phaser/Vite surface is `LEGACY_BROWSER_PROTOTYPE` and is not valid Golden Battle production proof.
- `desktop-spikes/godot-salto` is an experimental spike, not the canonical production project.

Before a production specialist edits files, verify the expected baseline SHA, this file, the canonical runtime document, `production/ascendant-realms-godot/project.godot`, `config/name="Ascendant Realms"`, and `run/main_scene="res://scenes/main.tscn"`. Opening the root browser prototype is a `WRONG_RUNTIME_TARGET` failure.

## Source of truth

- Product direction: [`docs/product/NORTH_STAR.md`](docs/product/NORTH_STAR.md)
- Gameplay contracts: [`docs/gameplay/RTS_DESIGN.md`](docs/gameplay/RTS_DESIGN.md)
- Runtime map: [`docs/architecture/SYSTEM_MAP.md`](docs/architecture/SYSTEM_MAP.md)
- Current facts and blockers: [`docs/current/CURRENT_STATE.md`](docs/current/CURRENT_STATE.md)
- Player-facing backlog: [`docs/current/HIGH_LEVERAGE_BACKLOG.md`](docs/current/HIGH_LEVERAGE_BACKLOG.md)
- Agent operating rules: [`docs/codex/AUTONOMY_POLICY.md`](docs/codex/AUTONOMY_POLICY.md)

## Safe default workflow

1. Confirm the active worktree, branch, base SHA, and dirty-file ownership.
2. Read the relevant current-state and backlog entry before editing.
3. Keep production behavior, saves, stable IDs, and evidence contracts in scope only when the task explicitly authorizes them.
4. Prefer one bounded player-facing change, focused tests, and fresh normal-scale evidence.
5. Run `git diff --check`; use the command ladder in [`docs/qa/TEST_STRATEGY.md`](docs/qa/TEST_STRATEGY.md).
6. Never stage a dirty worktree broadly. Never reset or discard historical work.

The current candidate may contain pre-existing dirty production/evidence work. Treat that patch as owned by its prior task unless the active goal explicitly names it.
