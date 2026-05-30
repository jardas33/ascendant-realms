# v0.79 Vertical Slice Priority Lock

Status: docs-only priority lock.

This document records the approved order for future vertical-slice planning. It does not approve art generation, runtime asset import, faction implementation, race implementation, map creation, balance work, or runtime display-copy migration during v0.79.

## Priority 1 - Barrosan Freeholds

Approved role:

- first polished player faction;
- first full environment, Worker, hero, unit, building, mine, shrine, and HUD visual-slice anchor;
- emotional anchor through Salto and the Barrosan Marches;
- stewardship relationship with Lume;
- defensive resilience, Retinue continuity, Workers, and site control.

Safe internal mapping:

- Existing placeholder `free_marches` can remain the stable internal ID.
- Future display copy can move toward `Barrosan Freeholds` only through a later copy-migration gate.
- No runtime ID rename is approved.

Future slice targets:

- Salto village mood and material language.
- Barrosan hero/Jardas silhouette.
- Worker utility silhouette.
- basic frontline unit silhouette.
- ranged unit silhouette.
- Command Hall and Barracks architectural language.
- mine, shrine, and Lume-site read.
- HUD direction that supports hearth, oath, stone, and tactical clarity.

## Priority 2 - Ashen Covenant

Approved role:

- first polished enemy/rival faction;
- antagonist contrast against Barrosan visual language;
- altered humans, forge-blooded exiles, ember-marked beings, and controlled constructs;
- aggression, siege, and dangerous Lume overcharge;
- Captain Malrec remains the Act 1 rival direction.

Safe internal mapping:

- Existing internal ID `ashen_covenant` remains valid.
- No runtime ID rename is approved.

Future slice targets:

- disciplined Ashen military silhouette language;
- ember and forge material language;
- fortress and siege architecture;
- controlled-overcharge Lume effects;
- commander silhouette clarity;
- readable antagonist contrast that does not become generic demon, undead, or orc language.

## Priority 3 - Wolfveil Clans

Approved role:

- first strongly non-human secondary silhouette study;
- proof that the art pipeline and race-design rules support clearly non-human anatomy;
- pack territory, scouting, speed, flanking, and mobile aggression;
- Lume sensed through scent, path, territory, and pack memory.

Runtime status:

- No runtime implementation is approved.
- No new units, buildings, maps, mechanics, assets, or factions are approved.
- Wolfveil is a future visual and gameplay design stress test, not a v0.79 feature.

## Why This Order Is Locked

The order is approved because it solves three different validation problems:

1. Barrosan Freeholds prove the player-facing identity, home, Worker economy, Retinue, and Jardas stewardship fantasy.
2. Ashen Covenant prove the first enemy contrast, rival pressure, and danger of forced Lume control.
3. Wolfveil Clans prove that the project can move beyond human-shaped races without losing tactical readability.

## Future Gate Requirements

Before any vertical-slice implementation, a later milestone must define:

- exact scope;
- source/license posture;
- whether art may be generated or curated;
- silhouette tests;
- tactical-readability criteria;
- package-review rules;
- runtime import approval;
- validation commands;
- rollback plan.

v0.79 approves the priority order only.
