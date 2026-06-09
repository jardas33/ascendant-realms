# v0.181 Road Material Boundary Rollback

Status: `PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY`

v0.181 adds exactly one player-facing environment-material opt-in slot for the selected Barrosan foothold road material. It does not add character slots, does not generate images, does not enable art by default, and does not wire anything into the browser runtime.

## Boundary

Confirmed:

- Default launcher remains procedural.
- Existing Worker, Worker + Barracks, Worker + Barracks + Militia, Worker + Barracks + Militia + Aster, five-slot, environment-foundation, environment-readability, environment-contrast, and ground-material launchers remain preserved.
- Character-slot integrations remain frozen at five.
- The selected road material loads only under `--road-material-opt-in`.
- Road material applies only to the three authorized road-bed surfaces.
- Ground material remains the existing explicit opt-in environment slot.
- Missing-art and hash-mismatch road fallbacks keep ground and character slots active while reverting roads to procedural visuals.

New launchers:

- `GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat`

## Rollback

To return to the v0.180 posture, revert only the v0.181 checkpoint commit.

Rollback removes:

- `--road-material-opt-in` player-slice handling.
- The new ground + road opt-in launch, review, validate, capture, and report tooling.
- Road-material overlay binding on player-facing road-bed meshes.
- v0.181 docs and artifact-index updates.

Rollback does not affect:

- The v0.180 private road-material comparator source, derivatives, fallback, and evidence.
- Existing ground-material opt-in launcher and validation path.
- Existing character opt-in launchers.
- Browser runtime.
- Default procedural launcher.

## Cleanup

Preserve:

- `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/`
- `artifacts/desktop-spikes/godot-salto/v0181/validation/`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/`
- `artifacts/desktop-spikes/godot-salto/v0181/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0181/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0181/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0181/artifact-retention/`

Delete only positively identified safe transient residue through the existing safe-only cleanup path after human approval.
