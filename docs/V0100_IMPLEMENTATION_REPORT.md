# v0.100 Implementation Report

## Summary

v0.100 adds a private-package-only Playtest Hub and Scenario Gallery for fast manual QA. It does not expose shortcuts in production posture and does not alter normal progression, saves, persistent rewards, gameplay rules, balance, stable IDs, maps, factions, art, assets, or desktop work.

## Runtime Changed

- Added `PlaytestHubScene`.
- Added a scenario manifest and fixture helpers under `src/game/playtest/`.
- Added Main Menu entry point gated by private playtest tools.
- Added hub return affordances to Campaign Map, Hero Creation, Hero Progression, Battle HUD, and Results fixtures.
- Added private scenario setup for selected hero, Worker, squad, building, contested site, fog/minimap sample, notification sample, and Lume overlay samples.
- Added private no-save wrappers for hub-launched campaign, hero progression, and Results paths.

## Save Format

- No save-version bump.
- No save fields added.
- No stable IDs or serialized values renamed.
- The hub uses an in-memory raw save snapshot and restores the existing save key after previews.

## Scenario Gallery

The gallery contains five groups: Campaign Shell, First Session, Battle Shell, Lume, and Meta. `docs/V0100_SCENARIO_GALLERY_MANIFEST.json` records purpose, expected UI, absent UI, manual question, screenshot ID, automated coverage, launch context, and isolation rule for each scenario.

## Emmanuel Fast Review

`docs/V0100_EMMANUEL_FAST_REVIEW_GUIDE.md` defines the intended under-8-minute review flow.

## Verification

```text
npm test - PASS, 100 files / 711 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-meta - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 31 tests after splitting the oversized behaviour/marquee gauntlet into two assertion-preserving tests.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 16 tests / 145 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 145 screenshots / 7 contact sheets.
```

Non-pass evidence resolved before closeout:

- A filtered v0.100 visual-QA-only run captured the intended nine hub screenshots but failed the global expected screenshot count because the suite was intentionally filtered. The final unfiltered visual QA run passed with all 145 screenshots.
- Hosted deep-battle initially timed out in one oversized behaviour/marquee/minimap gauntlet. The assertions were split into two focused tests without removing coverage, the exact split tests passed, and the full hosted deep-battle shard reran green with 31 tests.

Package, package verification, `git diff --check`, final commit, push, and remote Fast confidence are recorded in the final closeout response.

## Deferred

- No public-package hub.
- No persistent tour state.
- No autoplay gameplay.
- No new art or screenshots generated outside the existing visual-QA harness.
