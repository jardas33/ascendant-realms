# v0.238 Barrosan Building Roster Expansion Report

Milestone verdict: `PASS`

Overall finish classification: coherent stylized low-poly production roster, not final hand-textured shipped environment art.

## Asset revision

- Blender used: yes, Blender 5.1.2.
- New Blender source: `art-source/blender/v0238/salto_barrosan_building_roster.blend` (532,963 bytes).
- New runtime GLB: `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb`.
- v0.238 GLB: 6,987,388 bytes; SHA-256 `76FA042C420F7A8ED0420E38208B188E4C9C41E89CE951E42EB6B01810338839`.
- Existing v0.237 GLB modified: no; retained size 5,132,168 bytes and SHA-256 `EC36A297C9D4B9E77AB8EEEF52435D0C7FC07D04551126FDA4BF5C42DF545528`.
- Isolated Godot scene: `res://scenes/salto_barrosan_building_roster.tscn`.
- Art-bible expansion: `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`.

## Exact implementation counts

- New building modules: 6.
- New prop modules: 8.
- New or changed material families: 10.
- Composed building instances: 9, comprising the retained keep, barracks/workshop and mine/Lume landmarks plus all six new roles.
- Composed role-prop instances: 15.
- Roster ground surfaces: 11.
- Square terrain modules placed: 0.
- Panel-style road modules placed: 0.
- Optional buildings authored: 0.

## Required roster

1. House/dwelling: compact domestic mass, porch, garden plot and restrained storage clutter.
2. Farm/granary: broader raised storage form, cultivated rows, sacks, hay and barrels.
3. Lumber/carpenter yard: open work canopy, saw bench, logs and plank stock.
4. Blacksmith/forge: dark forge masonry, chimney, hot brazier, anvil and ore cart.
5. Watchtower: the roster's strongest new vertical silhouette, while remaining subordinate to the keep.
6. Market/storehouse: broad public awning, open counter, goods and supply stall.

All six retain the Barrosan roof contract: the central ridge is the highest line, roof planes descend to both eaves, eaves overhang the walls, and ridge caps and fascia boards are separate readable construction.

## Exact authored source files

- `tools/blender/generate_v0238_barrosan_building_roster.py`
- `tools/blender/generateV0238BarrosanBuildingRosterWindows.ps1`
- `tools/godot/captureGodotV0238BarrosanBuildingRosterWindows.ps1`
- `tools/godot/validateGodotV0238BarrosanBuildingRosterWindows.ps1`
- `tools/godot/buildV0238BarrosanReviewPack.py`
- `tools/godot/saltoV0238BarrosanBuildingRosterTool.mjs`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_building_roster.gd`
- `desktop-spikes/godot-salto/scenes/salto_barrosan_building_roster.tscn`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `package.json`
- `docs/art/V0236_BARROSAN_FACTION_ART_BIBLE.md`

Generated versioned assets and metadata:

- `art-source/blender/v0238/salto_barrosan_building_roster.blend`
- `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb`
- `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb.import`
- `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.export.json`
- `desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.contract.json`

## Honest visual assessment

The full overview reads as a substantially more complete RTS settlement rather than a three-landmark demonstration or floating asset catalogue. The six additions share Barrosan materials and construction language, but role-specific massing and yards keep them distinguishable. The watchtower breaks the roofline, the forge chimney and hearth create a clear craft read, the lumber canopy and stock create an open work-yard silhouette, and the market awning forms a public frontage. The keep, barracks/workshop and mine/Lume still own their reserved civic, military and magical-extraction hierarchy.

The milestone therefore passes. The result remains a focused stylized low-poly production kit: bespoke texture maps, construction and damage states, final game integration, animation and final lighting polish remain outside v0.238.

## Evidence

Exact review pack:

`artifacts/manual-review/v0238-barrosan-building-roster/`

The optional `09` capture is intentionally omitted because no optional building was authored. The pack therefore contains the required eleven files: baseline, overview, six role close-ups, scale/readability capture, before/after sheet and candid report.

## Boundaries

Gameplay, saves, economy logic, selection, pathing, commands, minimap logic, objectives, production logic, AI, collision, browser runtime, runtime-art slots and default launcher remain unchanged.

Stop after v0.238. Do not begin v0.239.
