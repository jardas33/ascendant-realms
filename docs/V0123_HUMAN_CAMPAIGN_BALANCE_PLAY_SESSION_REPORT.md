# v0.12.3 Human Campaign Balance Play Session Report

Date: 2026-05-17

Scope: final report for v0.12.3 Human Campaign Balance Play Session. This pass gathered direct human-style campaign evidence after v0.12.2 and only considered tiny changes if repeated evidence proved a real problem. No new maps, factions, units, art/assets, runtime art, save changes, multiplayer, procedural generation, monetization, broad AI/economy rewrites, hosted CI plumbing, or broad balance changes were made.

## What Was Played / Reviewed

- Direct visible browser path from main menu to New Campaign, hero creation, Campaign Map, Border Village guidance, and Border Village battle HUD.
- Existing browser evidence coverage for Cinderfen Crossing launch, shrine capture, pressure warning, victory results, Cinderfen Watch launch, pressure warning, and defeat results.
- Structural campaign route evidence from the 255-run deterministic playtest telemetry.
- Prior v0.12.1 slow-play evidence for Ashen Outpost, Cinderfen Crossing, Cinderfen Watch, defeat guidance, victory results, and campaign return.

New v0.12.3 docs:

- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`
- `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`
- `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`
- `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`
- `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`

## Evidence By Route

Baseline cautious:

- Safe Beginner wins every reviewed node.
- Cinderfen pressure triggers and warnings appear, but baseline wins through them.
- Verdict: fair baseline, no change.

No-retinue:

- Harder and slower, especially Ashen Outpost, but failures are timeouts rather than unfair early defeats.
- Verdict: campaign remains fair without retinue; no change.

One-veteran:

- Helpful without becoming automatic.
- One Veteran Ranger still has a rough Crossing read, which argues against one-veteran overpower.
- Verdict: earned advantage, no change.

Mixed-veterans:

- Strong experienced-player path, especially Ashen and Watch.
- Crossing still has a timeout in the profile.
- Verdict: strong but not proven mandatory; no change.

Retinue + Training Yard II:

- Strongest route: reviewed Ashen/Cinderfen rows are clean, fast, and no-loss.
- The profile remains close to too clean, but it is still tied to earned veterans and Stronghold investment.
- Verdict: main watchpoint, defer tuning.

Greedy Economy:

- Survives first waves and completes Barracks before contact.
- Fails through high resource float, losses after pressure, and timeouts.
- Verdict: risky conversion problem, no change.

Fast Army:

- Very quick on Cinderfen Crossing and strong on Watch.
- Still has Ashen timeouts and Watch pressure exposure.
- Verdict: legitimate speed profile, no change.

## Watchpoint Verdicts

Retinue + Training Yard II:

- Strong and satisfying earned power.
- No numeric tuning made.
- Keep as the first future balance watchpoint.

Greedy Economy:

- Fails because it is risky, slow, and conversion-limited, not because the economy is underpowered or pressure is unfair.
- No copy or numeric change made.

Fast Army:

- Rewards decisive play without proving whole-slice trivialization.
- No slowdown or reward change made.

Early defeats:

- No structural early-defeat issue.
- Direct browser entry into the campaign makes Border Village guidance clear.

Pressure fairness:

- Structurally fair and actionable.
- Human noticeability under real combat stress remains the main unresolved risk.

## Changes Made

- Added v0.12.3 play-session protocol, notes, evidence table, decision, and report.
- Updated checkpoint/handoff metadata.

No runtime code, gameplay data, simulator logic, tests, art/assets, save fields, release scripts, or CI workflow changed.

## Changes Deliberately Not Made

- No retinue, veterancy, Training Yard, Quartermaster, resource, reward, pressure timing, wave, enemy stat, or map-objective tuning.
- No Greedy Economy timeout relief.
- No Fast Army slowdown.
- No early campaign difficulty reduction.
- No pressure read-window or pressure-action change.
- No new maps, factions, units, art, runtime art, save migrations, workers, enemy construction, live reinforcements, route contest AI, defensive hold behavior, multiplayer, procedural generation, monetization, reward redesign, or visual overhaul.

## Verification

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run test:e2e:smoke
PASS - final full rerun 12 tests in 7.5m.
Note: the first full-smoke attempt hit a local timeout in the existing trophy-standard extended smoke after 11/12 tests passed; the focused trophy-standard rerun passed, then the full smoke rerun passed without code or test changes.

npm run visual:qa
PASS - 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS - production preview at http://127.0.0.1:4173/ verified menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Hosted release lanes were not run because this checkpoint made no gameplay, HUD, campaign, pressure, result, tuning, runtime, or test-harness behavior changes.

## Remaining Risks

- Retinue + Training Yard II is close to too clean in Ashen/Cinderfen and needs true hands-on repetition before any nerf.
- Greedy Economy may still be unclear to human players if they cannot diagnose resource-to-army conversion after timeouts.
- Fast Army may still need review if future human speed clears repeatedly skip map identity with low losses.
- Pressure warnings are visible in test/capture paths, but human attention during dense combat remains the unresolved player-feel risk.
- Hero survival is still not separately recorded as final HP/death telemetry.
- Visual debt remains: shrine/tower/fog landmarks, minimap icon language, command destination markers, and results density.

## GitHub Actions

GitHub Actions should be rerun only if a remote parity check is desired after push. This checkpoint is docs-only and does not change gameplay/HUD/campaign/pressure/result/tuning behavior or test harnesses.

## Next Recommended Long Goal

Next long goal: **v0.12.4 Manual Human Playtest Packet And Tester Checklist**.

Recommended scope:

- Produce a lightweight checklist for Emmanuel or a human tester to run Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch by hand.
- Ask for ratings and short notes on Retinue + Training Yard II, Greedy Economy, Fast Army, early defeat clarity, pressure-warning noticeability, and result guidance.
- Keep the pass evidence-only unless tester notes repeat the same concrete unfairness pattern.

Do not start the 2026 visual overhaul, new content, broad AI/economy work, or save migration under that goal unless explicitly rescoped.
