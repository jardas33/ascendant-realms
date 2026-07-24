# v0.376 Original Barrosan Art-Quality Pass -- Fail-Closed Blocker Report

## Exact status

**BLOCKED -- V0376 ORIGINAL BARROSAN ART-QUALITY GATE NOT MET**

This is an honest visual-quality blocker, not a Blender export, Godot import, runtime, or validation failure.

## Scope and baseline

- Base HEAD: `5bd7d0de17fc3ba9b87c37f78b22a7281085343c`
- Branch: `codex/v0215-v0226-recovery`
- Route: isolated opt-in prototype only
- Prototype scene: `desktop-spikes/godot-salto/scenes/v0376_original_barrosan_art_quality_pass.tscn`
- Blender generator: `tools/blender/generate_v0376_original_barrosan.py`
- Blender source: `art-source/blender/v0376/original_barrosan/barrosan_original_kit_v0376.blend`
- Exported GLB: `desktop-spikes/godot-salto/assets/v0376/original_barrosan/barrosan_original_kit_v0376.glb`
- Launch: `npm run godot:play:original-barrosan-quality-pass`
- Capture: `npm run godot:capture:original-barrosan-quality-pass`
- Validator: `npm run godot:validate:original-barrosan-quality-pass`

## What changed

The forked v0.376 prototype adds a bounded original Barrosan art-quality pass without changing the accepted runtime:

- one larger, uneven two-bank landform with raised shelves, damp bank levels, irregular material transition patches and a recessed stream;
- width-varied embedded roads with wear stones, bridge approaches and river reeds;
- stronger civic Main Hall silhouette with raised entry porch, civic tower, bell frame and banner;
- broader darker Field Barracks with military yard, training posts, equipment lean-to, shield rack and field banner;
- smaller domestic house with side wing, bench, barrel and warm limewash;
- granite mine face with extraction recess, embedded ochre seams, hoist frame, cart and tool crate;
- defensive hostile canopy with pitched roof, barricade entry, watch posts, weapon rack, storage, fire and dead timber;
- broadleaf trees, conifers, bushes, meadow tufts, moss clusters, rocks and river reeds;
- tighter orthographic oblique framing and warm-key/cool-fill value calibration.

## Four-iteration evidence

The required four substantial iterations were rendered at 1920x1080 and inspected frame-by-frame:

- `artifacts/work/v0376-iteration-01/`
- `artifacts/work/v0376-iteration-02/`
- `artifacts/work/v0376-iteration-03/`
- `artifacts/work/v0376-iteration-04/`
- `artifacts/work/v0376-iteration-log.md`

The first pre-import blank capture was rejected and documented at `artifacts/work/v0376-black-frame-rejection.md`. It was not scored or used as evidence.

## Visual scorecard

Scores are evidence-based, 0-10:

| Gate category | Score | Gate | Result |
| --- | ---: | ---: | --- |
| Terrain credibility | 6.8 | 7.5 | FAIL |
| Map-edge concealment | 5.5 | no critical defect | FAIL |
| Road integration | 6.6 | no critical defect | FAIL |
| Riverbank integration | 7.1 | no critical defect | FAIL |
| Bridge credibility | 8.2 | no critical defect | PASS |
| Main Hall identity | 7.0 | no critical defect | FAIL |
| House identity | 6.0 | no critical defect | FAIL |
| Barracks identity | 7.4 | no critical defect | FAIL |
| Resource readability | 7.2 | 7.5 | FAIL |
| Hostile-camp identity | 7.2 | 7.5 | FAIL |
| Vegetation quality | 6.4 | no critical defect | FAIL |
| Environmental storytelling | 6.8 | no critical defect | FAIL |
| Material cohesion | 6.8 | no critical defect | FAIL |
| Barrosan identity | 6.7 | 7.5 | FAIL |
| Lighting/value | 7.2 | no critical defect | FAIL |
| Camera/composition | 7.5 | 8.0 | FAIL |
| Immediate RTS readability | 7.7 | 8.0 | FAIL |
| Overall attractiveness | 6.9 | 8.0 | FAIL |

The candidate fails multiple threshold categories and retains critical visible defects: terrain boundary in the overview, pale board-like land, ribbon-like road/bank treatment, simple near-catalogue building language, and insufficient authored environmental density. The bridge and river are the strongest parts, but they do not compensate for the overall gate failure.

## Why this is blocked

The render is technically coherent and substantially better than v0.375, but it still reads as an authored low-poly test scene rather than a production-quality Barrosan battlefield. Material palette changes and additional props improved readability, but the remaining defects are structural:

1. the landform still resolves as a broad pale plane with visible outer boundary;
2. roads and banks still read as ribbons laid over land instead of worn terrain cuts;
3. the three main building roles remain too close in massing and simplified in facade language;
4. the mine and camp are understandable at close range but remain prop-led at overview scale;
5. vegetation and settlement work-life clusters do not yet establish a convincing highland boundary;
6. the temporary Quaternius characters remain scale references, not final faction art.

Blender-Python refinement can likely improve the terrain cut, role silhouettes, material breakup and authored dressing in another bounded art checkpoint. This does not justify integrating the prototype into gameplay or claiming the art direction is production-ready.

## Validation evidence

The technical validation path is green:

- `npm run godot:smoke:original-barrosan-quality-pass` -> `PASS_V0376_ORIGINAL_BARROSAN_ART_QUALITY_SMOKE`;
- `npm run godot:validate:original-barrosan-quality-pass` -> `PASS_V0376_ORIGINAL_BARROSAN_ART_QUALITY` with 16 rendered iteration PNGs;
- `npm test` -> 122 test files passed, 887 tests passed;
- `npm run build` -> production build passed;
- `npm run validate:content` -> passed;
- `npm run validate:art-intake` -> passed;
- `npm run validate:runtime-art-slots` -> passed, 52 slots validated;
- `npm run validate:artifact-retention` -> passed;
- `npm run godot:all` -> passed;
- `git diff --check` -> passed.

These checks prove export/import, opt-in wiring, render capture, artifact presence, and code hygiene. They do not override the failed human visual gate.

## Preservation

The accepted v0.375 source and route remain intact. The v0.376 work is opt-in and isolated. No gameplay, movement, pathfinding, route following, combat, damage, HP, AI, waves, economy, resources, selection, HUD, saves, stable IDs, production registry, pressure, true default runtime, House02 canonical source, or Barn gold canonical source was changed.

The only external content remains the previously intaken CC0 Quaternius character subset used as temporary scale references by the prototype Godot script. No protected-game asset was imported by the Blender kit generator.

## Delivery decision

No success review pack was created. The best rejected render remains under `artifacts/work/v0376-iteration-04/`. The isolated prototype, source, validator, wrappers, log, and this blocker report are retained for audit and for a future bounded art-direction decision.

Exact blocked delivery string:

`BLOCKED -- V0376 ORIGINAL BARROSAN ART-QUALITY GATE NOT MET`

## Closeout evidence

- Exact pushed commit: `68147dee719a51e6f378fbd1ffdaf53448c909ce`.
- GitHub Actions: run `30063761821` completed with `success` for that exact SHA.
- The report update below is documentary only; it does not change the prototype or its visual verdict.
- Final repo state after the documentary update: tracked changes committed and pushed; pre-existing untracked generated artifacts preserved and not deleted.
