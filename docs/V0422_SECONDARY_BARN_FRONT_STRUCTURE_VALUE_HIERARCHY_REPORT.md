# v0.422 Secondary-Barn Front Structural-Timber Value Hierarchy

## Scope and baseline

This is one opt-in, material-only calibration of the existing secondary-barn front beam and two outer front posts. It starts from `a99345e18816a298d8a004f9fea78b247dafb1af` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.421 chain and pre-existing untracked artifact backlog are preserved.

The exact admitted inventory is `V0399_Barn_Front_Beam`, `V0399_Barn_Front_Post_-2_25` and `V0399_Barn_Front_Post_2_25`. The v0.421 entrance-frame posts and lintel, door leaf, windows, wall, gable and all other timber are separately identified and excluded.

## Candidate and preservation

The candidate is `V0422_Secondary_Barn_Front_Structural_Timber` with albedo `#594636`, roughness `0.97`, specular `0.07`, and inherited vertex-colour albedo disabled. The beam and both posts share the same restrained material. Geometry, UVs, transforms, silhouettes, openings, entrance frame, base, roof, shadows, layout, camera, lighting, gameplay and runtime semantics remain unchanged.

If the exact three-node boundary cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_FRONT_STRUCTURE` and retains no candidate.

## Evidence and validation

The capture path writes matched wide/close colour and grayscale views, a non-black diagnostic naming the beam, both posts and the excluded entrance frame, and v0.421/v0.422 comparisons. The inspected real captures show one coherent load-bearing timber group without a dark cage, bright outline, material bleed or dominance over the facade.

Inspected real evidence:

- `01_PRIMARY_RTS_COLOUR.png`: nonblank 1920x1080 gameplay-wide render with the secondary barn, bridge, river, roads, units and props visible.
- `02_SECONDARY_BARN_FRONT_STRUCTURE_CLOSE_COLOUR.png`: nonblank close render showing the front beam and two outer posts in context with the separately retained entrance frame.
- `03_PRIMARY_RTS_GRAYSCALE.png` and `04_SECONDARY_BARN_FRONT_STRUCTURE_CLOSE_GRAYSCALE.png`: value checks retain readable structure, stone and roof separation.
- `05_TEMPORARY_BARN_FRONT_STRUCTURE_NODE_ID.png`: nonblack audit image naming the three admitted nodes and three excluded entrance-frame nodes.
- `06_V0421_V0422_WIDE_COMPARISON.png` and `07_V0421_V0422_FRONT_STRUCTURE_CLOSE_COMPARISON.png`: matched, stable before/after comparisons with restrained visual change.

The review pack contains the same eight runtime artifacts, plus the v0.422 preservation audit. The audit records exactly three affected nodes, the exact material-only candidate, zero UVs on every affected mesh, unchanged mesh count, no geometry/topology/transform/AABB changes, no overlays/decals/duplicate meshes, and unchanged gameplay/default/fallback/debug behavior.

Commands:

- `npm run godot:smoke:v0422-secondary-barn-front-structure`
- `npm run godot:capture:v0422-secondary-barn-front-structure`
- `npm run godot:validate:v0422-secondary-barn-front-structure`

Retained validators passed explicitly: v0.421, v0.420, v0.419, v0.418, v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401 and v0.400. No dedicated v0.402-v0.405 package commands exist in the repository. The full local batch also passed `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`.

The review pack is `artifacts/manual-review/v0422-secondary-barn-front-structure-value-hierarchy/`. The candidate passed real-render inspection and the dedicated validator.

## Closeout evidence

- Implementation commit: `3f7bc3d42f3c7bd49f4cf7851099c8deb34aec5a`.
- Exact GitHub Actions run: `30412201507` — `CI Release Matrix Dry Run`, success for the implementation commit.
- The final documentation follow-up records this CI result without changing runtime scope.
