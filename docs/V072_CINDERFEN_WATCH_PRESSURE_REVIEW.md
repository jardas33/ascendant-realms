# v0.7.2 Cinderfen Watch Pressure Review

Date: 2026-05-09

Status: Phase 4 human-paced surrogate review. This review uses seeded browser evidence, existing test hooks, existing telemetry, and screenshot inspection. It does not add mechanics, rewards, saves, maps, units, factions, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Review Target

Battle: `cinderfen_watch`

Map: `cinderfen_watchpost`

Pressure plan: `ashen_watch_captain_pressure`

Primary feel question: does Watch Road pressure feel like a fair enemy commander response rather than a hidden punishment for following the correct objective route?

Secondary feel questions:

- Is the first Watch Road warning readable before combat focus intensifies?
- Does the delayed raised-road warning explain the current pressure?
- Can pressure warnings survive ordinary income/status churn?
- Does Greedy Economy timeout pressure look understandable rather than unfair?
- Does Retinue + Training Yard II trivialize pressure enough to justify immediate tuning?

## 2. Review Method

Evidence sources:

- Seeded Playwright browser pass through the campaign UI from a post-Crossing campaign state.
- Existing battle test hook for capturing `watch_road_toll`.
- Real `BattleScene.update` steps to advance battle time and pressure status timers.
- Screenshot inspection at both immediate and delayed pressure-warning moments.
- Existing v0.7.1 telemetry and pressure e2e coverage.

Temporary review artifacts:

- `C:\Users\barro\AppData\Local\Temp\ascendant-v072-watch-immediate-warning.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v072-watch-delayed-warning.png`

The screenshots were used as local visual evidence only and are not shipped assets.

## 3. Browser Evidence

Initial battle launch:

| Field | Observation |
| --- | --- |
| Mode | `campaign_node` |
| Campaign node | `cinderfen_watch` |
| Map | `cinderfen_watchpost` |
| Launch pressure plan | `ashen_watch_captain_pressure` |
| Stats pressure plan | `ashen_watch_captain_pressure` |
| Triggered stages | none |
| Warnings shown | 0 |
| Reinforcement applied | false |
| Watch Road owner | `neutral` |

Watch Road capture:

| Field | Observation |
| --- | --- |
| Captured site | `watch_road_toll` |
| Owner after capture | `player` |
| Completed objective | `capture_watch_road` |
| Status line | `The Watch Captain tightens the road guard. Keep income protected.` |
| Status priority | `pressure` |
| Triggered pressure stage | `watch_road_response` |
| Warnings shown | 1 |
| Reinforcement applied | false |

The immediate warning is early in the seeded pass because the test hook captures the road almost instantly after launch. That exaggerates timing compared with mouse-driven play, but it still answers an important readability question: when the road is captured, the warning is visible, action-oriented, and does not imply workers, construction, or live reinforcements.

Real-time-like delayed pressure samples:

| Elapsed sample | Status | Priority | Warnings | Triggered stages |
| --- | --- | --- | --- | --- |
| ~5.5s | `+28 crowns` | normal | 1 | `watch_road_response` |
| ~30.9s | `+28 crowns` | normal | 1 | `watch_road_response` |
| ~37.0s | `Enemy horns answer your advance. Expect faster pressure on the raised road.` | pressure | 2 | `watch_road_response`, `watch_road_reinforcement` |

At the delayed warning moment:

- Status priority was `pressure`.
- Remaining status timer was about 3.47 seconds.
- `pressureWarningsShown` was 2.
- `pressureReinforcementApplied` stayed false.
- A generic normal message attempted afterward did not overwrite the active pressure warning.
- No browser console errors were recorded.

Screenshot inspection showed both the immediate and delayed warning banners centered at the top of the playfield. The objective list remained readable, the Watch Road site was visible near the player's start, and the selection panel/minimap did not overlap the pressure text. The delayed warning wrapped onto two lines but stayed within the status frame.

## 4. Telemetry Context

Existing telemetry says Watch pressure is consistently reached but not structurally punishing:

- `ashen_watch_captain_pressure`: 36 runs, 36 triggered, 0 quiet.
- Record: 25 wins / 0 defeats / 11 timeouts.
- Average first pressure: 0:19.
- Warnings shown: 77.
- Simulated reinforcement applications: 0.
- Safe Beginner: 12 wins / 0 defeats / 0 timeouts while triggering pressure in 12/12 runs.
- Greedy Economy: 3 wins / 0 defeats / 9 timeouts while triggering pressure in 12/12 runs.
- Fast Army: 10 wins / 0 defeats / 2 timeouts while triggering pressure in 12/12 runs.

This supports the feel read: Watch pressure is early and always visible in automated routes, but current outcomes do not show a pressure-caused defeat spike.

## 5. Feel Findings

The Watch Road warning is readable. It tells the player the enemy commander noticed the road and gives a practical response: protect income. This is especially useful because Watch Road is close to the player's opening position and is likely to be captured early by a correct route.

The early trigger feels fair in the surrogate review because it is caused by the player claiming the road objective. The warning is not a surprise global timer; it is a response to a visible player action.

The delayed raised-road warning is also readable. It explains faster pressure on the raised road without promising new units or implying live reinforcement promotion. The pressure-priority status guard works against ordinary income/status churn.

The main risk is still human attention, not balance. Watch Road is near the player start, and the first warning may appear while a player is still learning the map shape. A full mouse-driven playtest should judge whether the warning is noticed while units are being selected and moved.

## 6. Strategy Lenses

Safe Beginner style: current evidence supports no change. Safe Beginner wins every Watch run while triggering pressure, so the early warning reads as map identity instead of a difficulty spike.

Greedy Economy style: Greedy timeouts remain a pacing/readability issue, not a pressure-specific defeat problem. The warning is helpful because it points toward protecting income, but Phase 7 should decide whether timeout guidance needs clearer results copy.

Fast Army style: Fast Army still wins most Watch runs despite triggering pressure every time. That suggests the pressure is not over-punishing fast play and does not need an early nerf or buff.

Retinue + Training Yard II style: current Watch evidence does not justify retinue tuning. Retinue strength remains a watchpoint for Phase 6 because it may make pressure irrelevant, but it is not a Watch warning-copy or timing bug.

## 7. Change Decision

No gameplay, data, copy, timing, status-duration, defeat-tip, telemetry, or e2e change is applied in Phase 4.

Reason:

- Both Watch pressure warnings are visible and understandable.
- Pressure priority protects the delayed warning from ordinary normal status churn.
- The first warning is early but directly player-triggered by Watch Road capture.
- No console errors occurred.
- Reinforcement and defensive hold behavior remain inactive.
- Existing telemetry shows safety, not a Watch-specific pressure problem.

## 8. Remaining Human-Play Questions

- Does a real player notice the first Watch Captain warning while selecting units near the start base?
- Does the delayed raised-road warning arrive during combat focus in a real playthrough?
- Do Greedy Economy timeouts need stronger results guidance rather than pressure timing changes?
- Does Retinue + Training Yard II make Watch pressure feel irrelevant enough to tune retinue later?

These questions should feed Phases 6 and 7 and a later full human playtest. They do not justify stronger pressure behavior now.
