# v0.7.2 Cinderfen Crossing Pressure Review

Date: 2026-05-09

Status: Phase 3 human-paced surrogate review. This review uses seeded browser evidence, existing test hooks, existing telemetry, and screenshot inspection. It does not add mechanics, rewards, saves, maps, units, factions, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Review Target

Battle: `cinderfen_crossing`

Map: `cinderfen_causeway`

Pressure plan: `causeway_contest_pressure`

Primary feel question: does Cinder Shrine pressure read as fair, understandable enemy attention without hiding the Cinder Shrine reward/status moment?

Secondary feel questions:

- Does `Cinder Shrine Surge` remain readable when shrine pressure also fires?
- Does the delayed warning explain what changed and why the route matters?
- Does Fast Army bypass feel like acceptable strategy expression?
- Does Greedy Economy receive enough guidance to understand the timeout pressure?

## 2. Review Method

Evidence sources:

- Seeded Playwright browser pass through the campaign UI.
- Existing battle test hook for capturing `cinder_crossing`.
- Real `BattleScene.update` steps to advance battle time and pressure status timers.
- Screenshot inspection at the delayed pressure-warning moment.
- Existing v0.7.1 telemetry and pressure e2e coverage.

Important correction: an earlier exploratory check advanced `runtime.tick` and the pressure runtime directly without advancing `BattleScene` status timers. That was useful for confirming stage state, but it was not valid for visual status timing. The final review evidence below uses `BattleScene.update(..., 1000)` steps so status priority and status duration are exercised through the same surface the HUD uses.

Temporary review artifact:

- `C:\Users\barro\AppData\Local\Temp\ascendant-v072-crossing-pressure-warning-visible.png`

The screenshot was used as local visual evidence only and is not a shipped asset.

## 3. Browser Evidence

Initial battle launch:

| Field | Observation |
| --- | --- |
| Mode | `campaign_node` |
| Campaign node | `cinderfen_crossing` |
| Map | `cinderfen_causeway` |
| Launch pressure plan | `causeway_contest_pressure` |
| Stats pressure plan | `causeway_contest_pressure` |
| Triggered stages | none |
| Warnings shown | 0 |
| Reinforcement applied | false |

Cinder Shrine capture:

| Field | Observation |
| --- | --- |
| Captured site | `cinder_crossing` |
| Owner after capture | `player` |
| Completed objective | `capture_cinder_crossing` |
| Status line | `Cinder Shrine Surge: +20 Aether` |
| Status priority | `objective` |
| Triggered pressure stage | `shrine_route_warning` |
| Warnings shown | 1 |
| Reinforcement applied | false |

The objective status correctly wins the shared battle-status surface at the exact shrine-capture moment. That is desirable: the shrine reward is a core Crossing identity beat, and pressure should not obscure it.

Real-time-like delayed pressure sample:

| Elapsed sample | Status | Priority | Warnings | Triggered stages |
| --- | --- | --- | --- | --- |
| ~5s | `AI: EXPAND - Time 0:05` | normal | 1 | `shrine_route_warning` |
| ~30.8s | `Ashen scouts mark the center road. Expect faster pressure after the shrine.` | pressure | 2 | `shrine_route_warning`, `causeway_contest` |

At the delayed warning moment:

- Status priority was `pressure`.
- Remaining status timer was about 4.48 seconds.
- `pressureWarningsShown` was 2.
- `pressureReinforcementApplied` stayed false.
- No browser console errors were recorded.

The visible screenshot at ~30s showed the warning centered at the top of the playfield, with the objective list, selected units, resources, minimap, and shrine area still readable. The text spans two lines but stays inside the status frame and does not overlap the objectives or selection panel.

## 4. Feel Findings

The Cinder Shrine reward beat is protected. `Cinder Shrine Surge` remains the visible status line immediately after capture because objective priority is higher than pressure priority. This avoids the most likely feel regression from v0.7.1's longer pressure read window.

The delayed pressure warning is understandable. "Ashen scouts mark the center road" gives a clear enemy-intent read, and "Expect faster pressure after the shrine" tells the player why the warning matters without implying hidden construction, live reinforcement promotion, or capture-site contest AI.

The warning is readable but still subtle. The top status line is visible at 1440x900, and the 4.5 second pressure window gives enough time to read it in a surrogate review. A real full play pass is still needed to judge whether players notice it while handling unit orders and combat camera motion.

The pressure remains safe. No live reinforcement is applied, no route-contest behavior occurs, and no save/campaign behavior changes. The pressure signal is warning/telemetry plus the already-existing small timing nudge model.

## 5. Strategy Lenses

Safe Beginner style: current evidence supports no change. A player who captures the shrine sees the reward first, then a delayed enemy-intent warning. That is the right order for a normal stabilizing route.

Greedy Economy style: telemetry still shows Crossing Greedy Economy timeouts, but the review did not find a pressure-specific bug. The warning helps explain that sitting after the shrine invites faster pressure; broader timeout clarity belongs in the Greedy/Fast review phase rather than a Crossing-only tuning change.

Fast Army style: telemetry says Fast Army often bypasses Crossing pressure before it matters. That is acceptable for v0.7.2 because the pressure plan is subtle and should not punish a quick, clean strategy by firing earlier without evidence.

Retinue + Training Yard II style: no Crossing-specific retinue change is justified here. Retinue strength remains a separate watchpoint for Phase 6.

## 6. Change Decision

No gameplay, data, copy, timing, status-duration, defeat-tip, telemetry, or e2e change is applied in Phase 3.

Reason:

- The shrine reward/status beat is readable.
- The delayed pressure warning is visible and clear.
- No console errors occurred.
- Reinforcement and route contesting remain inactive.
- Existing telemetry shows safety, not a Crossing-specific pressure problem.

## 7. Remaining Human-Play Questions

- Does the immediate pressure floating text after shrine capture get noticed when the objective status owns the main line?
- Does the delayed 30-second warning appear during a busy enough moment that a human misses it?
- Does Greedy Economy need broader timeout guidance in results text rather than pressure timing changes?
- Does Fast Army bypass feel satisfying when played by hand rather than only in the simulator?

These questions should be revisited in Phases 6 and 7 and in a future full human playtest. They do not justify stronger pressure behavior now.
