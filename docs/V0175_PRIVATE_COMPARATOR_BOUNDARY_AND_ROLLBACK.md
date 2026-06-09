# v0.175 Private Comparator Boundary And Rollback

Status: `PASS_V0175_GROUND_MATERIAL_BOUNDARY`

v0.175 is a private-comparator terrain-material intake only. It does not import terrain material into the normal Godot Salto player slice, does not add a runtime-art slot, does not enable art by default, and does not wire any browser runtime path.

## Files In Scope

Tracked private comparator files:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ground_material_single_slot_comparator.gd`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.png`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.contract.json`
- `tools/godot/groundMaterialSingleSlotTool.mjs`
- `tools/godot/runGodotGroundMaterialFallbackReproducibility.ps1`
- `tools/godot/runGodotGroundMaterialDerivatives.ps1`
- `tools/godot/runGodotGroundMaterialValidation.ps1`
- `tools/godot/runGodotGroundMaterialAudit.ps1`
- `tools/godot/runGodotGroundMaterialBenchmarkWindows.ps1`
- `tools/godot/captureGodotGroundMaterialWindows.ps1`

Ignored local source and derivatives:

- `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/`

Required evidence:

- `artifacts/desktop-spikes/godot-salto/v0175/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run/`

## Fallback Posture

The tracked diagnostic fallback is deterministic and comparator-only:

- File: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_foothold_ground_material_v0175_fallback.png`
- SHA-256: `d44345b1dd1588c92e9ce0f5bcb6a8711e9b65ad089b6b8f89df9e0b90039d28`

Fallback exists to prove comparator behavior and benchmark fairness. It is not a player-slice placeholder and is not production art.

## Isolation Checks

Validated boundaries:

- Private comparator only: true.
- Runtime art slot added: false.
- Terrain material imported to player slice: false.
- Player-slice integration: forbidden.
- Browser runtime changed: false.
- Default launcher procedural: true.
- Production package included: false.

## Rollback

Rollback is narrow because v0.175 does not touch the normal player-facing art path. To remove the private comparator checkpoint, revert the v0.175 commit or remove only the tracked comparator/fallback/tooling/docs added by this checkpoint. The default launcher, prior opt-in launchers, five selected character/material slots, browser runtime, saves, stable IDs, gameplay rules, and production manifests do not need rollback work because v0.175 did not modify them.

The selected derivative remains local human-review evidence. Do not delete it during cleanup unless a later prompt explicitly supersedes or archives v0.175 terrain-material evidence.
