# v0.325 Human-First River and Hamlet Visual Naturalization

## Outcome

**READY FOR HUMAN VISUAL ENVIRONMENT REVIEW**

This checkpoint is an isolated opt-in visual slice. It is not production readiness, art lock, a gameplay checkpoint, or a full-world conversion.

## Base and scope

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `670ebd4c7468d44dfb52c8c2f7f6b098956e22bd` (v0.324 closeout)
- Scene: `desktop-spikes/godot-salto/visual_vertical_slice/V0325HumanRiverNaturalization.tscn`
- Capture command: `npm run godot:capture:salto-v0325-human-river-naturalization`
- Review pack: `artifacts/manual-review/v0325-human-river-naturalization/UPLOAD_TO_CHAT/`

v0.324 passed technical topology checks but was rejected before human review because its water read as a straight cyan road with white dashes, dark linear edges, sharp yard decals, and undersized bridge-end masses. v0.325 addresses those visible defects only in the opt-in environment scene.

## Human-visible changes

### River course and water

- Reauthored one continuous 128-sample river centreline with five measured direction changes.
- Added gradual 21% visible width variation, including a narrower bridge section and broader downstream water.
- Removed the v0.324 isolated white flow/dash construction completely.
- Replaced the road-like highlight with one continuous, broad, low-contrast water flow region.
- Retained darker blue-green water and a recessed lower riverbed.

### Visible banks and terrain relief

- Built continuous left/right bank geometry with grass shoulder, exposed earth slope, shoreline, and muted authored bank faces.
- Water remains 0.55–0.78m below the ordinary land reference.
- Added shallow local valley relief and subtle terrain colour variation without changing gameplay geometry.
- Added a restrained set of shoreline stones and inherited reeds/vegetation.

### Yards and paths

- Replaced circular/polygonal-looking pads with filled authored worn-earth yard surfaces.
- Principal yard is broader at the door and narrows toward the bridge route.
- Workshop yard includes a broad door apron and irregular side extension.
- Door-to-bridge paths are filled surfaces with 2.56m total width and no route/helper outline.

### Bridge and abutments

- Preserved bridge scale and traversal alignment.
- Added substantial true-3D base, face, capstone, and retaining-wing masses at both ends.
- Kept deck-to-abutment contact and filled paths over both approaches.

## Measurements

| Contract | Result |
|---|---:|
| River centreline samples | 128 |
| River cross-sections | 32 |
| Direction changes | 5 |
| Longest straight run | 23% |
| Water width | 2.74–3.48m |
| Width variation | 21% |
| Visible bank slope width | 1.25–2.65m |
| Water drop below land | 0.55–0.78m |
| White water-mark objects | 0 |
| Black border objects | 0 |
| Principal/workshop sharp corners | 0 / 0 |
| Visible PLAYER helper lines | 0 |
| Route connectivity | true / true |
| Abutment contacts | north true, south true |
| Floating bridge entrances | 0 |
| Local terrain height range | 0.86m |

## Preservation

- v0.323 roof measurements remain unchanged: principal rise 1.22000026702881m, secondary rise 1.12000012397766m; actual roof vertices 12/12; invalid normals 0/0; self-intersections 0/0; chimney and ridge-cap contacts true.
- v0.322 MP4 SHA remains `8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84`.
- Default runtime, gameplay, movement, pathfinding, combat, AI, economy, resources, saves, and stable IDs are unchanged.
- The v0.324 and v0.303 fallback/debug layers remain intact.

## Continuous media

- File: `08_CONTINUOUS_RIVER_NATURALIZATION.mp4`
- SHA-256: `fc01eb31f4912db12a1e4191e36f1076cf458d10046aa6605dbcfa0e6e7ca106`
- Codec: H.264
- Dimensions: 1280x720
- FPS: 24
- Duration: 11 seconds
- Decoded frames: 264
- Unique decoded frames: 264
- Post-copy hash verified: true
- Post-validation hash verified: true

The MP4 is genuine continuous Godot runtime evidence: camera movement is smooth, the worker choreography is visual-only, and the capture finishes at the ordinary PLAYER framing.

## PLAYER hygiene

Clean captures retain the resource bar, minimap, selected card, selection ring, and command row. They contain no DEBUG, REVIEW, PROTOTYPE, centreline measurements, cross-section counts, orange helpers, yard outlines, validator prose, white water dashes, or black water-border objects.

## Review pack

`artifacts/manual-review/v0325-human-river-naturalization/UPLOAD_TO_CHAT/` contains exactly ten files:

- `00_READ_ME_FIRST.md`
- `01_V0324_TO_V0325_COMPARISON.png`
- `02_CLEAN_PLAYER_OVERVIEW.png`
- `03_UPSTREAM_AND_DOWNSTREAM.png`
- `04_VISIBLE_BANK_CROSS_SECTION.png`
- `05_YARDS_AND_FILLED_PATHS.png`
- `06_BRIDGE_ABUTMENTS.png`
- `07_ORDINARY_GAMEPLAY.png`
- `08_CONTINUOUS_RIVER_NATURALIZATION.mp4`
- `compact-evidence-summary.json`

The full evidence directory retains the real-render contact sheet, compact summary, continuous-media audit, and black-frame/rejected-capture report. The visual comparison uses the actual v0.324 rejected PLAYER render beside the actual v0.325 render.

## Dedicated validator

Primary command:

`npm run godot:validate:salto-v0325-human-river-naturalization`

Focused commands:

- `npm run godot:validate:salto-v0325-river-curvature`
- `npm run godot:validate:salto-v0325-bank-visibility`
- `npm run godot:validate:salto-v0325-forbidden-water-marks`
- `npm run godot:validate:salto-v0325-yard-outlines`
- `npm run godot:validate:salto-v0325-path-connectivity`
- `npm run godot:validate:salto-v0325-bridge-abutments`
- `npm run godot:validate:salto-v0325-player-hygiene`
- `npm run godot:validate:salto-v0325-final-media`

The validator rejects the checkpoint for road-like water cues, white marks, black borders, disconnected paths, sharp yard corners, floating bridge entrances, PLAYER helper text, roof regression, media failure, or default/gameplay mutation. Technical component success does not override those human-visible rejection rules.

## Validation and CI

Dedicated v0.325 capture/pack/aggregate validation passed after direct inspection of the authoritative overview, upstream/downstream comparison, bank cross-section, yard/path, bridge-abutment, and v0.324 comparison images.

The retained v0.324 through v0.303 validators, v0.259 invariant validator, tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check` all passed locally before closeout. The implementation commit `a1e3fccfa80f0b0f9d5e2b7edf9587bce4d74513` completed GitHub Actions run `29492514132` successfully for that exact pushed SHA. This documentation-only closeout records the final evidence; its own exact-SHA CI result and the final synchronized repository state are recorded in repository history.

## Files added

- `desktop-spikes/godot-salto/scripts/v0325_human_river_naturalization.gd`
- `desktop-spikes/godot-salto/visual_vertical_slice/V0325HumanRiverNaturalization.tscn`
- `tools/godot/captureGodotV0325HumanRiverNaturalizationWindows.ps1`
- `tools/godot/buildV0325HumanRiverNaturalizationPack.py`
- `tools/godot/saltoV0325HumanRiverNaturalizationTool.mjs`
- this report
