# v0.147 Worker Billboard Validation Report

Status: validation target defined; final command results are recorded in `docs/V0147_IMPLEMENTATION_REPORT.md` after closeout.

## Validation Surfaces

- Static repository validation: `tools/godot/workerBillboardSingleSlotTool.mjs validate`.
- Fallback reproducibility: `tools/godot/workerBillboardSingleSlotTool.mjs fallback:check`.
- Godot runtime loader validation: `npm run godot:worker-billboard:validate`.
- Headed evidence generation: `npm run godot:worker-billboard:benchmark:headed`.
- Capture refresh: `npm run godot:worker-billboard:capture`.

## Expected Validation Behavior

- Local experimental cutout present: loader uses `local-experimental-cutout`.
- Local experimental cutout absent: loader uses `tracked-diagnostic-fallback`.
- Local metadata hash mismatch: loader refuses the local source.
- Fallback hash mismatch: validation fails.
- Unknown source: validation fails.

## Local Slot Metadata

The local experimental metadata lives under the ignored local slot path:

```text
artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147.metadata.json
```

It records slot ID, role, generator, model/provider posture, generation date, source posture, licence posture, protected-IP review status, human review status, SHA-256 hash, dimensions, alpha posture, trim bounds, pivot posture, intended scope, and explicit forbidden integration flags.

## Tracked Fallback Validation

The tracked fallback is deterministic and diagnostic only:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png
```

It validates against:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json
```

## Boundary Validation

Validation confirms that:

- No existing reference candidate is imported.
- No downloaded asset is used.
- No normal Salto player-facing slice launcher references the Worker experiment.
- No browser runtime path is changed.
- No production art-slot registry, runtime manifest, production package, save, or stable ID is mutated.
