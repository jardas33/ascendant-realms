# v0.149 Implementation Report

Status: implemented as a private comparator-only Barracks material single-slot intake path with final local evidence ready for human review.

## Start State

- Start commit: `5978905ab32a280543a74245ae36c2c28b87ce45`.
- Branch: `main`.
- Sync: `HEAD...@{u}` was `0 0`.
- Baseline GitHub Actions run `27078101206` completed successfully.
- v0.148 Worker repair decision encoded: continue isolated hybrid comparator work only.
- Preferred Worker derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Preferred Worker hash: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preferred scale posture: `1.00x`; `0.90x` is crowding comparator; `1.10x` is close-diagnostic only.

## Implemented

- Generated exactly one original local material-source image for `barrosan_barracks_material_v0149`.
- Kept source and deterministic derivatives ignored under `artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/`.
- Added deterministic 512, 768, and 1024 derivatives with metadata.
- Added tracked deterministic diagnostic fallback for clean-checkout validation.
- Added a private Barracks material comparator with a low-complexity procedural shell, Worker context, fair-path counters, Tier S/M/L benchmarks, and review captures.
- Added validation, fallback reproducibility, derivative reproducibility, audit, headed benchmark, and capture wrappers.
- Added one-click wrapper `GODOT_BARROSAN_BARRACKS_MATERIAL_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- Added v0.149 docs and scaffold coverage.

## Current Evidence

Generated source:

```text
artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.png
```

- SHA-256: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`.
- Dimensions: `1254 x 1254`.

Tracked fallback:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png
```

- SHA-256: `473ea8fd00a42716d2130109d2d3eb30f0a5eb3751fe0445af773a5bf0731767`.
- Dimensions: `512 x 512`.

Final selected derivative and benchmark evidence were recorded by `npm run godot:barracks-material:capture`.
Metadata:

```text
artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.metadata.json
```

Selected derivative:

```text
HYBRID_BARRACKS_LOCAL_768
```

- Source kind: `local-barracks-material-768`.
- SHA-256: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`.
- Dimensions: `768 x 768`.
- Tier L mean FPS: `1873.11`.
- Tier L mean p95: `0.85 ms`.
- FPS ratio against diagnostic fallback: `1.0499`.
- p95 ratio against diagnostic fallback: `0.9043`.
- Gate: `PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE`.

Fair-path audit:

- Status: `PASS_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT`.
- Texture cache entries: `5`.
- Material cache entries: `5`.
- Each source loaded once and each material key created once.
- No repeated texture or material creation during steady-state frames.
- No runtime derivative generation, metadata parsing during steady state, or steady-state UV rebuild.

Primary review captures:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/014_hybrid_barracks_local_768_l_paired_benchmark.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/020_hybrid_barracks_local_768_s_derivative_768_comparison.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/028_hybrid_barracks_local_768_m_wet_overcast_lighting_posture.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/screenshots/030_hybrid_barracks_local_1024_s_uv_tiling_seam_diagnostic.png
artifacts/desktop-spikes/godot-salto/v0149/evidence/contact-sheet.svg
```

Visual finding: the material reads as practical wet timber, stone, and dark metal on the simple procedural Barracks shell, while the panelized source divisions remain a human-review seam/repeat risk rather than an automatic production approval.

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
npm run godot:barracks-material:validate
npm run godot:barracks-material:fallback:reproduce
npm run godot:barracks-material:derivatives:reproduce
npm run godot:barracks-material:audit
npm run godot:barracks-material:benchmark:headed
npm run godot:barracks-material:capture
git diff --check
```

## Boundaries Preserved

- Exactly one new AI image.
- Barracks material source only.
- No existing reference candidate import.
- No downloaded asset use.
- No third runtime-art slot.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No production package inclusion.
- No save or stable-ID changes.
- No final engine choice.
- No v0.150 work.

The final pushed checkpoint must use commit message:

```text
Checkpoint v0.149 hybrid Barrosan Barracks material single-slot intake experiment and human review stop
```
