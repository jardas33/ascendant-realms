# v0.14.1 Emmanuel Quick Playtest Intake

Date: 2026-05-18

Scope: intake Emmanuel's real quick 30-minute Baseline Cautious private playtest feedback and classify each issue using the v0.12.5/v0.12.6 intake framework.

This document uses only the feedback supplied for session `PT-20260518-EMMANUEL-BASELINE-01` plus existing automated evidence for context. It does not invent additional tester feedback.

## Session Header

| Field | Value |
| --- | --- |
| Session ID | `PT-20260518-EMMANUEL-BASELINE-01` |
| Tester | Emmanuel |
| RTS experience | not provided |
| Date played | 2026-05-18 |
| Build/commit | v0.14 private playtest package context; assumed `0236df7` unless Emmanuel reports otherwise |
| Browser | not provided |
| Screen size | not provided |
| Route/profile | Baseline Cautious |
| Prepared save used | not provided |
| Session length | quick 30-minute route |
| Nodes played | Tutorial and campaign/battle flow implied; exact node list not provided |
| Wins/losses/timeouts | not provided |
| Evidence owner/source | Emmanuel direct feedback in this goal |
| Screenshots/videos | one screenshot described for stuck selection marquee |
| Intake author | Codex |
| Intake date | 2026-05-18 |
| Uncertainty | `missing-browser`, `missing-screen-size`, `missing-exact-nodes`, `missing-result`, `partial-reproduction-details` |

## Intake Rows

| ID | Feedback item | Category | Severity | Priority | Evidence strength | Proposed action | What not to do |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PT-20260518-EMMANUEL-BASELINE-01-I01 | Hovering tutorial objective buttons and Barracks training options makes the surrounding highlight flicker nonstop. | Control / Command Feel; UI readability | S2 Moderate | P2/P3 | One real tester report across multiple UI controls. | Investigate hover/focus/active CSS or state churn; apply small stability fix if root cause is clear. | Do not start a UI redesign or remove accessibility focus styling. |
| PT-20260518-EMMANUEL-BASELINE-01-I02 | Hero skills have no explanation, making it hard to understand what a skill does. | Clarity / Readability | S2 Moderate | P2 | One clear report; visible copy gap likely inspectable. | Add concise ability/skill description copy where the player sees hero skills. | Do not add new skills, rebalance skills, or redesign the hero system. |
| PT-20260518-EMMANUEL-BASELINE-01-I03 | On tutorial steps 5-9, pressing Next Objective did not advance until many seconds later or after multiple clicks. | Actual Bug; Tutorial/control issue | S1 Major | P1 | One real report with repeated steps named. | Reproduce/inspect tutorial gating and button state; fix if active button is clickable before it can advance or if clicks are being swallowed. | Do not weaken tutorial no-save/no-reward assertions or skip tutorial steps. |
| PT-20260518-EMMANUEL-BASELINE-01-I04 | Hero moves next to an enemy but does not visibly attack or reduce enemy life; player cannot confirm attacking state. | Combat readability; possible Actual Bug | S2 Moderate | P2 | One report; unclear if combat failed or feedback was unreadable. | Inspect attack/order state and selected-panel feedback; add Attacking/target feedback if safe. | Do not overhaul combat VFX, damage numbers, or enemy stats from this alone. |
| PT-20260518-EMMANUEL-BASELINE-01-I05 | Hero rename input blocks A/S/D/W letters, likely because global WASD hotkeys intercept text input. | Actual Bug | S1 Major | P0/P1 | One real report with exact affected keys; likely deterministic and inspectable. | Ensure global keyboard shortcuts ignore focused text inputs; add browser/unit coverage for typing WASD into hero name input. | Do not disable battle hotkeys globally when no input is focused. |
| PT-20260518-EMMANUEL-BASELINE-01-I06 | Retreat/move commands during losing combat made tiny movement but units stayed engaged and died. | Control / Command Feel; possible combat command bug | S1 Major | P1/P2 | One real combat report; root cause may overlap attack/aggro/pathing. | Inspect move command vs attack/guard intent; apply narrow fix if move orders fail to clear combat target or resume movement. | Do not make enemies harmless, retune combat, or rewrite broad AI. |
| PT-20260518-EMMANUEL-BASELINE-01-I07 | Selection marquee gets stuck when dragging into the bottom-right HUD/side panel area showing No Selection. | Actual Bug; Control issue | S1 Major | P1 | One report plus screenshot description; likely reproducible through pointer handling. | Ensure pointerup/pointercancel/window blur and HUD boundary cases clear selection drag state. | Do not use DOM fallback for canvas/world clicks or weaken side-panel reachability tests. |
| PT-20260518-EMMANUEL-BASELINE-01-I08 | A selected troop repeatedly snaps back to its original position while moving to a commanded spot. | Actual Bug | S1 Major / possible S0 if reproducible broadly | P0/P1 | One severe report; no video, but behavior is concrete and could break play. | Inspect pathing, command state, separation, and stuck recovery. Fix only if a clear small root cause is found; otherwise document for deeper pathing goal. | Do not rewrite pathfinding/formation movement broadly in this pass. |
| PT-20260518-EMMANUEL-BASELINE-01-I09 | There is no pause; Menu immediately interrupts the game and returns to main menu. | UX/control issue; Feature request if full pause | S2 Moderate | P1/P2 | One clear expectation mismatch; accidental exit can ruin a session. | Add a small pause/confirm overlay if architecture supports it safely, or at minimum confirm before exiting battle. | Do not change save format or build a broad pause/options system. |

## Summary Priorities

Immediate investigation:

1. Text input / WASD bug.
2. Selection marquee stuck over HUD.
3. Unit movement snap-back loop.
4. Tutorial Next Objective delay.
5. Retreat command not obeying.
6. Menu/pause accidental exit.

Secondary clarity/polish after high-confidence fixes:

- Hero skill explanation.
- Hero attack clarity.
- Hover highlight flicker.

## Automated Evidence Context

The v0.13.1a automated lab is useful for route-priority context only. It does not prove or disprove Emmanuel's human usability reports. No tuning should be made from this single Baseline Cautious session.

## Intake Decision

This session is sufficient to open focused bug/usability investigation because several reports are concrete command or input failures on the current private package.

This session is not sufficient to:

- change gameplay numbers
- tune balance
- add new units, maps, factions, or rewards
- start runtime art replacement
- claim broader tester trends
