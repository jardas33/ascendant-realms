# Chapter 2 Cinderfen Slice Report

Date: 2026-05-03

Scope: clean v0.3 Chapter 2 slice report for the current Cinderfen Road implementation. This report records the current content only; it does not itself add gameplay, change balance, or add units, factions, workers, enemy construction, diplomacy, crafting, or procedural generation.

Sources:

- `LLM_GAME_HANDOFF.md`
- `docs/CHAPTER_2_IMPLEMENTATION_SPEC.md`
- `docs/CHAPTER_2_VERTICAL_SLICE_REPORT.md`
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `BALANCE.md`
- `ROADMAP.md`

## 1. Current Chapter 2 Contents

Chapter metadata:

- Chapter id: `cinderfen_road`.
- Chapter title: `Chapter 2: Cinderfen Road`.
- Current role: compact v0.3 vertical slice after `ashen_outpost`.
- Implemented node chain: `cinderfen_overlook` event gate, optional `cinderfen_waystation` support node, `cinderfen_crossing` battle node, then `cinderfen_watch` battle node.
- Unlock shape: Chapter 2 remains unavailable in a fresh Chapter 1 save; Cinderfen Overlook unlocks after `ashen_outpost`; Cinderfen Waystation and Cinderfen Crossing unlock after Cinderfen Overlook is completed; Cinderfen Watch unlocks after Cinderfen Crossing victory. The Waystation helps preparation but does not block either battle.

Cinderfen Overlook event gate:

- Node id: `cinderfen_overlook`.
- Display name: `Cinderfen Road`.
- Type: event.
- Status: playable.
- System use: existing campaign event/choice, resource, reward, reputation, modifier, save, and duplicate-prevention rules.
- Baseline choices:
  - `Scout the Causeway`: costs 30 Crowns; grants 20 XP, 8 Stone, +3 Free Marches, +1 Common Folk, and Local Support.
  - `Aid the Marsh Refugees`: costs 55 Crowns; grants 25 XP, 10 Iron, +6 Common Folk, +2 Free Marches, and Inspired Militia.
  - `Study the Cinders`: costs 24 Aether; grants 20 XP, Emberglass Wand, +5 Old Faith, -2 Ashen Covenant, and Blessed Road.
- Each baseline choice is once-only, completes the event, persists through `choiceIdsClaimed`, and unlocks `cinderfen_crossing`.
- Completing the event also unlocks `cinderfen_waystation`.

Cinderfen Waystation support node:

- Node id: `cinderfen_waystation`.
- Display name: `Cinderfen Waystation`.
- Type: town.
- Status: playable after Cinderfen Overlook; remains available while Chapter 2 is active.
- System use: existing town-service/event choice infrastructure, campaign resource costs, campaign modifiers, reputation rewards, save persistence, and duplicate prevention.
- Services:
  - `Marsh Guides`: costs 35 Crowns; grants Marsh Guides for the next Cinderfen battle, adding +60 player-building vision and +20s enemy warning lead.
  - `Ash Filters`: costs 35 Crowns and 15 Aether; grants Ash Filters for the next Cinderfen battle, adding +8% hero HP and Mana.
  - `Refugee Scouts`: costs 25 Crowns, one-time; grants 10 XP and +2 Common Folk reputation while previewing the Cinder Shrine / guardian route in copy.
  - `Shrine Attunement`: costs 12 Aether; grants Shrine Attunement for the next Cinderfen battle, increasing the Cinder Shrine Surge from +20 to +25 Aether on first player capture.
- Repeatable services stay repeatable through `townServiceUseCounts`; the one-time Refugee Scouts service persists through `choiceIdsClaimed` and `townServiceClaimedIds`.

Malrec trophy consequence:

- Optional choice: `Raise Malrec's Standard`.
- Requirement: existing trophy `trophy_malrec_outpost_standard`.
- Effect: no resource cost, 10 XP, +3 Free Marches reputation, and Well Rested.
- Scope: event-only returning-rival consequence using existing Rival/Nemesis Persistence V1 trophy state. It does not add a new rival, faction, rematch system, battle AI behavior, or save schema.

Cinderfen Crossing battle node:

- Node id: `cinderfen_crossing`.
- Display name: `Cinderfen Crossing`.
- Type: battle.
- Status: playable after Cinderfen Overlook.
- Difficulty: Normal.
- Enemy style: existing `hexfire_cult` AI personality.
- Enemy content: existing Ashen Covenant units and structures, no named Chapter 2 rival.
- Campaign node reward: 60 XP, 40 Crowns, 20 Stone, 20 Iron, 12 Aether, and `Scout's Bow`.

Cinderfen Watch battle node:

- Node id: `cinderfen_watch`.
- Display name: `Cinderfen Watch`.
- Type: battle.
- Status: playable after Cinderfen Crossing victory.
- Difficulty: Normal.
- Enemy style: existing `hexfire_cult` AI personality.
- Enemy content: existing Ashen Covenant units and structures, no named Chapter 2 rival.
- Campaign node reward: 62 XP, 40 Crowns, 22 Stone, 18 Iron, and 10 Aether.

Cinderfen Causeway map:

- Map id: `cinderfen_causeway`.
- Display name: `Cinderfen Causeway`.
- Size: `2600 x 1700`.
- Theme: ash marsh, burned road, cinder pools, black reeds, ashglass outcrops.
- Player start: southwest road shelf with Command Hall, hero, three Militia, one Ranger, and 480 Crowns / 325 Stone / 195 Iron / 110 Aether.
- Enemy start: northeast staging camp with existing enemy Stronghold, enemy Barracks, one prebuilt Watchtower, Raiders, Hexer, generic enemy commander, and 250 Crowns / 195 Stone / 140 Iron / 100 Aether.
- Enemy pacing: existing Hexfire Cult staging with a 6.4 second training interval and Cinderfen-specific economy values.

Cinder Shrine tactical feature:

- Site id: `cinder_crossing`.
- Display name: `Cinder Shrine`.
- Normal income: 16 Aether every 6 seconds.
- Feature: first capture by a side grants one battle-local `Cinder Shrine Surge` of +20 Aether.
- Duplicate rule: recapturing the same shrine with the same team does not grant another surge.
- Scope: battle-local tempo only; no campaign-bank reward, save schema, new resource type, new map, or new system.

Current capture sites:

| Site id | Name | Income | Role |
| --- | --- | --- | --- |
| `causeway_toll` | Causeway Toll | 30 Crowns / 5s | First readable income objective |
| `reedcut_quarry` | Reedcut Quarry | 22 Stone / 6s | Safer northern staging route |
| `sunken_iron_cache` | Sunken Iron Cache | 18 Iron / 6s | Riskier southern side path |
| `cinder_crossing` | Cinder Shrine | 16 Aether / 6s plus +20 Aether once | Central tactical identity hook |

Current objectives:

- Primary: destroy the enemy Stronghold.
- Secondary: claim the Cinder Shrine.
- Secondary: clear the Cinder Guardians by defeating the Brute anchor.
- Secondary: destroy the Enemy Barracks.

Current reward table:

- Reward table id: `cinderfen_causeway_rewards`.
- Weighted reward: one affix-capable existing item roll.
- Base victory reward: 30 XP plus 16 Crowns, 10 Stone, 8 Iron, 6 Aether.
- First-clear bonus: 35 XP plus 14 Crowns, 10 Stone, 8 Iron, 6 Aether.
- Repeat-clear reward: 4 XP plus 6 Crowns, 3 Iron, 2 Aether.
- Full first-clear read with campaign node reward: 125 XP, 170 total resources, one weighted battle item roll, and `Scout's Bow`.

Cinderfen Watchpost map:

- Map id: `cinderfen_watchpost`.
- Display name: `Cinderfen Watchpost`.
- Size: `2400 x 1550`.
- Theme: raised road through the cinder marsh, controlled by an Ashen watchtower and compact staging camp.
- Player start: southwest road shelf with Command Hall, hero, three Militia, one Ranger, and 500 Crowns / 335 Stone / 205 Iron / 115 Aether.
- Enemy start: northeast watchpost with existing enemy Stronghold, enemy Barracks, one central Watchtower, Raiders, Hexer, generic enemy commander, and 280 Crowns / 210 Stone / 155 Iron / 110 Aether.
- Enemy pacing: 80 Crowns / 40 Stone / 36 Iron / 30 Aether income per tick, 6.4s training, 195s first attack delay, 74s attack interval, 6-unit wave target, and 4-unit defense squad.
- Tactical role: harder than Cinderfen Crossing in aggregate because it has no Cinder Shrine surge and asks the player to manage fog, a towered road, and two camps; easier than Ashen Outpost in the current simulator read.

Watchpost capture sites:

| Site id | Name | Income | Role |
| --- | --- | --- | --- |
| `watch_road_toll` | Watch Road Toll | 28 Crowns / 5s | Primary road economy objective |
| `blackreed_stonecut` | Blackreed Stonecut | 20 Stone / 6s | Safer staging route |
| `ash_cistern` | Ash Cistern | 14 Aether / 6s | Exposed Aether side route |

Watchpost objectives:

- Primary: destroy the Ashen Watchpost Stronghold.
- Secondary: capture the Watch Road.
- Secondary: clear the Marsh Raider Camp by defeating the Brute anchor.
- Secondary: destroy the Watchpost Tower.

Watchpost reward table:

- Reward table id: `cinderfen_watchpost_rewards`.
- Weighted reward: one affix-capable existing item roll.
- Base victory reward: 32 XP plus 18 Crowns, 10 Stone, 8 Iron, 5 Aether.
- First-clear bonus: 34 XP plus 16 Crowns, 10 Stone, 8 Iron, 5 Aether.
- Repeat-clear reward: 3 XP plus 5 Crowns, 2 Iron, 1 Aether.
- Full first-clear read with campaign node reward: 128 XP, 170 total resources, and one weighted battle item roll.

## 2. Explicit Non-Implementation

The current Cinderfen slice is not a full Chapter 2 campaign.

Explicitly not implemented:

- No full Chapter 2 campaign.
- No new faction.
- No workers.
- No enemy construction or rebuilding.
- No diplomacy or alliance simulation.
- No procedural campaign.
- No procedural maps.
- No crafting, durability, affix rerolling, or broader loot complexity.
- No third Chapter 2 battle map yet.
- No full Chapter 2 route beyond Cinderfen Overlook, Cinderfen Waystation, Cinderfen Crossing, and Cinderfen Watch.
- No new unit types.
- No Chapter 2 named rival.
- No new rival system.
- No broad army-management system.
- No broad shop/vendor system; Cinderfen Waystation is a compact preparation stop.

## 3. Current Telemetry

Latest simulator scope:

- 255 deterministic runs.
- 85 campaign battle node/profile summaries.
- No structural `too_easy` flags.
- No structural `too_hard` flags.
- No Stronghold warnings.
- Cinderfen Crossing and Cinderfen Watch are included as Chapter 2 battle scenarios, with one additional Waystation: Shrine Attunement simulator profile that applies only when the Cinder Shrine exists.

Cinderfen Crossing overall:

| Runs | Wins | Defeats | Timeouts | Verdict |
| ---: | ---: | ---: | ---: | --- |
| 39 | 26 | 0 | 13 | Reasonable |

Script breakdown:

| Script | Runs | Wins | Defeats | Timeouts | Average first enemy contact |
| --- | ---: | ---: | ---: | ---: | ---: |
| Safe Beginner | 13 | 13 | 0 | 0 | 256.1s, about 4:16 |
| Greedy Economy | 13 | 1 | 0 | 12 | 255.3s, about 4:15 |
| Fast Army | 13 | 12 | 0 | 1 | 255.0s, about 4:15 when contact occurs |

Cinderfen Watch overall:

| Runs | Wins | Defeats | Timeouts | Verdict |
| ---: | ---: | ---: | ---: | --- |
| 36 | 25 | 0 | 11 | Reasonable |

Script breakdown:

| Script | Runs | Wins | Defeats | Timeouts | Average first enemy contact |
| --- | ---: | ---: | ---: | ---: | ---: |
| Safe Beginner | 12 | 12 | 0 | 0 | 237.3s, about 3:57 |
| Greedy Economy | 12 | 3 | 0 | 9 | 237.3s, about 3:57 |
| Fast Army | 12 | 10 | 0 | 2 | 238.0s, about 3:58 |

Difficulty ordering:

- Cinderfen Crossing: 26 wins / 0 defeats / 13 timeouts.
- Cinderfen Watch: 25 wins / 0 defeats / 11 timeouts.
- Ashen Outpost: 22 wins / 0 defeats / 14 timeouts.
- This keeps Watchpost slightly harder than the first Cinderfen battle while still below the Chapter 1 milestone fortress.

Cinder Shrine usage:

- 26 of 39 Cinderfen runs captured the Cinder Shrine and received the one-time battle-local surge; two Waystation-attuned runs raised the surge to +25 Aether.
- Fast Army often skips the shrine, so the shrine does not explain quick rush wins.
- The shrine remains a route-readability watchpoint, not a current structural balance warning.
- Cinderfen Watchpost intentionally has no Cinder Shrine, so Shrine Attunement is not consumed there and the simulator records 0 shrine surges for that node.

Retinue impact:

- Retinue impact is visible but not a global `too_easy` flag.
- Veteran Militia, mixed veterans, and Quartermaster II profiles typically sit at 2 wins / 0 defeats / 1 timeout on Cinderfen.
- Veteran Ranger is slower at 1 win / 0 defeats / 2 timeouts.
- Retinue + Training Yard II is the strongest Chapter 2 profile at 6 wins / 0 defeats / 0 timeouts across Crossing and Watchpost and remains a human-review watchpoint.

Stronghold impact:

- Tier II Quartermaster remains useful but not a sweep on the current Cinderfen route.
- No Stronghold warnings are reported.
- Training Yard II plus retinue is the stronger watchpoint than Quartermaster II alone.

Waystation impact:

- Shrine Attunement is the simulator-modeled Waystation profile. It adds only +5 Aether to the first Cinder Shrine capture on the next eligible Cinderfen battle.
- The service profile records 2 wins / 0 defeats / 1 timeout, so it is battle-local and modest; it improves staged Cinder Shrine routes without making Fast Army rushes meaningfully richer.
- Shrine Attunement intentionally does not apply to Cinderfen Watchpost because that map has no `cinder_crossing` shrine site.
- Marsh Guides and Ash Filters are covered by unit/e2e launch-effect tests and remain candidates for human readability review rather than broad simulator expansion.

Rival impact:

- 0 current Cinderfen battle runs include an enemy hero.
- 0 current Cinderfen battle runs apply rival persistence modifiers.
- Malrec's trophy consequence is verified through event/save/e2e coverage, not through Cinderfen battle-simulator modifiers.

Chapter 1 regression status:

- Chapter 1 telemetry remains stable because the Cinderfen pass touched only Chapter 2 data, battle-local capture-site rules, simulator modeling, and Cinderfen-specific copy.
- Current structural read still reports no `too_easy` and no `too_hard` nodes.
- Ashen Outpost remains beatable.

## 4. Current Risks

Fast Army farming risk:

- Fast Army remains strong: it wins 12 of 13 Cinderfen Crossing runs and 10 of 12 Cinderfen Watch runs, often before first-wave pressure fully matters.
- Rewards were trimmed to reduce farming pressure, but future Chapter 2 rewards should stay modest until another sink or consequence exists.

Retinue + Training Yard II strength:

- Retinue + Training Yard II sweeps Cinderfen at 3 wins / 0 defeats / 0 timeouts.
- This is a human-play watchpoint before adding more Chapter 2 player power.

Cinder Shrine readability:

- The Cinder Shrine is intentionally useful but central and contested.
- Players may over-prioritize it if the safer northern route and neutral-camp threat are not visually clear.

Cinderfen Watchpost readability:

- The new Watchpost battle has earlier first enemy contact, averaging about 3:57, and a central Watchtower objective.
- Human play should verify the Watch Road Toll, Marsh Raider Camp, tower, fog, and minimap markers read clearly without feeling like a difficulty cliff.

Event choice clarity:

- Cinderfen Overlook choices show costs, rewards, reputation, modifiers, and completion state in one panel.
- Automated coverage verifies correctness, but human mobile readability still needs a spot check.

Waystation service clarity:

- Cinderfen Waystation adds four service cards to an already dense campaign side panel.
- Service effect copy is clear in tests, but human mobile/scroll review should verify the cost/modifier/outcome lines remain readable.

Chapter 2 reward pacing:

- First-clear rewards are useful but below Ashen Outpost; Watchpost now reads as 128 XP / 170 resources on a full first clear.
- Adding more Chapter 2 payout before a fresh sink or consequence could reopen the reward-farm risk.

E2E suite runtime:

- Full Playwright coverage is green but slow at roughly 23.5 minutes.
- Keep full e2e for checkpoints; use focused tests while iterating on narrow docs or UI-only changes.

## 5. Recommended Next Work

Recommend two small follow-ups:

1. Human-verify the two-battle Cinderfen route.
   - Purpose: confirm Waystation service readability, Cinder Shrine readability, Watchpost fog/tower readability, and campaign reward pacing in the live browser flow.
   - Scope: no new gameplay systems; use existing tests and a short browser pass.

2. Add one compact non-battle Chapter 2 consequence only after the two-battle route remains green.
   - Purpose: make the route feel reactive without adding a broad system.
   - Scope: one small event, warning, or town-service consequence using existing campaign resources, reputation, modifiers, and duplicate-prevention rules.

Keep the boundary firm: no workers, enemy construction, new factions, diplomacy, procedural campaign, crafting, another battle map, or broad army-management systems yet.
