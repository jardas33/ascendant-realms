# V0160 Worker Art Opt-In Visual Review Guide

Status: Emmanuel review guide for the single Worker opt-in experiment.

## Review Order

1. Launch the unchanged procedural default:

```text
GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat
```

2. Launch the explicit opt-in Worker-art slice:

```text
GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
```

3. Generate visual evidence:

```text
GODOT_CAPTURE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
```

## What To Compare

- Default procedural Worker versus opt-in billboard Worker.
- Worker selected with ring and context.
- Worker assignment and mine-work posture.
- Barracks repair proximity.
- Group crowding with Aster and squad.
- Normal camera, zoomed-in edge treatment, and zoomed-out readability.
- Missing-art and hash-mismatch fallback screenshots.
- 1.00x opt-in against 0.90x comparator.

Generated review files:

- `artifacts/desktop-spikes/godot-salto/v0160/capture/worker-art-opt-in-contact-sheet.svg`
- `artifacts/desktop-spikes/godot-salto/v0160/capture/worker-art-opt-in-visual-review-guide.md`
- `artifacts/desktop-spikes/godot-salto/v0160/capture/worker-art-opt-in-capture-report.json`

Recorded capture status:

- `PASS_V0160_WORKER_ART_OPT_IN_CAPTURE`
- Capture scenarios: 5.
- Screenshots per scenario: 12.
- Total screenshots: 60.

Scenarios captured:

- `default-procedural`
- `worker-opt-in`
- `worker-opt-in-scale-090`
- `missing-art-fallback`
- `hash-mismatch-fallback`

## Human Decision

This checkpoint asks only whether the opt-in Worker billboard is worth further player-facing iteration. It does not approve final art, production runtime art, final engine choice, or additional slots.
