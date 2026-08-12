# Golden Battle Sprint 1 Specialist Bootstrap

Common base: `3a49c2d2901fa5c868f5bb2c2cd81d6b0e4625b8`

All four specialist worktrees are real, clean, local Git worktrees. Start each thread in the matching folder below. Read `AGENTS.md`, `docs/codex/AUTONOMY_POLICY.md`, `docs/codex/PARALLEL_WORK_POLICY.md`, `docs/current/ACTIVE_SPRINT.md`, and `docs/current/HIGH_LEVERAGE_BACKLOG.md`.

Shared policy: make one bounded player-facing improvement, preserve saves and stable IDs, run focused validation plus one proportionate rehearsal, record changed files/tests/evidence/blockers, and make one scoped local commit. No push, PR, merge, rebase, protected-checkout mutation, destructive Git, or cross-lane edits.

## Core Gameplay

- Thread: `Golden S1 Core Gameplay`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-core`
- Branch: `codex/golden-s1-core`
- Outcome: dependable select -> move -> gather -> construct -> produce -> rally -> combat opening.
- Own: `src/game/battle`, `src/game/entities`, `src/game/pathfinding`, `src/game/results`.
- Proof: normal Hollowspan Crossing, Barrosan vs Lioraen Easy opening; focused tests and one normal rehearsal.

## AI / Skirmish

- Thread: `Golden S1 Easy AI Skirmish`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-ai`
- Branch: `codex/golden-s1-ai`
- Outcome: coherent Lioraen Easy economy, production, movement, first contact, pressure, and recovery.
- Own: `src/game/ai` and relevant AI doctrine/data only.
- Proof: one normal Hollowspan Crossing rehearsal with focused tests and a structured handoff.

## World / Visuals

- Thread: `Golden S1 World Visual Readability`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-world`
- Branch: `codex/golden-s1-world`
- Outcome: clearer unit/building silhouettes, ownership/health separation, terrain/road/river/bridge hierarchy, grounding, or camera framing.
- Own: visual metadata, opt-in Godot/world presentation, narrowly scoped visual styling.
- Proof: real before/after gameplay-scale captures, focused validation, and a local commit.

## UI/UX + Combat Feel

- Thread: `Golden S1 UX Combat Readability`
- Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-combat`
- Branch: `codex/golden-s1-combat`
- Outcome: clearer objective, selection, command feedback, action icons/tooltips/disabled reasons, ownership/health/status, or combat readability.
- Own: `src/game/ui`, command/selection/damage feedback presentation, related styles/tests.
- Proof: focused tests and fresh normal-scale evidence at supported resolutions.

## Lead Integration / QA

- Worktree: `D:\CodexData\worktrees\ascendant-realms-golden-s1-integration`
- Branch: `codex/golden-s1-integration`
- Role: inspect specialist handoffs, accept only scoped commits, run combined validation, and prepare a local playable candidate.
- Baseline: `npm test`, `npm run build`, `git diff --check`, and a lightweight existing Godot/runtime sanity check if cheap.
- Do not run native M41 smoke as part of this baseline. Do not push or merge.

Report every handoff with branch, worktree, base, local commit, changed-file manifest, tests, evidence, blocker, and next safe priority.
