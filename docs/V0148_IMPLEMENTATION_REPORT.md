# v0.148 Implementation Report

Status: implemented as a private comparator-only repair and fair benchmark path; final benchmark evidence is recorded, with pushed CI proof pending closeout.

## Start State

- Start commit: `f0bb252bb6767d5c24d6c3e4764ba83534b4ce36`.
- Branch: `main`.
- Sync: `HEAD...@{u}` was `0 0`.
- Baseline GitHub Actions run `27076917234` completed successfully.
- v0.147 stopped honestly after missing the original Tier L acceptance gate.

## Implemented

- Reused the existing ignored v0.147 Worker source and cutout.
- Generated zero new AI-generated images.
- Added deterministic trimmed 512, 768, and 1024 derivatives only.
- Preserved the source-quality full-resolution cutout as a comparator source.
- Added cached texture and material reuse in the private comparator.
- Added fair-path counters for source loads, texture creates, material creates, initialization, and warmup.
- Added five-trial Tier L paired benchmark sequencing with rotated order.
- Added validation, audit, derivative reproducibility, headed benchmark, and capture wrappers.
- Added one-click wrapper `GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat`.
- Added v0.148 docs and scaffold coverage.

## Final Evidence

Evidence root:

```text
artifacts/desktop-spikes/godot-salto/v0148/evidence/
```

Final selected derivative:

```text
HYBRID_WORKER_TRIMMED_1024
```

Threshold:

```text
PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE
```

- Selected hash: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Baseline Tier L mean FPS: `858.41`.
- Selected Tier L mean FPS: `851.14`.
- Average FPS ratio: `0.9915`.
- Baseline Tier L mean p95 frame time: `1.87 ms`.
- Selected Tier L mean p95 frame time: `1.88 ms`.
- p95 frame-time ratio: `1.0053`.
- p95 absolute delta: `0.01 ms`, context only.

Fair-path audit:

```text
PASS_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT
```

- Texture cache entries: `5`.
- Material cache entries: `10`.
- Texture creation during steady state: `false`.
- Material creation during steady state: `false`.
- Texture load/create count is one per source.
- Material create count is one per source/tint.

## Verification Stack

Required closeout stack:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:worker-billboard-repair:validate
npm run godot:worker-billboard-repair:audit
npm run godot:worker-billboard-repair:derivatives:reproduce
npm run godot:worker-billboard-repair:benchmark:headed
npm run godot:worker-billboard-repair:capture
git diff --check
```

## Boundaries Preserved

- No new AI image generation.
- No second runtime-art slot.
- No existing reference candidate import.
- No generated reference image import.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No production package inclusion.
- No save or stable-ID changes.
- No final engine choice.
- No v0.149 work.

The final pushed checkpoint must use commit message:

```text
Checkpoint v0.148 hybrid Worker billboard single-slot repair fair benchmark and human review stop
```
