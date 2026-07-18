# v0.334 House 02 Authentic Irregular Granite Material and Material-Evidence Repair

## Outcome

**REJECTED INTERNALLY — GRANITE STILL READS AS PATTERNED CLADDING, MARBLE TILES OR SYNTHETIC BLOCKS**

This is the permitted v0.334 internal outcome after inspecting the real Godot
candidate study and full-house renders. The technical evidence path is green,
but no automated check asserts granite authenticity and the pack is not a human
approval. The independent architectural result remains:

**ROOF FORM PRESERVED — PASS**

## Scope and baseline

- Base HEAD: `b9fec221c4020f015c6dcf486415adbeabb5e5c4`
- Branch: `codex/v0215-v0226-recovery`
- Prototype scene: `desktop-spikes/godot-salto/scenes/review/V0334BarrosanHouse02GraniteAuthenticity.tscn`
- Generator: `tools/blender/generate_v0334_barrosan_house_02.py`
- Capture: `tools/godot/captureGodotV0334House02GraniteAuthenticityWindows.ps1`
- Pack builder: `tools/godot/buildV0334House02GraniteAuthenticityPack.py`
- Validator: `tools/godot/saltoV0334House02GraniteAuthenticityTool.mjs`

The work is opt-in and isolated. It does not alter the accepted v0.333 scene,
gameplay, settlement integration, House 01, saves, stable IDs, or the default
runtime.

## v0.333 decision carried forward

v0.333’s roof and architecture passed while its granite authenticity gate
failed. v0.334 freezes the successful roof decisions: two continuous principal
slopes, one ridge, eaves, verges, one chimney, short-end gable walls only, and
zero front/rear false cross-gables. No stair, landing, upper-door, footprint,
or floor-logic changes were made.

## Isolated A/B/C material study

The study uses three 4 m × 3 m walls with an external corner, recessed dark
window, stone sill, lintel, dark foundation course, and a 1.75 m human figure:

- Candidate A: irregular uncoursed rubble intent.
- Candidate B: lightly coursed irregular intent.
- Candidate C: restrained RTS-readable hybrid intent.

All candidates are deterministic variations of one common authored masonry
height/source workflow. The captured comparison is a real Godot render at
candidate study, near, normal, and far views. The visual inspection rejected
all three because their repeated horizontal courses and block dimensions still
read as patterned cladding. No candidate was promoted to an authenticity pass.

## Material authorship and technical evidence

`art-source/materials/v0334/granite_height_2048.png` is the common source. Its
jittered masonry feature field drives height, albedo, roughness, and the local
height-derivative normal. The record documents neutral grey, taupe, brown and
restrained olive values, a 0.72–0.98 roughness range, 0.48 normal strength,
rougher recessed mortar, and the 8–15% / 45–60% / 20–35% stone hierarchy target.

The final map files are 2048 × 2048 PNGs:

- `granite_height_2048.png`
- `granite_albedo_2048.png`
- `granite_roughness_2048.png`
- `granite_normal_2048.png`

The exact density formula is:

`effective texture pixels per metre = sqrt(UV island pixel area / world surface area)`

Ten surface groups are recorded between 208 and 236 texels/m. The dimension
ledger separates principal house body (9.96 × 6.24 × 7.26 m), house plus
stair/landing and complete asset (10.30 × 9.71 × 7.26 m), collision bounds,
and review-scene bounds rather than silently mixing depths.

## Evidence repairs

- Checker is an unshaded UV-bound numbered checker with four high-contrast
  colours, black/cream glyphs, arrows, and grid; captures are not screen-space
  overlays.
- Wireframe is an actual bright triangle-edge `ImmediateMesh` evidence layer
  with the shaded house hidden.
- Collision capture hides the render mesh and environment and exposes the
  three collision hulls in distinct colours; the exported collision budget is
  36 triangles.
- Benchmark evidence records a five-second warm-up, 20.007-second measurement,
  1,500 raw samples, and 1,500 stored plotted samples without screenshot or
  video work during measurement.
- The real capture run produced 38 semantic screenshots and 288 unique
  turntable frames.

## Review pack

`artifacts/manual-review/v0334-house02-granite-authenticity/UPLOAD_TO_CHAT/`

The upload directory contains exactly ten required files, including documentary
analysis, A/B/C candidate comparison, v0.333-to-v0.334 comparison, roof
preservation, PBR response, checker/UV/density/dimensions, wireframe/collision/
LOD/benchmark evidence, turntable media, and the compact summary.

## Preservation and limitations

Preserved: v0.333 roof/architecture, default runtime, House 01, gameplay,
movement, pathfinding, combat, economy, resources, stable IDs, saves, and all
accepted state semantics. No settlement integration was added.

The limitation is material authorship quality, not pipeline integrity. The next
material attempt must abandon the remaining row/block silhouette and use a
more genuinely uncoursed, irregular source before any full-house promotion.

## Validation

Dedicated command:

`npm run godot:validate:salto-v0334-house-02-granite-authenticity`

Passed locally with 30 checks. The exact ten-file pack, real Godot capture,
20.007-second benchmark, 1,500 stored samples, and artifact-retention gate also
pass. The retained dedicated commands passed for v0.333 through v0.326 from a
clean accepted-baseline snapshot; the older scope guards intentionally reject
later-version files while they are uncommitted. Their historical content,
runtime, and preservation assertions all passed without modification.

The full local validation set passed:

- `npm test` — 887 tests in 122 files.
- `npm run build` — TypeScript and production Vite build.
- `npm run validate:content`.
- `npm run validate:art-intake`.
- `npm run validate:runtime-art-slots`.
- `npm run godot:validate:salto-experimental-artifact-retention`.
- `npm run godot:all`.
- `git diff --check`.

## CI and final repository state

The v0.334 commit and exact pushed-SHA GitHub Actions run are the final remote
closeout gates. The exact commit SHA, Actions run ID, and clean/synced 0/0
state are recorded here after push without changing the implementation scope.
