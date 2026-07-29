# v0.424 Secondary-Barn Ridge-Beam Value Hierarchy

## Scope and baseline

v0.424 is one opt-in, material-only calibration of the existing secondary-barn ridge beam. It starts from final v0.423 commit `1e561af85207acb7636d9f51587b69a77c68a565` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.423 chain and the pre-existing untracked artifact backlog remain preserved.

The admitted inventory is exactly `V0399_Barn_Ridge_Beam`, classified as `BARN_RIDGE_BEAM`. The left and right roof planes, both eaves, v0.422 front structure, v0.423 side beams, v0.421 entrance frame, openings, walls, base and contact shadow are separately inventoried and excluded.

## Candidate and preservation

The candidate is `V0424_Secondary_Barn_Ridge_Beam` with albedo `#5b4939`, roughness `0.97`, specular `0.07`, and inherited vertex-colour albedo disabled. It is intended as a restrained timber roof-cap joining the two accepted charcoal roof planes without reopening the fail-closed v0.409 roof-surface limitation.

The change is material-only. Geometry, topology, indices, vertices, surfaces, UVs, transforms, AABBs, dimensions, placement, grounding, camera, lighting, shadows, layout, gameplay and runtime semantics remain unchanged. If the exact one-node apex boundary cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_RIDGE_BEAM`.

## Visual evidence

The capture path writes a real wide RTS frame, a barn close frame showing the full ridge with meaningful roof-plane, gable and eave context, matched grayscale frames, a non-black exact-node diagnostic, and v0.423/v0.424 comparisons. Close and diagnostic captures use temporary visibility isolation of unrelated `GeometryInstance3D` nodes only; the existing barn shell, both roof planes, ridge, eaves and structural context remain visible, every visibility state is restored before comparisons/audit/exit, and the isolation never affects the true default runtime.

Required real evidence is stored in `artifacts/manual-review/v0424-secondary-barn-ridge-beam-value-hierarchy/`:

- `01_PRIMARY_RTS_COLOUR.png`
- `02_SECONDARY_BARN_RIDGE_BEAM_CLOSE_COLOUR.png`
- `03_PRIMARY_RTS_GRAYSCALE.png`
- `04_SECONDARY_BARN_RIDGE_BEAM_CLOSE_GRAYSCALE.png`
- `05_TEMPORARY_BARN_RIDGE_BEAM_NODE_ID.png`
- `06_V0423_V0424_WIDE_COMPARISON.png`
- `07_V0423_V0424_RIDGE_BEAM_CLOSE_COMPARISON.png`
- `v0424-preservation-audit.json`

Human inspection must reject black, blank, clipped, ridge-hidden, or title-card-only evidence. The close frame must show the full visible ridge, meaningful portions of both roof planes, the front gable, and enough eave/structural context to assess hierarchy. The diagnostic must identify `V0399_Barn_Ridge_Beam`, the excluded roof planes/eaves, and accepted front/side structural groups, and it must not appear in player-facing evidence.

## Commands and validation

- `npm run godot:play:v0424-secondary-barn-ridge-beam`
- `npm run godot:smoke:v0424-secondary-barn-ridge-beam`
- `npm run godot:capture:v0424-secondary-barn-ridge-beam`
- `npm run godot:validate:v0424-secondary-barn-ridge-beam`

The dedicated validator asserts the exact one-node ridge inventory, explicit exclusions, candidate parameters, material-only preservation, capture-only visibility restoration, real evidence dimensions, fail-closed behavior, package wiring, and v0.423 baseline.

Before closeout, run the retained v0.424-v0.400 validator ladder, `npm test`, `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check`.

The dedicated v0.424 validator passed with seven real captures and the candidate retained: one affected ridge beam, no unexpected apex names, explicit roof/eave/front/side/entrance exclusions, and material-only preservation. The retained v0.424 through v0.400 validator ladder passed; the accepted fail-closed limitations in v0.416, v0.415, v0.410, and v0.409 remained fail-closed. `npm test` passed with 122 files and 887 tests. Production build, content, art-intake, runtime-art-slot (52 slots), artifact-retention, `npm run godot:all`, and `git diff --check` all passed.

Human render inspection confirmed that the wide frame is a real non-black RTS render with river, bridge, house, secondary barn, units, and props; the close frame is a real non-black barn render with the full ridge, both roof planes, gable, eaves, and structural context; the node diagnostic is non-black and identifies the gold ridge, blue roof planes, and gray excluded structures; and both comparison frames contain real non-black v0.423/v0.424 image pairs. No black, blank, clipped, ridge-hidden, or title-card-only evidence was accepted.

## Closeout

The scoped implementation and review pack were committed as `dad5b8a6a24f8e18758f1cee2377ae2b6361e57d` with message `v0.424 calibrate secondary barn ridge-beam value hierarchy`. GitHub Actions run `30418243137` (`CI Release Matrix Dry Run`) completed successfully for that exact SHA. This report update is a documentation-only follow-up; after it is committed and pushed, its exact-SHA Actions run will also be confirmed. The final tracked repository must be clean and synchronized at 0 ahead / 0 behind; the pre-existing untracked artifact backlog is intentionally preserved and is not part of this checkpoint.
