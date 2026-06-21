# v0.245 Barrosan Authoritative Construction Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `e84cb1369c1f1ad7513ddd2c1c8b3f09d6530f84`.
- `818bd61319f629a628b3671a1d3cc9ea1e20db87` is the v0.244 implementation parent; `e84cb13...` is the true final v0.244 base.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27887850796.
- Implementation commit: `4fc5b6229ea7b99c36754a5281320f8b6423b94d`.
- Final repository HEAD if different: the docs-only closeout commit follows this report update; its exact SHA is recorded in the final handoff.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27888903983.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.

## Construction target and authority

- Target: exactly one opt-in technical Barracks.
- House was not chosen because the exported generated authority contains no House building definition; inventing one would violate the authority boundary.
- The existing Restored Barracks remains the live production building. The new structure is complete, selectable and registered, but intentionally has no production.
- Placement gate: `BuildPlacementValidationAdapter`, using exported `broken_ford` terrain, building size, overlap and resource rules.
- Exported cost: 180 Crowns and 120 Stone.

## Placement and resources

- Valid preview result: `true`.
- Cancel preview resources unchanged: `true`.
- Blocked preview/attempt reason: `blocked-terrain` / `Blocked terrain.`.
- Blocked attempt resources unchanged: `true`; structure created: `false`.
- Valid placement resource delta: `{"aether":0,"crowns":-180,"iron":0,"stone":-120}`; spend count: `1`.
- Runtime ID: `v0245_authoritative_barracks_00`.
- Role ID: `barrosan_role_barracks_constructed_00`.

## Registration and preserved systems

- New structure is present in runtime structures, selection hit testing and minimap.
- HUD: `Authoritative Field Barracks | Opt-in technical construction`; `Authoritative placement / complete / no production`.
- Existing Command Keep, Restored Barracks, Lume Mine, Aster, Worker and Militia remain intact.
- Existing Barracks restoration, Militia queue and spawn flow passes after the new placement.
- March Forge, Frontier Market and Watchtower remain honest non-producing shells.

## Pathing honesty

- Movement near the new structure completed without an obvious stuck/no-progress failure.
- This remains review-grade rectangular destination-nudge obstacle avoidance, not browser PathfindingGrid parity.

## Runtime boundaries

- Touched only the opt-in Barrosan subclass, existing read-only adapter access, capture routing and v0.245 tooling.
- Untouched: default browser runtime, default Godot runtime, saves, AI, combat, objectives, normal economy/production/commands and source content.

## Validation results

- `npm run godot:test`: pass.
- `npm run godot:capture:salto-barrosan-authoritative-construction-bridge`: pass.
- `npm run godot:validate:salto-barrosan-authoritative-construction-bridge`: pass.
- `npm test`: pass, 122 files / 887 tests.
- `npm run build`: pass.
- `npm run validate:content`: pass.
- `npm run validate:art-intake`: pass.
- `npm run validate:runtime-art-slots`: pass, 52 stable slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: pass.
- `npm run godot:all`: pass, including Windows export/package.
- `git diff --check`: pass.
- Exact-SHA GitHub Actions: pending publication.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/adapters/build_placement_validation_adapter.gd`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0245BarrosanAuthoritativeConstructionBridgeReviewPack.py`
- `tools/godot/captureGodotV0245BarrosanAuthoritativeConstructionBridgeWindows.ps1`
- `tools/godot/saltoV0245BarrosanAuthoritativeConstructionBridgeTool.mjs`
- `tools/godot/validateGodotV0245BarrosanAuthoritativeConstructionBridgeWindows.ps1`
- `package.json`
- `docs/V0245_BARROSAN_AUTHORITATIVE_CONSTRUCTION_BRIDGE_REPORT.md`

## Assessment

The key v0.245 contract is proven: a real structure cannot be appended or charged unless the same exported-authority adapter approves the point. Cancel and blocked attempts are mutation-free, while valid confirmation spends exactly once and registers a selectable minimap entity.

The verdict remains PARTIAL because the new Barracks is a constrained non-producing technical entity and navigation remains review-grade. Recommendation for v0.246: harden shared construction lifecycle and pathing semantics before calling this a first playable building system.

Stop after v0.245. Do not begin v0.246.
