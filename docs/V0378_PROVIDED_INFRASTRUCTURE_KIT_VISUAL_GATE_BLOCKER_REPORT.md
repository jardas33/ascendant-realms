BLOCKED — V0378 PROVIDED INFRASTRUCTURE KIT VISUAL GATE NOT MET

# v0.378 supplied infrastructure kit visual gate blocker report

## Scope

v0.378 imported the exact supplied authored infrastructure GLB into an isolated, opt-in Godot scene for a bounded terrain/road/riverbank/bridge visual gate. The scene contains no buildings, units, gameplay, HUD, or production-runtime mutation.

## Baseline and provenance

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `9d9ef05a72068565683ac35296226a416a524904`
- Intake README: `external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/README.md`
- Intake hash manifest: `external-art-intake/original-barrosan/v0378-authored-infrastructure/docs/SHA256.json`
- Supplied GLB: `external-art-intake/original-barrosan/v0378-authored-infrastructure/exports/barrosan_infrastructure_v0378.glb`
- Imported GLB: `desktop-spikes/godot-salto/assets/v0378/provided-infrastructure/barrosan_infrastructure_v0378.glb`
- Supplied/imported GLB SHA-256: `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`

## Render evidence

Four bounded iterations were rendered at 1920x1080 and manually inspected:

- `artifacts/work/v0378-iteration-01/`
- `artifacts/work/v0378-iteration-02/`
- `artifacts/work/v0378-iteration-03/`
- `artifacts/work/v0378-iteration-04/`
- Iteration log: `artifacts/work/v0378-iteration-log.md`
- Black-frame report: `artifacts/work/v0378-black-frame-rejection-report.md`

The renders prove that the GLB loads and includes continuous land, recessed water, road sections, bridge deck, rails, supports, abutments, rocks, and reeds. They do not meet the required visual bar.

## Exact gate failures

1. The road repeatedly shows pointed/torn triangular fragments in the primary and road-detail views. This fails the explicit no-torn-triangular-road requirement.
2. The bridge reads primarily as a tall sidewall/slab with hard landing intersections instead of a clean logical deck-to-bank join.
3. Terrain, road, and bank values are too flat and broad for a production-quality authored material hierarchy.
4. Sparse low-poly rock/reed dressing does not establish a convincing natural bank transition at gameplay scale.

The recessed river and the presence of bridge structural parts are positive, but they are insufficient to clear the gate. A camera/lighting-only adjustment did not resolve the underlying geometry/material defects.

## Scorecard

| Area | Score | Gate |
|---|---:|---:|
| Terrain | 45 | FAIL (<65) |
| Road | 35 | FAIL (<65) |
| River/banks | 55 | FAIL (<65) |
| Bridge | 50 | FAIL (<65) |
| Overall | 46 | FAIL (<70) |

## Technical status

The opt-in scene and capture path are deterministic and isolated. The exact GLB hash matches the intake manifest. The current accepted runtime and v0.377 fallback/proof layer remain untouched. No source regeneration was attempted because the requested primary artifact is the supplied GLB; repairing its source would require a new, explicitly audited geometry intake.

## Validation evidence

- `npm run godot:validate:v0378-provided-infrastructure` — passed; 20 rendered PNGs, supplied GLB hash verified, opt-in, no gameplay.
- `npm run godot:smoke:v0378-provided-infrastructure` — passed; scene loaded and smoke manifest reports unchanged default runtime.
- `npm test` — passed; 887 tests.
- `npm run build` — passed.
- `npm run validate:content` — passed.
- `npm run validate:art-intake` — passed.
- `npm run validate:runtime-art-slots` — passed.
- `npm run validate:artifact-retention` — passed.
- `npm run godot:all` — passed.
- `git diff --check` — passed; only the existing line-ending warning was reported.

The validator and runtime checks pass because the implementation is isolated and technically sound; the visual gate remains blocked by the inspected rendered evidence above.

## Safest next action

Do not start v0.379 from this result. If the checkpoint is reopened, repair or replace the supplied infrastructure source with an auditable road/landing topology and materially richer terrain/bank treatment, then rerun the same four-frame gate. Preserve this rejected evidence as the v0.378 blocker record.
