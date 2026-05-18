# v0.13.1 Balance Regression Dashboard

Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.

Generated at: 2026-05-18T13:01:51.673Z
Build commit: 1e59f8c
Batch: v0.13.1 extended deterministic scenario lab
Iterations: 5
Seed label: scenario-lab-v0131

## Quick Summary

- Strongest automated route: Mixed-Veterans.
- Weakest automated route: Greedy Economy.
- Biggest timeout risk: Ashen Outpost.
- Biggest pressure-risk signal: Cinderfen Watch.

## Profile Ranking

| Profile | Runs | Record | Win | Timeout | Loss | Median clear | Avg clear | Spread | Avg losses | Avg army | Avg resources | Objective completion | Pressure warnings | Stability |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Mixed-Veterans | 30 | 30-0-0 | 100% | 0% | 0% | 3:41 | 3:46 | 5:07 | 0.0 | 12.2 | 1546 | 100% | 25 | consistent stable |
| One-Veteran | 30 | 30-0-0 | 100% | 0% | 0% | 6:18 | 6:19 | 0:32 | 0.5 | 11.7 | 2427 | 100% | 45 | consistent stable |
| Pressure-Ignoring | 20 | 20-0-0 | 100% | 0% | 0% | 1:32 | 1:32 | 0:34 | 0.5 | 12.5 | 680 | 100% | 15 | consistent stable |
| Safe Beginner | 425 | 425-0-0 | 100% | 0% | 0% | 6:11 | 6:06 | 1:09 | 1.0 | 11.3 | 2275 | 100% | 285 | consistent stable |
| No-Retinue | 250 | 250-0-0 | 100% | 0% | 0% | 6:13 | 6:12 | 0:56 | 1.3 | 11.3 | 2294 | 100% | 180 | consistent stable |
| Baseline Cautious | 35 | 35-0-0 | 100% | 0% | 0% | 6:13 | 6:13 | 0:56 | 1.3 | 11.3 | 2265 | 100% | 25 | consistent stable |
| Objective-Rush | 30 | 25-0-5 | 83% | 17% | 0% | 1:33 | 4:10 | 16:14 | 1.8 | 11.5 | 2095 | 83% | 15 | mixed route |
| Retinue + Training Yard II | 105 | 85-15-5 | 81% | 5% | 14% | 5:34 | 5:41 | 13:49 | 1.8 | 10.3 | 3371 | 81% | 45 | mixed route |
| Fast Army | 425 | 265-120-40 | 62% | 9% | 28% | 2:02 | 5:07 | 16:19 | 3.0 | 7.8 | 2175 | 62% | 105 | mixed route |
| Greedy Economy | 425 | 155-55-215 | 36% | 51% | 13% | 15:00 | 11:12 | 12:51 | 4.7 | 6.6 | 9794 | 36% | 355 | unstable route |

## Watchpoint Status

| Watchpoint | Status | Human testing | Current signal | Recommended action |
| --- | --- | --- | --- | --- |
| Retinue + Training Yard II Dominance | Human testing required | yes | 81% win rate; 100% Ashen/Cinderfen low-loss win rate; 1.8 average losses. | Prioritize human testing; do not tune from automation alone. |
| Greedy Economy Collapse | Monitor | yes | 36% win rate; 51% timeout rate; 9793.8 average resource surplus. | Monitor conversion clarity and pacing; keep human testing first. |
| Fast Army Trivialization | Monitor | yes | 88% Cinderfen win rate; 38% whole-profile failure rate. | Monitor Cinderfen speed and ask humans whether it feels decisive or trivial. |
| Early Defeat Spike | OK | no | 0% early defeat rate; 0% early-pressure defeat rate. | No change. |
| Pressure Warning Fairness | Human testing required | yes | 100% Safe Beginner pressure-node win rate; 84% warning-row rate; average reaction window 139.8s. | Human testing required for noticeability and stress. |
| Cinderfen Crossing Fairness | OK | yes | 100% Safe Beginner win rate; 22% all-profile timeout rate. | No structural tuning; prioritize human route feel. |
| Cinderfen Watch Fairness | OK | yes | 100% Safe Beginner win rate; 20% all-profile timeout rate. | No structural tuning; prioritize human route feel. |
| Ashen Outpost Timeout Spike | OK | yes | 28% timeout rate; 0% defeat rate. | Monitor final-assault pacing and ask humans whether timeouts feel fair. |
| Objective Completion Drop | OK | no | 74% primary objective completion rate. | No change. |
| Resource Starvation Spike | OK | no | 0% low-resource non-victory row rate. | No change. |

## Node Risk Dashboard

| Node | Runs | Record | Win | Timeout | Loss | Avg losses | Pressure warnings | Greedy | Fast | Retinue+Yard | Pressure-Ignoring | Retinue advantage | Status | Verdict |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | --- | --- | --- | --- | ---: | --- | --- |
| Bandit Hillfort | 235 | 105-125-5 | 45% | 2% | 53% | 5.6 | 0 | 0-55-5 | 0-60-0 | 5-10-0 | 0-0-0 | -108.5 | Warning | loss-risk node (53% defeat rate) |
| Aether Well Ruins | 235 | 105-65-65 | 45% | 28% | 28% | 4.3 | 0 | 0-0-60 | 0-60-0 | 5-5-5 | 0-0-0 | -114.2 | OK | structurally stable |
| Ashen Outpost | 265 | 190-0-75 | 72% | 28% | 0% | 2.2 | 0 | 15-0-45 | 35-0-25 | 15-0-0 | 0-0-0 | 13.6 | OK | structurally stable |
| Cinderfen Crossing | 295 | 230-0-65 | 78% | 22% | 0% | 1.5 | 540 | 5-0-60 | 60-0-5 | 15-0-0 | 10-0-0 | 18.9 | Monitor | pressure-watch node |
| Cinderfen Watch | 275 | 220-0-55 | 80% | 20% | 0% | 1.6 | 555 | 15-0-45 | 50-0-10 | 15-0-0 | 10-0-0 | 19.1 | Monitor | pressure-watch node |
| Old Stone Road | 235 | 235-0-0 | 100% | 0% | 0% | 1.6 | 0 | 60-0-0 | 60-0-0 | 15-0-0 | 0-0-0 | 25.6 | OK | structurally stable |
| Border Village | 235 | 235-0-0 | 100% | 0% | 0% | 0.7 | 0 | 60-0-0 | 60-0-0 | 15-0-0 | 0-0-0 | 16.6 | OK | structurally stable |

## Top Monitor Items

- Pressure Warning Fairness: Human testing required - 100% Safe Beginner pressure-node win rate; 84% warning-row rate; average reaction window 139.8s.
- Retinue + Training Yard II Dominance: Human testing required - 81% win rate; 100% Ashen/Cinderfen low-loss win rate; 1.8 average losses.
- Fast Army Trivialization: Monitor - 88% Cinderfen win rate; 38% whole-profile failure rate.
- Greedy Economy Collapse: Monitor - 36% win rate; 51% timeout rate; 9793.8 average resource surplus.

## Do Not Tune Yet

- The extended batch repeats deterministic simulator evidence; it is stronger regression evidence, not human feedback.
- No watchpoint combines repeated automated signals with real human confirmation.
- Pressure-warning noticeability, route feel, and fun remain unavailable to automation.
- Most current signals are monitor or human-testing outcomes rather than numeric-tuning outcomes.

## Human Testing Recommendations

- Retinue + Training Yard II through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.
- Greedy Economy with explicit notes on resource-to-army conversion timing.
- Fast Army through Cinderfen to judge decisive play versus trivialization.
- Pressure warning noticeability under real combat stress.
- Ashen Outpost pacing and final-assault readability.
