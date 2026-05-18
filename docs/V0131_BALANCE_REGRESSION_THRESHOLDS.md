# v0.13.1 Balance Regression Thresholds

Date: 2026-05-18

Purpose: define conservative automated thresholds for future scenario-lab regression detection.

Implementation:

- `src/game/playtest/ScenarioLabRegressionThresholds.ts`

Statuses:

- `OK`
- `Monitor`
- `Warning`
- `Strong signal`
- `Human testing required`
- `Future systems pass`

## Rules

Thresholds are intentionally conservative:

- Do not create a tuning candidate from one weak automated signal.
- Human testing is a valid outcome.
- Pressure warning counts do not prove human noticeability.
- Copy/readability and human testing should come before numeric tuning when the issue may be understanding.
- Strong automated signals should become future investigation items unless real human evidence agrees.

## Watchpoint Thresholds

| Watchpoint | Normal expected state | Warning threshold | Strong signal threshold | Action | Do not do |
| --- | --- | --- | --- | --- | --- |
| Retinue + Training Yard II dominance | Strong earned-power route with some failures/costs outside ideal watchpoints. | >=90% full-profile win rate plus >=95% low-loss Ashen/Cinderfen watchpoint wins. | >=95% full-profile win rate, zero failures, <=1 average loss. | Human-test first. | Do not nerf from clean automated watchpoints alone. |
| Greedy Economy collapse | Greed is risky; openings survive; failures read as conversion/pacing. | >=65% timeout rate with <25% win rate. | >=75% timeout/loss rate with high surplus across multiple nodes. | Monitor conversion clarity. | Do not buff just because greed is risky. |
| Fast Army trivialization | Fast Army is fast and Cinderfen-friendly, but pays failures elsewhere. | >=96% Cinderfen win rate, <=10% whole-profile failure rate, <=1.5 average losses. | Cinderfen sweep plus whole-suite sweep. | Monitor speed feel. | Do not slow it just because it is fast. |
| Early defeat spike | Early-node defeats remain near zero. | >=5% early-node defeat rate. | >=15% early-node defeat rate or repeated early-pressure defeats. | Inspect clarity before tuning. | Do not weaken early tests. |
| Pressure warning unfairness | Safe routes win pressure nodes and warnings appear. | <90% safe pressure win rate, missing warnings, or short reaction windows. | Safe-route pressure defeats with missing/late warnings. | Human noticeability test. | Do not treat warning counts as proof humans noticed. |
| Cinderfen Crossing unfairness | Safe Beginner wins all current rows. | Any repeated Safe Beginner failure or >=45% all-profile timeout rate. | Safe-route losses/timeouts across repeated runs. | Human route feel first. | Do not tune from non-safe timeouts alone. |
| Cinderfen Watch unfairness | Safe Beginner wins all current rows. | Any repeated Safe Beginner failure or >=45% all-profile timeout rate. | Safe-route losses/timeouts across repeated runs. | Human route feel first. | Do not tune from non-safe timeouts alone. |
| Ashen Outpost timeout spike | Safe play remains stable; route timeouts are pacing evidence. | Any repeated safe-route failure or >=10% defeat rate. | Safe-route failures plus high timeout rate. | Monitor pacing/final assault. | Do not change Ashen numbers from timeouts alone. |
| Objective completion drop | Primary objective completion stays >=70% across overlapped rows. | <55% completion. | <45% completion. | Inspect profile/node combinations. | Do not infer confusion from completion alone. |
| Resource starvation spike | Resource problems remain localized. | >=20% non-victory rows end with very low resources. | >=35% starvation rows. | Review economy clarity. | Do not globally raise resources without node/profile evidence. |

## Current v0.13.1 Status

- Human testing required: Retinue + Training Yard II dominance, Pressure Warning Fairness.
- Monitor: Greedy Economy Collapse, Fast Army Trivialization.
- OK: Early Defeat Spike, Cinderfen Crossing Fairness, Cinderfen Watch Fairness, Ashen Outpost Timeout Spike, Objective Completion Drop, Resource Starvation Spike.

No threshold supports runtime tuning in v0.13.1.
