# Chapter 2 Vertical Slice Report

Date: 2026-05-03

Scope: current Chapter 2 vertical slice for Ascendant Realms after the Cinderfen event gate, first playable battle, compact returning-rival consequence, telemetry balance pass, and Cinder Shrine tactical feature.

This report summarizes the current slice. The slice still does not add maps, factions, units, workers, enemy construction, diplomacy, procedural generation, or crafting.

Primary sources:

- `LLM_GAME_HANDOFF.md`
- `docs/CHAPTER_2_IMPLEMENTATION_SPEC.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `QA_RUN.md`
- Current campaign and map data for Chapter 2 nodes and Cinderfen Causeway.

## Executive Summary

Chapter 2 is currently a compact vertical slice, not a full chapter. It contains one playable preparation event, `cinderfen_overlook`, and one playable battle, `cinderfen_crossing`, on the authored `cinderfen_causeway` map. The slice uses existing Ashen Covenant units, existing Ashen structures, the existing `hexfire_cult` AI personality, and the existing campaign event/choice, reward, reputation, modifier, save, launch, objective, fog, minimap, capture-site, and results systems.

The current Cinderfen-specific identity feature is the Cinder Shrine: the central Aether capture site releases a one-time +20 Aether battle-local surge on first capture, then behaves like a normal Aether site. The latest telemetry read marks Cinderfen Crossing as structurally reasonable: no `too_easy` flag, no `too_hard` flag, Safe Beginner wins cleanly, Greedy Economy mostly times out, and Fast Army exposes a rush/readability edge without making every profile a sweep. Chapter 1 telemetry remains stable because the Cinderfen changes are isolated to Chapter 2 data and Cinderfen-specific copy/rules.

## 1. Current Chapter 2 Content

Chapter metadata:

- Chapter id: `cinderfen_road`
- Display title: `Chapter 2: Cinderfen Road`
- Short description: the first playable road beyond Ashen Outpost, focused on one ash-glass wetland event gate and one causeway battle.
- Unlock prerequisite: `ashen_outpost`
- Node list: `cinderfen_overlook`, `cinderfen_crossing`

Playable nodes:

| Node id | Display name | Type | Status | Unlock rule |
| --- | --- | --- | --- | --- |
| `cinderfen_overlook` | Cinderfen Road | Event | Playable after Ashen Outpost | Requires `ashen_outpost` |
| `cinderfen_crossing` | Cinderfen Crossing | Battle | Playable after the event | Requires `ashen_outpost` and completed `cinderfen_overlook` |

Event node:

- `cinderfen_overlook` is a one-of-three preparation gate.
- The event text frames the army at the last dry rise before forcing the Cinderfen Causeway.
- Any choice completes the node, records the chosen once-only choice, persists rewards, and unlocks `cinderfen_crossing`.

Locked and upcoming nodes:

- `cinderfen_crossing` is locked until `cinderfen_overlook` is completed.
- No additional Chapter 2 nodes are currently authored in campaign data.
- Later Chapter 2 work is deferred; the current slice intentionally stops at one event and one battle.

Battle map:

- Map id: `cinderfen_causeway`
- Display name: `Cinderfen Causeway`
- Role: Chapter 2 ash-marsh crossing
- Size: `2600 x 1700`
- Theme: burned road, ash marsh, cinder pools, black reeds, ashglass outcrops.
- Player starts southwest with Command Hall, hero, three Militia, one Ranger, and 480 Crowns / 325 Stone / 195 Iron / 110 Aether.
- Enemy starts northeast with existing Ashen structures, existing Ashen units, one prebuilt Watchtower, and no named rival.

Current map objective structure:

- Primary: destroy the enemy Stronghold.
- Secondary: claim the Cinder Shrine.
- Secondary: clear the central Cinder Guardians camp by defeating the Brute anchor.
- Secondary: destroy the Enemy Barracks.

Capture sites:

| Site id | Display name | Income | Role |
| --- | --- | --- | --- |
| `causeway_toll` | Causeway Toll | 30 Crowns / 5s | First readable income objective |
| `reedcut_quarry` | Reedcut Quarry | 22 Stone / 6s | Safer northern staging route |
| `sunken_iron_cache` | Sunken Iron Cache | 18 Iron / 6s | Riskier southern side path |
| `cinder_crossing` | Cinder Shrine | 16 Aether / 6s plus one-time +20 Aether first-capture surge | Central contested aether objective and Chapter 2 tactical identity hook |

Neutral camps:

| Camp id | Display name | Units | Role |
| --- | --- | --- | --- |
| `reedcut_raiders` | Reedcut Raiders | 2 Raiders | Light northern side-route camp |
| `sunken_hexfire_pickets` | Sunken Hexfire Pickets | Raider, Hexer | Southern route pressure |
| `cinder_guardians` | Cinder Guardians | Hexer, Brute, Raider | Central objective camp |

## 2. Chapter 2 Battle Readability

Map name:

- The BattleScene launch path and e2e coverage verify that `Cinderfen Causeway` appears when `cinderfen_crossing` launches.

Objectives:

- The objective structure is understandable and staged: win by destroying the enemy Stronghold, then optional objectives point toward the Cinder Shrine, the central neutral camp, and enemy production.
- The current objective copy avoids implying that the player should rush the center immediately. It tells the player to claim the Cinder Shrine for `Cinder Shrine Surge (+20 Aether once)` only after securing enough troops, then break the Ashen staging camp before committing to the Stronghold.

Minimap markers:

- Existing e2e coverage verifies Cinderfen launch with minimap markers.
- Broader minimap marker and ping coverage already exists for the RTS HUD and remains the main regression guard for marker families.

Fog behavior:

- Cinderfen runs on Normal, so fog is active under the current difficulty defaults.
- The map uses existing fog behavior: sites and camps are hidden until explored, then known/readable after discovery.
- No Cinderfen-specific fog system was added.

Capture-site readability:

- The four sites have distinct names, resource identities, and route roles.
- Causeway Toll and Reedcut Quarry are the clearest early staging options.
- Cinder Shrine is valuable but intentionally framed as contested so the +20 Aether surge reads as a tactical tempo prize, not a first safe click or repeatable farm.

Defeat tips:

- Cinderfen-specific result tips now point failed runs toward side income, Cinder Guardians, and Enemy Barracks sequencing.
- This is useful because it teaches the route order without changing combat logic.

## 3. Chapter 2 Event Readability

Choices:

| Choice | Cost | Reward | Reputation | Modifier | Completes node |
| --- | --- | --- | --- | --- | --- |
| Scout the Causeway | 30 Crowns | 20 XP, 8 Stone | +3 Free Marches, +1 Common Folk | Local Support | Yes |
| Aid the Marsh Refugees | 55 Crowns | 25 XP, 10 Iron | +6 Common Folk, +2 Free Marches | Inspired Militia | Yes |
| Study the Cinders | 24 Aether | 20 XP, Emberglass Wand | +5 Old Faith, -2 Ashen Covenant | Blessed Road | Yes |

Readability assessment:

- The three choices have distinct identities: intel/preparation, humanitarian support and a volunteer-style battle boost, or Old Faith/aether study with an item and blessing.
- Costs and rewards are visible through the existing campaign choice UI.
- Reputation changes and granted modifiers are visible through the existing campaign choice summaries.
- Each choice clearly completes the event and unlocks the battle.

Duplicate reward prevention:

- Choices are `onceOnly`.
- Claimed choice ids persist through `choiceIdsClaimed`.
- Completing any Cinderfen Overlook choice completes `cinderfen_overlook`, which prevents alternate Cinderfen choices from paying out afterward.
- Unit and e2e coverage verify cost payment, reward grant, reputation change, modifier persistence, duplicate prevention, and save/load state.

## 4. Telemetry

Latest simulator scope:

- 216 deterministic runs.
- 72 campaign battle node/profile summaries.
- Includes `cinderfen_crossing` as the first Chapter 2 battle scenario.
- Simulator Cinderfen runs now model capture-site `firstCaptureBonus`, so scripts that reach the Cinder Shrine receive the same one-time +20 Aether surge as live battle. Event-choice launch modifiers are still covered by unit/e2e and are noted as future simulator profile work.

Cinderfen Crossing overall:

| Runs | Wins | Defeats | Timeouts | Verdict |
| ---: | ---: | ---: | ---: | --- |
| 36 | 24 | 0 | 12 | Reasonable |

Script read:

| Script | Runs | Wins | Defeats | Timeouts | First contact read |
| --- | ---: | ---: | ---: | ---: | --- |
| Safe Beginner | 12 | 12 | 0 | 0 | Around 4:16 |
| Greedy Economy | 12 | 1 | 0 | 11 | Around 4:15 |
| Fast Army | 12 | 11 | 0 | 1 | Often wins before first-wave pressure matters; contact when present remains around 4:15 |

First enemy contact timing:

- Safe and Greedy paths show fair first contact at roughly 4:15-4:16.
- Barracks is completed before pressure in the pressure-facing Cinderfen scripts.
- Fast Army is still the rush/readability watchpoint because many fast wins occur before first-wave pressure meaningfully tests the player.

Barracks, Mystic, and Watchtower usefulness:

- Barracks remains useful in Cinderfen pressure scripts and is completed before pressure for Safe Beginner and Greedy Economy.
- Mystic Lodge appears in 24 of 36 Cinderfen simulator runs, mostly in non-rush scripts.
- Watchtower appears in 14 of 36 Cinderfen simulator runs, mostly as a Safe Beginner defensive/readability tool.
- No new building system or Cinderfen-only structure behavior was added.

Retinue impact:

- Retinue impact is visible but not automatically structural.
- Veteran Militia and mixed retinue speed up Cinderfen.
- Veteran Ranger can slow Fast Army into a timeout.
- Retinue + Training Yard II is the strongest profile at 3 wins / 0 defeats / 0 timeouts and remains a human-review watchpoint rather than an automated `too_easy` flag.

Stronghold impact:

- Tier II Quartermaster does not create an automated warning on Cinderfen.
- Retinue + Quartermaster II sits at 2 wins / 0 defeats / 1 timeout on Cinderfen.
- The strongest Cinderfen profile is still Retinue + Training Yard II, not Quartermaster II alone.
- Stronghold warnings remain `none` in the simulator summary.

Rival impact:

- Cinderfen Crossing currently has no named Chapter 2 rival.
- 0 Cinderfen runs include an enemy hero.
- 0 Cinderfen runs apply rival persistence modifiers.
- The event copy explicitly warns that no named Ashen rival commands the crossing yet.
- The compact returning-rival consequence is event-only: if Malrec's trophy standard exists, the Cinderfen Overlook event offers one non-stacking Well Rested morale choice. It does not add a Chapter 2 rival, alter battle AI, or appear in baseline battle-simulator modifier counts.

Reward strength:

- Normal first-clear Cinderfen reward read: 125 XP, 170 campaign/battle resources, one weighted item roll, and `Scout's Bow`.
- This is useful but intentionally below the Ashen Outpost milestone and below the larger Chapter 1 branch spikes.
- Repeat-clear rewards were trimmed to reduce resource-farm pressure.
- The Cinder Shrine's +20 Aether surge is not a Results reward or campaign-bank payout. It is battle-only tempo, grants once per team per battle, and is covered by unit/e2e/simulator duplicate-prevention checks.
- The post-feature balance pass changed only the shrine surge, from +24 to +20 Aether. Enemy pacing, wave size, AI economy, starting resources, event costs/rewards, battle rewards, and the Malrec trophy consequence stayed unchanged because the latest telemetry did not show a structural cliff or a reward-farm warning.

Warnings:

- Structural `too_easy`: none.
- Structural `too_hard`: none.
- Human-review watchpoints: Retinue + Training Yard II on Cinderfen, Veteran Ranger on Cinderfen, and the broader existing human-review list for several Chapter 1 Normal nodes.

## 5. Regression Status

Chapter 1 stability:

- Chapter 1 telemetry records remain stable in the latest suite.
- Current Chapter 1 records:
  - Border Village: 36 wins / 0 defeats / 0 timeouts.
  - Old Stone Road: 36 wins / 0 defeats / 0 timeouts.
  - Aether Well Ruins: 12 wins / 12 defeats / 12 timeouts.
  - Bandit Hillfort: 12 wins / 23 defeats / 1 timeout.
  - Ashen Outpost: 22 wins / 0 defeats / 14 timeouts.
- The Chapter 2 balance pass and Cinder Shrine feature did not change Chapter 1 values.

Existing campaign flow:

- Existing Chapter 1 nodes, maps, rewards, rival commanders, campaign choices, town services, Stronghold upgrades, retinue, item rewards, and save paths remain the baseline.
- `cinderfen_overlook` unlocks only after `ashen_outpost`.
- `cinderfen_crossing` unlocks only after `cinderfen_overlook` is completed.

Simulator status:

- Latest recorded simulator result: PASS.
- 216 deterministic runs across 72 campaign battle node/profile summaries.
- No structural `too_easy` nodes.
- No structural `too_hard` nodes.
- No Stronghold warnings.
- Ashen Outpost remains beatable.

E2E status:

- Latest recorded full e2e result: PASS, 51 Playwright tests in 18.5 minutes.
- Coverage includes Cinderfen Overlook choice flow, Malrec trophy consequence coverage, Cinderfen Crossing launch/victory, and Cinder Shrine first-capture coverage.
- The Cinderfen e2e path seeds a post-Ashen save, verifies the event is available while the battle is locked, makes one choice, verifies reward/reputation/modifier/save state, then verifies Cinderfen Crossing becomes playable, launches the map, captures the Cinder Shrine, confirms +20 Aether, confirms no duplicate shrine surge, wins the battle, and verifies campaign persistence.

Current report-pass verification:

- Latest required verification: `npm test` passed 37 files / 233 tests, `npm run build` passed with the known large-chunk warning, `npm run test:e2e -- --reporter=line` passed 51 tests in 21.9 minutes on the clean full rerun, and `npm run playtest:sim` passed 216 deterministic runs.

## 6. Risks

Balance risks:

- Fast Army can still win Cinderfen quickly, so reward farming remains the main balance watchpoint even after reward trimming; the Cinder Shrine surge should stay small and battle-local.
- Retinue + Training Yard II sweeps Cinderfen and needs human-paced review before adding more player power to Chapter 2.
- Greedy Economy mostly timing out is currently acceptable because it reinforces staging, but it could feel too slow if future Cinderfen content adds more required pre-battle spending.

Map readability risks:

- The central Cinder Shrine is valuable and visually important; players may still over-prioritize it if they ignore the safer northern route.
- The Cinder Guardians camp uses existing neutral camp behavior, so the Brute anchor objective must remain clear in UI and result copy.
- Fog readability should get a human visual pass because automated checks verify state, not subjective map-reading comfort.

UI risks:

- Event choice rows are information-dense: cost, reward, reputation, modifier, and completion state all need to remain scannable.
- Chapter cards now have Chapter 1 and Chapter 2 state; future node additions could overcrowd the campaign map if not paced carefully.
- The e2e suite covers launch, Cinder Shrine HUD/status copy, the one-time surge, and saved campaign state, but a human pass should still inspect how the Cinderfen event choice panel and shrine objective read at normal UI scale.

Future expansion risks:

- Adding a named returning rival, a new faction, enemy construction, or broad new economy systems too early would make it harder to isolate whether Cinderfen itself is balanced.
- Adding several Cinderfen nodes at once would blur the current signal from this clean event-plus-battle slice.
- New reward sinks should come before any major reward increases.

## 7. Next Recommended Work

Recommended next steps should stay small and data-driven:

1. Add future simulator coverage for Cinderfen event-choice launch modifiers so Local Support, Inspired Militia, Blessed Road, and Well Rested have explicit Chapter 2 profile reads.
2. Run a human-paced Cinderfen visual/readability pass focused on the northern route, Cinder Shrine temptation, neutral camp clarity, fog, and objective panel readability.
3. Keep the Cinder Shrine surge at small battle-local tempo unless telemetry or human play shows it is too weak to notice.
4. Keep big systems out for now: no workers, no enemy construction, no new faction mechanics, no procedural generation, no crafting, and no broad army-management expansion.

## Final Status

The Chapter 2 vertical slice is coherent and playable as a minimal continuation after Chapter 1. It has one readable event gate, one readable first battle, stable automated coverage, useful but trimmed rewards, and clear boundaries for what is intentionally not implemented yet.
