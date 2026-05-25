# v0.21.3 Worker Explicit Attack Damage And Status Clarity

Date: 2026-05-24
Status: runtime polish/checkpoint closeout

## Scope

v0.21.3 follows Emmanuel's FAIL / MIXED retest of the latest v0.21.x Worker repair/intent package. The pass fixes Worker explicit attack damage visibility/proof and clarifies the Burn/status marker that previously looked like a red/orange dot at the start of the health bar.

No harvesting, enemy repair AI, enemy construction AI, new units/buildings/maps/factions, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or test weakening are included.

## Baseline

- Starting local commit: `5b33fc5`, `Checkpoint v0.21.3 worker intent closeout and CI verification`.
- Branch state at start: clean `main`, ahead of `origin/main` by one local commit.
- Emmanuel retest result: Worker could move to an enemy building after explicit attack but did not show damage numbers or visible HP reduction; Burn/status marker still read like a health-bar artifact.

## Runtime Changes

- Explicit Worker attack against buildings now has a narrow building-only damage floor when the Worker has an explicit attack target. This keeps the Worker weak while making real enemy-building HP reduction measurable through the existing combat system.
- Combat damage callbacks now include the damage source, allowing Worker explicit building hits to show floating damage even though small enemy-side hits normally stay filtered.
- Idle Workers still do not auto-attack enemy buildings by proximity.
- Burn/status markers now render as a small labeled `BURN` chip above the health bar instead of an unlabeled dot aligned with the bar fill.
- Burn/status floating text and normal HP reduction remain intact.

## Docs And Package Metadata

- Added `docs/V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md`.
- Added `docs/V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md`.
- Package checkpoint string should read `v0.21.3 worker explicit attack damage and status clarity`.
- Private playtest packages should include this closeout note plus the v0.21.3 intake and cursor note.

## Emmanuel Retest Checklist

1. Use the clean v0.21.3 private playtest package.
2. Select a Worker and explicitly order it to attack an enemy building.
3. Confirm the Worker moves into contact/range.
4. Confirm the enemy building HP decreases measurably.
5. With floating text enabled, confirm Worker building hits show damage numbers.
6. Confirm an idle Worker near an enemy building does not auto-attack by default.
7. Confirm Worker Repair still only applies to damaged friendly completed buildings.
8. Confirm construction/repair still require explicit Worker commands plus range.
9. Have a ranged Burn enemy damage a Worker or other unit.
10. Confirm HP decreases normally and Burn/status feedback is preserved.
11. Confirm the Burn marker reads as status feedback and no longer looks like a red dot embedded in the health bar.
12. Do not judge harvesting, resource-dropoff economy, repair cost balance, enemy repair/construction AI, save persistence, new content, new cursor art, or final art in this build.

## Verification

Requested v0.21.3 gate:

```text
npm test PASS, 65 files / 487 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Worker explicit attack damages" --reporter=line PASS, 1 focused Worker attack regression.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-5b33fc5-dirty generated.
npm run verify:playtest-package PASS, 62 checks.
git diff --check PASS.
```

Closeout note: regenerate and verify the final clean package again after the final v0.21.3 commit so the package name and build info use the final commit hash and do not end in `-dirty`.
