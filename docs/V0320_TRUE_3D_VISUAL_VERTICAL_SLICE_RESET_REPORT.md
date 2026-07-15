# v0.320 TRUE 3D Visual Vertical-Slice Reset Report

## Executive verdict

**CONTINUE TRUE 3D DIRECTION — VERTICAL SLICE REQUIRES ONE POLISH PASS**.

The isolated candidate is a genuine replacement of the flat/billboard presentation method for this visual slice: terrain, river, bridge, buildings, vegetation, resource nodes, Worker, and Militia are true 3D authored mesh assemblies under one coherent daylight model. The result clears the depth, scale, lighting, interface, and production-direction gates, but one contained polish pass remains before narrow production integration.

## Base and scope

- Base HEAD: `3ac4fd27481ff1267b23a5f597934339aa550341`
- Branch: `codex/v0215-v0226-recovery`
- Scene: `res://visual_vertical_slice/V0320VisualVerticalSlice.tscn`
- Capture command: `npm run godot:capture:salto-true-3d-visual-vertical-slice`
- Validator: `npm run godot:validate:salto-true-3d-visual-vertical-slice`

v0.320 is an opt-in presentation route only. It does not change the default launcher, accepted state chain, gameplay systems, authoritative positions, stable IDs, saves, H3 adapters, minimap data, or the current fallback/debug renderer.

## Presentation method and camera

The candidate uses **TRUE 3D STYLISED RTS** presentation. The locked camera is orthographic with approximately 45 degree yaw, 49 degree downward pitch, and orthographic size 27. It is a stable oblique RTS view with no perspective distortion or free-camera requirement. The continuous evidence performs only a capture-fixture camera pan/zoom and visual state scrub.

## World scale

The scale contract is documented in [V0320_WORLD_SCALE_BIBLE.md](V0320_WORLD_SCALE_BIBLE.md): Worker 1.80 m, Militia 1.86 m, ordinary door 2.20 m, town-hall door 2.55 m, road 3.60 m, bridge 4.00 m, dwelling wall 2.80 m, barracks wall 3.55 m, mature tree 7.50 m.

## Route and scene composition

The compact Salto settlement contains a continuous elevated terrain mesh, a recessed river with visible shoreline transition, an embedded main road and secondary paths, a thick stone-and-timber bridge with two piers and rails, a town hall, Field Barracks, Worker dwelling, storehouse, seven trees, nine rocks, an iron node, and a timber resource area. The settlement is composed around the bridge and civic cluster rather than scattered procedural rectangles.

## True 3D units and states

Worker and Militia are repository-authored `MeshInstance3D` part assemblies, not capsules, cards, billboards, or atlas sprites. Worker parts include head, torso, arms, hands, legs, boots, tunic, belt, backpack, and visible work tool. Militia parts include head, torso, arms, hands, legs, boots, tunic, padded front, helmet, shield, spear, and spearhead. Worker evidence covers idle/walk/work; Militia evidence covers idle/walk/ready. State changes are capture-fixture pose changes only; no root motion or authoritative movement exists.

## Lighting, materials, and Barrosan identity

One warm directional key and one cool ambient fill provide consistent unit/environment lighting and real directional shadows. Materials use weathered timber, granite/slate stone, rough plaster earth, dark roofs, muted teal water, and earth-tone Worker/Militia materials. The palette stays highland/Barrosan: restrained saturation, readable warm/cool separation, and no sci-fi, lava, giant black spires, or glossy mobile-game finish.

## Player interface and evidence

PLAYER captures use a compact resource strip, readable selected-unit panel, small minimap, and command row. No validator prose, IDs, UV data, collision shapes, target masks, frame counters, or evidence panels are visible. DEBUG_REVIEW remains available through the isolated flag/manifest and existing v0.319/H3 infrastructure remains untouched.

## Visual scorecard

Scores are based on the real rendered PLAYER frames in the review pack, not on validator success:

| Gate | Score |
|---|---:|
| Art-style coherence | 86 |
| 3D depth | 91 |
| Scale consistency | 88 |
| Terrain believability | 84 |
| Architectural quality | 82 |
| Unit silhouette quality | 81 |
| Unit/world lighting match | 86 |
| Bridge and water integration | 88 |
| Gameplay readability | 87 |
| PLAYER interface cleanliness | 89 |
| v0.141 ambition comparison | 78 |
| Production-direction viability | 84 |
| Overall | 85 |

## What changed

- Added an isolated true-3D vertical-slice scene and capture route.
- Added authored low-poly Worker and Militia mesh assemblies with simple pose states.
- Added real elevated terrain, recessed water, embedded roads, structural bridge, buildings, vegetation, resource nodes, and consistent lighting.
- Added world-scale bible, capture pack builder, dedicated validator, compact upload set, continuous 40-frame PLAYER GIF, and visual scorecard.

## What did not change

- No default-runtime integration.
- No gameplay/state-chain, movement, pathfinding, combat, damage, HP, AI, waves, economy, production, resource, pressure, save, stable-ID, minimap-data, or authoritative-position changes.
- No v0.319/H3 static or animated adapter changes.
- No deletion or invalidation of the billboard fallback assets; billboards used in v0.320 PLAYER candidate: no.

## Comparison and recommendation

The v0.320 render is materially deeper and more coherent than the accepted fallback/procedural presentation, and it is closer in ambition to the recovered v0.141 target. It is not yet a full Salto conversion. Recommended v0.321 is one narrow polish pass for architectural trim/roof variation, water edge refinement, and compact UI spacing, followed by another rendered gate. Do not wire this slice into the default runtime until that gate is accepted.

## Review pack and validation

Review pack: `artifacts/manual-review/v0320-true-3d-visual-vertical-slice/` with compact upload set under `UPLOAD_TO_CHAT/` (14 files). Full evidence includes runtime manifest, scale bible, camera/lighting settings, material manifest, model hierarchy, animation audit, performance audit, DEBUG_REVIEW note, contact sheets, and black-frame rejection report.

Dedicated validator: `tools/godot/saltoV0320True3DVisualVerticalSliceTool.mjs`.

Local validation evidence completed before commit:

- dedicated v0.320 validator: pass (`11` rendered primary captures, `14` compact upload files);
- retained v0.319 through v0.311 validators: pass;
- retained v0.310 through v0.303 validators: pass in a reversible clean-v0.319 isolation because historical scope guards reject later uncommitted files;
- v0.259 UI-state invariant validator: pass after regenerating its missing ignored evidence pack;
- `npm test`: `887` tests passed;
- `npm run build`: pass;
- `npm run validate:content`: pass;
- `npm run validate:art-intake`: pass;
- `npm run validate:runtime-art-slots`: pass (`52` slots);
- artifact-retention validator: pass;
- `npm run godot:all`: pass;
- `git diff --check`: pass.

CI evidence is recorded against the exact pushed SHA in the final closeout after publication. Final repository state is required to be clean and synced, 0 ahead / 0 behind.
