# Chapter 2 Implementation Spec - Cinderfen Event, Support, And Two Battle Slice

Status: event gate, compact support/town node, two compact playable battle nodes, compact aftermath event, compact Malrec trophy consequence, and one Cinderfen-specific tactical feature implemented.

Date: 2026-05-03

This document records the current compact Chapter 2 slice for Ascendant Realms. It intentionally stops at one playable preparation event node, one support/town node, two playable battle nodes, and one non-battle aftermath event using existing systems. It does not implement full Chapter 2.

## Scope Lock

Chapter title: **Chapter 2: Cinderfen Road**.

Playable event node: `cinderfen_overlook`.

Playable aftermath event node: `cinderfen_aftermath`.

Playable battle nodes: `cinderfen_crossing` and `cinderfen_watch`.

Playable support node: `cinderfen_waystation`.

Battle maps: **Cinderfen Causeway** with map id `cinderfen_causeway`, and **Cinderfen Watchpost** with map id `cinderfen_watchpost`.

Enemy content: existing Ashen Covenant units, existing Ashen structures, and existing `hexfire_cult` AI personality.

Event gate: `cinderfen_overlook` is a playable preparation event using the existing campaign choice system. It has three baseline choices plus one optional Malrec trophy choice when `trophy_malrec_outpost_standard` exists in the campaign save.

Tactical identity feature: the central `cinder_crossing` capture site is the **Cinder Shrine**. First capture by a side grants a one-time battle-local +20 Aether `Cinder Shrine Surge`; recaptures by the same team do not duplicate the surge.

Support node: `cinderfen_waystation` is a compact town/service node using existing campaign choice infrastructure. It unlocks after `cinderfen_overlook`, stays open, and offers Cinderfen-only preparation without adding a large shop or new system.

Second battle node: `cinderfen_watch` unlocks after `cinderfen_crossing` victory and launches the compact `cinderfen_watchpost` map. It reuses existing Ashen units, structures, objective types, reward rules, minimap/fog behavior, and simulator/e2e hooks.

Aftermath event: `cinderfen_aftermath` unlocks after `cinderfen_watch` victory, uses the existing event/choice system, completes after one once-only choice, and does not launch a battle.

Chapter 1 remains unchanged in flow: Border Marches still uses the existing Chapter 1 nodes, maps, rewards, and launch path. `cinderfen_overlook` unlocks only after `ashen_outpost`; `cinderfen_waystation` and `cinderfen_crossing` unlock only after `cinderfen_overlook` is completed; `cinderfen_watch` unlocks only after `cinderfen_crossing` is completed; `cinderfen_aftermath` unlocks only after `cinderfen_watch` is completed.

## Hard Non-Goals

- No workers.
- No enemy construction or rebuilding.
- No full new faction.
- No new enemy unit types.
- No diplomacy or alliance simulation.
- No procedural campaign.
- No procedural maps.
- No crafting, durability, affix rerolling, or broader loot complexity.
- No Chapter 1 retuning.
- No broad retinue management, wounded timers, or replacement UI.
- No new full rival system, Chapter 2 named rival, or rematch logic. The only returning-rival consequence is one existing-trophy-gated event choice.
- No additional Chapter 2 maps beyond the compact Cinderfen Causeway and Cinderfen Watchpost battle maps in this slice.

## Implemented Node Chain

| Order | Node id | Type | Current role |
| --- | --- | --- | --- |
| 1 | `cinderfen_overlook` | Event | Playable preparation gate. It unlocks after `ashen_outpost`, resolves one baseline or conditional choice, and then unlocks `cinderfen_waystation` and `cinderfen_crossing`. |
| 2 | `cinderfen_waystation` | Town | Optional support node. It unlocks after `cinderfen_overlook`, stays open, and sells modest Cinderfen-specific preparation services. |
| 3 | `cinderfen_crossing` | Battle | First playable Chapter 2 battle. It unlocks after `cinderfen_overlook` and launches `cinderfen_causeway`. |
| 4 | `cinderfen_watch` | Battle | Second compact Chapter 2 battle. It unlocks after `cinderfen_crossing` victory and launches `cinderfen_watchpost`. |
| 5 | `cinderfen_aftermath` | Event | Compact non-battle consequence node. It unlocks after `cinderfen_watch`, resolves one modest choice, and does not launch combat. |

Unlock rules:

- `cinderfen_overlook` unlocks after `ashen_outpost`.
- `cinderfen_waystation` unlocks after completed `cinderfen_overlook`.
- `cinderfen_crossing` unlocks after `ashen_outpost` and completed `cinderfen_overlook`.
- `cinderfen_watch` unlocks after completed `cinderfen_crossing`.
- `cinderfen_aftermath` unlocks after completed `cinderfen_watch`.
- No Chapter 2 node is available in a fresh Chapter 1 save.

## Cinderfen Overlook Event

Event id: `cinderfen_overlook`.

Display name: **Cinderfen Road**.

Event text: scouts find Ashen carts, refugee tracks, and old cinder-signs before the force commits to the Cinderfen Causeway.

Choices:

| Choice | Requirement | Cost | Reward | Reputation | Modifier | Completion |
| --- | --- | --- | --- | --- | --- | --- |
| Scout the Causeway | None | 30 Crowns | 20 XP, 8 Stone | +3 Free Marches, +1 Common Folk | Local Support | Completes node |
| Aid the Marsh Refugees | None | 55 Crowns | 25 XP, 10 Iron | +6 Common Folk, +2 Free Marches | Inspired Militia | Completes node |
| Study the Cinders | None | 24 Aether | 20 XP, Emberglass Wand | +5 Old Faith, -2 Ashen Covenant | Blessed Road | Completes node |
| Raise Malrec's Standard | `trophy_malrec_outpost_standard` | None | 10 XP | +3 Free Marches | Well Rested | Completes node |

Implementation notes:

- Choices are `onceOnly` and persist through `choiceIdsClaimed`.
- Completing any choice adds `cinderfen_overlook` to `completedNodeIds`, refreshes unlocks, and makes `cinderfen_crossing` available.
- The event uses only existing campaign resource, reputation, item reward, modifier, and Rival/Nemesis Persistence V1 trophy state.
- Raise Malrec's Standard is a compact returning-rival consequence: it checks `campaign.rivalTrophies`, grants an existing next-battle modifier, and does not create a new save field.
- Scout copy gives battle warning/intel through the choice description and Local Support modifier; Study the Cinders warns that no named Ashen rival commands the crossing yet.
- Duplicate rewards are prevented because a completed node and claimed once-only choice both block repeat application.

## Cinderfen Waystation Support Node

Node id: `cinderfen_waystation`.

Display name: **Cinderfen Waystation**.

Node type: `town`.

Unlock: completed `cinderfen_overlook`.

Purpose: a small frontier stop where the player spends campaign resources for Cinderfen-specific preparation. It reuses existing town-service choice cards, campaign costs, modifiers, reputation rewards, use counts, and save/load behavior.

Services:

| Service | Repeatability | Cost | Effect | Completion |
| --- | --- | --- | --- | --- |
| Marsh Guides | Repeatable | 35 Crowns | Grants `marsh_guides` for the next Cinderfen battle: +60 player-building vision and +20s enemy warning lead. | Keeps node open |
| Ash Filters | Repeatable | 35 Crowns, 15 Aether | Grants `ash_filters` for the next Cinderfen battle: +8% hero HP and Mana. | Keeps node open |
| Refugee Scouts | Once-only | 25 Crowns | Grants 10 XP and +2 Common Folk reputation; copy previews the Cinder Shrine and central guardians. | Keeps node open |
| Shrine Attunement | Repeatable | 12 Aether | Grants `shrine_attunement` for the next Cinderfen battle: Cinder Shrine Surge grants +5 extra Aether on first player capture. | Keeps node open |

Implementation notes:

- `next_cinderfen_battle` campaign modifiers are consumed only by battle nodes in `cinderfen_road`.
- The service node does not complete itself and does not gate Cinderfen Crossing.
- Repeatable services increment `townServiceUseCounts`; one-time Refugee Scouts also persists in `choiceIdsClaimed` and `townServiceClaimedIds`.
- Shrine Attunement modifies the existing Cinder Shrine first-capture bonus at battle runtime and in the simulator; it does not add campaign-bank rewards or save schema.
- Marsh Guides and Ash Filters use existing battle launch effect paths for vision/warning and hero HP/Mana.

## Cinderfen Causeway Map

Map id: `cinderfen_causeway`.

Display name: **Cinderfen Causeway**.

Size: `2600 x 1700`.

Theme: ash marsh, burned road, cinder pools, black reeds, ashglass outcrops.

Player start:

- Southwest road shelf around `(285, 1375)`.
- Safe but slightly constrained buildable area.
- Starts with a Command Hall, hero, three Militia, one Ranger, and a trimmed Chapter 2 starting bank of 480 Crowns, 325 Stone, 195 Iron, and 110 Aether.

Enemy start:

- Northeast causeway camp around `(2320, 315)`.
- Uses existing `enemy_stronghold`, `enemy_barracks`, one prebuilt `watchtower`, Raiders, Hexer, and generic `enemy_commander`.
- Starts with 250 Crowns, 195 Stone, 140 Iron, and 100 Aether, then trains from the existing enemy Barracks every 6.4 seconds.
- Uses `hexfire_cult` personality and no named rival.

Routes:

- Central burned causeway: main contested route from southwest to northeast.
- North reed shelf: safer Stone route for staged expansion.
- South iron embankment: riskier side path toward Iron.
- Cinder Shrine spur: central contested aether objective with a one-time first-capture surge.

Blocked and swamp terrain:

- Water zones mark cinder pools, ash marsh, black reeds, and eastern cinder water.
- Blocked zones mark ashglass outcrops, glass ribs, burned cairns, a waystone ruin, and a sunken cart.
- Terrain is authored for pathfinding readability without adding new terrain systems.

Capture sites:

| Site id | Name | Resource | Role |
| --- | --- | --- | --- |
| `causeway_toll` | Causeway Toll | 30 Crowns / 5s | First readable income objective. |
| `reedcut_quarry` | Reedcut Quarry | 22 Stone / 6s | Safer northern expansion. |
| `sunken_iron_cache` | Sunken Iron Cache | 18 Iron / 6s | Riskier southern staging site. |
| `cinder_crossing` | Cinder Shrine | 16 Aether / 6s plus one-time +20 Aether first-capture surge | Central contested route objective and Cinderfen's compact tactical identity feature. |

Neutral camps:

| Camp id | Name | Units | Role |
| --- | --- | --- | --- |
| `reedcut_raiders` | Reedcut Raiders | 2 Raiders | Light northern side-route camp. |
| `sunken_hexfire_pickets` | Sunken Hexfire Pickets | Raider, Hexer | Southern route pressure. |
| `cinder_guardians` | Cinder Guardians | Hexer, Brute, Raider | Central contested camp for the secondary objective. |

## Cinderfen Watchpost Map

Map id: `cinderfen_watchpost`.

Display name: **Cinderfen Watchpost**.

Size: `2400 x 1550`.

Theme: an Ashen watchpost controlling a raised road through the cinder marsh.

Player start:

- Southwest road shelf around `(285, 1285)`.
- Starts with a Command Hall, hero, three Militia, one Ranger, and 500 Crowns, 335 Stone, 205 Iron, and 115 Aether.
- The opening is a little better supplied than Cinderfen Crossing because this is the second Chapter 2 battle, but the route has no Cinder Shrine surge.

Enemy start:

- Northeast watchpost camp around `(2145, 285)`.
- Uses existing `enemy_stronghold`, `enemy_barracks`, one central `watchtower`, Raiders, Hexer, and generic `enemy_commander`.
- Starts with 280 Crowns, 210 Stone, 155 Iron, and 110 Aether.
- Uses `hexfire_cult` personality and no named rival.
- Current watchpost pacing uses 80 / 40 / 36 / 30 income per tick, 6.4s training, 195s first attack delay, 74s attack interval, 6-unit attack wave target, and 4-unit defense squad. This keeps the node harder than Cinderfen Crossing in aggregate but below Ashen Outpost.

Routes:

- Raised watch road: main southwest-to-northeast route and safest first capture.
- Blackreed stone path: side Stone route before the central push.
- Ash cistern spur: exposed Aether route near the watchtower.

Capture sites:

| Site id | Name | Resource | Role |
| --- | --- | --- | --- |
| `watch_road_toll` | Watch Road Toll | 28 Crowns / 5s | Primary road economy objective and secondary capture target. |
| `blackreed_stonecut` | Blackreed Stonecut | 20 Stone / 6s | Safer staging income before the watchtower. |
| `ash_cistern` | Ash Cistern | 14 Aether / 6s | Exposed Aether income near the central route. |

Neutral camps:

| Camp id | Name | Units | Role |
| --- | --- | --- | --- |
| `marsh_raider_camp` | Marsh Raider Camp | Raider, Brute | Lower-road camp and secondary objective anchor. |
| `watch_road_pickets` | Watch Road Pickets | Raider, Hexer | Central road pressure near the watchtower approach. |

## Objectives

`cinderfen_crossing` primary:

- Destroy the enemy stronghold.

`cinderfen_crossing` secondaries:

- Claim the Cinder Shrine.
- Clear the Cinder Guardians by defeating the Brute anchor.
- Destroy the Enemy Barracks.

The Cinder Shrine objective uses the existing capture-site flow plus the optional `firstCaptureBonus` capture-site data field. The +20 Aether surge is battle-local, applies once per team per battle, and does not add save schema or campaign rewards. The neutral-camp objective uses the existing `defeat_unit` objective type. Validation now allows a `defeat_unit` target to be present in either scenario unit spawns or neutral camp unit lists. Defeat tips now point failed Cinderfen runs toward side income, the Cinder Shrine, the Cinder Guardians, and Enemy Barracks sequencing.

`cinderfen_watch` primary:

- Destroy the Ashen Watchpost Stronghold.

`cinderfen_watch` secondaries:

- Capture the Watch Road.
- Clear the Marsh Raider Camp by defeating the Brute anchor.
- Destroy the Watchpost Tower.

Watchpost defeat tips point players toward the Watch Road Toll, the Marsh Raider Camp/Brute, and destroying the Watchpost Tower before the final Stronghold assault.

## Cinderfen Aftermath Event

Node id: `cinderfen_aftermath`.

Display name: **Cinderfen Aftermath**.

Node type: `event`.

Unlock: completed `cinderfen_watch`.

Purpose: a compact consequence node where the player decides what to do with the captured Cinderfen watch route. It reuses the existing event choice system and does not launch a battle.

Choices:

| Choice | Cost | Reward | Reputation | Modifier | Completion |
| --- | --- | --- | --- | --- | --- |
| Secure the Watch Road | 45 Crowns, 18 Stone | 12 XP, 10 Stone | +4 Free Marches | Local Support | Completes node |
| Aid the Fenfolk | 40 Crowns | 12 XP, 8 Iron | +5 Common Folk | None | Completes node |
| Study the Ashen Marks | 18 Aether | 12 XP, 6 Aether, Pilgrim Crook | +4 Old Faith, -1 Ashen Covenant | None | Completes node |
| Display Malrec's Standard | Requires `trophy_malrec_outpost_standard` | None | +1 Free Marches | None | Completes node |

Implementation notes:

- All choices are `onceOnly` and persist through `choiceIdsClaimed`.
- Completing any choice adds `cinderfen_aftermath` to `completedNodeIds`.
- Rewards are intentionally modest and do not add a new loot system.
- Secure the Watch Road uses the existing Local Support modifier instead of adding a new next-Cinderfen-battle modifier, because the current slice has no future Cinderfen battle after Watchpost.
- The node is event-only and excluded from battle simulator profiles.

## Rewards

Campaign node reward for `cinderfen_crossing`:

- 60 XP.
- 40 Crowns, 20 Stone, 20 Iron, 12 Aether.
- `Scout's Bow`.

Battle reward table: `cinderfen_causeway_rewards`.

- One affix-capable weighted item roll from existing catalog items.
- Base victory reward: 30 XP plus 16 Crowns, 10 Stone, 8 Iron, 6 Aether.
- First-clear bonus: 35 XP plus 14 Crowns, 10 Stone, 8 Iron, 6 Aether.
- Repeat-clear reward: 4 XP plus 6 Crowns, 3 Iron, 2 Aether.

This is deliberately below the Ashen Outpost milestone reward level.

Campaign node reward for `cinderfen_watch`:

- 68 XP.
- 45 Crowns, 25 Stone, 20 Iron, 12 Aether.

Battle reward table: `cinderfen_watchpost_rewards`.

- One affix-capable weighted item roll from existing catalog items.
- Base victory reward: 32 XP plus 18 Crowns, 10 Stone, 8 Iron, 5 Aether.
- First-clear bonus: 34 XP plus 16 Crowns, 10 Stone, 8 Iron, 5 Aether.
- Repeat-clear reward: 3 XP plus 5 Crowns, 2 Iron, 1 Aether.

The full first-clear Watchpost read is 128 XP, 170 total campaign/battle resources, and one existing weighted item roll. It is useful but not trophy-level, and it does not add a named rival reward.

## Chapter 2 Balance Pass

The 2026-05-03 telemetry pass kept the Cinderfen battles structurally reasonable while trimming farm pressure.

- The current simulator suite covers 255 deterministic runs across 85 campaign battle node/profile summaries.
- Cinderfen Crossing remains structurally reasonable at 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch is structurally reasonable at 25 wins / 0 defeats / 11 timeouts, making it slightly harder than Crossing and slightly easier than Ashen Outpost's 22 wins / 0 defeats / 14 timeouts.
- Safe Beginner stayed 12 wins / 0 defeats / 0 timeouts with fair first contact around 4:16.
- Cinderfen Watch first contact averages about 3:57; Barracks timing and first-wave survival stay fair in the simulator, but the earlier pressure is a human-play readability watchpoint.
- Greedy Economy stays mostly timeout-prone, preserving the staging lesson.
- Fast Army stays the main rush/readability watchpoint, so first-clear XP/resources stay modest instead of adding new systems or units.
- Retinue + Training Yard II remains the strongest Chapter 2 profile at 6 wins / 0 defeats / 0 timeouts across the two Cinderfen battles and stays a human-review watchpoint.
- No Cinderfen battle runs applied rival modifiers because this slice has no named Chapter 2 rival. The Malrec trophy choice is a campaign-event consequence and is covered by unit/e2e save flow rather than the baseline simulator.
- The later Cinder Shrine addition now grants only +20 battle Aether on first capture after the post-feature telemetry pass trimmed it from +24. It is simulator-modeled as tactical tempo, not a campaign reward, and should be watched mainly for route readability rather than long-term economy snowball.
- Chapter 1 values were not changed.

## UI Requirements

Campaign Map must show:

- `Chapter 2: Cinderfen Road`.
- `Cinderfen Road` / `cinderfen_overlook` as an available event when `ashen_outpost` is complete.
- Three baseline event choices with costs, rewards, reputation changes, completion outcome, and granted modifiers.
- The conditional Raise Malrec's Standard choice, including its trophy requirement when absent and its XP, reputation, Well Rested modifier, and completion outcome when present.
- `Cinderfen Waystation` as locked until `cinderfen_overlook` is completed and available afterward.
- Four Waystation services with costs, one-time/repeatable state, granted modifiers or reputation, and "keeps this node open" outcome copy.
- `Cinderfen Crossing` as locked until `cinderfen_overlook` is completed.
- `Cinderfen Crossing` as playable after the event choice is made.
- Map name `Cinderfen Causeway`.
- Difficulty `Normal`.
- Enemy style `Hexfire Cult`.
- Reward preview including XP, campaign resources, and `Scout's Bow`.
- Battle HUD objective copy for `Claim the Cinder Shrine`, including `Cinder Shrine Surge (+20 Aether once)`.
- Battle status/floating copy when the shrine surge is granted, plus a minimap ping labeled `Cinder Shrine Surge`.
- `Cinderfen Watch` as locked until `cinderfen_crossing` is completed.
- `Cinderfen Watch` as playable after Cinderfen Crossing victory.
- Map name `Cinderfen Watchpost`.
- Watchpost objective copy for destroying the Ashen Watchpost Stronghold, capturing the Watch Road, clearing the Marsh Raider Camp, and destroying the Watchpost Tower.
- Watchpost reward preview with modest XP/resources and no trophy-level reward.

Existing campaign node panel code already supports this through node/map/reward/choice data. Tests assert the Chapter 2 card, event choice summaries, and Cinderfen node preview.

## Validation And Tests

Content validation covers:

- Map index references.
- Campaign node map, faction, AI personality, prerequisite, unlock, and reward references.
- Event choice item, resource, reputation, and modifier references.
- Event choice rival trophy requirements.
- Reward table item/resource/map references.
- Objective target references.
- Capture site definitions.
- Capture-site first-capture bonus resource references.
- Neutral camp unit references.
- Enemy building/unit references.

E2E coverage:

- Seeds a post-Ashen save.
- Verifies `cinderfen_overlook` becomes playable while `cinderfen_crossing` remains locked.
- Makes one Cinderfen Overlook choice.
- Verifies cost payment, reward grant, reputation changes, modifier persistence, duplicate prevention, and node completion in localStorage.
- Opens Cinderfen Waystation after the event, buys Shrine Attunement, verifies Aether cost, active modifier persistence, town service use count, and open node state.
- Verifies `cinderfen_crossing` becomes playable after the event.
- Launches `Cinderfen Causeway`.
- Verifies BattleScene loads with map name, objective text, resources, Cinder Shrine first-capture bonus data, and minimap markers.
- Uses a safe test hook to capture the Cinder Shrine, verifies the attuned +25 Aether surge, verifies the status/HUD copy, and verifies repeating the hook does not duplicate the bonus.
- Verifies the chosen next-battle modifier reaches launch and is consumed from the campaign save.
- Seeds Malrec's trophy state, verifies the conditional Raise Malrec's Standard choice appears and is available, applies it once, and verifies reward/modifier/reputation persistence.
- Seeds post-Crossing Chapter 2 progress.
- Verifies `cinderfen_watch` unlocks only after `cinderfen_crossing`.
- Launches `Cinderfen Watchpost`.
- Verifies BattleScene loads with map name, objective text, resources, minimap markers, difficulty, and any relevant Waystation launch effect.
- Uses safe hooks to capture the Watch Road Toll, clear the Marsh Raider Camp, destroy the Watchpost Tower, destroy the enemy Stronghold, and complete victory.
- Verifies Results map/node copy, XP/resources/item reward, objective summary, return-to-campaign flow, campaign completion, and no duplicate reward on revisit.

Simulator coverage:

- Includes `cinderfen_crossing` and `cinderfen_watch` as Chapter 2 scripted scenarios.
- Keeps three scripts per scenario: Safe Beginner, Greedy Economy, and Fast Army.
- Reports Chapter 2 separately in the Markdown table.
- Models `firstCaptureBonus` on captured sites, so the Greedy Economy Cinderfen script records `Cinder Shrine Surge: 20 Aether` when it reaches the shrine.
- Adds one `Waystation: Shrine Attunement` profile that applies only to Cinderfen battles that contain the `cinder_crossing` shrine site; it records `Cinder Shrine Surge: 25 Aether` on Cinderfen Crossing and intentionally does not spend the modifier on Cinderfen Watchpost.
- Cinderfen event-choice launch modifiers, including the Malrec trophy Well Rested path, remain covered by unit/e2e save flow rather than the baseline simulator.
- Preserves the no structural `too_hard` and no structural `too_easy` gates.

Regression gates:

- `npm test`: PASS after the Cinderfen Aftermath pass with 37 test files and 258 tests.
- `npm run build`: PASS, known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: PASS, 52 Playwright tests in 20.9m on the clean full rerun, including Aftermath unlock, choice, reward, reputation, completion, and duplicate-prevention coverage.
- `npm run playtest:sim`: PASS, 255 deterministic battle runs across 85 campaign battle node/profile summaries. Cinderfen Aftermath is event-only and does not add a battle simulator profile.

## Deferred Chapter 2 Work

- Add any further returning-rival consequence only if it stays at this scale, reuses existing rival state, and keeps duplicate first-defeat rewards blocked.
- Add any later Chapter 2 town/service node or battle only after the current two-battle slice remains green.
- Do not add workers, enemy construction, full new factions, diplomacy, procedural generation, crafting, or another Chapter 2 map as part of this slice.

## Acceptance Criteria

- `cinderfen_overlook` is a playable event node with three clear baseline choices and one clear optional Malrec trophy choice.
- `cinderfen_waystation` is a playable town/support node with clear services, costs, effects, and persistence.
- At least three Waystation services exist; Marsh Guides, Ash Filters, and Shrine Attunement apply real effects through existing launch/modifier paths.
- Choice costs, rewards, reputation changes, completion behavior, and modifiers are visible on the Campaign Map.
- Event choice rewards do not duplicate after save/load.
- `cinderfen_causeway` exists and is registered.
- `cinderfen_crossing` launches the new map.
- `cinderfen_crossing` requires `cinderfen_overlook`.
- `cinderfen_watchpost` exists and is registered.
- `cinderfen_watch` launches Cinderfen Watchpost.
- `cinderfen_watch` requires `cinderfen_crossing`.
- Chapter 1 flow still works.
- No missing-map launch path remains.
- Existing Ashen units and existing AI personality drive the enemy setup.
- Objectives, rewards, capture sites, neutral camps, and enemy references validate.
- Cinder Shrine gives Chapter 2 one distinct tactical identity without adding a new faction, map, unit, worker loop, enemy construction, diplomacy, procedural generation, or crafting.
- Cinder Shrine Surge is readable in objective/status copy, grants its +20 Aether once, and does not duplicate on recapture.
- Cinderfen Watch uses existing systems only, has three capture sites, two neutral camps, one central watchpost/tower objective, fog/minimap readability, and modest rewards.
- Unit tests, build, e2e, and playtest simulator pass.
