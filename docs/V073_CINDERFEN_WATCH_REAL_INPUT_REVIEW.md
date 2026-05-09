# v0.7.3 Cinderfen Watch Real-Input Review

Date: 2026-05-09

Status: Phase 4 real-input pressure review. This document records the closest available browser-input review for `cinderfen_watch` without adding gameplay, maps, units, factions, rewards, saves, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive holds, or broad systems.

## 1. Review Target

Battle: `cinderfen_watch`

Map: `cinderfen_watchpost`

Pressure plan: `ashen_watch_captain_pressure`

Primary review question: does Watch Road pressure feel readable and fair when the player captures the correct early road objective?

Secondary review questions:

- Is Watch Road visible enough from the opening camera?
- Does the immediate pressure warning stay readable while the player force finishes capturing the site?
- Does the delayed raised-road warning survive ordinary battle status churn?
- Does the warning copy suggest a practical response without implying live reinforcement?
- Does the current evidence justify any tiny copy, timing, status-duration, or defeat-tip change?

## 2. Evidence Labels

No direct human manual pass was available inside this environment. The review uses controlled browser-input evidence:

- Playwright seeded the post-Crossing campaign state.
- The app was launched in Chromium with the same WebGL flags used by the repo Playwright config.
- The campaign continued through visible UI.
- `cinderfen_watch` launched through the visible campaign node/start controls.
- The selected player force received a real browser right-click order to the visible `watch_road_toll` position.
- The battle then ran in real time until the immediate and delayed pressure warnings appeared.

Runtime reads were used to record stage ids, status priority, timers, warning counts, and reinforcement state. Those reads are instrumentation, not human play.

## 3. What Was Actually Run

Setup:

- Started the app on `http://127.0.0.1:5174/`.
- Seeded a post-Crossing campaign state with `cinderfen_watch` available.
- Continued the campaign through the visible UI.
- Launched Cinderfen Watch through the campaign UI.
- Issued one right-click move order to the visible Watch Road Toll world position `{ x: 650, y: 1115 }`, which mapped to screen position `{ x: 650, y: 465 }` at the launch camera.

Initial launch observation:

| Field | Observation |
| --- | --- |
| Mode | `campaign_node` |
| Campaign node | `cinderfen_watch` |
| Map | `cinderfen_watchpost` |
| Pressure plan | `ashen_watch_captain_pressure` |
| Selected player units | 5 |
| Watch Road owner | `neutral` |
| Pressure warnings shown | 0 |
| Triggered pressure stages | none |
| Reinforcement applied | false |
| Console errors | 0 in the final Playwright-flagged run |

An earlier ad hoc launch without the repo's Playwright WebGL flags emitted a Phaser framebuffer warning while still rendering. The evidence pass was rerun with `--use-gl=angle`, `--use-angle=swiftshader`, and `--enable-unsafe-swiftshader`; that rerun had zero console errors and is the source for the observations below.

## 4. Watch Road Capture

The right-click movement captured `watch_road_toll` naturally. No capture hook was needed.

Immediate warning observation:

| Field | Observation |
| --- | --- |
| Capture time | about 7.3 battle seconds |
| Captured site | `watch_road_toll` |
| Owner after capture | `player` |
| Completed objective | `capture_watch_road` |
| Status line | `The Watch Captain tightens the road guard. Keep income protected.` |
| Status priority | `pressure` |
| Status timer | about 4.24s remaining when sampled |
| Pressure stage completed | `watch_road_response` |
| Pressure warnings shown | 1 |
| Reinforcement applied | false |
| Hero HP | 324 / 324 |

The immediate warning is early, but it is directly caused by the player claiming the raised-road income site. It reads as enemy commander attention rather than hidden punishment.

## 5. Delayed Road Warning

The delayed warning appeared during real-time battle progression after the Watch Road capture.

Delayed warning observation:

| Field | Observation |
| --- | --- |
| Delayed warning time | about 42.1 battle seconds |
| Status line | `Enemy horns answer your advance. Expect faster pressure on the raised road.` |
| Status priority | `pressure` |
| Status timer | 4.5s when sampled |
| Pressure stages completed | `watch_road_response`, `watch_road_reinforcement` |
| Pressure warnings shown | 2 |
| Reinforcement applied | false |
| Hero HP | 324 / 324 |

After the delayed warning appeared, a generic normal status message was attempted through instrumentation. The visible status stayed `Enemy horns answer your advance. Expect faster pressure on the raised road.` with `pressure` priority, confirming that the current priority guard still protects the pressure message from ordinary status churn.

## 6. Screenshot Evidence

Local screenshot artifacts:

- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-watch-launch.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-watch-before-road-move.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-watch-immediate-warning.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-watch-delayed-warning.png`

Visual read:

- Launch screenshot: the Watch Road route and battle HUD were readable from the opening camera.
- Immediate warning screenshot: the warning text centered in the top status frame, the `Capture the Watch Road` objective was marked done, Watch Road Toll remained visible under the selected force, and the resources/minimap/selection surfaces stayed readable.
- Delayed warning screenshot: the raised-road warning used two lines but stayed inside the status frame without covering objectives, resources, minimap, or selected-unit UI.

## 7. Findings

Watch Road is a good pressure trigger for V1. It is visible near the opening position, is already an objective, and the player action clearly causes the commander response.

The immediate warning is readable. It tells the player the Watch Captain has noticed the road and gives a practical response: keep income protected. The wording does not imply live reinforcements, workers, construction, capture-site contest AI, or defensive-hold behavior.

The delayed warning is readable and protected from generic status churn. The pressure-priority guard worked in the reviewed pass, and the screenshot evidence shows no HUD overlap.

The pressure is still subtle. It communicates enemy intent, but it does not add combat behavior beyond the existing V1 safe model. That is correct for v0.7.3.

Greedy Economy timeout feel was not fully proven by this pass. The browser review confirms the warning exists and is readable; it does not replace later human judgment about whether a greedy player understands the timeout pattern.

Fast Army remains acceptable. The reviewed path captured Watch Road quickly and still left the pressure as readable signal rather than a hard punishment.

## 8. Decision

No Watch gameplay, data, warning copy, warning timing, status duration, defeat-tip, telemetry, e2e, balance, reward, save, map, unit, faction, worker, construction, economy AI, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression change is justified in Phase 4.

Reason:

- Watch Road capture succeeded through a real browser right-click order.
- The immediate warning was readable and action-oriented.
- The delayed warning appeared in real time and stayed readable.
- A generic normal status update did not overwrite the active pressure warning.
- Console errors were 0 in the final evidence pass.
- `pressureReinforcementApplied` stayed false.

## 9. Manual Follow-Up Questions

Emmanuel should still answer these during the manual playtest:

- Did the Watch Road warning feel like fair enemy response or too early?
- Did you notice the delayed raised-road warning while managing units?
- Did the warning make you leave a guard, build earlier defense, or push faster?
- Did Greedy Economy feel like a clear strategic risk or an opaque timeout?
- Did Fast Army make the road warning feel irrelevant, or did it still add tension?
