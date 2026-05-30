# v0.78 Signature Gameplay Pillars

Date: 2026-05-30

## Status

This document classifies future signature pillars. It does not authorize implementation in v0.78.

| Pillar | Definition | Current status | Next safe posture |
| --- | --- | --- | --- |
| Hero-led RTS/RPG warfare | Persistent Race + Class heroes lead armies, evolve, and influence tactical combat and site control. | Partially implemented: hero XP, skills, relics, abilities, and loadout exist. | Safe near-term extension only after review. |
| Lume Network | Mines, shrines, springs, stones, ruins, and sites form linked territorial networks with strategic effects. | Concept only; current sites exist. | Requires dedicated design gate. |
| Living Mines | Workers visibly work captured mines and choose extraction specializations. | Scaffolded by resource sites, Workers, assignment, and upgrades. | Requires art-pipeline maturity and careful economy design. |
| Persistent Retinue | Survivors gain continuity, names, scars, loyalty, traits, and emotional value. | Partially implemented: Retinue persistence, deployment, recovery, reinforcement. | Safe near-term extension if small and save-safe. |
| Rival Commanders | Rivals remember, adapt, gain traits, and return with altered strategies. | Scaffolded by Malrec, rival rewards, doctrines, finale. | Requires dedicated design gate before persistence depth. |
| Dynamic Battlefield Oaths | Mid-battle choices create consequence, such as saving villagers or overcharging a site. | Conceptually scaffolded by dynamic objectives/events. | Requires narrative/gameplay gate. |
| Salto Stronghold | Salto evolves visibly between missions as home, not menu. | Stronghold upgrades exist conceptually; Salto identity not in runtime. | Requires art/UI/narrative gate. |
| Long Branching Campaign | Mix RTS battles, hero missions, defense, hunts, rival arcs, choices, stronghold growth. | Partially implemented through Act 1 campaign/replay/finale. | Requires campaign design gate. |
| Future PvP | Long-term competitive online mode. | Deferred. | Multiplayer-dependent, long-term desktop scope. |
| Future Co-op Expeditions | 2-4 player co-op against monsters, corrupted fortresses, and Lume-depth challenges. | Deferred. | Multiplayer-dependent, long-term desktop scope. |
| High-Level Endgame | High-level heroes stay useful through hunts, bosses, challenge tiers, and build experiments. | Concept only. | Long-term full-game scope. |

## Lume Network Examples

Possible future links:

- connect a quarry to a shrine for defensive wards,
- connect two mines for deeper extraction,
- connect a spring to a village for recovery,
- sever an enemy link to weaken a fortress,
- defend a junction site to preserve network bonuses.

Every race should eventually interact with the Lume Network differently.

## Living Mines Examples

Possible mine specializations:

- Safe Extraction,
- Deep Delving,
- Fortified Works,
- Lume Channel.

Each specialization should create decisions and consequences. Do not implement in v0.78.

## Dynamic Battlefield Oath Examples

- Save villagers or seize a strategic vein.
- Rescue a wounded Retinue veteran or pursue a rival commander.
- Overcharge a site for immediate strength or preserve it for campaign value.

## Implementation Principle

Every pillar should deepen the same identity: a personal hero, a living land, tactical armies, consequence-bearing sites, and a home worth defending. No pillar should become a disconnected minigame.
