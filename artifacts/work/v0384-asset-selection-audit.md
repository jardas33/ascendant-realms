# v0.384 asset-selection audit

## Scope

This audit covers the isolated first inhabited crossing target only. The accepted v0.380 GLB remains read-only and no bulk third-party import was added.

## Primary-building candidates inspected

| Candidate | Decision | Reason |
|---|---|---|
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Corner_ExteriorWide_Wood.gltf` | Reject | A modular corner fragment, not a complete homestead; would require an assembly pass and risks the v0.371 disconnected-block read. |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Corner_Exterior_Wood.gltf` | Reject | Smaller fragment with no complete roof/entrance relationship at the target camera. |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Wall_Plaster_WoodGrid.gltf` | Reject | Wall module only; not a truthful primary building candidate. |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Roof_RoundTiles_6x10.gltf` | Reject | Roof-only module; direct use would create a pasted-on roof without a coherent base. |

Selected primary: scene-local authored low-poly Barrosan roadside homestead in `desktop-spikes/godot-salto/scripts/v0384_first_inhabited_crossing.gd`. It provides one stable silhouette, foundation, door, windows, roof planes, ridge, chimney, and stairs without importing a large unapproved asset or mixing incompatible modular scales.

## Subordinate candidates inspected

| Candidate | Decision | Reason |
|---|---|---|
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Prop_Wagon.gltf` | Prop only | Useful yard dressing, not a subordinate structure. |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Floor_WoodDark.gltf` | Reject | Floor fragment with no shelter volume. |
| `external-art-intake/quaternius/medieval-village-megakit/glTF/Overhang_Roof_Plaster.gltf` | Reject | Roof fragment with no complete shelter or entrance. |

Selected subordinate: scene-local authored timber shed in the same script, deliberately smaller than the homestead and placed behind/beside the yard.

## Prop candidates and use

Inspected `external-art-intake/quaternius/fantasy-props-megakit/Exports/glTF/Barrel.gltf`, `Crate_Wooden.gltf`, `Stall_Cart_Empty.gltf`, and `Workbench.gltf`. The final prototype uses scene-local proxy equivalents for the visible cart, barrel, crate, firewood, trough, and fence grouping so that the composition remains deterministic and provenance is explicit. No bulk prop import was added.

## Temporary-human candidates inspected

Inspected `external-art-intake/quaternius/ultimate-modular-men/Individual Characters/glTF/Adventurer.gltf`, `Farmer.gltf`, and `Worker.gltf`. They were not imported into the prototype because the target requires exactly three static, grounded figures and the existing imported family has previously produced scale/style ambiguity in this crossing. The final scene uses three authored low-poly static human proxies with explicit roles and no locomotion or unit logic.

## Provenance and boundary

The accepted infrastructure source remains `external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb`, with the imported runtime copy retained unchanged. v0.384 adds only authored scene-local geometry and materials; it does not modify the accepted GLB, default runtime, or gameplay systems.
