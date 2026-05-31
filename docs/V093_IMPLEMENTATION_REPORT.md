# v0.93 Implementation Report

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Summary

v0.93 promotes the v0.88 design-token proposal into a first runtime CSS-token layer, applies a focused typography/hierarchy polish across existing UI surfaces, and fixes the Salto selected-mission panel reset path. It is a presentation-foundation and bugfix checkpoint only.

## Runtime Changed

- Added `src/game/styles/tokens.css` and imported it before the existing UI styles.
- Mapped base shell colors, panel variables, typography defaults, and key UI surfaces to token names.
- Improved typography readability for campaign, Results, HUD, command panel, character creation, and inventory surfaces.
- Enlarged campaign node click targets while preserving route visibility and non-overlap requirements.
- Reset selected mission panel scroll/details state when changing campaign nodes.
- Added v0.93 layout regression and visual-QA capture coverage.
- Updated playtest package metadata/copy rules so v0.93 docs are included and the package checkpoint names v0.93.

## Save Format

No save-version bump. No save fields, localStorage keys, stable IDs, serialized IDs, reward fields, XP, campaign progression, replay rules, Tutorial state, settings, or package folder naming changed.

## Gameplay Boundary

No gameplay systems, balance values, maps, factions, units, buildings, races, rewards, campaign unlock logic, Lume rules, Retinue rules, enemy AI, pathing, desktop implementation, runtime title, public title, image generation, imported art, or runtime assets changed.

## Tests

Added/updated coverage for:

- Salto selected-mission panel reset from a scrolled locked-node details state;
- node click target size;
- primary mission action above the fold;
- details disclosure reset;
- campaign save reward/progression arrays unchanged;
- readable campaign typography at `1366x768`;
- no campaign node overlap;
- no horizontal/text overflow;
- no nested-card clutter;
- visual-QA screenshot for the Salto reset state.

## Verification

Pre-commit verification evidence:

```text
npm test - PASS, 93 files / 683 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 26 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run visual:qa - PASS, 9 tests / 65 screenshots / 0 browser console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 65 screenshots / 7 contact sheets.
```

Final `git diff --check`, package generation, and package verification run during final commit/package closeout.

Non-pass evidence:

- First `npm test` after adding package validation requirements failed because the complete-package fixture did not include the new v0.93 docs; the fixture was updated without weakening validation.
- First focused v0.93 Playwright run showed panel focus was not retained after node-selection DOM replacement; focus is now reapplied after the render/default-click cycle.
- First `npm run test:e2e:smoke:fast` showed the fresh campaign map height was `408.7px` against a `410px` acceptance floor; campaign shell vertical gap was tightened and the rerun passed.
- First `npm run visual:qa` captured 65 screenshots successfully, but the deterministic expected count still said 64; the harness was updated and the rerun passed.
- First post-commit `npm run verify:playtest-package` correctly failed because the package generator had not copied the newly required v0.93 docs; package copy metadata was updated before the final package was regenerated.

## Package

Package generation and verification are run after the final checkpoint commit so playtest build info can reference the exact clean commit.

## Deferred

- Broader token migration across every CSS selector.
- Final art direction and generated/imported assets.
- Desktop runtime/engine implementation.
- Public title/runtime rebrand.
- v0.94.
