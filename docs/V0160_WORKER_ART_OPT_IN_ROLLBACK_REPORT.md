# V0160 Worker Art Opt-In Rollback Report

Status: rollback posture for the opt-in experiment.

## Default Rollback

The default stabilized launcher remains procedural. If the opt-in experiment is rejected, no default player-facing review path needs to change.

Default procedural paths:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`

## Code Rollback

To remove the experiment later:

1. Delete the v0.160 opt-in launcher, validate, capture, and benchmark wrappers.
2. Remove the `--worker-art-*` argument handling from the Godot root script.
3. Remove `configure_worker_art_experiment` and Worker billboard rendering from the 2.5D scene.
4. Remove v0.160 package scripts and docs.
5. Keep the original procedural Worker silhouette path.

## Runtime Fallback

The shipped safety fallback is already built in. Missing source, hash mismatch, bad metadata, bad dimensions, image load failure, texture creation failure, or absent opt-in flag all return to the procedural Worker silhouette.

## Boundary

No ignored image is packaged into ordinary builds, no browser runtime is wired, no production manifest is mutated, and no second player-facing art slot is introduced.
