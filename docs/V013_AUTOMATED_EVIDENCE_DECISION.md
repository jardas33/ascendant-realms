# v0.13 Automated Evidence Decision

Date: 2026-05-18

Evidence source: automated deterministic scenario lab only. No real human tester feedback was available or used.

Generated outputs reviewed:

- `PLAYTEST_SCENARIO_LAB.json`
- `PLAYTEST_SCENARIO_LAB.md`
- `PLAYTEST_WATCHPOINT_SUMMARY.md`
- `PLAYTEST_SCENARIO_PROFILES.json`
- `PLAYTEST_SCENARIO_PROFILES.md`

## Decision

No runtime gameplay change.

No numeric tuning.

No copy/readability patch.

No new maps, factions, units, art/assets, save migration, combat systems, campaign progression, AI rewrite, hosted release plumbing, or visual overhaul.

## Rationale

Retinue + Training Yard II:

- Strongest automated watchpoint profile.
- Ashen/Cinderfen watchpoint nodes are very clean: 9/9 low-loss wins.
- Full profile is not a whole-suite sweep: 17 wins / 3 defeats / 1 timeout across 21 lab runs.
- Decision: needs human testing, not an automated nerf.

Greedy Economy:

- 31 wins / 11 defeats / 43 timeouts across 85 lab runs.
- First wave survived in 85/85 Greedy source runs.
- High resource surplus plus timeouts still reads as conversion/timing risk.
- Decision: monitor clarity/pacing; do not buff just because greed is risky.

Fast Army:

- 53 wins / 24 defeats / 8 timeouts across 85 lab runs.
- Cinderfen Fast Army wins 22/25.
- Whole-suite failures remain 32.
- Decision: monitor Cinderfen speed; do not slow it just because it is fast.

Early defeats:

- Early-node record is 72 wins / 0 defeats / 0 timeouts.
- Decision: no change.

Pressure fairness:

- Pressure runs: 75.
- Triggered pressure runs: 63.
- Warnings shown: 149.
- Safe Beginner pressure-node wins: 25/25.
- Reinforcement applications: 0.
- Decision: structurally actionable, but human noticeability still needs real play.

Cinderfen Crossing / Watch:

- Crossing record: 26 wins / 0 defeats / 13 timeouts.
- Watch record: 25 wins / 0 defeats / 11 timeouts.
- Safe Beginner wins all current rows on both.
- Decision: no structural tuning from automation.

Ashen Outpost:

- 22 wins / 0 defeats / 14 timeouts.
- Safe Beginner wins 12/12.
- Decision: monitor pacing/final-assault attrition.

## Future Action

Use v0.13 automated evidence to prioritize real human testing:

1. Retinue + Training Yard II route.
2. Greedy Economy route.
3. Fast Army route.
4. Pressure warning noticeability in Cinderfen Watch and Crossing.
5. Ashen Outpost timeout/final-assault feel.

Do not run v0.12.7/v0.13 human-feedback triage until real completed tester forms exist.
