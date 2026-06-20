# v0.240 Barrosan Playable Art Integration Lane

Verdict: `PASS`

## Outcome

v0.240 maps the retained v0.239 Barrosan building roster into one explicit opt-in Godot review/runtime lane. It demonstrates completed buildings at game scale with review-only selection rings, role labels, footprint fills, collision shapes, valid/blocked placement examples and Worker/Militia/Aster scale probes.

This milestone changes presentation integration only. It does not wire the art into gameplay entities or alter build, selection, collision, pathing, production, economy, AI, save, minimap, objective, command, browser-runtime or default-launcher behavior.

## Asset facts

- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused: yes.
- v0.239 GLB superseded or modified: no.
- Reused GLB: `desktop-spikes/godot-salto/assets/v0239/salto_barrosan_roster_silhouette_beauty.glb`.
- Reused GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Scene: `res://scenes/salto_barrosan_playable_art_integration.tscn`.
- Runtime mapping: `res://data/v0240_barrosan_playable_art_mapping.json`.
- Review pack: `artifacts/manual-review/v0240-barrosan-playable-art-integration/`.

## Runtime role mapping

| Gameplay role | v0.239 module | Review name |
| --- | --- | --- |
| Main base / keep | `keep_landmark` | Command Keep |
| House / population | `house_dwelling` | Barrosan House |
| Farm / food economy | `farm_granary` | Granary Farm |
| Lumber / construction economy | `lumber_carpenter_yard` | Carpenter Yard |
| Blacksmith / upgrades | `blacksmith_forge` | March Forge |
| Barracks / military production | `barracks_workshop_landmark` | Restored Barracks |
| Mine / Lume resource | `mine_lume_landmark` | Lume Mine |
| Watchtower / defense | `watchtower_defense` | March Watchtower |
| Market / logistics | `market_storehouse` | Frontier Market |

Missing or placeholder roles: none within the nine-role v0.240 contract.

## Selection, footprint and scale checks

- Selection readability: passed. Nine rings are visible; gold identifies selected review examples and teal identifies selectable buildings.
- Footprint readability: passed. Nine completed-building footprints plus valid and river-blocked placement examples are visible.
- Collision sanity: passed for review purposes. Nine review-only `StaticBody3D` box bounds match the displayed footprints.
- Unit-relative scale: passed. Worker, Militia and Aster probes remain much smaller than buildings while doors, yards, roads and the bridge stay credible at RTS scale.
- Tactical readability: passed. The road network, bridge crossing and river remain readable in overview and cluster cameras.
- Construction-state integration: out of scope. The current safe architecture does not justify faking construction or placement-ghost gameplay; v0.240 proves completed-placement presentation only.

## Retained art checks

The v0.239 role language remains intact: blacksmith chimney and soot mass, open lumber yard, market awning, watchtower verticality, farm/granary storage cues and calm domestic house silhouette. No roof, role silhouette or material simplification was made.

## Exact source files changed

- `desktop-spikes/godot-salto/data/v0240_barrosan_playable_art_mapping.json`
- `desktop-spikes/godot-salto/scenes/salto_barrosan_playable_art_integration.tscn`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_art_integration.gd`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_art_integration.gd.uid`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0240BarrosanPlayableArtIntegrationReviewPack.py`
- `tools/godot/captureGodotV0240BarrosanPlayableArtIntegrationWindows.ps1`
- `tools/godot/saltoV0240BarrosanPlayableArtIntegrationTool.mjs`
- `tools/godot/validateGodotV0240BarrosanPlayableArtIntegrationWindows.ps1`
- `package.json`
- `docs/V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_REPORT.md`
- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`

The Barrosan art bible did not require a change; v0.240 applies its existing silhouette and readability rules without adding new faction-art doctrine.

## Validation

- Exact v0.240 capture and review-pack assembly: passed.
- Exact v0.240 runtime/mapping/review-pack validation: passed.
- `npm test`: passed, 887 tests across 122 files.
- `npm run build`: passed.
- `npm run validate:content`: passed.
- `npm run validate:art-intake`: passed.
- `npm run validate:runtime-art-slots`: passed, 52 slots retained.
- `npm run godot:all`: passed outside the filesystem sandbox; the sandboxed attempt could not write the Godot runtime report.
- Retained v0.236, v0.237, v0.238 and v0.239 exact validators: passed.
- Experimental-artifact retention and cleanup dry run: passed.
- `git diff --check` and exact pushed-SHA CI are recorded at final closeout.

## Brutally honest visual assessment

The authored roster survives the move to game-scale presentation. Keep, barracks and mine remain strong landmarks; all six support roles retain distinct silhouettes; rings and footprints read without burying the roads, bridge or river. The weak point is intentionally the review layer: the labels and translucent fills are utilitarian debug communication, not production selection UI. The buildings also have no construction, damage or faction-state variants.

This is ready for a broader opt-in gameplay-integration experiment. It is not ready to replace the default runtime presentation.

Stop after v0.240. Do not begin v0.241.
