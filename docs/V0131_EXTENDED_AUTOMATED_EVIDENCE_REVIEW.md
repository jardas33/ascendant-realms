# v0.13.1 Extended Automated Evidence Review

Date: 2026-05-18

Evidence source: repeated deterministic scenario-lab automation only. No real human tester feedback was available or used.

Generated outputs reviewed:

- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_PROFILE_COMPARISON.md`
- `PLAYTEST_PROFILE_COMPARISON.csv`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`
- `PLAYTEST_WATCHPOINTS_EXTENDED.md`

## What Changed Compared To v0.13

v0.13 generated one quick evidence pass:

- 255 source simulator runs.
- 355 derived profile-run metrics.
- 8 watchpoint classifications.

v0.13.1 generated an extended repeated batch:

- 5 deterministic iterations.
- 1,275 source simulator runs.
- 1,775 derived profile-run metrics.
- 10 regression watchpoints.
- Profile comparison table with median/average/spread metrics.
- Profile x node x script aggregation.
- Node risk dashboard.
- Balance regression dashboard.
- Conservative future regression thresholds.

## Profile Summary

Top-ranked stable automated profile:

- Mixed-Veterans: 30-0-0 across 30 extended metric rows, 100% win rate, 0.0 average losses.

Strongest watchpoint route:

- Retinue + Training Yard II remains the dominance watchpoint because Ashen/Cinderfen watchpoint rows are very clean, but the full extended profile is 85-15-5 across 105 rows.

Weakest / most failure-prone route:

- Greedy Economy: 155-55-215 across 425 rows, 36% win rate, 51% timeout rate, 9,793.8 average resource surplus.

Fastest profile:

- Pressure-Ignoring, a narrow Fast Army pressure-node proxy.

## Watchpoint Findings

Retinue + Training Yard II:

- Status: Human testing required.
- 81% full-profile win rate.
- 100% Ashen/Cinderfen low-loss win rate.
- Did not cross the strong-signal tuning threshold because the full route still has defeats/timeouts.

Greedy Economy:

- Status: Monitor.
- 51% timeout rate with high resource surplus.
- Still reads as conversion/timing risk, not raw economy weakness.
- Did not cross warning/strong collapse thresholds.

Fast Army:

- Status: Monitor.
- 88% Cinderfen win rate.
- 38% whole-profile failure rate.
- Did not cross trivialization threshold because it still pays failures outside the favorable slice.

Early Defeats:

- Status: OK.
- 0% early defeat rate.
- No change.

Pressure Fairness:

- Status: Human testing required.
- Safe Beginner pressure-node win rate is 100%.
- Warnings appear in automated state with a 139.8s average reaction-window estimate.
- Human noticeability remains unknowable without real play.

Cinderfen Crossing / Cinderfen Watch:

- Status: OK structurally.
- Safe Beginner remains 100% on both.
- Human route feel and warning noticeability remain open.

Ashen Outpost:

- Status: OK under current thresholds, with pacing still worth monitoring.
- 28% timeout rate and 0% defeat rate in the extended node dashboard.

Objective Completion:

- Status: OK.
- 74% primary objective completion across overlapped extended rows.

Resource Starvation:

- Status: OK.
- 0% low-resource non-victory row rate.

## Still Unknowable Without Human Testing

- Whether pressure warnings are noticed.
- Whether Retinue + Training Yard II feels earned or mandatory.
- Whether Fast Army feels decisive or trivial.
- Whether Greedy Economy feels intentionally risky or confusing.
- Whether Cinderfen visual/readability debt changes player decisions.
- Whether Ashen Outpost timeouts feel fair.

## Recommended Next Action

No runtime tuning from v0.13.1.

Use the dashboard to prioritize real human testing:

1. Retinue + Training Yard II through Ashen and Cinderfen.
2. Greedy Economy conversion/timing.
3. Fast Army Cinderfen speed feel.
4. Pressure-warning noticeability.
5. Ashen Outpost timeout/final-assault feel.
