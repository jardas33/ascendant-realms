# v0.7.2 Pressure Readability Polish Decision

Date: 2026-05-09

Status: Phase 5 no-change decision. This note records why v0.7.2 does not change pressure warning copy, timing, status duration, defeat tips, telemetry labels, e2e coverage, or mechanics after the Cinderfen Crossing and Cinderfen Watch reviews.

## 1. Inputs Reviewed

- `docs/V072_CINDERFEN_CROSSING_PRESSURE_REVIEW.md`
- `docs/V072_CINDERFEN_WATCH_PRESSURE_REVIEW.md`
- `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`
- `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`
- `PLAYTEST_TELEMETRY.md`
- Local browser screenshots from the Phase 3 and Phase 4 seeded review passes.

## 2. Crossing Decision

No Crossing readability polish is applied.

Evidence:

- `Cinder Shrine Surge: +20 Aether` keeps `objective` status priority immediately after shrine capture.
- The delayed warning `Ashen scouts mark the center road. Expect faster pressure after the shrine.` appears with `pressure` priority around 30.8s in the surrogate review.
- The warning is readable in the status frame, does not overlap core HUD surfaces, and does not imply construction, live reinforcements, or capture-site contest AI.
- `pressureReinforcementApplied` remains false.
- Existing telemetry shows Crossing pressure is safe: 26 wins / 0 defeats / 13 timeouts, with no enemy-pressure analyzer warning.

Reason for no change:

The main remaining Crossing question is human attention during live play, not unclear copy or broken timing. Changing text or timing now would be speculative.

## 3. Watch Decision

No Watch readability polish is applied.

Evidence:

- The immediate warning `The Watch Captain tightens the road guard. Keep income protected.` appears with `pressure` priority after Watch Road capture.
- The delayed warning `Enemy horns answer your advance. Expect faster pressure on the raised road.` appears with `pressure` priority around 37.0s in the surrogate review.
- Pressure priority protects the delayed warning from an ordinary normal status replacement attempt.
- The warnings are readable in screenshots and do not overlap objectives, minimap, resources, or selected-unit UI.
- `pressureReinforcementApplied` remains false.
- Existing telemetry shows Watch pressure is early and always triggered, but not structurally punishing: 25 wins / 0 defeats / 11 timeouts and no enemy-pressure analyzer warning.

Reason for no change:

The first Watch warning is early, but it is caused by the player claiming Watch Road and tells the player to protect income. The current evidence supports keeping that cause-and-effect readable rather than moving the trigger.

## 4. Explicit Non-Changes

v0.7.2 Phase 5 applies no changes to:

- pressure warning copy
- stage timing
- warning timing
- status duration
- defeat-tip text
- telemetry labels
- e2e coverage
- pressure plan scope
- existing-wave timing nudge strength

It also keeps all stronger actions warning/telemetry-only:

- `reinforce_next_wave`
- `contest_capture_site`
- `defensive_hold`

## 5. Follow-Up

Use Phases 6 and 7 to judge strategy extremes:

- whether Retinue + Training Yard II makes pressure irrelevant enough to become a balance watchpoint
- whether Greedy Economy needs clearer timeout guidance
- whether Fast Army bypass should remain accepted strategy expression

Do not tune warning text or pressure timing unless those phases produce a specific evidence-backed readability issue.
