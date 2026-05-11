# v0.11 Technical Reliability Report

Date: 2026-05-11

Scope: improve technical reliability, e2e runtime clarity, preview smoke repeatability, optional visual QA trust, bundle/performance documentation, developer command ergonomics, and release-gate maintainability. This milestone does not change gameplay, balance, content, tutorial behavior, save format, campaign progression, visual assets, runtime art, maps, units, factions, rewards, or UI design.

## What Changed

- Added an e2e runtime audit refresh: `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`.
- Added a release lane reliability plan: `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`.
- Added production preview smoke helper: `npm run smoke:preview`, implemented in `tools/smokePreview.ts`.
- Added preview smoke reliability notes: `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`.
- Improved optional visual QA reporting so the generated index and command output show screenshot count, browser console error count, viewport coverage, and harness path.
- Added visual QA reliability notes: `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`.
- Refreshed bundle/performance facts and analyzer findings: `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`.
- Added a developer command guide: `docs/DEVELOPER_COMMAND_GUIDE.md`.
- Tightened `RELEASE_CHECKLIST.md` with routine/docs/tutorial/UI/visual-intake/content/final-freeze gate categories.
- Updated README, roadmap, changelog, development checkpoint, and LLM handoff for v0.11.

## What Did Not Change

v0.11 did not add or change:

- gameplay
- balance
- campaign progression
- tutorial behavior
- rewards
- save schema or save version
- maps, units, factions, workers, enemy construction, economy AI, diplomacy, crafting, procedural generation, multiplayer, monetization, or desktop packaging
- generated/imported/downloaded/scraped/runtime art
- runtime asset wiring
- pixel-perfect screenshot assertions
- Playwright coverage removal
- Phaser/Vite chunking or warning policy

## E2E Runtime Findings

Current Playwright inventory remains:

- 67 e2e tests across 4 spec files.
- Smoke: 12 tests.
- Full release: 67 tests.
- 2-way shards: 55 and 12 tests.
- 3-way shards: 28, 27, and 12 tests.

The 2-way split remains uneven because shard 1 carries deep-flow, layout, and pressure-heavy coverage while shard 2 is smoke-sized. The 3-way split remains the better-balanced CI option, but it does not replace the canonical full release lane.

## Release Lane Reliability Plan

`docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md` defines:

- smoke for frequent iteration
- 3-way shards for balanced CI/long checks
- full release before major freezes
- timeout policy
- transient rerun policy
- stale-process and port-conflict policy
- explicit "do not delete tests for speed" guardrails

## Preview Smoke Reliability

`npm run smoke:preview` now:

- starts Vite preview on `http://127.0.0.1:4173/`
- waits for the server
- uses Chromium with the project SwiftShader/ANGLE args
- verifies title and release menu copy
- launches/exits Tutorial / Proving Grounds
- verifies New Campaign, Continue Campaign, and Skirmish Setup
- fails on browser console errors
- shuts down the preview process tree it started

Final Phase 3 result: pass in about 27 seconds with 0 browser console errors.

## Visual QA Reliability

`npm run visual:qa` still captures 18 human-review screenshots under ignored `visual-qa/latest/`. v0.11 adds a summary block to `visual-qa/latest/index.md`:

- screenshot count
- browser console error count
- viewport coverage
- harness path

No cleanup/deletion behavior was added, and no pixel-perfect image assertions were added.

## Bundle And Performance Status

Current production build:

```text
assets/index-DY-3qp2P.js          477.04 kB / gzip 127.86 kB
assets/vendor-phaser-B61OQUcB.js 1,481.79 kB / gzip 339.86 kB
assets/index-BiGdwuWI.css          44.51 kB / gzip   9.16 kB
```

The known Phaser vendor warning remains unchanged and non-blocking. The app and CSS chunks did not grow from v0.10. Production string scan found no v0.11 preview helper or visual QA harness leakage into the app JS.

Recommendation: no bundle optimization in v0.11. Keep measuring; do not lazy-load scenes/data or adjust `chunkSizeWarningLimit` without a dedicated optimization goal.

## Developer Command Guide

`docs/DEVELOPER_COMMAND_GUIDE.md` maps work type to gates:

- fast local confidence
- tutorial changes
- visual-intake changes
- visual QA changes
- content/data changes
- e2e release verification
- full final gate
- preview smoke
- art-intake validation
- bundle analysis
- simulator

## Release Checklist Changes

`RELEASE_CHECKLIST.md` now separates:

- routine iteration
- docs-only change
- tutorial/UI change
- visual-intake change
- content/data change
- final freeze gate

It also calls out `validate:art-intake`, `visual:qa`, 3-way shards, preview smoke helper use, the known Phaser vendor warning, and the slow full release lane.

## Remaining Risks

- Full release e2e remains slow.
- 2-way shard 1 remains much heavier than shard 2.
- The known Phaser vendor chunk warning remains.
- Visual QA remains human-review evidence, not an art-quality approval mechanism.
- Preview smoke is now automated but should still be watched on future OS/CI environments.
- Tutorial v0.10.1 should wait for Emmanuel's manual tutorial feedback.
- v0.9.2 visual candidate review should wait for source/license-documented candidate art.

## Next Recommended Long Goal

If Emmanuel provides tutorial feedback, the next player-facing goal should be **v0.10.1 Tutorial v2 Human-Feedback Polish**, still preserving no rewards, no persistence, no campaign progression changes, no new maps/units/factions, and no art replacement.

If no human tutorial feedback or visual candidates are available, the safest autonomous follow-up is **v0.11.1 CI Release Matrix Dry-Run And Preview Helper Portability**, focused on CI documentation, shard matrix examples, process cleanup notes, and preview helper portability without gameplay/content/runtime changes.
