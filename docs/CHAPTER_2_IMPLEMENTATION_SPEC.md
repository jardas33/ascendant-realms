# Chapter 2 Implementation Spec - Event Gate And First Playable Battle Slice

Status: event gate, first playable battle slice, compact Malrec trophy consequence, and one Cinderfen-specific tactical feature implemented.

Date: 2026-05-03

This document records the smallest implemented Chapter 2 slice for Ascendant Realms. It intentionally stops at one playable event node, one playable battle node, and one authored map that already existed in the Chapter 2 battle slice. It does not implement full Chapter 2.

## Scope Lock

Chapter title: **Chapter 2: Cinderfen Road**.

Playable event node: `cinderfen_overlook`.

Playable battle node: `cinderfen_crossing`.

Battle map: **Cinderfen Causeway** with map id `cinderfen_causeway`.

Enemy content: existing Ashen Covenant units, existing Ashen structures, and existing `hexfire_cult` AI personality.

Event gate: `cinderfen_overlook` is a playable preparation event using the existing campaign choice system. It has three baseline choices plus one optional Malrec trophy choice when `trophy_malrec_outpost_standard` exists in the campaign save.

Tactical identity feature: the central `cinder_crossing` capture site is the **Cinder Shrine**. First capture by a side grants a one-time battle-local +20 Aether `Cinder Shrine Surge`; recaptures by the same team do not duplicate the surge.

Chapter 1 remains unchanged in flow: Border Marches still uses the existing Chapter 1 nodes, maps, rewards, and launch path. `cinderfen_overlook` unlocks only after `ashen_outpost`; `cinderfen_crossing` unlocks only after `cinderfen_overlook` is completed.

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
- No additional Chapter 2 maps.

## Implemented Node Chain

| Order | Node id | Type | Current role |
| --- | --- | --- | --- |
| 1 | `cinderfen_overlook` | Event | Playable preparation gate. It unlocks after `ashen_outpost`, resolves one of three choices, and then unlocks `cinderfen_crossing`. |
| 2 | `cinderfen_crossing` | Battle | First playable Chapter 2 battle. It unlocks after `cinderfen_overlook` and launches `cinderfen_causeway`. |

Unlock rules:

- `cinderfen_overlook` unlocks after `ashen_outpost`.
- `cinderfen_crossing` unlocks after `ashen_outpost` and completed `cinderfen_overlook`.
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

## Objectives

Primary:

- Destroy the enemy stronghold.

Secondaries:

- Claim the Cinder Shrine.
- Clear the Cinder Guardians by defeating the Brute anchor.
- Destroy the Enemy Barracks.

The Cinder Shrine objective uses the existing capture-site flow plus the optional `firstCaptureBonus` capture-site data field. The +20 Aether surge is battle-local, applies once per team per battle, and does not add save schema or campaign rewards. The neutral-camp objective uses the existing `defeat_unit` objective type. Validation now allows a `defeat_unit` target to be present in either scenario unit spawns or neutral camp unit lists. Defeat tips now point failed Cinderfen runs toward side income, the Cinder Shrine, the Cinder Guardians, and Enemy Barracks sequencing.

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

## Chapter 2 Balance Pass

The 2026-05-03 telemetry pass kept the map structurally reasonable while trimming farm pressure.

- Cinderfen Crossing remained 24 wins / 0 defeats / 12 timeouts across the 216-run suite.
- Safe Beginner stayed 12 wins / 0 defeats / 0 timeouts with fair first contact around 4:16.
- Greedy Economy stayed mostly timeout-prone, preserving the staging lesson.
- Fast Army stayed the main rush/readability watchpoint, so first-clear XP/resources and event payouts were reduced instead of adding new systems or units.
- Retinue + Training Yard II remained the strongest profile at 3 wins / 0 defeats / 0 timeouts and stays a human-review watchpoint.
- No Cinderfen battle runs applied rival modifiers because this slice has no named Chapter 2 rival. The Malrec trophy choice is a campaign-event consequence and is covered by unit/e2e save flow rather than the baseline simulator.
- The later Cinder Shrine addition now grants only +20 battle Aether on first capture after the post-feature telemetry pass trimmed it from +24. It is simulator-modeled as tactical tempo, not a campaign reward, and should be watched mainly for route readability rather than long-term economy snowball.
- Chapter 1 values were not changed.

## UI Requirements

Campaign Map must show:

- `Chapter 2: Cinderfen Road`.
- `Cinderfen Road` / `cinderfen_overlook` as an available event when `ashen_outpost` is complete.
- Three baseline event choices with costs, rewards, reputation changes, completion outcome, and granted modifiers.
- The conditional Raise Malrec's Standard choice, including its trophy requirement when absent and its XP, reputation, Well Rested modifier, and completion outcome when present.
- `Cinderfen Crossing` as locked until `cinderfen_overlook` is completed.
- `Cinderfen Crossing` as playable after the event choice is made.
- Map name `Cinderfen Causeway`.
- Difficulty `Normal`.
- Enemy style `Hexfire Cult`.
- Reward preview including XP, campaign resources, and `Scout's Bow`.
- Battle HUD objective copy for `Claim the Cinder Shrine`, including `Cinder Shrine Surge (+20 Aether once)`.
- Battle status/floating copy when the shrine surge is granted, plus a minimap ping labeled `Cinder Shrine Surge`.

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
- Verifies `cinderfen_crossing` becomes playable after the event.
- Launches `Cinderfen Causeway`.
- Verifies BattleScene loads with map name, objective text, resources, Cinder Shrine first-capture bonus data, and minimap markers.
- Uses a safe test hook to capture the Cinder Shrine, verifies the +20 Aether surge, verifies the status/HUD copy, and verifies repeating the hook does not duplicate the bonus.
- Verifies the chosen next-battle modifier reaches launch and is consumed from the campaign save.
- Seeds Malrec's trophy state, verifies the conditional Raise Malrec's Standard choice appears and is available, applies it once, and verifies reward/modifier/reputation persistence.
- Does not require full victory.

Simulator coverage:

- Includes `cinderfen_crossing` as the first Chapter 2 scripted scenario.
- Keeps three scripts per scenario: Safe Beginner, Greedy Economy, and Fast Army.
- Reports Chapter 2 separately in the Markdown table.
- Models `firstCaptureBonus` on captured sites, so the Greedy Economy Cinderfen script records `Cinder Shrine Surge: 20 Aether` when it reaches the shrine.
- Cinderfen event-choice launch modifiers, including the Malrec trophy Well Rested path, are noted as future simulator profile work; the current simulator models battle-local shrine effects while unit/e2e coverage verifies live event effects.
- Preserves the no structural `too_hard` and no structural `too_easy` gates.

Regression gates:

- `npm test`: PASS, 37 test files and 233 tests.
- `npm run build`: PASS, known Vite large-chunk warning only.
- `npm run test:e2e -- --reporter=line`: PASS, 51 Playwright tests in 21.9m on the clean full rerun.
- `npm run playtest:sim`: PASS, 216 deterministic battle runs across 72 campaign battle node/profile summaries.

## Deferred Chapter 2 Work

- Add any further returning-rival consequence only if it stays at this scale, reuses existing rival state, and keeps duplicate first-defeat rewards blocked.
- Add any later Chapter 2 town/service node only after the first battle slice remains green.
- Do not add workers, enemy construction, full new factions, diplomacy, procedural generation, crafting, or a second Chapter 2 map as part of this slice.

## Acceptance Criteria

- `cinderfen_overlook` is a playable event node with three clear baseline choices and one clear optional Malrec trophy choice.
- Choice costs, rewards, reputation changes, completion behavior, and modifiers are visible on the Campaign Map.
- Event choice rewards do not duplicate after save/load.
- `cinderfen_causeway` exists and is registered.
- `cinderfen_crossing` launches the new map.
- `cinderfen_crossing` requires `cinderfen_overlook`.
- Chapter 1 flow still works.
- No missing-map launch path remains.
- Existing Ashen units and existing AI personality drive the enemy setup.
- Objectives, rewards, capture sites, neutral camps, and enemy references validate.
- Cinder Shrine gives Chapter 2 one distinct tactical identity without adding a new faction, map, unit, worker loop, enemy construction, diplomacy, procedural generation, or crafting.
- Cinder Shrine Surge is readable in objective/status copy, grants its +20 Aether once, and does not duplicate on recapture.
- Unit tests, build, e2e, and playtest simulator pass.
