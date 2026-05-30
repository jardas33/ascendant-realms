# v0.68 Counterplay Readability Spec

## Goal

Every doctrine and elite squad should tell the player what is happening and how to respond using existing campaign, HUD, selection, and Results surfaces.

## Counterplay Lines

- Raider: protect resource sites and Workers with Militia screens.
- Fortress: attack economy first or prepare a larger push before entering defenses.
- Hunter: keep hero and Retinue near escorts; avoid isolated dives.
- Warband: regroup before late pressure and use the once-per-battle Retinue reinforcement wisely.

## UI Rules

- Keep copy short and tactical.
- Avoid modal flow or new art.
- Put warnings in campaign briefing before launch, battle HUD during play, selected-unit details for elite units, and Results after action.
- Do not clutter Tutorial or no-reward routes.

## Results Rules

Results should show:

- active doctrine,
- key doctrine actions recorded,
- elite squad present,
- elite squad defeated,
- note that doctrine and elite tags are battle-only and save-safe.

## Save Compatibility

No save schema changes are required. Doctrine ids and elite squad ids live in battle launch/runtime stats only. Old saves load exactly as before.

## Deferrals

- No advanced scouting layer.
- No player doctrine codex.
- No elite trophy rewards.
- No enemy counter-build tree.
