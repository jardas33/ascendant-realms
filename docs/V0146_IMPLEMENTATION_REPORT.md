# v0.146 Implementation Report

Status: implemented as isolated private comparator tooling; final closeout verification is recorded after the full stack passes.

## Start State

- Start commit: `ca318bc94a591eb8738c05466246826b215e7042`.
- Branch: `main`.
- Sync: `HEAD...@{u}` was `0 0`.
- v0.145 GitHub Actions push run `27073934707` completed successfully.
- v0.145 generated exactly three HUD reference-only frames.
- `npm run art:reference:validate` passed with 15 metadata files and 15 candidate images.
- All 15 metadata records remained `runtimeIntegrationStatus = forbidden`.

## Implemented

- Added isolated comparator scene/script under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/`.
- Added private root dispatch flag `--runtime-art-comparator` without changing the default player-facing launch path.
- Added comparator validator/report post-processor `tools/godot/runtimeArtComparatorTool.mjs`.
- Added Windows PowerShell wrappers for static/runtime validation, headed benchmark evidence, and screenshot capture.
- Added root one-click wrapper `GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat`.
- Added package scripts:
  - `godot:runtime-art-comparator:validate`
  - `godot:runtime-art-comparator:benchmark:headed`
  - `godot:runtime-art-comparator:capture`
- Added v0.146 spec, benchmark, scorecard, recommendation, review guide, boundary, and implementation docs.

## Comparator Evidence

The comparator evaluates:

- `ORTHO_3D_MESH`
- `BILLBOARD_2D_ATLAS`
- `HYBRID_3D_WORLD_BILLBOARD_UNITS`

Each runs Tier S, Tier M, and Tier L with equivalent entity counts, structures, sites, Lume posture, movement beats, selection rings, animation-update proxy, camera pan/zoom, VFX placeholders, and Results-ready posture.

Latest evidence paths:

```text
artifacts/desktop-spikes/godot-salto/v0146/runtime-art-comparator-runtime.json
artifacts/desktop-spikes/godot-salto/v0146/runtime-art-comparator-evidence.json
artifacts/desktop-spikes/godot-salto/v0146/benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0146/scorecard.md
artifacts/desktop-spikes/godot-salto/v0146/contact-sheet.svg
```

## Recommendation

Recommended next single-slot runtime-art experiment: `HYBRID_3D_WORLD_BILLBOARD_UNITS`.

Fallback comparator: `ORTHO_3D_MESH`.

Deferred / rejected for the next slot: `BILLBOARD_2D_ATLAS`.

This is not final engine selection and not runtime-art integration approval.

## Boundaries Preserved

- Zero generated reference images imported.
- Zero downloaded assets.
- Zero production textures, sprites, atlases, models, or animations added.
- No normal Salto player-facing slice mutation.
- No default launcher replacement.
- No browser runtime mutation.
- No runtime manifest, fixture manifest, art-slot, production package, save, or stable-ID mutation.
- No final engine choice.
- No full port.
- No v0.147 work.

## Verification

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
npm run godot:runtime-art-comparator:validate
npm run godot:runtime-art-comparator:benchmark:headed
npm run godot:runtime-art-comparator:capture
git diff --check
```

The final pushed checkpoint must use commit message:

```text
Checkpoint v0.146 Godot runtime-art pipeline comparator spike scorecard and human decision stop
```
