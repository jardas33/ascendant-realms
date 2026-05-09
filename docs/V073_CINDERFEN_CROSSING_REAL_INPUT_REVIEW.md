# v0.7.3 Cinderfen Crossing Real-Input Review

Date: 2026-05-09

Status: Phase 3 real-input pressure review. This document records the closest available browser-input review for `cinderfen_crossing` without adding gameplay, maps, units, factions, rewards, saves, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive holds, or broad systems.

## 1. Review Target

Battle: `cinderfen_crossing`

Map: `cinderfen_causeway`

Pressure plan: `causeway_contest_pressure`

Primary review question: can a player notice and understand the Cinder Shrine pressure sequence while the Cinder Shrine reward/status beat remains readable?

Secondary review questions:

- Is the Cinder Shrine visible enough to motivate movement?
- Is `Cinder Shrine Surge` readable when the shrine is captured?
- Does the delayed pressure warning explain what changed?
- Does the status surface leave objectives, resources, minimap, and selected-unit UI readable?
- Does the current evidence justify any tiny copy, timing, status-duration, or defeat-tip change?

## 2. Evidence Labels

No direct human manual pass was available inside this environment. The review therefore uses two labeled evidence types:

- Controlled browser-input evidence: Playwright launched the app, clicked through visible campaign UI, camera-centered the shrine for observation, and issued a real right-click move order through the browser.
- Seeded surrogate evidence: Playwright seeded the post-Ashen campaign state, read runtime state, and in one pass used the existing `captureSite` hook to force `cinder_crossing` capture and observe the delayed pressure warning.

These observations should not be described as full human play. They are closer to real input than simulator telemetry, but Emmanuel should still run the manual checklist before any v0.8 live-pressure experiment.

## 3. What Was Actually Run

Setup:

- Started the app on `http://127.0.0.1:5174/`.
- Seeded a post-Ashen Chapter 2 campaign state.
- Continued the campaign through the visible UI.
- Opened `cinderfen_overlook`.
- Chose the Overlook option `aid_marsh_refugees`.
- Launched Cinderfen Crossing through the campaign UI.

Initial launch observation:

| Field | Observation |
| --- | --- |
| Mode | `campaign_node` |
| Campaign node | `cinderfen_crossing` |
| Map | `cinderfen_causeway` |
| Pressure plan | `causeway_contest_pressure` |
| Selected player units | 6 |
| Pressure warnings shown | 0 |
| Triggered pressure stages | none |
| Reinforcement applied | false |
| Console errors | 0 |

Controlled browser-input shrine pass:

- Camera assistance centered the Cinder Shrine area so the browser could issue a reliable right-click order.
- A real browser right-click move order was issued at the visible shrine area.
- The player force naturally captured `cinder_crossing` at about 19 seconds in one clean pass.
- No capture hook was used for this natural capture pass.

Natural shrine-capture observation:

| Field | Observation |
| --- | --- |
| Captured site | `cinder_crossing` |
| Owner after capture | `player` |
| Completed objective | `capture_cinder_crossing` |
| Status line | `Cinder Shrine Surge: +20 Aether` |
| Status priority | `objective` |
| Pressure stage completed | `shrine_route_warning` |
| Pressure warnings shown | 1 |
| Reinforcement applied | false |
| Console errors | 0 |

Seeded surrogate delayed-warning pass:

- In an earlier review pass, the same battle was launched through the campaign UI.
- The existing test hook captured `cinder_crossing` after natural movement proved inconsistent in automation.
- The battle then advanced until the delayed pressure stage became visible.

Delayed warning observation:

| Field | Observation |
| --- | --- |
| Status line | `Ashen scouts mark the center road. Expect faster pressure after the shrine.` |
| Status priority | `pressure` |
| Pressure stages completed | `shrine_route_warning`, `causeway_contest` |
| Pressure warnings shown | 2 |
| Reinforcement applied | false |
| Console errors | 0 |

## 4. Screenshot Evidence

Local screenshot artifacts:

- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-crossing-launch.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-crossing-centered-before-move.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-crossing-natural-shrine-surge.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-crossing-shrine-surge.png`
- `C:\Users\barro\AppData\Local\Temp\ascendant-v073-crossing-pressure-warning.png`

Visual read:

- Launch screenshot: the battle HUD, objectives, resources, selected-unit panel, and minimap were readable with no pressure warning at battle start.
- Natural shrine-surge screenshot: `Cinder Shrine Surge: +20 Aether` was readable in the top status surface, `Claim the Cinder Shrine` was marked done, and the objective/resource/minimap/selection surfaces remained readable while combat was active.
- Delayed pressure screenshot: `Ashen scouts mark the center road. Expect faster pressure after the shrine.` was readable in the top pressure status surface without covering objectives, resources, minimap, or selected-unit UI.

The delayed-warning screenshot came from a seeded surrogate pass and should be treated as visibility evidence, not as a clean full battle play result.

## 5. Findings

The shrine reward beat is protected. In the natural capture pass, `Cinder Shrine Surge: +20 Aether` owned the status line with `objective` priority, while the pressure stage completed in telemetry. This is the correct ordering for player comprehension.

The delayed pressure warning is understandable. The copy names enemy attention on the center road and gives a practical read: expect faster pressure after taking the shrine. It does not imply live construction, workers, capture-site contest AI, or defensive-hold behavior.

The warning surface is readable at the reviewed desktop viewport. The status line stayed in the top HUD area, and the objective list, resources, minimap, selected units, and command surface remained legible in the screenshot evidence.

Automation still struggled to reproduce a clean shrine route every time. One controlled right-click pass captured the shrine naturally, while later attempts fought Cinder Guardians or stopped short. This is a reason to keep the manual player checklist, not a reason to alter pressure mechanics.

Fast Army bypass was not proven or disproven by this pass. Existing telemetry still says Fast Army often clears Crossing before pressure matters, and v0.7.2 already treats that as acceptable strategy expression unless manual play says it feels cheap.

## 6. Decision

No Crossing gameplay, data, warning copy, warning timing, status duration, defeat-tip, telemetry, e2e, balance, reward, save, map, unit, faction, worker, construction, economy AI, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression change is justified in Phase 3.

Reason:

- The natural browser-input pass confirmed shrine capture can show the objective reward clearly.
- The seeded surrogate pass confirmed the delayed pressure warning remains readable.
- Console errors were 0.
- `pressureReinforcementApplied` stayed false.
- The remaining uncertainty is human attention under real hand-play, not a verified copy or timing defect.

## 7. Manual Follow-Up Questions

Emmanuel should still answer these during the manual playtest:

- Did you notice `Cinder Shrine Surge` without looking for it?
- Did you notice the delayed pressure warning while ordering units?
- Did the warning change whether you defended, regrouped, or pushed?
- Did a quick Crossing clear feel clever, or did it make pressure feel irrelevant?
- Did the shrine route feel worth contesting without pressure becoming noisy?
