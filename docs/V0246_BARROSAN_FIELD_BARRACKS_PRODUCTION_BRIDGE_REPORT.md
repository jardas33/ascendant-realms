# v0.246 Barrosan Field Barracks Production Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `f9895e5bbca9cf38280097383afa877719a68986`.
- v0.245 implementation commit: `4fc5b6229ea7b99c36754a5281320f8b6423b94d`; documentation closeout/base: `f9895e5bbca9cf38280097383afa877719a68986`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27889143566.
- Implementation commit: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.

## Construction and production

- Construction target: one authoritative opt-in Field Barracks.
- Production target: only that newly constructed Field Barracks.
- Existing Restored Barracks remains a separate live production flow.
- Shell roles remain non-producing.
- Construction cost/delta: 180 Crowns and 120 Stone, spent exactly once.
- Militia training authority/cost: generated portable unit definition, {"crowns":60,"iron":20}.
- Starting resources: {"aether":38,"crowns":420,"iron":90,"stone":160}.
- Resources after construction: {"aether":38,"crowns":240,"iron":90,"stone":40}.
- Resources after training spend: {"aether":38,"crowns":180,"iron":70,"stone":40}.
- Training delta/spend count: {"aether":0,"crowns":-60,"iron":-20,"stone":0} / 1.

## Queue, failure and spawn

- Single-slot queue accepted: true; progress reached: 1.
- Duplicate queue rejected without mutation: true / true.
- Post-spawn failed training rejected without mutation: true / true; reason: single-slot-occupied-or-limit-reached.
- Spawned Militia runtime ID: `v0246_field_militia_00`; spawn count: 1.
- Selection: true; movement probes: true; minimap: true.

## Preservation and pathing honesty

- Existing Restored Barracks restore/train flow preserved: true.
- Command Keep preserved: true.
- Lume Mine preserved: true.
- Forge, Market and Watchtower remain non-producing: true.
- Pathing remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.
- Default browser and Godot runtimes remain unchanged; saves, combat, AI, objectives, global economy and source content remain untouched.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0246BarrosanFieldBarracksProductionBridgeReviewPack.py`
- `tools/godot/captureGodotV0246BarrosanFieldBarracksProductionBridgeWindows.ps1`
- `tools/godot/saltoV0246BarrosanFieldBarracksProductionBridgeTool.mjs`
- `tools/godot/validateGodotV0246BarrosanFieldBarracksProductionBridgeWindows.ps1`
- `package.json`
- `docs/V0246_BARROSAN_FIELD_BARRACKS_PRODUCTION_BRIDGE_REPORT.md`

## Validation results

- `npm run godot:test`: pass.
- v0.246 capture and dedicated validator: pass.
- `npm test`: pass (122 files / 887 tests).
- `npm run build`: pass.
- Content, art-intake and runtime-art-slot validators: pass.
- Experimental artifact-retention validator: pass.
- `npm run godot:all`: pass, including Windows export/package.
- `git diff --check`: pass.
- Exact-SHA GitHub Actions: pending publication.

## Assessment

The first limited opt-in playable production loop is technically real: authoritative construction spends once, the constructed Field Barracks exposes one generated-cost Militia action, the one-slot queue rejects duplicates, one uniquely registered Militia spawns, and that Militia can be selected, moved and represented on the minimap.

The verdict remains PARTIAL because production is deliberately limited to one Militia, the lane is opt-in, no broader objective/combat integration is added, and pathing remains review-grade. Recommendation for v0.247: only broaden lifecycle integration after preserving these exact mutation and ownership boundaries.

Stop after v0.246. Do not begin v0.247.
