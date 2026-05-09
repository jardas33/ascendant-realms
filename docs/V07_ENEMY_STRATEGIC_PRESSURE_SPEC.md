# v0.7 Enemy Strategic Pressure V1 Spec

Date: 2026-05-09

Status: Phase 9 balance checkpoint. The implemented V1 scope is data-driven pressure metadata, validation, campaign-only runtime warning/telemetry, one safe next-wave timing adjustment, small defeat-tip feedback, simulator telemetry, and targeted e2e coverage. The Phase 9 telemetry gate applies no tuning. It still does not add workers, real enemy construction, new maps, new units, new factions, dynamic enemy economy, save fields, save-version changes, campaign reward changes, tutorial rewards, or broad systems.

## Purpose

Enemy Strategic Pressure V1 should make selected enemies feel more strategic and reactive while staying safely inside the current browser prototype.

The system should:

- Make enemy commanders feel like they are responding to important player actions.
- Use existing maps, units, buildings, AI personalities, and battle pacing.
- Preserve the current campaign balance and tutorial behavior.
- Keep Chapter 1 and the v0.6 Tutorial / Proving Grounds stable.
- Add telemetry so the pressure can be measured before it is expanded.

The system should not:

- Become full enemy construction.
- Add workers, harvesters, build placement, enemy base expansion, or dynamic enemy economy.
- Add maps, factions, units, rewards, save fields, or campaign progression changes.
- Make pressure mandatory across all battles.

## System Model

### EnemyStrategicPressurePlan

Planned fields:

| Field | Type intent | Notes |
| --- | --- | --- |
| `id` | string id | Unique stable content id. |
| `name` | string | Player-facing or report-facing plan name. |
| `description` | string | Short design description. |
| `scope` | enum/string | V1 scope such as `campaign_node` or `disabled`. |
| `allowedMapIds` | string[] | Existing map ids only. |
| `allowedNodeIds` | string[] | Existing campaign node ids only. |
| `personalityTags` | string[] | Tags such as `hexfire`, `watch`, `causeway`, or `defensive`. |
| `stages` | `PressureStage[]` | Ordered stage definitions. |
| `telemetryTags` | string[] | Stable report labels. |
| `enabledByDefault` | boolean | V1 plans should be explicit and easy to disable. |
| `notes` | string | Guardrail notes for designers and validators. |

Plans are content metadata. They are not saved to the hero or campaign save. Runtime state should be reconstructed from the active battle launch and current battle stats.

### PressureStage

Planned fields:

| Field | Type intent | Notes |
| --- | --- | --- |
| `id` | string id | Unique within its plan. |
| `trigger` | trigger definition | One allowed V1 trigger. |
| `delaySeconds` | number optional | Delay after trigger before action fires. |
| `battleTimeSeconds` | number optional | Absolute battle time trigger when applicable. |
| `condition` | condition definition optional | V1 filter such as site id or unit/building id. |
| `action` | action definition | One allowed V1 action. |
| `intensity` | `minor` / `moderate` | V1 should not exceed moderate. |
| `warningCopy` | string optional | Short player-readable warning. |
| `telemetryLabel` | string | Stable telemetry/report label. |

Stages should be one-shot by default. Repeating pressure is out of V1 scope.

## Allowed V1 Triggers

Allowed triggers:

- Battle start time.
- Player captures a site.
- Player destroys a structure.
- Player trains first army unit.
- Enemy hero damaged or defeated, only if already supported by existing systems.
- Late battle time.

Initial implementation should prioritize:

- `player_captures_site`.
- `battle_time`.
- `player_trains_first_army_unit`, only if the existing battle stats make this easy to detect.

Enemy hero triggers should stay planned-only for V1 unless they can reuse existing enemy hero stats without adding new combat hooks.

## Allowed V1 Actions

Allowed actions:

- Show pressure warning copy.
- Mark telemetry.
- Send an existing attack wave sooner or later if the existing wave controller supports it safely.
- Add existing unit reinforcement to a future wave only if this can reuse existing enemy units/training safely.
- Temporarily increase enemy rally or defense behavior around existing units/buildings if this stays local.
- Contest a capture site using existing units if the movement order is safe.
- Activate a defensive hold around the existing enemy base if this stays local.

Initial implementation should prioritize:

- Warning copy.
- Telemetry mark.
- Small wave timing pressure or warning-only fallback.

The implementation should not ship a combat-strength effect unless simulator and e2e evidence show it is readable and stable.

## Forbidden V1 Actions

Forbidden actions:

- Spawning new buildings as construction.
- Placing buildings.
- Workers.
- Enemy workers.
- Harvesting.
- Dynamic enemy economy.
- Enemy base expansion.
- New unit types.
- New maps.
- New factions.
- Permanent save changes.
- Save-version bump.
- Campaign reward changes.
- Tutorial rewards.
- Broad `BattleScene` rewrites.

Content validation should reject or fail closed on fields that attempt to express workers, construction, economy, build placement, or new content.

## Candidate V1 Nodes

V1 will use at most two existing battle nodes.

### Candidate A: Cinderfen Watch

Plan concept: Ashen Watch Captain Pressure.

Node and map:

- Node: `cinderfen_watch`.
- Map: `cinderfen_watchpost`.
- AI personality: `hexfire_cult`.

Planned stages:

| Stage | Trigger | Action | Intensity |
| --- | --- | --- | --- |
| Watch Road response | Player captures `watch_road_toll` | Show warning and mark telemetry. | Minor |
| Watch road reinforcement | Short delay after Watch Road response | If safe, nudge next existing enemy wave timing or mark planned reinforcement telemetry. | Minor |
| Late watch hold | Late battle time | Show warning/telemetry that the watchpost is holding around the existing base. | Minor |

Example warning copy:

- `The Watch Captain tightens the road guard. Keep income protected.`
- `Enemy horns answer your advance. Expect faster pressure on the raised road.`

Reason for inclusion:

- The Watch Road Toll is already a clear route objective.
- The enemy Watchtower and Barracks are already present.
- There is no named rival commander on the node.

### Candidate B: Cinderfen Crossing

Plan concept: Causeway Contest.

Node and map:

- Node: `cinderfen_crossing`.
- Map: `cinderfen_causeway`.
- AI personality: `hexfire_cult`.

Planned stages:

| Stage | Trigger | Action | Intensity |
| --- | --- | --- | --- |
| Shrine response | Player captures `cinder_crossing` | Show warning and mark telemetry. | Minor |
| Causeway contest | Short delay after Shrine response | If safe, nudge next existing enemy wave timing toward visible pressure; otherwise warning/telemetry only. | Minor |
| Late causeway push | Late battle time | Mark telemetry and show a small late-push warning if battle is still active. | Minor |

Example warning copy:

- `Enemy horns answer the Cinder Shrine. Hold the route before pushing on.`
- `Ashen scouts mark the center road. Expect faster pressure after the shrine.`

Reason for inclusion:

- The Cinder Shrine is already strategically important.
- A pressure warning can improve shrine salience.
- No new content is needed.

### Excluded From V1: Ashen Outpost

Ashen Outpost is excluded from V1 runtime attachment.

Reasons:

- It already uses Captain Malrec.
- It has milestone battle pacing.
- It has rival rewards and trophy state.
- It has special objective effects and defeat tips.
- Existing telemetry already flags retinue and Training Yard II interactions as watch items.

## Tuning Policy

V1 tuning should be subtle.

Rules:

- Pressure should be visible through warning copy and telemetry.
- Pressure should not create a structural too-hard node.
- Pressure should not erase Fast Army as a valid quick-clear strategy.
- Pressure should not trivialize Safe Beginner or Greedy Economy reads.
- Pressure should not alter campaign rewards, Cinderfen rewards, map geometry, or progression.
- Pressure should be disabled or scoped down if telemetry shows repeated unfair losses, new timeouts, or invisible triggers.

Allowed tuning:

- Stage timing.
- Warning timing.
- Plan scope.
- Reinforcement count or removal if a safe reinforcement action is implemented.

Not allowed:

- Broad enemy AI rewrite.
- New units or maps.
- New rewards.
- Enemy economy or construction systems.
- Save migration.

## Tests And Validation

Content validation should cover:

- Unique pressure plan ids.
- Unique stage ids within a plan.
- Valid allowed map ids.
- Valid allowed campaign node ids.
- Node-map compatibility for attached plans.
- Valid trigger types.
- Valid action types.
- Existing unit references for reinforcement actions.
- Existing capture-site references for capture-site triggers or contest actions.
- No forbidden action types.
- No worker, construction, build placement, harvesting, or economy fields.
- Disabled or upcoming plans still cannot reference missing maps or nodes.

Unit tests should cover:

- Data shape and uniqueness.
- Resolver behavior for campaign node attachments.
- Trigger/stage resolution.
- Tutorial and skirmish exclusion unless explicitly configured.
- Failing validation for missing ids and forbidden fields.

## Runtime Strategy

Runtime should fail closed:

- If no plan is attached, there is no pressure behavior.
- If launch mode is `tutorial`, there is no pressure behavior.
- If launch mode is `skirmish`, there is no pressure behavior unless a later explicit config allows it.
- If a stage references missing content, validation should catch it before runtime.

Smallest acceptable runtime V1:

- Resolve one active plan from the campaign node.
- Track active plan id, triggered stage ids, completed stage ids, emitted telemetry labels, first pressure time, warning count, and reinforcement applied yes/no.
- Listen to battle time and existing player action signals.
- Emit warning copy through the existing battle message surface.
- Mark stats/telemetry through `BattleRuntime`.

Optional runtime effect:

- If safe, nudge an existing future enemy wave or queue one modest existing-unit reinforcement through current systems.
- If that requires broad scene changes, ship warning/telemetry-only and document why.

## Simulator Integration

Simulator telemetry should add:

- `enemyPressurePlanId`.
- `triggeredStages`.
- `reinforcementApplied`.
- `firstPressureTime`.
- `pressureWarningsShown`.
- `lossesAfterPressure`.

Simulator analysis should flag:

- Pressure trivial if no stage ever triggers.
- Pressure too punishing if selected nodes become structural too-hard.
- Pressure too invisible if warnings or telemetry are absent.
- Pressure suspicious if Fast Army quick-clear becomes the only reliable strategy.

Profiles should separate:

- Baseline without pressure.
- Pressure-enabled Cinderfen Crossing.
- Pressure-enabled Cinderfen Watch.

## E2E Strategy

Add minimal browser coverage without bloating smoke.

Preferred first coverage:

- A targeted release/deep test that launches one pressure-enabled battle.
- Trigger the pressure condition cheaply.
- Assert the warning appears.
- Assert no crash.
- Assert Tutorial / Proving Grounds launches without pressure warning.

Smoke should stay light unless the pressure test is cheap and stable.

## Rollback Plan

The system should be easy to disable.

Rollback steps:

1. Remove pressure plan id attachments from selected campaign nodes.
2. Keep the inert data model and validation if useful.
3. Disable runtime resolution when no active plan is found.
4. Re-run source/test or battle/simulator gates depending on the rollback surface.
5. Document the reason in `LLM_GAME_HANDOFF.md`.

No save migration should ever be needed for rollback because V1 should not write persistent pressure state.

## Phase 2 Decision

Proceed to Phase 3 with data types and metadata only.

Initial data should define exactly two V1 plans:

- `ashen_watch_captain_pressure` for `cinderfen_watch` on `cinderfen_watchpost`.
- `causeway_contest_pressure` for `cinderfen_crossing` on `cinderfen_causeway`.

Both plans should stay modest, use existing ids only, and carry explicit notes that they are pressure events, not enemy construction.

## Phase 3 Metadata Checkpoint

Phase 3 added the inert TypeScript data model and initial V1 pressure metadata:

- Types: `src/game/types/EnemyPressureTypes.ts`.
- Data: `src/game/data/enemyPressurePlans.ts`.
- Indexing: `ENEMY_PRESSURE_PLAN_BY_ID` and `requireEnemyPressurePlan`.
- Pure metadata tests: `src/game/data/enemyPressurePlans.test.ts`.

The two initial plans are still metadata only. They do not attach to campaign launch requests, do not affect runtime behavior, do not alter saves, and do not change tutorial, campaign, skirmish, or simulator results until later gated phases wire them in deliberately.

## Phase 4 Validation Checkpoint

Phase 4 added content validation for enemy strategic pressure plans:

- Unique plan ids.
- Unique stage ids within each plan.
- Valid plan scope.
- Boolean `enabledByDefault`.
- Valid allowed map ids and campaign node ids.
- Campaign node map compatibility with each plan's allowed maps.
- Valid AI personality tags.
- Valid trigger, condition, and action types.
- Existing unit references for trigger/action unit ids.
- Capture-site references constrained to the plan's allowed maps.
- Finite, non-negative stage delay and battle-time fields.
- Positive reinforcement counts and defensive hold radii.
- Forbidden worker, harvesting, construction, placement, and economy field names.

This validation still does not attach plans to runtime. It exists to make later data edits fail before launch if they drift into missing content, hidden construction concepts, or unsafe scope.

## Phase 5 Runtime Checkpoint

Phase 5 attaches the two V1 plans through transient campaign battle launch metadata:

- `cinderfen_crossing` uses `causeway_contest_pressure`.
- `cinderfen_watch` uses `ashen_watch_captain_pressure`.

Runtime behavior remains deliberately narrow:

- Tutorial and skirmish launches do not create a pressure runtime.
- Campaign nodes without an explicit `enemyPressurePlanId` do not create a pressure runtime.
- The runtime tracks active plan id, triggered stage ids, completed stage ids, telemetry labels, first trigger time, warning count, and whether reinforcement was applied.
- Capture-site, structure-destroyed, unit-trained, enemy-hero-defeated, and battle-time triggers can be observed.
- Warning copy is shown through the existing battle message surface.
- `adjust_next_wave_timing` is the only runtime effect applied in Phase 5, because it reuses the existing enemy wave timer.
- `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` remain warning/telemetry-only in Phase 5. They are intentionally not applied yet because live reinforcement or route contesting needs more evidence to avoid becoming hidden spawning, construction, or pathing work.

No save fields, save-version changes, rewards, maps, units, factions, workers, real enemy construction, enemy economy, tutorial rewards, campaign progression changes, or broad `BattleScene` rewrite were added.

## Phase 6 Feedback Checkpoint

Phase 6 keeps player feedback intentionally small:

- Pressure warnings continue to use the existing battle message surface.
- No new HUD panel, cinematic, icon, art, or overlay system was added.
- Tutorial / Proving Grounds still cannot create a pressure runtime, so tutorial overlay priority is unaffected.
- Defeat tips now add one pressure-specific retry note only when pressure actually triggered during the battle.

The result is readable but quiet: players get the warning during the fight and a short retry hint after a pressure-influenced defeat, without adding persistent UI or new tutorial/campaign behavior.

## Phase 7 Simulator Checkpoint

Phase 7 mirrors V1 pressure in the deterministic playtest simulator:

- `PlaytestTelemetry` schema version 3 now records `enemyPressurePlanId`, `triggeredStages`, `reinforcementApplied`, `firstPressureTime`, `pressureWarningsShown`, and `lossesAfterPressure`.
- The simulator resolves pressure only from explicit campaign node attachments and fails closed for non-pressure nodes.
- Capture-site, first-trained-unit, structure-destroyed, enemy-hero-defeated, and battle-time triggers are represented in the scripted driver.
- `adjust_next_wave_timing` applies the same safe next-wave timing nudge as the live runtime.
- `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` remain warning/telemetry-only in simulator output, matching the live V1 safety gate.
- Analyzer output now warns if pressure never triggers, becomes invisible, or coincides with structural too-hard summaries.
- `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` now separate baseline no-pressure runs from pressure-enabled Cinderfen Crossing and Cinderfen Watch runs.

Current generated telemetry shows 180 baseline runs without pressure, 75 pressure-enabled Cinderfen runs, 63 runs with at least one triggered pressure stage, 149 pressure warnings, 0 simulated reinforcement applications, and no enemy-pressure analyzer warnings.

## Phase 8 E2E Checkpoint

Phase 8 adds a targeted release-suite spec instead of expanding smoke:

- Added `tests/e2e/enemy-pressure.spec.ts`.
- Positive coverage launches `cinderfen_watch`, verifies the explicit `ashen_watch_captain_pressure` campaign attachment, captures `watch_road_toll`, checks pressure telemetry/stats, and asserts the delayed Watch Road pressure warning reaches the existing battle status surface.
- Negative coverage launches Tutorial / Proving Grounds and Cinderfen Watchpost skirmish, then verifies no pressure plan id, no triggered stages, and no pressure warning after a skirmish site capture.
- The full Playwright release suite now lists 67 tests across 4 spec files. The smoke lane remains unchanged at 12 tests.

## Phase 9 Balance Checkpoint

Phase 9 reads the simulator output as a no-tuning gate:

- Enemy-pressure analyzer warnings: none.
- Pressure-enabled Cinderfen runs: 75; 63 triggered at least one stage; 149 warnings were shown; 0 simulated reinforcements were applied.
- Cinderfen Crossing remains 26 wins / 0 defeats / 13 timeouts. Safe Beginner wins 13/13, Greedy Economy remains timeout-prone at 1 win / 12 timeouts, and Fast Army still wins 12/13 with pressure mostly bypassed by the quick clear.
- Cinderfen Watch remains 25 wins / 0 defeats / 11 timeouts. Watch pressure triggers in 36/36 runs, Safe Beginner wins 12/12, Greedy Economy remains 3 wins / 9 timeouts, and Fast Army wins 10/12.
- Ashen Outpost is not attached to pressure and remains 22 wins / 0 defeats / 14 timeouts.
- Retinue + Training Yard II remains a strong Cinderfen human-review profile at 6 wins / 0 defeats / 0 timeouts across Crossing and Watch, but it is not a pressure-specific problem.

Decision: keep the two V1 pressure plans scoped and unchanged. Do not promote `reinforce_next_wave`, `contest_capture_site`, or `defensive_hold` into real combat effects until a human play pass confirms warning salience and fairness.
