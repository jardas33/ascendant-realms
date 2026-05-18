# v0.13.1 Scenario Lab Limitations Audit

Date: 2026-05-18

Baseline commit: `1a4e09e` (`Checkpoint v0.13 automated playtest scenario lab`), clean and synced with `origin/main` before edits.

Scope: identify what the v0.13 automated scenario lab already proves, where it is still shallow, and what v0.13.1 can safely deepen without gameplay changes.

## v0.13 Already Tracks

- 10 deterministic automated profiles.
- 255 source simulator rows from 7 battle nodes, 3 scripts, and 13 Stronghold/retinue profiles.
- 355 derived profile-run metric rows.
- 8 watchpoint classifications.
- win/loss/timeout, clear time, losses, final army, resource surplus, Aether, objective count, pressure warnings, pressure reaction-window estimate, route markers, route verdict, and confidence.

## v0.13 Does Not Track

- Human attention or warning noticeability.
- Fun, stress, frustration, or whether victories feel earned.
- Final hero HP/death state.
- Base HP or base damage.
- True objective timing/order beyond currently exposed telemetry.
- Visual readability.
- Human confusion.
- Independent player populations; profile rows intentionally overlap source telemetry.

## Evidence That Was Too Shallow

- One quick lab pass could report current profile strength, but not whether the reporting layer is stable across repeated batches.
- Profile ranking was available, but did not include median clear time, spread, timeout/loss rates, objective completion rates, or route verdict distributions.
- Node risk existed as a compact table, but did not directly answer where Greedy Economy struggles, where Fast Army dominates, or where Retinue + Training Yard II has the largest advantage.
- Watchpoint actions were useful, but did not define future regression thresholds.

## Profile Comparisons Needing Repeated Runs

- Retinue + Training Yard II: repeated evidence is needed to distinguish clean Ashen/Cinderfen watchpoint performance from whole-suite dominance.
- Greedy Economy: repeated evidence is needed to confirm conversion/time risk instead of treating greed as raw weakness.
- Fast Army: repeated evidence is needed to separate decisive Cinderfen speed from true trivialization.
- Pressure-Ignoring and Objective-Rush: repeated evidence is needed because both are proxy profiles built from existing Fast Army behavior.

## Low-Confidence Watchpoints

- Pressure Fairness remains human-noticeability limited.
- Retinue + Training Yard II dominance remains an earned-power feel question.
- Cinderfen Crossing and Cinderfen Watch are structurally fair for Safe Beginner but still need human route feel.
- Ashen Outpost timeouts remain a pacing/final-assault feel question.

## Human Testing Remains Required

Automation cannot decide:

- whether warnings are seen
- whether warning copy is actionable under stress
- whether Greedy Economy feels confusing or intentionally risky
- whether Fast Army feels satisfying or trivial
- whether Retinue + Training Yard II feels earned or mandatory
- whether Cinderfen readability/art debt blocks play

## Tooling-Only Safe Additions

- Extended deterministic batch runner.
- Iteration and seed labels.
- Profile comparison tables and CSV.
- Profile x node x script aggregation.
- Node-level risk dashboard.
- Conservative regression threshold classifier.
- Separate extended JSON/Markdown outputs.
- Tests for extended batch/report/threshold behavior.

## Guardrail

v0.13.1 should not tune runtime numbers. If evidence is strong, document a future candidate only; do not implement tuning in this goal.
