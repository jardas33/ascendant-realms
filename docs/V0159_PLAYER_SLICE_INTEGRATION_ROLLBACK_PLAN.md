# V0159 Player-Slice Integration Rollback Plan

Status: rollback plan for the future v0.160 Worker-only opt-in experiment. v0.159 does not integrate art and has nothing runtime-facing to roll back.

## Default Safety Posture

The default player-facing launchers must remain procedural:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`.
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.

Future v0.160 must add only a separate opt-in launcher. If the opt-in path fails, the procedural Worker fallback remains the supported review path.

## Immediate Rollback For Future v0.160

If future v0.160 fails any acceptance gate:

1. Remove or disable `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
2. Remove the opt-in dispatch flag and Worker art adapter references added in v0.160.
3. Preserve procedural Worker fallback behavior.
4. Leave ignored local candidate files untracked.
5. Run the default player-slice validation and capture commands to prove the ordinary Salto slice still works.
6. Run boundary scans for browser wiring, production manifests, packages, saves, stable IDs, and second-slot references.
7. Commit only the rollback if it is needed.

## Files That Must Not Need Rollback

If future v0.160 follows the contract, rollback must not require changes to:

- Browser runtime files.
- Production art-slot manifests.
- Save schemas.
- Stable-ID registries.
- Gameplay rules.
- Campaign content.
- Default player-facing launchers.
- Ordinary package metadata.

## Review Closeout

After rollback or a successful opt-in proof, the work must stop for Emmanuel review. Do not continue into a second slot without a new bounded goal.
