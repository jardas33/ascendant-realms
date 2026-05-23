# v0.17 Solo Playtest Intake

Date: 2026-05-23

Tester: Emmanuel
Route: Tutorial / Proving Grounds
Baseline package: `ascendant-realms-private-playtest-461c563`
Baseline checkpoint: v0.16.13 / v0.16.x combat-control line
Result: PASS with polish/design follow-up

## Manual Result

- CI is green.
- Critical adjacent melee bug is fixed.
- Attack cursor feels better.
- No major broken/confusing items.
- Tutorial defeat/results works.

## Remaining Annoyance

- The Tutorial objective box can block the playfield view.
- It should be draggable, movable, minimized, or otherwise easy to get out of the way without interfering with HUD or minimap interactions.
- Any persistence should be current-session only, not save data.

## Tutorial Difficulty Feedback

- Tutorial feels too hard when the enemy builds a large army quickly.
- The player needs to aggressively capture mines and build an army to keep up.
- v0.17 should prefer Tutorial-specific readability and guidance before broader tuning:
  - clearer instruction to capture resource sites early,
  - clearer warning that the enemy is building army,
  - clearer guidance toward Barracks, Militia, rally, and grouped defense,
  - only small Tutorial-only pacing changes if strongly justified.

## Worker-Economy Design Feedback

- The Command Hall/main building should not produce army units long-term.
- It should produce workers.
- Workers should build buildings.
- Barracks/training buildings should produce army units.
- Buildings should unlock upgrades and army units.

## Scope Decision

v0.17 is a first polish/design checkpoint after the green v0.16.13 combat-control baseline. It may adjust Tutorial UI/readability and document the worker-economy direction, but it must not implement full worker construction, rewrite production/economy architecture, add units/buildings/maps/factions, change save format, add runtime art/assets, or globally rebalance enemy AI.

## v0.16 Manual Status

The v0.16 critical adjacent melee/contact reacquisition bug is manually fixed as of Emmanuel's `ascendant-realms-private-playtest-461c563` retest. No further v0.16.x combat bugfix is required from this intake.
