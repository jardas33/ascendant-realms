# v0.58 Unit Role Identity Spec

## Goal

Give each existing player unit a clear battlefield identity so selection, commands, control groups, and combat feedback explain what the unit is for.

## Role Taxonomy

- Militia: frontline, melee, holds ground.
- Ranger: ranged, focus fire, fragile.
- Acolyte: aether, support, special damage.
- Hero: commander, champion.
- Worker: utility, build, repair, site support.
- Watchtower/buildings keep existing building-role copy and are not army units.

## Metadata Rules

- Role metadata is content-driven and validates against existing unit ids.
- Player-facing role copy includes a short label, readable tags, and a tactical hint.
- Enemy unit role metadata may exist for readability, but it must not buff enemies or alter AI globally.
- Worker remains primarily utility and should not be encouraged as a combat unit.

## UI Scope

- Selected unit panel shows a concise role label and tags.
- Group selection can summarize the selected army mix without requiring a new roster UI.
- Role copy should reinforce existing commands: Militia in front, Rangers focus from range, Acolytes support with aether damage, Workers build/repair/assign sites.

## Deferrals

- No class system.
- No role-based passive ability tree.
- No formation editor or squad composition manager.
- No new unit types.
- No runtime art or icon pipeline.
