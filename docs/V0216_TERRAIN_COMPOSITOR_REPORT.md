# v0.216 Terrain Compositor Report

Status: PASS

v0.216 binds the selected Barrosan foothold terrain material only through the isolated Salto presentation-reboot launcher. It leaves the default procedural launcher and all prior launchers unchanged.

## Runtime Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoTerrainMaterialProductionWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoTerrainMaterialProductionWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoTerrainMaterialProductionBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoTerrainMaterialProductionTool.mjs`

## Compositor Notes

- The selected material is applied through the existing shell-v2 mesh compositor rather than broad rectangular static pads.
- Runtime status records `terrainMeshCompositor=true`, `irregularPlayableAreaSilhouette=true`, `v0216IrregularPatchCount=4` and `v0216EdgeTreatmentCount=6` for the selected path.
- The selected derivative uses UV scale `0.48` and alpha `0.24` to keep terrain detail visible without making the RTS overview too noisy.
- The procedural fallback remains visible and fail-closed when the selected material is missing or hash-mismatched.
- The previous v0.175 ground material remains available as a comparator through a private marker argument.

## Visual Outcome

The repaired v0.216 derivative reduces the flat green prototype read without turning the battlefield into a high-frequency texture sheet. The terrain still reads subdued compared with roads, river, bridge, structures, character billboards and markers.

The fallback comparison confirms that:

- selected terrain loads with SHA `8049b692b5d89d9abf5da39a79a31d8609ceb944dcb5695af8efc8553cd1eea3`;
- hash mismatch fails closed to the procedural presentation;
- missing art fails closed to the procedural presentation;
- the previous v0.175 material can still be launched as comparator evidence.

## Boundaries

- Generated images: exactly one source image.
- Downloaded assets: zero.
- New production art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.
