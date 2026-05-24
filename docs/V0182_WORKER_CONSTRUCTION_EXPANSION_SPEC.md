# v0.18.2 Worker Construction Expansion Spec

Date: 2026-05-23
Status: implementation spec

## Goal

Expand the v0.18 Worker construction foundation from the first Barracks slice to the existing player construction set only:

1. Barracks.
2. Mystic Lodge.
3. Watchtower.

This is still not a full worker economy. The pass should only make the existing player buildings start from Worker selection instead of Command Hall selection.

## Scope

Included:

- Worker build commands for Barracks, Mystic Lodge, and Watchtower.
- Existing building costs, construction times, art, footprints, and production behavior.
- Existing one assigned Worker per construction site.
- Existing construction progress and blocker behavior.
- Incomplete Watchtower inertness before completion.
- UI feedback for visible costs, locked affordability, assigned Worker, construction status, and construction progress.
- Focused unit/UI/runtime tests and hosted browser coverage.

Not included:

- harvesting,
- repairs,
- multiple workers per site,
- cancellation/refund UI,
- broad economy or production rebalance,
- enemy worker construction,
- broad AI rewrite,
- save migration,
- new factions, maps, buildings, units, or runtime art/assets,
- Patrol runtime,
- formations,
- Tutorial expansion beyond the existing Worker Barracks path.

## Design Rules

- Player-facing construction commands live on Worker selection.
- Command Hall trains Workers but exposes no direct building placement commands.
- Barracks, Mystic Lodge, and Watchtower use the same Worker assignment path.
- A Worker-created construction site stores assigned Worker id/name and progress status.
- Construction progresses only while the assigned Worker is alive and close enough to the building footprint.
- Incomplete buildings block/path like buildings but do not train, research, or attack.
- Completed buildings resume their existing behaviors:
  - Barracks trains Militia and Ranger.
  - Mystic Lodge trains Acolyte and researches Aether Study I.
  - Watchtower fires its existing defensive attack.

## UI Expectations

Worker selection should show:

- Build Barracks.
- Build Mystic Lodge.
- Build Watchtower.
- Cost text for each command.
- Disabled commands with cost text when resources are insufficient.

Incomplete selected buildings should show:

- production lock copy,
- status,
- construction percentage,
- assigned Worker,
- one world health/progress bar pattern only.

## Tutorial Impact

Tutorial remains stable and still teaches the Barracks construction route. Mystic Lodge and Watchtower are available to Workers in normal battle UI, but Tutorial does not require or add objectives for them in this checkpoint.

## Save Format

No save format change.

Construction state remains battle-runtime state for this pass.

## Package Retest Focus

Retest the packaged build by confirming:

1. Command Hall can train Worker.
2. Command Hall has no build buttons.
3. Worker has Barracks, Mystic Lodge, and Watchtower build buttons.
4. An incomplete building cannot train/research/attack.
5. A Worker-built Barracks can complete and then train units.
6. A Worker-built Watchtower does not fire before completion and can fire after completion.
