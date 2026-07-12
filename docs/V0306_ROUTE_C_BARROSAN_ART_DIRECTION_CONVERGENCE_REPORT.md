# v0.306 Route C Barrosan Art-Direction Convergence

## Executive verdict

v0.306 is a meaningful visual convergence pass, but it does not yet pass the player-facing art-direction bar. The honest result is **revise again**. Route C remains the correct technical direction to continue because it solves v0.303's flat-board failure with real 3D terrain/buildings, an oblique RTS camera, and a credible bridge crossing. It is still too sparse, low-poly, and dependent on fallback billboard mannequins to become the player-facing baseline.

- v0.305 honest score: **55/100**
- v0.306 honest score: **68/100**
- Recommendation: **continue Route C with another isolated art-direction pass**

## Base HEAD and branch

- Base HEAD: `0d69502417d84b9bd5a7ac7d4ffba2ad70997ca2`
- Branch: `codex/v0215-v0226-recovery`
- Prototype scene: `desktop-spikes/godot-salto/scenes/salto_v0306_route_c_barrosan_convergence.tscn`
- Capture command: `npm run godot:capture:salto-route-c-barrosan-convergence`

## What v0.305 proved

v0.305 proved Route C's technical architecture: a small real 3D sector can use authored terrain, a recessed river, a bridge, imported Barrosan building modules, and billboard units while remaining deterministic, isolated, and easy to capture. It clearly outperformed the v0.303 procedural PLAYER board.

## Why v0.305 was not accepted visually

The real v0.305 renders still read as bright polygonal diorama islands. The palette was toy-like, the river was nearly featureless, the bridge and landings were too clean, the support building was placeholder-quality, and the units read as thin test mannequins. The environment was far below the v0.141 R1 benchmark in naturalism, weathering, atmosphere, and world cohesion.

## Scope of v0.306

This is one isolated Route C representative-sector revision. It does not integrate Route C into the default runtime, does not migrate gameplay, and does not replace the accepted renderer. The East bridge / Field Barracks / river-crossing sector remains the only content under test.

## Terrain revision

The revision separates the land into two extruded masses and adds smaller sloped shoulders, terraces, damp grass, moss patches, soil variation, embedded rock clusters, and bank forms. The river remains below the land plane. The pass improves value separation and breaks the largest uniform planes, but overview framing still reveals low-poly island edges and broad procedural surfaces.

## Water revision

The river now uses darker recessed water, two muted directional flow bands, wet moss edges, riverbank soil, shoreline stones, and bridge-contact treatment. The implementation is deterministic and capture-safe without a production shader. It reads as cold water more reliably than v0.305, but flow and depth variation remain tonal rather than materially rich.

## Bridge/road integration

The successful v0.305 bridge topology is preserved. Timber and structural parts were shifted toward weathered charcoal/grey values, with darker rails, damp stone piers, muted planks, mossy landing contacts, and cooler embedded road shoulders. Bridge readability remains strong. The remaining gap is natural integration at the landings and the lack of small authored weathering detail.

## Field Barracks revision

The repository-authored v0.236 Field Barracks module is retained, but its materials are retuned toward dark stone, weathered timber, restrained roof value, and cooler filtered light. The building remains the strongest object in the slice and retains its readable footprint and pitched-roof silhouette. It still carries some stylized-European cues and needs more rugged, climate-specific authored detail before production use.

## Support building revision

The visibly intersecting v0.305 roof slabs were replaced with a single authored coherent gabled roof mesh, foundation, dark stone walls, entrance, timber trim, ridge cap, and a small moss ledge. It now belongs to the same material family as the Barracks, but remains a deliberate prototype blockout rather than production art.

## Unit strategy revision

Aster, Defender, and Reserve Support remain repository static billboard sources, now with slightly stronger scale, role accents, directional contact shadows, and explicit selected/unselected captures. The selection radius was reduced from v0.305. This improves grounding and selection discipline without adding animation or runtime entity behavior.

The unit strategy is viable for a prototype, but the inherited fallback figures still read as test mannequins at close distance. A cohesive Barrosan billboard source or a more detailed stylized hybrid is still required.

## Selection treatment

Selection is now a compact, low-alpha ground treatment sized to support rather than dominate the unit. Selected and unselected Aster, Defender, and Reserve Support frames are included. The treatment remains readable over grass, road, bank, and bridge while avoiding the oversized v0.305 disc.

## Lighting and palette

The pass moves from bright orange/olive toward cooler damp greens, grey stone, charcoal timber, moss, and filtered overcast mountain light. One coherent directional key and one cold sky fill preserve readable shadows. The palette is materially closer to the Barrosan highland direction, but still lacks the environmental richness and natural variation of R1.

## Matched-framing comparison

The review pack contains real PNG comparisons for full overview, terrain/road, river, bridge, architecture, units, selection, material palette, remaining weaknesses, and final human review. R1 is labelled reference-only; v0.305 and v0.306 are labelled prototype evidence. No title card is used as visual-quality proof.

## v0.305 versus v0.306 scorecard

| Category | v0.305 | v0.306 |
| --- | ---: | ---: |
| Terrain depth | 55 | 68 |
| Terrain naturalism | 45 | 58 |
| Water | 42 | 58 |
| Road integration | 63 | 72 |
| Bridge credibility | 82 | 84 |
| Architecture identity | 57 | 66 |
| Building cohesion | 62 | 70 |
| Unit silhouettes | 42 | 49 |
| Unit grounding | 61 | 69 |
| Selection treatment | 48 | 72 |
| Lighting | 68 | 74 |
| Palette | 48 | 68 |
| Material identity | 50 | 63 |
| Barrosan atmosphere | 44 | 56 |
| RTS readability | 82 | 84 |
| Distance from v0.141 target | 35 | 45 |
| Production feasibility | 84 | 82 |
| Overall | **55** | **68** |

## Comparison to v0.141 target

R1 remains an art-direction benchmark, not an asset source. v0.306 is closer in coolness, dampness, bridge readability, and material restraint, but remains far behind R1 in terrain naturalism, environmental density, shoreline complexity, atmospheric depth, and unit/world cohesion. The gap is now actionable rather than architectural: the next pass should raise authored material/environment quality, not abandon Route C immediately.

## Remaining visual gaps

- Broad terrain surfaces still expose low-poly diorama edges.
- Water flow and shoreline variation remain too uniform.
- The support building needs authored detail and stronger Barrosan identity.
- Billboard figures remain fallback-like test mannequins.
- Rocks, moss, wet stone, and road shoulders need more integrated variation.
- The scene remains below R1's environmental richness and atmosphere.

## Feasibility assessment

Route C is visually credible enough to continue as an isolated prototype, not as the player-facing baseline. The low-poly route is not inherently too far from the target; its current authored environment quality is the limiting factor. Keep Route C, raise material/environment quality, and be prepared to pivot toward a more detailed stylized 3D route only if the next isolated pass cannot close the naturalism gap. Billboard units remain viable for the next pass if their source silhouettes are replaced or materially strengthened.

## Recommendation: revise again

Continue Route C with one more tightly bounded art-direction pass. Do not integrate it into the true default runtime yet. Do not add gameplay to make the prototype feel richer.

## Exact recommended v0.307

**v0.307 — Route C Authored Terrain Edge, Barrosan Architecture Detail, and Unit Silhouette Production Spike**

One isolated sector only: replace broad procedural terrain surfaces with authored edge/shoulder modules, add a small weathered stone/moss detail kit, deepen the support building and Barracks material language, and replace the three fallback billboard figures with one cohesive repository-authored Barrosan silhouette set. Re-score against the same R1/v0.305/v0.306 framing. No runtime migration or gameplay integration.

## Preserved state

- accepted gameplay/state chain
- Pressure 70/100
- stable IDs and saves
- true default runtime
- v0.303 debug/fallback renderer
- v0.305 Route C assets recoverable
- no movement, pathfinding, combat, economy, resource, pressure, or production integration changes
- no protected-game assets or copied expression

## Validation

Required closeout validation:

- dedicated v0.306 validator
- retained v0.305 validator
- retained v0.304 validator from a clean baseline-compatible checkout
- v0.303 validator
- `npm test`
- `npm run build`
- content, art-intake, and runtime-art-slot checks
- artifact-retention validator
- `npm run godot:all`
- `git diff --check`

The v0.306 review pack contains the real non-blank rendered evidence and rejected-capture register. Exact CI evidence is recorded after the final pushed SHA completes.

## Final repo state

Recorded after commit, push, exact-SHA GitHub Actions verification, and clean-sync audit.
