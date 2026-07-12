# v0.304 Recommended Target Selection

## Target

Use **v0.141 R1** as the primary visual target, with **R2** supplying restrained Barrosan material and atmosphere guidance. Use **R3** only for lane hierarchy and Ashen-edge contrast, excluding its technological Lume pylons, energy-beam infrastructure, crystal-tower language and spectacle. Use the v0.236 authored slice as the technical geometry/pipeline seed, not as the visual ceiling.

The target is an original, readable Barrosan highland battlefield: wet stone and worked earth, timber-and-stone structures, clear bridge/ford crossings, open build areas, practical roads, restrained atmosphere, and strong role silhouettes. The references are style direction, not source textures or runtime assets.

## Route scorecard

Scores are 1–5, where 5 is favorable. “Asset burden” and “animation burden” are scored as lower burden = higher score.

| Route | Visual quality | Match R1 | Feasibility | Asset burden | Animation burden | Risk | Performance | Validation | Maintainability | Future faction contrast | Time to credible slice |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A — recover/integrate approved sprites or references | 3 | 4 | 2 | 2 | 3 | 2 | 4 | 2 | 2 | 3 | 2 |
| B — true Godot 2.5D sprites with elevation/depth sorting | 4 | 4 | 3 | 3 | 2 | 3 | 4 | 4 | 4 | 4 | 3 |
| C — low-poly 3D environment + billboard/sprite units | 5 | 5 | 4 | 3 | 4 | 4 | 4 | 5 | 5 | 5 | 4 |
| D — full low-poly 3D | 5 | 5 | 2 | 1 | 1 | 2 | 3 | 3 | 3 | 5 | 1 |
| E — continue procedural 2D layering | 2 | 1 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 2 | 5 |

## Recommendation

Choose **Route C**. It follows the strongest repository evidence: Godot orthographic 3D works, the Blender-to-GLB pipeline is real and reproducible, v0.236 already proves the needed environment vocabulary, and billboard units can preserve tactical readability while avoiding a full animation burden. It is more likely to reach an attractive playable vertical slice than continued procedural layering, without committing the project to full 3D character production.
