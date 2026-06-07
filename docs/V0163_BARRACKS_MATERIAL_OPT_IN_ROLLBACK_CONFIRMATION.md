# v0.163 Barracks Material Opt-In Rollback Confirmation

Status: `PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.

Rollback remains launcher-level because the default stabilized launcher is unchanged and procedural. Removing or ignoring the v0.163 review and validation helpers leaves the ordinary default review path intact.

Preserved launchers:

- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.

Fallback behavior:

- Missing Barracks material source produces procedural Barracks fallback.
- Barracks hash mismatch produces procedural Barracks fallback.
- Worker art remains active in both Barracks fallback scenarios.

Package boundary:

- Ignored source images and metadata remain outside the ordinary packaged ZIP.
- No browser runtime asset manifest is modified.
- Package leakage reported `false`.
- Default, Worker-only, and combined launcher hashes match the expected preserved hashes.
