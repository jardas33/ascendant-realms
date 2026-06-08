# v0.173 Implementation Report

Status: `PASS_V0173_IMPLEMENTATION_REPORT`

## Implemented

v0.173 introduces an opt-in procedural environment-foundation review path for Godot Salto:

- Added `--salto-environment-foundation-review`.
- Added `GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`.
- Added validation/capture tooling and a v0.173 report tool.
- Added review-only procedural layers for terrain value hierarchy, roads, river banks, bridge deck, structure ground plates, site-marker collars, and overcast lighting.
- Expanded v0.173 capture steps to include roads, river/banks, bridge, structures, site markers, coexistence, combat, minimap, and pan/zoom.
- Preserved the five selected character/material slots without adding a sixth slot.

## Verification

- `npm run godot:validate:salto-environment-foundation`
- `node --check tools/godot/saltoEnvironmentFoundationTool.mjs`
- `npm run godot:validate:salto-experimental-artifact-retention -- --output-root=artifacts/desktop-spikes/godot-salto/v0173/artifact-retention-final`
- `npm run validate:runtime-art-slots`
- `npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts`
- `git diff --check`
- Windows-side Computer Use review of the packaged v0.173 title, briefing, and live battle states

Automation emitted:

- `PASS_V0173_SALTO_ENVIRONMENT_FOUNDATION_AUTOMATION_READY`
- `PASS_V0173_ENVIRONMENT_FOUNDATION_VALIDATION`
- `PASS_V0173_ENVIRONMENT_FOUNDATION_CAPTURE`
- `PASS_V0173_ENVIRONMENT_FOUNDATION_BENCHMARK`
- `PASS_V0173_ENVIRONMENT_FOUNDATION_BOUNDARY`
- `PASS_V0173_ENVIRONMENT_FOUNDATION_COMPUTER_USE_REVIEW`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`

## Human Review Stop

v0.173 is an opt-in environment shell hardening experiment only. v0.174 was not started by this implementation report.

`PASS_V0173_IMPLEMENTATION_REPORT`
