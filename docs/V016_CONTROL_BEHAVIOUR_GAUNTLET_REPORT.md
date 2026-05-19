# v0.16 Control Behaviour Gauntlet Report

Date: 2026-05-19
Starting commit: `27dfe1a` (`Checkpoint v0.15 RTS control behaviour foundation`)
Final commit: the v0.16 checkpoint commit created from this report; the exact hash is assigned after commit and recorded in the final handoff.
Scope: automated confidence, diagnostics, regression coverage, package hardening, and Emmanuel retest preparation for the v0.15 behaviour-mode/control foundation.

## CI Baseline

GitHub Actions inspected: partially.

- Local `gh` CLI: unavailable.
- GitHub connector query for commit `27dfe1a1ec060708c831690c4bfa806b0d06cb32`: no PR-triggered workflow runs returned.
- Combined commit status query for the same SHA: no statuses returned.
- Latest v0.15 CI Release Matrix Dry Run status from this environment: unknown.

No red Actions lane was visible locally, so v0.16 proceeded from the clean, synced, local-green v0.15 baseline.

## Files Changed

Docs:

- `docs/V016_BASELINE_AND_CI_AUDIT.md`
- `docs/V016_BEHAVIOUR_MODE_AUDIT.md`
- `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`
- `docs/V016_EMMANUEL_CONTROL_RETEST_SCRIPT.md`
- `docs/V016_PRIVATE_PLAYTEST_CONTROL_ROUTE_CARD.md`
- `docs/V016_BEHAVIOUR_MODE_TESTER_CHECKLIST.md`
- `docs/V016_CONTROL_FEEDBACK_INTAKE_TEMPLATE.md`
- `docs/V016_CONTROL_REGRESSION_TRIAGE_GUIDE.md`
- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `RELEASE_CHECKLIST.md`
- `README.md`
- `ROADMAP.md`

Code and package tools:

- `src/game/systems/CombatSystem.ts`
- `src/game/playtest/PlaytestPackageValidation.ts`
- `src/game/playtest/ScriptedBattlePlaytest.ts`
- `src/game/playtest/ControlBehaviourScenarioTypes.ts`
- `src/game/playtest/ControlBehaviourScenarioProfiles.ts`
- `src/game/playtest/ControlBehaviourScenarioRunner.ts`
- `src/game/playtest/ControlBehaviourScenarioReportWriter.ts`
- `src/game/playtest/ControlBehaviourScenarioValidation.ts`
- `tools/runControlBehaviourLab.ts`
- `tools/verifyControlBehaviourLabOutputs.ts`
- `tools/packagePlaytestBuild.ts`
- `package.json`

Tests:

- `src/game/systems/BehaviourModeSystem.test.ts`
- `src/game/systems/CombatSystem.test.ts`
- `src/game/ui/UnitOrderSummary.test.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.test.ts`
- `src/game/playtest/PlaytestPackageValidation.test.ts`
- `src/game/playtest/ControlBehaviourScenarioLab.test.ts`
- `tests/e2e/deep-flow.spec.ts`

Generated outputs:

- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`
- `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`

## Runtime Status

- Runtime gameplay changed: yes, narrowly.
- Gameplay numbers changed: no.
- Save format changed: no.
- Runtime art/assets changed: no.
- Behaviour modes changed: yes, but only to align Hold Ground direct-attacker response with the v0.15 spec.
- New behaviour modes added: no.
- Patrol implemented: no.
- Package changed: yes, package validation and package contents now include v0.16 control retest materials.

The only runtime fix was in `CombatSystem`: Hold Ground now may pursue a nearby enemy that is directly attacking the unit within the existing local aggro radius. Hold Ground still refuses idle distant threats, and no unit data, range, damage, cooldown, HP, speed, economy, wave timing, map, faction, unit, save, or asset data changed.

## Control Lab Coverage

Scripts added:

- `npm run playtest:controls`
- `npm run playtest:controls:extended`
- `npm run playtest:controls:verify`

The deterministic lab covers:

1. Hold Ground Contact Defence
2. Hold Ground Distant Threat Refusal
3. Guard Area Default Local Defence
4. Press Attack Bounded Pursuit
5. Explicit Attack Overrides Mode
6. Move-Away Suppression
7. Post-Kill Adjacent Reacquisition
8. Group Mixed Mode Application
9. Attack Cursor/Intent Integrity
10. HUD/Minimap/Selection Regression Protection

Normal run result: 10 rows, 10 pass, 0 fail.
Extended run result: 5 deterministic iterations, 50 rows, 50 pass, 0 fail.
Verifier result: 930 consistency checks passed.

The lab does not prove:

- human fun;
- balance quality;
- multiplayer readiness;
- stochastic robustness;
- visual appeal;
- every possible pathing or formation edge case;
- Emmanuel's manual retest result.

The lab is deterministic automated evidence only. It does not invent or replace human feedback.

## Browser Gauntlet

The new hosted browser gauntlet in `tests/e2e/deep-flow.spec.ts` covers:

- selecting the hero and confirming default Guard Area copy;
- switching Hold Ground, Guard Area, and Press Attack through HUD controls;
- Hold Ground distant threat refusal;
- attack hover cursor intent on a valid hostile;
- left-click hostile attack ordering;
- Guard Area nearby response;
- Press Attack bounded pursuit intent;
- retreat/move-away feedback without same-tick snap-back;
- marquee cleanup while crossing the side panel;
- minimap camera movement after behaviour controls;
- `H` hero-select refresh after HUD/minimap interaction.

Targeted repeat result:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "behaviour mode control gauntlet" --repeat-each=3 --retries=0 --reporter=line
PASS, 3 passed.
```

The gauntlet uses direct DOM clicking only for real HUD mode buttons after hosted re-render/actionability evidence showed the buttons could detach during normal Playwright click actionability. Canvas/world interactions still use real pointer input. No force-clicks or DOM fallback world clicks were added.

## Verification

Required gates run for v0.16:

```text
npm test
PASS, 56 files / 406 tests.

npm run build
PASS with known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 metadata JSON and 0 review manifests checked.

npm run test:e2e:smoke:fast
PASS, 7 tests.

npm run test:e2e:smoke
PASS, 13 tests.

npm run visual:qa
PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.

npm run smoke:preview
PASS against production preview.

npm run playtest:sim
PASS, 255 runs across 85 campaign battle nodes.

npm run playtest:lab:verify
PASS, 63 checks.

npm run playtest:controls
PASS, 10 rows / 10 pass.

npm run playtest:controls:extended
PASS, 50 rows / 50 pass.

npm run playtest:controls:verify
PASS, 930 checks.

npm run test:e2e:release:hosted:deep-meta
PASS, 12 tests.

npm run test:e2e:release:hosted:deep-battle
PASS, 12 tests.

npm run test:e2e:release:hosted:deep-campaign-pressure
PASS, 7 tests.

npm run test:e2e:release:hosted:layout-core
PASS, 20 tests.

npm run test:e2e:release:hosted:layout-cinderfen
PASS, 12 tests.

npm run test:e2e:release:hosted:smoke
PASS, 13 tests.

npm run test:e2e:release:shard1of3
PASS, 29 tests.

npm run test:e2e:release:shard2of3
PASS, 34 tests.

npm run test:e2e:release:shard3of3
PASS, 13 tests.

npm run test:e2e:release
PASS, 76 tests.

npm run package:playtest
PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-27dfe1a-dirty`.

npm run verify:playtest-package
PASS, 24 checks for the dirty package.
```

One earlier `npm run test:e2e:release` attempt hit the shell timeout at 40 minutes before returning output. The orphaned process was stopped, the release suite passed in 3 existing shards, and the exact all-in-one command then passed with a longer timeout.

`git diff --check` is run immediately before commit.

## Package

Pre-commit dirty package:

```text
artifacts/playtest/ascendant-realms-private-playtest-27dfe1a-dirty
```

Clean package expectation after commit:

```text
artifacts/playtest/ascendant-realms-private-playtest-<final-v0.16-commit>
```

The clean package must be regenerated and verified after the v0.16 commit so build metadata has no dirty suffix.

## GitHub Actions Recommendation

Rerun GitHub Actions after push. v0.16 changes runtime combat/control behaviour narrowly, adds a new hosted gauntlet, expands deterministic diagnostics, and changes private package validation. The local hosted/release gates are green, but the remote CI Release Matrix Dry Run should still be rerun for hosted runner confidence.

## Emmanuel Manual Retest Checklist

1. Select the hero/unit and confirm Guard Area appears by default.
2. Switch Hold Ground and confirm the unit does not chase a distant hostile without an explicit attack.
3. Hover a valid hostile and confirm attack intent.
4. Left-click the hostile and confirm an attack order appears.
5. Put hero beside a Stone Imp/Raider-style hostile and confirm contact attacks happen without nudging.
6. Confirm an enemy beside the hero attacks without nudging.
7. Switch Guard Area and confirm normal nearby defensive response.
8. Switch Press Attack and confirm stronger but reasonable pursuit.
9. Retreat/move away from combat and confirm visible movement without instant snap-back.
10. Drag-select across HUD and minimap after using behaviour controls.
11. Use the minimap, then press `H`, and confirm the side panel is not stale at `No Selection`.
12. Complete Tutorial and lose Tutorial to confirm no-save/no-reward Results flows still work.

## Deferred

- Patrol runtime behaviour.
- Save-persistent behaviour preferences.
- Formation or pathing rewrite.
- Broad combat AI rewrite.
- Balance tuning.
- Runtime art or icon additions.
- Visual overhaul.
- New maps, factions, or units.
- Human-feedback claims before Emmanuel retests the package.
