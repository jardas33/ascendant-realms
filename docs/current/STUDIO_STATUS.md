# Studio status — I1 canonical integration

Updated: 2026-08-14

## Current checkpoint

- Canonical worktree: `D:\CodexData\worktrees\ascendant-realms-current-godot-baseline`
- Branch: `codex/current-godot-baseline`
- I1 local HEAD: `195d265b991d359afd6c12c1ecc31c74a6864fb7`
- Starting baseline: `5822bcd5e677b88ee9f017c119fb5848c7981ae3`
- Protected checkout: untouched
- Remote state: no push or PR mutation performed

## Integrated player-facing slices

- RESOURCES-01 resource-node identity: `b816eef2923fd3f9db923406b6ea05785e90cc44`
- BUILDINGS-01A placement readability: `e430abf8`
- UX cleanup for normal-player construction diagnostics: `d0767f1c`
- COMBAT-FEEL presentation only: `195d265b`

The combat slice changes only hit-flash and damage-label presentation. No combat rules, movement, AI, economy, saves, or stable IDs were changed.

## Evidence and qualification

- Fresh resource readability proof: `D:\CodexData\evidence\i1-resources-final\run-20260814162028-195d265b`
- Fresh combat proof: `artifacts/manual-review/v0434-first-combat-casualty-loop`
- Fresh official startup/capture logs: `D:\CodexData\evidence\i1-startups\startup-2.log`, `startup-3.log`, plus the first successful v0.434 run
- v0.432 headed production validator: passed at I1 HEAD
- v0.434 headed combat validator: passed at I1 HEAD
- package tests/build/content/art/runtime-slot/artifact-retention/godot:all: passed

## Known yellow qualification

The retained v0.433 headed economy capture fails on both the canonical I1 lane and the untouched RESOURCES-01 specialist lane at the pre-existing assertion `tests/v0433_capture.gd:190` (`expected the carried food deposit before the gold switch`). It is not caused by the I1 resource or presentation diffs. The independent RESOURCES-01 capture and focused economy tests pass. This remains a truthful capture-contract blocker, not a validator weakening or metadata rewrite.

## Parked lanes

- WORLD-02: `YELLOW_P1_WORLD02_VISUAL_PAYOFF_INSUFFICIENT`; not integrated.
- PLAY-01A / AI-01: still requires a fresh current-source Easy opening and first-contact proof.
- COMBAT-RULES-01 and BUILD-01 dirty extension: excluded from I1.
- R2 runtime-stability diagnostic patch: preserved in its specialist lane only; not integrated.
