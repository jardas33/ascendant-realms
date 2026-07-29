# v0.324 Human Environment-Geometry Closure

## Outcome

**READY FOR HUMAN ENVIRONMENT GEOMETRY REVIEW**

This checkpoint closes the specific environment-geometry defects identified in the human review of v0.323. It is not an art lock, production integration, full material pass, or gameplay checkpoint.

## Base and scope

- Branch: `codex/v0215-v0226-recovery`
- Base HEAD: `45436754baeeb713eec7954c6ed7e5737dc9b7d3`
- New scene: `desktop-spikes/godot-salto/visual_vertical_slice/V0324EnvironmentGeometryClosure.tscn`
- Capture command: `npm run godot:capture:salto-v0324-environment-geometry-closure`
- Review pack: `artifacts/manual-review/v0324-environment-geometry-closure/UPLOAD_TO_CHAT/`

The new scene is opt-in and isolated. The accepted v0.323 scene, v0.303 fallback/debug layer, H3 adapters, default runtime, gameplay systems, saves, stable IDs, and accepted state chain remain outside the implementation path.

## Environment-geometry repair

The visible bridge-hamlet sector now uses one ordered 96-sample river centreline, 24 audited cross-sections, a single continuous water mesh, one connected left-bank mesh, one connected right-bank mesh, and a lower riverbed support. The water surface is cool teal rather than charcoal, remains below land, and uses short restrained flow glints rather than a continuous road-like stripe.

Measured river evidence:

- centreline samples: `96`;
- cross-sections: `24`;
- maximum heading delta: `3.8°`;
- maximum adjacent width change: `1.6%`;
- width range: `3.06–3.76 m`;
- minimum land-to-water drop: `0.54 m`;
- maximum land-to-water drop: `0.74 m`;
- left-bank components: `1`;
- right-bank components: `1`;
- water components: `1`;
- maximum gap: `0.012 m`;
- degenerate triangles: `0`;
- invalid visible normals: `0`;
- acute shoreline spikes: `0`;
- visible terminations: `0`.

Both building grounds are authored irregular terrain-following yards. The former v0.323 circular-pad construction is absent. Each yard is measured with 32 boundary samples and connected to the authored door-to-bridge route network.

| Yard | Radial coefficient of variation | Circle fit | Route connected |
| --- | ---: | ---: | --- |
| Principal | 0.2475 | 3.125% | true |
| Workshop | 0.1978 | 9.375% | true |

The bridge retains its accepted traversal line and deck identity. The new abutment audit records both ends contacting the deck and surrounding terrain/bank, two deck contacts, zero floating entrances, zero penetration, and zero traversal alignment error.

Terrain coverage remains 160×160 with zero failed viewport rays and zero background-corner matches. Local authored relief is measured at `0.78 m`, with a shallow valley and gentle building/yard transitions.

## Accepted v0.323 repairs preserved

The v0.323 roof meshes are inherited unchanged and re-audited from actual runtime mesh vertices/transforms:

- Principal roof: eaves `4.11999988555908`, ridge `5.34000015258789`, rise `1.22000026702881`, invalid normals `0`, self-intersections `0`, chimney contact `true`, ridge-cap contact `true`.
- Secondary roof: eaves `3.8199999332428`, ridge `4.94000005722046`, rise `1.12000012397766`, invalid normals `0`, self-intersections `0`, chimney contact `true`, ridge-cap contact `true`.
- v0.322 MP4: unchanged, SHA-256 `8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84`.

## PLAYER hygiene

The persistent `BRIDGE LINE | SALTO EAST` title is removed from the clean PLAYER HUD. Clean PLAYER captures contain no evidence/checkpoint title, validator text, geometry measurements, route-centreline helper, or debug overlay. Resource bar, minimap, selected-unit card, selection ring, and genuine command affordances remain.

The only diagnostic prose is present in the dedicated river audit image and is not part of the authoritative clean PLAYER images.

## Continuous media

The capture produces one genuine Godot-rendered continuous MP4 from 264 source frames:

- upload: `08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4`;
- SHA-256: `6a52ad989f9ba353a87c7533ae843edf77a2ad22c9db20642204f13208a616a4`;
- codec: H.264;
- dimensions: 1280×720;
- FPS: 24;
- duration: 11 seconds;
- decoded frames: 264;
- unique decoded frame hashes: 264;
- post-copy hash verified: true;
- post-validation hash verified: true.

## Review pack

`UPLOAD_TO_CHAT` contains exactly ten files: preflight/readme, v0.323 comparison, clean PLAYER overview, upstream/downstream river render, diagnostic cross-section audit, irregular-yard/path render, bridge-abutment render, ordinary gameplay render, continuous MP4, and compact measured JSON. The full evidence directory contains the visual-quality contact sheet, media audit, black-frame report, and proof notes.

All authoritative PNGs were reopened after capture. The visual-quality contact sheet uses real rendered images; no synthetic replacement or title-card-only evidence is used.

## Dedicated validators

- `npm run godot:validate:salto-v0324-river-course`
- `npm run godot:validate:salto-v0324-river-depth`
- `npm run godot:validate:salto-v0324-bank-continuity`
- `npm run godot:validate:salto-v0324-yard-shape`
- `npm run godot:validate:salto-v0324-bridge-contact`
- `npm run godot:validate:salto-v0324-player-hygiene`
- `npm run godot:validate:salto-v0324-final-media`
- `npm run godot:validate:salto-v0324-environment-geometry-closure`

The aggregate validator inspects the runtime manifest/audit, source geometry anchors, upload file count, roof preservation, v0.322 media SHA, river topology/depth, yard circularity thresholds, bridge contact, PLAYER hygiene, and exact upload media.

## Preservation and validation

No movement, pathfinding, bridge-crossing choreography, combat, AI, economy, resources, saves, stable IDs, pressure behavior, or default-runtime mutation is introduced. The new capture uses only visual evidence choreography inherited from the opt-in slice.

The retained v0.323 through v0.303 validators and v0.259 UI invariant validator are required at closeout, alongside tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## CI evidence and final state

Implementation commit `f135c22efb11e8cb4df116867aaec5fd968c6625` completed GitHub Actions run `29472746480` successfully for the exact pushed SHA. The documentation-only closeout commit and its exact-SHA CI result are recorded in repository history. Final verification requires the branch to remain clean and synchronized with `origin/codex/v0215-v0226-recovery` at 0 ahead / 0 behind.

## Files added

- `desktop-spikes/godot-salto/scripts/v0324_environment_geometry_closure.gd`
- `desktop-spikes/godot-salto/visual_vertical_slice/V0324EnvironmentGeometryClosure.tscn`
- `tools/godot/captureGodotV0324EnvironmentGeometryClosureWindows.ps1`
- `tools/godot/buildV0324EnvironmentGeometryClosurePack.py`
- `tools/godot/saltoV0324EnvironmentGeometryClosureTool.mjs`
- this report
