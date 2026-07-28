# v0.412 Bridge Understructure Value-Hierarchy Calibration

## Scope

v0.412 is an opt-in, material-only calibration of the complete live inventory of existing bridge underbeams and edge-course components. The accepted v0.411 bridge deck and rail/post calibration remain the baseline; both accepted bridge landings remain unchanged.

## Base and preservation

- Base commit: `7f73ded8743f415392f2eea2d08cfa4578432728`
- Branch: `codex/v0215-v0226-recovery`
- Runtime: opt-in Salto bridge presentation only
- Default runtime, fallback renderer, and debug renderer: unchanged
- Gameplay/state/route/terrain/river/buildings/barn/characters/props/camera/lighting: unchanged

Before applying the candidate, the runtime dynamically inventories every existing visible MeshInstance3D under the accepted bridge world whose name identifies it as `UNDERBEAM` or `EDGE_COURSE`. The audit records each node, functional class, original material, UV count, snapshots, hashes, and final material.

## Material treatment

Only existing `Bridge_*Underbeam*` and `Bridge_*EdgeCourse*` nodes are assigned compatible flat structural materials. Underbeams use a restrained dark brown (`#43342a`, roughness 0.94, specular 0.10); edge courses use an intermediate timber-earth value (`#6a513a`, roughness 0.92, specular 0.14). Both disable inherited vertex-colour-as-albedo influence. No texture or UV dependency is introduced.

The intended hierarchy is deck walking surface, edge course boundary, darker underbeam support, accepted v0.411 upper rails/posts, then warm earth landings. The understructure remains lighter than near-black and the edge course does not read as a landing or a brighter deck replacement.

## Evidence

The review pack at `artifacts/manual-review/v0412-bridge-understructure-value-hierarchy/` contains real rendered wide and close colour views, corresponding grayscale views, a temporary node-ID diagnostic, v0.411/v0.412 wide and close comparisons, and `v0412-preservation-audit.json`. The diagnostic is temporary capture instrumentation only and is not part of the active presentation.

Required real captures:

1. `01_PRIMARY_RTS_COLOUR.png` — layered crossing in the RTS view.
2. `02_BRIDGE_UNDERSTRUCTURE_CLOSE_COLOUR.png` — deck, edge, underbeams, accepted rails/posts, footings, and landings.
3. `03_PRIMARY_RTS_GRAYSCALE.png` — wide value hierarchy.
4. `04_BRIDGE_UNDERSTRUCTURE_CLOSE_GRAYSCALE.png` — close value separation.
5. `05_TEMPORARY_UNDERBEAM_EDGECOURSE_ID.png` — every affected live node and class.
6. `06_V0411_V0412_WIDE_COMPARISON.png` — accepted v0.411 versus v0.412.
7. `07_V0411_V0412_CLOSE_COMPARISON.png` — accepted v0.411 versus v0.412 close.

## Fail-closed rule

If either functional class is absent, the live inventory is incomplete, or the components cannot be isolated without touching forbidden geometry/materials, the validator records `ASSET_MATERIAL_LIMITATION_BRIDGE_UNDERSTRUCTURE`, retains no candidate, and preserves the prior accepted runtime.

## Validation

- Dedicated validator: `node tools/godot/saltoV0412BridgeUnderstructureValueHierarchyTool.mjs validate`
- Smoke/capture commands: `npm run godot:smoke:v0412-bridge-understructure` and `npm run godot:capture:v0412-bridge-understructure`
- Retained v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401, and v0.400 validators
- Full tests, build, content, art-intake, runtime-art-slot, artifact-retention, `npm run godot:all`, and `git diff --check`

The preservation audit explicitly records `materialOnly: true`, geometry/topology/index/vertex/surface/transform/AABB preservation, zero new MeshInstance3D nodes, no overlays/decals/duplicate meshes, unchanged bridge/deck/rail/post/footing/landing/route hashes, and unchanged gameplay/default/fallback/debug behavior.

## Closeout

The candidate is retained only when real colour and grayscale captures satisfy the layered-bridge criteria. No v0.413 work begins in this checkpoint.
