# v0.12.5 Watchpoint Aggregation Sheet

Date: 2026-05-18

Use this sheet to aggregate completed v0.12.4 playtest feedback. Copy the blank table into a new intake note when real sessions arrive, or append rows here during a dedicated intake checkpoint.

Rating scale: 1 = very bad/confusing/unfair, 2 = weak/often unclear, 3 = acceptable but rough, 4 = good, 5 = excellent/clear/satisfying.

Severity: `S0`, `S1`, `S2`, `S3`, or `S4` from `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`.

Status examples: `new`, `needs follow-up`, `monitor`, `candidate`, `accepted`, `deferred`, `rejected`, `resolved`.

| Watchpoint | Session ID | Route | Rating 1-5 | Evidence quote/summary | Category | Severity | Repeated by how many testers | Recommended action | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Retinue + Training Yard II |  |  |  |  |  |  |  |  |  |
| Greedy Economy |  |  |  |  |  |  |  |  |  |
| Fast Army |  |  |  |  |  |  |  |  |  |
| Early defeat clarity |  |  |  |  |  |  |  |  |  |
| Pressure warning noticeability |  |  |  |  |  |  |  |  |  |
| Cinderfen Crossing fairness |  |  |  |  |  |  |  |  |  |
| Cinderfen Watch fairness |  |  |  |  |  |  |  |  |  |
| Results guidance |  |  |  |  |  |  |  |  |  |
| Objective tracker clarity |  |  |  |  |  |  |  |  |  |
| Command feedback clarity |  |  |  |  |  |  |  |  |  |
| Combat readability |  |  |  |  |  |  |  |  |  |
| Fun factor |  |  |  |  |  |  |  |  |  |

## Decision Thresholds

- 1 isolated report = note only.
- 2 similar reports = monitor / maybe copy tweak.
- 3+ similar reports = candidate for small fix.
- 3+ reports across different routes = strong signal.
- 5+ reports or severe blocker = priority issue.

## Threshold Notes

One severe reproducible bug can bypass repetition thresholds and become an investigation item.

Balance tuning should require stronger evidence than copy/readability polish. A single clear copy issue can justify a wording fix, but a numeric change needs repeated route-aware evidence.

Different-route evidence is stronger than same-route repetition. Example: pressure missed in Baseline Cautious, Greedy Economy, and Fast Army is stronger than three Fast Army-only misses.

Contradictory reports should be preserved. If one tester says Fast Army trivializes Cinderfen and another says it caused heavy losses, classify the pattern as `needs more testing` until save state, route execution, and experience level explain the difference.

## Aggregation Workflow

1. Add one row per watchpoint per session.
2. Keep quotes short and tied to evidence.
3. Update `Repeated by how many testers` only when reports are meaningfully similar.
4. Use `Category` from the evidence classification guide.
5. Use severity from the rubric.
6. Choose recommended action from: `no change`, `copy/readability`, `tiny tuning`, `needs more testing`, `future art/UI overhaul`, `future systems pass`, `bug investigation`.
7. Revisit rows after every new tester session.
