# v0.248 Barrosan Ashen Pressure Readability and Timing Hardening

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `3904510b82cb5f6040fdff13dc0f6b2b83e520ff`.
- v0.247 implementation commit: `2c502121ec83b476e571d1ef557bf8666fed90de`; documentation closeout/base: `3904510b82cb5f6040fdff13dc0f6b2b83e520ff`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27906676309.
- Implementation commit: `6c5cfa196e31229b3c976254212114dcbeeef473`.
- Final repository HEAD: `6c5cfa196e31229b3c976254212114dcbeeef473`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27908751456.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes.
- Existing GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.

## Runtime scope

- Systems touched: opt-in objective copy, pressure timing snapshots, non-colliding threat/intercept markers, HUD copy, capture and validation.
- Default systems untouched: default runtime, combat, damage, death, AI planner, waves, economy, saves, production shells and source assets.
- Construction target/cost: one authoritative Field Barracks; 180 Crowns / 120 Stone.
- Production target/cost: exactly one Militia; 60 Crowns / 20 Iron.
- Pressure target: one scripted Ashen Raider, ID `v0247_ashen_raider_00`; AI-driven: false; count: 1.
- Pressure telegraph: red/orange non-blocking `ASHEN APPROACH` marker on the east lane, opt-in only.
- Intercept zone: cyan non-blocking `INTERCEPT ZONE` marker near the bridge approach; changes to `PRESSURE CONTAINED`; not a building.
- Objective ladder: 1. Select Aster -> 8. Prepare for Ashen pressure -> Prepare one defender -> Militia preparing... -> Defender ready -> 9. Ashen pressure incoming -> Ashen Raider advancing -> Move Militia to intercept -> Ashen pressure contained.
- Raider timing: deterministic visible spawn, 150-frame lane-entry movement and 245-frame bridge-approach movement; never more than one Raider.
- Militia intercept condition: proximity/zone containment at the existing 115-unit review radius.
- HUD explicitly reports `Scripted pressure entity | no damage in v0.248` and `No damage exchanged`.

## Resource and mutation proof

- Before construction: {"aether":38,"crowns":420,"iron":90,"stone":160}.
- After construction: {"aether":38,"crowns":240,"iron":90,"stone":40}; delta {"aether":0,"crowns":-180,"iron":0,"stone":-120}.
- After training: {"aether":38,"crowns":180,"iron":70,"stone":40}; delta {"aether":0,"crowns":-60,"iron":-20,"stone":0}.
- After telegraph: {"aether":38,"crowns":180,"iron":70,"stone":40}.
- After Raider spawn: {"aether":38,"crowns":180,"iron":70,"stone":40}.
- After Raider movement: {"aether":38,"crowns":180,"iron":70,"stone":40}.
- After containment: {"aether":38,"crowns":180,"iron":70,"stone":40}.
- Pressure resource snapshots unchanged: true. Health unchanged: true.
- Damage exists: false; death exists: false; any combat exists: false.
- Damage applied: false; death occurred: false; extra enemies spawned: false.

## Preservation and honesty

- Raider minimap registered: true; deterministic lane probes pass: true.
- Existing Restored Barracks train flow preserved: true.
- Command Keep / Lume Mine live: true / true.
- March Forge, Frontier Market and Watchtower remain non-producing shells: true.
- Default runtime proof: opt-in skin disabled in default capture; Raider, markers and v0.248 labels absent.
- Pathing honesty: review-grade rectangular destination-nudge only; no browser PathfindingGrid parity.
- The verdict remains PARTIAL because this is a single scripted Raider, proximity containment, primitive functional markers and no combat.

## Files changed

- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0248BarrosanAshenPressureReadabilityTimingReviewPack.py`
- `tools/godot/captureGodotV0248BarrosanAshenPressureReadabilityTimingWindows.ps1`
- `tools/godot/saltoV0248BarrosanAshenPressureReadabilityTimingTool.mjs`
- `tools/godot/validateGodotV0248BarrosanAshenPressureReadabilityTimingWindows.ps1`
- `package.json`
- `docs/V0248_BARROSAN_ASHEN_PRESSURE_READABILITY_TIMING_REPORT.md`

## Validation results

- `npm run godot:test`: pass.
- v0.248 capture and dedicated validator: pass.
- `npm test`: pass (122 files / 887 tests).
- `npm run build`: pass.
- Content, art-intake and runtime-art-slot validators: pass.
- Experimental artifact-retention validator: pass.
- `npm run godot:all`: pass, including Windows export/package.
- `git diff --check`: pass.
- Exact-SHA GitHub Actions: pending publication.

## Recommendation for v0.249

If reopened, introduce one tightly bounded combat-resolution bridge only after preserving this readability contract; do not broaden into waves, production AI or full pathfinding.

Stop after v0.248. Do not begin v0.249.
