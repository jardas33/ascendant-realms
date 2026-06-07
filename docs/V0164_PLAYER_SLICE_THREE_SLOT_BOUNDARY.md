# v0.164 Player Slice Three-Slot Boundary

Status: `PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY`.

Allowed changes:

- Add Militia art loading behind `--militia-art-opt-in`.
- Add a new Worker + Barracks + Militia launch, validate, and capture path.
- Add v0.164 evidence aggregation tooling and docs.
- Add scaffold guardrails for the new three-slot opt-in path.

Protected launchers:

- Default stabilized launcher: preserved as procedural.
- Worker-only launcher: preserved as Worker-only.
- Worker + Barracks launcher: preserved as two-slot.

| Launcher | Required posture | SHA-256 |
| --- | --- | --- |
| `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` | default procedural | `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d` |
| `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat` | Worker-only | `87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb` |
| `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat` | Worker + Barracks | `a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a` |

Boundary confirmations:

- Exactly one new normal-slice opt-in slot was added.
- Exactly three normal-slice opt-in slots exist in the new combined posture.
- No fourth player-facing art slot was added.
- No new images were generated.
- No browser runtime was changed.
- No production package leakage was detected.
- No save or stable-ID mutation was detected.
- No default-launcher mutation was detected.
- No Worker-only launcher mutation was detected.
- No Worker + Barracks launcher mutation was detected.

Boundary evidence:

- `artifacts/desktop-spikes/godot-salto/v0164/boundary/worker-barracks-militia-art-opt-in-boundary-scan.json`
