# v0.318 H3 Single-Sprite Atlas-Cell Rendering Repair

## Decision

**H3 SINGLE-SPRITE ATLAS-CELL RENDERING REPAIRED — EXISTING WORKER WORK ART STILL INSUFFICIENT**

The live renderer now presents one authored atlas cell per H3 unit. The adapter is not adopted as the final animated H3 method because the existing Worker work art does not provide the required four distinct work identities in the captured evidence. The static H3 adapter remains the fallback.

## Scope and base

- Base HEAD: `4bf033622b50633af8ad96f7518ffa2132b03536`
- Branch: `codex/v0215-v0226-recovery`
- Runtime: H3 directional-animation opt-in only
- Presentation modes captured: `PLAYER` and `DEBUG_REVIEW`
- Default runtime: unchanged
- Gameplay: unchanged; no movement, pathing, combat, economy, or resource mutation

This checkpoint repairs the visual sampling contract and closes the evidence-integrity gap exposed by v0.317. It does not add animation art, replace the accepted static adapter, or alter the accepted H3 state chain.

## Exact root cause

The Worker and Militia sources are authored atlases with 128×128 cells: Worker is 1024×1024 (8×8) and Militia is 1024×640 (8×5). v0.317 created an `AtlasTexture` region, but the live 3D QuadMesh sampled the full atlas through its material UVs. The target-isolated masks therefore showed the entire 8×8 Worker or 8×5 Militia grid as miniature repeated figures.

The repair is in `desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd`: each live `StandardMaterial3D` now receives `uv1_scale` equal to cell dimensions divided by atlas dimensions and `uv1_offset` equal to the cell origin divided by atlas dimensions. The runtime reports `StandardMaterial3D_UV_CELL`, one visual child, `hframes=0`, `vframes=0`, and `regionEnabled=false` so the active sampling contract is explicit and auditable.

## Runtime and evidence contract

The capture path remains target-isolated using the real rendered-frame boundary (`RenderingServer.force_draw`) and a live billboard visibility difference. It does not construct evidence from an atlas crop. The independent PNG detector measures normalized target masks. The restored v0.317 masks detect 8×8 Worker and 8×5 Militia grids; the repaired v0.318 masks detect one occupied row/column motif and no grid.

Representative live UV coverage is exactly one cell: Worker `1/64 = 0.015625`, Militia `1/40 = 0.025`. The capture manifests include the atlas dimensions, cell pixel rect, UV minimum/maximum, active coverage, material instance, visual-child count, and source hashes.

## Animation and state evidence

- Worker idle, locomotion, and work live target masks are single figures.
- Militia idle and locomotion live target masks are single figures.
- Eight requested facings and four directional families remain captured.
- Scale candidates remain captured at 1.00, 0.88, and 0.76.
- Bridge and road traversal evidence remains present, with displacement and arrived-idle proof.
- 12-unit and 24-unit formations remain present with no fully hidden units.
- Save/load reconstruction remains present and hashed.
- Worker work identity count remains below the four-identity adoption threshold; therefore the exact outcome is the repair-only decision above.

The runtime continues to report `rootMotion=false`, `movementOwnedByAnimation=false`, `gameplayMutation=false`, and `defaultRuntimeChanged=false`.

## Review pack

`artifacts/manual-review/v0318-h3-single-sprite-atlas-rendering-repair/`

The compact `UPLOAD_TO_CHAT/` directory contains exactly 14 files. It includes a real before/after grid-versus-single-cell image, Worker and Militia live target masks, 40-frame GIFs, atlas/UV audit, frame/state strips, directions, scale, save/load, formations, the final scorecard, and the compact JSON summary. The full pack retains both mode manifests, target-mask and visual-child audits, UV audit, grid report, cell-reference check, continuous ledger, hashes, save audit, validator report, and black-frame rejection report.

## Validator and retained evidence

Dedicated command:

```text
npm run godot:validate:salto-h3-single-sprite-atlas-rendering-repair
```

The corrected v0.317 validator must report the historical pack as:

```text
PASS_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REJECTED
```

with explicit target-mask grid detection. v0.318 independently verifies the live one-cell contract and preserves the v0.317 rejection semantics rather than weakening them. Retained v0.316 through v0.303 validators, tests, build, content/art/runtime checks, artifact retention, Godot validation, and `git diff --check` are required before closeout.

## What changed and what did not

Changed:

- explicit cell-sized UV scale/offset on the live H3 QuadMesh material
- v0.318 opt-in dispatch, capture, independent PNG grid detector, validator, pack, and report
- technical cell-to-reference and black-frame evidence
- corrected v0.317 validator so the historical grid defect cannot pass silently

Did not change:

- no new animation art
- no new gameplay or states
- no movement, pathfinding, route following, combat, damage, HP, projectiles, death/despawn, AI, waves, fog gameplay, economy, resources, saves, or stable IDs
- no true-default runtime mutation
- no static H3 fallback removal

## Final validation and CI

Local validation completed before commit:

- v0.318 dedicated validator: PASS; grid detected `no`, estimated rows/columns `1/1`, visible child count `1`, Worker UV `0.015625`, Militia UV `0.025000000372529`
- corrected v0.317 validator: `PASS_V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REJECTED`, with historical Worker `8x8` and Militia `8x5` target-mask grids explicitly detected
- retained v0.316 through v0.303 validators: PASS, including v0.304 archaeology and v0.305–v0.309 Route C checks
- `npm test`: 887 tests passed
- `npm run build`: PASS
- `npm run validate:content`: PASS
- `npm run validate:art-intake`: PASS
- `npm run validate:runtime-art-slots`: PASS
- artifact retention validator: PASS
- `npm run godot:all`: READY/PASS
- `git diff --check`: PASS

The commit, push, exact-SHA GitHub Actions result, and final 0-ahead/0-behind clean repository state are recorded in the closeout update after they complete.
