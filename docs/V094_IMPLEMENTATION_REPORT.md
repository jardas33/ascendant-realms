# v0.94 Implementation Report

## Summary

v0.94 is a presentation-only usability pass for out-of-battle surfaces.

## Runtime Changed

- Main menu composition now uses a wider two-region panel with grouped Play, Practice, and Manage actions.
- Ascendant creation is organized into Step 1 Choose Class, Step 2 Choose Origin, and Step 3 Review Hero.
- Campaign map presentation uses a slightly larger workspace, clearer selected routes, dimmer future content, and larger node labels.
- Selected mission panel default content is compacted into status, description, objective, reward chips, difficulty, action, and More Details.
- Campaign tabs use a clearer card hierarchy with summary and action/detail separation.
- Ordinary Results expanded details use accordion groups.

## Save Format

No save format changes.

## Gameplay / Progression

No gameplay, reward, hero-rule, campaign progression, stable id, map, faction, or art changes.

## Tests Added

- Focused layout assertions for v0.94 menu, Ascendant creation, campaign density, tabs, and ordinary Results details.
- Visual QA captures for all required v0.94 presentation states.
- Package validation coverage for v0.94 docs and checkpoint metadata.

## Verification

Passed:

- `npm test` - 93 files / 683 tests.
- `npm run build` - passed with the known Vite Phaser vendor chunk-size warning.
- `npm run validate:content`.
- `npm run validate:art-intake` - 1 candidate metadata JSON file, 0 review manifests.
- `npm run test:e2e:smoke:fast` - 9 tests.
- `npm run test:e2e:smoke` - 16 tests.
- `npm run playtest:controls` - 18 scenarios / 18 pass rows.
- `npm run playtest:controls:extended` - 90 pass rows.
- `npm run playtest:controls:verify` - 1658 checks.
- `npm run playtest:act1` - 180 Act 1 runs summarized from 255 deterministic simulator runs.
- `npm run test:e2e:release:hosted:deep-battle` - 29 tests.
- `npm run test:e2e:release:hosted:smoke` - 16 tests.
- `npm run test:e2e:release:hosted:deep-campaign-pressure` - 8 tests.
- `npm run test:e2e:release:hosted:layout-core` - 27 tests.
- `npm run test:e2e:release:hosted:layout-cinderfen` - 12 tests.
- `npm run visual:qa` - 10 tests / 84 screenshots / 0 console errors / 0 screenshot retries.
- `npm run visual:review-pack` - 84 screenshots / 7 contact sheets.

Resolved non-pass evidence:

- Initial fast smoke caught campaign node overlap after label readability changes; node sizing/positions were tightened.
- Initial full smoke timed out before exposing a Results optional-objective detail assertion; the objectives accordion is now open inside expanded details and full smoke passed.
- Hosted layout-core caught mobile-short main-menu overflow; responsive menu columns now collapse cleanly.
- Visual QA caught the locked-mission primary action slightly below the 1366x768 fold; mission-panel pacing copy and spacing were compacted.

## Package

Final clean package generation and package verification are run after the exact closeout commit so the playtest package has no `-dirty` suffix and reports the final commit.
