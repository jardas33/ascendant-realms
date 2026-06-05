# v0.131 Implementation Report

Status: `IMPLEMENTED_AND_LOCALLY_PROVEN`

## What Changed

- Added real mouse event handling to the player-facing 2.5D Godot scene.
- Added screen-space hit testing for Aster, Worker, soldiers, hostiles, terrain, and squad drag selection.
- Added player-facing live movement advancement so real move orders visibly displace Aster.
- Added Aster staging, pulse ring, compact label, objective arrow, destination pulse, minimap hero marker, and camera centering for Objective 1.
- Added real-input telemetry under ignored `artifacts/desktop-spikes/godot-salto/v0131/`.
- Added `GODOT_REAL_INPUT_SMOKE_WINDOWS.bat` and `GODOT_LAUNCH_PLAYABILITY_REVIEW_WINDOWS.bat`.
- Added `npm run godot:validate:real-input` and `npm run godot:headed:real-input-smoke`.

## Boundaries Preserved

- No artwork was generated, imported, or integrated.
- No browser runtime files were changed for the Godot repair.
- No save files, save schema, localStorage keys, rewards, XP, campaign state, or stable IDs changed.
- `linked_ward` remains exactly `0.92`.
- The private engineering harness remains separate.
- Routine Godot editor work is still not required.
- No final Godot decision, full port, Unity project, Unreal project, Electron project, or v0.132 work was started.

## Verification Evidence

Latest v0.131 real-input validation:

- `npm run godot:validate:real-input` - PASS.
- `PASS_HEADED_REAL_INPUT_SMOKE`.
- `PASS_SELECTION_PROOF`.
- `PASS_MOVEMENT_PROOF`.
- `PASS_V0131_REAL_INPUT_SCREENSHOTS`.
- `PASS_V0131_REAL_INPUT_VALIDATION`.

Full closeout verification is run before commit and push according to the v0.131 prompt.

