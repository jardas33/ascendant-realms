# v0.135 Implementation Report

Checkpoint: v0.135 Godot RTS Input Ergonomics, Recoverable Feedback, and Camera-Control Pass

## Implemented

- Added packaged-player RTS ergonomics smoke mode: `--rts-ergonomics-smoke`.
- Added one-click Windows proof: `GODOT_RTS_ERGONOMICS_SMOKE_WINDOWS.bat`.
- Added npm proof command: `npm run godot:headed:rts-ergonomics-smoke`.
- Added compact help overlay through F1 and Help.
- Added Escape recovery handling.
- Added mouse-wheel zoom, keyboard pan, and Space focus Aster.
- Added Worker focus during the Worker objective.
- Added invalid-order/context-action tracking for command feedback validation.
- Added v0.135 artifact validation through `desktop-spikes/godot-salto/tools/godotSpikeTool.mjs rts-ergonomics-v0135`.

## Evidence

The headed proof writes ignored artifacts under `artifacts/desktop-spikes/godot-salto/v0135/`:

- `headed-rts-ergonomics-smoke.json`
- `rts-ergonomics-smoke.json`
- `rts-input-contract.json`
- `order-feedback-report.json`
- `camera-control-report.json`
- `compact-help-report.json`
- `rts-ergonomics-trace.json`
- `screenshot-manifest.json`
- `rts-ergonomics-validation.json`
- `screenshots/*.png`

## Boundaries

No art generation/import, runtime art integration, save change, stable-ID change, browser-runtime change, broad gameplay system, final Godot decision, full port, Unity, Unreal, Electron, or v0.136 work was started. The private engineering harness remains separate.
