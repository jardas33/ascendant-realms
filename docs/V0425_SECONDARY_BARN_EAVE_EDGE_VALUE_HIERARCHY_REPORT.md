# v0.425 Secondary-Barn Eave-Edge Value Hierarchy

## Scope and baseline

v0.425 is one opt-in, material-only calibration of the two existing secondary-barn eave timbers. It starts from final v0.424 commit `5ded7a7b59bd09ef4e466f48b68dd8b16c1ae224` on `codex/v0215-v0226-recovery`. The accepted v0.409-v0.424 chain and pre-existing untracked artifact backlog remain preserved.

The admitted inventory is exactly `V0399_Barn_Left_Eave` and `V0399_Barn_Right_Eave`, both classified `BARN_EAVE_EDGE`. The roof planes, accepted v0.424 ridge, front structure, v0.423 side beams, entrance frame, openings, walls, base and contact shadow remain separately inventoried and excluded.

## Candidate and preservation

The candidate is `V0425_Secondary_Barn_Eave_Timber` with albedo `#564536`, roughness `0.98`, specular `0.06`, and inherited vertex-colour albedo disabled. Both eaves receive identical parameters. The target is a quiet, weathered timber roof-edge support pair: warmer than the charcoal roof planes, quieter than the v0.424 ridge, and subordinate to the complete barn silhouette.

The change is material-only. Geometry, topology, indices, vertices, surfaces, UVs, transforms, AABBs, dimensions, placement, grounding, camera, lighting, shadows, layout, gameplay and runtime semantics remain unchanged. If the exact two-node boundary or functional equivalence cannot be proven, the checkpoint fails closed with `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_EAVES`.

## Visual evidence

The capture path writes a real wide RTS frame, a matched close frame where both eaves are independently assessable with both roof planes, ridge, gable and structural context, grayscale counterparts, a non-black exact-node diagnostic, and v0.424/v0.425 comparisons. Close and diagnostic captures use temporary visibility isolation of unrelated `GeometryInstance3D` nodes only; the barn shell, both roof planes, both eaves, ridge, gable and relevant context remain visible, every visibility state is restored before comparisons/audit/exit, and the isolation never affects the true default runtime.

Required real evidence is stored in `artifacts/manual-review/v0425-secondary-barn-eave-edge-value-hierarchy/`:

- `01_PRIMARY_RTS_COLOUR.png`
- `02_SECONDARY_BARN_EAVES_CLOSE_COLOUR.png`
- `03_PRIMARY_RTS_GRAYSCALE.png`
- `04_SECONDARY_BARN_EAVES_CLOSE_GRAYSCALE.png`
- `05_TEMPORARY_BARN_EAVE_NODE_ID.png`
- `06_V0424_V0425_WIDE_COMPARISON.png`
- `07_V0424_V0425_EAVES_CLOSE_COMPARISON.png`
- `v0425-preservation-audit.json`

The close frame shows both eaves without clipping, meaningful portions of both roof planes, the ridge, front gable, and enough wall/structural context to judge hierarchy. The diagnostic is non-black and identifies both eaves by exact name, distinguishes left and right, identifies the excluded roof planes and v0.424 ridge, and identifies front/side structural groups. Diagnostic text is not player-facing evidence. Human inspection accepted the wide RTS render, eave close render, grayscale pair, node diagnostic, and both matched comparisons as real non-black imagery; no black, blank, clipped, hidden-eave, or title-card-only evidence was accepted.

## Commands and validation

- `npm run godot:play:v0425-secondary-barn-eaves`
- `npm run godot:smoke:v0425-secondary-barn-eaves`
- `npm run godot:capture:v0425-secondary-barn-eaves`
- `npm run godot:validate:v0425-secondary-barn-eaves`

The dedicated validator asserts the exact two-node eave inventory, functional equivalence, explicit exclusions, identical candidate parameters, material-only preservation, capture-only visibility restoration, real evidence dimensions, fail-closed behavior, package wiring, and the v0.424 baseline. It passed with `RENDERED_CANDIDATE`, two affected nodes, and seven real captures. The retained v0.425-v0.400 ladder passed, including fail-closed v0.416, v0.415, v0.410, and v0.409. `npm test`, `npm run build`, content validation, art-intake validation, runtime-art-slot validation, artifact retention, `npm run godot:all`, and `git diff --check` all passed.

## Closeout

The v0.425 implementation and real review pack were committed as `6f91a0a08c44d48a6994dd9a463456e520b7259b` with message `v0.425 calibrate secondary barn eave-edge value hierarchy`. GitHub Actions run `30420945906` (`CI Release Matrix Dry Run`) completed successfully for that exact SHA. The documentation-only follow-up commit is `e7d1c26433a84b5cd52b8bcf19b331cd0911e1f4`, and its exact-SHA GitHub Actions run `30421426875` also completed successfully. The pre-existing untracked artifact backlog is intentionally preserved and is not part of this checkpoint.
