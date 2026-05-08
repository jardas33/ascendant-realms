# v0.5 Save, Content Validation, Determinism, and Expansion Readiness Gate Report

Date: 2026-05-08

Status: Phase 14 documentation checkpoint complete. The full final release-style verification remains a separate Phase 15 gate.

## Purpose

The v0.5 gate hardens Ascendant Realms before broad mechanics or new content expansion. It protects saves, validates content references, makes simulator behavior easier to trust, and selects one future vertical-slice candidate without implementing broad systems.

This gate preserves the frozen v0.3 Cinderfen Route Baseline, the frozen v0.3.1 polish release, and the v0.4 technical groundwork.

## Added

- File-backed save fixtures and a test-only fixture harness under `tests/fixtures/saves/`.
- Save migration and normalization regression tests for legacy V1, current V2, settings-only, affixed inventory, legacy equipment, retinue, rivals, trophies, Chapter 2, Cinderfen route progress, malformed JSON, missing optional fields, and future-ish unknown fields.
- `docs/V05_SAVE_FIXTURE_PLAN.md` and `docs/V05_SAVE_FIXTURE_REPORT.md`.
- Stronger content validation for campaign graphs, node/map/reward references, repeat reward policy, event/town visible effects, map objective/capture-site consistency, Cinderfen modifier scope, enemy AI references, and tutorial metadata.
- `npm run validate:content`, backed by `tools/validateContent.ts`.
- `docs/V05_CONTENT_VALIDATION_AUDIT.md` and `docs/CAMPAIGN_GRAPH_REWARD_GATE.md`.
- `docs/COMMAND_LOG_REPLAY_FEASIBILITY.md`.
- `docs/SIMULATOR_DETERMINISM_GATE.md`.
- `docs/V05_VERTICAL_SLICE_CANDIDATE.md`.
- `docs/TUTORIAL_PROVING_GROUNDS_BRIEF.md`.
- A non-playable Tutorial / Proving Grounds metadata scaffold with validation only.

## Save Fixture Tests

The fixture suite protects:

- Legacy V1 hero migration.
- V2 campaign progress and selected Chapter 2 state.
- Settings-only saves staying non-playable.
- Affixed item instances, equipment links, duplicate affix normalization, and legacy catalog-ID equipment migration.
- Campaign resources, event choices, town purchases, Stronghold upgrades, campaign modifiers, retinue units, rival state, rival trophies, and Cinderfen route completion.
- Invalid JSON returning safe `null` behavior.
- Missing optional fields receiving safe defaults.
- Unknown future-ish fields not crashing current normalization.

Current save version remains `2`. No v0.5 work required a save-version bump.

## Validation Rules

The v0.5 validation gate now checks:

- Unique campaign node/chapter/prerequisite entries.
- Campaign chapter node references and reachable graph shape.
- Battle nodes referencing existing maps and reward tables.
- Unlock and prerequisite references.
- Reward table duplicate IDs, item references, deterministic item IDs, weighted pools, first-clear/repeat-clear conflicts, and repeat-clear economy caps.
- Event and town choices having visible persisted effects when they cost resources or do not complete the node.
- One-time town item services having stock guards.
- Stronghold, rival, trophy, reputation, modifier, enemy hero, AI personality, map, objective, capture-site, neutral camp, and enemy-building references.
- Cinderfen-specific one-battle modifiers staying scoped to Cinderfen maps/sites.
- Tutorial metadata IDs, step IDs, statuses, step types, and optional references.

## Standalone Script

`npm run validate:content` runs the same `validateContent()` path as the pure test suite without opening the game UI. It prints actionable validation errors and exits nonzero on broken data, making it suitable for CI or pre-release content checks.

## Campaign Graph And Reward Gate

The campaign graph/reward gate documents the current Chapter 1 and Chapter 2 graph, intentional route endpoints, repeat-reward policy, and watch items.

Current repeat policy:

- Repeat battle item rewards stay disabled unless explicitly allowed.
- Repeat XP/resources must stay below or equal to matching first-clear bonuses.
- Cinderfen repeat farming remains intentionally tiny.

Watch items remain human-facing:

- Fast Army quick-clear feel.
- Retinue plus Training Yard II strength.
- Cinder Shrine salience.
- Waystation and Aftermath density.

## Command-Log Feasibility

Recommendation: build a tiny test-only semantic command-log V1 later, but do not wire production command replay yet.

The safest first future target is the existing first-campaign-battle deep-flow path, replayed through Playwright/test helpers with high-level commands rather than raw pointer coordinates. Production replay, multiplayer lockstep, save fields, deterministic engine rewrites, and gameplay-facing replay UI remain out of scope.

## Simulator Determinism

The scripted simulator is deterministic for the default suite:

- 7 campaign battle scenarios.
- 3 player scripts.
- 13 Stronghold/retinue/service profiles.
- 255 generated telemetry runs.
- 85 campaign battle node/profile summaries.

The simulator can be trusted for structural drift, coverage, reward presence, route pressure trends, and schema stability. It cannot replace human review for feel, readability, route stress, reward excitement, audio, animation, or UI comprehension.

## Selected Vertical Slice

Approved future planning candidate: Candidate A, Tutorial / Proving Grounds.

Reason: it improves onboarding and QA leverage while using existing systems and avoiding workers, enemy construction, new factions, new maps, new units, diplomacy, procedural generation, crafting, multiplayer, or broad campaign expansion.

Phase 13 added only a metadata scaffold:

- `src/game/types/TutorialTypes.ts`
- `src/game/data/tutorials.ts`
- `src/game/data/validation/validateTutorials.ts`

The scaffold is not playable, not exposed in UI, grants no rewards, persists no progress, adds no save field, and launches no map or scene.

## Skipped Or Blocked Systems

The gate intentionally did not implement:

- Workers.
- Enemy construction.
- New factions.
- New maps.
- New units.
- Diplomacy.
- Procedural generation.
- Crafting, durability, or affix rerolling.
- Multiplayer.
- Monetization code.
- Broad loot complexity.
- Full trophy rooms.
- Broad army-management systems.
- Playable tutorial content.
- Production command replay.
- Save-version bump.

## Phase 14 Verification Status

Phase 14 documentation-gate verification passed:

- `npm test`: PASS, 40 test files / 298 tests.
- `npm run build`: PASS with the known Phaser vendor warning. App JS `assets/index-Caz7zKca.js`, 445.42 kB / gzip 119.69 kB; vendor Phaser `assets/vendor-phaser-B61OQUcB.js`, 1,481.79 kB / gzip 339.86 kB; CSS `assets/index-CeqfGaMI.css`, 42.04 kB / gzip 8.74 kB.
- `npm run validate:content`: PASS.
- `npm run test:e2e:smoke`: PASS, 10 Playwright tests in 4.7m.
- `npm run playtest:sim`: PASS, 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: PASS.

Phase 15 will run the full release gate, release shards, simulator, diff check, and production preview smoke.

## Next Recommended Goal

Recommended next `/goal`: implement the first Tutorial / Proving Grounds playable shell only after the v0.5 gate is fully green.

The first implementation should stay narrow:

- Use existing units, buildings, resources, abilities, and maps if feasible.
- Add no new faction, worker system, enemy construction, crafting, diplomacy, procedural generation, or save-version bump.
- Start with a non-rewarding tutorial launch shell and one guided objective.
- Keep content validation, e2e tutorial start/completion checks, campaign/skirmish non-regression checks, and save compatibility green.
