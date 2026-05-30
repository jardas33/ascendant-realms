# v0.81 Emmanuel Review Packet

Status: decision packet for the Lume Site Network prototype specification. No runtime Lume code was added.

## What v0.81 Audited

v0.81 audited the current browser prototype architecture for resource sites, Workers, campaign nodes, maps, HUD, Results, battlefield events, enemy AI, saves, replay, Tutorial/no-reward routing, package validation, and tests.

Important files inspected:

- `src/game/types/MapTypes.ts`
- `src/game/entities/CaptureSite.ts`
- `src/game/systems/ResourceSystem.ts`
- `src/game/battle/BattleSceneSystems.ts`
- `src/game/battle/BattlefieldEventDirector.ts`
- `src/game/data/borderMarchesNodes.ts`
- `src/game/data/maps/brokenFord.ts`
- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/ui/hudPanels/SelectedEntityPanel.ts`
- `src/game/ui/hudPanels/ObjectivePanel.ts`
- `src/game/results/ResultsObjectiveSummary.ts`
- `src/game/save/SaveTypes.ts`
- `src/game/save/SaveNormalization.ts`

## Why Runtime Implementation Has Not Started

The goal is a docs-only design gate. Runtime implementation would be premature because the team needs a decision on the smallest fun slice before code starts. This packet is meant to prevent a too-large graph system, save migration, visual overlay, or race-specific expansion from sneaking in before the core idea is proven.

## Current Site-System Summary

Resource sites are map-defined `CaptureSiteDefinition` entries. Live `CaptureSite` entities track owner, capture progress, income timer, level, Worker assignments, and enemy abstract logistics. `ResourceSystem` handles capture, income, first-capture bonuses, Worker assignment, and site upgrades.

The important safety fact: `CaptureSite.setOwner` already resets capture progress, income timer, site level, Worker assignments, and enemy logistics. This is a natural future severing point for Lume links.

## Safe Extension Points

- Content-driven eligible-site metadata.
- Battle-local link resolver.
- Existing site ownership and enemy recapture.
- Existing campaign mission briefing.
- Existing objective/event HUD row.
- Existing selected-site panel.
- Existing Results summary blocks.
- Existing content validation.

## Three Smallest-Fun-Slice Candidates

1. Linked Control: capture two linked sites to activate one modest benefit. Best core rule.
2. Jardas Binding: hero binds captured sites before links activate. Strong identity, higher friction.
3. Mission-Local Lume Objective: one mission teaches a tightly scoped Lume objective. Safest teaching shell.

## Recommended Candidate

Recommend a hybrid:

> Mission-local Linked Control.

Use Candidate C as the teaching shell and Candidate A as the rule set.

## Recommended First Mission

Recommend `Aether Well Ruins` (`aether_well_ruins`) on `broken_ford`.

Reason:

- It is already the Act 1 resource-control mission.
- The player has already learned basic capture and base development.
- The map has a readable site chain.
- The theme fits Lume without starting a runtime copy migration.
- It is not as overloaded as the Act 1 finale.

Recommended future visible display name, if later approved: `Lume Well Ruins`. Keep internal id `aether_well_ruins`.

## Recommended Node And Link Limits

- Maximum eligible nodes: three.
- Recommended nodes: `west_stone_cut`, `ford_toll`, `north_aether_spring`.
- Maximum active links: two.
- First link: `west_stone_cut` <-> `ford_toll`.
- Optional second link: `ford_toll` <-> `north_aether_spring`.

## Recommended First Benefit

Recommend `Linked Ward`:

- friendly units/buildings near active linked sites gain a small defensive readiness bonus;
- non-stacking;
- battle-local;
- active only while both linked sites are held;
- severed by enemy recapture.

Why this benefit:

- It makes territory feel alive.
- It is more readable than another income multiplier.
- It avoids economy snowball.
- It gives the enemy a natural counterplay path.

## Hero Binding Posture

Recommendation: defer hero/Jardas binding for the first runtime prototype.

Reason:

- Capture-only proves the network first.
- Binding would add a new action command, progress state, disabled reasons, interruption logic, pathing expectations, and tests.
- The system can still imply the Jardas through briefing/Results copy.

Emmanuel can override this if hero identity is more important than lowest-friction testing.

## HUD Posture

Use one existing objective/event-style row:

- title;
- linked site names;
- active/inactive/severed state;
- one counterplay line.

Do not add a giant overlay or minimap graph first.

## Results Posture

Use one compact Results block:

- links activated;
- links severed;
- objective completed/incomplete;
- benefit summary;
- battle-local/no-save note.

## Tutorial, Replay, Reward, And Save Posture

- Tutorial/no-reward routes remain excluded.
- Replay can show the battle-local objective again but cannot duplicate first-clear rewards.
- No persistent Lume reward in the first prototype.
- No save-version bump.
- No new persistent save fields.
- No stable ID rename.

## Race Extensibility Summary

First slice should be race-neutral/Barrosan-baseline. Later race directions:

- Barrosan Freeholds: stewardship and reliable defense.
- Ashen Covenant: overcharge and instability.
- Moura Court: hidden paths and bargains.
- Granitborn: living walls and stone.
- Wolfveil Clans: trails and scouting.
- Careto Host: disruption and inversion.
- Rootbound Concord: spread and recovery.
- Deepbell League: engineering and resonance.

No race-specific rules should be implemented first.

## Future Sequence

1. v0.81 Emmanuel review.
2. Future runtime prototype: one mission, battle-local, Linked Ward.
3. Controlled display-copy migration only after prototype direction approval.
4. Separate visual style-frame review.
5. Later Living Mines, race variants, desktop gate, and title gate.

## Explicit Non-Goals

No runtime Lume code, gameplay change, balance change, save migration, display-copy migration, stable ID rename, art generation/import, new maps, new factions, new races, new units, new buildings, desktop work, multiplayer, PvP, co-op, or v0.82 work was added in v0.81.

## Decisions For Emmanuel

1. Is mission-local Linked Control the correct smallest fun slice?
2. Is `Aether Well Ruins` the correct first mission?
3. Should the first slice use capture-only activation, Jardas binding, or a hybrid?
4. Should the first slice allow two or three eligible sites?
5. Should the first slice allow one or two active links?
6. Is `Linked Ward` clear and fun enough as the first benefit?
7. Should the first slice remain battle-local with no save changes?
8. Should Tutorial and no-reward routes remain excluded?
9. Should race-specific Lume mechanics remain deferred?
10. Should the first runtime prototype happen before display-copy migration?
11. Should `Aether Well Ruins` eventually display as `Lume Well Ruins`, `Old Spring Ruins`, or another name?
12. Which design questions should remain open?

## Confirmation

No runtime Lume Network code was added.
