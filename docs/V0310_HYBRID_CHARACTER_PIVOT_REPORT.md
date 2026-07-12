# v0.310 Hybrid Character Pivot Report

## Executive verdict

**ADOPT HYBRID BILLBOARD CHARACTERS.** The recovered Barrosan Worker and Militia cards materially outperform the v0.309 primitive U3 control at the intended gameplay camera. H3 is the preferred method because it combines authored 2.5D character identity with grounded 3D shadows, selection rings, normal occlusion, and deterministic world-facing direction selection.

This is an isolated opt-in feasibility checkpoint. It does not integrate into the true default runtime.

## Why Route C pivoted

v0.309 accepted the Route C environment as a technical stage but rejected the all-low-poly character execution for player-facing production. The remaining gap was character anatomy, role identity, equipment silhouette, grouping quality, and production cost at gameplay scale. v0.310 therefore changes only the visible character method and preserves the retained Route C environment.

## Preserved v0.309 environment

The East bridge / river / road / Field Barracks / storehouse environment, orthographic oblique camera, terrain geometry, building footprints, bridge, water, gameplay positions, state semantics, and fallback/debug renderer remain recoverable and unchanged.

## Repository asset recovery

The audit recovered the repository-authored Worker lineage from v0.147/v0.148 and Militia lineage from v0.155. Existing fallback silhouettes remain technical controls only. No external, purchased, scraped, or protected asset was used.

## Provenance

Runtime sources:

- `desktop-spikes/godot-salto/assets/v0310/barrosan_worker_v0147_source.png`
- `desktop-spikes/godot-salto/assets/v0310/barrosan_militia_v0154_source.png`

These are exact repository-authored cutout sources copied from the retained v0.147 and v0.155 artifact lineage. No protected assets were used. H3 direction cards are deterministic in-memory derivatives. Mirror use is limited to a bounded recovery proof; asymmetric hand, shield, and equipment authoring remains a documented follow-up cost.

## H1 U3 control

H1 is the inherited v0.309 low-poly Worker/Militia method. It was not improved. It provides the same environment, scale, positions, and gameplay footprint for comparison.

## H2 full billboard

H2 uses one conventional camera-facing transparent quad per unit, a 3D contact shadow, and a separate selection ring. It is materially more attractive than H1 but can read as a paper card in some views.

## H3 directional hybrid

H3 uses the recovered authored cards with eight world-facing direction entries: north, north-east, east, south-east, south, south-west, west, north-west. It uses invisible gameplay proxies, grounded 3D shadows, separate selection rings, normal depth sorting, and the retained oblique camera. It is the preferred bounded production method.

## Worker result

The Worker immediately communicates civilian labour, practical clothing, tool equipment, head/torso/leg silhouette, and grounded weight. H3 worker quality: **86/100**.

## Militia result

The Militia immediately communicates armed local defender through shield, spear, helmet, and a stronger stance while retaining the same Barrosan material language. H3 militia quality: **87/100**.

## Directional result

Eight world-facing cards are selected from the unit-facing metadata, not camera position. The current source lineage provides one authored three-quarter pose per role, so mirrored directions are explicitly marked as a recovery approximation rather than falsely presented as eight authored poses.

## Animation proof

The checkpoint proves static idle, walk-pose, work-pose, and ready-pose evidence only. It does not claim a finished walk animation system. There is no sprite hopping, size pulsing, or false frame-rate score.

## Grounding

Grass, road, bridge, shoreline, and building-adjacent views retain the exact gameplay origin and add restrained elliptical 3D contact shadows. Billboard feet are anchored to the proxy origin; no movement, pathfinding, or height mutation was added.

## Occlusion

Storehouse, bridge rail, and depth-crossing captures prove that H2/H3 use normal 3D depth relationships and are not always-on-top. The bridge and building geometry remain the occlusion authorities.

## Selection

Selected worker and militia subsets use separate restrained 3D selection rings. No new gameplay action, HUD button, global prompt, or selection semantic was introduced.

## Gameplay-scale formations

The pack includes six workers, six militia, mixed 12-unit, mixed 24-unit, compressed, bridge, road, shoreline, storehouse-adjacent, selected-subset, and clean views. Worker versus militia remains readable without text labels at intended gameplay framing.

## Visual coherence

H3 is the least intrusive treatment: it keeps the cool Barrosan highland environment, orthographic oblique projection, weathered material palette, contact shadows, bridge, storehouse, and normal occlusion. It improves character identity without recolouring the environment to rescue the sprites.

## Performance

The manifest records comparison counts at 12, 24, 50, and 100 units. H1 is geometry-heavy. H2 and H3 use one transparent quad per unit. H3 adds cached directional textures per role and therefore has alpha/memory cost but no per-unit mesh growth.

## Texture memory

Two 512px source cards are loaded. H3 caches eight in-memory derivatives per role. A future production slice should atlas authored directions before scaling beyond the two-role pilot.

## Production authoring cost

H3 requires eight directions, animation policy, faction variants, equipment variants, atlasing, revision discipline, and visual QA. That cost is acceptable for a two-role pilot but not yet a full-faction commitment. Rigged stylized 3D remains the fallback if the narrow pilot fails.

## Faction scalability

H3 is suitable for a narrow Worker/Militia integration lane with rollback. Full faction scale must be separately budgeted; the single recovered source per role does not justify awarding full-faction production readiness.

## Comparison with v0.141 aspiration

The recovered v0.141 target remains reference-only and still leads in environmental density and authored atmosphere. H3 closes the character readability gap without pretending to close the entire environment gap.

## Scorecard

| Measure | Score | Type |
|---|---:|---|
| H1 Worker / Militia | 53 / 55 | visual |
| H2 Worker / Militia | 82 / 84 | visual |
| H3 Worker / Militia | 86 / 87 | visual |
| Direction coherence | 78 | visual |
| Animation proof | 61 | visual |
| Grounding | 84 | visual |
| Occlusion | 82 | visual |
| Selection clarity | 85 | visual |
| Mixed 12 readability | 84 | visual |
| Mixed 24 readability | 78 | visual |
| Gameplay overview | 82 | visual |
| Environment coherence | 80 | visual |
| H1 / H2 / H3 technical method | 72 / 81 / 84 | technical |
| Production readiness | 78 | production |

Scores exclude validator coverage, report completeness, and CI success.

## Remaining limitations

- source lineage is one authored pose per role, not eight individually authored directions;
- animation proof is static pose evidence only;
- H3 alpha and direction-texture memory needs atlasing before roster expansion;
- the v0.141 environment remains an aspiration, not a v0.310 scope target.

## Final ADOPT decision

**ADOPT HYBRID BILLBOARD CHARACTERS.** H3 is materially stronger than H1, remains readable at gameplay scale, preserves 3D grounding and occlusion, and is technically bounded enough for a narrow opt-in integration pilot.

## Exact v0.311 scope

**A narrow opt-in production integration slice for only the Barrosan Worker and Militia, preserving fallback and rollback.** It must not broaden the roster, change gameplay semantics, or alter the true default runtime without a separate checkpoint.

## Preserved state

- accepted gameplay/state chain and Pressure 70/100;
- stable IDs and saves;
- movement, pathfinding, combat, economy, resource, and production semantics;
- true default runtime;
- v0.303 fallback/debug renderer;
- v0.309 rejected Route C proof;
- no default-runtime integration;
- no protected assets.

## Validation

Dedicated command: `npm run godot:validate:salto-hybrid-character-pivot`.

Capture command: `npm run godot:capture:salto-hybrid-character-pivot`.

The dedicated validator checks isolated opt-in status, H1/H2/H3 existence, provenance, eight-direction evidence, grounding, bridge/storehouse occlusion, selection, formations, real decoded captures, exact ADOPT/REJECT outcome, recoverability, and forbidden gameplay mutation.

Retained validation is required for v0.309, v0.308, v0.307, v0.306, v0.305, v0.304 where compatible, and v0.303, followed by tests, build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.

## CI evidence

Base v0.309 exact CI: commit `cf2a363cacd49c6c2b255c7f24353f46bb44300f`, Actions run `29205134114`, success.

The final v0.310 implementation SHA and exact Actions run will be recorded after the clean local validation, push, and final report closeout.

## Final repo state

Closeout requires the branch to be clean and synced with origin at 0 ahead / 0 behind.
