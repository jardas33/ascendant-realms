# v0.15 Control, Combat, And Behaviour Fix Report

Date: 2026-05-19  
Baseline commit: 5ab64f5ec56324ba0f9abd4d69d51f109e0adeca  
Status: runtime implementation and full verification green; package closeout in progress

## What Was Built

v0.15 adds a narrow RTS control foundation on top of the v0.14.x human playtest fixes:

- session-only unit behaviour modes;
- selected-unit and selected-group behaviour controls;
- clearer current-order copy for behaviour modes, attack targets, and repositioning;
- attack-hover reliability coverage across HUD refresh;
- a guard against empty left-clicks becoming attack orders;
- a stricter move-away suppression rule so reacquisition cannot happen on the same frame the retreat window expires;
- focused combat tests for Hold Ground, Guard Area, Press Attack, melee contact, direct attack labels, and retreat suppression.

## Behaviour Modes

Implemented:

- `Hold Ground`
- `Guard Area`
- `Press Attack`

Default:

- `Guard Area`

Storage:

- session-only on live units;
- no save field;
- no save migration.

Group behavior:

- selected groups show shared mode or `Mixed`;
- clicking a mode applies it to all alive selected player units.

Deferred:

- Patrol;
- Escort/follow-anchor;
- return-to-anchor memory;
- saved stance preferences;
- icons or new art.

## Attack Intent Changes

Attack-hover and click behavior remains original and current-style:

- selected player units hovering a visible hostile or neutral combat target get the existing crosshair cursor and `data-battle-cursor="attack"`;
- left-clicking that target issues an attack order;
- right-click attack remains intact;
- attack cursor state survives HUD refresh and clears when the pointer leaves the target;
- empty left-clicks do not issue attack orders;
- selected-unit order copy can now show the target label for explicit attack orders.

This does not add protected UI, external icons, or copied RTS layout.

## Melee Engagement Changes

v0.15 keeps the v0.14.4 visual-contact melee interpretation and layers behaviour-mode rules around it:

- adjacent melee units still attack without nudging;
- Hold Ground units attack immediate-range/contact enemies;
- Guard Area units reacquire nearby threats;
- Press Attack units pursue inside a larger bounded leash;
- explicit move-away suppression still protects retreat intent before reacquisition resumes.

No unit HP, damage, range, cooldown, speed, armor, map, faction, or spawn data changed.

## Retreat / Move-Away Changes

Retreat remains a command-intent feature, not invulnerability:

- normal move orders clear explicit attack targets;
- the suppression window now remains effective for the frame in which it reaches zero;
- units do not reacquire the same target on that expiry frame;
- enemies can still chase, attack, and deal damage;
- blocked paths still use the existing movement failure feedback.

Order copy now uses `Repositioning` while the move-away window is active.

## Marquee / HUD / Minimap Safeguards

The v0.14.4 and v0.14.5 safeguards remain in place:

- drag selection continues across DOM HUD and minimap surfaces;
- release over side panel clears active marquee state and selects battlefield units;
- release over minimap clears active marquee state;
- minimap click camera movement remains explicitly asserted;
- stale-selection HUD/minimap deferral fixes remain protected.
- hero-select hotkey refreshes the HUD immediately after HUD/minimap focus interactions;
- the expanded side panel scrolls sooner so Cinderfen/Ashen focus landmarks remain visible.

No hosted release restructuring was needed for v0.15.

## Tutorial And Tester Copy

Updated tester-facing controls copy explains:

- enemy hover attack intent;
- left-click enemy attack order;
- Hold Ground / Guard Area / Press Attack buttons;
- retreat/move-away expectations.

Tutorial runtime steps were not lengthened in this pass.

## What Emmanuel Should Retest

1. Select unit, hover enemy, confirm attack intent.
2. Left-click enemy, confirm attack command.
3. Hero beside Stone Imp/Raider attacks without nudging.
4. Enemy beside hero attacks without nudging.
5. Set Hold Ground and confirm unit does not chase distant enemy.
6. Set Guard Area and confirm default defensive behaviour.
7. Set Press Attack and confirm stronger pursuit within reason.
8. Retreat from combat and confirm unit visibly obeys.
9. Drag-select across HUD/minimap.
10. Complete tutorial / lose tutorial still work.
11. Confirm no snap-back loop.

## Verification

```text
npm test PASS, 55 files / 393 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-5ab64f5-dirty`.
npm run verify:playtest-package PASS, 19 checks.
git diff --check PASS.
```

The clean post-commit package path is recorded in the final handoff.
