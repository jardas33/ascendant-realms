# Ascendant Realms agent map

This repository is a Phaser 3 + TypeScript + Vite browser RTS/RPG prototype with an opt-in Godot presentation and qualification lane. Read this file before changing anything.

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
