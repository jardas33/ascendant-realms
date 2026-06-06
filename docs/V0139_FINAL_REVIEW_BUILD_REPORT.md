# v0.139 Final Review Build Report

Status: stabilized human-review package path only. No art generation or runtime-art import.

## Launchers

v0.139 adds three root-level Windows launchers:

- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`
- `GODOT_VALIDATE_STABILIZED_SALTO_REVIEW_WINDOWS.bat`
- `GODOT_CAPTURE_STABILIZED_SALTO_REVIEW_WINDOWS.bat`

The launch wrapper opens the packaged player-facing Salto slice. The validate/capture wrappers refresh the existing packaged evidence surfaces and generate the v0.139 review pack.

## Review Pack Outputs

The ignored v0.139 pack is generated under:

`artifacts/desktop-spikes/godot-salto/v0139/`

Required outputs:

- `gate.json`
- `triple-playthrough.json`
- `usability.json`
- `performance.json`
- `screenshot-manifest.json`
- `screenshot-hashes.json`
- `package-report.json`
- `scorecard-update.json`
- `README.md`

## Evidence Sources

The v0.139 pack consolidates these existing proof lanes:

- v0.134 triple natural playthrough, recovery, restart, no-softlock, and no-shortcut proof.
- v0.135 RTS controls, recoverable feedback, camera controls, compact help, and screenshots.
- v0.136 HUD, minimap, onboarding, pacing, and screenshots.
- v0.137 procedural blockout quality, screenshots, hashes, and bounded performance smoke.
- v0.120 fresh-checkout validation.
- Latest Windows package and scorecard artifacts.
- v0.138 reference-art workspace validation and review-pack status.

## Package Posture

The stabilized review launcher uses the packaged Godot player-facing slice. The package evidence is mirrored in `v0139/package-report.json` and points to the current ignored Windows package under `artifacts/desktop-spikes/godot-salto/latest/`.

Current package:

- Path: `artifacts/desktop-spikes/godot-salto/latest/AscendantRealmsGodotSalto-v0124-windows.zip`
- SHA-256: `0eef9ce8e415452166b31af0722e02db68faad9b2a4d4a90c4599c0291406f92`
- Size: `34.711 MB`

This report does not approve Godot finally and does not convert reference art into runtime art.
