# v0.369 Visual Direction Reset Sandbox — Asset Gap Blocker

Status: **BLOCKED — no visual target sandbox accepted**

Base HEAD: `69b7a756dcd5525d1d4caeab93881c56b93236b8`

Branch: `codex/v0215-v0226-recovery`

## Decision

The v0.369 Route C sandbox was prototyped against the strongest available
repository-authored family, then rejected after direct rendered inspection.
No v0.369 sandbox route, launcher, capture pack, or production-art claim is
being retained.

## Asset gate attempted

The attempted family was:

- `desktop-spikes/godot-salto/assets/v0340/barrosan_secondary_environment_kit.glb`
- `desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb`
- repository-authored true-3D worker and militia construction helpers from
  `desktop-spikes/godot-salto/scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd`

The source family is compatible in material palette and basic low-poly
language, but it does not satisfy the v0.369 visual gate as a representative
playable RTS sector.

## Rendered rejection findings

The raw three-view trial was inspected at wide, gameplay, and close-detail
framing. The result visibly failed these required constraints:

1. Large flat terrain slabs dominate the composition.
2. The road reads as a light rectangular strip rather than an embedded
   natural path.
3. Secondary structures and the bridge approach remain generic block masses.
4. Vegetation and environmental dressing are too sparse to establish a lived
   village edge or coherent asset family.
5. The units are technically authored 3D silhouettes, but their scale and
   presentation still read as debug-like tokens beside the environment.

The House 02 anchor improved the primary building, but did not repair the
terrain, path, secondary-building, or density failures. The rendered result
therefore does not meet the brief's bar of a commercially presentable
stylized RTS visual target.

## Scope safety

The trial was isolated and then removed. The accepted v0.368 gameplay scene,
fallback route, default runtime, gameplay state, stable IDs, saves, and
mechanics were not changed. No v0.369 review pack is claimed because the
required raw renders were rejected rather than promoted as evidence.

## Required asset gap before retry

Provide or author a small coherent production-quality family containing:

- one irregular terrain patch with natural bank transitions, not tiled slabs;
- one embedded dirt/stone path and a scaled bridge approach;
- one primary human Barrosan building plus one secondary building in the same
  authored family;
- natural river-edge dressing and a denser but restrained prop set;
- human unit art whose silhouette and scale hold up at gameplay distance;
- a matching material/lighting treatment across terrain, buildings, bridge,
  props, and units.

Until that family exists, the safest next action is to remain on the accepted
v0.368 mechanical reference and do not package a Route C visual target.
