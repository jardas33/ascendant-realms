# v0.7 Enemy Strategic Pressure Research Audit

Date: 2026-05-09

Status: Phase 1 research audit for Enemy Strategic Pressure V1. This is research only. It does not implement runtime behavior, data models, validation, balance changes, campaign progression, rewards, maps, units, factions, workers, enemy construction, economy simulation, or save changes.

## Purpose

v0.7 should make selected enemies feel more strategic without turning the prototype into a full enemy economy or construction system. The safest direction is a small data-driven pressure layer that reuses existing enemy units, existing buildings, existing maps, existing AI personalities, current battle timers, current warning surfaces, and current simulator telemetry.

## Current Enemy Behavior Systems

The live battle enemy is owned by `EnemyAIController`.

Current behavior already includes:

- Enemy resource income from fixed pacing data.
- Enemy unit training through existing enemy production buildings.
- Timed attack waves against the player base.
- Expansion pressure by sending existing enemy units toward uncaptured capture sites.
- Defensive behavior when player units threaten the enemy base or protected capture sites.
- Personality-based pacing and target preferences.
- First-battle protection so the opening tutorial-style fight has a safer first contact.
- Optional enemy commander participation once the current phase and difficulty allow it.

Important guardrail: the current controller can train from an already spawned enemy production building, but it does not place buildings, spawn workers, gather with workers, pick build locations, expand bases, or run an enemy build order. That makes it a good reuse point for pressure timing, warnings, and selected existing-unit actions.

## Current Wave And Attack Timing

Enemy timing is defined by map `scenario.enemyAI`, battle difficulty, and AI personality modifiers.

The current battle pacing phases are:

| Phase | Time | Current role |
| --- | ---: | --- |
| Opening | 0-120s | No base attack; protects early setup. |
| Expansion | 120-300s | Small pressure with Raiders and Hexers. |
| Pressure | 300-480s | Larger mixed waves, Brutes can enter. |
| Assault | 480s+ | Larger waves, enemy commander can join when configured. |

Difficulty settings control starting enemy unit spawns, enemy income multiplier, first attack delay, attack interval, wave size, expansion interval, training interval, minimum attack size, expansion squad size, commander join delay, and fog.

Stronghold modifiers can already affect warning lead time, so there is an existing pattern for player-readable enemy pressure without changing the core wave system.

## Current Enemy Hero Integration

Enemy heroes are existing unit replacements, not new unit classes or runtime spawns.

The spawner replaces an existing `enemy_commander` unit spawn with the configured enemy hero when the launch request includes an `enemyHeroId`. Rival state, first-defeat rewards, trophies, and enemy hero telemetry are already handled outside the proposed v0.7 pressure scope.

Current named commanders include:

| Commander | Current battle usage | Personality |
| --- | --- | --- |
| Gorak Emberhand | Bandit Hillfort / Broken Ford | Fortress Keeper |
| Veyra Cinders | Aether Well Ruins / Broken Ford | Hexfire Cult |
| Captain Malrec | Ashen Outpost | Hexfire Cult |

Ashen Outpost already has Captain Malrec, special objective advice, and milestone pacing. That makes it useful as a reference, but risky as a first v0.7 pressure target.

## Existing AI Personalities

The current AI personalities are:

- `balanced_warlord`: baseline pacing and mixed unit pressure.
- `raider_rush`: faster attacks, faster expansion, lower defense reserve.
- `fortress_keeper`: stronger defensive reserve and capture-site protection.
- `hexfire_cult`: Hexer-forward pressure with quicker magical tempo.

Personalities already tune first attack delay, attack interval, expansion interval, training interval, commander join delay, income, preferred attack units, wave size, defense reserve, and capture-site protection. A pressure plan can safely use personality tags for filtering and copy tone without needing a new AI architecture.

## Existing Map And Base Data

The best V1 candidates are current Chapter 2 Cinderfen battles because they are already post-tutorial, have visible capture-site objectives, and currently have no named rival commander.

| Node | Map | Existing pressure hooks | Current risk |
| --- | --- | --- | --- |
| Cinderfen Crossing | `cinderfen_causeway` | Cinder Shrine, side income sites, enemy Barracks, enemy Watchtower, Hexfire Cult pacing | Fast Army can clear quickly, Shrine salience is a known watch item. |
| Cinderfen Watch | `cinderfen_watchpost` | Watch Road Toll, Ash Cistern, enemy Barracks, enemy Watchtower, raised-road route | Waystation/Aftermath density and Watchpost readability are known watch items. |
| Ashen Outpost | `ashen_outpost` | Burned Shrine, enemy Barracks, Watchtower, Captain Malrec | Milestone node with rival rewards, retinue/Training Yard II risk, and stronger existing objective logic. |

Cinderfen Crossing and Cinderfen Watch both use existing Ashen Covenant units and buildings. Both are campaign nodes using `hexfire_cult` and normal difficulty. Neither requires new maps, new units, new factions, workers, or construction to express commander pressure.

## Current Objective And Defeat Tip Systems

Secondary objectives are completed by existing capture, building destruction, and unit defeat hooks. Results advice already has node-specific defeat tips for:

- Ashen Outpost.
- Cinderfen Crossing.
- Cinderfen Watch.

This means v0.7 can add pressure-specific feedback later without replacing the objective system. If pressure contributes to defeat, the safest results change would be a small extra tip driven by battle stats, not a new results panel.

## Current Simulator And Telemetry

The playtest simulator mirrors the live AI shape:

- It uses the same campaign battle nodes.
- It resolves map enemy AI config and AI personality.
- It models enemy training, warnings, waves, contact, first-wave survival, objectives, rewards, rival state, and Stronghold effects.
- Current default scenarios include Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.

Current telemetry has no enemy pressure plan fields. The right V1 expansion later is additive: plan id, triggered stage ids, first pressure time, warning count, reinforcement applied yes/no, and losses after pressure.

## Safe Reuse Points

Safe to reuse:

- Campaign node metadata for explicit pressure-plan attachment.
- Existing map ids, node ids, capture-site ids, unit ids, and building ids.
- AI personality ids and tags for plan eligibility and copy.
- Existing battle elapsed time and stats.
- Existing capture-site completion signals.
- Existing warning message/minimap surfaces.
- Existing enemy attack-wave callbacks.
- Existing simulator event log and telemetry writer.
- Existing content validation patterns.

These reuse points can produce a V1 that feels intentional without turning into real RTS base management.

## Dangerous Areas To Touch

Dangerous to touch in V1:

- Save schema or hero/campaign persistence.
- Campaign reward logic.
- Cinderfen reward or progression balance.
- Building placement and pathfinding.
- Unit definitions, faction data, and map geometry.
- Broad `BattleScene` lifecycle rewrites.
- Enemy worker, gather, build, or expansion systems.
- Ashen Outpost numeric balance unless telemetry shows a clear pressure-related bug.
- Existing tutorial launch and no-reward behavior.

The runtime hook should be small and should fail closed when no plan is attached.

## Pressure Plan Versus Real Construction

Safe pressure plan:

- Timed strategic intention attached by data to selected current battle nodes.
- Emits readable warning copy.
- Marks telemetry.
- Adjusts timing of an already supported wave or warning.
- Adds modest existing-unit pressure only through existing battle systems if safe.
- Sends existing units toward an existing capture site if supported.
- Can be disabled by data.

Forbidden real construction:

- Enemy workers or harvesters.
- Build placement.
- Dynamic enemy bases.
- New buildings as construction.
- New unit types.
- Economy simulation beyond existing fixed enemy resources and training.
- New maps, factions, campaign rewards, or save fields.

## Best Candidate Nodes For V1

Recommended V1 candidates:

1. `cinderfen_watch`
   - Best fit for "Ashen Watch Captain Pressure."
   - Strong capture-site read through Watch Road Toll.
   - Existing Watchtower and Barracks make defensive/road pressure legible.
   - No named rival commander, so pressure can become the commander flavor without overlapping rival rewards.

2. `cinderfen_crossing`
   - Best fit for "Causeway Contest."
   - Cinder Shrine already has strategic importance and first-capture salience.
   - A pressure warning can reinforce the route story.
   - Needs extra restraint because Fast Army can already clear quickly and Shrine salience is a known watch item.

Ashen Outpost should remain a reference node for now. It is already loaded with Captain Malrec, objective effects, rival telemetry, and balance risks.

## Recommended Implementation Scope

Recommended V1:

- Add a narrow data model and disabled-by-default-capable plan definitions.
- Attach at most two explicit plan ids to campaign battle nodes.
- Validate all pressure references against current content.
- Implement warning and telemetry first.
- Implement only one modest runtime effect if existing systems support it safely.
- Prefer wave timing or existing-unit contest pressure over invisible stat buffs.
- Exclude Tutorial / Proving Grounds.
- Exclude Skirmish unless explicitly configured later.
- Mirror the same pressure events in simulator telemetry.
- Add one targeted e2e check for a pressure-enabled battle and a tutorial no-pressure guard.

Recommended first runtime behavior if still safe after design:

- Cinderfen Watch: when the player captures Watch Road Toll, emit a warning and mark a pressure stage; optionally hasten the next existing enemy wave or queue a modest existing-unit reinforcement from the existing enemy Barracks.
- Cinderfen Crossing: when the player captures the Cinder Shrine, emit a warning and mark a pressure stage; optionally nudge the next existing enemy pressure toward the central route if that can be done without pathfinding/build placement work.

If reinforcement or route contesting requires broad scene rewrites, V1 should ship as warning plus telemetry only and document the limitation.

## Research Conclusion

The current codebase has enough enemy pacing, personality, warning, map, objective, validation, and simulator structure to support Enemy Strategic Pressure V1 as a small data-driven layer. The safest first version should make commander intent visible and measurable before increasing combat difficulty. Cinderfen Watch and Cinderfen Crossing are the right initial targets because they are current Chapter 2 battles, have clear strategic sites, use existing content, and avoid the extra rival complexity of Ashen Outpost.
