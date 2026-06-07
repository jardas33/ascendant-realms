# v0.162 Barracks Material Opt-In Rollback Report

Status: `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.

Rollback posture:
- Remove `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat` to remove the combined human-review entry point.
- Remove the v0.162 combined PowerShell wrappers and v0.162 evidence tool.
- Remove only the Barracks material option parsing and scene material override if the second slot is rejected.
- Keep `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` unchanged.
- Keep `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat` unchanged.

Fallback behavior:
- Missing Barracks source fails closed to procedural Barracks.
- Barracks hash mismatch fails closed to procedural Barracks.
- Worker art remains active in both Barracks fallback scenarios.

No rollback touches:
- Browser runtime.
- Save systems.
- Stable IDs.
- Production runtime-art manifests.
- Aster, Militia, or Ashen Raider art paths.

Boundary proof:
- Default stabilized launcher hash remained `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`.
- Worker-only launcher hash remained `87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb`.
- Package leakage check passed with `leaked=false`.
