# v0.46 Difficulty Pacing Foundation Implementation Report

Date: 2026-05-29

## Scope

v0.46 adds small data-driven difficulty pacing metadata to Act 1. The pacing layer explains how missions should read to the player without changing global balance, enemy pathing, or broad AI behavior.

## Pacing Metadata

Initial pacing tiers are:

- Training: Tutorial / Proving Grounds, no campaign save or reward state.
- Low: Border Village, light persistent campaign battle.
- Standard: Old Stone Road and Aether Well Ruins, economy/resource-control focus.
- Milestone: Bandit Hillfort and Ashen Outpost, rival/champion pressure and preparation copy.
- Replay: completed battle cleanup with reduced rewards and one-time objective safety.

## Runtime Changes

- Act 1 step metadata now declares pacing tier, difficulty pacing copy, mechanic focus, and recommended build tags.
- Campaign node details expose pacing tier and mechanic focus using existing guidance cards and grid rows.
- Results campaign reward blocks show Act 1 step, unlock summary, next action, and replay hint.
- Scenario modifiers remain the v0.43 mission-local hooks. This checkpoint adds no new modifiers and no global rebalance.

## Farming Safety

The checkpoint keeps the v0.39-v0.41 reward model:

- first-clear rewards remain one-time;
- replay rewards stay reduced;
- unique relic rewards do not duplicate;
- optional objective credit records once;
- Tutorial / Proving Grounds remains no-save and no-reward.

## Save Format

No save-version bump and no new save fields. Pacing metadata is content-driven and can be changed without migrating old saves.

## Verification

Focused verification completed before full release closeout:

```text
npm test PASS, 74 files / 570 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "first campaign battle path|Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 3 hosted tests.
```

Final release verification is recorded in `docs/V047_IMPLEMENTATION_REPORT.md`.

## Deferrals

- Dynamic difficulty scaling.
- New wave system.
- Randomized modifiers.
- New enemy AI planner.
- Player-selected difficulty mutators.
