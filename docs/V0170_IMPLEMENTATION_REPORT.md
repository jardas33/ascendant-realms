# v0.170 Implementation Report

Status: `PASS_V0170_ASHEN_OPT_IN_SUMMARY`

## Implemented

- Added Ashen Raider opt-in loader/reporting to `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`.
- Added v0.170 argument routing and capture checkpoint recognition to `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- Added fifth-slot launch, capture, validate, and review scripts.
- Added `tools/godot/saltoFiveSlotArtOptInTool.mjs` for validation, capture, benchmark, real-input, boundary, Computer Use, and summary gates.
- Added scaffold coverage for the fifth-slot contract.
- Reapplied player-facing staging when entering battle and made review rings obey `reviewHidden`, fixing the visual leak where unrecruited friendly military billboards appeared in the opening battle review frame.
- Post-review hardening: reduced five-slot-only review-ring dominance, raised the v0.170 review-scale arguments for the existing selected cutouts, and staged the five-slot squad-comparison capture into a clear lane so foreground Barracks geometry no longer slices through Aster.
- The rebuilt Windows Godot app was inspected through Computer Use and advanced into the battle screen after the post-review visual hardening.

## Validation

- `npm run godot:validate:salto-five-slot-art-experiment`: `PASS_V0170_WORKER_BARRACKS_MILITIA_ASTER_ASHEN_ART_OPT_IN_AUTOMATION_READY`.
- `node tools/godot/saltoFiveSlotArtOptInTool.mjs computer-use --artifact-root=artifacts/desktop-spikes/godot-salto/v0170`: `PASS_V0170_ASHEN_OPT_IN_COMPUTER_USE`.
- `node tools/godot/saltoFiveSlotArtOptInTool.mjs summary --artifact-root=artifacts/desktop-spikes/godot-salto/v0170`: `PASS_V0170_ASHEN_OPT_IN_SUMMARY`.
- Benchmark: `PASS_V0170_ASHEN_OPT_IN_BENCHMARK`.
- Boundary: `PASS_V0170_ASHEN_OPT_IN_BOUNDARY`.
- Real input: `PASS_V0170_ASHEN_OPT_IN_REAL_INPUT`.

## Post-Review Closeout

- The original v0.170 checkpoint was committed, pushed, clean/synced, and remote-green at `0455739fc0bbaabbf05ac5dabef925ec0d79d5d9`.
- This post-review hardening keeps the default launcher procedural, preserves prior opt-in launchers, generates zero images, adds zero slots, and does not begin v0.171.
- The evidence roots were regenerated during this post-review hardening pass before final handoff.

v0.171 has not been started.
