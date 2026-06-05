# v0.133 Implementation Report

Status: `POST_MINE_FLOW_GREEN`

Implemented:

- Added v0.133 objective prerequisite gating and alias normalization.
- Removed the box-select objective skip to `prepare_ashen_pressure`.
- Added live Barracks restoration through Worker right-click.
- Added live construction and recruitment progress in the player-facing loop.
- Added Barracks selection and context-sensitive Train command.
- Added Ashen-pressure countdown and automatic wave launch.
- Added normal wave movement and combat simulation advancement.
- Added Objective 8 Attack-button raw-click recovery for the visible HUD command while preserving the right-click Ashen target path.
- Added simulation-backed wave defeat and input-facing Lume restoration.
- Added `GODOT_POST_MINE_FLOW_SMOKE_WINDOWS.bat`, `GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat`, and npm scripts `godot:validate:post-mine-flow` / `godot:headed:post-mine-flow-smoke`.
- Added v0.133 artifact validation in `desktop-spikes/godot-salto/tools/godotSpikeTool.mjs`.

Verified:

- `npm run godot:validate:post-mine-flow` -> `PASS_V0133_POST_MINE_FLOW_VALIDATION`
- `headed-post-mine-flow-smoke.json` -> `PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE`
- Packaged-window Computer Use proof reached `Salto Review Complete` through visible mouse input and normal simulation.

Scope not changed:

- No full port.
- No final engine choice.
- No runtime artwork.
- No save or stable-ID changes.
- No browser runtime changes.
- No broad economy, broad building tree, broad recruitment, or campaign expansion.
- No v0.134 work.
