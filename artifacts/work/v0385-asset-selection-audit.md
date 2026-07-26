# v0.385 curated inhabited crossing asset-selection audit

## Decision

This isolated opt-in prototype uses existing authored or tracked repository assets. No scene-local primitive is used as the final primary building, subordinate building, prop, or character. The accepted v0.380 infrastructure GLB remains byte-for-byte unchanged.

## Primary building candidates

| Candidate | Decision | Reason |
|---|---|---|
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Corner_ExteriorWide_Wood.gltf` | rejected | façade fragment; no complete inhabited structure or reliable entrance read |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Corner_Exterior_Wood.gltf` | rejected | partial corner piece; unsuitable as the single primary homestead |
| `desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb` | inspected | viable historical Barrosan source, superseded by the material-gold candidate for this controlled slice |
| `desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb` | selected | complete Barrosan house silhouette with roof, granite walls, side volume, windows, and entrance |

## Subordinate-building candidates

| Candidate | Decision | Reason |
|---|---|---|
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Floor_WoodDark.gltf` | rejected | floor fragment, not a building |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Overhang_Roof_Plaster.gltf` | rejected | roof fragment without walls or entrance |
| `desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn` | selected | existing Barrosan agricultural structure with coherent roof/base treatment |

## Props and characters

Selected yard sources are `village/Prop_Wagon.gltf`, `props/Crate_Wooden.gltf`, `props/Barrel_Apples.gltf`, `props/Whetstone.gltf`, `village/Prop_Crate.gltf`, `village/Prop_WoodenFence_Single.gltf`, and `village/Prop_WoodenFence_Extension1.gltf` from the inspected Quaternius pack. Character sources inspected were `men/Farmer.gltf`, `men/Adventurer.gltf`, and `men/Worker.gltf`. The final composition uses Farmer once and Adventurer twice because the Worker origin/pose did not separate reliably at this camera; the role nodes remain Resident, Guard, and Traveller and are documented as a visual composition constraint, not gameplay identity.

## Provenance and isolation

Quaternius files are consumed from the tracked local intake under `external-art-intake/quaternius/` and the copied opt-in Godot asset root under `desktop-spikes/godot-salto/assets/third_party/quaternius/v0370/`. They are instantiated only by `v0385_curated_inhabited_crossing.gd`. No protected-game asset or bulk production-wide import is used.
