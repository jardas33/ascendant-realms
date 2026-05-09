# v0.7.2 Pressure Play Review Report

Date: 2026-05-09

Status: Phase 9 release report. v0.7.2 is a human-paced surrogate review and decision gate for Cinderfen pressure readability. It does not add mechanics, rewards, saves, maps, units, factions, workers, enemy construction, enemy economy, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. What Was Reviewed

v0.7.2 reviewed Enemy Strategic Pressure V1 on the two existing pressure-enabled battles:

- `cinderfen_crossing` / `cinderfen_causeway`
- `cinderfen_watch` / `cinderfen_watchpost`

The review focused on human-perceived feel:

- whether warnings are visible
- whether warnings explain what changed
- whether Cinder Shrine pressure protects shrine readability
- whether Watch Road pressure feels fair
- whether Greedy Economy timeouts are understandable
- whether Fast Army bypass is acceptable strategy expression
- whether Retinue + Training Yard II trivializes pressure
- whether stronger pressure actions should remain warning-only

## 2. Evidence Used

Evidence sources:

- Seeded browser/Playwright Cinderfen Crossing review.
- Seeded browser/Playwright Cinderfen Watch review.
- Local screenshot inspection for Crossing and Watch pressure warnings.
- Existing pressure e2e coverage.
- `PLAYTEST_TELEMETRY.md`.
- `PLAYTEST_TELEMETRY.json`.
- v0.7 and v0.7.1 pressure specs, reports, visibility audits, and action-promotion gate.

No new browser-game mechanics were required to gather evidence.

## 3. Cinderfen Crossing Finding

Crossing pressure is readable enough to keep unchanged.

Findings:

- `Cinder Shrine Surge: +20 Aether` remains visible with `objective` priority immediately after shrine capture.
- The delayed pressure warning appears around 30.8s in the surrogate review.
- The delayed warning text is clear: `Ashen scouts mark the center road. Expect faster pressure after the shrine.`
- Screenshot inspection showed the pressure banner readable without covering objectives, resources, minimap, or selected-unit UI.
- `pressureReinforcementApplied` remained false.
- Browser console errors were 0.

Decision: no Crossing copy, timing, status-duration, defeat-tip, telemetry, e2e, or gameplay change.

## 4. Cinderfen Watch Finding

Watch pressure is early but fair because it is player-triggered by Watch Road capture.

Findings:

- Immediate warning after `watch_road_toll` capture: `The Watch Captain tightens the road guard. Keep income protected.`
- Delayed warning around 37s: `Enemy horns answer your advance. Expect faster pressure on the raised road.`
- Pressure priority protects the delayed warning from ordinary status replacement.
- Screenshot inspection showed both Watch warnings readable without HUD overlap.
- `pressureReinforcementApplied` remained false.
- Browser console errors were 0.

Decision: no Watch copy, timing, status-duration, defeat-tip, telemetry, e2e, or gameplay change.

## 5. Retinue + Training Yard II Finding

Retinue + Training Yard II makes current Cinderfen pressure mostly cosmetic, but this is a saved-progress power watchpoint rather than a pressure bug.

Telemetry read:

- 6 Cinderfen runs.
- 6 wins.
- 0 defeats.
- 0 timeouts.
- 5 pressure-triggered runs.
- 9 warnings.
- 0 losses after pressure.
- 0 total unit losses.
- 0 reinforcement applications.

Decision: no retinue, Training Yard II, pressure, Cinderfen, or reward tuning. Keep this as a future human balance watchpoint.

## 6. Greedy Economy Finding

Greedy Economy still times out often, but it does not show a pressure-caused defeat spike.

Telemetry read:

- Crossing: 13 runs, 1 win, 12 timeouts, 13 pressure triggers, 38 warnings, average first pressure 0:35.
- Watch: 12 runs, 3 wins, 9 timeouts, 12 pressure triggers, 33 warnings, average first pressure 0:07.
- Combined: 25 pressure-triggered runs out of 25, 71 warnings, 0 defeats, and 0 reinforcement applications.

Decision: no timing or copy change. Greedy loses to clock/closure after surviving the first wave, not to a sudden unfair pressure spike. A later real-input playtest can decide whether timeout results need clearer "spend and push" guidance.

## 7. Fast Army Finding

Fast Army bypass is acceptable strategy expression.

Telemetry read:

- Crossing: 13 runs, 12 wins, 1 timeout, only 1 pressure trigger.
- Watch: 12 runs, 10 wins, 2 timeouts, 12 pressure triggers.
- Combined: 22 wins / 0 defeats / 3 timeouts, 13 pressure-triggered runs, 21 warnings, and 0 reinforcement applications.

Decision: no pressure buff aimed at catching Fast Army. Crossing can be rushed before shrine-route pressure matters; Watch already catches Fast Army pressure and still lets fast play win most runs.

## 8. Copy And Timing Changes

No copy or timing changes were applied.

Reviewed and left unchanged:

- pressure warning copy
- pressure stage timing
- pressure status duration
- pressure defeat tips
- telemetry labels
- e2e coverage
- pressure plan scope
- existing-wave timing nudge strength

Reason: the review found no specific readability bug. Changing text or timing would be speculative.

## 9. Stronger Actions Decision

`reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` remain warning/telemetry-only.

Future recommendation:

- If a later goal tests stronger pressure at all, start with simulator-only `reinforce_next_wave` on one node.
- Do not promote live reinforcement until human warning salience and simulator safety both pass.
- Keep `contest_capture_site` blocked until route/pathing/site-ownership evidence is stronger.
- Keep `defensive_hold` blocked until late-push clarity outweighs the timeout/turtling risk.

## 10. Verification And E2E Coverage

Report-gate verification:

- `npm test`: passed with 45 files / 334 tests.
- `npm run build`: passed with the known Phaser vendor warning.
- `npm run validate:content`: passed.
- `npm run test:e2e:smoke`: passed with 12 tests in 5.2m.
- `npm run playtest:sim`: passed with 255 runs across 85 campaign battle nodes.
- `git diff --check`: passed.

E2E coverage decision:

- v0.7.2 does not add new e2e coverage.
- Existing `tests/e2e/enemy-pressure.spec.ts` still covers targeted pressure warning visibility and Tutorial/skirmish no-pressure guards.
- Smoke coverage remains 12 tests and is unchanged by this review.
- Full release verification is reserved for the final v0.7.2 gate.

## 11. Remaining Risks

- Real human input may miss warnings more often than seeded surrogate review.
- Crossing immediate pressure feedback may be less noticeable when `Cinder Shrine Surge` owns the main status line.
- Watch Road pressure can trigger very early and still needs real input feel confirmation.
- Greedy Economy timeout guidance may need clearer Results wording later.
- Fast Army can skip much of Crossing pressure.
- Retinue + Training Yard II can trivialize current pressure and remains a separate balance watchpoint.
- Release e2e lanes remain slow but green in the latest full v0.7.1 gate.
- The known Phaser vendor chunk warning remains.

## 12. Next Recommended Goal

Recommended next long-running goal: v0.7.3 real-input Cinderfen pressure playtest.

Scope:

- Play Cinderfen Crossing and Cinderfen Watch with real mouse/keyboard pacing.
- Focus on warning noticeability, Cinder Shrine salience, Watch Road fairness, Greedy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Keep changes limited to docs, copy, timing, or results guidance unless evidence is overwhelming.
- Do not add workers, real enemy construction, enemy economy, new maps, new units, new factions, rewards, save changes, live reinforcement, route-contest AI, defensive-hold behavior, or broad systems.

Only after that should a future v0.8 consider a simulator-only reinforcement experiment.
