# v0.136 Usability Presentation Gate

Classification: `USABILITY_PRESENTATION_GREEN`
Gate: `USABILITY_PRESENTATION_GREEN`

## Gate States

`USABILITY_PRESENTATION_GREEN` means the packaged player-facing slice proves the HUD hierarchy, minimap, onboarding copy, pacing, screenshots, and natural completion path without forbidden proof paths.

`USABILITY_PRESENTATION_AMBER` means the slice remains completable, but one or more presentation or pacing checks are incomplete, unclear, or not fully proven.

`USABILITY_PRESENTATION_RED` means normal packaged play can fail, soft-lock, hide required targets behind chrome, require private/debug/editor intervention, or fail a real gate.

## Green Requirements

- v0.135 gate is accepted from either `Classification:` or `Gate:` and is `RTS_ERGONOMICS_GREEN`.
- `GODOT_USABILITY_PRESENTATION_WINDOWS.bat` completes.
- `headed-usability-presentation-smoke.json` reports `PASS_V0136_HEADED_USABILITY_PRESENTATION_SMOKE`.
- `hud-hierarchy-report.json` reports `PASS_V0136_HUD_HIERARCHY`.
- `minimap-refinement-report.json` reports `PASS_V0136_MINIMAP_REFINEMENT`.
- `onboarding-copy-report.json` reports `PASS_V0136_ONBOARDING_COPY`.
- `microloop-pacing-report.json` reports `PASS_V0136_MICROLOOP_PACING`.
- `screenshot-manifest.json` reports `PASS_V0136_SCREENSHOT_MANIFEST` with title, briefing, HUD default, mine conversion, Worker assignment, construction, recruitment, countdown, combat, Lume, minimap states, and Results captures.
- `usability-presentation-validation.json` reports `PASS_V0136_USABILITY_PRESENTATION_VALIDATION`.

No private harness shortcut, debug shortcut, state injection, fixture-only helper proof, scripted objective skipping, screenshot-only proof, routine Godot-editor work, save write, stable-ID change, browser-runtime change, generated/imported art, runtime art integration, final engine choice, full port, or v0.137 work is allowed.

