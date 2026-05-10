# v0.8 Technical Performance And Visual Foundation Report

Date: 2026-05-10  
Scope: technical performance/e2e runtime pass plus visual debt and future art-direction foundation.

## What Was Done

- Refreshed the current bundle and performance audit.
- Measured current build output and compared it against the prior bundle audit.
- Confirmed the known large chunk warning remains isolated to the Phaser vendor chunk.
- Audited current Playwright release runtime and shard imbalance.
- Added optional 3-shard release scripts while preserving the full release lane and existing 2-shard scripts.
- Created a serious visual debt audit from current gameplay, map renderer, entity scale, minimap, HUD, and asset evidence.
- Created a visual scale/readability audit with current unit, hero, building, capture-site, minimap, camera, fog, and pathfinding scale rules.
- Recorded an explicit no-code visual readability decision for v0.8.
- Created a 2026 art direction bible for the future desktop-quality visual target.
- Created an asset pipeline plan for future source/license/scale metadata and asset categories.
- Created a Cinderfen visual rework spec for future terrain, shrine, road, outpost, and readability direction.

## What Was Not Done

- No gameplay expansion.
- No new maps.
- No new units.
- No new factions.
- No workers or enemy workers.
- No real enemy construction.
- No enemy economy AI.
- No reward changes.
- No campaign progression changes.
- No save-version change.
- No pressure behavior expansion.
- No live reinforcement promotion.
- No route contest AI.
- No defensive hold behavior.
- No desktop packaging.
- No engine switch.
- No 3D rewrite.
- No generated or external art assets.
- No large binary assets.
- No shader, VFX, animation, terrain-renderer, or UI redesign implementation.

## Performance Findings

Current build output from the v0.8 performance audit:

```text
App JS: assets/index-CC1M6Mg7.js, 476.83 kB / gzip 127.77 kB
Phaser vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB
CSS: assets/index-v9ZLtiOK.css, 44.23 kB / gzip 9.11 kB
```

Compared with the prior bundle audit, app JS grew by about 40.51 kB minified / 10.44 kB gzip and CSS grew by about 2.19 kB / 0.37 kB gzip. The Phaser vendor chunk is unchanged.

The largest app-code areas remain data, scenes, core, systems, and battle modules. Tutorial and enemy pressure systems are visible in the app bundle, but the app chunk remains below Vite's default warning threshold. The only active warning remains the Phaser vendor chunk.

Decision:

- No bundle optimization was implemented in v0.8.
- Future bundle work should remain analyzer-guided.
- Do not remove content validation, pressure validation, tutorial data, or real behavior checks for bundle size.

## E2E Runtime Findings

The current full release suite lists 67 tests across 4 spec files:

```text
deep-flow.spec.ts: 28 tests
enemy-pressure.spec.ts: 2 tests
layout.spec.ts: 25 tests
smoke.spec.ts: 12 tests
```

The old 2-shard split remains coverage-preserving but imbalanced:

```text
shard1: 55 tests, deep-flow + enemy-pressure + layout
shard2: 12 tests, smoke
```

v0.8 adds optional 3-shard scripts:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

Verified 3-shard result:

```text
shard1of3: PASS, 28 tests in 12.3m
shard2of3: PASS, 27 tests in 14.9m
shard3of3: PASS, 12 tests in 5.3m
```

The full release lane and existing 2-shard scripts remain intact. No test coverage was removed or weakened.

## Visual Debt Findings

The current browser prototype is tactically readable but visually rough.

Major visual debt:

- Roads are broad procedural strokes rather than grounded road materials.
- Swamp/water areas are blob-like and do not yet have a material language.
- Capture sites are readable but mostly icon/ring-driven.
- Terrain, sprites, buildings, labels, and UI do not share a final style system.
- Unit role identity depends too much on labels and health bars.
- Buildings are readable but do not yet have coherent faction architecture or ground contact.
- UI is usable but still prototype-level.

Decision:

- The visual debt is real, but it is structural.
- A tiny constant tweak cannot solve it.
- v0.8 documents the foundation and defers visual implementation to a properly scoped future sprint.

## Visual Scale Findings

Current scale rules are functional:

- Player hero radius is 19 and renders at about 82.65 px target height.
- Common infantry radii 12 to 13 render about 43.8 to 47.45 px.
- Brute radius 16 renders about 58.4 px.
- Enemy commander radius 18 renders about 65.7 px.
- Building sprite boxes are derived from footprint size.
- Capture-site radii are generally 74 to 86 with 42 x 42 resource icons.
- Minimap markers have clear hierarchy: sites and buildings outrank units.

Main inconsistencies:

- Enemy commander scale is not on the same visual-height rule as the player hero.
- Capture-site rings dominate their landmark cores.
- Labels and bars carry too much identity.
- Source art and procedural terrain do not share one production standard.

Decision:

- No unit radius, building size, capture-site radius, camera zoom, pathfinding cell, fog cell, or map dimension change is justified for v0.8.

## Visual Readability Decision

No prototype visual code or CSS tweak was applied.

Candidate tweaks considered:

- Selection ring size/opacity.
- Label spacing.
- Health bar offset.
- Unit/building sprite scale.
- Capture-site icon/ring tuning.
- Minimap contrast or marker scale.
- Terrain overlay opacity.

Reason for no change:

- Current readability is functional.
- The largest problems are asset and art-direction problems.
- A small visual constant change would create churn without enough evidence of player comprehension gain.

## 2026 Art Direction Bible Summary

`docs/ART_DIRECTION_2026_BIBLE.md` defines the future target:

- Original dark heroic fantasy RTS/RPG.
- Readable battlefield first.
- Hero RPG identity.
- Grounded terrain.
- Distinctive original factions.
- Modern lighting/VFX later.
- Tactile, cleaner, scalable UI.

It also records strict IP guardrails:

- Do not copy Warcraft.
- Do not copy Warlords Battlecry.
- Do not copy protected names, factions, units, terrain, UI, lore, music, art, maps, or other expression from any source.

## Asset Pipeline Summary

`docs/ASSET_PIPELINE_PLAN.md` defines future handling for:

- Unit sprites/models.
- Building sprites/models.
- Terrain tiles/materials.
- UI frames/icons.
- VFX.
- Audio.
- Portraits.
- Source/license tracking.
- Placeholder vs production tags.
- Scale metadata.
- Browser prototype folder and naming conventions.
- Future desktop pipeline considerations.

No asset files were created, moved, deleted, renamed, or generated.

## Cinderfen Visual Rework Direction

`docs/CINDERFEN_VISUAL_REWORK_SPEC.md` defines Cinderfen's future identity:

- Ash-glass wetland.
- Blackened causeways.
- Ember-lit shrine sites.
- Wet reflective pools.
- Dead reeds.
- Ruined watch markers.
- Cinder fog.

Gameplay readability requirements:

- Roads must be obvious.
- Capture sites must pop.
- Enemy-base paths must be readable.
- Fog must not hide ownership clarity.
- Units must remain visible.

The spec includes prompt templates and implementation phases, but no art was generated or committed.

## E2E Coverage

Relevant v0.8 verification so far:

```text
npm run test:e2e:smoke: PASS, 12 tests in 6.1m during Phase 7.
npm run test:e2e:layout: first attempt hit command timeout with no failing-test output; after cleanup and longer timeout, PASS, 25 tests in 14.9m.
npm run test:e2e:release:shard1of3: PASS, 28 tests in 12.3m during Phase 4.
npm run test:e2e:release:shard2of3: PASS, 27 tests in 14.9m during Phase 4.
npm run test:e2e:release:shard3of3: PASS, 12 tests in 5.3m during Phase 4.
```

The final v0.8 gate should still run the full release suite and both existing 2-shard scripts.

## Report-Gate Verification

Phase 11 report-gate verification:

```text
npm test: PASS, 45 test files / 334 tests.
npm run build: PASS with the known Phaser vendor warning.
npm run validate:content: PASS.
npm run test:e2e:smoke: PASS, 12 tests in 6.3m.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
git diff --check: PASS.
```

`npm run playtest:sim` regenerated `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` without producing a git diff.

## Remaining Risks

- The full one-piece Playwright release lane remains slow.
- Existing 2-shard scripts remain imbalanced, though the additive 3-shard option is more balanced for CI.
- The Phaser vendor chunk warning remains.
- Visual quality remains prototype-level.
- Cinderfen terrain, roads, water, and capture-site landmarks need a real art pipeline.
- Unit and building visual consistency requires source-art standards, not only runtime scale constants.
- Human tutorial and pressure feedback remain useful.
- Cinder Shrine salience remains a watchpoint.
- Fast Army bypass and Retinue + Training Yard II dominance remain watchpoints.

## Next Recommended Long Goal

Recommended next long-running goal: **v0.8.1 Visual Asset Manifest and Screenshot QA Gate**.

Purpose:

- Add source/license/status/scale metadata for existing assets.
- Define a small screenshot review set for current battlefield, UI, minimap, capture sites, and Cinderfen.
- Do not add new assets yet.
- Do not overhaul visuals yet.
- Preserve gameplay and save compatibility.

Alternative if player-facing work is preferred:

- Tutorial v2 onboarding refinement, still no rewards and no new content unless explicitly scoped.

Do not start a full graphics overhaul, desktop port, engine switch, workers, enemy construction, new factions, new maps, or live enemy-pressure mechanics from this checkpoint.
