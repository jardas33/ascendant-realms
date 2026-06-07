# V0161 Worker Art Opt-In Computer Use Review

Status: Windows-side app review record for the v0.161 Worker-art opt-in hardening pass.

## Review Target

Computer Use is used only for Windows-side app inspection of the packaged Godot Salto review slice. The Browser runtime remains untouched.

Review paths:

- Procedural baseline: `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- Worker-art opt-in: `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- Optional one-click opt-in review helper: `GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat`.

## Checklist

- Default path remains procedural and does not load the local Worker billboard.
- Opt-in posture is visible and loads the selected Worker source only.
- Worker selection ring remains visible.
- Worker assignment remains understandable.
- Barracks-restoration continuation remains understandable.
- Worker remains non-combatant and subordinate to Aster.
- No HUD, minimap, terrain, objective, Aster, Militia, Ashen Raider, or Barracks-material generated visual enters the normal slice.

## Evidence

Computer Use review evidence is recorded under:

```text
artifacts/desktop-spikes/godot-salto/v0161/computer-use/
```

The gate report is:

```text
artifacts/desktop-spikes/godot-salto/v0161/computer-use/worker-art-opt-in-computer-use-gate.json
```

Latest gate status:

```text
PASS_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_GATE
```

Observed live-window checks: procedural baseline reviewed, Worker-art opt-in reviewed, default launcher stayed procedural, only the Worker visual changed, Worker selection ring stayed visible, assignment feedback stayed understandable, and Barracks-continuation readability remained covered by the paired real-input evidence.

This review is not a final art approval. It is a human-review readiness pass.
