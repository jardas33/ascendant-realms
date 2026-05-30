# v0.83 Implementation Report

## Scope

v0.83 rescues the campaign map presentation and adds one private playtest quick-launch path for the existing Aether Well Lume runtime slice. It does not add maps, factions, art, save fields, rewards, balance changes, Lume rules, desktop work, multiplayer, or broad runtime copy migration.

## Runtime Changes

- Campaign Map now opens on a map-first tab with the node map, selected-node summary, and primary action visible together.
- Stronghold, Hero, Inventory, Intel, and Reputation surfaces moved behind existing-style campaign tabs.
- Selected mission details remain available through a More Details disclosure.
- Private playtest tooling is visible only in development builds or packages that explicitly inject `window.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__ = true`.
- The private Aether Well Lume demo launches `aether_well_ruins` on `broken_ford` while bypassing campaign prerequisites.
- The private demo uses `rewardsDisabled: true` and adds HUD/Results no-save copy.
- Generic no-reward campaign launches still do not enable Lume; the exception is scoped to the explicit private demo id.

## Save Format

No save-version bump. No save fields were added, removed, renamed, or migrated. The private demo does not persist campaign node completion, battle rewards, hero XP, Retinue status, rival state, reputation, resource rewards, relic rewards, or optional-objective credit.

## Package Changes

- Private playtest packages inject the explicit private-tool flag into `game/index.html`.
- Package validation now requires the v0.83 docs and the private playtest tool marker.
- Package build info now names `v0.83 campaign map UX rescue and private playtest quick launch`.

## Testing Added

- Focused Lume launch gating coverage for normal campaign, no-reward campaign, Tutorial, and explicit private-demo launches.
- Battle launch request coverage for private demo metadata and disabled tactical plans.
- Results coverage for private demo no-save summary.
- Smoke coverage for campaign map node-card overlap and the private Lume demo no-save path.
- Visual QA coverage for the map-first campaign layout at 1920x1080 and 1366x768, plus private Lume demo HUD screenshots.

## Verification

```text
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/battle/BattleLaunchRequest.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 4 files / 45 tests.
npm test PASS, 87 files / 656 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx playwright test tests/e2e/smoke.spec.ts --grep "new campaign flow|private playtest" --reporter=line PASS, 2 tests.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 26 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-319730c-dirty` generated.
npm run verify:playtest-package PASS, 258 checks against the dirty pre-commit package.
```

Final clean package generation should be repeated after the closeout commit so the package folder has no `-dirty` suffix.
