# v0.118 Godot Headed Smoke Spec

v0.118 extends the v0.117 Godot Salto workflow spike with a packaged Windows headed smoke path. It remains a workflow spike only: no full port, no final Godot choice, no artwork import, no save migration, and no routine Godot editor requirement.

## Authorized Surface

- Root launcher: `GODOT_LAUNCH_REVIEW_WINDOWS.bat`
- Smoke launcher: `GODOT_HEADED_SMOKE_WINDOWS.bat`
- NPM entry: `npm run godot:headed:smoke`
- Scripted executable flags: `--review-smoke`, `--headed-benchmark`, `--artifact-root=<path>`
- Artifact root: `artifacts/desktop-spikes/godot-salto/v0118/`

## Review Harness Steps

The private in-build harness exposes a compact overlay and a scripted tour:

1. Home
2. Launch 2D
3. Launch 2.5D
4. Select hero
5. Select Worker
6. Box-select squad
7. Move
8. Attack
9. Camera pan
10. Camera zoom
11. Pause
12. Capture site
13. Lume link
14. Results transition
15. Return home
16. Exit

The harness is repository-driven and editor-optional. It writes no saves and does not use browser localStorage.

## Pass Contract

`headed-smoke.json` passes only when the packaged executable opens a headed Godot window, runs the review tour, records the Godot version and fixture hash, and confirms no editor assembly, runtime art import, save write, or final engine choice.

## Current Result

```text
Status - PASS_PACKAGED_HEADED_SMOKE
Window - 1600x900
Mode coverage - home, 2D, and 2.5D
Review steps - completed
Godot editor required - false
Save write - false
Runtime art import - false
Final engine choice - false
```
