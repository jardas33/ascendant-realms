# v0.13.1 Extended Watchpoints

Evidence type: repeated deterministic simulator evidence only. No human tester feedback is included or implied.

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

## Threshold Detail

### Retinue + Training Yard II Dominance

- Normal expected state: Strong earned-power route with some failures or costs outside ideal watchpoint nodes.
- Warning threshold: >=90% full-profile win rate plus >=95% low-loss wins on Ashen/Cinderfen watchpoint nodes.
- Strong signal threshold: >=95% full-profile win rate, zero failures, and <=1 average unit loss.
- Current signal: 81% win rate; 100% Ashen/Cinderfen low-loss win rate; 1.8 average losses.
- Recommended action: Prioritize human testing; do not tune from automation alone.
- Do not do: Do not nerf retinue or Training Yard II from clean automated watchpoint nodes alone.
- Evidence: Retinue + Training Yard II: 85-15-5 across 105 extended metric rows.
- Evidence: Ashen/Cinderfen low-loss wins: 45/45.

### Greedy Economy Collapse

- Normal expected state: Greedy is risky but survives openings; failures read as conversion or pacing rather than raw weakness.
- Warning threshold: >=65% timeout rate with <25% win rate across repeated extended rows.
- Strong signal threshold: >=75% timeout/loss rate plus resource surplus remaining high across multiple nodes.
- Current signal: 36% win rate; 51% timeout rate; 9793.8 average resource surplus.
- Recommended action: Monitor conversion clarity and pacing; keep human testing first.
- Do not do: Do not buff economy just because greed is risky or timeout-prone.
- Evidence: Greedy Economy: 155-55-215 across 425 extended metric rows.
- Evidence: First-wave survived rate: 100%; conversion/clear-speed timeouts: 55.

### Fast Army Trivialization

- Normal expected state: Fast Army is faster and often good in Cinderfen but still has failures elsewhere.
- Warning threshold: >=96% Cinderfen win rate, <=10% whole-profile failure rate, and <=1.5 average losses.
- Strong signal threshold: Cinderfen sweep plus whole-suite sweep across repeated runs.
- Current signal: 88% Cinderfen win rate; 38% whole-profile failure rate.
- Recommended action: Monitor Cinderfen speed and ask humans whether it feels decisive or trivial.
- Do not do: Do not slow Fast Army just because it is the fastest route.
- Evidence: Fast Army: 265-120-40 across 425 extended metric rows.
- Evidence: Cinderfen Fast Army wins: 110/125.

### Early Defeat Spike

- Normal expected state: Early-node defeats remain near zero in automation.
- Warning threshold: >=5% early-node defeat rate.
- Strong signal threshold: >=15% early-node defeat rate or repeated early-pressure defeats.
- Current signal: 0% early defeat rate; 0% early-pressure defeat rate.
- Recommended action: No change.
- Do not do: Do not weaken early tests or mask first-wave failures.
- Evidence: Early-node record: 470-0-0 across 470 extended metric rows.

### Pressure Warning Fairness

- Normal expected state: Safe routes win pressure nodes and warnings appear before pressure matters.
- Warning threshold: <90% safe-route pressure win rate, warnings missing from most pressure rows, or very short reaction windows.
- Strong signal threshold: Repeated safe-route pressure defeats with missing/late warnings.
- Current signal: 100% Safe Beginner pressure-node win rate; 84% warning-row rate; average reaction window 139.8s.
- Recommended action: Human testing required for noticeability and stress.
- Do not do: Do not treat warning counts as proof that humans saw or understood warnings.
- Evidence: Pressure/Cinderfen rows: 570.
- Evidence: Pressure warnings shown: 1095.

### Cinderfen Crossing Fairness

- Normal expected state: Safe Beginner wins all current rows; other route timeouts can remain monitor items.
- Warning threshold: Any repeated Safe Beginner failure or >=45% route timeout rate.
- Strong signal threshold: Safe-route losses/timeouts across repeated runs.
- Current signal: 100% Safe Beginner win rate; 22% all-profile timeout rate.
- Recommended action: No structural tuning; prioritize human route feel.
- Do not do: Do not tune Cinderfen from non-safe route timeouts alone.
- Evidence: Cinderfen Crossing record: 230-0-65 across 295 extended metric rows.

### Cinderfen Watch Fairness

- Normal expected state: Safe Beginner wins all current rows; other route timeouts can remain monitor items.
- Warning threshold: Any repeated Safe Beginner failure or >=45% route timeout rate.
- Strong signal threshold: Safe-route losses/timeouts across repeated runs.
- Current signal: 100% Safe Beginner win rate; 20% all-profile timeout rate.
- Recommended action: No structural tuning; prioritize human route feel.
- Do not do: Do not tune Cinderfen from non-safe route timeouts alone.
- Evidence: Cinderfen Watch record: 220-0-55 across 275 extended metric rows.

### Ashen Outpost Timeout Spike

- Normal expected state: Safe play remains stable, with route timeouts watched as pacing/final-assault evidence.
- Warning threshold: Any repeated safe-route failures or >=10% defeat rate.
- Strong signal threshold: Safe-route failures plus high timeout rate across repeated batches.
- Current signal: 28% timeout rate; 0% defeat rate.
- Recommended action: Monitor final-assault pacing and ask humans whether timeouts feel fair.
- Do not do: Do not change Ashen Outpost numbers from timeout telemetry alone.
- Evidence: Ashen Outpost record: 190-0-75 across 265 extended metric rows.

### Objective Completion Drop

- Normal expected state: Primary objective completion stays at or above 70% across overlapped extended profile rows.
- Warning threshold: <55% primary objective completion rate.
- Strong signal threshold: <45% primary objective completion rate.
- Current signal: 74% primary objective completion rate.
- Recommended action: No change.
- Do not do: Do not infer player confusion from objective completion alone.
- Evidence: Primary objective completed in 1320/1775 extended metric rows.

### Resource Starvation Spike

- Normal expected state: Resource problems are localized, not a global economy starvation signal.
- Warning threshold: >=20% non-victory rows end with very low resource surplus.
- Strong signal threshold: >=35% non-victory starvation rows, suggesting future economy-system review.
- Current signal: 0% low-resource non-victory row rate.
- Recommended action: No change.
- Do not do: Do not globally raise resources without node/profile evidence.
- Evidence: Low-resource non-victory rows: 0/1775.
