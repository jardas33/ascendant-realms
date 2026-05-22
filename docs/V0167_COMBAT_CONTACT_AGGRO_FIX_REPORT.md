# v0.16.7 Combat Contact And Aggro Fix Report

Date: 2026-05-21

## Manual Evidence Used

- Session: `PT-20260521-EMMANUEL-V0166-CONTROLS-01`
- Build: `3737c16`
- Package: `ascendant-realms-private-playtest-3737c16`
- Tester: Emmanuel
- Route: Tutorial
- Browser: Brave
- OS: Windows
- Result: MIXED

Confirmed working from the manual retest:

- Guard Area is default.
- Hold Ground generally does not chase distant enemies.
- Hold Ground responds when directly attacked.
- Left-click enemy attack seems to work.
- Guard Area seems fine.
- Press Attack is not infinite-chasing.
- Drag-select across HUD/minimap works.
- Minimap click plus `H` hero-select does not leave the side panel stuck at `No Selection`.
- Tutorial defeat Results flow works.

Confirmed issues fixed or guarded in this pass:

- Adjacent/contact melee could idle after the first enemy died.
- Enemy melee units could stand beside a player Command Hall/building without attacking.
- Normal move-away/retreat could lose its combat suppression as soon as pathing cleared the move target.
- Attack hover/click intent used a raw small hit circle that did not match the visible unit footprint.

Deferred:

- Worker construction/builders are a future feature/design pass, not a v0.16.7 bugfix.
- Attack cursor art was not replaced because v0.16.7 does not add runtime art/assets. The existing native crosshair cursor remains; the hit tolerance was improved.

## Root Cause

The manual report pointed to four narrow runtime edges rather than a broad behaviour-mode design problem:

- Melee contact used raw range plus circular body radii. That was slightly too strict for small adjacent enemies whose visible sprite/ring read as contact-valid.
- Melee building contact treated buildings like circular targets, while building pathing/obstacles use rectangular footprints. A melee enemy could be visually beside the Command Hall but still outside center-radius attack contact.
- Move-away suppression was cleared by movement/pathing when `moveTarget` disappeared, allowing combat reacquisition to resume immediately near multiple enemies.
- World entity hit testing used raw entity radius. Small hostile units therefore required a tiny hover/click spot even though their visible body/health/selection footprint was larger.

## Runtime Changes

- `CombatSystem`:
  - Increased the melee visual contact margin from `14` to `18`.
  - Uses building footprint diagonal radius for melee unit-vs-building contact.
  - Keeps player move-away combat suppression active for the short suppression window even if `moveTarget` has already cleared, as long as there is no explicit attack/attack-move order.
- `MovementSystem`:
  - Stops erasing move-away suppression only because there is no path target or because the current waypoint list ended.
  - Still clears suppression when a unit actually reaches its commanded destination.
- `CollisionSystem` and `BattleScene`:
  - Added optional interaction hit-test padding/minimum radius.
  - `BattleScene.findWorldEntityAt` now uses a conservative 24px minimum world interaction radius and 4px unit padding.
  - Empty nearby terrain remains non-targetable.

## Tests Added

- `src/game/systems/CombatSystem.test.ts`
  - Hold Ground reacquires/attacks a second visible-contact hostile after killing the first adjacent enemy.
  - Distant Hold Ground enemies remain unchased.
  - Enemy melee attacks a nearby Command Hall/building footprint.
  - Enemy melee does not globally chase a distant building.
  - Move-away suppression blocks immediate reacquisition near multiple enemies.
- `src/game/systems/MovementSystem.test.ts`
  - Movement does not erase suppression just because pathing has no current target.
- `src/game/systems/CollisionSystem.test.ts`
  - Interaction minimum radius supports enemy hover tolerance.
  - Empty nearby terrain remains empty.
  - Optional padding improves visible unit-body tolerance.
- `tests/e2e/deep-flow.spec.ts`
  - Added a hosted-safe manual combat contact regression covering adjacent follow-up, enemy building aggro, retreat suppression, and hover tolerance.

## What Was Not Changed

- No v0.17 work.
- No worker construction/builders.
- No new units, buildings, maps, factions, patrol runtime, or formations.
- No broad AI/pathing rewrite.
- No gameplay-number tuning.
- No unit stat changes.
- No enemy wave timing changes.
- No save format changes.
- No behaviour-mode persistence changes.
- No runtime art/assets added or replaced.
- No force clicks.
- No DOM fallback for canvas/world clicks.

## Verification Results

Focused:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts
PASS: 3 files, 30 tests.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line
PASS: 1 test in 23.9s.
```

Full/local:

```text
npm test
PASS: 57 files, 414 tests.

npm run build
PASS: TypeScript and Vite build; known Phaser vendor chunk warning only.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: 1 candidate metadata JSON, 0 review manifests.

npm run test:e2e:smoke:fast
PASS: 8 tests in 2.9m.

npm run test:e2e:smoke
First attempt timed out at 6m with no pass/fail result.
Rerun PASS: 14 tests in 7.1m.

npm run playtest:controls
PASS: 10 scenarios, 10 pass rows, 0 fail rows.

npm run playtest:controls:verify
PASS: 930 checks.

npm run test:e2e:release:hosted:deep-battle
PASS: 14 tests in 4.6m.

npm run test:e2e:release:hosted:smoke
PASS: 14 tests in 3.0m.

npm run test:e2e:release
First attempt timed out at 30m with no pass/fail result.
Rerun with a longer local wrapper PASS: 79 tests in 38.8m.

npm run visual:qa
PASS: 5 tests in 4.5m; 18 screenshots, 0 browser console errors, 0 screenshot retries.

git diff --check
PASS.
```

## Manual Retest Checklist

1. Start Tutorial on the v0.16.7 package.
2. Confirm Guard Area remains the default.
3. Put the hero in Hold Ground near two Stone Imps.
4. Let the first adjacent imp die and confirm the second adjacent/contact imp does not idle indefinitely.
5. Confirm Hold Ground still does not chase a distant idle enemy.
6. Drag melee enemies near the Command Hall and confirm they attack the building when no better target is active.
7. Select the hero/group near multiple enemies and issue a normal move-away/retreat command.
8. Confirm the move-away order visibly starts and is not immediately canceled by opportunistic reacquisition.
9. Confirm suppression eventually ends if the unit remains in danger.
10. Hover hostile body/visible-footprint edges and confirm the attack cursor appears more forgivingly.
11. Hover empty terrain near a hostile and confirm it does not become attack intent.
12. Recheck Tutorial defeat Results flow as a sanity pass.
