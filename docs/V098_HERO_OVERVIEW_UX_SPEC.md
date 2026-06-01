# v0.98 Hero Overview UX Spec

Status: implemented presentation-only spec.

## Purpose

The Hero screen should read like a clear meta-progression game screen instead of a long dashboard. v0.98 keeps all hero rules, XP rules, equipment rules, Retinue rules, saves, and stable IDs unchanged.

## Default Hierarchy

The top of the Hero Inventory screen now prioritizes:

- hero identity;
- level and XP progress;
- class and origin;
- primary stats;
- equipment slot count;
- equipped relic;
- skill points and purchased skills;
- Retinue deployment/reserve/recovery summary;
- stored inventory count.

## Screen Structure

Above the fold:

- hero portrait, name, class, origin, and level;
- Hero Overview card;
- concise progression guidance/status;
- Skills, Equipment, Inventory, and Retinue summary cards.

Behind `More Details`:

- full primary stat grid;
- unlocked ability list;
- build identity/relic synergy details;
- detailed recent battle stat readout when the screen was opened from Results.

## Rules Boundary

No hero progression math changed. Rendering the screen must not mutate the hero save, campaign save, XP, stats, equipment, inventory, relic state, skill allocations, Retinue state, or Stronghold upgrades.

## Deferrals

- Full character-sheet tabs remain deferred.
- Final art, portrait art, and icon replacement remain deferred to the controlled visual pipeline.
- Persistent UI preferences are deferred.
