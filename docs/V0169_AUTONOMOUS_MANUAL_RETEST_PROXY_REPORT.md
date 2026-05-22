# v0.16.9 Autonomous Manual-Retest Proxy Report

Date: 2026-05-22

## Implementation

Extended the deterministic control behaviour lab with six scenarios that directly proxy the v0.16.7 manual checklist and stress nearby combat edge cases:

- `manual_proxy_hold_ground_adjacent_followup`
- `manual_proxy_group_retreat_resume`
- `combat_edge_hero_three_melee_followup`
- `combat_edge_two_friendlies_three_enemies`
- `combat_edge_building_aggro_matrix`
- `combat_edge_mode_difference_matrix`

Added a focused `CombatSystem` unit test for ranged enemy building aggro so the building matrix covers both melee contact and ranged targeting without changing runtime code.

## Generated Evidence

Latest control-lab output after v0.16.9 additions:

- normal lab: 18 scenarios, 18 pass rows, 0 fail rows
- extended lab: 18 scenarios, 5 deterministic iterations, 90 pass rows, 0 fail rows
- verifier: PASS, 1658 checks

## Focused Verification So Far

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts
PASS: 2 files, 29 tests.

Focused repeat:
same command repeated 5 times.
PASS: 5/5, no flakes.

npm run playtest:controls
PASS: 18 scenarios, 18 pass rows, 0 fail rows.

npm run playtest:controls:extended
PASS: 18 scenarios, 5 iterations, 90 pass rows, 0 fail rows.

npm run playtest:controls:verify
PASS: 1658 checks.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|manual combat contact regression" --repeat-each=3 --reporter=line
PASS: 6/6 in 2.8m.
```

## Findings

No deterministic or hosted proxy regression was found in the v0.16.7 combat/contact fix areas. The proxy still requires Emmanuel's real manual retest because automated evidence cannot judge feel, readability, or whether the cursor is subjectively clear enough.
