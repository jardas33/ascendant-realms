# v0.12.2 Human Balance Watchpoint Report

Date: 2026-05-17

Scope: final report for v0.12.2 Human Balance Watchpoint Review. This was a narrow evidence review after the v0.12.1 green checkpoint. It did not add maps, factions, units, art/assets, runtime art, save changes, multiplayer, procedural generation, monetization, broad AI/economy rewrites, hosted CI plumbing, or numeric balance changes.

## What Was Reviewed

- Retinue + Training Yard II strength.
- Greedy Economy timeout pressure.
- Fast Army quick-clear speed.
- Early campaign defeat causes.
- Cinderfen pressure warning fairness.
- Whether battle pacing issues are readability/guidance issues or actual balance issues.

New v0.12.2 docs:

- `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`
- `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`
- `docs/V0122_HUMAN_BALANCE_NOTES.md`
- `docs/V0122_TUNING_DECISION.md`
- `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`

## Simulator Evidence

Source: `PLAYTEST_TELEMETRY.json` and `PLAYTEST_TELEMETRY.md`, 255 deterministic runs across 85 campaign battle node/profile summaries.

Global read:

- Structural `too_easy`: none.
- Structural `too_hard`: none.
- Stronghold warnings: none.
- Enemy pressure warnings: none.
- Ashen Outpost beatable: yes.

Key watchpoint data:

- Retinue + Training Yard II full profile: 17 wins / 3 defeats / 1 timeout.
- Retinue + Training Yard II Cinderfen slice: 6 wins / 0 defeats / 0 timeouts, average duration 3:57, 0 average losses, 0 losses after pressure.
- Greedy Economy full script: 31 wins / 11 defeats / 43 timeouts, with first-wave survival and Barracks-before-contact in 85/85 runs.
- Greedy Economy Cinderfen: 4 wins / 0 defeats / 21 timeouts, high resource float, and heavy losses after pressure.
- Fast Army full script: 53 wins / 24 defeats / 8 timeouts.
- Fast Army Cinderfen: 22 wins / 0 defeats / 3 timeouts, very fast clears, but pressure/loss exposure on Watch and broader failures outside Cinderfen.
- Border Village: 36 wins / 0 defeats / 0 timeouts.
- Ashen Outpost: 22 wins / 0 defeats / 14 timeouts; Safe Beginner wins 12/12.
- Pressure-enabled Cinderfen runs: 75; triggered runs: 63; warnings shown: 149; simulated reinforcement applications: 0.

## Human-Style Evidence

v0.12.1 slow play found the core readability pass landed well:

- Selection and current-order state are clearer.
- Move command acknowledgement stays readable.
- Ashen/Cinderfen objective `Next` state gives a useful plan.
- Defeat/result guidance is more practical after v0.12/v0.12.1 copy changes.

v0.12.2 human-style balance review found:

- Border Village is stable and not currently an early-defeat problem.
- Ashen Outpost timeouts are milestone pacing and final-push attrition, not unfair early losses.
- Cinderfen Crossing and Cinderfen Watch pressure is structurally fair because Safe Beginner wins through warnings.
- Greedy Economy failures read as risky conversion problems: high resources, slow push, timeouts.
- Fast Army is a legitimate speed profile, especially in Cinderfen, but it is not dominant across the whole suite.
- Retinue + Training Yard II is the strongest watchpoint and should stay watched, but it currently reads as satisfying earned power rather than a confirmed balance bug.

## Decisions

Retinue + Training Yard II:

- Decision: no change.
- It is strong and satisfying. It is the main future watchpoint, not a current nerf target.

Greedy Economy:

- Decision: no change.
- It fails because it is risky and slow to convert resources into victory, not because early pressure is unfair or economy is too weak.

Fast Army:

- Decision: no change.
- Quick clears are real, but the profile accepts broader failure risk and is a legitimate aggressive strategy.

Early defeats:

- Decision: no change.
- Current evidence points away from structural early difficulty problems.

Pressure fairness:

- Decision: no change.
- Pressure warnings are fair and actionable in structural evidence. Remaining risk is human noticeability under stress.

Numeric tuning:

- None.

Copy/readability changes:

- None in v0.12.2. v0.12/v0.12.1 already made the relevant pressure/objective/defeat readability changes, and this pass found no new copy issue strong enough to patch.

## Changes Made

- Added v0.12.2 balance/watchpoint review docs.
- Updated checkpoint/handoff metadata.

No runtime code, gameplay data, simulator logic, tests, art, assets, save fields, release scripts, or CI plumbing were changed.

## Changes Deliberately Not Made

- No retinue, veterancy, Training Yard, Quartermaster, resource, reward, pressure timing, wave, enemy stat, or map-objective numeric tuning.
- No Greedy Economy timeout relief.
- No Fast Army slowdown.
- No early campaign difficulty reduction.
- No pressure read-window or pressure-action promotion.
- No workers, enemy construction, live reinforcement behavior, route contest AI, defensive hold behavior, new maps, new factions, new units, new art, runtime art replacement, save migration, multiplayer, procedural generation, monetization, or visual overhaul.

## Remaining Risks

- Retinue + Training Yard II may become too clean if future human play repeatedly shows low-loss clears with little objective or production engagement.
- Greedy Economy may still feel unclear to human players if they do not recognize that high resources need to become army pressure.
- Fast Army may still feel reward-efficient if future repeat-clear or first-clear reward evidence changes.
- Pressure warning fairness still needs ordinary human attention review under real combat stress.
- Hero survival is not independently recorded as HP/death telemetry; do not infer hero-specific tuning from this pass.

## Verification

Final local verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview at http://127.0.0.1:4173/, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
git diff --check: PASS.
```

Hosted release groups were not run locally because v0.12.2 made no gameplay, HUD, campaign, pressure, result, tuning, test-harness, or release-lane behavior changes. Full release was not run for the same reason: no tuning or campaign/battle behavior changed.

## GitHub Actions

The user-provided remote baseline before this pass is GitHub Actions `CI Release Matrix Dry Run #44`, green on commit `1b28678`, including Fast confidence, Release simulator, and all hosted release matrix groups.

Because v0.12.2 is docs-only and makes no runtime or test-harness changes, a GitHub Actions rerun is optional rather than required for behavior confidence. If the checkpoint is pushed, rerunning the manual release matrix is still a clean remote parity check.

## Next Recommended Long Goal

Next long goal: **v0.12.3 Human Campaign Balance Play Session**.

Recommended scope:

- Play Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch by hand with no retinue, one veteran, mixed veterans, and Retinue + Training Yard II.
- Record player decisions, army size, losses, pressure-warning noticeability, objective order, and whether failures feel earned.
- Keep it evidence-only unless repeated human runs reproduce a specific unfairness pattern.

Do not start the 2026 visual overhaul, new content, broad AI/economy work, or save migration under that goal unless explicitly rescoped.
