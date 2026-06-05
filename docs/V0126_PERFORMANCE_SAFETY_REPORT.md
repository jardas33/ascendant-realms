# v0.126 Performance Safety Report

v0.126 keeps performance evidence non-final and tied to the existing Godot player-slice workflow.

## Benchmarked Surfaces

- Default camera.
- Zoomed-out camera.
- Authored terrain.
- Tier M objective loop.
- One pressure wave.
- Lume activation.
- Minimap.

## Recorded Fields

The generated report at `artifacts/desktop-spikes/godot-salto/v0126/performance-safety-report.json` records:

- `fpsAverage`
- `frameTimeP95Ms`
- `stuckUnits`
- `launchPosture`
- `packageSizeMb`

Current generated evidence:

- Status: `PASS_V0126_PERFORMANCE_SAFETY`
- FPS average: `74.9`
- p95 frame time: `13.38 ms`
- Stuck units: `0`
- Launch posture: player-facing packaged Windows slice by default, private harness through explicit launcher.
- Package size: `34.528 MB`

The launch posture remains the player-facing packaged Windows slice by default, with the private harness available only through its explicit launcher. The report keeps `finalProductionCertification` false.

## Boundary

This is not a production performance certification, final engine approval, browser replacement, or full port. No saves, stable IDs, gameplay rules, imported art, generated images, or routine editor steps are introduced.
