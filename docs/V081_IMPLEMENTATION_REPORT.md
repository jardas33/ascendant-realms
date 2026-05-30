# v0.81 Implementation Report

Status: docs-only checkpoint report.

## Scope

v0.81 creates the Lume Site Network prototype specification and smallest-fun-slice gate. It audits the existing site, Worker, resource, campaign, HUD, Results, event, AI, save, replay, Tutorial, and test architecture, then recommends a small future runtime prototype.

## Runtime Changed

None.

No gameplay, balance, site behavior, Worker behavior, hero behavior, enemy AI, pathing, controls, UI behavior, campaign behavior, Results behavior, rewards, replay, Tutorial behavior, saves, art, assets, maps, factions, races, units, buildings, classes, desktop work, multiplayer, PvP, co-op, runtime copy migration, title rename, stable ID rename, or Lume Network runtime code changed.

## Files Created

- `docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md`.
- `docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md`.
- `docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md`.
- `docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md`.
- `docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md`.
- `docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md`.
- `docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md`.
- `docs/V081_RACE_EXTENSIBILITY_MATRIX.md`.
- `docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md`.
- `docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md`.
- `docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md`.
- `docs/V081_EMMANUEL_REVIEW_PACKET.md`.
- `docs/V081_IMPLEMENTATION_REPORT.md`.

## Audit Summary

The current resource-site system is suitable for a small Lume prototype:

- `CaptureSiteDefinition` is content-driven map data.
- `CaptureSite` owns live ownership, capture progress, site level, Worker assignment, and visual rings.
- `ResourceSystem` owns capture, income, first-capture bonuses, Worker assignment, and site upgrades.
- Enemy AI already scores resource sites for capture, retake, defend, raid, and upgrades.
- HUD and Results already have compact rows for objectives, events, site status, and battle-only summaries.
- Save state does not store site ownership and does not need Lume state for the first prototype.

## Recommendation

Recommended smallest fun slice:

- Mission-local Linked Control.
- First testbed: `aether_well_ruins` on `broken_ford`.
- Maximum eligible sites: three.
- Maximum active links: two.
- First benefit: Linked Ward, a small non-stacking defensive readiness benefit near active linked sites.
- Activation: capture-only first.
- Hero/Jardas binding: deferred for Emmanuel decision.
- State: battle-local only.

## Save Format

No save-version bump.

No save fields were added, removed, renamed, or migrated.

Stable internal IDs remain unchanged, including `aether_well_ruins`, `broken_ford`, `aether`, `mission_aether_surge`, `aether_surge`, `aether_lens`, and `maxMana`.

## Package

Package metadata and package validation are updated to include the v0.81 docs. The playable build remains the unchanged browser prototype plus docs.

## Verification

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-5ef4f92-dirty` generated.
npm run verify:playtest-package PASS, 246 checks against the dirty pre-commit package.
git diff --check PASS.
```

## Deferred

- Runtime Lume Network prototype.
- Hero/Jardas binding action.
- Living Mines.
- Race-specific Lume variants.
- Runtime display-copy migration.
- Art generation/import.
- Visual style-frame milestone.
- Desktop/engine work.
- v0.82.
