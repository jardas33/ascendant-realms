# v0.16.8 Combat Fix Soak Report

Date: 2026-05-22

## Scope

Automated soak focused on v0.16.7's runtime changes:

- adjacent/contact melee reacquisition after first kill
- Hold Ground immediate/contact threat handling and distant refusal
- Guard Area default local defence
- Press Attack bounded pursuit
- local melee enemy building aggro
- retreat / move-away suppression
- attack hover tolerance and empty terrain non-targeting
- tutorial/result sanity through smoke coverage

No runtime gameplay code was changed during this soak. The only code changes in v0.16.8 were deterministic control-lab scenario additions and one smoke test assertion stabilization.

## Focused Unit/System Soak

Command:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts
```

Initial result:

```text
PASS: 5 files, 38 tests.
```

Repeat soak:

```text
same command repeated 10 times
PASS: 10/10 iterations, no flakes.
```

Coverage included:

- `CombatSystem.test.ts`: 24 tests
- `CollisionSystem.test.ts`: 3 tests
- `MovementSystem.test.ts`: 3 tests
- `BehaviourModeSystem.test.ts`: 4 tests
- `ControlBehaviourScenarioLab.test.ts`: 4 tests

## Hosted Manual Combat Regression Soak

Command:

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --repeat-each=5 --reporter=line
```

Result:

```text
PASS: 5/5, 1.6m, no flakes.
```

Covered:

- adjacent follow-up after first kill
- enemy melee building aggro
- retreat suppression near multiple enemies
- hover tolerance and nearby empty-terrain non-targeting

## Control Lab Soak

Commands repeated as a cycle:

```text
npm run playtest:controls
npm run playtest:controls:extended
npm run playtest:controls:verify
```

Repeat count:

```text
PASS: 3/3 cycles.
```

Final generated outputs:

- normal lab: 12 scenarios, 12 pass rows, 0 fail rows
- extended lab: 12 scenarios, 5 iterations, 60 pass rows, 0 fail rows
- verifier: PASS, 1112 checks

New v0.16.8 deterministic scenarios:

- `enemy_melee_building_aggro`
- `attack_hover_tolerance_boundary`

## Hosted Release Lanes

```text
npm run test:e2e:release:hosted:deep-battle
PASS: 14 tests in 4.4m.
```

```text
npm run test:e2e:release:hosted:smoke
First run: FAIL, 1 failed / 13 passed.
Failure: hosted smoke Cinderfen Crossing test relied on transient battle-status map/difficulty text after the battle had already advanced to AI status.
Fix: test-only assertion stabilization in tests/e2e/smoke.spec.ts; deterministic BattleScene state still asserts map, campaign node, reward table, mode, and difficulty.
Targeted rerun: PASS, 1 test in 27.7s.
Full affected lane rerun: PASS, 14 tests in 2.9m.
```

## Full Smoke

```text
npm run test:e2e:smoke:fast
PASS: 8 tests in 2.4m.
```

```text
npm run test:e2e:smoke
PASS: 14 tests in 7.0m after the hosted smoke assertion fix.
```

## Full Local Release Soak

```text
npm run test:e2e:release
PASS: 79 tests in 38.7m.
```

## Visual QA

```text
npm run visual:qa
PASS: 5 tests in 4.4m.
18 screenshots captured.
Browser console errors: 0.
Screenshot retries: 0.
```

## Flake Classification

One flake/failure appeared:

- command: `npm run test:e2e:release:hosted:smoke`
- test: `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards @extended-smoke`
- classification: hosted timing issue / transient status-line assertion
- fix needed: yes, test-only
- runtime regression: no
- reproduced/fixed by targeted local hosted rerun: yes

No combat/contact/aggression/retreat runtime regression was found during the soak.

## Soak Verdict

Automated evidence supports the v0.16.7 combat/contact fixes. Emmanuel should still manually retest because this soak is deterministic automated evidence, not human feedback.
