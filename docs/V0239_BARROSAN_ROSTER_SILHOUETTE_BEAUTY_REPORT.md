# v0.239 Barrosan Roster Silhouette Differentiation and Settlement Beauty Restore

Milestone verdict: `PASS`

Overall finish classification: differentiated and inhabited stylized low-poly production roster, not final hand-textured environment art.

## Asset and scene revision

- Blender used: yes, Blender 5.1.2.
- New Blender source: `art-source/blender/v0239/salto_barrosan_roster_silhouette_beauty.blend` (538,403 bytes).
- New GLB exported: yes.
- New GLB: `desktop-spikes/godot-salto/assets/v0239/salto_barrosan_roster_silhouette_beauty.glb`.
- New GLB size: 6,987,256 bytes; SHA-256 `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- v0.238 GLB preserved: yes, unchanged at 6,987,388 bytes and SHA-256 `76FA042C420F7A8ED0420E38208B188E4C9C41E89CE951E42EB6B01810338839`.
- v0.239 supersedes v0.238 only for the isolated review path.
- Scene: `res://scenes/salto_barrosan_roster_silhouette_beauty.tscn`.

## Exact counts

- Building modules revised: 6.
- Prop modules added or revised: 6.
- New or changed material families: 6.
- Composed building instances: 9.
- Composed role-prop instances: 28.
- Added beauty vegetation instances: 15.
- Added beauty ground surfaces: 6.
- Square terrain modules placed: 0.
- Panel-style road modules placed: 0.

## Role differentiation

- House: smallest calm closed body, modest porch, garden, domestic bench/laundry and low boundary.
- Farm/granary: raised broad storage body, taller roof, loading deck, ramp, loft vent, sacks, hay and grain cart.
- Lumber/carpenter: small service body plus dominant open canopy yard, A-frame, saw bench, logs and planks.
- Blacksmith/forge: compact heavy dark-stone body, buttresses, soot chimney, forge mouth, anvil, tools and coal/ore.
- Watchtower: narrow shaft, projecting braced lookout, ladder and guard banner, clearly below keep authority.
- Market/storehouse: open public hall and counter, broad cloth awning, visible goods and loading space.

## Exact source files changed

- `tools/blender/generate_v0239_barrosan_roster_silhouette_beauty.py`
- `tools/blender/generateV0239BarrosanRosterSilhouetteBeautyWindows.ps1`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_roster_silhouette_beauty.gd`
- `desktop-spikes/godot-salto/scenes/salto_barrosan_roster_silhouette_beauty.tscn`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/captureGodotV0239BarrosanRosterSilhouetteBeautyWindows.ps1`
- `tools/godot/validateGodotV0239BarrosanRosterSilhouetteBeautyWindows.ps1`
- `tools/godot/buildV0239BarrosanRosterSilhouetteBeautyReviewPack.py`
- `tools/godot/saltoV0239BarrosanRosterSilhouetteBeautyTool.mjs`
- `package.json`
- `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`

## Validation and visual assessment

The exact v0.239 validator passes, the pack contains the required twelve files, roofs remain valid, and the retained v0.238 hash matches. The six roles now separate by massing, height, openness and yard footprint at RTS overview scale. Added threshold wear, vegetation, riverbank growth and working clutter restore much of v0.237's inhabited rhythm without blocking roads, bridge or river.

The result is materially better than v0.238 and passes. It remains geometry-and-color-driven stylized low-poly art; bespoke textures, construction/damage states, animation, gameplay integration and final lighting polish remain outside this milestone.

Gameplay systems, saves, economy logic, selection, pathing, commands, minimap, objectives, production logic, AI, collision, browser runtime, runtime-art slots and launcher defaults were untouched.

Stop after v0.239. Do not begin v0.240.
