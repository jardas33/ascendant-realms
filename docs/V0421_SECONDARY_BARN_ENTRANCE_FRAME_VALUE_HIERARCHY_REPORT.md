# v0.421 Secondary-Barn Entrance-Frame Value Hierarchy

## Scope and baseline

This is one opt-in, material-only calibration of the existing three-piece secondary-barn entrance frame. It starts from `de4e5c25d9e42d5d4cf2c7358741a961ffd3f468` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.420 chain and pre-existing untracked artifact backlog are preserved.

The exact admitted inventory is `V0399_Barn_Door_Left_Post`, `V0399_Barn_Door_Right_Post` and `V0399_Barn_Door_Lintel`. The accepted `V0399_Barn_Entrance_Door` leaf is separately identified and excluded.

## Candidate and preservation

The candidate is `V0421_Secondary_Barn_Entrance_Frame` with albedo `#65503e`, roughness `0.96`, specular `0.08`, and inherited vertex-colour albedo disabled. All three frame components share the same restrained material. The door, wall, gable, stone base, contact shadow, wider timber, geometry, UVs, transforms, layout, camera, lighting, gameplay and runtime semantics remain unchanged.

If the exact three-node boundary cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_ENTRANCE_FRAME` and retains no candidate.

## Evidence and validation

The capture path writes matched wide/close colour and grayscale views, a non-black diagnostic naming both posts, the lintel and the excluded door leaf, and v0.420/v0.421 comparisons. Real captures must show the frame as a coherent warm timber group, clearly surrounding the door without a bright outline, material bleed, detached lintel or competition with the façade.

Commands:

- `npm run godot:smoke:v0421-secondary-barn-entrance-frame`
- `npm run godot:capture:v0421-secondary-barn-entrance-frame`
- `npm run godot:validate:v0421-secondary-barn-entrance-frame`

The review pack is `artifacts/manual-review/v0421-secondary-barn-entrance-frame-value-hierarchy/` and contains seven real rendered captures plus `v0421-preservation-audit.json`. The real colour, grayscale, diagnostic and matched comparison renders were inspected before acceptance. The dedicated v0.421 validator, retained v0.420-v0.400 ladder including fail-closed gates, full tests/build/content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check` are green.

## Final closeout

Implementation commit: `55d24607f2edf848396616bfb5a47b86d26fdcb5`.

Implementation exact GitHub Actions run: `30409768011` - `CI Release Matrix Dry Run` - success.

The final repository remains a clean tracked tree synchronized with `origin/codex/v0215-v0226-recovery`; the pre-existing untracked artifact backlog is preserved and not staged.
