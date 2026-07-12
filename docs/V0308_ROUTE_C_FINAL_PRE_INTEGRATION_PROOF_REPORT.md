# v0.308 Route C Final Pre-Integration Proof

## Executive verdict

v0.308 is a bounded, opt-in Route C proof slice. It improves the v0.307 prototype with genuinely authored U3-W and U3-M low-poly units, less plate-like terrain edges, deterministic water-flow/contact evidence, and a completed Barrosan utility storehouse. The evidence is materially stronger, but the slice is not yet ready for production integration.

**Final decision: REVISE_ONCE_MORE.**

The next checkpoint is exactly: **v0.309 — Route C final authored silhouette and terrain-edge correction before integration gate**. This is a bounded correction proposal, not permission to continue indefinitely in isolation.

## Human correction to v0.307 score

The earlier v0.307 report overstated its rendered visual quality at 78/100. The honest v0.307 visual-quality score for this comparison is **72/100**. Its U3 method remains promising, but the rendered prototype still showed plate-like terrain, weak river contact, and an unfinished utility roof.

## Why v0.307 was not integration-ready

The U3 concept was the right technical direction, but the prior render did not yet prove authored unit anatomy, finished architecture, natural terrain continuity, or sufficiently convincing water contact at gameplay scale. v0.141 remains substantially ahead in atmosphere, terrain density, material richness, and environmental cohesion.

## U3-W result

U3-W is a repository-authored low-poly Barrosan worker/pioneer with a cap, head, torso, separated arms and legs, boots, pack, apron, faction accent, and pickaxe. Selected/unselected, alternate oblique, top-down, road, bridge, shoreline, and group evidence are captured. Rendered visual-quality score: **76/100**.

## U3-M result

U3-M is a repository-authored low-poly Barrosan militia/defender with helm, shoulder line, head, separated limbs, boots, shield and boss, spear and head, and restrained faction accent. It is distinct from U3-W without oversized fantasy armor or sci-fi styling. Rendered visual-quality score: **78/100**.

## Mixed-unit readability

The worker and militia remain distinguishable in the mixed group and at intended gameplay framing. The group proof scores **80/100** for current rendered readability. Equipment and silhouette variants are modular enough for a production spike, but density and occlusion need one more bounded correction.

## Terrain-edge result

The representative slice now uses irregular landform outlines, bank cuts, sloped shoulders, wet-soil transitions, grass-to-earth breaks, embedded stones, and restrained environmental dressing. The large rectangular debug-pad treatment is absent from the prototype view. Some low-poly land boundaries still read as authored plates at secondary angles, so the environment score is **76/100**, not an integration pass.

## River/water result

The river has a deep channel below land, shallow shelf, wet bank transition, directional flow bands, bridge-contact foam, rock contacts, and deterministic flow on/off captures. The treatment is restrained and readable, though it remains a stylized proof rather than a production water solution.

## Utility-building result

The finished Barrosan utility storehouse has limewashed walls, dark timber, stone foundation, framed entrance, windows, finished slate roof, ridge cap, eaves, gutter, drain pipe, chimney, porch, and damp moss foot. It no longer reads as exposed framing. Current rendered visual-quality score: **80/100**.

## Material hierarchy

The slice separates damp grass, exposed earth, compacted road, wet bank soil, dry/wet stone, dark timber, weathered slate, deep/shallow water, worker gold, and militia teal. The palette remains a cool damp highland Barrosan direction without sci-fi, lava, bloom, or tropical-water drift.

## Environmental density

Density is restrained to rock clusters, sparse trees, posts, logs, crates, rubble, wet patches, and shoreline contacts. It supports tactical readability rather than forming a decorative diorama.

## Gameplay-camera result

The primary verdict uses the stable orthographic oblique gameplay camera at intended scale, with direct top-down and alternate-oblique comparisons as secondary evidence. The camera is not a new navigation system and does not affect gameplay objects.

## Performance

The slice uses simple authored primitive meshes and no new runtime art slots, animation system, movement, or gameplay update. Technical feasibility is strong for a bounded prototype; production performance still needs measurement after density and source assets are expanded.

## Production cost

U3 technical strategy: **88/100**. It provides a reusable low-poly role shell with modular equipment and no animation burden in this checkpoint. Production scalability: **78/100**. Terrain-edge authoring and faction/unit expansion are the largest costs.

Final Route C readiness: **74/100** rendered visual quality. The method is technically feasible, but the current slice is not yet ready for production integration.

## Comparison with v0.141

The v0.141 image is reference-only. It remains ahead in atmospheric cohesion, environmental density, material richness, and integrated authored detail. v0.308 is a feasible low-poly method proof, not a claim of parity.

## Remaining weaknesses

- terrain continuity still exposes low-poly authored boundaries at secondary angles;
- water flow/contact is deterministic proof geometry, not a final shader/material solution;
- U3 units are authored and readable but still need production-quality source art and variant coverage;
- the storehouse is finished for the slice but not a complete production roster;
- the gap to v0.141 remains visible in atmosphere and environmental cohesion.

## Exact integration decision

**REVISE_ONCE_MORE.** Do not integrate Route C into the default runtime in v0.308. The prototype remains opt-in and isolated.

## Exact recommended v0.309

**v0.309 — Route C final authored silhouette and terrain-edge correction before integration gate**

Scope should be limited to terrain-edge continuity and final authored unit silhouette/source-art correction, followed by a decisive integrate/revise/pivot gate.

## Preserved state

- accepted gameplay/state chain and Pressure 70/100;
- stable IDs, saves, true default runtime, and the v0.303 fallback/debug renderer;
- v0.305/v0.306/v0.307 recoverability;
- no movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resource, pressure, or production integration changes;
- no protected game assets and no large unapproved asset import.

## Validation

The dedicated command is `npm run godot:validate:salto-route-c-final-pre-integration-proof`. The capture command is `npm run godot:capture:salto-route-c-final-pre-integration-proof`. The validator requires real decoded non-blank PNGs, the isolated scene/manifest, U3-W/U3-M/comparison contracts, finished utility/water/terrain evidence, explicit `REVISE_ONCE_MORE`, reference-only lineage, and scope-safe changes.

Retained validators: v0.307, v0.306, v0.305, v0.304, and v0.303 are run from compatible clean/artifact-bearing checkouts as required by their historical scope gates.

Full local validation includes tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## Review pack

`artifacts/manual-review/v0308-route-c-final-pre-integration-proof/`

The pack contains real rendered captures, fourteen quality/technical contact sheets, comparison references, registers, capture manifest, rejected-capture register, honest scorecard, and validator report. v0.141, v0.307, and v0.303 references are explicitly reference-only or fallback/debug evidence.

## CI evidence

Implementation commit: `26058a420dd04fe416acb55f03fbb8a28dd0dea0`.

Exact GitHub Actions run: `29200065237` (`CI Release Matrix Dry Run`) — completed successfully for that SHA.

The final report-bearing documentation closeout commit and its exact-SHA CI result are recorded in the final repository audit.

## Final repo state

Closeout requires the branch to be clean and synced with origin at 0 ahead / 0 behind.
