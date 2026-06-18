# v0.228 Implementation Report

Status: `PASS_V0228_PRODUCTION_BATTLEFIELD_BACKPLATE_RESCUE_WITH_LIMITATIONS`

## Scope

- Added one isolated `--salto-production-battlefield-backplate` review flag.
- Added v0.228 capture, validation, benchmark and before/after tooling.
- Reused the selected v0.216 terrain and v0.217 road/riverbank/water materials without adding art slots.
- Suppressed legacy rectangular road/river surfaces only in the v0.228 path.
- Added opaque authored foundations plus restrained texture insets for terrain, road, river and banks.
- Preserved the default launcher, browser runtime, gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and input behavior.

## Verification

- Capture: `PASS_V0228_CAPTURE`.
- Validation and fallback matrix: `PASS_V0228_VALIDATION`.
- Benchmark: `PASS_V0228_BENCHMARK`.
- Selected: 74.79 FPS average, 12.57 ms p95.
- v0.227 comparator: 73.33 FPS average, 10.95 ms p95.
- FPS ratio versus v0.227: 1.0199.
- `npm test`: 122 files, 887 tests passed.
- `npm run godot:test`: `PASS_GODOT_HEADLESS_TESTS`.
- `npm run build`: passed; existing large-chunk warning only.
- Content, art-intake and 52 runtime-art-slot validations: passed.
- Safe cleanup dry run and `git diff --check`: passed.

## Art Boundary

The one attempted generated preview did not produce a filesystem source. No generated source or derivative was integrated, so no source hashes exist for v0.228.
