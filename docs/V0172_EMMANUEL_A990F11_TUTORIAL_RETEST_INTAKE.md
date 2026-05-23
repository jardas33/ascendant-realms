# v0.17.2 Emmanuel a990f11 Tutorial Retest Intake

Date: 2026-05-23
Package tested: `ascendant-realms-private-playtest-a990f11`
Route: Tutorial
Result: MIXED

## Passed

- Tutorial objective box dragging works well.
- Tutorial box Hide/Show and Reset remain usable.

## Issues

1. Stone Imp damage against the hero is missing.
   - Damage from Stone Imps against player units appears correctly.
   - Damage from other enemies against the hero appears correctly.
   - The missing case appears specific to Stone Imps hitting the Tutorial hero.

2. Incoming damage text is too wordy.
   - Player-side damage sometimes shows `HIT -N`.
   - Preferred behavior: show only the damage number, matching outgoing enemy damage.
   - Status/effect labels such as `Burn` should still appear through the existing effect feedback.

3. Tutorial enemy buildup is still too fast.
   - Enemy army growth remains too quick for a new player.
   - Tutorial should be easier without globally nerfing campaign or skirmish AI.

## Implementation Scope

- Keep the fix narrow to Tutorial polish and damage feedback readability.
- Do not implement worker construction or start v0.18.
- Do not add units, buildings, maps, factions, runtime art/assets, save migrations, or broad AI/pathing rewrites.
- Keep Tutorial pressure changes Tutorial-only.

## Fix Notes

- Root cause for the Stone Imp hero case: Stone Imp raw damage is `8`; the Tutorial Warlord hero has `4` armor, so the actual direct hit is `4`. The previous direct-damage feedback threshold hid values below `5`.
- Player-owned targets now show small incoming direct hits down to `1` damage.
- Incoming direct damage now uses compact `-N` text instead of `HIT -N`.
- Effect labels remain separate through existing status feedback.
- Tutorial-only enemy AI pacing is eased further without changing shared map AI data or global difficulty presets.
