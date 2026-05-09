# v0.7.1 Enemy Pressure Feel Report

Date: 2026-05-09

Status: release-report checkpoint. v0.7.1 reviews, polishes, and hardens Enemy Strategic Pressure V1 without expanding it into real enemy construction, workers, economy AI, new units, new maps, new factions, rewards, save changes, or stronger live pressure actions.

## 1. What Changed

- Added `docs/V071_ENEMY_PRESSURE_FEEL_AUDIT.md`.
- Polished player-facing pressure warning copy for Cinderfen Crossing and Cinderfen Watch.
- Polished pressure-specific defeat tips so losses point toward holding income, holding the shrine route, regrouping, and pushing after a wave breaks.
- Added battle-status priority for pressure warnings, with a longer pressure read window.
- Added objective status priority above pressure so important capture/objective feedback, such as `Cinder Shrine Surge`, still wins the shared battle status line.
- Hardened focused pressure e2e coverage so an active pressure warning survives a generic normal status replacement attempt.
- Improved simulator markdown reporting with baseline, pressure-enabled, triggered, quiet/untriggered, warning, loss, stage-label, and per-strategy pressure reads.
- Regenerated `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.
- Added `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`.
- Added `docs/V071_PRESSURE_ACTION_PROMOTION_GATE.md`.

## 2. What Did Not Change

- No pressure plan scope change.
- No pressure timing change.
- No existing-wave timing nudge change.
- No live reinforcement promotion.
- No capture-site contest AI.
- No defensive hold behavior.
- No new maps, units, factions, rewards, campaign progression, save fields, or save-version bump.
- No tutorial rewards or tutorial pressure.
- No skirmish pressure.
- No workers, enemy workers, real enemy construction, harvesting, build placement AI, or enemy economy simulation.
- No broad `BattleScene` rewrite.

## 3. Warning Copy Improvements

Cinderfen Watch now uses clearer player-facing warnings:

- `The Watch Captain tightens the road guard. Keep income protected.`
- `Enemy horns answer your advance. Expect faster pressure on the raised road.`
- `Watchpost defenders tighten around the stronghold. Regroup before the tower push.`

Cinderfen Crossing now names the shrine/causeway response without promising live route-contest AI:

- `Enemy horns answer the Cinder Shrine. Hold the route before pushing on.`
- `Ashen scouts mark the center road. Expect faster pressure after the shrine.`
- `Ashen forces gather for a late causeway push. Break the next wave first.`

Defeat tips now explain practical answers after pressure-triggered losses: guard income, hold the shrine route, regroup after the surge, and push after a wave breaks.

## 4. Visibility And Message Priority

The pressure warning surface remains the existing battle status line. v0.7.1 does not add a panel, modal, cinematic, icon, or HUD redesign.

The status system now distinguishes:

- `normal`: routine battle status.
- `pressure`: enemy commander pressure warnings, shown slightly longer and not immediately replaced by normal messages.
- `objective`: critical capture/objective feedback, kept above pressure so pressure cannot hide immediate objective rewards.

This fixed an observed smoke-regression risk where a pressure warning could hide `Cinder Shrine Surge`. The final behavior preserves pressure salience while keeping objective feedback readable.

## 5. E2E Coverage

Focused pressure coverage remains in `tests/e2e/enemy-pressure.spec.ts` rather than the smoke lane.

Coverage now verifies:

- Campaign Cinderfen Watch launches with `ashen_watch_captain_pressure`.
- Capturing `watch_road_toll` triggers pressure telemetry/stats.
- The delayed Watch Road pressure warning appears on the battle status surface.
- An active pressure warning is not replaced by a generic normal status message.
- Tutorial / Proving Grounds remains pressure-free.
- Cinderfen Watchpost skirmish remains pressure-free.

Smoke remains 12 tests. The full release suite remains 67 tests across 4 spec files.

## 6. Simulator Telemetry

Current generated telemetry:

- 255 deterministic runs across 85 campaign battle node/profile summaries.
- 180 baseline no-pressure runs.
- 75 pressure-enabled scoped Cinderfen runs.
- 63 triggered pressure runs.
- 12 quiet/untriggered pressure runs.
- 149 warnings shown.
- 0 simulated reinforcement applications.
- 147 player unit losses recorded after pressure triggers.
- No enemy-pressure analyzer warnings.

Plan reads:

- Causeway Contest pressure: 39 runs, 27 triggered, 12 quiet, 26 wins / 0 defeats / 13 timeouts, average first pressure 2:47.
- Ashen Watch Captain pressure: 36 runs, 36 triggered, 0 quiet, 25 wins / 0 defeats / 11 timeouts, average first pressure 0:19.

## 7. Balance Decision

No tuning was applied.

Reasons:

- Cinderfen Crossing remains structurally reasonable at 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch remains structurally reasonable at 25 wins / 0 defeats / 11 timeouts.
- Ashen Outpost remains unaffected by pressure at 22 wins / 0 defeats / 14 timeouts.
- There are no enemy-pressure analyzer warnings.
- There are no structural `too_easy` or `too_hard` nodes.
- Greedy Economy timeouts are pacing/readability watchpoints, not pressure-caused defeat spikes.
- Fast Army bypasses most Crossing shrine pressure, but that does not justify buffing pressure before human review.
- Retinue + Training Yard II strength predates pressure and should be handled through human retinue/Stronghold review, not by making pressure harsher.

## 8. Promotion Decision For Stronger Actions

`reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` stay warning/telemetry-only.

Reasons:

- v0.7.1 evidence supports warning salience and report clarity, not mechanics promotion.
- Live reinforcement could look like hidden spawning if it is not extremely explicit.
- Capture-site contesting requires movement/pathing and site-target behavior beyond this feel-polish gate.
- Defensive hold behavior risks a broader AI behavior pass and late-battle turtling.
- All three need human-play evidence, simulator-first experiments, targeted tests, and strict existing-unit/no-construction guardrails before any future promotion.

## 9. Remaining Risks

- Human players still need to confirm whether pressure warnings are noticed during normal battle motion.
- Cinderfen Watch pressure can trigger very early, especially on strong profiles.
- Cinderfen Crossing pressure can be bypassed by fast clears.
- Greedy Economy timeouts may need clearer human-facing strategic guidance later.
- Retinue + Training Yard II remains a strong Cinderfen watchpoint.
- Full release e2e remains slow but green.
- The known Phaser vendor chunk warning remains.

## 10. Next Recommended Goal

Run a human-paced Cinderfen pressure play review. Focus on:

- Cinder Shrine warning salience.
- Watch Road timing and fairness.
- Whether pressure warnings are readable without a new panel.
- Fast Army quick-clear feel.
- Greedy Economy timeout clarity.
- Retinue + Training Yard II strength.

Do not add workers, real enemy construction, enemy economy, new maps, new units, new factions, campaign rewards, save changes, live reinforcements, route-contest AI, or defensive-hold behavior until human evidence proves a specific safe need.
