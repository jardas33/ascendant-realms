# Campaign Graph And Reward Gate

Last updated: 2026-05-08

## Purpose

This v0.5 gate protects the current campaign route before future chapters, tutorial shells, workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural generation, or broader army systems are added.

The gate is intentionally conservative:

- Validate that current chapters are reachable from their entry and prerequisite graph.
- Validate that battle nodes do not become isolated route stops.
- Validate that non-town choices that refuse to complete a node still open or close a path.
- Validate that one-time town item services have a stock item guard.
- Validate that repeat-clear rewards stay explicit, item-free in the direct repeat bonus, and lower than matching first-clear bonuses.

## Current Graph Shape

Chapter 1, Border Marches:

```text
border_village
  -> old_stone_road
old_stone_road
  -> marcher_camp
  -> aether_well_ruins
  -> bandit_hillfort
  -> refugee_caravan
aether_well_ruins
  -> chapel_of_the_marches
chapel_of_the_marches
  -> ashen_outpost
bandit_hillfort
  -> ashen_outpost
ashen_outpost
  -> unlock prerequisite for cinderfen_road
```

Chapter 2, Cinderfen Road:

```text
ashen_outpost
  -> cinderfen_overlook
cinderfen_overlook
  -> cinderfen_waystation
  -> cinderfen_crossing
cinderfen_crossing
  -> cinderfen_watch
cinderfen_watch
  -> cinderfen_aftermath
```

`marcher_camp`, `refugee_caravan`, and `cinderfen_waystation` are optional support or event branches. They may have no forward unlock because the campaign status rules also unlock nodes whose prerequisites are complete, and these side nodes are not intended to be mandatory route gates.

## Intentional Endpoints

- `ashen_outpost` has no direct node unlock, but it is the required chapter unlock prerequisite for `cinderfen_road`.
- `cinderfen_aftermath` is the current frozen v0.3 route endpoint.
- Optional support/event nodes can end locally when they are not the main route continuation.

The validator now fails battle nodes that have no direct unlock, no dependent prerequisite node, and no chapter-continuation role.

## Current Repeat Reward Policy

- Every reward table must define `repeatClearReward`.
- Direct `repeatClearReward.itemIds` are disallowed.
- Repeat-clear XP cannot exceed first-clear bonus XP when a first-clear XP bonus exists.
- Repeat-clear resources cannot exceed matching first-clear bonus resources when a first-clear resource bonus exists.
- Cinderfen battle reward pools keep weighted items and base resource/XP payouts first-clear-only, with repeat clears limited to tiny XP/resources.

Current Cinderfen repeat rewards:

```text
cinderfen_causeway_rewards: 6 crowns, 3 iron, 2 aether, 4 XP
cinderfen_watchpost_rewards: 5 crowns, 2 iron, 1 aether, 3 XP
```

## Added Gate Coverage

The v0.5 Phase 8 validator/tests cover:

- Chapter 1 and Chapter 2 reachability through chapter entry prerequisites.
- Missing or unreachable current chapter nodes.
- Battle nodes with no route continuation.
- Battle nodes whose maps point at missing reward tables.
- Missing unlock targets through existing node and choice reference validation.
- Costed choices with no visible saved effect.
- Non-town `completesNode: false` choices with no unlock or lock flow.
- One-time town item services without `stockItemId` duplicate guards.
- Reputation effects pointing at missing faction IDs.
- Repeat-clear rewards with direct items or higher XP/resources than first-clear bonuses.

## Watch Items

Fast Army quick-clear feel:

- The route remains green in simulator telemetry, but quick clears can make repeat farming feel more attractive than intended.
- The current gate protects direct repeat rewards, but it does not replace human review of pace, fatigue, or reward perception.

Retinue plus Training Yard II strength:

- Retinue capacity and Training Yard II remain watch items because veteran carryover plus faster training can compress Cinderfen difficulty.
- This gate does not change balance. Future tuning should use simulator evidence plus manual route review.

Cinder Shrine salience:

- `shrine_attunement` now has stricter Cinderfen-only capture-site validation from Phase 6.
- Human readability still matters: the gate can prove references are valid, not that the shrine is obvious enough in play.

## Future Expansion Risks

- Chapter 3 should add chapter entry prerequisites before adding nodes.
- New battle nodes should either feed a later prerequisite, directly unlock a route node, or be documented as an intentional endpoint before validation is relaxed.
- New repeat-clear economies should stay small and item-free unless a future farming policy explicitly allows otherwise.
- New town services that sell one-time items should always use `stockItemId`.
- New non-town choices that do not complete their node should visibly change path flow.
- Procedural/skirmish rewards need a separate economy gate before they share campaign reward tables.
