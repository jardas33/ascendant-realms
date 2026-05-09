# v0.7 Enemy Strategic Pressure V1 Report

Date: 2026-05-09

Status: report checkpoint. Enemy Strategic Pressure V1 is implemented as a small, data-driven, campaign-scoped pressure prototype for selected existing Cinderfen battles.

## 1. What Was Implemented

- Added `EnemyStrategicPressurePlan` and `PressureStage` TypeScript types.
- Added two V1 pressure plans in `src/game/data/enemyPressurePlans.ts`.
- Added content validation for plan ids, stage ids, map/node references, trigger/action types, unit references, capture-site references, and forbidden worker/construction/economy fields.
- Attached `causeway_contest_pressure` to `cinderfen_crossing` and `ashen_watch_captain_pressure` to `cinderfen_watch` through campaign battle launch metadata.
- Added a campaign-only runtime tracker for active plan id, triggered/completed stage ids, telemetry labels, first pressure time, warning count, and reinforcement-applied state.
- Added warning copy through the existing battle status surface.
- Added one safe runtime effect: a modest existing next-wave timing nudge.
- Kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.
- Added pressure-aware defeat advice only when a pressure stage actually triggered.
- Extended simulator telemetry and generated reports with pressure plan id, triggered stages, first pressure time, warnings, reinforcement state, and losses after pressure.
- Added targeted Playwright release coverage for a pressure-enabled Cinderfen Watch campaign battle plus Tutorial/skirmish no-pressure guards.

## 2. What Was Not Implemented

- No workers or enemy workers.
- No harvesting or dynamic enemy economy.
- No enemy building placement or real enemy construction.
- No new maps, units, factions, rewards, or campaign progression.
- No save fields, save-version bump, or pressure persistence.
- No tutorial rewards or tutorial pressure behavior.
- No skirmish pressure behavior.
- No broad `BattleScene` rewrite.
- No live unit reinforcement, route contesting, or defensive-hold combat behavior beyond warning/telemetry.

## 3. Why This Is Not Full Enemy Construction

Enemy Strategic Pressure V1 is a one-shot intention layer over existing battle content. It listens for existing battle events, emits warning copy and telemetry, and can nudge the existing enemy wave timer. It does not create buildings, place buildings, train workers, gather resources, evaluate build placement, expand bases, or simulate an enemy economy.

## 4. Nodes And Maps Using V1

- `cinderfen_crossing` on `cinderfen_causeway`: `causeway_contest_pressure`.
- `cinderfen_watch` on `cinderfen_watchpost`: `ashen_watch_captain_pressure`.

Ashen Outpost is intentionally excluded from V1 because it already has Captain Malrec, rival rewards, trophy state, milestone pacing, objective effects, and retinue/Training Yard II watchpoints.

## 5. Allowed V1 Actions

- Show short pressure warning copy.
- Mark battle and simulator telemetry.
- Nudge an existing future attack wave through the current wave timer.
- Keep planned reinforcement, site contesting, and defensive hold as warning/telemetry-only until human play justifies real combat effects.

## 6. Forbidden V1 Actions

- Spawning buildings as construction.
- Placing buildings.
- Workers, enemy workers, harvesting, or economy simulation.
- New unit types, maps, factions, rewards, save fields, or campaign progression.
- Tutorial rewards or tutorial pressure behavior.
- Broad enemy AI or `BattleScene` rewrites.

## 7. Telemetry Results

Latest generated simulator read:

- 255 deterministic runs across 85 campaign battle node/profile summaries.
- 180 baseline runs without pressure.
- 75 pressure-enabled Cinderfen runs.
- 63 pressure runs triggered at least one stage.
- 149 pressure warnings shown.
- 0 simulated reinforcement applications.
- 147 player unit losses after pressure triggered.
- No enemy-pressure analyzer warnings.

Plan reads:

- `causeway_contest_pressure`: 39 runs, 27 triggered, average first pressure 2:47, 72 warnings, 71 losses after pressure.
- `ashen_watch_captain_pressure`: 36 runs, 36 triggered, average first pressure 0:19, 77 warnings, 76 losses after pressure.

## 8. E2E Coverage

Added `tests/e2e/enemy-pressure.spec.ts`:

- Positive coverage launches campaign `cinderfen_watch`, verifies `ashen_watch_captain_pressure`, captures `watch_road_toll`, checks pressure stats, and asserts the delayed warning reaches the battle status surface.
- Negative coverage launches Tutorial / Proving Grounds and Cinderfen Watchpost skirmish, then verifies no pressure plan id, no triggered stages, and no warnings.
- Full Playwright release suite now lists 67 tests across 4 spec files. Smoke stays 12 tests.

## 9. Balance Status

Phase 9 applied no tuning:

- Cinderfen Crossing remains 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch remains 25 wins / 0 defeats / 11 timeouts.
- Ashen Outpost remains untouched by pressure at 22 wins / 0 defeats / 14 timeouts.
- Fast Army remains a valid quick-clear read rather than being erased by pressure.
- Greedy Economy remains timeout-prone but does not show new defeat spikes.
- Retinue + Training Yard II remains strong and needs human review, but it is not a pressure-specific problem.

## 10. Remaining Risks

- Warning visibility may feel too quiet or too easily overwritten by other battle messages in real play.
- Watch Road pressure triggers very early in many simulator paths and needs human readability review.
- Crossing pressure can be bypassed by very fast clears, which may be acceptable but should be played by hand.
- Retinue + Training Yard II remains strong in Cinderfen and should be judged by feel before any numeric tuning.
- Live reinforcement, route contesting, and defensive hold are not ready for real combat behavior.
- Full release e2e remains slow but green.
- The known Phaser vendor chunk warning remains.

## 11. Next Recommended Step

Run a human-paced Cinderfen pressure feel review. Focus on Cinderfen Crossing shrine salience, Cinderfen Watch road-warning readability, Fast Army quick-clear feel, Greedy Economy timeout clarity, and Retinue + Training Yard II strength. Keep any follow-up limited to copy, timing, scope, or telemetry unless human evidence clearly supports a small real combat effect.
