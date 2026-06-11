# v0.217 Road Riverbank Water Compositor Report

Status: PASS

v0.217 binds the selected road, riverbank, water and wet-edge material derivatives only through the isolated Salto presentation-reboot launcher. The default stabilized launcher remains procedural and browser runtime wiring remains untouched.

## Runtime Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoRoadRiverbankWaterWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoRoadRiverbankWaterWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoRoadRiverbankWaterBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoRoadRiverbankWaterTool.mjs`

## Compositor Notes

- The material bundle is loaded as a four-region hash-gated set; a missing or mismatched region fails the whole bundle closed to the procedural presentation.
- The selected path reported four loaded regions, four texture creations, four image decodes and 130 applied material surfaces in the benchmark manifest.
- Roads use the compacted road derivative with subdued warm dirt/gravel value, widened consistently against units and structures.
- Riverbanks use the mossy stone/earth edge derivative with restrained tinting to frame the channel without reading as opaque overlays.
- Water and wet-edge derivatives are tinted down for shallow muted water and damp-edge hierarchy rather than a flat cyan strip.
- Road-to-bridge approaches, bridge abutments and landing edges reuse the same bundle so the crossing reads as one material system.

## Fallbacks

Fallback validation passed for:

- default procedural path with no presentation reboot material request;
- selected v0.217 bundle;
- hash-mismatch fallback;
- missing-art fallback.

The selected benchmark averaged `75.54` FPS with p95 frame time `13.34` ms. Procedural fallback averaged `75.52` FPS with p95 frame time `12.51` ms. The selected p95 frame-time ratio was `1.066`.

## Boundaries

- Generated images: exactly one source atlas.
- Downloaded assets: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

Decision: selected. The material hierarchy improves road, riverbank, water and bridge-approach readability inside the presentation-reboot path without production-slot leakage.
