# v0.135 RTS Ergonomics Gate

Classification: `RTS_ERGONOMICS_GREEN`

## Gate States

`RTS_ERGONOMICS_GREEN` means conventional controls, concise command feedback, camera comfort, recoverability, and full microloop completion passed in the packaged player-facing slice without forbidden proof paths.

`RTS_ERGONOMICS_AMBER` means the slice remains completable, but one or more ergonomic affordances are incomplete, unclear, or not fully proven.

`RTS_ERGONOMICS_RED` means normal packaged play can fail, soft-lock, lose the player after a recoverable mistake, or require private/debug/editor intervention.

## Green Requirements

- v0.134 gate has `REPEATABLE_PLAYTHROUGH_GREEN`.
- `GODOT_RTS_ERGONOMICS_SMOKE_WINDOWS.bat` completes.
- `headed-rts-ergonomics-smoke.json` reports `PASS_V0135_HEADED_RTS_ERGONOMICS_SMOKE`.
- `rts-input-contract.json` reports `PASS_V0135_RTS_INPUT_CONTRACT`.
- `order-feedback-report.json` reports `PASS_V0135_ORDER_FEEDBACK`.
- `camera-control-report.json` reports `PASS_V0135_CAMERA_CONTROL`.
- `compact-help-report.json` reports `PASS_V0135_COMPACT_HELP`.
- `screenshot-manifest.json` reports `PASS_V0135_SCREENSHOT_MANIFEST` with at least 14 packaged screenshots.
- `rts-ergonomics-validation.json` reports `PASS_V0135_RTS_ERGONOMICS_VALIDATION`.

No private harness shortcut, debug shortcut, state injection, fixture-only helper proof, scripted objective skipping, screenshot-only proof, routine Godot-editor work, save write, stable-ID change, browser-runtime change, generated/imported art, runtime art integration, final engine choice, or full port is allowed.
