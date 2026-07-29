# v0.377 Reference-Driven Terrain, Road, Riverbank and Bridge Production Proof

## Verdict

`BLOCKED -- V0377 REFERENCE-DRIVEN TERRAIN INFRASTRUCTURE GATE NOT MET`

The isolated Stage 1 prototype is real, opt-in, rendered, and technically feasible. It is not visually close enough to the recovered reference to pass the production-proof gate. The checkpoint is closed fail-closed with the best rejected render preserved for the next explicitly authorized checkpoint.

## Base and scope

- Base HEAD: `1a2f17c09d41f621631aeba0d82e0b10ce8f5104`
- Branch: `codex/v0215-v0226-recovery`
- Scope: continuous terrain, embedded roads, recessed river, irregular wet banks, bridge, rocks, reeds, moss and grass contact only.
- Explicitly excluded: buildings, units, mine, hostile camp, HUD work, gameplay, movement, pathfinding, combat, economy, resources, saves, stable IDs, and the true default runtime.

## Reference gate and visual result

The binding reference was `docs/art-direction/v0377-visual-reference-pack/03_TERRAIN_ROAD_RIVER_BRIDGE.png`, with the recovered art rules in `05_REFERENCE_IMPLEMENTATION_RULES.md` and acceptance checklist in `06_REFERENCE_ACCEPTANCE_CHECKLIST.md`.

Iteration 06 is a genuine wide gameplay-scale render. It proves:

- continuous 3D land with readable height variation;
- a river below the land plane;
- curved riverbanks and a bridge with deck, rails, supports and abutments;
- connected road geometry through the crossing;
- authored rocks, reeds, moss and grass contact;
- a restrained oblique orthographic RTS camera;
- a deterministic grayscale capture and reference comparison board.

It does not yet prove the required visual quality. The land is too smooth and sparse, the road shoulders are broad and diagrammatic, the bank material changes remain too clean, and the bridge/river contact lacks the dense irregular wet stone and reed language of the reference. The result therefore remains a prototype proof, not a production-ready sector slice.

## Implementation

- Blender source: `tools/blender/generate_v0377_terrain_infrastructure.py`
- Authored source record: `art-source/blender/v0377/terrain-infrastructure/README.md`
- Blender source output: `art-source/blender/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.blend`
- Imported prototype kit: `desktop-spikes/godot-salto/assets/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.glb`
- Isolated scene: `desktop-spikes/godot-salto/scenes/v0377_reference_driven_terrain_infrastructure.tscn`
- Runtime script: `desktop-spikes/godot-salto/scripts/v0377_reference_driven_terrain_infrastructure.gd`
- Launch: `npm run godot:play:v0377-terrain-infrastructure`
- Smoke: `npm run godot:smoke:v0377-terrain-infrastructure`
- Capture: `$env:V0377_ITERATION='6'; npm run godot:capture:v0377-terrain-infrastructure`
- Validator: `npm run godot:validate:v0377-terrain-infrastructure`

The capture wrapper now refreshes the isolated Godot import cache before launching the capture scene. This closes the stale-GLB evidence defect found between iterations 05 and 06.

## Iteration and evidence review

Six iteration folders are retained at `artifacts/work/v0377-iteration-01/` through `artifacts/work/v0377-iteration-06/`. Each contains six real rendered PNGs and a manifest. The iteration log is `artifacts/work/v0377-iteration-log.md`; the black-frame report is `artifacts/work/v0377-black-frame-rejection-report.md`.

No v0.377 success review pack was created because the visual gate failed. The best candidate remains in `artifacts/work/v0377-iteration-06/`.

## Technical isolation and preservation

- The route is opt-in through `--v0377-terrain-infrastructure`.
- The isolated scene is not the default scene.
- The accepted runtime state chain was not changed.
- No gameplay mutation, movement, pathfinding, route following, combat, damage, HP, AI, waves, fog gameplay, economy, resource mutation, save mutation, or stable-ID mutation was added.
- No buildings, units, mine, camp or third-party asset was imported into the Stage 1 kit.
- The current v0.376/v0.375 fallback and debug layers remain intact.

## Scorecard

| Dimension | Score | Evidence-based note |
|---|---:|---|
| Attractiveness | 36/100 | Clear prototype read, but too sparse and clean. |
| Reference closeness | 28/100 | River/bridge relationship is present; terrain language is not close enough. |
| RTS readability | 67/100 | River and bridge read immediately; roads are overly broad. |
| Terrain credibility | 34/100 | Height exists, but natural landform and contact density are insufficient. |
| Bridge credibility | 55/100 | Deck, rails, supports and abutments are legible. |
| Water/river credibility | 57/100 | Recessed and readable, but edge treatment is too regular. |
| Technical feasibility | 78/100 | Isolated Blender-to-GLB-to-Godot path works deterministically. |
| Maintainability | 73/100 | Infrastructure-only source is modular and removable. |
| Performance risk | 72/100 | Small authored kit; no production-wide systems added. |

Overall visual score: **47/100**.

Recommendation: **revise Route C once**, but only after a new explicitly authorized checkpoint with authored terrain micro-relief, irregular road shoulders, denser natural bank contact, and a more materially varied bridge landing. Do not treat this report as authorization for v0.378.

## Validation evidence

- dedicated v0.377 validator: six rendered iteration folders, 36 PNGs, manifests and Stage 1 boundary checks;
- Blender generation and Godot import/capture completed;
- visual inspection completed for all six images in iteration 06 and comparison evidence;
- no black/blank frame accepted;
- `npm test`: 122 files and 887 tests passed;
- `npm run build`: production TypeScript/Vite build passed;
- `npm run validate:content`: passed;
- `npm run validate:art-intake`: passed;
- `npm run validate:runtime-art-slots`: passed with 52 stable slots;
- `npm run validate:artifact-retention`: passed;
- `npm run godot:all`: passed;
- `git diff --check`: passed;
- exact-SHA GitHub Actions evidence is attached to the final pushed commit and reported in closeout.

## Final state

This report intentionally records an honest visual blocker. The implementation is preserved as an isolated, removable, opt-in proof kit; no accepted runtime or gameplay behavior was promoted or replaced.
