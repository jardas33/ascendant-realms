# v0.7.3 Real-Input Cinderfen Pressure Playtest Report

Date: 2026-05-09

Status: Phase 9 report. v0.7.3 is a real-input pressure playtest gate for Cinderfen Crossing and Cinderfen Watch. It does not add gameplay, maps, units, factions, rewards, saves, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive holds, or broad systems.

## 1. What Was Reviewed

Reviewed pressure-enabled campaign battles:

- `cinderfen_crossing` on `cinderfen_causeway`
- `cinderfen_watch` on `cinderfen_watchpost`

Reviewed questions:

- whether current pressure warnings are noticeable and readable in closer-to-real browser flows
- whether Cinder Shrine pressure preserves `Cinder Shrine Surge` readability
- whether Watch Road pressure feels early but fair
- whether warnings stay readable on the existing status surface
- whether Safe Beginner, Greedy Economy, Fast Army, and Retinue + Training Yard II justify tiny polish
- whether any stronger v0.8 pressure action should be promoted

## 2. Real-Input Vs Automated Evidence

True direct human manual evidence:

- Not available in this environment.
- A player-facing checklist was created so Emmanuel can run the missing hands-on pass.

Controlled browser-input evidence:

- Cinderfen Crossing launched through visible campaign UI after a seeded post-Ashen state.
- A real browser right-click order naturally captured the Cinder Shrine in one pass.
- Cinderfen Watch launched through visible campaign UI after a seeded post-Crossing state.
- A real browser right-click order naturally captured Watch Road.
- Watch delayed pressure appeared during real-time battle progression and survived a generic status replacement attempt.

Seeded surrogate evidence:

- Crossing's delayed pressure warning used the existing capture-site hook because repeated automated movement to the shrine was not stable enough to call full human play.

Simulator evidence:

- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- 255 deterministic runs across 85 campaign battle node/profile summaries

## 3. Cinderfen Crossing Finding

Crossing pressure remains readable enough to keep unchanged.

Findings:

- The natural browser-input shrine capture showed `Cinder Shrine Surge: +20 Aether` with `objective` priority.
- `capture_cinder_crossing` completed and `shrine_route_warning` triggered without applying reinforcement.
- The delayed warning `Ashen scouts mark the center road. Expect faster pressure after the shrine.` was readable in seeded visibility evidence.
- Objective, resource, minimap, and selected-unit surfaces remained readable in screenshot evidence.
- Automation could not reliably reproduce the full shrine route every time, so true human play remains required.

Decision:

- No Crossing warning copy, timing, status-duration, defeat-tip, telemetry, e2e, balance, reward, save, map, unit, faction, worker, construction, economy AI, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression change.

## 4. Cinderfen Watch Finding

Watch pressure remains readable and fair enough to keep unchanged.

Findings:

- Watch Road capture succeeded through a real browser right-click order.
- The immediate warning `The Watch Captain tightens the road guard. Keep income protected.` appeared with `pressure` priority at about 7.3 battle seconds.
- The delayed warning `Enemy horns answer your advance. Expect faster pressure on the raised road.` appeared at about 42.1 battle seconds.
- A generic normal status update did not overwrite the active pressure warning.
- Final evidence pass had zero browser console errors.
- `pressureReinforcementApplied` stayed false.

Decision:

- No Watch warning copy, timing, status-duration, defeat-tip, telemetry, e2e, balance, reward, save, map, unit, faction, worker, construction, economy AI, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression change.

## 5. Strategy-Profile Finding

Safe Beginner:

- Crossing: 13/13 wins with pressure triggered in 13/13.
- Watch: 12/12 wins with pressure triggered in 12/12.
- Decision: pressure teaches caution without creating structural difficulty.

Greedy Economy:

- Crossing: 1 win / 12 timeouts, pressure triggered in 13/13.
- Watch: 3 wins / 9 timeouts, pressure triggered in 12/12.
- Decision: this remains a closure/build-order timeout pattern, not a pressure defeat spike.

Fast Army:

- Crossing: 12 wins / 1 timeout, pressure triggered in only 1/13.
- Watch: 10 wins / 2 timeouts, pressure triggered in 12/12.
- Decision: quick pressure bypass remains acceptable strategy expression.

Retinue + Training Yard II:

- 6 wins / 0 defeats / 0 timeouts across Cinderfen pressure nodes.
- 5 pressure-triggered runs and 9 warnings.
- Decision: this remains a saved-progress power watchpoint, not a reason to make pressure harsher.

## 6. Manual User Checklist

Created:

- `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`

The checklist asks Emmanuel to play Cinderfen Crossing and Cinderfen Watch with normal mouse/keyboard pacing and rate:

- warning clarity
- warning timing
- pressure fairness
- strategic usefulness
- fun
- frustration

The checklist explicitly tells the player not to inspect code, logs, telemetry, tests, save files, or internal debug state.

## 7. Tiny Changes Made

No gameplay, data, copy, timing, status-duration, defeat-tip, e2e, telemetry, balance, reward, save, map, unit, faction, worker, construction, enemy economy, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression changes were made.

Documentation added:

- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_PROTOCOL.md`
- `docs/V073_PRESSURE_REVIEW_SETUP.md`
- `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`
- `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`
- `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`
- `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`
- `docs/V073_EVIDENCE_BACKED_PRESSURE_POLISH_DECISION.md`
- `docs/V08_DIRECTION_DECISION_BRIEF.md`
- `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`

## 8. No-Change Decisions

Kept unchanged:

- `causeway_contest_pressure`
- `ashen_watch_captain_pressure`
- pressure warning copy
- pressure stage timing
- pressure status duration
- pressure defeat tips
- telemetry labels
- e2e coverage
- pressure plan scope
- existing-wave timing nudge strength
- `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` as warning/telemetry-only

Reason:

- The current evidence supports readability, not intervention.
- The missing evidence is true human attention and feel, which should come from Emmanuel's checklist.

## 9. v0.8 Recommendation

Recommended next direction:

1. Option C - Technical performance/e2e runtime pass.
2. Option D - Tutorial v2 onboarding refinement if player-facing clarity is preferred.

Defer:

- Option A simulator-only reinforcement experiment until Emmanuel's manual pressure feedback confirms current warnings are noticed and fair.
- Option B Chapter 2 content continuation until pressure feel and release runway are steadier.

Pressure-specific guardrail:

- If v0.8 later tests stronger pressure, start with simulator-only `reinforce_next_wave` on one node. Do not promote live reinforcement, capture-site contest AI, defensive hold, workers, construction, economy AI, new maps, new units, new factions, rewards, saves, or campaign progression changes.

## 10. Remaining Risks

- Emmanuel has not yet completed the manual checklist.
- Real players may miss the Crossing delayed warning while issuing commands.
- Crossing Fast Army may feel clever or too cheap; simulator evidence alone cannot decide.
- Greedy Economy timeouts may need clearer Results guidance after human play.
- Retinue + Training Yard II may feel rewarding or boring depending on human control.
- Release e2e lanes remain green but slow.
- The known Phaser vendor chunk warning remains.
