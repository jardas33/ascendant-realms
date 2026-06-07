# V0161 Worker Art Opt-In Visual Review Guide

Status: Emmanuel visual review guide for the v0.161 Worker-art opt-in pass.

## Open

Use the procedural baseline first:

```text
GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat
```

Then use the Worker-art opt-in path:

```text
GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
```

The optional helper for the opt-in path is:

```text
GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat
```

## Inspect

- Hair/cap edge, shoulders, rope, lantern, hammer, pack outline, boots, and alpha halo.
- Foot pivot, terrain anchoring, camera pan, and camera zoom.
- Repeated Worker overlap.
- Selection ring, hover marker, Worker near mine, Worker near Barracks, and assignment posture.
- Hierarchy below Aster and distinction from Militia.
- No HUD, minimap, terrain, objective, or other generated normal-slice regression.

## Decision

Recommended next separately authorized milestone after a passing v0.161 gate is: pause for Emmanuel manual review.

Do not begin v0.162 from this guide.
