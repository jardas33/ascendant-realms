# v0.9 Cinderfen Visual Replacement Implementation Plan

Date: 2026-05-10  
Status: future-only implementation plan. No art was generated, imported, moved, renamed, deleted, replaced, committed, or wired into runtime.

## Purpose

This document defines a safe future sequence for replacing Cinderfen visuals after v0.9. It is a planning document only. It does not authorize runtime asset replacement, renderer changes, map changes, gameplay changes, save changes, or production approval.

The current browser prototype remains systems-first and source/license conservative.

## Future Phase 1 - Generate Or Obtain Style Frames Manually

Goal: create or obtain a small number of approved style-frame candidates outside runtime.

Rules:

- use the v0.9 prompt pack or a commissioned/manual brief,
- no direct copyrighted reference ingestion,
- no protected franchise lookalikes,
- no large binary commits without explicit approval,
- no runtime folder placement.

Output:

- 1 to 3 style frames or concept sheets for terrain, shrine, and Ashen architecture.

## Future Phase 2 - Record Source / License Metadata

Goal: record source, license, prompt, author/tool/vendor, date, reviewer, and usage rights before any commit.

Rules:

- unknown source means not production-safe,
- generated assets need generated-review metadata,
- external references stay reference-only,
- source/license uncertainty blocks runtime integration.

Output:

- metadata notes suitable for manifest entries and review docs.

## Future Phase 3 - Add Assets To A Non-Runtime Review Folder

Goal: keep candidate assets isolated from runtime loading.

Preferred future location:

```text
docs/asset-review/cinderfen/
```

Rules:

- do not use `public/assets/final/` yet,
- do not update `AssetKeys.ts`,
- do not preload candidate assets,
- keep file sizes reasonable and documented.

Output:

- review-only files, if explicitly approved by the future goal.

## Future Phase 4 - Add Manifest Entries As Reference / Candidate, Not Runtime

Goal: track reviewed candidates conservatively.

Rules:

- `usage: "docs-reference"`, `manual-reference`, or `unused`,
- `allowedInProduction: false` until review is complete,
- `needsReview: true`,
- no runtime `usedBy` unless a later integration phase approves it,
- run `npm run validate:content`.

Output:

- manifest entries that describe real files without pretending they are production-ready.

## Future Phase 5 - Run Screenshot QA With Side-By-Side Docs If Possible

Goal: compare the current prototype screenshots with candidate direction before runtime import.

Rules:

- use `npm run visual:qa` for current baseline,
- create a human-readable comparison report if candidates are mocked or composited outside runtime,
- no pixel-perfect diffing,
- document pass/fail against `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`.

Output:

- review decision: terrain first, shrine first, architecture first, or stop.

## Future Phase 6 - Select One Tiny Runtime Replacement Candidate

Goal: pick one low-scope, high-value replacement.

Allowed first-candidate families:

- Cinder Shrine landmark replacement,
- Cinderfen road material overlay,
- Ashen stronghold replacement.

Rules:

- one target only,
- no broad renderer rewrite,
- no full UI redesign,
- no gameplay or map progression change,
- no source/license uncertainty.

Output:

- implementation proposal for exactly one runtime candidate.

## Future Phase 7 - Add Asset With Manifest Validation

Goal: add a reviewed asset to runtime only after metadata is safe.

Rules:

- add only the approved file(s),
- update `visualAssetManifest.ts` conservatively,
- source/license and production fields must match evidence,
- run `npm run validate:content`.

Output:

- a manifest-valid asset candidate ready for small integration.

## Future Phase 8 - Integrate Behind Feature Flag Or Tiny Scoped Path If Possible

Goal: minimize blast radius.

Options:

- feature flag for alternate shrine/core asset,
- Cinderfen-only map renderer branch for a road overlay,
- enemy stronghold-only asset key swap after scale check.

Rules:

- preserve existing behavior,
- no save version change,
- no map geometry change,
- no campaign progression change,
- no e2e selector destabilization.

Output:

- the smallest runtime path that allows review.

## Future Phase 9 - Run Visual QA Before / After

Goal: prove the replacement improves the visual target without harming readability.

Required:

- before screenshots from current branch or prior baseline,
- after screenshots from replacement branch,
- `visual-qa/latest/index.md` for generated captures,
- human review notes.

Output:

- accept, revise, or roll back.

## Future Phase 10 - Run Full Gate

Goal: protect the playable prototype.

Required for a runtime visual replacement:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run test:e2e:release`
- release shards as needed
- `npm run visual:qa`
- `npm run playtest:sim`
- `git diff --check`
- production preview smoke when feasible

Output:

- green verification or focused fix/rollback decision.

## Future Phase 11 - Consider Next Replacement Only After Review

Goal: avoid cascading visual churn.

Rules:

- commit one replacement only after green gate,
- document outcome and remaining risks,
- do not start the next replacement until the previous one is accepted,
- keep unknown-source assets out of runtime.

Output:

- next scoped candidate or stop.

## Candidate 1 - Cinder Shrine Landmark Replacement

Value:

- high immediate Cinderfen identity gain,
- addresses the ring/icon-led capture-site problem,
- improves the most screenshot-visible tactical landmark.

Risk:

- high if ownership or progress clarity is weakened,
- can hide units inside capture radius,
- can confuse shrine, building, resource, and VFX reads,
- source/license uncertainty blocks integration.

Files likely touched later:

- `src/game/entities/CaptureSite.ts`
- `src/game/assets/AssetKeys.ts`
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/` only after approved runtime import
- `tests/visual-qa/visual-qa.spec.ts` only if a new focused target is needed

Tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run visual:qa`
- broader release lane if capture-site rendering changes broadly

Screenshot QA targets:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-crossing-pressure-desktop.png`
- `cinderfen-crossing-tablet.png`
- `tutorial-mobile.png` for HUD/label density comparison

Rollback plan:

- remove the new runtime asset reference,
- restore prior `CaptureSite.ts` behavior for the shrine core,
- keep candidate file only if it remains a documented non-runtime reference and metadata is valid,
- rerun validation and visual QA.

## Candidate 2 - Cinderfen Road Material Overlay

Value:

- highest terrain readability payoff,
- addresses paint-like roads and route identity,
- supports pressure-route and shrine-route comprehension.

Risk:

- high because road rendering touches broad battlefield readability,
- can imply pathing changes,
- can hide units/projectiles,
- can require renderer complexity if not scoped tightly.

Files likely touched later:

- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/data/maps/cinderfenCauseway.ts` only if asset placement data is approved later
- `src/game/data/maps/cinderfenWatchpost.ts` only if asset placement data is approved later
- `src/game/assets/visualAssetManifest.ts`
- `public/assets/final/` only after approved runtime import

Tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run test:e2e:release`
- `npm run visual:qa`
- `npm run playtest:sim` if perceived route clarity changes tactical review

Screenshot QA targets:

- `cinderfen-crossing-desktop.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-crossing-pressure-desktop.png`
- `cinderfen-watch-desktop.png`
- `cinderfen-watch-pressure-desktop.png`

Rollback plan:

- disable or remove the road overlay branch,
- return to prior procedural road rendering,
- leave manifest candidate as `unused`/reference only if source/license metadata remains valid,
- rerun content validation, visual QA, and smoke.

## Candidate 3 - Ashen Stronghold Replacement

Value:

- improves enemy base identity,
- gives Cinderfen Watch and enemy pressure screenshots a clearer target,
- lower surface area than full terrain replacement if isolated to one building asset.

Risk:

- medium-high because stronghold art changes perceived threat and victory target clarity,
- can disrupt label/bar/ring compatibility,
- can make the current footprint feel wrong,
- can unintentionally imply stronger enemy mechanics.

Files likely touched later:

- `src/game/assets/AssetKeys.ts`
- `src/game/assets/visualAssetManifest.ts`
- `src/game/entities/Building.ts` only if render sizing/foundation compatibility requires a tiny scoped adjustment
- `public/assets/final/buildings/` only after approved runtime import

Tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run visual:qa`
- release lane if building rendering or asset loading paths change

Screenshot QA targets:

- `cinderfen-watch-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- `cinderfen-crossing-desktop.png`
- `results-defeat-desktop.png` if perceived enemy threat changes

Rollback plan:

- revert the asset key/runtime selection to existing enemy stronghold art,
- keep new file only as non-runtime candidate if valid,
- restore previous manifest usage/status,
- rerun validation, visual QA, and affected e2e.

## Work Explicitly Not In This Plan

- no generated art in v0.9,
- no runtime visual replacement in v0.9,
- no desktop port,
- no engine switch,
- no 3D rewrite,
- no new maps,
- no new units,
- no new factions,
- no workers or enemy construction,
- no economy AI,
- no campaign rewards,
- no procedural generation,
- no broad BattleScene rewrite,
- no production approval of unknown-source assets.

## v0.9 Decision

The safest first future runtime candidate is likely the Cinder Shrine landmark if source/license metadata is complete and screenshot QA proves ownership clarity. The road/causeway overlay has larger upside but broader risk. The Ashen stronghold is a useful third option when architecture identity is ready and scale compatibility is proven.
