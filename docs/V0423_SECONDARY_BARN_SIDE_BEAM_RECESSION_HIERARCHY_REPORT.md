# v0.423 Secondary-Barn Side-Beam Recession Hierarchy

## Scope and baseline

This is one opt-in, material-only calibration of the two existing secondary-barn side structural beams. It starts from `5a74f257d582d6b1adcce4bf17dae23737d92621` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.422 chain and pre-existing untracked artifact backlog remain preserved.

The admitted inventory is exactly `V0399_Barn_Side_Beam_-1_8` and `V0399_Barn_Side_Beam_1_8`. The v0.422 front beam/posts, v0.421 entrance frame, ridge beam and eaves are separately classified and excluded.

## Candidate and preservation

The candidate is `V0423_Secondary_Barn_Side_Structural_Timber` with albedo `#524235`, roughness `0.98`, specular `0.06`, and inherited vertex-colour albedo disabled. Both beams share identical parameters. The target is a quieter, slightly recessed side pair subordinate to the accepted v0.422 front structural group.

The change is material-only. Geometry, topology, indices, vertices, surfaces, UVs, transforms, AABBs, dimensions, placement, grounding, camera, lighting, shadows, layout, gameplay and runtime semantics remain unchanged. If the exact two-node boundary cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_SIDE_BEAMS`.

## Evidence and validation

The capture path writes matched wide/close colour and grayscale views, a non-black diagnostic naming both side beams and excluded front/ridge/eave nodes, and v0.422/v0.423 comparisons. The primary frame is the unchanged gameplay-context view. The close colour/grayscale and diagnostic frames use a temporary capture-only context isolation that hides unrelated `GeometryInstance3D` nodes, leaving the existing secondary-barn shell and the two candidate beams visible; visibility is restored before the baseline comparison, diagnostic completion, and process exit. No runtime geometry, scene placement, or gameplay state is changed by that capture framing.

Required real evidence is stored in `artifacts/manual-review/v0423-secondary-barn-side-beam-recession-hierarchy/`:

- `01_PRIMARY_RTS_COLOUR.png`
- `02_SECONDARY_BARN_SIDE_BEAMS_CLOSE_COLOUR.png`
- `03_PRIMARY_RTS_GRAYSCALE.png`
- `04_SECONDARY_BARN_SIDE_BEAMS_CLOSE_GRAYSCALE.png`
- `05_TEMPORARY_BARN_SIDE_BEAM_NODE_ID.png`
- `06_V0422_V0423_WIDE_COMPARISON.png`
- `07_V0422_V0423_SIDE_BEAMS_CLOSE_COMPARISON.png`
- `v0423-preservation-audit.json`

Commands:

- `npm run godot:smoke:v0423-secondary-barn-side-beams`
- `npm run godot:capture:v0423-secondary-barn-side-beams`
- `npm run godot:validate:v0423-secondary-barn-side-beams`

The validator asserts the exact two-beam inventory, material-only preservation, excluded front/entrance/ridge/eave groups, real evidence dimensions, candidate parameters, and fail-closed behavior. Retained v0.422-v0.400 validation and full repository checks are run before closeout.

Human inspection accepted the evidence set: `01_PRIMARY_RTS_COLOUR.png` is a non-black wide RTS frame containing the river, bridge, main house, secondary barn, units, and props; `02_SECONDARY_BARN_SIDE_BEAMS_CLOSE_COLOUR.png` is a non-black context-isolated barn view where the side structural pair is readable; `05_TEMPORARY_BARN_SIDE_BEAM_NODE_ID.png` highlights the two admitted nodes in cyan while keeping the excluded front structure distinct; and both comparison frames are non-black and directly comparable.

The dedicated validator passed with the exact result `PASS_V0423_SECONDARY_BARN_SIDE_BEAM_RECESSION_HIERARCHY_VALIDATOR (material-only candidate; 2 side beams; front structure, entrance frame, ridge and eaves excluded; 7 real captures)`. The retained validator ladder passed for v0.422, v0.421, v0.420, v0.419, v0.418, v0.417, v0.416, v0.415, v0.414, v0.413, v0.412, v0.411, v0.410, v0.409, v0.408, v0.407, v0.406, v0.401, and v0.400. v0.416, v0.415, v0.410, and v0.409 retained their accepted fail-closed limitation results.

Full local validation passed: `npm test` (887 tests), `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run validate:runtime-art-slots`, `npm run validate:artifact-retention`, `npm run godot:all`, and `git diff --check`.

## Closeout

Implementation commit and exact-SHA GitHub Actions evidence are recorded in the final closeout update after the explicit v0.423 files and review pack are committed and pushed. The final tracked repository state must be clean and synchronized with `origin/codex/v0215-v0226-recovery`; the pre-existing untracked artifact backlog is intentionally preserved and is not part of this checkpoint.
