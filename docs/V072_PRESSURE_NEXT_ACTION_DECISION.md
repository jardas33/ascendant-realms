# v0.7.2 Pressure Next Action Decision

Date: 2026-05-09

Status: Phase 8 decision gate. This document decides whether v0.8 should promote `reinforce_next_wave`, `contest_capture_site`, or `defensive_hold` beyond warning/telemetry. It does not implement stronger actions, new units, new maps, new factions, workers, construction, enemy economy, rewards, save changes, or broad systems.

## 1. Evidence Used

v0.7.2 reviewed:

- Cinderfen Crossing pressure through seeded browser evidence and screenshot inspection.
- Cinderfen Watch pressure through seeded browser evidence, screenshot inspection, and priority overwrite checks.
- Retinue + Training Yard II Cinderfen telemetry.
- Greedy Economy timeout telemetry.
- Fast Army bypass telemetry.
- v0.7.1 warning visibility, telemetry, and action-promotion guardrails.

Current pressure remains scoped to:

- `cinderfen_crossing` / `cinderfen_causeway`
- `cinderfen_watch` / `cinderfen_watchpost`

Current implementation remains:

- warning copy
- pressure telemetry
- existing-wave timing nudge
- no live reinforcement promotion
- no capture-site contest AI
- no defensive hold behavior
- no workers, construction, or economy AI

## 2. Overall Decision

Do not promote stronger pressure actions in v0.7.2.

For v0.8, the safest possible first experiment is simulator-only `reinforce_next_wave`, not live combat. `contest_capture_site` and `defensive_hold` should remain blocked from live implementation until more human-play evidence exists.

Recommended order:

1. Keep all three actions warning/telemetry-only now.
2. If future evidence demands more concrete pressure, run a simulator-only reinforcement experiment on one node.
3. Only after that, consider a tiny live reinforcement V0 with existing units and explicit warning lead time.
4. Do not attempt capture-site contest AI or defensive hold before reinforcement is understood.

## 3. `reinforce_next_wave`

Decision: keep warning-only now; consider simulator-only experiment later.

Player value:

- Could make an enemy response feel more tangible after the player claims Watch Road or the Cinder Shrine.
- Could give warning copy visible follow-through if the wave change is modest and readable.
- Could make pressure matter a little more against strong openings without creating new systems.

Risk:

- Easy to feel like hidden spawning if the next wave becomes stronger without enough warning.
- Can punish Greedy Economy timeouts without teaching a better response.
- Can tempt tuning against Retinue + Training Yard II, which would likely hurt normal players first.
- Needs a clear boundary between "existing-wave timing/contents" and forbidden enemy construction/economy.

Required evidence before any live promotion:

- Human players notice the warning before the changed wave arrives.
- Safe Beginner still stabilizes on Crossing and Watch.
- Greedy Economy understands the consequence as strategic debt, not surprise punishment.
- Fast Army remains a valid strategy expression.
- Retinue + Training Yard II is not the sole reason for escalation.

Required tests:

- Unit tests for plan scope and action resolution.
- Runtime tests proving only existing unit ids can be used.
- Tutorial, skirmish, Chapter 1, and Ashen Outpost negative tests.
- Targeted e2e showing warning appears before the adjusted wave matters.
- Simulator determinism tests for reinforcement counts and losses after reinforcement.

Content validation implications:

- Validate existing unit ids.
- Validate positive, tiny reinforcement counts.
- Reject construction, workers, harvesting, economy, placement, building, and new-unit fields.
- Validate node/map scope remains explicit.

Simulator implications:

- Add a simulator-only profile before live runtime behavior.
- Report reinforcement-applied counts separately from warning-only stages.
- Report losses after reinforced waves separately from generic losses after pressure.
- Add analyzer warnings for structural too-hard, warning invisibility, or strategy collapse.

E2E implications:

- Keep coverage outside smoke unless very cheap.
- Assert pressure warning text and active plan id.
- Avoid requiring full victory.
- Add no brittle long wait for a full combat wipe.

Safest future experiment:

- Simulator-only.
- One node only, probably `cinderfen_watch`.
- One existing unit added to one future wave or one mild wave timing/content adjustment.
- Warning must fire at least 20-30 seconds before the wave pressure matters.
- Live runtime remains unchanged until simulator and human play both pass.

## 4. `contest_capture_site`

Decision: keep warning-only; block live implementation for now.

Player value:

- Could make the Cinder Shrine and causeway route feel actively contested.
- Could teach "claim the shrine, then hold the route" more strongly.
- Could make Crossing pressure more visible against non-fast routes.

Risk:

- Real contest behavior needs movement targeting, pathing, site ownership logic, and combat interaction.
- Spawning contest units would violate the hidden-spawning/no-construction boundary.
- Redirecting existing units can produce odd pathing or weaken base defense unless enemy AI is broadened.
- Can turn a readable shrine reward into a confusing tug-of-war.
- Likely grows e2e runtime because movement and ownership changes are slower to assert.

Required evidence before any promotion:

- Human players miss or misunderstand the current shrine pressure despite the warning.
- Players want a more visible shrine contest and can identify where it came from.
- Fast Army bypass remains acceptable.
- Safe Beginner does not get dragged into a frustrating early site fight.

Required tests:

- Unit tests for selecting an existing unit or already-launched wave as the contest source.
- Runtime tests proving no new units are created for the contest.
- Capture-site tests for owner changes and no broken objective completion.
- Pathing-focused regression tests for Cinderfen Causeway.
- Targeted e2e observing contest intent without requiring a full victory.

Content validation implications:

- Validate capture-site ids against allowed maps.
- Validate source behavior cannot specify spawned units, buildings, workers, or construction.
- Reject arbitrary pathing/build placement/economy fields.
- Keep action scope locked to explicit node/map attachments.

Simulator implications:

- Start as a report-only "would contest route" marker, not a live simulation buff.
- Track contest warning time, contest target site, and whether the player held the site.
- Add analyzer warnings if contest pressure makes shrine capture mandatory or creates timeouts.

E2E implications:

- Would need slower, more brittle movement assertions.
- Should stay out of smoke.
- Must include Tutorial/skirmish/Chapter 1/Ashen negative coverage if live behavior exists.

Safest future experiment:

- Do not start here.
- If eventually approved, begin simulator-only as a route-intent marker for `cinderfen_crossing`.
- Never spawn contest units.
- Only consider live behavior by redirecting an already-launched existing wave after warning visibility is proven.

## 5. `defensive_hold`

Decision: keep warning-only; block live implementation for now.

Player value:

- Could make late base/tower pushes feel like the enemy is bracing.
- Could support Cinderfen Watchpost's tower/raised-road identity.
- Could give late warnings more visible follow-through.

Risk:

- Can easily become frustrating turtling or longer timeouts.
- Risks broad enemy AI changes around defense radius, target selection, and wave behavior.
- If it creates or preserves units through economy-like rules, it violates V1 boundaries.
- Current Greedy Economy already times out often, so stronger late defense is especially risky.

Required evidence before any promotion:

- Human players find late pushes unclear or anticlimactic despite current warnings.
- Safe Beginner finishes without excessive timeout risk.
- Greedy Economy timeout guidance improves before late defense is made harder.
- Players understand the hold as local bracing around existing structures, not new construction.

Required tests:

- Unit tests proving no unit or building creation.
- Runtime tests for local scope around existing enemy structures only.
- Simulator tests separating late-hold losses/timeouts from normal late pressure.
- E2E launch/warning coverage if live behavior is ever added.

Content validation implications:

- Validate finite, modest defensive radius if such a field is ever live.
- Reject unit creation, building creation, construction, economy, and global AI override fields.
- Validate stage timing so hold cannot fire before the player has a fair route read.

Simulator implications:

- Report late-hold trigger time and battle duration after hold.
- Add analyzer warnings for timeout increases.
- Compare Greedy Economy separately because it is the most vulnerable to late-stall changes.

E2E implications:

- Live defensive hold would be hard to test without long waits.
- Keep any first coverage targeted and non-smoke.
- Prefer checking warning/telemetry rather than requiring a full late assault.

Safest future experiment:

- Do not start here.
- If later approved, run simulator-only late-hold markers before live behavior.
- A live V0 would have to be a local temporary defense-radius preference around existing structures only, with no unit creation and no economy effect.

## 6. Final Gate

v0.7.2 keeps all three stronger actions warning/telemetry-only.

Future v0.8 recommendation:

- Do not promote any stronger action until at least one full human playtest confirms current warnings are noticed and understood.
- If a future goal insists on an experiment, start with simulator-only `reinforce_next_wave` on one node.
- Keep `contest_capture_site` and `defensive_hold` blocked until pathing, timeout, and human salience evidence are stronger.
