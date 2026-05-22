# v0.16.8 Control Lab v0.16.7 Coverage Review

Date: 2026-05-22

## Review Question

Does the deterministic control behaviour lab explicitly cover Emmanuel's v0.16.7 manual combat/contact issues?

## Existing Coverage Before This Pass

The lab already covered:

- Hold Ground contact defence
- Hold Ground distant-threat refusal
- Guard Area default local defence
- Press Attack bounded pursuit
- explicit attack overriding Hold Ground
- move-away suppression / same-frame snap-back prevention
- post-kill adjacent reacquisition
- mixed group mode application
- browser-owned attack cursor and HUD/minimap contracts

This was enough for adjacent post-kill reacquisition and retreat suppression, but it did not explicitly measure local melee enemy building aggro or the hover tolerance boundary between visible enemy footprint and nearby empty terrain.

## v0.16.8 Lab Additions

Added two deterministic, narrow scenarios:

- `enemy_melee_building_aggro`
  - Confirms an enemy melee unit can damage a local hostile Command Hall-sized building footprint.
  - Does not add or imply global building chase.
  - Does not tune waves, HP, damage, aggro radius, or balance.

- `attack_hover_tolerance_boundary`
  - Confirms the interaction hit-test reaches a visible enemy body edge.
  - Confirms nearby empty terrain remains non-targetable.
  - Does not replace browser cursor rendering or real left-click attack coverage.

## Files Changed

- `src/game/playtest/ControlBehaviourScenarioTypes.ts`
- `src/game/playtest/ControlBehaviourScenarioProfiles.ts`
- `src/game/playtest/ControlBehaviourScenarioRunner.ts`
- generated control lab outputs:
  - `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`
  - `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`
  - `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`
  - `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`
  - `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`
  - `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`

## Verification

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts
PASS: 5 files, 38 tests.

Focused unit soak:
same command repeated 10 times.
PASS: 10/10 iterations, no flakes.

Control lab regeneration and verification:
npm run playtest:controls
npm run playtest:controls:extended
npm run playtest:controls:verify

Repeated control lab cycles:
PASS: 3/3 cycles.
Final generated normal lab: 12 scenarios, 12 pass rows, 0 fail rows.
Final generated extended lab: 12 scenarios, 5 iterations, 60 pass rows, 0 fail rows.
Final verifier: PASS, 1112 checks.
```

## Coverage Decision

The control behaviour lab now explicitly covers all v0.16.7 manual issue classes at deterministic-system level:

- adjacent/contact melee after first kill
- Hold Ground distant refusal
- local melee enemy building aggro
- move-away suppression / retreat snap-back prevention
- attack hover tolerance versus empty terrain

Browser-level coverage remains responsible for real canvas hover, cursor state, left-click attack, HUD/minimap, and tutorial flow.
