# v0.7.3 Evidence-Backed Pressure Polish Decision

Date: 2026-05-09

Status: Phase 7 polish gate. This document records whether the v0.7.3 review evidence justifies any tiny pressure copy, timing, status-duration, defeat-tip, docs, or e2e wording change.

## 1. Evidence Reviewed

Reviewed:

- `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`
- `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`
- `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`
- `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`

Evidence types:

- Controlled browser-input evidence for Cinderfen Crossing and Cinderfen Watch.
- Seeded surrogate evidence for Crossing's delayed pressure warning.
- Simulator evidence for Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II.
- Manual checklist design for future true human input.

No direct human manual pass was available inside this environment.

## 2. Possible Polish Checks

| Candidate change | Evidence | Decision |
| --- | --- | --- |
| Crossing warning copy | Delayed warning was readable and understandable in seeded visibility evidence. | No change |
| Crossing warning timing | Natural shrine capture showed objective feedback clearly; delayed pressure remained readable. | No change |
| Watch warning copy | Immediate and delayed Watch warnings were readable and action-oriented. | No change |
| Watch warning timing | Immediate warning is early but directly player-triggered by Watch Road capture. | No change |
| Pressure status duration | Watch delayed pressure survived generic status churn; screenshots showed readable banners. | No change |
| Defeat or timeout tips | Greedy timeouts remain a human-readability watchpoint, but no direct human evidence proves current tips are unclear. | No change |
| E2E wording or assertions | Existing targeted pressure coverage plus v0.7.3 browser evidence is sufficient for this review goal. | No change |

## 3. Decision

No Phase 7 pressure polish change is applied.

No changes to:

- pressure warning copy
- warning timing
- pressure status duration
- defeat-tip wording
- e2e assertions
- telemetry labels
- pressure plan data
- existing-wave timing nudge
- rewards
- saves
- maps
- units
- factions
- workers
- construction
- enemy economy
- live reinforcement
- capture-site contest AI
- defensive-hold behavior
- campaign progression

## 4. Rationale

The current evidence supports confidence, not intervention:

- Crossing kept `Cinder Shrine Surge` readable and then showed the delayed pressure warning clearly.
- Watch captured Watch Road through a real browser right-click order and showed both pressure warnings clearly.
- Watch pressure priority protected the delayed warning from ordinary status replacement.
- Safe Beginner wins while seeing pressure.
- Greedy Economy times out without pressure-caused defeats.
- Fast Army remains valid strategy expression.
- Retinue + Training Yard II remains a saved-progress power watchpoint.

Changing copy or timing now would be speculative. The right next evidence is Emmanuel's manual playtest checklist.

## 5. Follow-Up

If manual play later shows a real issue, prefer the smallest possible response:

1. Copy-only warning or Results-tip adjustment.
2. Tiny timing/status-duration adjustment.
3. Documentation-only v0.8 recommendation.

Do not promote live reinforcement, capture-site contest AI, defensive hold, workers, construction, economy AI, new maps, new units, new factions, rewards, saves, or broad systems from v0.7.3 evidence.
