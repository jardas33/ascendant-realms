# v0.103 Evidence-Backed Optimization Report

## Changes Made

- Reduced stable capture-site ring opacity and width while preserving selected/contested/objective/hostile emphasis.
- Hid quiet friendly/neutral capture-site labels by default; selected, contested, objective-relevant, and hostile sites still show labels.
- Made Lume Auto hide stable active links after transition pulses unless an endpoint is selected.
- Kept Lume Hidden and Always explicit and unchanged in purpose.
- Moved optional Lume link prose behind Details.
- Added a private profiler and Performance Lab to identify future cost signals before optimization work.

## Evidence Boundary

These changes are presentation and QA-tooling only. They do not change Lume mechanics, the `linked_ward` multiplier, combat, AI, saves, rewards, campaign progression, or stable IDs.

## Top Cost Signals

`npm run perf:profile:private` completed 17 private scenarios. The top local p95 frame-time signals from the final refreshed run were:

1. `perf_selected_worker`: p95 683.3 ms, max 683.3 ms.
2. `perf_lume_activation_pulse`: p95 583.3 ms, max 583.3 ms.
3. `perf_fog_heavy_camera`: p95 566.7 ms, max 566.7 ms.

The Lume visibility scenarios support the v0.103 clutter reduction:

- Hidden renders 0 Lume links.
- Auto renders 1 contextual Lume link in the sampled fixture.
- Always renders 2 Lume links for deliberate inspection.

Capture-site label density remains visible in the explicit label-heavy fixture but no longer keeps quiet friendly/neutral labels always-on by default.

## Deferred Optimizations

- Broad renderer batching.
- Phaser object pooling beyond existing patterns.
- Final terrain/art pipeline.
- Desktop renderer selection.
- Lume race-specific art.
