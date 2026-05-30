# v0.78 Hero Race Class Origin Oath Architecture

Date: 2026-05-30

## Status

This is a future design architecture. No hero classes, save fields, balance values, UI flows, or runtime strings are changed in v0.78.

## Intended Hero Layers

Future heroes should be defined by:

1. Race
2. Class
3. Origin
4. Oath specialization
5. Skill-point allocation
6. Equipment
7. Relics
8. Unlimited hero levelling with soft scaling rather than a hard cap

The hero should feel like a persistent personal character, not an expendable match commander.

## Proposed Initial Class Directions

| Class | Identity | Battlefield role |
| --- | --- | --- |
| Marshal | Army leadership, morale, banners, disciplined formations. | Strong army buffs and command rhythm. |
| Warden | Frontline durability, site defense, area control. | Holds territory and protects Lume sites. |
| Seer | Lume manipulation, foresight, ranged magic, disruption. | Ability control and tactical prediction. |
| Binder | Site conversion, territorial control, wards, summons, Lume-network support. | Converts map control into power. |
| Hunter | Scouting, mobility, elite-target killing, beasts, ambushes. | Finds and removes key threats. |
| Artificer | Traps, siege support, mine upgrades, constructs. | Economy-tech and battlefield devices. |
| Shepherd | Healing, protection, Retinue support, spiritual resilience. | Keeps armies and survivors alive. |

Class names are human-review proposals.

## Conservative Mapping From Existing Prototype Classes

| Current prototype class | Future mapping option | Notes |
| --- | --- | --- |
| Warlord | Marshal or Warden | Existing leadership/damage fantasy can split into command or frontline durability later. |
| Arcanist | Seer or Binder | Existing ability/mana fantasy can become Lume manipulation or site-binding. |
| Shepherd | Shepherd | Existing name already fits Retinue/protection support; may need stronger world-specific oath framing. |

No runtime migration is approved now.

## Race + Class Examples

- Barrosan Warden: hearth defense, site protection, Retinue recovery.
- Moura Seer: hidden route prediction, spring illusions, elite control.
- Granitborn Binder: standing-stone wards, living walls, slow map lock.
- Wolfveil Hunter: scouting, ambush, elite commander pressure.
- Deepbell Artificer: mine upgrades, traps, resonant machinery.
- Rootbound Shepherd: healing ecosystems, Retinue regrowth, site restoration.
- Careto Marshal: ritual tempo, morale disruption, winter charge windows.
- Ashen Seer: controlled overburn, dangerous Lume foresight, commander pressure.

Race + Class combinations should be mechanically meaningful, not merely cosmetic. Race should shape economy, site interaction, and silhouette. Class should shape abilities, army command, and hero build. Origin and Oath should add personal story and progression direction.

## Origins

Origins should express where the hero comes from and what social debt they carry. Examples:

- Salto Hearthkeeper,
- Mine Road Survivor,
- Shrine-Bound Orphan,
- Exiled Forge Witness,
- Ridge Path Scout,
- Broken-Oath Heir.

Origins should affect starting story, small passives, dialogue hooks, or future campaign options. They should not become a giant class system.

## Oath Specializations

Oaths should define the hero's relationship to Lume:

- Oath of Hearth: protect home, Retinue, and recovery.
- Oath of Stone: defend sites and endure pressure.
- Oath of Flame: wield dangerous force with consequence.
- Oath of Spring: heal, reveal, and restore.
- Oath of Road: move, scout, and connect.
- Oath of Bell: craft, mine, and resonate.

Names are draft only.

## Unlimited Hero Levelling Philosophy

Future design should avoid a hard level cap while protecting campaign pacing:

- campaign missions preserve the pleasure of becoming stronger,
- later regions naturally introduce stronger enemies,
- optional high-level Expeditions scale upward,
- elite monsters and future co-op bosses become increasingly difficult,
- stat growth softens gradually at high levels,
- new synergies and build options remain meaningful after raw numerical growth slows,
- early missions do not endlessly auto-scale to match the player.

Do not implement balance changes in v0.78.

## Save And Migration Posture

Future hero architecture likely needs a dedicated save-compatibility gate. Until that gate exists, preserve current hero save fields, class IDs, item IDs, relic IDs, skill IDs, and save version.
