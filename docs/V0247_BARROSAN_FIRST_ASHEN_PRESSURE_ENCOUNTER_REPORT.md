# v0.247 Barrosan First Ashen Pressure Encounter

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `0ffa827d8377148f599b3df173f67de710a11ad1`.
- v0.246 implementation commit: `2325d8c2853404a62193957471bebdf2c8cdcb62`; documentation closeout/base: `0ffa827d8377148f599b3df173f67de710a11ad1`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27890932048.
- Implementation commit: `PENDING_PUBLICATION`.
- Final repository HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no.
- New GLB exported: no.
- Existing v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.

## Runtime scope

- Systems touched: opt-in Barrosan subclass state, review capture dispatch, minimap marker and HUD copy.
- Systems untouched: default browser/Godot runtime, saves, full combat, full AI, global economy, source content and shell production.
- Construction target: one authoritative opt-in Field Barracks.
- Production target: exactly one Militia from that constructed Field Barracks.
- Pressure target: exactly one scripted Ashen Raider using the existing procedural runtime silhouette.
- Ashen Raider runtime ID: `v0247_ashen_raider_00`; scripted, not AI-driven.
- Combat damage: no. Death: no.

## Resources and trigger

- Starting resources: {"aether":38,"crowns":420,"iron":90,"stone":160}.
- After construction: {"aether":38,"crowns":240,"iron":90,"stone":40}; delta {"aether":0,"crowns":-180,"iron":0,"stone":-120}.
- After Militia training: {"aether":38,"crowns":180,"iron":70,"stone":40}; delta {"aether":0,"crowns":-60,"iron":-20,"stone":0}.
- After Raider pressure: {"aether":38,"crowns":180,"iron":70,"stone":40}; unchanged during pressure: true.
- Pressure trigger: constructed Field Barracks trained one Militia.

## Pressure and containment

- Lane: east edge -> hostile road -> bridge/base approach marker; lane probes pass: true.
- Intercept zone: "(790.0, 760.0)", radius 115.
- Contained condition: Militia enters the intercept zone and is within the same radius of the Raider.
- Militia selected/movable/minimap: true / true / true.
- Raider selected/minimap/pathing: true / true / review-grade rectangular destination-nudge only.
- Pressure contained: true; damage applied: false; death occurred: false.

## Preservation

- Existing Restored Barracks flow preserved: true.
- Command Keep preserved: true.
- Lume Mine preserved: true.
- Forge, Market and Watchtower shells preserved and non-producing: true.
- Pathing remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.
- Default runtime remains unchanged.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0247BarrosanFirstAshenPressureEncounterReviewPack.py`
- `tools/godot/captureGodotV0247BarrosanFirstAshenPressureEncounterWindows.ps1`
- `tools/godot/saltoV0247BarrosanFirstAshenPressureEncounterTool.mjs`
- `tools/godot/validateGodotV0247BarrosanFirstAshenPressureEncounterWindows.ps1`
- `package.json`
- `docs/V0247_BARROSAN_FIRST_ASHEN_PRESSURE_ENCOUNTER_REPORT.md`

## Validation results

- `npm run godot:test`: pass.
- v0.247 capture and dedicated validator: pass.
- `npm test`: pass (122 files / 887 tests).
- `npm run build`: pass.
- Content, art-intake and runtime-art-slot validators: pass.
- Experimental artifact-retention validator: pass.
- `npm run godot:all`: pass, including Windows export/package.
- `git diff --check`: pass.
- Exact-SHA GitHub Actions: pending publication.

## Honest assessment

The encounter closes the first build-to-defense lifecycle: the constructed Field Barracks trains one Militia, one scripted Raider enters from the east, the Militia moves to a road/bridge intercept zone, and proximity marks the pressure contained without resource, health or death mutation.

The verdict remains PARTIAL because the encounter is deliberately single-enemy, scripted, proximity-resolved and non-combat, while pathing remains review-grade. Recommendation for v0.248: validate human-readable timing and command affordances before considering any tightly bounded combat bridge.

Stop after v0.247. Do not begin v0.248.
