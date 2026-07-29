# v0.309 Route C Final Integration Gate

## Executive verdict

v0.309 completes the last permitted Route C isolation checkpoint. It adds a bounded terrain-contact pass, matched water-flow evidence, three authored U3-W variants, three authored U3-M variants, a 12-unit mixed formation, and limited storehouse cohesion detail. The principal gameplay renders improve the evidence, but they do not meet the production integration bar.

**Final decision: PIVOT ROUTE C.**

This is a decisive pivot, not an open-ended isolated revision. Exact v0.310: **v0.310 — bounded hybrid environment/character pivot prototype for player-facing unit readability**.

## v0.308 accepted findings

v0.308 established the U3 low-poly strategy, authored single worker/militia candidates, a finished utility storehouse, deterministic water proof, and an opt-in isolated scene. Those findings remain accepted as technical feasibility evidence.

## Why v0.308 was not integrated

Human review identified terrain as the dominant weakness, water as too much of a colored channel, repetitive/toy-like unit execution, and insufficient Barrosan highland cohesion. The honest v0.308 readiness was approximately 71–73/100, below the integration threshold.

## Terrain-contact result

v0.309 adds low-profile grass/earth, road/earth, wet-bank transitions, bank cut faces, drainage patches, embedded erosion stones, and softened edge treatment. The terrain reads more connected at gameplay scale, but the representative island still exposes a constructed low-poly boundary in the principal frame. Rendered score: **78/100**.

## Water result

Matched flow-off/on captures show directional value bands, deep/shallow distinction, wet shoreline darkening, bank contact, bridge contact, rock disturbance, and limited foam. The motion remains deterministic and restrained, but the river still reads more like authored channel geometry than production water. Rendered score: **74/100**.

## Worker-variant result

The U3-W family contains axe/tool, pack/carry, and builder/hammer variants. They share worker semantics and footprint while varying head silhouette, carried equipment, pack, and shoulder details. Rendered family score: **79/100**.

## Militia-variant result

The U3-M family contains spear/round-shield, axe/smaller-shield, and polearm/billhook variants. They share the militia family while varying weapon and shield profiles. Rendered family score: **80/100**.

## Mixed-formation result

The six-worker plus six-militia formation remains class-distinguishable in loose, compressed, bridge, shoreline, road, selected-subset, and storehouse-adjacent views. It still reads as a repeated low-poly token family at the intended zoom. Rendered score: **78/100**.

## Storehouse cohesion

The v0.308 storehouse remains in its original placement and footprint. v0.309 adds only a functional crate and restrained damp lower-wall treatment. Its slate, timber, stone, drainage, and moss language remains coherent with the sector. Rendered score: **82/100**.

## Material and atmosphere result

The cool damp highland palette separates damp grass, exposed soil, compacted road, wet bank, dry/wet stone, weathered timber, slate, deep/shallow water, leather, wood, iron, and restrained teal/gold accents. Atmosphere off/on captures show restrained haze and contact shadows without bloom, mirror water, orange regression, or sci-fi styling. Atmosphere score: **76/100**.

## Gameplay-camera result

The principal verdict uses the stable orthographic oblique gameplay camera at intended scale. The clean overview, mixed 12-unit view, selected groups, bridge crossing, road contact, shoreline, storehouse adjacency, and atmosphere comparisons are primary evidence. Close-ups and top-down frames are supporting evidence only. Gameplay overview score: **77/100**.

## Performance

The runtime manifest records approximate mesh-instance and draw-call counts, six authored variants, twelve formation units, zero new runtime art slots, and no animation system. The capture remains deterministic. The technical method is viable, but this does not overcome the player-facing quality gap.

## Production cost

U3 strategy method score: **84/100**. Production scalability score: **72/100**. The authored low-poly method is structurally reusable, but every faction expansion adds equipment, silhouette, source-art, animation, and density cleanup burden. Production-readiness score: **62/100**.

## Production scalability

The current character execution does not scale to the required player-facing roster quality at acceptable cost. The next bounded direction should retain the authored environment language while moving player-facing unit readability to authored directional sprite/billboard cards, with a small 3D hero exception.

## Comparison with v0.141

The v0.141 image remains reference-only and is substantially ahead in atmosphere, terrain continuity, material richness, environmental density, and cohesion. v0.309 closes selected evidence gaps but does not reach that player-facing standard.

## Remaining visual gap

- terrain still exposes a low-poly constructed-island boundary;
- water flow/contact remains stylized proof geometry;
- unit families remain repetitive and toy-like at gameplay scale;
- environmental density and authored cohesion remain below the reference target;
- production-readiness is below the integration threshold.

## Final PIVOT decision

**PIVOT ROUTE C.** Do not integrate the current Route C low-poly character execution into the production runtime. The exact alternative is a **hybrid environment/character split**: retain the authored low-poly environment language, move the player-facing unit roster to authored directional sprite/billboard cards, and reserve a small 3D hero exception.

## Exact v0.310 scope

**v0.310 — bounded hybrid environment/character pivot prototype for player-facing unit readability**

The next slice must prototype only the hybrid character presentation against this representative sector, compare it at intended gameplay zoom, and end with a bounded accept/reject decision. It must not integrate the current Route C character execution or broaden gameplay scope.

## Preserved state

- accepted gameplay/state chain and Pressure 70/100;
- stable IDs, saves, true default runtime, and v0.303 fallback/debug renderer;
- v0.305–v0.308 recoverability;
- no gameplay, movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resource, pressure, or production integration changes;
- no protected assets.

## Validation

Dedicated command: `npm run godot:validate:salto-route-c-final-integration-gate`.

Capture command: `npm run godot:capture:salto-route-c-final-integration-gate`.

The dedicated validator requires isolated runtime flags, three worker variants, three militia variants, a 12-unit formation, terrain/water/bridge/storehouse/gameplay evidence, performance/cost evidence, real non-blank PNGs, reference-only lineage, recoverable earlier checkpoints, and an exact `PIVOT ROUTE C` decision. No intermediate revise outcome is accepted.

Retained validators: v0.308, v0.307, v0.306, v0.305, v0.304 where compatible, and v0.303.

Full local validation includes tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## CI evidence

Implementation commit: `60f9776593a622420038060ee542f9ac6dcb81f9`.

Exact GitHub Actions run: `29204820318` (`CI Release Matrix Dry Run`) — completed successfully for the implementation SHA.

The final report-bearing closeout commit and its exact-SHA run are recorded in the final task closeout after this documentation update.

## Final repo state

Closeout requires the branch to be clean and synced with origin at 0 ahead / 0 behind.
