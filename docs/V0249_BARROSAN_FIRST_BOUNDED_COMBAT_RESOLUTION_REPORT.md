# v0.249 Barrosan First Bounded Combat Resolution Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `cca1b455cbda9df2873e972d9ba4528f6271a7b7`.
- v0.248 implementation commit: `6c5cfa196e31229b3c976254212114dcbeeef473`; documentation closeout/base: `cca1b455cbda9df2873e972d9ba4528f6271a7b7`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27909037181.
- Implementation commit: `d0663dba28a7ab7f11c06d0999b84236ca89b9b6`.
- Final repository HEAD: `d0663dba28a7ab7f11c06d0999b84236ca89b9b6`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27910771432.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes.
- Existing GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Files changed: the opt-in runtime subclass, capture dispatch, v0.249 capture/validator/report tools, package scripts and this report.
- Runtime systems touched: only opt-in Field Barracks/Militia/Ashen pressure state, deterministic contact ticks, HP HUD, combat marker, Raider defeat and minimap visibility.
- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, buildings, economy, saves, pathfinding and assets.

## Bounded model

- Construction target/cost: one authoritative Field Barracks; 180 Crowns / 120 Stone.
- Production target/cost: one Militia; 60 Crowns / 20 Iron.
- Raider ID/count: `v0247_ashen_raider_00` / 1.
- Combat model: deterministic contact ticks; one Militia versus one scripted Raider.
- Militia HP: 100; Raider HP: 60.
- Militia damage: 20; Raider damage: 10; tick interval: 1s.
- Combat start: Militia and Raider within 115-unit intercept/contact radius; measured distance 68.4878845214844.
- Combat end: third deterministic exchange reduces Raider to 0 HP.
- Final Militia / Raider HP: 70 / 0.
- Raider removed/defeated: true; minimap removed: true.
- Pressure contained by combat: true.
- Death exists only for the scripted Raider. Militia cannot die in this version.
- Enemy AI: no. Waves: no. Base/building damage: no.

## Proof

- Starting resources: {"aether":38,"crowns":420,"iron":90,"stone":160}.
- After construction: {"aether":38,"crowns":240,"iron":90,"stone":40}; delta {"aether":0,"crowns":-180,"iron":0,"stone":-120}.
- After training: {"aether":38,"crowns":180,"iron":70,"stone":40}; delta {"aether":0,"crowns":-60,"iron":-20,"stone":0}.
- Resources unchanged through telegraph, spawn, movement, combat and containment: true.
- Buildings unharmed: true; Aster/Worker unharmed: true.
- Objective ladder: 1. Select Aster -> 8. Prepare for Ashen pressure -> Prepare one defender -> Militia preparing... -> Defender ready -> 9. Ashen pressure incoming -> Ashen Raider advancing -> Move Militia to intercept -> Combat engaged -> Militia engaging Raider -> Ashen Raider defeated -> Ashen pressure contained.
- Telegraph/intercept markers preserved: true / true.
- Raider minimap before/after defeat: true / removed=true.
- Existing Restored Barracks / Command Keep / Lume Mine preserved: true / true / true.
- Forge, Market and Watchtower remain non-producing shells: true.
- Default runtime proof: default capture has the opt-in skin disabled and contains no Raider, markers, combat state or v0.249 HUD semantics.
- Pathing honesty: review-grade rectangular destination-nudge only.

## Validation results

- `npm run godot:test`: pass.
- v0.249 capture and dedicated validator: pass.
- `npm test`: pass, 122 files / 887 tests.
- `npm run build`: pass.
- Content, art-intake and 52 runtime-art-slot validators: pass.
- Experimental artifact retention: pass.
- `npm run godot:all`: pass.
- `git diff --check`: pass.
- Exact-SHA GitHub Actions: pending publication.

## Honest assessment

The bridge proves the smallest believable combat lifecycle, but remains deliberately single-pair, scripted, contact/proximity-based and visually primitive. Verdict remains PARTIAL.
Recommendation for v0.250: harden player-issued attack/contact behavior or presentation without adding waves, broad AI, building damage or a general combat rewrite.

Stop after v0.249. Do not begin v0.250.
