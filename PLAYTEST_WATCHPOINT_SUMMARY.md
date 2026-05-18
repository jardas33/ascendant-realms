# v0.13 Playtest Watchpoint Summary

Evidence type: automated deterministic simulator evidence only. No human tester feedback is included or implied.

| Watchpoint | Action | Confidence | Evidence |
| --- | --- | --- | --- |
| Retinue + Training Yard II | needs human testing | medium | Retinue + Training Yard II: 17 wins / 3 defeats / 1 timeout across 21 lab runs; Ashen/Cinderfen low-loss wins: 9/9; Average losses: 1.8; average final army: 10.3. |
| Greedy Economy | monitor | medium | Greedy Economy: 31 wins / 11 defeats / 43 timeouts across 85 lab runs; First wave survived in 85/85 Greedy source runs; Conversion timeouts: 11; average resource surplus: 9794. |
| Fast Army | monitor | medium | Fast Army: 53 wins / 24 defeats / 8 timeouts across 85 lab runs; Cinderfen Fast Army wins: 22/25; Whole-suite failures: 32. |
| Early Defeats | no change | high | Early-node record: 72 wins / 0 defeats / 0 timeouts; First-wave not-survived markers: 24/72; speed routes can end before absorbing a first wave. |
| Pressure Fairness | needs human testing | medium | Pressure runs: 75; triggered: 63; warnings shown: 149; Safe Beginner pressure-node wins: 25/25; Reinforcement applications: 0. |
| Cinderfen Crossing Fairness | no change | medium | Cinderfen Crossing record: 26 wins / 0 defeats / 13 timeouts; Safe Beginner wins: 13/13; Pressure warnings shown: 72. |
| Cinderfen Watch Fairness | no change | medium | Cinderfen Watch record: 25 wins / 0 defeats / 11 timeouts; Safe Beginner wins: 12/12; Pressure warnings shown: 77. |
| Ashen Outpost Stability | monitor | medium | Ashen Outpost record: 22 wins / 0 defeats / 14 timeouts; Safe Beginner wins: 12/12; Timeouts across all profiles/scripts: 14. |

## Next Human Testing Priorities

- Retinue + Training Yard II: Automated watchpoint nodes are very clean, but the full route is not a whole-suite sweep; treat as earned-power human-test priority, not an automated nerf.
- Greedy Economy: Greedy failures continue to read as timing and conversion risk: first waves are generally survived, but surplus resources do not consistently become a fast win.
- Fast Army: Fast Army is decisive in Cinderfen but still pays failure risk across the broader suite; do not slow it just because it is fast.
- Pressure Fairness: Pressure remains structurally actionable in automation, but automated telemetry cannot prove human noticeability during combat stress.
- Cinderfen Crossing Fairness: Cinderfen Crossing is structurally fair for the safe script; remaining questions are route feel and pressure noticeability.
- Cinderfen Watch Fairness: Cinderfen Watch is structurally fair for the safe script; remaining questions are route feel and pressure noticeability.
- Ashen Outpost Stability: Ashen Outpost remains beatable and stable for safe play, while route timeouts keep it as a pacing and final-assault watchpoint.

## No-Tuning Guardrail

- No runtime tuning should be made from this summary alone.
- Tiny tuning requires repeated strong evidence and preferably real human playtest notes.
- Copy/readability work should be considered before numbers when the issue may be understanding or noticeability.
