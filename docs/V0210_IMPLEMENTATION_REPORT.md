# v0.210 Implementation Report

Status: PASS.

## Changes

- Added `--salto-selection-command-panel` as an explicit opt-in flag layered on top of the v0.209 Salto UI shell experiment.
- Added a richer selected-context panel for Aster, Worker, Barracks, Militia and multi-select review states.
- Added hash-checked optional Aster portrait loading from existing approved private evidence, with forced fallback proof.
- Added procedural command/ability icon specifications, shortcut labels, tooltip text, focus styles, cooldown overlays and disabled overlays.
- Added v0.210 deterministic capture and validation wrappers plus a review-pack/boundary tool.

## Commands

- `npm run godot:test` - PASS
- `npm run godot:export:windows` - PASS
- `npm run godot:package:windows` - PASS
- `npm run godot:capture:salto-selection-command-panel` - PASS
- `npm run godot:validate:salto-selection-command-panel` - PASS
- `npm run validate:runtime-art-slots` - PASS
- `node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0210/cleanup-dry-run` - PASS dry run
- `npm run validate:content` - PASS
- `npm run validate:art-intake` - PASS
- `npm run build` - PASS
- `npm test` - PASS, 887 tests
- `git diff --check` - PASS with only the existing Godot script CRLF warning

## Acceptance Tracking

- Default launcher remains procedural.
- v0.209 UI shell launcher remains the parent opt-in path.
- No new image generation or downloaded assets.
- No production art or UI slot.
- No gameplay or stable-ID mutation.
- Aster portrait reuse is gated by source metadata and SHA-256 validation, with forced fallback proof.
- Manual review pack: `artifacts/manual-review/v0210-selection-command-panel/`.
- Direct Computer Use app inspection was attempted, but the Windows bridge failed during setup with `failed to write kernel assets: The system cannot find the path specified. (os error 3)`. Scripted packaged Windows captures were used as the visual evidence path.
