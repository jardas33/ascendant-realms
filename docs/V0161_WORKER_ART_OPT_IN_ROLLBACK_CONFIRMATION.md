# V0161 Worker Art Opt-In Rollback Confirmation

Status: rollback posture for v0.161.

## Rollback Path

The default stabilized launcher remains unchanged and procedural:

```text
GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat
```

The default player-slice launcher remains unchanged and procedural:

```text
GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat
```

The Worker-art opt-in path is isolated to explicit opt-in launch/tooling:

```text
GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat
GODOT_VALIDATE_SALTO_WORKER_ART_OPT_IN_HARDENING_WINDOWS.bat
```

## Fail-Closed Behavior

- Missing local Worker art falls back to the procedural Worker.
- Hash mismatch falls back to the procedural Worker.
- The selected ignored derivative and metadata are not moved, rewritten, or destructively staged by v0.161.

## Not Changed

No browser runtime, production runtime-art manifest, save system, stable IDs, gameplay rules, objective logic, AI, balance, map content, default-art enablement, or second player-facing art slot is changed.
