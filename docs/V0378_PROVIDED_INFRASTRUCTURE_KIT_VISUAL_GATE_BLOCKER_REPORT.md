# BLOCKED — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET

# v0.378 supplied infrastructure kit visual gate blocker report

## Scope

v0.378 imports the supplied authored infrastructure GLB into an isolated, opt-in Godot scene for a bounded terrain/road/riverbank/bridge visual gate. The scene contains no buildings, units, gameplay, HUD, or production-runtime mutation.

## Baseline and provenance

- Branch: `codex/v0215-v0226-recovery`
- Original checkpoint base HEAD: `9d9ef05a72068565683ac35296226a416a524904`
- Intake README: `external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/README.md`
- Intake hash manifest: `external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/SHA256.json`
- Original supplied GLB preserved at `exports/barrosan_infrastructure_v0378_original_supplied.glb`
- Original supplied GLB SHA-256: `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`
- Repaired evaluated GLB: `exports/barrosan_infrastructure_v0378.glb`
- Repaired/imported GLB SHA-256: `a6b73bc6252b4d6cfa19cdd4c08d40468e6f1ab1ff723d5d2405ec5b2f5f6418`
- Repaired generator source SHA-256: `4d0571cdf414ddc134f006f407218a1f7d9416cd4725f595a4eb0c84f69a0cff`

The supplied artifact remains preserved and auditable. The evaluated GLB is a bounded source repair, not a silent replacement: the README and SHA manifest record both hashes.

## Render evidence

The original four iterations remain preserved in:

- `artifacts/work/v0378-iteration-01/`
- `artifacts/work/v0378-iteration-02/`
- `artifacts/work/v0378-iteration-03/`
- `artifacts/work/v0378-iteration-04/`

The bounded source-repair rerun also rendered and manually inspected all five required frames for each of four iterations:

- `artifacts/work/v0378-repaired-iteration-01/`
- `artifacts/work/v0378-repaired-iteration-02/`
- `artifacts/work/v0378-repaired-iteration-03/`
- `artifacts/work/v0378-repaired-iteration-04/`

The iteration log is `artifacts/work/v0378-iteration-log.md`. The black-frame report is `artifacts/work/v0378-black-frame-rejection-report.md`. All inspected renders are real 1920x1080 PNGs; no checkerboard, blank, black, or title-card-only frame was accepted.

## Bounded source repair attempted

The allowed source-repair lane was used once and regenerated reproducibly from the supplied generator. The repair narrowed and smoothed road shoulders, raised and conformed road surfaces, added a bridge-end blend, and shortened abutment slabs. Godot import and smoke validation passed against the repaired hash.

The rendered result is still rejected. Across all four repaired iterations, the road renders as an over-wide wall-like band with dense vertical striping/aliasing rather than a believable worn travel surface. The bridge remains a tall slab/sidewall with weak deck-to-landing integration. The repaired source did not clear the geometry/material gate.

## Exact gate failures

1. Road presentation fails the no-torn-triangular/no-wall-like-road requirement: the repaired road surface still produces dense repeated striping and an over-wide continuous band at the required camera views.
2. Bridge presentation fails the clean logical join requirement: the deck, side rails, abutments, and road landings still read as intersecting or disconnected slabs rather than one coherent crossing.
3. Terrain and bank material hierarchy remains too flat and broad for the required authored production read.
4. Sparse low-poly rocks and reeds do not establish a convincing natural riverbank transition at gameplay scale.

The recessed river and visible bridge structural parts are positive, but they are insufficient to clear the gate.

## Scorecard

| Area | Score | Gate |
|---|---:|---:|
| Terrain | 45 | FAIL (<65) |
| Road | 25 | FAIL (<65) |
| River/banks | 55 | FAIL (<65) |
| Bridge | 40 | FAIL (<65) |
| Overall | 38 | FAIL (<70) |

The repaired render is lower than the original road/bridge presentation because the raised road surfaces expose the wall-like band and striping more strongly. This is an evidence-based rejection, not a validator failure.

## Technical status

The opt-in scene, repaired intake, capture path, and smoke manifest are deterministic and isolated. The imported GLB matches the repaired intake manifest, and the preserved original GLB matches its provenance hash. The accepted runtime and v0.377 fallback/proof layer remain untouched. No success review pack was created because the visual gate did not pass.

## Validation evidence

- `npm run godot:validate:v0378-provided-infrastructure` — passed; 40 rendered PNGs across the original and repaired four-iteration sets, repaired intake/import hashes verified, original supplied hash preserved, opt-in, no gameplay.
- `npm run godot:smoke:v0378-provided-infrastructure` — passed; scene loaded and smoke manifest reports unchanged default runtime.
- `npm test` — passed; 887 tests.
- `npm run build` — passed.
- `npm run validate:content` — passed.
- `npm run validate:art-intake` — passed.
- `npm run validate:runtime-art-slots` — passed.
- `npm run validate:artifact-retention` — passed.
- `npm run godot:all` — passed.
- `git diff --check` — passed; only the existing line-ending warning was reported.

The focused validator and runtime checks pass because the implementation is technically isolated and auditable; the visual gate remains blocked by manually inspected rendered evidence.

## Safest next action

Do not start v0.379 from this result. Keep the supplied and repaired evidence available for review. If v0.378 is reopened, replace the road/landing topology with an auditable mesh authored specifically for a clean gameplay surface and materially rebuild the riverbank treatment; do not attempt to pass this kit through further camera/material tuning alone.

**BLOCKED — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET**
