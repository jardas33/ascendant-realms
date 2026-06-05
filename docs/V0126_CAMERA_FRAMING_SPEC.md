# v0.126 Camera Framing Spec

v0.126 improves the Godot 2.5D fixed-camera review slice without changing gameplay rules or requiring routine editor work.

## Camera Contract

- Mode: `2_5D_ORTHOGRAPHIC_PLACEHOLDER`.
- Default preset: `CLEAN_READABILITY` with restrained atmospheric cues.
- Default zoom: `10.8`.
- Safe zoom bounds: `8.8` to `13.8`.
- Default angle: improved fixed orthographic pitch at `-60` degrees.
- Pan bounds are script-defined and clamped.
- The battlefield frame avoids giant unused margins and board-game slab posture.
- HUD and minimap remain inside safe review margins.
- Objective focus and recenter hooks are script-owned helpers.

## Capture Proof

The v0.126 capture path records default camera, objective focus, camera min zoom, and camera max zoom screenshots. The generated `camera-framing-report.json` verifies viewport coverage, zoom bounds, pan bounds, HUD-safe frame, objective focus, and recenter availability.

Current generated status: `PASS_V0126_CAMERA_FRAMING`.

The camera work remains placeholder-only and does not approve a production camera, final Godot choice, or desktop port.
