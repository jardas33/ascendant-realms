# Golden Battle Sprint 1 — one-time specialist bootstrap

## Why this package exists

The Codex app project registry exposes `D:\Code for projects\WB game like` as a non-Git workspace, but the active Git candidate is `D:\CodexData\worktrees\ascendant-realms-human-playtest4-movement`. The Lead therefore cannot truthfully instantiate repository-scoped specialist worktree threads from this session. Do not create projectless threads for these missions.

Create four Codex threads once, each attached to the candidate repository/worktree through the app's normal project/worktree flow. The Lead will coordinate their handoffs and local integration afterward.

## Shared safety header

Every thread must start by reading `AGENTS.md`, `docs/codex/AUTONOMY_POLICY.md`, `docs/codex/PARALLEL_WORK_POLICY.md`, `docs/current/ACTIVE_SPRINT.md`, and `docs/current/HIGH_LEVERAGE_BACKLOG.md`.

Expected base: `251853ebd936767dd8f8a5c4d6c5d6cbee54b9b9`.

Use isolated worktrees. Local commits are authorized when scoped and validated. No push, PR, remote merge, protected-checkout mutation, destructive Git, or shared-history rebase.

## Thread 1 — Core Gameplay

Suggested title: `Golden S1 Core Gameplay`

Suggested branch: `codex/golden-s1-core`

Kickoff:

```text
You are the Core Gameplay specialist for Ascendant Realms Golden Battle Sprint 1. Work only in your isolated worktree from base 251853ebd936767dd8f8a5c4d6c5d6cbee54b9b9. Read the shared safety docs. Reproduce the highest-impact concrete player-facing blocker in a normal Hollowspan Crossing, Barrosan vs Lioraen Easy opening. Focus on select worker/unit, move, gather, construct/complete, produce/rally, and entering combat. Repair one causal blocker only. Preserve saves, stable IDs, content scope, AI/art boundaries, and protected checkout. Run focused tests and one proportionate rehearsal, inspect evidence, write a structured handoff with changed files/tests/evidence/blockers, and make a scoped local commit. Do not push, merge, rebase, or broaden scope.
```

Owned systems: `src/game/battle`, `src/game/entities`, `src/game/pathfinding`, `src/game/results`.

## Thread 2 — AI / Skirmish

Suggested title: `Golden S1 Easy AI Skirmish`

Suggested branch: `codex/golden-s1-ai`

Kickoff:

```text
You are the AI/Skirmish specialist for Ascendant Realms Golden Battle Sprint 1. Work only in your isolated worktree from base 251853ebd936767dd8f8a5c4d6c5d6cbee54b9b9. Read the shared safety docs. Improve one concrete player-facing coherence problem in a normal Hollowspan Crossing Barrosan vs Lioraen Easy match: economy, workers, housing, production, army composition, reinforcement, movement, clearance, attack planning, first contact, continued pressure, or recovery. Do not rebalance to hide correctness defects. Preserve the accepted gameplay contract, saves, stable IDs, and protected checkout. Run focused tests and one proportionate rehearsal, inspect evidence, write a structured handoff, and make a scoped local commit. Do not push, merge, rebase, or broaden scope.
```

Owned systems: `src/game/ai`, relevant AI data/doctrine files, with no edits to UI/art lanes unless explicitly justified.

## Thread 3 — World / Visuals

Suggested title: `Golden S1 World Visual Readability`

Suggested branch: `codex/golden-s1-world`

Kickoff:

```text
You are the World/Visuals specialist for Ascendant Realms Golden Battle Sprint 1. Work only in your isolated worktree from base 251853ebd936767dd8f8a5c4d6c5d6cbee54b9b9. Read the shared safety docs. Improve one bounded player-facing readability problem in the Hollowspan Golden Battle: unit/building silhouettes, ownership/health separation, terrain/road/river/bridge hierarchy, grounding, or camera framing. Use the smallest authored or existing opt-in presentation change; do not rewrite the renderer, alter gameplay geometry, import unapproved assets, or change behavior. Provide real before/after gameplay-scale captures, focused validation, a structured handoff, and a scoped local commit. Do not push, merge, rebase, or broaden scope.
```

Owned systems: visual metadata, presentation skin, opt-in Godot/world presentation, and narrowly scoped visual styling.

## Thread 4 — UI/UX + Combat Feel

Suggested title: `Golden S1 UX Combat Readability`

Suggested branch: `codex/golden-s1-combat`

Kickoff:

```text
You are the UI/UX and Combat Feel specialist for Ascendant Realms Golden Battle Sprint 1. Work only in your isolated worktree from base 251853ebd936767dd8f8a5c4d6c5d6cbee54b9b9. Read the shared safety docs. Implement one bounded player-facing improvement to objective, selection card, command feedback, action icons/tooltips/disabled reasons, ownership/health/status, or combat readability. Keep debug/review overlays explicit, preserve gameplay semantics and state, and do not redesign the whole HUD. Run focused tests, inspect fresh normal-scale evidence at supported resolutions, write a structured handoff, and make a scoped local commit. Do not push, merge, rebase, or broaden scope.
```

Owned systems: `src/game/ui`, command/selection/damage feedback presentation, and related styles/tests.

## Lead integration

After threads exist, report their branch/worktree paths to the Lead. The Lead will create/use a dedicated local integration worktree, inspect each handoff, cherry-pick only accepted scoped commits, run risk-based combined validation, and prepare a daily brief. No remote action is authorized.
