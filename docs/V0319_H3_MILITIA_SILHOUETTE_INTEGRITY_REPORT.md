# v0.319 H3 Militia Silhouette Integrity

## Scope

v0.319 closes the Militia silhouette question raised by v0.318. It is an evidence-integrity and target-isolated runtime audit, not a new gameplay or renderer feature. The audit is opt-in to the H3 capture path and leaves the accepted runtime, static fallback, workload, saves, and true default unchanged.

Base HEAD: `23aa065057ce2e4db273af3a6e839f79d10f8cf8`
Branch: `codex/v0215-v0226-recovery`

## Historical finding

v0.318 correctly repaired the single-sprite atlas-cell sampling contract, but its Militia target-only masks showed a horizontal band. The source atlas cell was inspected directly and is continuous. The live selected Militia also showed a separate green health-bar mesh crossing the torso. v0.318 target isolation retained that health-bar overlay; subtracting the target-hidden frame therefore removed the overlay from the difference and made it look like a missing sprite row.

This is the concrete root cause. It is not a new atlas defect, a UV seam, a QuadMesh seam, or depth occlusion in the sprite.

## v0.319 capture and audit

The new capture is a clean neutral presentation containing exactly one live Militia stable ID (`friendly_00`) and no Worker, Hero, neighbors, building, bridge, road, rail, selection ring, contact shadow, HUD, or health-bar overlay. It runs in both PLAYER and DEBUG_REVIEW capture modes and keeps the live H3 adapter, `QuadMesh`, `StandardMaterial3D`, and explicit UV-cell sampling intact.

The role contracts remain explicit:

- Worker: UV scale `0.125 x 0.125`.
- Militia: UV scale `0.125 x 0.200`.
- Militia cell: 128x128 pixels inside the 1024x640 atlas.
- Live mesh: QuadMesh, one surface, four vertices, six indices, two triangles, one visible visual child.

The six diagnostic variants cover current exact-cell/depth, no-depth-test, neutral-unshaded, nearest, linear-without-mipmaps, and half-texel-inset hypotheses. The clean proof does not require a production material change: the current exact-cell live output is continuous once the presentation health bar is suppressed.

## Mask truth and continuous proof

The clean target mask has no interior empty row sequence. The pack records target-mask IoU, recall, and precision at 1.0 for the clean live target truth and records a maximum horizontal gap of zero. The source-cell row audit is retained separately so source alpha coverage and live target coverage remain inspectable rather than being conflated with the overlay subtraction.

The uninterrupted Militia session contains 40 live frames at 130 ms each (5.2 seconds), including idle, locomotion, arrival, and restored idle phases. The authoritative save state is restored after capture. Worker work regression remains at three unchanged identities, and the accepted v0.318 Worker decision is retained.

## Exact decision

**MILITIA MASK-EVIDENCE DEFECT REPAIRED — PLAYER RUNTIME WAS CLEAN**

This is outcome 1 from the v0.319 brief. No production renderer repair was needed. The corrected v0.318 validator now rejects its historical Militia band explicitly with `PASS_V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REJECTED_MILITIA_BAND`; the v0.319 validator accepts the clean runtime evidence.

## Preservation boundaries

No gameplay state, movement semantics, pathfinding, combat, damage, HP, projectiles, death/despawn, AI, waves, fog, economy, resources, stable IDs, saves, or default runtime behavior were added or changed. The capture uses the existing opt-in H3 pilot and does not alter the authoritative workload runtime. The static H3 fallback remains intact.

## Evidence and commands

Review pack: `artifacts/manual-review/v0319-h3-militia-silhouette-integrity/`
Capture command: `npm run godot:capture:salto-h3-militia-silhouette-integrity`
Pack command: `npm run godot:pack:salto-h3-militia-silhouette-integrity`
Dedicated validator: `npm run godot:validate:salto-h3-militia-silhouette-integrity`
Corrected retained rejection validator: `node tools/godot/saltoV0318H3SingleSpriteAtlasRenderingRepairTool.mjs validate`

The compact upload set contains exactly 14 files, including actual rendered before/after evidence, source/live comparison, visible/hidden reconstruction, UV and mesh audits, depth classification, a 40-frame Militia GIF, Worker regression, save/load evidence, row coverage, decision scorecard, and machine-readable summary. `UPLOAD_TO_CHAT` contains no title-card-only substitute for the rendered proof.

## Validation evidence

Local validation is run after the capture and pack are built. The final report records the dedicated v0.319 validator, corrected v0.318 rejection validator, retained v0.317-v0.303 validators, project tests/build/content/art/runtime checks, artifact retention, Godot aggregate validation, and `git diff --check`.

GitHub Actions exact-SHA evidence and final repository state are recorded at closeout after the v0.319 commit is pushed. The target final state is a clean branch synchronized with origin at zero ahead and zero behind.
