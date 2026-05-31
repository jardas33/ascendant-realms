# v0.85 Implementation Report

Status: implemented and verified locally before final clean package generation.

## Runtime Changes

- Added contextual Lume link presentation rules in `src/game/battle/LumeNetworkRendering.ts`.
- Added session-only `Links: Auto`, `Links: Always`, and `Links: Hidden` controls to the existing Lume HUD row.
- Changed Auto mode so inactive links are hidden during ordinary play, while the private demo shows only the currently relevant guide link.
- Changed stable active links to a lower-opacity line while keeping activation, restore, contested, severed, selected-endpoint, and Always-mode highlights readable.
- Added render snapshots for visibility mode, visible state, emphasis, pulse kind, alpha, width, and layer depth so hosted tests can guard the overlay behavior.
- Added a private-demo Results branch that uses `PRIVATE DEMO COMPLETE`, moves the Lume summary and no-save/no-reward state above the fold, and keeps full telemetry under `Show Full Battle Details`.
- Updated package generation and package validation to require all v0.85 specs, reports, deferred findings, and Emmanuel retest docs.

## Save Format

No save-version bump. No save fields, localStorage keys, persistent settings, ID renames, reward changes, campaign progression changes, or Lume balance changes were added.

The visibility mode is battle-session-only and defaults to `Auto` on each eligible Lume battle launch.

## Stable IDs And Balance

Preserved unchanged:

- campaign node `aether_well_ruins`
- map `broken_ford`
- sites `west_stone_cut`, `ford_toll`, `north_aether_spring`
- links `west_stone_cut_to_ford_toll`, `ford_toll_to_north_aether_spring`
- benefit `linked_ward`
- damage-taken multiplier `0.92`

## Verification

```text
npx vitest run src/game/battle/LumeNetworkRendering.test.ts src/game/battle/LumeNetworkDirector.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 5 files / 42 tests.
npm test PASS, 88 files / 664 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests. Initial short shell timeout was non-pass evidence; rerun passed.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests. Initial 10-minute shell timeout was non-pass evidence; 15-minute rerun passed.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 29 screenshots / 0 console errors / 0 screenshot retries.
```

Final clean package generation and package verification are run after the final commit so package build info can report a clean tree and the final commit hash.
