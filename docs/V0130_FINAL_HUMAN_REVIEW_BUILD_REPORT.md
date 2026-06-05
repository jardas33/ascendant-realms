# v0.130 Final Human Review Build Report

Status: prepared for v0.130 human review after scripted validation and capture. The generated acceptance gate reports `SALTO_VERTICAL_SLICE_REVIEW_READY`.

## One-Click Paths

- Launch review slice: `GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Validate review slice: `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Capture review pack: `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat`
- Private engineering harness: `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat`

Default review path:

```text
title -> briefing -> microloop -> Results
```

The private harness remains separate and is not the default human-review path.

## Artifact Pack

The v0.130 review pack is generated under:

```text
artifacts/desktop-spikes/godot-salto/v0130/
```

Expected files:

- `validation.json`
- `acceptance-gate.json`
- `performance-smoke.json`
- `objective-flow.json`
- `screenshot-manifest.json`
- `screenshot-hashes.json`
- `package-report.json`
- `scorecard-update.json`
- `README.md`
- `contact-sheet.svg`

Expected captures: title, briefing, battle default, hero, Worker, mine, quarry, build, Barracks, recruit, pressure wave, Lume, minimap, Results, and private harness separate proof.

## Scope Notes

This build uses procedural placeholder presentation only. It does not import artwork, generate images, integrate runtime art, change browser runtime, change saves, change stable IDs, choose Godot finally, or start a full port.
