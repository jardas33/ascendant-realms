# v0.99 Implementation Report

Status: implemented and verified.

## Scope

`v0.99 Act 1 Mission Presentation, Objective Clarity, and Narrative Polish` is campaign presentation and copy polish only. It changes mission descriptions, briefing copy, compact mission-panel next-step copy, Results overview copy, tests, visual QA, package metadata, and docs. It does not add nodes, change unlock rules, rewards, difficulty, AI, saves, stable IDs, broad branding, art, imported assets, or desktop work.

## Runtime Changed

- Act 1 node descriptions were shortened into one-line premises.
- Several Act 1 briefings now lead with clearer primary objectives and shorter reward/after-action copy.
- Campaign selected-mission panels now show either a lock reason or recommended next step in the compact default view.
- Results overview now uses campaign primary objective copy and Act 1 next-step guidance when a campaign completion result exists.
- Captain Malrec's visible flavor copy now frames him as disciplined, dangerous, and convinced controlled Lume prevents collapse.

## Save Format

No save-version bump. No save fields changed. No serialization or migration code changed. Old saves continue to use the existing campaign normalization and stable IDs.

## Stable IDs

No stable IDs were renamed. v0.99 explicitly preserves campaign node IDs, map IDs, faction IDs, resource terms, class IDs, unit IDs, building IDs, relic IDs, save fields, and `CURRENT_SAVE_VERSION`.

## Tests Added or Extended

- Mission-card premise and stable-ID guard coverage.
- Lock-reason and recommended-next-step coverage.
- Results primary objective and finale next-step coverage.
- Content-validation guards for Aether Well Ruins, Ashen Outpost objective copy, Mana, Aether resource copy, and save version.
- Visual-QA coverage for every Act 1 presentation node and the finale Results summary.
- Package validation coverage for v0.99 docs and checkpoint metadata.

## Verification

```text
npm test -- src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts - PASS, 4 files / 87 tests.
npm test - PASS, 98 files / 704 tests after updating one stale Old Stone Road metadata assertion to the new concise objective.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests after one transient Tutorial overlay bounding-box failure passed exact rerun and full-lane rerun.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests after updating two stale hosted copy assertions and rerunning the exact failures plus the full lane.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 15 tests / 136 screenshots / 0 console errors / 0 screenshot retries after the first 30-minute tool timeout was rerun with a longer timeout.
npm run visual:review-pack - PASS, 136 screenshots / 7 contact sheets.
npm run package:playtest - PASS for the pre-commit dirty package; final clean package is generated after commit.
npm run verify:playtest-package - PASS, 357 checks on the pre-commit dirty package.
git diff --check - PASS.
```

## Package

Package metadata now names v0.99 and includes the v0.99 docs/retest checklist. The final clean package is generated after the exact v0.99 commit.

## Non-Pass Evidence Resolved

- Initial full `npm test` found one stale Old Stone Road mission-metadata assertion for the old `hold the road economy` phrasing. The assertion now checks the new concise objective and the full suite reran green.
- Initial hosted smoke found one transient Tutorial overlay bounding-box read returning `null`; the exact test reran green, then the full hosted smoke lane reran green.
- Initial hosted deep-campaign-pressure found two stale after-action copy assertions for Old Stone Road and Ashen Outpost. They now expect the v0.99 copy and both exact tests plus the full lane reran green.
- Initial `visual:qa` exceeded the 30-minute tool timeout without returning pass/fail output. Generated `visual-qa/latest` artifacts were cleaned and the full visual QA reran with a longer timeout, passing with 136 screenshots.
