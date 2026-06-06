# v0.137 Performance Safety Report

Classification: `BLOCKOUT_QUALITY_GREEN`

## Measured Windows

`GODOT_BLOCKOUT_QUALITY_WINDOWS.bat` / `npm run godot:headed:blockout-quality` records `artifacts/desktop-spikes/godot-salto/v0137/performance-smoke.json` for:

- default slice;
- combat peak;
- zoomed out;
- fog on;
- Lume pulse.

Each window records frame count, elapsed time, average frame time, estimated FPS, and `screenshotCaptureExcluded: true`. The screenshot capture excluded posture is explicit for measured windows, and this remains a bounded spike smoke, not final production performance certification.

Latest packaged smoke:

- `default_slice`: 79.27 FPS estimate, 12.61 ms average frame time.
- `zoomed_out`: 79.38 FPS estimate, 12.6 ms average frame time.
- `fog_on`: 74.89 FPS estimate, 13.35 ms average frame time.
- `combat_peak`: 75.01 FPS estimate, 13.33 ms average frame time.
- `lume_pulse`: 75.65 FPS estimate, 13.22 ms average frame time.

## Safety Boundaries

No browser performance claims, save changes, stable-ID changes, imported art, generated images, runtime art integration, full port, or final engine decision are made.
