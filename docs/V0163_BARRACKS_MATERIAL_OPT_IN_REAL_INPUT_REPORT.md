# v0.163 Barracks Material Opt-In Real-Input Report

Status: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`.

The real-input hardening run uses the packaged Godot app and the existing combined Worker + Barracks opt-in path. It does not use private debug shortcuts as a substitute for player input.

Scenarios:

- `worker-barracks-post-mine-flow`: validates Worker assignment, Barracks restoration, Militia recruitment continuation, Lume restoration continuation, and screenshot evidence.
- `worker-barracks-restart-replay`: validates normal playthrough, recoverable-mistake profile, restart integrity, no-softlock proof, and no-shortcut proof.

Expected generated evidence:

- `artifacts/desktop-spikes/godot-salto/v0163/real-input/worker-barracks-art-opt-in-real-input-report.json`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`.

Human-playability verdict remains reserved for human review.

Result:

- `worker-barracks-post-mine-flow` passed with Barracks restoration, Militia recruitment, Lume restoration, and screenshot proof.
- `worker-barracks-restart-replay` passed with normal playthrough, recoverable-mistake profile, restart integrity, no-softlock proof, no-shortcut proof, and screenshot proof.
- `debugShortcutUsed=false` and `stateInjectionUsed=false` in the recorded real-input report.
