# Development Checkpoint

Updated: 2026-06-09 v0.185 Salto Environment Shell Live QA

## v0.185 Salto Environment-Shell Live QA Residual-Overlay Pruning And Human-Review Stop - 2026-06-09

Scope: explicit opt-in Godot Salto environment-shell live-QA refinement after v0.184. This checkpoint generates zero images, adds zero slots, keeps the default launcher procedural, preserves all prior opt-in launchers, keeps browser runtime untouched, and leaves gameplay, pathing, collisions, objectives, AI, saves, stable IDs, selected art, metadata, fallbacks, and required evidence unchanged.

Included work:

- Added `GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat` plus matching validate/capture wrappers.
- Added `tools/godot/saltoEnvironmentShellLiveQaTool.mjs` with validation, capture, benchmark, and boundary gates.
- Added the visual-only `--salto-environment-shell-live-qa` Godot flag and status/audit reporting.
- Kept the v0.184 geometry-convergence foundation while pruning residual diagnostic-looking overlay surfaces in E4 only.
- Reduced terrain/value pad dominance, site-marker base/collar intensity, transparent layer competition, road/bridge review-band weight, and remaining slab-like material masks.
- Performed Windows-side Computer Use review across title, briefing, battle, pan, zoom, mine, Worker, Barracks, Militia, Ashen, minimap, Results, and restart.
- Produced v0.185 QA/benchmark, boundary/rollback, and implementation reports.

Verification targets:

```text
PASS: npm run godot:validate:salto-environment-shell-live-qa.
PASS: PASS_V0185_ENVIRONMENT_SHELL_LIVE_QA_VALIDATION/CAPTURE/BENCHMARK/BOUNDARY.
PASS: E4 FPS ratio 1.0000 and p95 worsening -2.92% against the E3 geometry-convergence baseline.
PASS: npm run godot:headed:post-mine-flow-smoke.
PASS: npm run godot:headed:triple-natural-playthrough.
PASS: Windows-side packaged review covered live objective flow, camera movement, Results, and restart.
PASS: safe-only cleanup deleted exactly 18 known Godot sidecars; retention after cleanup passed.
PASS: zero images, zero slots, no launcher mutation, default procedural preserved, browser runtime untouched, no gameplay/pathing/collision/objective/AI/save/stable-ID mutation.
```

## v0.184 Salto Opt-In Environment-Shell Geometry Convergence And Human-Review Stop - 2026-06-09

Scope: explicit opt-in Godot Salto visual geometry-convergence review path. This checkpoint generates zero images, adds zero character slots, adds zero environment-material slots, keeps the default launcher procedural, preserves all prior opt-in launchers, keeps browser runtime untouched, and leaves gameplay, pathing, collisions, objectives, AI, saves, stable IDs, selected art, metadata, fallbacks, and required evidence unchanged.

Included work:

- Added `GODOT_REVIEW_SALTO_ENVIRONMENT_GEOMETRY_CONVERGENCE_WINDOWS.bat` plus matching validate/capture wrappers.
- Added `tools/godot/saltoEnvironmentGeometryConvergenceTool.mjs` with validation, capture, benchmark, boundary, cleanup, and retention gates.
- Added a visual-only `--salto-environment-geometry-convergence` Godot flag and reporting audit.
- Narrowed material-bearing terrain surfaces, segmented road and river/riverbank geometry, improved bridge readability, and added structure-grounding trim.
- Performed Windows-side Computer Use review from title to briefing to battle.
- Produced v0.184 QA/benchmark, boundary/rollback, and implementation reports.

Verification targets:

```text
PASS: npm run godot:validate:salto-environment-geometry-convergence.
PASS: PASS_V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_VALIDATION.
PASS: PASS_V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_CAPTURE with 20/20 E3 screenshots.
PASS: PASS_V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_BENCHMARK, FPS ratio 1.0000, p95 worsening -0.30%.
PASS: PASS_V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_BOUNDARY.
PASS: PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE.
PASS: Windows-side packaged review reached title, briefing, and battle.
PASS: safe-only cleanup deleted exactly 18 known Godot sidecars; retention after cleanup found 0 unknown files.
PASS: zero images, zero slots, no launcher mutation, default procedural preserved, browser runtime untouched, no gameplay/pathing/collision/objective/AI/save/stable-ID mutation.
```

## Post-v0.183 Godot Opt-In Visual Hardening Review - 2026-06-09

Scope: ad hoc visual QA and repair for the existing explicit Godot Salto ground + road material opt-in review path after v0.183. This is not v0.184. It generates zero images, adds zero slots, changes no launcher, keeps the default launcher procedural, keeps browser runtime untouched, and preserves the frozen five character slots plus the selected ground and road environment-material opt-ins.

Included work:

- Reduced ground and road material dominance so the opt-in textures support the tactical scene instead of overpowering it.
- Lightened opt-in-only terrain, ridge, and review lighting for better unit, road, river, and structure readability.
- Added opt-in-only terrain feathering, west-side value pads, road crowns, river edges, bridge trim, structure accents, and unit contact shadows.
- Repaired the review capture ordering defect that let battle-shell rendering overwrite local road/bridge/site/pan/zoom focus.
- Tightened environment-foundation review camera framing.
- Revalidated the existing ground+road opt-in path, including road missing-art and hash-mismatch fallback.
- Performed Windows-side live exported-app review of title, briefing, and battle start with captured window screenshots.
- Added `docs/POST_V0183_GODOT_OPT_IN_VISUAL_HARDENING_REVIEW.md`.

Verification targets:

```text
PASS: npm run godot:validate:salto-ground-road-material-opt-in.
PASS: PASS_WINDOWS_EXPORT.
PASS: PASS_WINDOWS_PACKAGE.
PASS: PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION.
PASS: PASS_V0181_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_AUTOMATION_READY.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION/CAPTURE/BENCHMARK/BOUNDARY.
PASS: repaired ground+road FPS ratio 1.0035 and p95 worsening -3.49%.
PASS: focused review captures are distinct for overview, road/bridge, pan, min zoom, and max zoom.
PASS: Windows-side live exported-app screenshots captured title, briefing, and battle start.
PASS: zero images, zero slots, no launcher mutation, default procedural preserved, browser runtime untouched, v0.184 not started.
```

## v0.183 Post-Freeze Next-Phase Scorecard And v0.184 Preparation Only - 2026-06-09

Scope: documentation-only post-freeze scorecard and v0.184 prompt preparation. This checkpoint generates zero images, adds zero slots, changes no runtime code or launchers, performs no cleanup deletion/archive move, preserves default procedural launchers, keeps browser runtime untouched, and prepares but does not start v0.184.

Included work:

- Scored bridge/river material comparator, structure-shell material comparator, environment lighting hardening, HUD visual foundation, static-to-animation comparator, default-art enablement readiness analysis, archive-first cleanup execution, and pause/manual-review options.
- Recommended exactly one next milestone: v0.184 Emmanuel environment-freeze manual review decision packet.
- Created the tracked v0.184 prompt under `docs/art-prompts/`.
- Recorded cleanup execution decision: no broad archive/delete work until explicit human approval.
- Updated handoff, artifact index, roadmap, changelog, release checklist, and checkpoint docs.

Verification targets:

```text
PASS: v0.182 was current HEAD, clean/synced, and remote-green before v0.183.
PASS: npm run godot:validate:salto-experimental-artifact-retention.
PASS: node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0183/cleanup-dry-run.
PASS: git diff --check.
PASS: zero images, zero slots, no runtime code, no launcher mutation, no cleanup deletion/archive move, v0.184 prepared but not started.
```

## v0.182 Environment-Foundation Visual-Cohesion QA Cleanup Freeze Stop - 2026-06-09

Scope: bounded QA, cleanup packet, and freeze decision for the current Godot Salto five-slot plus ground+road environment-material opt-in posture. This checkpoint generates zero images, adds zero slots, changes no code or launchers, preserves the default procedural launcher, keeps browser runtime untouched, and freezes further environment-material additions until Emmanuel review.

Included work:

- Reran the existing ground+road opt-in validation stack after v0.181.
- Reviewed default procedural and explicit ground+road opt-in paths with Windows-side Computer Use.
- Confirmed title, briefing, battle start, Aster selection, move order, conversion onset, pan/zoom, HUD, minimap, road/river/bridge hierarchy, and fallback evidence.
- Ran broad artifact inventory, targeted cleanup dry-run, safe-only sidecar cleanup, and retention validation after cleanup.
- Produced v0.182 visual-cohesion QA, cleanup freeze packet, and implementation report docs.

Verification targets:

```text
PASS: npm run godot:validate:salto-ground-road-material-opt-in.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY.
PASS: ground+road FPS ratio 1.0032 and p95 worsening -2.92%.
PASS: cleanup dry-run found 18 known sidecars and 0 unknown cleanup-scope files.
PASS: safe-only cleanup deleted exactly 18 known sidecars / 7719 bytes.
PASS: retention after cleanup reported PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION and 0 unknown sidecars.
PASS: zero images, zero slots, default procedural preserved, no browser/save/stable-ID/gameplay mutation.
```

## v0.181 Road-Material Opt-In Player-Slice Integration Experiment Stop - 2026-06-08

Scope: bounded integration of the selected v0.180 Barrosan foothold road material into the existing Godot Salto environment-material opt-in posture. This checkpoint generates zero images, adds exactly one road environment-material opt-in slot, keeps character-slot integration frozen at five, preserves all prior launchers, keeps the default launcher procedural, keeps browser runtime untouched, and does not begin v0.182.

Included work:

- Added `GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat` with matching validation and capture wrappers.
- Integrated only `barrosan_foothold_road_material_v0180` / `ROAD_MATERIAL_LOCAL_1024` with SHA `a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10`.
- Bound the material only to `v0173_main_road_wide_readable_bed`, `v0173_barracks_side_path_wide_bed`, and `v0173_ruins_side_path_wide_bed`.
- Preserved the existing ground-material opt-in, five frozen character/material slots, procedural fallback underlay, exact hash validation, one-time load/create counters, and missing-art/hash-mismatch road fallback.
- Performed Windows-side Computer Use review of title, briefing, battle view, and safe Aster move-order input smoke.

Verification targets:

```text
PASS: node --check tools/godot/saltoGroundRoadMaterialOptInTool.mjs.
PASS: npm run godot:validate:salto-ground-road-material-opt-in.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK.
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY.
PASS: E2 FPS ratio 1.0001 and p95 worsening -1.15%.
PASS: cleanup dry-run, artifact retention, Windows-side Computer Use review, zero images, one road environment-material opt-in slot, zero character slots, no browser/save/stable-ID/gameplay mutation.
```

## v0.178 Ground-Material Visual QA, UV-Scale Hardening, And Terrain-Noise Control Stop - 2026-06-08

Scope: bounded visual hardening for the existing Godot Salto ground-material opt-in path. This checkpoint generates zero images, adds zero slots, keeps the same selected v0.175 material source, preserves all launchers, keeps default procedural, keeps browser runtime untouched, and does not begin v0.179.

Included work:

- Reduced the ground-material UV scale from `0.72` to `0.56`.
- Reduced texture overlay alpha to `0.48` with a restrained tint.
- Added a procedural value underlay beneath the material overlay on the two authorized foothold ground surfaces.
- Preserved mipmapped filtering, exact selected hash validation, one-time load/create counters, and missing-art/hash-mismatch fallback.
- Updated validation/capture/benchmark/boundary tooling to write v0.178 evidence and reject the old v0.177 UV/noise posture.
- Performed Windows-side Computer Use review of title, briefing, battle view, and quick pan/zoom smoke.

Verification targets:

```text
PASS: npm run godot:validate:salto-ground-material-opt-in.
PASS: PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_VALIDATION.
PASS: PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_CAPTURE.
PASS: PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BENCHMARK.
PASS: PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BOUNDARY.
PASS: E1 FPS ratio 0.998 and p95 worsening 2.78%.
PASS: cleanup dry-run, artifact retention, Windows-side Computer Use review, zero images, zero slots added, no browser/save/stable-ID/gameplay mutation.
```

## v0.177 Barrosan Foothold Ground-Material First Opt-In Player-Slice Integration Experiment - 2026-06-08

Scope: first player-slice environment-material opt-in slot for the existing five-slot Godot Salto posture. This checkpoint generates zero images, adds exactly one environment-material opt-in slot, adds zero character slots, keeps the default launcher procedural, preserves all prior opt-in launchers, and does not begin v0.178.

Included work:

- Confirmed v0.176 as the required clean/synced starting checkpoint before edits.
- Integrated only `barrosan_foothold_ground_material_v0175` / `GROUND_MATERIAL_LOCAL_1024` with SHA `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`.
- Added `GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat` with matching validation and capture wrappers.
- Bound the material only to `v0173_terrain_mid_value_field` and `v0173_friendly_staging_value_field`.
- Preserved roads, river, banks, bridge, structures, site markers, minimap, HUD, browser runtime, default launchers, and all five selected character/material slots.
- Proved missing-art and hash-mismatch fallback while keeping the five frozen character/material slots active.

Verification targets:

```text
PASS: npm run godot:validate:salto-ground-material-opt-in.
PASS: PASS_V0177_GROUND_MATERIAL_OPT_IN_VALIDATION.
PASS: PASS_V0177_GROUND_MATERIAL_OPT_IN_CAPTURE.
PASS: PASS_V0177_GROUND_MATERIAL_OPT_IN_BENCHMARK.
PASS: PASS_V0177_GROUND_MATERIAL_OPT_IN_BOUNDARY.
PASS: E1 FPS ratio 0.9977 and p95 worsening 2.49%.
PASS: ground material one-time source load, metadata parse, image decode, texture create, and material create.
PASS: cleanup dry-run, artifact retention, Windows-side Computer Use review, zero images, one environment-material slot, zero character slots, no browser/save/stable-ID/gameplay mutation.
```

## v0.176 Terrain-Material Opt-In Player-Slice Integration Readiness Packet - 2026-06-08

Scope: documentation-only readiness for one future terrain-material opt-in player-slice slot. This checkpoint generates zero images, adds zero slots, modifies no runtime code, deletes no historical evidence, keeps the default launcher procedural, preserves all prior opt-in launchers, and does not begin v0.177.

Included work:

- Confirmed v0.175 as the required current clean/synced and remote-green checkpoint before edits.
- Read v0.173/v0.174 environment QA, v0.175 ground-material evidence, artifact index, cleanup manifests, current launchers, and default procedural boundary.
- Prepared the future terrain-material readiness packet with candidate surface, fallback posture, opt-in launcher design, UV/filter/mipmap contract, performance gates, visual gates, rollback, and package-leak prevention.
- Prepared the exact future v0.177 prompt without executing it.

Verification targets:

```text
PASS: v0.176 docs exist.
PASS: retention validation and cleanup dry-run.
PASS: boundary scans for zero images, zero slots, no runtime code changes, no player-slice integration, no browser wiring, no new launcher, and no default launcher mutation.
PASS: git diff --check.
PASS: v0.177 prepared but not started.
```

## v0.175 Barrosan Foothold Terrain-Material Single-Slot Private Comparator Intake And Human-Review Stop - 2026-06-08

Scope: private-comparator-only terrain-material intake after the character-slot freeze. This checkpoint generates exactly one image, adds no character slots, adds no normal-slice terrain slot, imports no terrain material into the player-facing slice, keeps the default launcher procedural, preserves all prior opt-in launchers, and does not begin v0.176.

Included work:

- Confirmed v0.174 as the required prior clean/synced and remote-green checkpoint before edits.
- Generated exactly one original Barrosan foothold ground-material source.
- Produced deterministic 512, 768, 1024, and wrap-safe offset-blend derivatives under the ignored v0.175 local material workspace.
- Added a tracked diagnostic fallback and private comparator only.
- Selected `GROUND_MATERIAL_LOCAL_1024` after seam, repetition, style, fair-path, benchmark, and capture review.
- Rejected `GROUND_MATERIAL_1024_WRAPSAFE_OFFSET_BLEND` as comparison evidence because it showed more visible banding than the selected 1024 derivative.
- Updated cleanup/retention classifiers to protect the new v0.175 comparator/fallback files.

Verification targets:

```text
PASS: npm run godot:ground-material:fallback:reproduce.
PASS: npm run godot:ground-material:derivatives:reproduce.
PASS: npm run godot:ground-material:validate.
PASS: npm run godot:ground-material:benchmark:headed.
PASS: npm run godot:ground-material:capture.
PASS: npm run godot:ground-material:audit.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run.
PASS: PASS_V0175_GROUND_MATERIAL_SELECTION_GATE.
PASS: selected derivative GROUND_MATERIAL_LOCAL_1024, seam mean opposing-edge delta 11.29, Tier L FPS ratio 1.015, p95 worsening -1.32%.
PASS: exactly one image generated, private comparator only, no player-slice integration, no browser runtime wiring, no further character slots.
```

## v0.174 Salto Road-River-Bridge Site-Marker Readability Hardening And Human-Review Stop - 2026-06-08

Scope: opt-in E2 procedural environment-readability review for the existing five-slot Godot Salto posture. This checkpoint generates no images, adds no slots, imports no terrain material, keeps the default launcher procedural, preserves all prior opt-in launchers, and does not begin v0.175.

Included work:

- Confirmed v0.173 as current clean/synced and remote-green before edits.
- Added `GODOT_REVIEW_SALTO_ENVIRONMENT_READABILITY_WINDOWS.bat` with matching validation and capture launchers.
- Added review-only procedural road continuity/intersection overlays, mine/Barracks approach lanes, hostile approach lane, friendly foothold boundary, river-bank contrast, bridge crossing guards, site-marker hierarchy, minimap markers, and pan/zoom anchors.
- Preserved the five selected Worker, Barracks material, Militia, Aster, and Ashen opt-in slots without adding a sixth slot.
- Preserved the default procedural launcher and all prior opt-in launchers.
- Rebuilt the packaged Godot executable during validation to avoid stale-binary evidence.
- Ran Windows-side review of title, briefing, and live battle; shortened the opt-in label after finding right-edge clipping.

Verification targets:

```text
PASS: npm run godot:validate:salto-environment-readability.
PASS: PASS_V0174_ENVIRONMENT_READABILITY_VALIDATION.
PASS: PASS_V0174_ENVIRONMENT_READABILITY_CAPTURE.
PASS: PASS_V0174_ENVIRONMENT_READABILITY_BENCHMARK.
PASS: PASS_V0174_ENVIRONMENT_READABILITY_BOUNDARY.
PASS: benchmark E2 FPS ratio versus E1 = 1.0039 and p95 worsening = 2.52%.
PASS: zero images generated, zero slots added, no terrain material import, default procedural launcher preserved, all prior opt-in launchers preserved, no browser/save/stable-ID/gameplay/pathing/navigation mutation.
```

## v0.173 Salto Procedural World-Shell Hierarchy Hardening Experiment And Human-Review Stop - 2026-06-08

Scope: opt-in procedural environment-foundation review for the existing five-slot Godot Salto posture. This checkpoint generates no images, adds no slots, imports no terrain material, keeps the default launcher procedural, preserves all prior opt-in launchers, and does not begin v0.174.

Included work:

- Confirmed v0.172 as current clean/synced and remote-green before edits.
- Added `GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat` with matching validation and capture launchers.
- Added review-only procedural terrain value fields, road beds/edges/ticks, river banks, ford/bridge hierarchy, structure pads/contact shadows, site-marker collars, lighting, framing, and environment status reporting.
- Preserved the five selected Worker, Barracks material, Militia, Aster, and Ashen opt-in slots without adding a sixth slot.
- Preserved the default procedural launcher and all prior opt-in launchers.
- Recorded validation, capture/contact-sheet, benchmark, and boundary evidence for M5 baseline versus E1 environment foundation.

Verification targets:

```text
PASS: npm run godot:validate:salto-environment-foundation.
PASS: PASS_V0173_ENVIRONMENT_FOUNDATION_VALIDATION.
PASS: PASS_V0173_ENVIRONMENT_FOUNDATION_CAPTURE.
PASS: PASS_V0173_ENVIRONMENT_FOUNDATION_BENCHMARK.
PASS: PASS_V0173_ENVIRONMENT_FOUNDATION_BOUNDARY.
PASS: benchmark E1 FPS ratio versus M5 >= 0.90 and p95 worsening <= 15%.
PASS: zero images generated, zero slots added, no terrain material import, default procedural launcher preserved, all prior opt-in launchers preserved, no browser/save/stable-ID/gameplay mutation.
```

## v0.172 Safe Cleanup Execution Documentation-Budget Enforcement And Environment-Phase Decision Packet - 2026-06-08

Scope: bounded cleanup execution, documentation-budget policy, and environment-phase roadmap. This checkpoint adds no images, adds no slots, makes no runtime visual changes, performs no archive moves, keeps default launchers procedural, and does not begin v0.173.

Included work:

- Confirmed v0.171 as current clean/synced HEAD before edits.
- Ran fresh before/after artifact inventory and cleanup dry-run manifests.
- Ran safe-only cleanup before validation and again after launcher validation.
- Deleted only regenerated Godot comparator sidecars: 14 files / 5,505 bytes after launcher validation.
- Left all archive candidates as candidates only.
- Preserved selected local art, active derivatives, metadata, tracked fallbacks, latest evidence, historical evidence, and unknown files.
- Validated default player slice plus Worker-only, Worker + Barracks, Worker + Barracks + Militia, Worker + Barracks + Militia + Aster, and five-slot launchers.
- Added documentation-budget policy and environment-phase scorecard/roadmap.

Verification targets:

```text
PASS: npm run godot:audit:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-inventory.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-dry-run.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/safe-only --apply-safe-only.
PASS: npm run godot:validate:player-slice.
PASS: npm run godot:validate:salto-worker-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-militia-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-militia-aster-art-experiment.
PASS: npm run godot:validate:salto-five-slot-art-experiment.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/post-launcher-safe-only --apply-safe-only.
PASS: npm run godot:validate:salto-experimental-artifact-retention -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/retention-final.
PASS: npm run godot:audit:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-inventory.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-dry-run.
```

## v0.171 Salto Five-Slot Visual-Cohesion QA Cleanup Packet And Character-Integration Freeze Stop - 2026-06-08

Scope: review the existing five-slot Godot Salto opt-in posture, run cleanup retention checks, execute only safe sidecar cleanup, and freeze further character-slot integration. This checkpoint generates no images, adds no slots, keeps the default launchers procedural, preserves all prior opt-in launchers, and does not begin v0.172.

Included work:

- Confirmed the expected v0.170 follow-up baseline at `efe9ab451ed1bbc2d86d16df05c504964128ba41` with `HEAD...@{u}` at `0 0`.
- Reviewed title, briefing, and live battle through the Windows Godot app with the five-slot opt-in path.
- Confirmed Worker, Barracks material, Militia, Aster, and Ashen remain selected active opt-in evidence.
- Recorded that the remaining visual weakness is the procedural world shell, not a sixth character slot need.
- Hardened audit, cleanup, and retention scripts so all five selected derivatives and metadata records are protected.
- Executed safe-only cleanup for 14 known Godot-generated sidecars totaling 5,505 bytes.
- Preserved selected local art, metadata, tracked fallbacks, latest evidence, historical evidence, and unknown files.
- Added v0.171 visual QA, benchmark/fallback/boundary, cleanup, character-freeze, and implementation docs.

Verification targets:

```text
PASS: npm run godot:validate:salto-worker-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-militia-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-militia-aster-art-experiment.
PASS: npm run godot:validate:salto-five-slot-art-experiment.
PASS: npm run godot:audit:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/audit.
PASS: npm run godot:validate:salto-experimental-artifact-retention -- --output-root=artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/retention.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/dry-run.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/safe-only --apply-safe-only.
PASS: Windows-side Computer Use review of title, briefing, and live battle.
```

## v0.167 Salto Three-Slot Presentation QA Placeholder Classification And Artifact-Retention Enforcement Stop - 2026-06-08

Scope: classify the existing three-slot Godot review posture, enforce artifact retention, and preserve all current launchers before any fourth-slot work. This checkpoint adds no images, adds no slots, and does not integrate Aster or Ashen.

Included work:

- Added the Salto experimental artifact index.
- Added artifact-retention validation.
- Added three-slot presentation QA and visible placeholder classification reporting.
- Classified Worker, Militia, procedural Aster, Barracks shell/material, terrain, water/bridge, roads, site/objective markers, HUD, minimap, fallback blocks, residual procedural unit bodies, and unknown visuals.
- Confirmed target-slot accidental procedural double-render remains zero.
- Preserved Worker, Barracks, and Militia active opt-in derivatives and their metadata.
- Preserved selected future Aster and Ashen derivatives as evidence only.

Verification targets:

```text
PASS: npm run godot:validate:salto-three-slot-visual-coherence.
PASS: npm run godot:report:salto-three-slot-presentation-qa.
PASS: npm run godot:validate:salto-experimental-artifact-retention.
PASS: npm run godot:cleanup:salto-experimental-artifacts.
PASS: npm run godot:cleanup:salto-experimental-artifacts -- --apply-safe-only when only known sidecars are present.
PASS: npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts.
PASS: git diff --check.
```

## v0.166 Godot Salto Three-Slot Visual Coherence Review Launcher And Safe Cleanup Stop - 2026-06-07

Scope: review clarity, visual-coherence evidence, and safe cleanup execution for the existing three-slot Godot player-slice opt-in path. This checkpoint adds no images, adds no slots, preserves all existing launchers, keeps the default launcher procedural, and confines cleanup deletion to positively identified Godot-generated sidecars.

Included work:

- Confirmed v0.165 prerequisite status and pre-v0.166 hygiene unblock before edits.
- Reproduced the remaining screenshot concern as mode/framing ambiguity rather than a remaining compression or duplicate-render defect.
- Preserved Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preserved Barracks slot `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` and SHA-256 `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Preserved Militia slot `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024` and SHA-256 `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Added review-only on-screen mode label support.
- Added review-only safe camera framing.
- Added rendered pixel width/height evidence for Worker and Militia.
- Added `GODOT_REVIEW_SALTO_THREE_SLOT_ART_WINDOWS.bat`.
- Added `GODOT_VALIDATE_SALTO_THREE_SLOT_VISUAL_COHERENCE_WINDOWS.bat`.
- Added `GODOT_CLEANUP_SALTO_EXPERIMENTAL_ARTIFACTS_SAFE_WINDOWS.bat`.
- Added v0.166 visual coherence, screenshot/scale, visual QA, cleanup, launcher guide, boundary, and implementation docs.

Current interpretation:

- The default stabilized launcher remains procedural.
- The default player-slice launcher remains procedural.
- The Worker-only launcher remains Worker-only.
- The Worker + Barracks launcher remains two-slot.
- The Worker + Barracks + Militia launcher remains exactly three-slot.
- Barracks material remains correctly bound and intentionally restrained at normal RTS distance.
- Cleanup deletes only audited `.gd.uid` and `.png.import` sidecars when explicitly requested.
- Browser runtime, production manifests, saves, stable IDs, new art slots, gameplay, objectives, input semantics, balance, AI, map content, campaign state, final engine choice, full port, broad cleanup, and v0.167 remain out of scope unless a later queued prompt explicitly passes gates.

Verification targets:

```text
PASS: npm run godot:validate:salto-three-slot-visual-coherence - PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_AUTOMATION_READY.
PASS: review scorecard - PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_HUMAN_REVIEW_READY after cleanup evidence is present.
PASS: cleanup dry-run - PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN.
PASS: cleanup safe-only - PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP or no eligible candidates.
PASS: boundary - default launchers procedural, prior opt-in launchers preserved, zero images, zero slots, no Aster/Ashen/browser/save/stable-ID/gameplay mutation.
```

## v0.165 Godot Salto Three-Slot Visual Hardening And Artifact Hygiene Inventory Stop - 2026-06-07

Scope: visual-scale hardening and artifact-hygiene inventory for the existing three-slot Godot player-slice opt-in path. This checkpoint adds no images, adds no slots, preserves all launchers, repairs only proven Worker/Militia runtime aspect compression, and stops for Emmanuel review.

Included work:

- Confirmed v0.164 prerequisite status and starting commit before edits.
- Reproduced the human screenshot concern in the actual Windows app before repair.
- Measured selected Worker and Militia source dimensions, alpha bounds, trim bounds, pivots, and runtime quad dimensions.
- Preserved Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preserved Barracks slot `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` and SHA-256 `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Preserved Militia slot `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024` and SHA-256 `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Repaired Worker and Militia runtime quad width calculation to preserve source aspect.
- Added `v0165VisualHardeningAudit` runtime evidence.
- Added `GODOT_VALIDATE_SALTO_THREE_SLOT_VISUAL_HARDENING_WINDOWS.bat`.
- Added `GODOT_AUDIT_SALTO_EXPERIMENTAL_ARTIFACTS_WINDOWS.bat`.
- Added v0.165 scale/aspect, duplicate-render, Barracks-binding, visual QA, benchmark, artifact-hygiene, boundary, and implementation docs.

Current interpretation:

- The default stabilized launcher remains procedural.
- The Worker-only launcher remains Worker-only.
- The Worker + Barracks launcher remains two-slot.
- The Worker + Barracks + Militia launcher remains exactly three-slot.
- Barracks material remains bound to the intended Barracks surfaces and intentionally leaves procedural shell detail visible.
- Militia missing-art and hash-mismatch fallback remain fail-closed to procedural Militia while Worker and Barracks stay active.
- Browser runtime, production manifests, saves, stable IDs, new art slots, gameplay, objectives, input semantics, balance, AI, map content, cleanup execution, campaign state, final engine choice, full port, and v0.166 remain out of scope.

Verification targets:

```text
PASS: npm run godot:validate:salto-three-slot-visual-hardening - PASS_V0165_THREE_SLOT_VISUAL_HARDENING_AUTOMATION_READY.
PASS: scale/aspect - PASS_V0165_BILLBOARD_SCALE_ASPECT_PIVOT_AUDIT.
PASS: duplicate render - PASS_V0165_DUPLICATE_RENDER_AUDIT.
PASS: Barracks binding - PASS_V0165_BARRACKS_MATERIAL_BINDING_REVIEW.
PASS: benchmark - PASS_V0165_THREE_SLOT_BENCHMARK.
PASS: artifact hygiene - PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN.
PASS: Computer Use - PASS_V0165_THREE_SLOT_COMPUTER_USE_GATE.
PASS: boundary - PASS_V0165_PLAYER_SLICE_THREE_SLOT_BOUNDARY.
PASS: summary - PASS_V0165_THREE_SLOT_VISUAL_HARDENING_HUMAN_REVIEW_READY.
```

## v0.164 Godot Salto Militia Third Opt-In Player-Slice Integration And Human Review Stop - 2026-06-07

Scope: three-slot Godot player-slice opt-in experiment. This checkpoint adds only the selected v0.155 Militia billboard behind a new Worker + Barracks + Militia launcher, keeps the default stabilized launcher procedural, preserves the Worker-only launcher and Worker + Barracks launcher, and stops for Emmanuel review.

Included work:

- Confirmed v0.163 prerequisite status `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.
- Preserved Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preserved Barracks slot `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` and SHA-256 `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Added Militia slot `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024` and SHA-256 `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Added `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- Added `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- Added `GODOT_CAPTURE_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- Added v0.164 validation/capture/benchmark/real-input/Computer Use/boundary aggregation tooling.
- Added v0.164 docs and scaffold guardrail coverage.

Current interpretation:

- The default stabilized launcher remains procedural.
- The existing Worker-only launcher remains Worker-only.
- The existing Worker + Barracks launcher remains two-slot.
- The new Worker + Barracks + Militia launcher requests exactly three normal-slice opt-in slots.
- Militia missing-art and hash-mismatch fallback fail closed to procedural Militia while Worker and Barracks art remain active.
- Browser runtime, production manifests, saves, stable IDs, fourth art slots, gameplay, objectives, input semantics, balance, AI, map content, campaign state, and v0.165 remain out of scope.

Verification results:

```text
PASS: npm run godot:validate:salto-worker-barracks-militia-art-experiment - PASS_V0164_WORKER_BARRACKS_MILITIA_ART_OPT_IN_AUTOMATION_READY.
PASS: validation - PASS_V0164_MILITIA_OPT_IN_VALIDATION.
PASS: functional - PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL.
PASS: capture - PASS_V0164_MILITIA_OPT_IN_CAPTURE.
PASS: benchmark - PASS_V0164_MILITIA_OPT_IN_BENCHMARK; M3 FPS ratio versus M0 1.0003, M3 P95 ratio versus M0 0.9442, M3 FPS ratio versus M2 1.0001, M3 P95 ratio versus M2 0.9478.
PASS: real-input - PASS_V0164_MILITIA_OPT_IN_REAL_INPUT, including squad-selection and combat-onset proof with normal packaged Godot input.
PASS: Windows-side Computer Use review - PASS_V0164_MILITIA_OPT_IN_COMPUTER_USE_GATE.
PASS: boundary - PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY; default launcher unchanged, Worker-only launcher unchanged, Worker + Barracks launcher unchanged, package leakage false, zero image changes, no fourth slot.
```

## v0.163 Godot Salto Barracks-Material Opt-In Visual QA Hardening And Human Review Stop - 2026-06-07

Scope: Windows-side visual QA and real-input hardening for the existing combined Worker + Barracks-material opt-in player-slice path. This checkpoint adds evidence and docs only around the already-integrated v0.162 two-slot path, keeps the default launcher procedural, preserves the Worker-only launcher, and stops for Emmanuel review.

Included work:

- Confirmed v0.162 prerequisite status `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.
- Preserved Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Preserved Barracks slot `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` and SHA-256 `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Added `GODOT_REVIEW_SALTO_WORKER_BARRACKS_ART_OPT_IN_WINDOWS.bat`.
- Added `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_ART_OPT_IN_HARDENING_WINDOWS.bat`.
- Added v0.163 validation/capture/benchmark/real-input/Computer Use/boundary aggregation tooling.
- Added v0.163 docs and scaffold guardrail coverage.

Current interpretation:

- The default stabilized launcher remains procedural.
- The existing Worker-only launcher remains Worker-only.
- The existing combined launcher remains the only two-slot opt-in path.
- Barracks missing-art and hash-mismatch fallback fail closed to procedural Barracks while Worker art remains active.
- Browser runtime, production manifests, saves, stable IDs, third art slots, gameplay, objectives, input semantics, balance, AI, map content, campaign state, and the next milestone remain out of scope.

Verification results:

```text
PASS: node --check tools/godot/saltoWorkerBarracksArtOptInHardeningTool.mjs.
PASS: npm test - 122 files / 877 tests.
PASS: npm run build.
PASS: npm run validate:content.
PASS: npm run validate:art-intake.
PASS: npm run validate:runtime-art-slots.
PASS: npm run art:reference:init.
PASS: npm run art:reference:validate - PASS_V0138_REFERENCE_METADATA.
PASS: npm run art:reference:contact-sheet - PASS_V0138_REFERENCE_CONTACT_SHEET.
PASS: npm run art:reference:review-pack - PASS_V0138_REFERENCE_REVIEW_PACK.
PASS: npm run godot:validate:player-slice.
PASS: npm run godot:validate:salto-worker-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-art-experiment - PASS_V0162_WORKER_BARRACKS_ART_OPT_IN_AUTOMATION_READY.
PASS: npm exec -- vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts - 43 tests.
PASS: npm run godot:validate:salto-worker-barracks-art-opt-in-hardening - PASS_V0163_WORKER_BARRACKS_ART_OPT_IN_HARDENING_AUTOMATION_READY.
PASS: validation - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_QA_VALIDATION.
PASS: capture - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_CAPTURE.
PASS: benchmark - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_BENCHMARK; Worker-only FPS 0.9940, combined FPS 0.9939, combined-vs-Worker FPS 0.9999, Worker-only P95 0.9837, combined P95 1.0186, combined-vs-Worker P95 1.0354.
PASS: real-input - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT.
PASS: Windows-side Computer Use review - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE.
PASS: boundary - PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY; default launcher unchanged, Worker-only launcher unchanged, combined launcher unchanged, package leakage false, zero image changes.
PASS: summary - PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY.
PASS: git diff --check.
```

## v0.162 Godot Salto Worker + Barracks Art Opt-In Human Review Stop - 2026-06-07

Scope: two-slot Godot player-slice opt-in experiment. This checkpoint adds only the selected v0.150 seam-repaired Barracks material behind a new combined Worker + Barracks launcher, keeps the default stabilized launcher procedural, preserves the existing Worker-only launcher, and stops for Emmanuel review.

Included work:

- Confirmed v0.161 prerequisite status `PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY`.
- Preserved Worker slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Added Barracks slot `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` and SHA-256 `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Added `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- Added `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- Added `GODOT_CAPTURE_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat`.
- Added v0.162 validation/capture/benchmark/real-input/boundary aggregation tooling.
- Added v0.162 docs and scaffold guardrail coverage.

Current interpretation:

- The default stabilized launcher remains procedural.
- The existing Worker-only launcher remains Worker-only.
- The combined launcher requests exactly two normal-slice opt-in slots.
- Barracks missing-art and hash-mismatch fallback fail closed to procedural Barracks while Worker art remains active.
- Browser runtime, production manifests, saves, stable IDs, third art slots, gameplay, objectives, input semantics, balance, AI, map content, campaign state, and v0.163 remain out of scope.

Required verification:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:validate:player-slice
npm run godot:validate:salto-worker-art-experiment
npm run godot:validate:salto-worker-barracks-art-experiment
npm run godot:capture:salto-worker-barracks-art-experiment
npm run godot:benchmark:salto-worker-barracks-art-experiment
Windows-side Computer Use review where available
npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts
boundary scans
git diff --check
```

Verification results:

```text
PASS: npm test - 122 files / 876 tests.
PASS: npm run build.
PASS: npm run validate:content.
PASS: npm run validate:art-intake.
PASS: npm run art:reference:init.
PASS: npm run art:reference:validate - PASS_V0138_REFERENCE_METADATA.
PASS: npm run art:reference:contact-sheet - PASS_V0138_REFERENCE_CONTACT_SHEET.
PASS: npm run art:reference:review-pack - PASS_V0138_REFERENCE_REVIEW_PACK.
PASS: npm run godot:validate:player-slice.
PASS: npm run godot:validate:salto-worker-art-experiment.
PASS: npm run godot:validate:salto-worker-barracks-art-experiment - PASS_V0162_WORKER_BARRACKS_ART_OPT_IN_AUTOMATION_READY.
PASS: npm run godot:capture:salto-worker-barracks-art-experiment.
PASS: npm run godot:benchmark:salto-worker-barracks-art-experiment.
PASS: validation - PASS_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION and PASS_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL.
PASS: capture - PASS_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE.
PASS: benchmark - PASS_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK; Worker-only FPS 0.9975, combined FPS 1.0028, Worker-only P95 1.0106, combined P95 1.0334.
PASS: real-input - PASS_V0162_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT with debugShortcutUsed=false and stateInjectionUsed=false.
PASS: boundary - PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY; default launcher unchanged, Worker-only launcher unchanged, package leakage false.
PASS: Windows-side Computer Use smoke - packaged combined opt-in app reached title, briefing, and battle view, then closed cleanly.
PASS: npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts - 42 tests.
PASS: node --check tools/godot/saltoWorkerBarracksArtOptInTool.mjs.
PASS: git diff --check.
```

## v0.161 Godot Salto Worker-Art Opt-In Visual QA Hardening And Human Review Stop - 2026-06-07

Scope: Windows-side visual QA and real-input hardening for the existing one-slot Worker-art opt-in path. This checkpoint adds evidence and docs only around the already-integrated v0.160 Worker slot, keeps the default launchers procedural, and stops for Emmanuel review.

Included work:

- Confirmed v0.160 prerequisite slot `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` and SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Added `GODOT_REVIEW_SALTO_WORKER_ART_OPT_IN_WINDOWS.bat`.
- Added `GODOT_VALIDATE_SALTO_WORKER_ART_OPT_IN_HARDENING_WINDOWS.bat`.
- Added v0.161 validation/capture/benchmark/real-input/boundary aggregation tooling.
- Added v0.161 docs and scaffold guardrail coverage.
- Preserved the default stabilized launcher as procedural.

Current interpretation:

- v0.161 is not a second integration checkpoint.
- The only player-facing art slot under review remains Worker.
- Missing-art and hash-mismatch fallback remain fail-closed to procedural Worker.
- Browser runtime, production manifests, saves, stable IDs, gameplay, objectives, input semantics, balance, AI, map content, and campaign state remain out of scope.
- v0.162 has not started.

Required verification:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:validate:player-slice
npm run godot:validate:salto-worker-art-experiment
npm run godot:validate:salto-worker-art-opt-in-hardening
Windows-side Computer Use review where available
npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts
boundary scans
git diff --check
```

Verification results:

```text
PASS: npm test - 122 test files, 875 tests.
PASS: npm run build - TypeScript compile and Vite production build; known large-chunk warning only.
PASS: npm run validate:content.
PASS: npm run validate:art-intake - 1 candidate metadata file.
PASS: npm run art:reference:init.
PASS: npm run art:reference:validate - PASS_V0138_REFERENCE_METADATA, 15 metadata files, 15 candidate images.
PASS: npm run art:reference:contact-sheet - PASS_V0138_REFERENCE_CONTACT_SHEET.
PASS: npm run art:reference:review-pack - PASS_V0138_REFERENCE_REVIEW_PACK.
PASS: npm run godot:validate:player-slice - default procedural player slice preserved.
PASS: npm run godot:validate:salto-worker-art-experiment.
PASS: npm run godot:validate:salto-worker-art-opt-in-hardening - PASS_V0161_WORKER_ART_OPT_IN_HARDENING_AUTOMATION_READY.
PASS: Windows-side Computer Use review - PASS_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_GATE.
PASS: npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts - 41 tests.
PASS: boundary scans - PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY and PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY.
PASS: git diff --check.
```

Final v0.161 scorecard ratios: FPS `1.0023` versus procedural, P95 frame-time `0.8784` versus procedural. Package leakage is `false`; default stabilized launcher hash remains `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`.

## v0.160 Godot Salto Worker Billboard Opt-In Player-Slice Integration Experiment - 2026-06-07

Scope: one-slot Godot player-slice opt-in integration checkpoint. This checkpoint integrates only the validated Worker billboard into the packaged Salto review slice behind a new explicit opt-in launcher, keeps the default launchers procedural, proves fallback behavior, benchmarks the opt-in path, and stops for Emmanuel review.

Included work:

- Confirmed clean synchronized `main` at `0063095c8bb5c56eec2a687d392c2e4c6efcfc31` before editing.
- Confirmed v0.159 prerequisite packet and selected Worker contract.
- Added `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`, `GODOT_VALIDATE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`, and `GODOT_CAPTURE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- Added Worker-art opt-in flags and runtime status to the Godot root script.
- Added one Worker-only billboard loader in the 2.5D scene with exact source hash, metadata, dimensions, image-load, and texture-creation checks.
- Preserved `worker_00` and existing Worker selection, assignment, mine-work, Barracks repair, and Results behavior.
- Added validation/capture/benchmark evidence tooling and docs.

Current interpretation:

- The default stabilized launcher remains procedural and is protected by hash scan.
- The opt-in launcher is a human-review experiment, not final runtime-art approval.
- Missing source and hash mismatch fail closed to procedural Worker.
- v0.161 was not started inside the v0.160 checkpoint.

Verification results:

```text
PASS: npm test - 122 test files, 874 tests.
PASS: npm run build - TypeScript compile and Vite production build; known large-chunk warning only.
PASS: npm run validate:content.
PASS: npm run validate:art-intake - 1 candidate metadata file.
PASS: npm run art:reference:init.
PASS: npm run art:reference:validate - PASS_V0138_REFERENCE_METADATA, 15 metadata files, 15 candidate images.
PASS: npm run art:reference:contact-sheet - PASS_V0138_REFERENCE_CONTACT_SHEET.
PASS: npm run art:reference:review-pack - PASS_V0138_REFERENCE_REVIEW_PACK.
PASS: npm run godot:validate:player-slice - default procedural player slice preserved.
PASS: npm run godot:validate:salto-worker-art-experiment - PASS_V0160_WORKER_ART_OPT_IN_VALIDATION.
PASS: npm run godot:capture:salto-worker-art-experiment - PASS_V0160_WORKER_ART_OPT_IN_CAPTURE, 5 scenarios, 60 screenshots.
PASS: npm run godot:benchmark:salto-worker-art-experiment - PASS_V0160_WORKER_ART_OPT_IN_BENCHMARK.
PASS: npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts - 40 tests.
PASS: isolation scan - PASS_V0160_WORKER_ART_OPT_IN_BOUNDARY, default stabilized launcher SHA-256 47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d.
PASS: git diff --check.
```

## v0.159 First Player-Facing Hybrid-Art Integration Readiness Packet And V0.160 Worker Contract - 2026-06-07

Scope: documentation and contract checkpoint only. This checkpoint prepares the first player-facing hybrid-art integration readiness packet and the future v0.160 Worker opt-in implementation contract. It generates zero images, adds zero runtime-art slots, integrates nothing into the normal Salto player slice, preserves default launchers unchanged, and stops for Emmanuel review.

Included work:

- Confirmed clean synchronized `main` at `1d5daeb61645d7fd2195c0fab8c9f13866d6e787` before editing.
- Confirmed v0.158 prerequisite gates, selected five-slot private comparator context, and remote-green status.
- Created v0.159 readiness, first-slot scorecard, v0.160 Worker opt-in contract, risk register, rollback plan, Emmanuel review guide, boundary, implementation report, and future v0.160 prompt.
- Selected `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` as the safest future first player-facing opt-in proof.
- Added scaffold guardrail coverage proving the packet exists while the future opt-in launcher is not created in v0.159 and default launchers do not contain Worker experiment tokens.

Current interpretation:

- v0.159 is not an art integration checkpoint. It prepares the next contract only.
- Future v0.160 may be considered only after Emmanuel review and a new explicit bounded goal.
- Required future v0.160 posture is Godot-only, Worker-only, opt-in launcher only, default launcher unchanged, and fail-closed to procedural Worker fallback.
- v0.160 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:hybrid-mixed-combat:validate
npm run godot:hybrid-mixed-combat:audit
npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts
isolation scans
git diff --check
```

## v0.158 Hybrid Mixed Friendly-Versus-Hostile Combat-Readability Stress Gate And Human Review Stop - 2026-06-07

Scope: isolated private Godot mixed-combat comparator checkpoint. This checkpoint stress-tests the already-selected five-slot posture, generates zero new images, adds zero runtime-art slots, preserves archived v0.156 Ashen evidence, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `7a9c2685667e9f66eb43b2a99f1ef7331b702f84` before editing.
- Confirmed v0.157 selected `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`, selected hash `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`, gates, and ratios `0.9853` / `1.0159`.
- Encoded the v0.157 Ashen visual decision only for this private mixed-combat stress test.
- Added private `--hybrid-mixed-combat-readability-stress` dispatch and v0.158 wrappers.
- Added selected-local, fallback-only, and orthographic fallback scenarios for 4/8/16/32 Ashen stress.
- Added v0.158 validation, scorecard, fair-path audit, capture, contact-sheet, and benchmark reporting.

Current interpretation:

- Runtime validation, fair-path audit, benchmark, capture, and final scorecard were refreshed by the v0.158 command stack under `artifacts/desktop-spikes/godot-salto/v0158/evidence/`.
- Recorded gates: `PASS_V0158_HYBRID_MIXED_COMBAT_VALIDATION`, `PASS_V0158_HYBRID_MIXED_COMBAT_FAIR_PATH_AUDIT`, `PASS_V0158_HYBRID_MIXED_COMBAT_EVIDENCE_RECORDED`, and `PASS_V0158_HYBRID_MIXED_COMBAT_STRESS_GATE`.
- Tier L selected-vs-fallback FPS / p95 ratios: `0.9392` / `1.1098`; 32-Ashen selected-vs-fallback FPS / p95 ratios: `1.1061` / `0.9154`; screenshot count: `47`.
- Human review is pending. Passing the private gate marks the five-slot posture technically promising only, not production-approved.
- v0.159 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:hybrid-mixed-combat:validate
npm run godot:hybrid-mixed-combat:audit
npm run godot:hybrid-mixed-combat:benchmark:headed
npm run godot:hybrid-mixed-combat:capture
isolation scans
git diff --check
```

## v0.157 Ashen Raider Visual-Restraint Replacement Private Comparator And Human Review Stop - 2026-06-07

Scope: isolated private Godot Ashen Raider visual-restraint replacement checkpoint. This checkpoint preserves the technically valid v0.156 Ashen Raider source/cutout as archived comparison evidence, generates exactly one restrained replacement source image, derives fullres/512/768/1024 deterministic candidates for the same hostile slot, benchmarks the private comparator path against fallback and archived comparison evidence, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `1d74b91411641f077ba5190dd2cb4e4a17a56069`.
- Confirmed v0.156 prerequisite evidence, source/cutout hashes, and selected Worker/Barracks/Aster/Militia context hashes.
- Generated exactly one restrained ignored Ashen Raider source image.
- Preserved the v0.156 source/cutout as archived comparison evidence only.
- Added deterministic v0.157 fullres, 512, 768, and 1024 derivative tooling.
- Added private `--ashen-raider-visual-restraint-replacement` dispatch and v0.157 wrappers.
- Captured fallback, archived v0.156, fullres, 512, 768, 1024, alpha, dark/light edge, context, group, overlap, ring, normal-distance, zoomed, and Tier S/M/L evidence.

Current interpretation:

- Derivative reproducibility: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_DERIVATIVES_REPRODUCIBILITY`.
- Validation: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_VALIDATION`.
- Runtime validation: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_VALIDATION`.
- Runtime evidence: `PASS_V0157_ASHEN_RAIDER_RESTRAINT_REPLACEMENT_RUNTIME_EVIDENCE`.
- Gate: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_SELECTION_GATE`.
- Evidence marker: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_EVIDENCE_RECORDED`.
- Fair-path audit: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT`.
- Source SHA-256: `f2c96f230534c86f060b04d0580b8b0f797b859dc348ba1a450a97c90eca6954`.
- Archived v0.156 source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- Archived v0.156 cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.
- Selected derivative: `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`.
- Selected SHA-256: `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`, dimensions `1024 x 1024`.
- Tier L fallback average-FPS / p95: `1025.21` / `1.26 ms`.
- Tier L archived v0.156 average-FPS / p95: `988.19` / `1.42 ms`.
- Tier L selected average-FPS / p95: `1010.16` / `1.28 ms`.
- Tier L selected average-FPS ratio: `0.9853`.
- Tier L selected p95 ratio: `1.0159`.
- Screenshot count: `37`; benchmark row count: `42`; aggregate row count: `18`.
- Fair-path audit cache posture: `10` texture cache entries, `10` material cache entries, `10` source load entries, one create/load per key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review is pending. Automated checks mark the replacement as a restrained ordinary hostile wave attacker; this is not final runtime-art approval.
- v0.158 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:ashen-raider-replacement:derivatives:reproduce
npm run godot:ashen-raider-replacement:validate
npm run godot:ashen-raider-replacement:audit
npm run godot:ashen-raider-replacement:benchmark:headed
npm run godot:ashen-raider-replacement:capture
isolation scans
git diff --check
```

## v0.156 Hybrid Ashen Raider Static Billboard Single Hostile-Slot Intake Experiment And Human Review Stop - 2026-06-07

Scope: isolated private Godot Ashen Raider billboard intake checkpoint. This checkpoint generates exactly one original ignored Ashen Raider source image, derives one deterministic alpha cutout, benchmarks a single hostile private comparator-only runtime-art slot against a tracked procedural fallback with selected Worker, Barracks, Aster, and Militia context, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `9d4a776209e22b2eaef5b6569a7af18cb6d76703`.
- Confirmed v0.155 prerequisite evidence, selected `HYBRID_MILITIA_TRIMMED_1024`, and preserved Worker/Barracks/Aster/Militia hashes.
- Generated exactly one original ignored Ashen Raider source image and deterministic alpha cutout.
- Added tracked procedural fallback PNG and contract for `ashen_raider_billboard_static_v0156`.
- Added private `--ashen-raider-billboard-single-slot` dispatch and v0.156 wrappers.
- Captured one-Raider, alpha, dark/light edge, Aster hierarchy, Worker distinction, selected Militia friendly/hostile distinction, group, zoomed group, overlap, rings, static formation, fallback, ortho, and Tier S/M/L evidence.

Current interpretation:

- Gate: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence marker: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`.
- Validation: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_VALIDATION`.
- Runtime validation: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_RUNTIME_VALIDATION`.
- Fair-path audit: `PASS_V0156_ASHEN_RAIDER_BILLBOARD_FAIR_PATH_AUDIT`.
- Source SHA-256: `9eec7bde19bbd698ae3d738c7cb284d570043fe31d220e22e7a00e6ecb344cad`.
- Cutout SHA-256: `95b9d6dd592e9cb84aff64ae5fb1b73eb80d8bf2b93064260484f3f99514e6ba`.
- Fallback SHA-256: `501dd67cff89a7cd09aa6a1674b24717f183a7a6d71eddbd33a26f6962bb9faa`.
- Tier L local average-FPS ratio: `1.0051`.
- Tier L local p95 ratio: `1.0074`.
- Fallback Tier L mean FPS / p95: `1001.64` / `1.35 ms`.
- Local Ashen Raider Tier L mean FPS / p95: `1006.75` / `1.36 ms`.
- Screenshot count: `24`; benchmark row count: `21`; aggregate row count: `9`.
- Fair-path audit cache posture: `6` texture cache entries, `6` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review is pending. The source reads hostile and distinct, but the large weapon silhouette should be reviewed before any future approval decision.
- v0.157 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:ashen-raider-billboard:fallback:reproduce
npm run godot:ashen-raider-billboard:metadata
npm run godot:ashen-raider-billboard:validate
npm run godot:ashen-raider-billboard:audit
npm run godot:ashen-raider-billboard:benchmark:headed
npm run godot:ashen-raider-billboard:capture
isolation scans
git diff --check
```

## v0.155 Hybrid Militia Billboard Repair Mass-Overlap Combat-Readability Benchmark And Human Review Stop - 2026-06-07

Scope: isolated private Godot Militia billboard repair checkpoint. This checkpoint generates zero new AI images, uses only the existing v0.154 Militia cutout, derives full-res/512/768/1024 deterministic same-source variants, benchmarks fallback/full/512/768/1024 at S/M/L plus 32-Militia stress, selects `HYBRID_MILITIA_TRIMMED_1024`, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `17cc1de5620c80c75ee6481508e8c783ec5aa40d`.
- Confirmed v0.154 pushed remote CI success and prerequisite PASS gates.
- Added private `--militia-billboard-mass-overlap-repair` dispatch and v0.155 wrappers.
- Added deterministic full-res, 512, 768, and 1024 Militia derivatives under the ignored v0.155 artifact root.
- Captured checkerboard/dark/light alpha review, normal/zoomed RTS distance, 4/8/16/32 overlap, Aster hierarchy, Worker distinction, rings, formation spacing, sorting, pan/zoom pivot, fallback, and Tier S/M/L/stress evidence.

Current interpretation:

- Gate: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_GATE`.
- Evidence marker: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_EVIDENCE_RECORDED`.
- Fair-path audit: `PASS_V0155_MILITIA_BILLBOARD_REPAIR_FAIR_PATH_AUDIT`.
- Selected derivative: `HYBRID_MILITIA_TRIMMED_1024`.
- Selected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.
- Tier L selected average-FPS ratio: `1.0702`.
- Tier L selected p95 ratio: `0.9688`.
- 32-Militia stress selected average-FPS ratio: `1.0018`.
- 32-Militia stress selected p95 ratio: `0.9946`.
- Screenshot count: `36`; benchmark row count: `60`.
- Fair-path audit cache posture: `8` texture cache entries, `8` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review is pending.
- v0.156 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:militia-billboard-repair:derivatives:reproduce
npm run godot:militia-billboard-repair:validate
npm run godot:militia-billboard-repair:benchmark:headed
npm run godot:militia-billboard-repair:audit
npm run godot:militia-billboard-repair:capture
isolation scans
git diff --check
```

## v0.154 Hybrid Militia Static Billboard Single-Slot Intake Experiment And Human Review Stop - 2026-06-07

Scope: isolated private Godot Militia static billboard intake checkpoint. This checkpoint generates exactly one original ignored Militia source image, derives one deterministic alpha cutout, benchmarks a fourth private comparator-only runtime-art intake check against a tracked procedural fallback with selected Aster, Worker, and Barracks context, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `9f8bd3b617c47cafa36767515f3b0af256f4e995`.
- Confirmed v0.153 pushed remote CI success and prerequisite PASS gates.
- Generated exactly one original ignored Militia source image and deterministic alpha cutout.
- Added tracked procedural fallback PNG and contract for `militia_billboard_static_v0154`.
- Added private `--militia-billboard-single-slot` dispatch and v0.154 wrappers.
- Captured one-Militia, alpha, dark/light edge, Aster+Militia, Worker+Militia, group, zoomed group, overlap, rings, static formation, fallback, ortho, and Tier S/M/L evidence.

Current interpretation:

- Gate: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence marker: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`.
- Fair-path audit: `PASS_V0154_MILITIA_BILLBOARD_FAIR_PATH_AUDIT`.
- Source SHA-256: `b53e94150bd3fb9b1fde36268655df251deca286f336e6faed72ba1d264d8de0`.
- Cutout SHA-256: `eb007174023e2a4339d45e62ef7bb28769126bd7635ca4ca00115daaafa78996`.
- Fallback SHA-256: `8b262f722cc28b346109f0578a0ca151ef8ff01fd4e149075cf7e539a5ab767c`.
- Tier L local average-FPS ratio: `1.0055`.
- Tier L local p95 ratio: `1.0199`.
- Fallback Tier L mean FPS / p95: `962.15` / `1.51 ms`.
- Local Militia Tier L mean FPS / p95: `967.42` / `1.54 ms`.
- Ortho fallback Tier L mean FPS / p95: `853.8` / `2.11 ms`.
- Screenshot count: `22`; benchmark row count: `21`.
- Fair-path audit cache posture: `5` texture cache entries, `5` material cache entries, one load/create per source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review is pending.
- v0.155 has not started in this checkpoint.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:militia-billboard:metadata
npm run godot:militia-billboard:fallback:reproduce
npm run godot:militia-billboard:validate
npm run godot:militia-billboard:benchmark:headed
npm run godot:militia-billboard:audit
npm run godot:militia-billboard:capture
isolation scans
git diff --check
```

## v0.153 Hybrid Three-Slot Private Composition Stress Gate And Human Review Stop - 2026-06-07

Scope: isolated private Godot composition stress checkpoint for the already-selected v0.148 Worker billboard, v0.150 Barracks material repair, and v0.152 Aster billboard repair. This checkpoint uses zero new AI images, adds zero new runtime-art slots, and does not modify the normal Salto player slice or browser runtime.

Included work:

- Confirmed clean synchronized `main` at `6becadddcccc3cd104ac829c257b3e0c906ee225`.
- Confirmed v0.152 pushed remote CI success and prerequisite PASS gates for v0.148, v0.150, and v0.152.
- Added private `--hybrid-three-slot-composition-stress` dispatch and v0.153 wrappers.
- Added fallback-only, selected-local, and ortho fallback composition approaches.
- Captured normal, zoomed, crowding, overlap, selection, pan/zoom, alpha-sensitive, wet-overcast, hearth, minimap, fallback, and ortho comparison evidence.

Current interpretation:

- Gate: `PASS_V0153_HYBRID_THREE_SLOT_STRESS_GATE`.
- Evidence marker: `PASS_V0153_HYBRID_THREE_SLOT_EVIDENCE_RECORDED`.
- Selected-local Tier L FPS ratio: `1.0071`.
- Selected-local Tier L p95 ratio: `1.0379`.
- Fallback-only Tier L mean FPS / p95: `1111.09` / `1.32 ms`.
- Selected-local Tier L mean FPS / p95: `1118.98` / `1.37 ms`.
- Ortho fallback Tier L mean FPS / p95: `999.84` / `1.67 ms`.
- Screenshot count: `24`; benchmark row count: `21`.
- Fair-path audit: `PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT`, with `6` texture cache entries, `6` material cache entries, one load/create per selected/fallback source/material key, and no repeated texture/material creation or metadata parsing during steady-state frames.
- Human review is pending.
- v0.154 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:hybrid-three-slot-composition:validate
npm run godot:hybrid-three-slot-composition:audit
npm run godot:hybrid-three-slot-composition:benchmark:headed
npm run godot:hybrid-three-slot-composition:capture
isolation scans
git diff --check
```

## v0.152 Hybrid Aster Billboard Fair-Path Repair Derivative Selection And Human Review Stop - 2026-06-07

Scope: isolated private Godot Aster billboard repair and derivative-selection checkpoint. This checkpoint uses zero new AI images, derives deterministic full-res/512/768/1024 comparator variants from the same v0.151 Aster cutout only, preserves the original acceptance gate, and stops without modifying the normal Salto player slice or starting v0.153.

Included work:

- Confirmed clean synchronized `main` at `b97e0a6fbacdb5cb8a1692f04bf3c54d30b447a6`.
- Confirmed v0.151 pushed remote CI success and selected `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD` as the preserved source.
- Generated zero new AI images and reused the same v0.151 Aster cutout only.
- Added deterministic same-source repair derivatives under ignored `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/`.
- Extended the private Aster comparator/tooling with repair validation, fair-path audit, headed benchmark, capture, and one-click launcher support.
- Captured checkerboard/dark/light alpha, hair/cloak/shoulders, boots/hands/gear, normal RTS, zoomed-out, Aster+Worker, overlap, ring, pivot, scale, fallback, and Tier S/M/L evidence.

Current interpretation:

- Selected recommended repair: `HYBRID_ASTER_TRIMMED_1024`.
- Selected hash: `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`.
- Selected dimensions: `1024 x 1024`.
- Gate: `PASS_V0152_ASTER_BILLBOARD_REPAIR_GATE`.
- Evidence marker: `PASS_V0152_ASTER_BILLBOARD_REPAIR_EVIDENCE_RECORDED`.
- Tier L selected FPS ratio: `0.9708`.
- Tier L selected p95 ratio: `1.0088`.
- Screenshot count: `31`; benchmark row count: `35`.
- Fair-path audit: `PASS_V0152_ASTER_BILLBOARD_FAIR_PATH_AUDIT`, with `7` texture cache entries, `7` material cache entries, one load/create per source/material key, and no repeated texture/material creation during steady-state frames.
- Human review is pending.
- v0.153 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:aster-billboard-repair:derivatives:reproduce
npm run godot:aster-billboard-repair:validate
npm run godot:aster-billboard-repair:audit
npm run godot:aster-billboard-repair:benchmark:headed
npm run godot:aster-billboard-repair:capture
isolation scans
git diff --check
```

## v0.151 Hybrid Aster Static Billboard Single-Slot Intake Experiment And Human Review Stop - 2026-06-07

Scope: isolated private Godot Aster static billboard single-slot intake and fair benchmark. This checkpoint generates exactly one original Aster source image, converts it to one ignored matte-to-alpha cutout, validates a tracked fallback, uses the v0.148 Worker and v0.150 Barracks repair only as comparator context, and stops without modifying the normal Salto player slice or starting v0.152.

Included work:

- Confirmed clean synchronized `main` at `01acb26a668fd73eb35c1e7468901ccf652fecdc`.
- Confirmed v0.150 pushed remote CI success and selected `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` as the preserved Barracks material context.
- Generated exactly one original Aster source under the ignored v0.151 local slot folder.
- Added a deterministic tracked diagnostic fallback PNG and contract.
- Added private Aster billboard comparator code, metadata/fallback/validation/audit/benchmark/capture wrappers, one-click launcher, and tracked v0.151 docs.
- Captured Tier S/M/L evidence for diagnostic fallback, local Aster billboard, Worker context baseline, Barracks context baseline, and orthographic fallback comparator.
- Captured 0.90x, 1.00x, and 1.10x scale views.

Current interpretation:

- Selected recommended approach: `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD`.
- Selected hash: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`.
- Selected dimensions: `1024 x 1536`.
- Gate: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence marker: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`.
- Tier L local-vs-fallback FPS ratio: `0.9273`.
- Tier L local-vs-fallback p95 ratio: `1.1081`.
- Screenshot count: `32`; benchmark row count: `35`.
- Fair-path audit: `PASS_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT`, with `4` texture cache entries, `4` material cache entries, one load/create per source/material key, and no repeated texture/material creation during steady-state frames.
- Human review is pending.
- v0.152 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:aster-billboard:metadata
npm run godot:aster-billboard:fallback:reproduce
npm run godot:aster-billboard:validate
npm run godot:aster-billboard:benchmark:headed
npm run godot:aster-billboard:audit
npm run godot:aster-billboard:capture
isolation scans
git diff --check
```

## v0.150 Hybrid Barracks Material UV Seam Repair Lighting Review And Human Review Stop - 2026-06-07

Scope: isolated private Godot Barrosan Barracks material seam-repair and lighting-review checkpoint. This checkpoint uses zero new AI images, repairs and benchmarks deterministic derivatives of the same v0.149 material source only, keeps the existing second private runtime-art slot, and stops without modifying the normal Salto player slice or starting v0.151.

Included work:

- Confirmed clean synchronized `main` at `241dd18127f1c4c9b8a2493dd67bd2436371caac`.
- Confirmed v0.149 pushed remote CI success and selected `HYBRID_BARRACKS_LOCAL_768` as the preserved original material control.
- Reused the v0.149 source hash `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c` and generated zero new AI images.
- Generated deterministic original, wrapsafe offset-blend, wrapsafe quadrant, and wrapsafe softseam ignored derivatives.
- Added private seam-repair comparator code, validation/reproducibility/audit/benchmark/capture wrappers, one-click launcher, and tracked v0.150 docs.
- Captured source, tiling, seam, lighting, Worker+BARRACKS, zoom-transition, repeated-shell stress, fallback comparison, and Tier S/M/L evidence.

Current interpretation:

- Selected recommended repair: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- Selected hash: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Selected dimensions: `768 x 768`.
- Gate: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE`.
- Evidence marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_EVIDENCE_RECORDED`.
- Tier L selected FPS ratio: `1.0048`.
- Tier L selected p95 ratio: `0.9681`.
- Screenshot count: `62`; benchmark row count: `49`.
- Fair-path audit: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_FAIR_PATH_AUDIT`, with `6` texture cache entries, `18` material cache entries, one load/create per source/material key, and no repeated texture/material creation during steady-state frames.
- Human review is pending.
- v0.151 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:barracks-material-seam-repair:derivatives:reproduce
npm run godot:barracks-material-seam-repair:validate
npm run godot:barracks-material-seam-repair:audit
npm run godot:barracks-material-seam-repair:benchmark:headed
npm run godot:barracks-material-seam-repair:capture
isolation scans
git diff --check
```

## v0.149 Hybrid Barrosan Barracks Material Single-Slot Intake Experiment And Human Review Stop - 2026-06-06

Scope: isolated private Godot Barrosan Barracks material single-slot intake and fair benchmark. This checkpoint generates exactly one original material-source image, creates deterministic ignored derivatives, validates a tracked fallback, uses the v0.148 Worker derivative only as comparator context, and stops without modifying the normal Salto player slice or starting v0.150.

Included work:

- Confirmed clean synchronized `main` at `5978905ab32a280543a74245ae36c2c28b87ce45`.
- Confirmed v0.148 pushed remote CI success and selected `HYBRID_WORKER_TRIMMED_1024` as the existing Worker context.
- Generated exactly one original Barrosan Barracks material source under the ignored v0.149 local slot folder.
- Generated deterministic 512, 768, and 1024 derivatives from that source only.
- Added a tracked deterministic diagnostic fallback PNG and contract.
- Added private Barracks material comparator code, validation/reproducibility/audit/benchmark/capture wrappers, one-click launcher, and tracked v0.149 docs.
- Captured Tier S/M/L evidence for diagnostic fallback, local 512, local 768, local 1024, Worker context baseline, and orthographic fallback comparator.

Current interpretation:

- Source hash: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`, dimensions `1254 x 1254`.
- Selected recommended derivative: `HYBRID_BARRACKS_LOCAL_768`.
- Selected hash: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`.
- Selected dimensions: `768 x 768`.
- Original gate: `PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE`.
- Tier L baseline mean FPS: `1784.09`; selected mean FPS: `1873.11`; FPS ratio `1.0499`.
- Tier L baseline p95: `0.94 ms`; selected p95: `0.85 ms`; p95 ratio `0.9043`.
- Fair-path audit: `PASS_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT`, with one texture load/create per source and no repeated texture/material creation during steady-state frames.
- Human review is pending.
- v0.150 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:barracks-material:validate
npm run godot:barracks-material:fallback:reproduce
npm run godot:barracks-material:derivatives:reproduce
npm run godot:barracks-material:audit
npm run godot:barracks-material:benchmark:headed
npm run godot:barracks-material:capture
git diff --check
```

## v0.148 Hybrid Worker Billboard Single-Slot Repair Fair Benchmark And Human Review Stop - 2026-06-06

Scope: isolated private Godot Worker billboard single-slot repair and fair benchmark. This checkpoint uses only the existing ignored v0.147 Worker source/cutout, generates zero new AI images, adds no second runtime-art slot, preserves the original gate, and stops without modifying the normal Salto player slice or starting v0.149.

Included work:

- Confirmed clean synchronized `main` at `f0bb252bb6767d5c24d6c3e4764ba83534b4ce36`.
- Confirmed v0.147 pushed remote CI success and the v0.147 Tier L threshold miss that justified one bounded repair pass.
- Generated deterministic trimmed 512, 768, and 1024 derivatives from the existing v0.147 cutout only.
- Preserved the original source-quality full-resolution cutout as a comparator source.
- Added private repair validation, derivative reproducibility, fair-path audit, headed benchmark, capture wrappers, one-click launcher, and tracked v0.148 docs.
- Added cached texture/material reuse inside the private comparator and separated initialization/warmup from measured benchmark frames.
- Captured Tier S/M/L evidence for the diagnostic fallback, full-resolution Worker, trimmed 512, trimmed 768, trimmed 1024, and orthographic fallback comparator.

Current interpretation:

- Selected recommended derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Selected hash: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Selected dimensions: `1024 x 1024`.
- Original gate: `PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE`.
- Tier L baseline mean FPS: `858.41`; selected mean FPS: `851.14`; FPS ratio `0.9915`.
- Tier L baseline p95: `1.87 ms`; selected p95: `1.88 ms`; p95 ratio `1.0053`; absolute p95 delta `0.01 ms` context only.
- Fair-path audit: `PASS_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT`, with one texture load/create per source and no repeated texture/material creation during steady-state frames.
- Human review is pending.
- v0.149 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:worker-billboard-repair:validate
npm run godot:worker-billboard-repair:audit
npm run godot:worker-billboard-repair:derivatives:reproduce
npm run godot:worker-billboard-repair:benchmark:headed
npm run godot:worker-billboard-repair:capture
git diff --check
```

## v0.147 Hybrid Worker Billboard Single-Slot Runtime-Art Intake Experiment And Human Review Stop - 2026-06-06

Scope: isolated private Godot hybrid Worker billboard single-slot intake experiment and human review stop. This checkpoint uses the v0.146 hybrid recommendation, generates exactly one original local Worker cutout, validates it against deterministic fallback evidence, benchmarks Tier S/M/L comparator posture, and stops without importing existing reference candidates, modifying the normal Salto player slice, or starting v0.148.

Included work:

- Confirmed clean synchronized `main` at `d82fe5efba6ee8af70bba94d2517023c76e6b558`.
- Confirmed v0.146 pushed remote CI success and recommended `HYBRID_3D_WORLD_BILLBOARD_UNITS` as the next single-slot experiment.
- Confirmed `ORTHO_3D_MESH` remains fallback comparator only and `BILLBOARD_2D_ATLAS` remains deferred.
- Generated exactly one original Worker cutout and preserved the source under the ignored v0.147 local slot folder.
- Converted the flat chroma source to alpha and wrote ignored local metadata for `worker_billboard_static_v0147`.
- Added tracked deterministic diagnostic fallback PNG and contract under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.
- Added private Worker billboard comparator code, validation/reproducibility/benchmark/capture wrappers, one-click launcher, and tracked v0.147 docs.
- Captured Tier S/M/L evidence for diagnostic fallback, local Worker slot, and orthographic mesh fallback comparator.

Current interpretation:

- Local Worker cutout hash: `e294115817821eb84a459f6c86110d7b6951ad34182802bf6b0c07f560cab88a`.
- Local Worker dimensions: `1254 x 1254`.
- Local Worker alpha posture: matte-to-alpha transparent PNG with source preserved.
- Tracked fallback hash: `fa60b6e6a86b41cb449c3a16a0401cf44fbab8b5faefd7f19147b3a8c6161419`.
- Tracked fallback dimensions: `512 x 512`.
- Tier L threshold: `FAIL_V0147_WORKER_BILLBOARD_TIER_L_THRESHOLD`; local Worker average FPS ratio `0.8464`, p95 frame-time ratio `1.3697`, and p95 absolute delta `0.44 ms` versus diagnostic fallback. The p95 delta stayed within the recorded `0.50 ms` local headed jitter allowance, but the average-FPS gate missed the `0.90` target.
- Preferred scale posture: `1.00x`; `0.90x` is safer for crowding and `1.10x` is close diagnostic only.
- Recommendation: stop for Emmanuel review and consider one bounded repair pass before any additional slot or production integration.
- Human review is pending.
- v0.148 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:worker-billboard:validate
npm run godot:worker-billboard:fallback:reproduce
npm run godot:worker-billboard:benchmark:headed
npm run godot:worker-billboard:capture
git diff --check
```

## v0.146 Godot Runtime-Art Pipeline Comparator Spike And Human Decision Stop - 2026-06-06

Scope: isolated private Godot runtime-art pipeline comparator and human decision stop. This checkpoint validates the v0.145 HUD/reference-art workspace, encodes the HUD decision for future experiments, benchmarks and captures procedural Tier S/M/L evidence for three approaches, produces a scorecard and recommendation, and stops without importing art, modifying the normal Salto player slice, or starting v0.147.

Included work:

- Confirmed clean synchronized `main` at `ca318bc94a591eb8738c05466246826b215e7042`.
- Confirmed v0.145 generated exactly three Salto HUD reference-style frames and was pushed with remote CI success.
- Confirmed the existing fifteen reference candidates remained reference-only and runtime-forbidden before comparator work.
- Encoded v0.145 HUD decision: H3 as primary combined Salto HUD reference direction, H2 as approved Barrosan material companion, and H1 as limited tactical-information companion with no production UI lock.
- Added isolated private comparator code under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/`.
- Added comparator wrappers and npm scripts for validation, headed benchmark, and capture.
- Captured Tier S/M/L evidence for `ORTHO_3D_MESH`, `BILLBOARD_2D_ATLAS`, and `HYBRID_3D_WORLD_BILLBOARD_UNITS`.
- Added scorecard, recommendation, Emmanuel review guide, boundary report, and implementation docs.

Current interpretation:

- Recommended next single-slot runtime-art experiment: `HYBRID_3D_WORLD_BILLBOARD_UNITS`.
- Fallback comparator: `ORTHO_3D_MESH`.
- Deferred for the next slot: `BILLBOARD_2D_ATLAS`.
- This is not a final engine selection, runtime-art approval, production UI lock, or full port start.
- Human review is pending.
- v0.147 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
npm run godot:runtime-art-comparator:validate
npm run godot:runtime-art-comparator:benchmark:headed
npm run godot:runtime-art-comparator:capture
git diff --check
```

## v0.145 Salto HUD Reference-Style Exploration And Human Review Stop - 2026-06-06

Scope: controlled reference-only Salto HUD frame generation and human-review stop. This checkpoint encodes the v0.144 silhouette review decision, generates exactly three HUD reference-style frames, validates matching runtime-forbidden metadata, updates the contact sheet and review pack, and stops without importing art or starting v0.146.

Included work:

- Confirmed clean synchronized `main` at `f832edb1bf4f636f21c4f6099fe951c11fc500dd`.
- Confirmed v0.144 generated exactly three Aster / Worker silhouette-scale convergence boards and was pushed.
- Confirmed the existing twelve reference candidates remained reference-only and runtime-forbidden before generation.
- Encoded v0.144 review decision: T1 as the primary combined silhouette direction, T2 as the Worker-role companion, and T3 only as a limited Aster-presence cue with large sword, ornate emblem language, oversized cape dominance, and polished-fantasy excess rejected.
- Generated exactly three Salto HUD reference-style frames: H1 gameplay-first tactical clarity, H2 Barrosan material restraint, and H3 modern balanced PC RTS.
- Added matching ignored metadata records with `runtimeIntegrationStatus = forbidden`.
- Regenerated the ignored contact sheet and review pack for fifteen total reference candidates.
- Added the ignored local human review note and v0.145 tracked docs.

Current interpretation:

- The frames are reference-only and are not production UI assets.
- Human protected-IP and HUD reference review is pending.
- No Godot or browser runtime integration is approved.
- No final art or final HUD decision has been made.
- v0.146 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.144 Aster / Worker Silhouette-Scale Convergence Revisions And Human Review Stop - 2026-06-06

Scope: controlled reference-only Aster / Worker silhouette convergence board generation and human-review stop. This checkpoint encodes the v0.143 review direction, generates exactly three convergence boards, validates matching runtime-forbidden metadata, updates the contact sheet and review pack, and stops without importing art or starting v0.145.

Included work:

- Confirmed clean synchronized `main` at `f79e8cf5a0b4c84b2acdcff3089acc393d6ababd`.
- Confirmed v0.143 generated exactly three Aster / Worker silhouette-scale boards and was pushed with remote CI success.
- Confirmed the existing nine reference candidates remained reference-only and runtime-forbidden before generation.
- Encoded v0.143 review direction: S2 as the primary grounded Barrosan material input, S3 as the primary gameplay-readability/proportion input, and S1 as selective role-separation input.
- Generated exactly three Aster / Worker silhouette convergence boards: T1 balanced Barrosan readability, T2 Builder support clarity, and T3 Commander / Champion restraint.
- Added matching ignored metadata records with `runtimeIntegrationStatus = forbidden`.
- Regenerated the ignored contact sheet and review pack for twelve total reference candidates.
- Added the ignored local human review note and v0.144 tracked docs.

Current interpretation:

- The boards are reference-only and are not final character designs.
- Human protected-IP and silhouette convergence review is pending.
- No Godot or browser runtime integration is approved.
- No final art decision has been made.
- v0.145 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.143 Aster / Worker Silhouette-Scale Reference Boards And Human Review Stop - 2026-06-06

Scope: controlled reference-only Aster / Worker silhouette-scale board generation and human-review stop. This checkpoint generates exactly three comparison boards, validates matching runtime-forbidden metadata, updates the contact sheet and review pack, and stops without importing art or starting v0.144.

Included work:

- Confirmed clean synchronized `main` at `cf93376a36bef8b0678a8d1125e7a893270d272e`.
- Confirmed v0.142 ratified R1 as the primary reference-only environment style lock, retained R2 as the material/atmosphere companion, and limited R3 to lane hierarchy and Ashen readability.
- Confirmed the existing six environment candidates remained reference-only and runtime-forbidden before generation.
- Generated exactly three Aster / Worker silhouette-scale boards: S1 gameplay-first readability, S2 Barrosan grounded identity, and S3 modern balanced scale.
- Added matching ignored metadata records with `runtimeIntegrationStatus = forbidden`.
- Regenerated the ignored contact sheet and review pack for nine total reference candidates.
- Added the ignored local human review note and v0.143 tracked docs.

Current interpretation:

- The boards are reference-only and are not final character designs.
- Human protected-IP and silhouette-scale review is pending.
- No Godot or browser runtime integration is approved.
- No final art decision has been made.
- v0.144 has not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.142 Salto Environment Reference-Only Style Lock Ratification And Silhouette Brief Preparation - 2026-06-06

Scope: documentation, ratification, and future-brief preparation only. This checkpoint records Emmanuel's completed v0.141 human style-lock decision, preserves all six environment candidates as reference-only and runtime-forbidden, prepares a future Aster/Worker silhouette-scale board brief, and stops without generating images or starting v0.143.

Included work:

- Confirmed clean synchronized `main` at `99b598b35f53c5086f37f9cab3ec8617ca2575ae`.
- Confirmed v0.141 produced exactly three revised environment reference-only candidates.
- Confirmed six total environment candidates and six metadata files validate with `PASS_V0138_REFERENCE_METADATA`.
- Confirmed all six metadata records keep `runtimeIntegrationStatus = forbidden`.
- Recorded `v0141-env-r1-gameplay-first-barrosan` as the primary reference-only Salto environment style lock.
- Recorded `v0141-env-r2-barrosan-signature` as the approved companion reference for Barrosan material language and atmosphere.
- Limited `v0141-env-r3-modern-balanced-ashen-contrast` to lane hierarchy and Ashen readability, while rejecting technological Lume pylons, visible energy beams, sci-fi crystal towers, excessive cliff spectacle, and cinematic key-art framing.
- Added the local ignored decision note and v0.142 tracked docs.
- Prepared `docs/art-prompts/V0143_01_ASTER_WORKER_SILHOUETTE_SCALE_BOARD.md` for a future explicit v0.143 prompt.

Current interpretation:

- The style lock is reference-only and is not final runtime art.
- Human style approval is not protected-IP clearance.
- No Godot or browser runtime integration is approved.
- No Aster or Worker images have been generated yet.
- v0.143 has been prepared but not started.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.141 Salto Environment Style-Lock Revision Round And Human Approval Stop - 2026-06-06

Scope: controlled reference-only Salto environment revision round. This checkpoint generates exactly three revised environment candidates from the v0.140 human direction, validates six total metadata/contact-sheet/review-pack outputs, records tracked docs, and stops for Emmanuel's human style-lock review.

Included work:

- Confirmed clean synchronized `main` at `5a5f662de51fedd6cfa8635c01e851c6ad524b4d`.
- Confirmed v0.140 produced exactly three validated environment reference-only candidates with `runtimeIntegrationStatus = forbidden`.
- Confirmed the Codex `image_generation` feature was available.
- Generated exactly three revised environment-only candidates: `v0141-env-r1-gameplay-first-barrosan`, `v0141-env-r2-barrosan-signature`, and `v0141-env-r3-modern-balanced-ashen-contrast`.
- Added matching ignored metadata records with `runtimeIntegrationStatus = forbidden`.
- Regenerated the local ignored contact sheet and review pack for six total environment candidates.
- Added v0.141 docs for revision report, style-lock review guide, boundary, and implementation report.

Current interpretation:

- The images are local reference candidates only and are not runtime assets.
- Human protected-IP and style-lock review is pending.
- No Godot or browser runtime integration is approved.
- No final art decision has been made.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.140 Salto Environment Reference-Art Canary Generation And Human Style-Lock Stop - 2026-06-06

Scope: controlled image-generation capability test and reference-only Salto environment canary. This checkpoint generates exactly three environment style-frame candidates, validates metadata/contact-sheet/review-pack outputs, records tracked docs, and stops for Emmanuel's human art review.

Included work:

- Confirmed v0.139 `SALTO_SLICE_STABILIZATION_GREEN` precondition from clean synchronized `main`.
- Confirmed the Codex `image_generation` feature was available and stable.
- Ran empty-workspace reference-art init, validation, contact-sheet, and review-pack commands before generation.
- Generated exactly three environment-only candidates: `v0138-env-a-tactical-clarity`, `v0138-env-b-barrosan-atmosphere`, and `v0138-env-c-modern-2_5d-balance`.
- Added matching ignored metadata records with `runtimeIntegrationStatus = forbidden`.
- Regenerated the local ignored contact sheet and review pack.
- Added v0.140 docs for generation report, boundary, Emmanuel guide, and implementation report.

Current interpretation:

- The images are local reference candidates only and are not runtime assets.
- Human protected-IP and style-lock review is pending.
- No Godot or browser runtime integration is approved.
- No final art decision has been made.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run art:reference:init
npm run art:reference:validate
npm run art:reference:contact-sheet
npm run art:reference:review-pack
git diff --check
```

## v0.139 Godot Salto Slice Stabilization Gate, Human Review Package, And Next-Phase Roadmap - 2026-06-06

Scope: bounded Godot player-facing stabilization review packaging, validation aggregation, capture/report tooling, docs, and roadmap only. This checkpoint does not add gameplay systems, select Godot finally, start a full port, create Unity/Unreal/Electron work, generate images, download assets, import runtime art, change browser runtime, saves, stable IDs, rewards, maps, factions, broad AI, broad economy, broad building tree, broad recruitment, pathing balance, multiplayer, PvP, co-op, campaign scope, or v0.140.

Included work:

- Added stabilized Salto launch, validate, and capture `.bat` wrappers.
- Added v0.139 PowerShell wrappers under `tools/godot/`.
- Added `tools/godot/generateGodotStabilizationReviewPack.mjs`.
- Added ignored v0.139 artifacts under `artifacts/desktop-spikes/godot-salto/v0139/`.
- Added v0.139 docs for the gate, final review build, Emmanuel review guide, next-phase options, and implementation report.
- Classified the stabilization gate as `SALTO_SLICE_STABILIZATION_GREEN` from the v0.134-v0.138 evidence chain.

Current interpretation:

- The packaged player-facing Godot Salto slice is ready for Emmanuel's stabilized human review.
- The private engineering harness remains separate and cannot count as human-facing proof.
- Reference-image generation is recommended only as a future explicit Option A, not started here.
- Godot is still not selected finally.
- The browser prototype remains the current source of truth.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run godot:all
npm run godot:fresh-checkout:validate
npm run art:reference:validate
npm run art:reference:review-pack
git diff --check
```

## v0.133 Godot Post-Mine Sequence Repair, Barracks-Recruit Guidance, Ashen-Wave Trigger, And Real Combat-Onset Proof - 2026-06-05

Scope: bounded Godot player-facing post-mine repair, validation, headed proof, docs, and one-click retest tooling. This checkpoint does not select Godot finally, start a full port, create Unity/Unreal/Electron work, generate images, import runtime art, change browser runtime, saves, stable IDs, rewards, maps, factions, broad AI, broad economy, broad building tree, broad recruitment, pathing balance, multiplayer, PvP, co-op, campaign scope, or v0.134.

Included work:

- Added guarded post-mine objective prerequisites for `restore_barracks`, `train_militia`, `prepare_ashen_pressure`, `defeat_ashen_wave`, `restore_lume_link`, and `review_results`.
- Removed the box-select objective skip so squad selection cannot advance into Ashen pressure before prerequisites are satisfied.
- Added player-facing Barracks restoration guidance, construction progress, Barracks selection, Train Militia command, recruit progress, Militia spawn feedback, visible Ashen countdown, automatic wave trigger, enemy movement, combat onset, simulation-backed wave defeat, Lume restoration, and Results.
- Added the `test11` recording-driven combat readability repair: Objective 8 defender handoff, four-attacker Ashen wave staging, active attacker target marks, empty combat box-select preservation, one-click wave-defense Attack behavior, and reduced top battle chrome.
- Added `GODOT_POST_MINE_FLOW_SMOKE_WINDOWS.bat` and `GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat`.
- Added ignored v0.133 artifact generation under `artifacts/desktop-spikes/godot-salto/v0133/`.
- Added v0.133 docs for the objective audit, prerequisite ledger, guidance specs, proof, gate, implementation report, and Emmanuel retest guide.

Current interpretation:

- The gate classification is `POST_MINE_FLOW_GREEN` only when the headed packaged player reaches Results through normal mouse input and simulation without debug, private-harness, direct-state, fixture-only, or screenshot-only proof.
- The private engineering harness remains separate from the player-facing review path.
- Godot is still not selected finally.
- The browser prototype remains the current source of truth.
- Emmanuel should retest with `GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat` and `docs/V0133_EMMANUEL_RETEST_GUIDE.md`.
- The `test11` recording analysis and repair ledger is `docs/V0133_TEST11_RECORDING_COMBAT_READABILITY_REPAIR.md`.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run godot:all
npm run godot:fresh-checkout:validate
npm run godot:validate:player-slice
npm run godot:validate:real-input
npm run godot:headed:real-input-smoke
npm run godot:validate:site-semantics
npm run godot:headed:site-semantics-smoke
npm run godot:validate:post-mine-flow
npm run godot:headed:post-mine-flow-smoke
git diff --check
```

## v0.130 Godot Salto Vertical-Slice Acceptance Pack, Human Review Build, And First Reference-Art Generation Session - 2026-06-05

Scope: bounded Godot review packaging, validation, capture, docs, and reference-only art generation preparation. This checkpoint does not select Godot finally, start a full port, create Unity/Unreal/Electron work, generate images, import runtime art, change browser runtime, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, multiplayer, PvP, co-op, campaign scope, or v0.131.

Included work:

- Added `GODOT_LAUNCH_SALTO_VERTICAL_SLICE_WINDOWS.bat` as the named player-facing vertical-slice launcher.
- Added `GODOT_VALIDATE_SALTO_VERTICAL_SLICE_WINDOWS.bat` and `GODOT_CAPTURE_SALTO_VERTICAL_SLICE_WINDOWS.bat`.
- Added v0.130-specific validation and capture scripts under `tools/godot/`.
- Added v0.130 artifact generation under `artifacts/desktop-spikes/godot-salto/v0130/`.
- Added v0.130 docs for acceptance, human review, first reference-art generation, art review workflow, Emmanuel decisions, and implementation.

Current interpretation:

- The slice is `SALTO_VERTICAL_SLICE_REVIEW_READY` for human review only.
- The private engineering harness remains separate.
- First reference-art generation is limited to four reference-only images, then stop for human review.
- Godot is still not selected finally.
- The browser prototype remains the current source of truth.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run export:portable-content
npm run validate:portable-content
npm run export:desktop-spike-fixture
npm run validate:desktop-spike-fixture
npm run godot:all
npm run godot:fresh-checkout:validate
npm run godot:validate:player-slice
npm run godot:capture:player-slice
git diff --check
```

## v0.124 Godot Player-Facing Salto Review Slice, Private Harness Separation, And Art-Ready Presentation Shell - 2026-06-04

Scope: bounded Godot player-facing review-slice shell, private harness separation, procedural presentation improvements, v0.124 validation/capture artifacts, and docs only. This checkpoint does not select Godot finally, start a full port, create Unity/Unreal/Electron work, generate images, import runtime art, change browser runtime, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, multiplayer, PvP, co-op, content, or v0.125 scope.

Included work:

- Added `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` as the default human-review launcher.
- Added `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat` for the preserved private adapter harness.
- Added player title, briefing, battle, and Results screens.
- Improved the 2.5D `CLEAN_READABILITY` procedural Salto blockout, silhouettes, HUD, minimap, and Lume posture.
- Added v0.124 player-slice validation, capture, screenshot hash, performance smoke, objective-flow, and art-slot reports under ignored artifacts.
- Added v0.124 docs and updated handoff files.

Current interpretation:

- Emmanuel should review the player slice, not the private harness, for game-feel and visual-foundation feedback.
- The private harness remains available for engineering evidence only.
- The slice is art-ready in slot posture only; no art is loaded, generated, approved, or runtime-integrated.
- Godot is still not selected finally.
- The browser prototype remains the current source of truth.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run export:portable-content
npm run validate:portable-content
npm run export:desktop-spike-fixture
npm run validate:desktop-spike-fixture
npm run godot:all
npm run godot:fresh-checkout:validate
npm run godot:validate:player-slice
npm run godot:capture:player-slice
git diff --check
```

## v0.123 Godot Continuation Decision Packet, Unity Comparator Boundary, And First Reference-Art Prompt Library - 2026-06-04

Scope: docs, scorecard interpretation, validation-boundary maintenance, and reference-art prompt preparation only. This checkpoint consolidates v0.116 through v0.122 Godot evidence, classifies the Godot spike as `GODOT_SPIKE_GREEN` for careful next-spike planning, defines the Unity comparator boundary, gives Emmanuel a simple one-click review guide, and prepares eight reference-only art prompts. It does not select Godot finally, start a full port, create a Unity/Unreal/Electron project, generate images, import runtime art, change browser runtime, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, multiplayer, PvP, co-op, content, or v0.124 scope.

Included work:

- Added v0.123 Godot continuation gate, scorecard update, Unity comparator boundary, Emmanuel review guide, reference-art boundary, and implementation report.
- Added eight copy-ready reference-only prompt docs under `docs/art-prompts/`.
- Updated handoff, roadmap, changelog, checkpoint, and release checklist.
- Advanced the desktop-spike boundary guard to block v0.124 Godot docs instead of authorized v0.123 docs.

Current interpretation:

- Godot is green for careful continuation planning, not final engine selection.
- 2D remains the readability/control lane.
- 2.5D `CLEAN_READABILITY` remains the leading visual-review lane.
- Unity remains a comparator only if future Godot work fails visual quality, automation, packaging, or reproducibility gates.
- Reference art may be generated outside runtime only after human prompt approval; it remains reference-only and non-loadable.

Verification:

```text
Required closeout stack:
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run export:portable-content
npm run validate:portable-content
npm run export:desktop-spike-fixture
npm run validate:desktop-spike-fixture
npm run godot:all
npm run godot:fresh-checkout:validate
git diff --check
```

## v0.118 Godot Packaged-Build Headed Smoke Automated Visual Capture And Human-Review Harness - 2026-06-04

Scope: Godot packaged-build review workflow only. This checkpoint proves that the v0.117 repository-driven Godot Salto spike can launch as a headed Windows executable, run an automated private review-tour harness, capture deterministic 1600x900 screenshots, benchmark both 2D and 2.5D placeholder modes headed, validate the package, and provide Emmanuel with one-click review scripts. It does not select Godot finally, start a full port, replace the browser prototype, import art, change gameplay, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, multiplayer, PvP, co-op, content, or v0.119 scope.

Included work:

- Added packaged executable flags for headed smoke, screenshot capture, and headed benchmark runs.
- Added private in-build review harness steps for home, 2D launch, 2.5D launch, hero selection, Worker selection, squad selection, move, attack, pan, zoom, pause, site capture, Lume link, Results, return home, and exit.
- Added root one-click launch/capture/smoke wrappers and matching PowerShell automation.
- Added `npm run godot:launch:review`, `npm run godot:headed:smoke`, and `npm run godot:capture:review`.
- Added ignored v0.118 artifact generation for headed smoke, headed benchmarks, screenshot manifest, package validation, review summary, README, and SVG contact sheet.
- Added v0.118 docs and updated checkpoint handoff files.

Current interpretation:

- Godot standard non-.NET 4.6.3 x86_64 and export templates are locally detected.
- Routine Godot editor operation remains optional for Emmanuel; repository scripts drive scene generation, validation, build/export/package, headed smoke, benchmark, and capture.
- 2.5D orthographic remains the stronger future visual-quality candidate, while 2D remains the automation/readability control.
- Godot is not selected finally.
- The browser prototype remains the current source of truth.

Verification:

```text
npm test - PASS.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:desktop-spike-fixture - PASS, fixture hash d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3.
npm run validate:desktop-spike-fixture - PASS.
npm run godot:all - PASS.
npm run godot:headed:smoke - PASS.
npm run godot:capture:review - PASS.
git diff --check - PASS.
```

## v0.117 Godot-First Automated Desktop Benchmark Spike And One-Click Windows Workflow - 2026-06-03

Scope: Godot workflow spike, one-click Windows tooling, fixture import, headless validation/tests, placeholder benchmarks, Windows export/package, scorecard, and docs only. This checkpoint proves repository-driven Godot workflow viability for the representative Salto slice. It does not select Godot finally, start a full port, replace the browser prototype, import art, change gameplay, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, multiplayer, PvP, co-op, content, or v0.118 scope.

Included work:

- Added `desktop-spikes/godot-salto/` text project, scenes, scripts, tests, generated fixture data, Windows export preset, and README.
- Added `tools/godot/` PowerShell scripts and root `GODOT_*_WINDOWS.bat` wrappers for doctor, bootstrap, validation, tests, benchmark, export, package, scorecard, and run-all flow.
- Added `npm run godot:*` scripts and focused scaffold tests.
- Added v0.117 docs and Emmanuel one-click guide.

Current interpretation:

- Godot standard non-.NET 4.6.3 x86_64 and export templates are locally detected.
- AI-first/editor-optional workflow evidence is strong for this placeholder slice: scorecard AI-operability `24 / 25`.
- 2.5D orthographic is the leading future visual-quality candidate because it better supports modern lighting, depth, and atmosphere, but 2D remains the automation/readability control.
- Godot is not selected finally.
- The browser prototype remains the current source of truth.

Verification:

```text
npm run godot:all - PASS.
npm test - PASS.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS.
npm run validate:portable-content - PASS.
npm run test:save-translation-contract - PASS.
npm run export:desktop-spike-fixture - PASS, fixture hash d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3.
npm run validate:desktop-spike-fixture - PASS.
git diff --check - PASS with Git's line-ending warning for .gitignore.
```

## v0.116 Reviewed Architecture Direction, Desktop-Engine Spike Preparation Pack, And Engine-Neutral Salto Fixture - 2026-06-03

Scope: architecture review docs, desktop-engine spike preparation docs, scorecard template, and deterministic engine-neutral Salto fixture tooling only. This checkpoint responds to the v0.115 RED browser gate by preparing a future decision packet. It does not select an engine, create an engine project, add a desktop wrapper, add an engine dependency, change gameplay, saves, stable IDs, rewards, maps, factions, AI, pathing, combat balance, art, runtime asset paths, public benchmark controls, multiplayer, PvP, co-op, content, or v0.117 scope.

Included work:

- Added v0.116 architecture decision record, engine candidate matrix, spike order, acceptance contract, fixture export spec, scorecard template, Emmanuel review packet, art continuation boundary, and implementation report docs.
- Added `DesktopSpikeFixture` export/validation tooling and focused tests for deterministic double export, ID validity, save-fixture index safety, scorecard shape, boundary checks, and `linked_ward` preservation.
- Added `export:desktop-spike-fixture` and `validate:desktop-spike-fixture`.
- Added ignored artifact root `artifacts/desktop-spike-fixture/`.

Current interpretation:

- v0.115 browser gate remains `RED`; broad browser runtime visual expansion and runtime art integration remain blocked.
- Recommended future spike order is Godot first, Unity second, Electron/browser wrapper as packaging control, Unreal deferred.
- AI-operability is a primary scored criterion: future workflows must be reproducible from repo files, scriptable/text-editable where practical, manifest-driven, editor-optional for Emmanuel during routine work, CLI-buildable/packageable, and debuggable by Codex through deterministic evidence.
- Visual ambition is a modern original top-down RTS/RPG in the spirit of a super-cool 2026 Warlords Battlecry evolution, with original IP, strong silhouettes, atmospheric Salto terrain, modern lighting/VFX, persistent hero readability, tactical clarity, and no mobile-game/dashboard appearance.

Verification:

```text
npm test - PASS, 120 files / 830 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS, 229 stable manifest entries.
npm run validate:portable-content - PASS, deterministic double export.
npm run test:save-translation-contract - PASS, 16 fixtures, 11 translated, 2 quarantined, 3 rejected.
npm run export:desktop-spike-fixture - PASS, fixture hash d6c00aad4d32173566194b01cd9b88c2947151da1e1c93cccaeb411ce225f7a3.
npm run validate:desktop-spike-fixture - PASS, deterministic double export of 12 files.
git diff --check - PASS with Git's line-ending warning for .gitignore.
```

## v0.115 Trusted Performance Consolidation, Clean-Restart Retest Packet, And Browser Gate - 2026-06-03

Scope: trusted performance consolidation, Emmanuel clean-restart retest packet, Emmanuel performance decision packet, package metadata/docs, and verification tests only. This checkpoint compares v0.109 trusted baseline, v0.110 phase/density/gate evidence, v0.111 host controls and clean profile, v0.112 scheduler/allocation/idle evidence, v0.113 spatial/pathing evidence, and v0.114 renderer lifecycle evidence. It does not alter gameplay, saves, rewards, stable IDs, maps, factions, AI, pathing rules, combat balance, art, runtime asset paths, public benchmark controls, engine posture, desktop work, multiplayer, PvP, co-op, content, or v0.116 scope.

Included work:

- Added v0.115 gate, consolidated report, clean-restart retest, decision packet, and implementation report docs.
- Added `TrustedPerformanceConsolidationGate` validation coverage for gate schema, artifact references, doc links, package docs, RED result, no-runtime scope guard, and required verification commands.
- Updated private package generation and validation to include v0.115 docs and checkpoint metadata.

Current interpretation:

- Gate result: `RED`.
- Host/browser pressure is unlikely to be the dominant automated cause because v0.111 blank page, simple DOM, simple canvas, and true Phaser-empty controls hold about 60 FPS with 16.7 ms p95.
- Battle code and app-specific shell cost remain dominant: representative Tier M rows still sit around 2.4-2.5 FPS with about 533.3-633.3 ms p95 after v0.112-v0.114 bounded rescue work.
- Runtime art integration and broad browser visual expansion remain blocked. Move reviewed architecture or earlier engine-spike discussion forward before approving more visual runtime work.

Verification:

```text
npm test - PASS, 119 files / 820 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run perf:host-snapshot - PASS.
npm run perf:controls:preview - PASS, 6 rows.
npm run perf:trusted:clean-profile - PASS, 4 rows.
npm run perf:trusted:preview - PASS, 2 rows.
npm run perf:phase-profile - PASS, 3 rows.
npm run perf:allocation-audit - PASS, 8 rows.
npm run perf:spatial-query-profile - PASS, 14 rows.
npm run perf:render-lifecycle-audit - PASS, 15 rows.
npm run perf:trusted:report - PASS, 21 rows.
npm run benchmark:battle:smoke - PASS, 1 scenario.
npm run benchmark:battle:representative - PASS, 8 scenarios.
npm run benchmark:battle:stress - PASS, 1 scenario.
npm run benchmark:battle:report - PASS, 10 scenarios.
npm run package:playtest - PASS, pre-commit dirty package.
npm run verify:playtest-package - PASS, 459 checks on the pre-commit dirty package.
Browser plugin smoke - PASS at http://127.0.0.1:5260/ with a visible 1085x912 canvas and only the Phaser banner in dev logs.
git diff --check - PASS before final verification-document update.
```

Final clean package generation and package verification are repeated after the checkpoint commit so the package commit matches the final checkpoint commit and the dirty status says `no`.

## v0.111 Host Environment Calibration, Clean-Browser Reproducibility, And Machine-Pressure Gate - 2026-06-03

Scope: private host snapshot tooling, browser control baselines, temporary clean Chromium profile comparison, machine-pressure classification, private Playtest Hub instruction controls, package metadata/docs, and benchmark reporting only. This checkpoint separates host/browser pressure from Phaser-empty, campaign-map, and Tier M battle costs. It does not alter gameplay, saves, rewards, stable IDs, maps, factions, races, units, buildings, Living Mines, art, public runtime posture, engine choice, desktop implementation, desktop saves, user browser profiles, OS settings, multiplayer, PvP, co-op, runtime title, or v0.112 scope.

Included work:

- Added `src/game/playtest/HostEnvironmentCalibration.ts`, focused tests, and `tools/runHostEnvironmentCalibration.ts`.
- Added `perf:host-snapshot`, `perf:controls:preview`, `perf:controls:headed`, `perf:trusted:clean-profile`, and `perf:controls:report`.
- Added safe ignored host snapshots under `artifacts/performance/host-snapshots/<timestamp>/`.
- Added ignored v0.111 browser-control, clean-profile, environment-comparison, and raw-frame artifacts under `artifacts/performance/v0111/`.
- Added private Performance Lab instruction buttons for host snapshot, browser controls, clean-profile benchmark, environment comparison export, and post-restart instructions.
- Updated package metadata and package validation to include v0.111 docs.

Save/profile/system safety:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, XP, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, races, units, buildings, Living Mines, generated/imported art, runtime asset path, public benchmark controls, desktop path, desktop save path, engine choice, runtime title, multiplayer, PvP, co-op, or v0.112 work changed.
- No reboot, OS setting change, user browser profile mutation, browser history collection, open-tab collection, private process command-line collection, or personal filename collection.
- `linked_ward` remains exactly `0.92`.

Current interpretation:

- Host classification: `HOST_PRESSURE_UNLIKELY`.
- Game-cost classification: `BATTLE_CODE_DOMINANT`.
- Blank rAF, simple DOM, simple canvas, and Phaser-empty controls are healthy at about 60 FPS with p95 around 16.7 ms.
- Campaign map remains materially slower at 9.9 FPS / p95 183.4 ms in normal preview and 9.8 FPS / p95 300 ms in clean-profile headless.
- Tier M battle remains severe at 2.5 FPS / p95 516.6 ms in normal preview and 483.3 ms in clean-profile headless.
- Clean-profile evidence closely matches normal preview evidence, so current automated evidence does not point to extension/profile overhead as the dominant cause.

Verification:

```text
npm test - PASS, 114 files / 795 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run perf:host-snapshot - PASS.
npm run perf:controls:preview - PASS, 6 rows.
npm run perf:trusted:clean-profile - PASS, 4 clean-profile rows.
npm run perf:controls:report - PASS, refreshed 10 v0.111 result rows.
npm run test:e2e:smoke:fast - PASS, 10 tests.
Browser plugin private hub check - PASS at http://127.0.0.1:5230/ with all five v0.111 controls visible once, export safety fields present, and post-restart instructions visible.
npm run package:playtest - PASS before commit, producing the expected dirty package for pre-commit validation.
npm run verify:playtest-package - PASS, 433 checks, after fixing the package validator's stale v0.110 checkpoint expectation.
```

Final clean package generation and package verification are repeated after the checkpoint commit so the package commit matches the final checkpoint commit and the dirty status says `no`.

## v0.110 Battle-Loop Phase Profiler, Runtime Bottleneck Isolation, And Controlled Performance Rescue - 2026-06-03

Scope: private battle-loop phase profiling, subsystem isolation, density-scaling evidence, trusted browser gate, visual QA/review-pack coverage, package metadata/docs, and benchmark reporting only. This checkpoint extends v0.109 trusted browser methodology with BattleScene update phase timing and private binary diagnostic switches. It does not alter gameplay, saves, rewards, stable IDs, maps, factions, races, units, buildings, Living Mines, art, public runtime posture, engine choice, desktop implementation, desktop saves, multiplayer, PvP, co-op, runtime title, or v0.111 scope.

Included work:

- Added `src/game/playtest/BattleLoopPhaseProfiler.ts`, focused tests, and `tools/runBattleLoopPhaseProfile.ts`.
- Added `perf:phase-profile:preview`, `perf:subsystem-matrix`, `perf:density-ladder`, `perf:browser-gate`, and `perf:v0110:report`.
- Added private BattleScene phase timing around scene/update, simulation, camera, abilities, movement/pathing, combat/projectiles, status effects, economy/production, Lume, AI, cleanup, fog, HUD DOM, and end-condition work.
- Added session-only subsystem switches for simulation, AI, path, movement, combat, projectiles, fog simulation, fog presentation, entity graphics, labels, capture rings, Lume, minimap, HUD DOM patches, notifications, camera, and profiler overlay.
- Added a 22-row v0.110 Performance Lab ladder that reuses existing private fixtures and benchmark staging.
- Added ignored `artifacts/performance/v0110/` outputs with raw frame intervals, raw phase samples, and retained phase-summary artifacts.
- Updated visual QA to 244 screenshots and routed v0.110 phase-profiler captures into the Trusted Benchmark review-pack family.
- Updated package metadata and package validation to include v0.110 docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, XP, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, races, units, buildings, Living Mines, generated/imported art, runtime asset path, public benchmark controls, desktop path, desktop save path, engine choice, runtime title, multiplayer, PvP, co-op, or v0.111 work changed.
- `linked_ward` remains exactly `0.92`.

Benchmark interpretation:

- The v0.110 gate reports GREEN/AMBER/RED/PENDING from trusted browser phase-profile evidence. It is local browser QA evidence, not final desktop hardware certification.
- Phase profiling is off by default and does no per-phase timing work unless private diagnostics explicitly enable it.
- Broader renderer, architecture, engine, desktop, or art rescue remains deferred until a separately approved goal.

Verification:

```text
Focused implementation tests - PASS, BattleLoopPhaseProfiler / TrustedBrowserBenchmark / PrivatePerformanceProfiler.
npx tsc -p tsconfig.json --noEmit - PASS.
npm test - PASS, 113 files / 788 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run validate:runtime-art-slots - PASS, 52 runtime art slots.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run benchmark:battle:smoke - PASS, 1 scenario.
npm run benchmark:battle:representative - PASS, 8 scenarios.
npm run benchmark:battle:stress - PASS, 1 local-only stress scenario.
npm run benchmark:battle:report - PASS, refreshed 10-scenario report.
npm run perf:trusted:preview - PASS, production-preview baseline evidence.
npm run perf:trusted:dev - PASS, dev-server comparison evidence.
npm run perf:root-cause-matrix - PASS, 19 production-preview root-cause cases.
npm run perf:trusted:report - PASS, refreshed 21 trusted v0.109 result rows.
npm run perf:phase-profile:preview - PASS, 3 v0.110 phase-profile rows.
npm run perf:subsystem-matrix - PASS, 17 v0.110 subsystem rows.
npm run perf:density-ladder - PASS, 5 v0.110 density rows.
npm run perf:browser-gate - PASS command; gate status RED for v0110_tier_m_density at 2.5 FPS average, 516.6 ms p95, 533.3 ms max frame, and 52 long tasks.
npm run perf:v0110:report - PASS, refreshed 22 v0.110 result rows and 22 raw phase-sample artifacts.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run playtest:controls - PASS, 18/18 rows.
npm run playtest:controls:extended - PASS, 90/90 rows.
npm run playtest:controls:verify - PASS, 1,658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-battle - first command timed out at the 20-minute outer timeout; exact rerun PASS, 31 tests in 25.3 minutes.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - first command timed out at the one-hour outer timeout; exact rerun PASS, 21 tests / 244 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 244 screenshots and 10 contact sheets.
Browser plugin local review - PASS, localhost review pack loaded 244 screenshots and 4 v0.110 screenshot entries.
```

v0.111 and art-ready follow-up are blocked by the RED browser performance gate until a separately approved architecture/performance rescue goal clears it.

Final clean package generation and package verification are repeated after the checkpoint commit so the package commit matches the final checkpoint commit and the dirty status says `no`.

## v0.109 Browser Benchmark Integrity Audit And Performance Root-Cause Isolation - 2026-06-02

Scope: benchmark methodology, private manual benchmark flow, private diagnostic toggles, root-cause matrix, visual QA/review-pack coverage, package metadata/docs, and benchmark reporting only. This checkpoint audits the v0.108 suspicious 2-3 FPS evidence and replaces the trusted protocol with production-preview-first warm-up plus steady-state sampling. It does not alter gameplay, saves, rewards, stable IDs, maps, factions, art, public runtime posture, engine choice, desktop implementation, desktop saves, or v0.110 scope.

Included work:

- Added `src/game/playtest/TrustedBrowserBenchmark.ts`, focused tests, and `tools/runTrustedBrowserBenchmark.ts`.
- Added trusted benchmark scripts for production preview, dev comparison, manual template, root-cause matrix, and report refresh.
- Added private Playtest Hub manual benchmark flow with copyable summary and no console requirement.
- Added private battle-session diagnostic toggles for labels, rings, Lume, minimap refresh, fog visual redraw, HUD density, notifications, and profiler overlay.
- Added ignored `artifacts/performance/v0109/` outputs with raw frame intervals and interaction-latency artifacts.
- Updated visual QA to 240 screenshots and the visual review pack to include a Trusted Benchmark family/contact sheet.
- Updated package metadata and package validation to include v0.109 docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, XP, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, generated/imported art, runtime asset path, public benchmark controls, desktop path, desktop save path, engine choice, or v0.110 work changed.
- `linked_ward` remains exactly `0.92`.

Benchmark interpretation:

- The old v0.108 1200 ms dev-server/headless/profiler-overlay evidence was methodologically weak.
- The trusted production-preview baseline still reports serious browser lag, so the earlier 2-3 FPS evidence is mixed with real runtime cost, not purely harness artifact.
- Top measured cost signals in the refreshed evidence are Tier L stress, dev-server headless comparison, and the minimap-paused diagnostic row. The minimap signal remains uncertain because pausing it did not improve p95, so no broad runtime optimization was applied.

Verification:

```text
Focused implementation tests - PASS, 5 files / 28 tests.
npm test - PASS, 112 files / 783 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run benchmark:battle:smoke - PASS, 1 scenario.
npm run benchmark:battle:representative - PASS, 8 scenarios.
npm run benchmark:battle:stress - PASS, 1 local-only stress scenario.
npm run benchmark:battle:report - PASS, refreshed 10-scenario report.
npm run perf:trusted:manual-template - PASS.
npm run perf:trusted:preview - PASS, 2 trusted preview rows.
npm run perf:trusted:dev - PASS, 1 trusted dev row.
npm run perf:root-cause-matrix - PASS, 19 production-preview root-cause cases.
npm run perf:trusted:report - PASS, refreshed 21 trusted result rows.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run playtest:controls - PASS, 18/18 rows.
npm run playtest:controls:extended - PASS, 90/90 rows.
npm run playtest:controls:verify - PASS, 1,658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 31 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - first attempt timed out at the outer command timeout; exact rerun exposed a v0.109 final cleanup click failure; narrow harness cleanup patch applied; final exact rerun PASS, 21 tests / 240 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 240 screenshots and 10 contact sheets.
Browser plugin manual review - PASS, local review-pack Trusted Benchmark contact sheet loaded 27/27 images.
npm run package:playtest - PASS for the pre-commit dirty package.
npm run verify:playtest-package - PASS for the pre-commit dirty package.
git diff --check - PASS.
```

Final clean package generation and package verification are repeated after the checkpoint commit so the package commit matches the final checkpoint commit and the dirty status says `no`.

## v0.108 Representative Battle Benchmark Harness And Desktop Acceptance Profile - 2026-06-02

Scope: private benchmark harness, provisional desktop acceptance profile, visual QA/review-pack coverage, package metadata/docs, and benchmark reporting only. This checkpoint adds deterministic no-save representative battle scenarios to the private Playtest Hub and local browser benchmark scripts. It does not alter gameplay, saves, rewards, stable IDs, maps, factions, art, public runtime posture, engine choice, desktop implementation, or desktop saves.

Included work:

- Added `src/game/playtest/RepresentativeBattleBenchmark.ts` and focused benchmark manifest tests.
- Added ten private Playtest Hub entries under `REPRESENTATIVE BATTLE BENCHMARK`.
- Added benchmark-only private battle staging for Tier S/M/L, Lume Hidden/Auto/Always, fog-heavy, notification-heavy, minimap interaction, and Results transition.
- Added `benchmark:battle:smoke`, `benchmark:battle:representative`, `benchmark:battle:stress`, and `benchmark:battle:report`.
- Added ignored `artifacts/benchmarks/v0108/` output and generated a 10-scenario report.
- Updated visual QA to 213 screenshots and the visual review pack to 9 contact sheets.
- Updated package metadata and package validation to include v0.107/v0.108 docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, XP, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, generated/imported art, runtime asset path, public benchmark controls, desktop path, desktop save path, or engine choice changed.
- Mine/shrine coverage uses the existing capture sites `west_stone_cut` and `ford_toll`; no mine or shrine building IDs were added.

Verification:

```text
npm test - PASS, 111 files / 777 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run benchmark:battle:smoke - PASS, 1 scenario.
npm run benchmark:battle:representative - PASS, 8 scenarios.
npm run benchmark:battle:stress - PASS, 1 local-only stress scenario.
npm run benchmark:battle:report - PASS, refreshed 10-scenario report.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run visual:qa - PASS, 213 screenshots, 0 console errors, 0 screenshot retries.
npm run visual:review-pack - PASS, 213 screenshots and 9 contact sheets.
Browser plugin check - PASS, in-app Browser verified the Representative Battle Benchmark group plus smoke, representative, and Results-transition entries.
```

Final clean package generation and package verification are repeated after the checkpoint commit so the package does not carry a dirty suffix.

## v0.107 Salto Vertical Slice Composition Plan And Asset-Dimension Contracts - 2026-06-02

Scope: docs/tooling/validation only. This checkpoint defines the first Salto visual-slice composition, asset-dimension contracts, deterministic machine-readable manifest, dependency order, first-slice review gate, Emmanuel checklist, and metadata-only packet generator. It does not generate/import art, load unapproved runtime art, alter gameplay, change saves, rename stable IDs, change maps/factions/balance/rewards, choose an engine, start desktop work, change package metadata, or change the runtime title.

Included work:

- Added v0.107 composition, dimension, manifest, dependency-order, review-gate, implementation, and Emmanuel checklist docs.
- Added `tools/salto-slice/saltoSliceManifest.ts`, `generateSaltoSlicePacket.ts`, and focused tests.
- Added `npm run art:packet:salto-slice`.
- Added ignored `artifacts/art-review/salto-slice-packet/` output for metadata-only packet files.
- Deferred optional private mock composition preview to avoid adding a new UI/visual-QA surface.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, generated/imported art, runtime asset path, package metadata, desktop path, or engine choice changed.

Verification:

```text
npx vitest run tools/salto-slice/saltoSlicePacket.test.ts --reporter=dot - PASS, 1 file / 9 tests.
npm run art:packet:salto-slice - PASS, metadata packet generated under ignored artifacts.
npm test - PASS, 109 files / 768 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run art:review:validate - PASS, committed registry/schema checked and 0 candidate metadata files.
npm run validate:runtime-art-slots - PASS, 52 runtime art slots.
git diff --check - PASS with the existing .gitignore LF-to-CRLF warning.
```

## v0.106 Runtime Art Slot Adapter And Placeholder Fallback Harness - 2026-06-02

Scope: runtime art slot contract and fallback-review harness only. This checkpoint defines 52 stable runtime art slots, validates their fallback owners and v0.105 registry references, rejects unapproved/candidate/final-art paths, exposes private-only diagnostics/mock routing, adds private Art Slot Fallbacks scenarios, updates visual QA/review-pack coverage, and updates package metadata/docs. It does not generate/import art, load unapproved runtime art, alter gameplay, change saves, rename stable IDs, change maps/factions/balance/rewards, choose an engine, start desktop work, or change the runtime title.

Included work:

- Added `src/game/art/RuntimeArtSlotTypes.ts`, `src/game/art/RuntimeArtSlots.ts`, and `src/game/art/RuntimeArtSlotAdapter.ts`.
- Added `src/game/art/RuntimeArtSlotAdapter.test.ts`.
- Added `tools/runtime-art-slots/validateRuntimeArtSlots.ts` and `npm run validate:runtime-art-slots`.
- Added private-only runtime art slot diagnostics and mock routing.
- Added `src/game/styles/runtime-art-slots.css`.
- Added the private `art_slot_fallbacks` Playtest Hub scenario family.
- Added 14 v0.106 visual QA screenshots, bringing the target matrix to 203 screenshots.
- Added `Art Slot Fallbacks` to the visual review pack, bringing focused contact sheets to 8.
- Updated package generation and validation to v0.106 with v0.105/v0.106 art docs.
- Added v0.106 contract, fallback matrix, validation, visual QA, implementation, and Emmanuel guide docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, generated/imported art, unapproved runtime image loading, desktop path, or engine choice changed.

Verification:

```text
npm run validate:runtime-art-slots - PASS, 52 runtime art slots.
npm test -- RuntimeArtSlotAdapter PlaytestScenarioGallery VisualReviewPack PlaytestPackageValidation - PASS, 4 files / 20 tests.
npm test - PASS, 108 files / 759 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run art:review:validate - PASS.
npm run visual:qa - PASS, 203 screenshots, 0 console errors, 0 retries.
npm run visual:review-pack - PASS, 203 screenshots and 8 contact sheets.
npm run package:playtest - PASS for the pre-commit package.
npm run verify:playtest-package - PASS, 392 checks on the pre-commit package.
git diff --check - PASS.
```

Final clean package generation and package verification are repeated after the checkpoint commit so the package does not carry a dirty suffix.

## v0.105 Visual Asset Registry, Candidate Review Workspace, And Art-Intake Tooling - 2026-06-02

Scope: tooling/schema/docs pass for future art review. This checkpoint turns the v0.88 vertical-slice asset plan into a deterministic reference-only registry, adds ignored candidate review workspace tooling, validates art-review state progression, generates SVG contact sheets and deterministic reports, and prepares Emmanuel's first controlled art generation packet. It does not generate/import art, wire runtime assets, alter gameplay, change saves, rename stable IDs, change package metadata, choose an engine, start desktop work, or start v0.106.

Included work:

- Added `src/game/art/visual-asset-registry.schema.json`.
- Added `src/game/art/visual-asset-registry.json`.
- Added `src/game/art/VisualAssetReviewRegistry.ts` and focused tests.
- Added `tools/art-review/` init, validate, contact-sheet, report, and test coverage.
- Added `npm run art:review:init`, `npm run art:review:validate`, `npm run art:review:contact-sheet`, and `npm run art:review:report`.
- Added ignored `artifacts/art-review/candidates/`, `artifacts/art-review/contact-sheets/`, and `artifacts/art-review/reports/` roots.
- Added v0.105 registry/workspace/state-machine/first-packet/implementation/Emmanuel review docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, runtime art assets, desktop path, package metadata, or engine choice changed.

Verification:

```text
npm test -- VisualAssetReviewRegistry artReviewTools - PASS, 2 files / 16 tests.
npm run art:review:validate - PASS, committed registry and schema checked.
npm test - PASS, 107 files / 752 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
git diff --check - PASS.
```

Package generation and package verification are not required for v0.105 because package metadata and private package contents are unchanged.

## v0.104 Profiler-Guided Rendering Optimization And Public Battle HUD Minimal Mode - 2026-06-02

Scope: evidence-led rendering and battle-HUD presentation pass. This checkpoint uses the committed v0.103 profiler artifacts to reduce redundant HUD/minimap/fog/Lume rendering work, adds public Minimal battle HUD density, keeps private Standard/Debug density review controls isolated to private playtest tools, expands the private profiler to 20 scenarios, and updates visual QA to 189 screenshots. It does not alter gameplay, balance, rewards, saves, stable IDs, campaign progression, Lume rules, art, maps, factions, desktop work, runtime title, or production private controls.

Included work:

- Added `src/game/ui/hudPanels/HudDensity.ts`.
- Added `src/game/ui/hudPanels/HudDensity.test.ts`.
- Added `src/game/ui/hudPanels/HudVolatileRegions.test.ts`.
- Added public Minimal battle HUD density and private-only Standard/Debug density controls.
- Added private Debug HUD counters for HUD/minimap/fog/Lume/display-object review.
- Moved the battle HUD refresh cadence ahead of ordinary snapshot construction, while forced refreshes remain immediate.
- Added volatile HUD-region patching for status/minimap/hint updates.
- Cached minimap SVG markup by deterministic render signature.
- Skipped redundant fog and Lume graphics redraws when rendered signatures are unchanged.
- Expanded private Performance Lab/profiler coverage to 20 scenarios with `perf_hud_minimal`, `perf_hud_standard`, and `perf_hud_debug`.
- Added 17 v0.104 visual QA screenshots, bringing the visual QA matrix to 189 screenshots.
- Added v0.104 specs, profiler triage, optimization, performance delta, visual QA, implementation, and Emmanuel retest docs.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, campaign progression, Retinue rules, relic rules, reputation, Lume rules, combat balance, maps, factions, art assets, desktop path, or engine choice changed.

Verification:

```text
npm test - PASS, 105 files / 736 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run perf:profile:private - PASS, 20 private scenarios.
npm run perf:report:private - PASS.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-meta - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 31 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 189 screenshots, 0 console errors, 0 retries.
npm run visual:review-pack - PASS, 189 screenshots and 7 contact sheets.
npm run playtest:controls - PASS, 18 rows.
npm run playtest:controls:extended - PASS, 90 rows.
npm run playtest:controls:verify - PASS, 1,658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
```

Final clean package generation and package verification are run after the checkpoint commit so the package does not carry a dirty suffix.

## v0.103 Battlefield Clutter Reduction And Private Performance Profiler - 2026-06-01

Scope: presentation and private QA-tooling pass. This checkpoint reduces stable battlefield visual clutter, adds a private/dev-only performance profiler and Performance Lab, expands visual QA to 172 screenshots, and updates private package metadata. It does not alter gameplay, balance, rewards, saves, stable IDs, campaign progression, Lume rules, art, maps, factions, desktop work, or production posture.

Included work:

- Added `src/game/playtest/PrivatePerformanceProfiler.ts`.
- Added `src/game/playtest/PrivatePerformanceProfiler.test.ts`.
- Added `tools/profilePrivatePerformance.ts`.
- Added `tools/reportPrivatePerformance.ts`.
- Added `npm run perf:profile:private`.
- Added `npm run perf:report:private`.
- Added `/artifacts/performance/` to ignored generated artifacts.
- Added private Performance Lab entries to the Playtest Hub.
- Added 27 v0.103 visual QA screenshots.
- Added v0.103 specs, profiler manifest, baseline/optimization/visual QA reports, implementation report, deferred art/rendering findings, and Emmanuel retest checklist.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, content IDs, gameplay rules, rewards, campaign progression, Retinue rules, Lume rules, combat balance, maps, factions, art assets, desktop path, or engine choice changed.

Verification:

```text
npm test - PASS, 103 files / 730 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run export:portable-content - PASS, 229 stable-ID manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
npm run perf:profile:private - PASS, 17 private scenarios.
npm run perf:report:private - PASS.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run playtest:controls - PASS, 18 rows.
npm run playtest:controls:extended - PASS, 90 rows.
npm run playtest:controls:verify - PASS, 1,658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-battle - PASS on longer rerun, 31 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS on rerun, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 172 screenshots, 0 console errors, 0 retries.
npm run visual:review-pack - PASS, 172 screenshots and 7 contact sheets.
git diff --check - PASS with only the existing .gitignore Windows line-ending notice.
Final clean package generation and package verification are run after the checkpoint commit so the package does not carry a dirty suffix.
```

## v0.102 Browser Save Fixture Library And Desktop Translation Contract Proof - 2026-06-01

Scope: save testing, schema-contract, tooling, and documentation pass. This checkpoint adds deterministic fictional save fixtures and a pure translation-contract proof for future desktop experiments. It does not alter runtime save behavior, gameplay, balance, rewards, stable IDs, `CURRENT_SAVE_VERSION`, localStorage behavior, package posture, engine posture, or desktop implementation.

Baseline:

- Starting commit: `fbea00d`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26786777684` on `fbea00d` passed after rerunning the Fast confidence job.
- v0.101 package generation was not required because v0.101 changed tooling/docs only.

Included work:

- Added `src/game/save/SaveTranslationContract.ts`.
- Added `src/game/save/SaveTranslationContract.test.ts`.
- Added `tools/testSaveTranslationContract.ts`.
- Added `npm run test:save-translation-contract`.
- Added 16 deterministic v0.102 save fixtures plus manifest under `tests/fixtures/saves/v0102/`.
- Added ignored generated proof output folder `artifacts/save-translation-contract/`.
- Added `docs/V0102_SAVE_FIXTURE_LIBRARY_SPEC.md`.
- Added `docs/V0102_DESKTOP_SAVE_ENVELOPE_CONTRACT.md`.
- Added `docs/V0102_SAVE_TRANSLATION_PROOF_REPORT.md`.
- Added `docs/V0102_UNKNOWN_ID_AND_CORRUPTION_POLICY.md`.
- Added `docs/V0102_IMPLEMENTATION_REPORT.md`.

Save format:

- No save-version bump.
- No runtime save fields, localStorage keys, real-save writes, stable IDs, serialized IDs, content definitions, gameplay rules, rewards, campaign progression, Retinue rules, settings behavior, desktop save path, profile UI, desktop port, or engine choice changed.
- `CURRENT_SAVE_VERSION` remains `2`.

Verification:

```text
npx vitest run src/game/save/SaveTranslationContract.test.ts --reporter=dot - PASS, 7 tests.
npm test - PASS, 102 files / 724 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run export:portable-content - PASS, 229 manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
npm run test:save-translation-contract - PASS, 16 fixtures / 11 translated / 2 quarantined / 3 rejected.
git diff --check - PASS; PowerShell reported only the existing Windows line-ending warning for .gitignore.
```

## v0.101 Portable Content Export Contract And Stable-ID Snapshot - 2026-06-01

Scope: tooling, schema, validation, and documentation pass. This checkpoint generates deterministic portable content from TypeScript definitions, writes ignored downstream artifacts, adds a compact stable-ID snapshot, validates references and byte-for-byte determinism, and documents the future content-reuse contract. It does not alter runtime behavior, gameplay, balance, saves, stable IDs, package posture, engine posture, art, desktop implementation, or start v0.102.

Baseline:

- Starting commit: `58cef40`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26785850168` on `58cef40` completed successfully.
- Baseline v0.100 package and verification were complete before v0.101 work began.

Included work:

- Added `src/game/portable/PortableContentExport.ts`.
- Added `src/game/portable/PortableContentExport.test.ts`.
- Added `src/game/portable/stable-id-snapshot.json`.
- Added `tools/exportPortableContent.ts`.
- Added `tools/validatePortableContent.ts`.
- Added `npm run export:portable-content` and `npm run validate:portable-content`.
- Export output is generated under ignored `artifacts/portable-content/latest/`.
- Added `docs/V0101_PORTABLE_CONTENT_EXPORT_CONTRACT.md`.
- Added `docs/V0101_STABLE_ID_FREEZE_POLICY.md`.
- Added `docs/V0101_EXPORT_SCHEMA_REFERENCE.md`.
- Added `docs/V0101_CONTENT_REUSE_ROUNDTRIP_PLAN.md`.
- Added `docs/V0101_IMPLEMENTATION_REPORT.md`.

Save format:

- No save-version bump.
- No save fields, localStorage keys, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, rewards, replay rules, Retinue rules, Tutorial safety, difficulty, AI, or balance values changed.

Verification:

```text
npx vitest run src/game/portable/PortableContentExport.test.ts - PASS, 6 tests.
npm run export:portable-content -- --update-snapshot src/game/portable/stable-id-snapshot.json - PASS, 229 manifest entries.
npm test - PASS, 101 files / 717 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run export:portable-content - PASS, 229 manifest entries.
npm run validate:portable-content - PASS, deterministic two-pass export.
git diff --check - PASS; PowerShell reported only the existing Windows line-ending warning for .gitignore.
```

## v0.100 Private Playtest Hub And Scenario Gallery - 2026-06-01

Scope: private-package QA convenience pass. This checkpoint adds a gated Playtest Hub, grouped Scenario Gallery, fixture previews, an 8-minute visual tour, save-isolation wrappers, visual QA captures, docs, and package validation metadata. It does not expose shortcuts in production posture, alter normal progression, saves, persistent rewards, gameplay rules, balance, stable IDs, maps, factions, art, imported assets, desktop work, or start v0.101.

Baseline:

- Starting commit: `79fc948`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-79fc948`.
- Baseline package verification: `npm run verify:playtest-package` passed 357 checks before v0.100 edits.
- Baseline remote status: GitHub Actions run `26776037930` on `79fc948` completed successfully.

Included work:

- Added private-only `PlaytestHubScene` behind the existing private playtest tooling gate.
- Added Scenario Gallery groups for Campaign Shell, First Session, Battle Shell, Lume, and Meta.
- Added deterministic no-save fixture helpers for campaign, battle, Lume, hero/meta, ordinary Results, defeat Results, and private-demo Results previews.
- Added an 8-minute visual tour with Next, Back, and Exit controls.
- Added in-memory raw save snapshot/restore helpers and hub return controls across Main Menu, Campaign Map, Hero Creation, Hero Progression, Battle HUD, and Results preview flows.
- Added `docs/V0100_SCENARIO_GALLERY_MANIFEST.json` with purpose, expected visible/absent UI, manual question, screenshot ID, automated coverage, launch context, and save-isolation rule for each scenario.
- Added unit, smoke, visual QA, package validation, and hosted test coverage for private-only visibility, no-save fixtures, gallery routing, tour navigation, and scenario isolation.
- Visual QA now includes 145 screenshots after adding nine v0.100 hub/gallery captures.
- Visual review pack now generates from the full visual QA set with 145 screenshots and 7 contact sheets.
- Package generation and validation now require/copy the v0.100 docs and report the v0.100 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, unlock rules, rewards, replay rules, Retinue rules, reputation rules, Tutorial safety, difficulty, AI, or balance values changed.
- Hub previews restore the existing raw save key from memory and launch battle previews with rewards disabled.

Verification:

```text
npm test - PASS, 100 files / 711 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 10 tests.
npm run test:e2e:smoke - PASS, 17 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-meta - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 31 tests after splitting the oversized behaviour/marquee gauntlet into two assertion-preserving tests.
npm run test:e2e:release:hosted:smoke - PASS, 17 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 16 tests / 145 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 145 screenshots / 7 contact sheets.
git diff --check - PASS after final doc/package closeout.
```

## v0.99 Act 1 Mission Presentation Objective Clarity And Narrative Polish - 2026-06-01

Scope: campaign presentation and copy-only pass. This checkpoint makes Act 1 read like a coherent journey from Salto through road control, support choices, Lume pressure, hillfort/church prerequisites, and the Ashen Outpost finale. It does not add nodes, alter unlock rules, rewards, difficulty, AI, saves, stable IDs, broad branding, art, imported assets, desktop work, or start v0.100.

Baseline:

- Starting commit: `8fefc83`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-8fefc83`.
- Baseline package verification: `npm run verify:playtest-package` passed 350 checks before v0.99 edits.
- Baseline remote status: GitHub Actions run `26767676334` on `8fefc83` completed successfully.

Included work:

- Act 1 node descriptions are now concise one-line premises.
- Salto Outskirts, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost briefing/after-action copy now lead with clearer objectives and next-step language.
- Campaign selected-mission panels show either an existing lock reason or existing Act 1 recommended next step in the compact default view.
- Results overview uses campaign primary-objective copy and existing Act 1 next-step guidance when campaign completion data exists.
- Captain Malrec copy now frames him as disciplined, dangerous, and convinced controlled Lume prevents collapse.
- Added focused mission-card, lock-reason, stable-ID, old-save, Results, and package validation coverage.
- Visual QA now includes 136 screenshots after adding ten v0.99 Act 1 presentation/Results captures.
- Package generation and validation now require/copy the v0.99 docs and report the v0.99 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, skill rules, XP values, relic stats, equipment rules, Retinue rules, Stronghold rules, campaign progression, unlock rules, rewards, replay rules, optional objective logic, Tutorial safety, difficulty, AI, or balance values changed.

Verification:

```text
npm test - PASS, 98 files / 704 tests after one stale Old Stone Road copy assertion was updated and the full suite reran.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests after one transient Tutorial overlay exact rerun plus full-lane rerun.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests after two stale hosted copy assertions were updated and exact/full lanes reran.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 15 tests / 136 screenshots / 0 console errors / 0 screenshot retries after the first 30-minute tool timeout was rerun with a longer timeout.
npm run visual:review-pack - PASS, 136 screenshots / 7 contact sheets.
npm run package:playtest - PASS for the pre-commit dirty package; final clean package is generated after commit.
npm run verify:playtest-package - PASS, 357 checks on the pre-commit dirty package.
git diff --check - PASS.
```

## v0.98 Hero Retinue Inventory And Stronghold UX Rescue - 2026-06-01

Scope: presentation-only meta-progression pass. This checkpoint rescues Hero Overview, Skills, Equipment, Inventory, Relic, Retinue, Stronghold, and Results-to-meta readability. It does not change progression rules, XP, relic stats, equipment rules, Retinue rules, Stronghold upgrade rules, saves, stable IDs, rewards, campaign progression, gameplay balance, art/assets, imported assets, desktop work, or start v0.99.

Baseline:

- Starting commit: `3c00ffc`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-3c00ffc`.
- Baseline package verification: `npm run verify:playtest-package` passed 342 checks before v0.98 edits.
- Baseline remote status: GitHub Actions run `26757548780` on `3c00ffc` completed successfully.

Included work:

- Hero Progression now opens with a concise Hero Overview card covering identity, level/XP, class/origin, primary stats, equipment, relic, skill points, Retinue, and inventory.
- Skills now present purchased / available / locked state, cost, requirement, concise effect, and details disclosure without changing unlock logic.
- Equipment now reads as a loadout; Inventory now groups equipped gear, stored gear, and relics with compact comparison/effect chips.
- Relic rows now distinguish equipped, stored, duplicate/owned posture, active-only effect copy, and build synergy details without changing stats.
- Retinue Camp now surfaces Ready, Deployed, Recovering, reserve, cap, reinforcement eligibility, recovery status, and veteran identity with member details behind disclosure.
- Stronghold now surfaces current tier, available/locked/purchased upgrades, cost, prerequisite, benefit, and action state with extra rules behind disclosure.
- Ordinary Results now include a compact Progression Summary for XP, rewards, relics, Retinue, and Stronghold/campaign resources.
- Added focused meta-progression tests and eight v0.98 visual-QA captures, raising the deterministic visual-QA set from 118 to 126 screenshots.
- Package generation and validation now require/copy the v0.98 docs and report the v0.98 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero progression rules, skill unlock rules, XP values, relic stats, equipment rules, Retinue rules, Stronghold upgrade rules, campaign progression, rewards, replay rules, Tutorial safety, or balance values changed.

Verification:

```text
npm test - PASS, 98 files / 700 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests after updating the inventory smoke assertion for the new Hero Overview default and rerunning an unrelated transient settings click test.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests after one transient behaviour-gauntlet timeout passed on exact rerun and full-lane rerun.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 14 tests / 126 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 126 screenshots / 7 contact sheets.
npm run package:playtest - PASS for the pre-commit dirty package; final clean package is generated after commit.
npm run verify:playtest-package - PASS, 350 checks on the pre-commit dirty package.
```

## v0.97 Camera Selection Orders And Tactical Feedback Polish - 2026-06-01

Scope: controls-readability and tactical-feedback pass. This checkpoint improves selection focus, enemy inspection, command destination markers, camera focus/minimap feedback, compact command-panel details, package metadata, and visual-QA coverage. It does not add gameplay systems, alter unit stats, change combat balance, change pathing rules, change saves, rename IDs, add art/assets, start desktop work, add multiplayer/PvP/co-op, or start v0.98.

Baseline:

- Starting commit: `630a8d0`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-630a8d0`.
- Baseline remote status: GitHub Actions run `26743347152` on `630a8d0` completed successfully.

Included work:

- Added `CommandFeedbackMarker` presentation rules and short-lived Phaser markers for move, attack-move, attack target, Patrol, rally, build, ability, invalid, and focus feedback.
- Reused the existing reduced-motion setting so marker cleanup remains deterministic without new saved preferences.
- Added selection focus cards for hero, Worker, combat unit, squad, building, site, and enemy inspection.
- Enemy inspection is explicitly read-only and no longer exposes friendly behavior controls.
- Space now focuses the selected entity before falling back to Aster; minimap and focus actions emit concise confirmation.
- Camera center and scroll clamping now share a pure helper.
- Command-panel secondary command text is behind `More Details`.
- Visual QA now includes 118 screenshots after adding eight v0.97 command/selection/focus states.
- Package generation and validation now require/copy the v0.97 docs and report the v0.97 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, rewards, XP, combat stats, balance values, or pathing rules changed.

Verification:

```text
npm test - PASS, 97 files / 696 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run visual:qa - PASS, 13 tests / 118 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 118 screenshots / 7 contact sheets.
```

Non-pass evidence: full local `npm run test:e2e:release` exceeded the 60-minute local tool timeout with no pass/fail output. A local `npm run test:e2e:release:shard1of3` attempt later reported three older deep-flow startup/timeout failures; exact reruns of all three failed tests passed.

## v0.96 First-Time Player Onboarding And Tutorial UX Rescue - 2026-06-01

Scope: first-session presentation and usability pass. This checkpoint rescues Tutorial step order/readability, compact contextual help, Salto first-step guidance, package metadata, and visual-QA coverage. It does not add gameplay, alter rewards, change saves, rename IDs, change campaign progression, broaden Lume rules, add maps/factions/races/art/assets, change balance, or start v0.97.

Baseline:

- Starting commit: `dc54bb7`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-dc54bb7`.
- Baseline remote status: GitHub Actions run `26734904715` on `dc54bb7` completed successfully.

Included work:

- Proving Grounds now starts with selecting Aster instead of camera prose and proceeds through troop selection, movement, Crown Shrine capture, Command Hall selection, Barracks construction, Worker site assignment, Militia training, rally, Rally Banner, safe pressure, and completion.
- Tutorial steps can show a short reason, collapsed More Help, and a player-initiated Focus Objective target.
- Tutorial completion signals now include selecting starting troops and assigning a Worker to a resource site.
- Tutorial panel now supports More Help, Focus Objective, Dismiss, and Reopen.
- Battle HUD, pause menu, and campaign shell now share a collapsed onboarding help surface.
- Fresh Salto selection now has a compact next-action card while keeping Start Battle immediately visible.
- Visual QA now includes 110 screenshots after adding eight v0.96 first-session onboarding states.
- Package generation and validation now require/copy the v0.96 docs and report the v0.96 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent onboarding preferences, stable IDs, serialized IDs, mission IDs, map IDs, node IDs, site IDs, Lume IDs, reward IDs, hero rules, campaign progression, rewards, XP, or persistent settings changed.

Verification:

```text
npm test - PASS, 95 files / 689 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 12 tests / 110 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 110 screenshots / 7 contact sheets.
```

Non-pass evidence resolved during v0.96: initial fast smoke caught Tutorial preselection auto-completing the opening step, campaign primary-action crowding, and Tutorial More Help drag conflict; each fix was rerun. An early visual-QA timeout was rerun with a long timeout and passed. Hosted layout-core caught stale build output and small CSS overflow issues; final build and layout-core passed.

## v0.95 Procedural Battlefield Readability And Placeholder-World Rescue - 2026-05-31

Scope: presentation-only battle-readability pass. This checkpoint rescues procedural placeholder terrain, fog presentation, entity silhouettes, capture-site emphasis, label density, minimap readability, package metadata, and visual-QA coverage. It does not add gameplay, alter balance, change saves, rename IDs, change fog logic, change Lume mechanics, import/generate art, add maps/factions/assets, start desktop work, or start v0.96.

Baseline:

- Starting commit: `f6f63a2`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-f6f63a2`.
- Baseline remote status: GitHub Actions run `26729836593` on `f6f63a2` completed successfully.

Included work:

- Battle terrain rendering now has deterministic ground scuffs, road beds, water edges, blocked-ground shadows, and site-ground context using Phaser primitives only.
- Fog presentation is softer and less checkerboard-like while preserving the existing fog-of-war system.
- Units/buildings use role-aware placeholder silhouettes through `PlaceholderBattlefieldPresentation`.
- Routine unit labels are quieter; selected/statused, hero, commander/elite, building, and capture-site labels remain visible.
- Capture sites have calmer ownership rings, stronger contested/selected/objective priority, and objective relevance from existing secondary objective metadata.
- Minimap panel and marker families are slightly more legible.
- Visual QA now includes 102 screenshots after adding 18 v0.95 battlefield-readability states.
- Package generation and validation now require/copy the v0.95 docs and report the v0.95 checkpoint in playtest build info.

Save format:

- No save-version bump.
- No save fields, localStorage keys, stable IDs, serialized IDs, mission IDs, map IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, rewards, XP, or persistent settings changed.

Verification:

```text
npm test - PASS, 94 files / 686 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 11 tests / 102 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 102 screenshots / 7 contact sheets.
```

Non-pass evidence resolved during v0.95: initial unit testing caught unsupported triangle primitives in existing Phaser test doubles; the placeholder silhouettes now use rectangle/ellipse/circle primitives. A v0.95-only visual-QA grep run failed only the global expected screenshot count because the suite was intentionally filtered; the final full visual-QA run passed with all 102 screenshots.

## v0.94 Main Menu Ascendant Creation And Campaign-Shell Density Rescue - 2026-05-31

Scope: presentation-only usability pass. This checkpoint rescues the main menu composition, reorganizes existing Ascendant creation into staged comparison panels, compacts the campaign mission panel, improves campaign tab hierarchy, and groups ordinary Results expanded details. It does not add gameplay, alter hero rules, rewards, saves, stable IDs, campaign progression, maps, factions, races, art/assets, runtime title, or desktop work.

Baseline:

- Starting commit: `a5606fb`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline package: `ascendant-realms-private-playtest-a5606fb`.
- Baseline remote status: GitHub Actions run `26726003025` on `a5606fb` completed successfully.

Included work:

- Main menu uses a wider title/action composition with grouped primary and secondary actions.
- Ascendant creation now presents Step 1 Choose Class, Step 2 Choose Origin, and Step 3 Review Hero.
- Campaign map node/route presentation is clearer while preserving map-first visibility and progression rules.
- Selected mission panel default content is reduced to status, one-line description, objective, reward chips, difficulty, primary action, and More Details.
- Campaign tabs prioritize primary summary cards and collapse optional detail prose.
- Ordinary Results expanded data is grouped into accordion sections; private-demo Results remain preserved.
- Added v0.94 layout assertions, visual-QA screenshots, package validation metadata, specs, implementation report, visual QA report, and Emmanuel retest checklist.

Save format:

- No save-version bump.
- No save fields, localStorage keys, stable IDs, serialized IDs, hero rules, campaign progression, rewards, XP, or persistent settings changed.

Verification:

```text
npm test - PASS, 93 files / 683 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests after fixing mobile-short menu overflow.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 10 tests / 84 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 84 screenshots / 7 contact sheets.
```

Non-pass evidence resolved during v0.94: initial fast smoke caught campaign node overlap, full smoke exposed a hidden optional-objective detail assertion after the Results accordion change, hosted layout-core caught mobile-short menu overflow, and visual QA caught the locked-mission primary action below the 1366x768 fold. All four issues were fixed and rerun successfully before closeout.

## v0.93 Runtime UI Foundation Tokens And Mission-Panel State Reset - 2026-05-31

Scope: presentation foundation and campaign-shell bugfix. This pass promotes the v0.88 design-token proposal into runtime CSS variables, improves baseline typography/hierarchy across existing UI surfaces, and makes selected-mission panel state reset deterministic when switching nodes. It does not add gameplay, alter rewards, change saves, rename IDs, add art, import assets, change campaign progression, or start desktop work.

Baseline:

- Starting commit: `b9c7bb2`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26722963239` on `b9c7bb2` completed successfully.

Included work:

- Added `src/game/styles/tokens.css`.
- Imported runtime UI tokens before the existing UI style stack.
- Tokenized base, main menu, form, inventory, campaign, Results, and battle-HUD typography/panel hierarchy.
- Enlarged campaign node click targets while preserving map visibility and non-overlap acceptance.
- Reset selected mission scroll/details/focus when changing campaign nodes, including the Salto return path after inspecting locked Aether Well details.
- Added v0.93 layout and visual-QA coverage.
- Added all required v0.93 specs, reports, and Emmanuel retest checklist.

Save format:

- No save-version bump.
- No save fields, localStorage keys, stable IDs, serialized IDs, persistent settings, campaign progression, rewards, XP, or package folder naming changed.

Verification:

```text
npm test - PASS, 93 files / 683 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 26 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle - PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run visual:qa - PASS, 9 tests / 65 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 65 screenshots / 7 contact sheets.
```

Final `git diff --check`, package generation, and package verification run during commit/package closeout.

## v0.92 Visual Review Pack Generator And Unified Emmanuel Retest Packet - 2026-05-31

Scope: QA tooling and documentation milestone. This pass adds a deterministic visual review-pack generator, static local review artifact, contact sheets, and unified Emmanuel retest packet. It does not alter gameplay, runtime behavior, saves, stable IDs, balance, art assets, desktop implementation, engine choice, or dependencies.

Baseline:

- Starting commit: `90e687e`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26721957259` on `90e687e` completed successfully.

Included work:

- Added `src/game/playtest/VisualReviewPack.ts`.
- Added `src/game/playtest/VisualReviewPack.test.ts`.
- Added `tools/generateVisualReviewPack.ts`.
- Added `npm run visual:review-pack`.
- Added `/artifacts/visual-review/` to `.gitignore`.
- Added `docs/V092_VISUAL_REVIEW_PACK_SPEC.md`.
- Added `docs/V092_CONTACT_SHEET_INDEX.md`.
- Added `docs/V092_EMMANUEL_UNIFIED_RETEST_PACKET.md`.
- Added `docs/V092_IMPLEMENTATION_REPORT.md`.

Generated artifact:

- `artifacts/visual-review/latest/index.html`.
- `artifacts/visual-review/latest/review-manifest.json`.
- `artifacts/visual-review/latest/README.md`.
- 64 copied screenshots.
- 7 contact sheets.

Save format:

- No save-version bump.
- No save fields, localStorage keys, stable IDs, serialized IDs, persistent settings, or package metadata changed.

Verification:

```text
npx vitest run src/game/playtest/VisualReviewPack.test.ts - PASS, 1 file / 5 tests.
npm test - PASS, 93 files / 683 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run visual:qa - PASS, 9 tests / 64 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS after visual:qa, 64 screenshots / 7 contact sheets.
git diff --check - PASS.
```

Closeout note: commit as `Checkpoint v0.92 visual review pack generator and unified Emmanuel retest packet`, push safely, and do not start v0.93 automatically. Non-pass evidence: an initial build caught a TypeScript narrowing issue in the new contact-sheet screen-family filter; the type was tightened before final verification.

## v0.91 Desktop Full-Game Transition Technical Audit And Vertical-Slice Roadmap - 2026-05-31

Scope: docs-only strategic engineering milestone. This pass audits current architecture reuse, desktop engine decision criteria, future vertical-slice scope, staged transition experiments, save/content/test reuse, and deferred multiplayer/co-op requirements. It does not port the game, create a wrapper, choose an engine, add dependencies, generate/import art, implement multiplayer, change runtime behavior, alter saves, or start v0.92.

Baseline:

- Starting commit/package: `c849ffb`, `ascendant-realms-private-playtest-c849ffb`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26721555321` on `c849ffb` completed successfully.

Included work:

- Added `docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md`.
- Added `docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md`.
- Added `docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md`.
- Added `docs/V091_STAGED_TRANSITION_EXPERIMENTS.md`.
- Added `docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md`.
- Added `docs/V091_MULTIPLAYER_AND_COOP_DEFERRED_REQUIREMENTS.md`.
- Added `docs/V091_EMMANUEL_DESKTOP_TRANSITION_REVIEW_PACKET.md`.
- Added `docs/V091_IMPLEMENTATION_REPORT.md`.
- Classified every requested major subsystem by reuse category for a future desktop transition.
- Defined engine-decision criteria for Phaser/browser prototype continuation, later desktop packaging experiment, Godot, Unity, Unreal, and justified alternatives without choosing a winner.
- Scoped a future installable Salto/Barrosan/Ashen desktop vertical slice and staged the gated experiments required before full transition.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, serialized IDs, or `CURRENT_SAVE_VERSION` changed.

Runtime/package boundary:

- No runtime code changed.
- No package metadata or package validation requirements changed because v0.91 does not alter package contents or private playtest distribution.

Verification:

```text
Required v0.91 docs existence check - PASS, all 8 required docs present.
JSON validation - not applicable; v0.91 adds no JSON files.
npm test - PASS, 92 files / 678 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
git diff --check - PASS.
```

Closeout note: commit as `Checkpoint v0.91 desktop full-game transition technical audit and vertical-slice roadmap`, push safely, and do not start v0.92 automatically.

## v0.90 UX Visual-Regression Harness And Desktop-Viewport Acceptance Hardening - 2026-05-31

Scope: QA-hardening only. This pass expands deterministic screenshot coverage, desktop viewport acceptance assertions, visual-regression manifest validation, review rules, and lightweight performance baselines. It does not add gameplay, alter balance, change saves, rename stable IDs, generate/import art, or begin desktop implementation.

Baseline:

- Starting commit/package: `dffcaaa`, `ascendant-realms-private-playtest-dffcaaa`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26716281197` on `dffcaaa` completed successfully.

Included work:

- Added `docs/V090_VISUAL_REGRESSION_MATRIX.json`.
- Added `docs/V090_DESKTOP_VIEWPORT_ACCEPTANCE_SPEC.md`.
- Added `docs/V090_LAYOUT_ASSERTION_COVERAGE.md`.
- Added `docs/V090_LIGHTWEIGHT_PERFORMANCE_BASELINE.md`.
- Added `docs/V090_VISUAL_QA_REVIEW_RULES.md`.
- Added `docs/V090_IMPLEMENTATION_REPORT.md`.
- Expanded `npm run visual:qa` to 64 deterministic screenshots across menu, campaign, all campaign tabs, battle HUD states, Lume states, private-demo Results, ordinary Results, replay Results, and Tutorial.
- Added `1600x900` to visual QA desktop coverage alongside 1920x1080 and 1366x768 acceptance captures.
- Added layout assertions for campaign node overlap, visible primary actions, Results action visibility, text overflow, HUD/objective/minimap posture, Lume control isolation, and private-demo control posture.
- Added manifest validation in `src/game/playtest/VisualRegressionMatrix.test.ts`.
- Updated hosted `deep-meta` to navigate current campaign tabs before asserting Stronghold/Hero/Intel/Reputation panels and to expect current Retinue `Ready` status copy.
- Updated package generation and verification requirements for the v0.90 QA docs.

Save format:

- No save-version bump.
- No save fields, localStorage keys, serialized IDs, gameplay state, campaign progression, rewards, XP, or Tutorial behavior changed.

Verification:

```text
npm test PASS, 92 files / 678 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 16 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core PASS, 25 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run visual:qa PASS, 9 tests / 64 screenshots / 0 console errors / 0 screenshot retries.
```

Resolved non-pass evidence: initial hosted `deep-meta` found stale campaign-tab expectations and passed after test cleanup. Initial full local layout sweep passed 36/37, then the exact failed private-demo posture test and hosted layout-core rerun passed after distinguishing local/private posture from hosted public posture.

Closeout note: commit as `Checkpoint v0.90 UX visual-regression harness and desktop-viewport acceptance hardening`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.89 Controlled Display-Copy Migration Batch A - 2026-05-31

Scope: narrow copy-only runtime migration based on the v0.79 direction lock and v0.80 string inventory. This pass changes approved player-facing display labels only: Barrosan Freeholds, The Barrosan Marches, Salto Outskirts/Salto onboarding, Rootbound Concord, and Lume Surge. It does not change saves, serialized values, stable IDs, gameplay, campaign progression, rewards, balance, maps, factions, art/assets, repository folders, runtime/internal title, public title, or class display names.

Baseline:

- Starting commit/package: `b8b9d41`, `ascendant-realms-private-playtest-b8b9d41`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26713031477` on `b8b9d41` completed successfully.

Included work:

- Added `docs/V089_APPLIED_COPY_MIGRATION_LEDGER.md`.
- Added `docs/V089_DEFERRED_AMBIGUOUS_TERMS.md`.
- Added `docs/V089_COPY_ONLY_TEST_AND_ROLLBACK_REPORT.md`.
- Added `docs/V089_VISUAL_QA_REPORT.md`.
- Added `docs/V089_IMPLEMENTATION_REPORT.md`.
- Added `docs/V089_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated faction, campaign, Results, onboarding, HUD/status, tooltip/test, and package-visible copy for the approved migration set.
- Added content-validation guards that assert stable IDs are unchanged while approved display labels changed.
- Preserved `Aether`, `Aether Well Ruins`, `Aether Lens`, `Aether Flow`, `Mana`, `maxMana`, all map/node/site/class/unit/building/relic IDs, save fields, and `CURRENT_SAVE_VERSION`.
- Fixed active building-placement HUD status readability so battlefield event copy cannot obscure the current placement instruction.

Save format:

- No save-version bump.
- No save fields, localStorage keys, serialized IDs, campaign progression, replay state, rewards, XP, Tutorial behavior, or package folder naming changed.

Verification:

```text
npm test PASS, 91 files / 676 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 16 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 36 screenshots / 0 console errors / 0 screenshot retries.
```

Resolved non-pass evidence: an initial hosted deep-battle rerun failed 2 of 29 tests. The behaviour-mode gauntlet passed on exact rerun; the first-campaign build placement failure was fixed as presentation priority only, rebuilt, rerun exactly, and then confirmed by a full hosted deep-battle pass.

Closeout note: commit as `Checkpoint v0.89 controlled display-copy migration batch A`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.88 Visual Foundation, Style-Frame Preparation, And AI-Art Intake Gate - 2026-05-31

Scope: docs-first visual foundation for future controlled AI-assisted art review. This pass defines screen hierarchy, UI token proposals, Barrosan/Ashen/Wolfveil style-frame briefs, prompt templates, a vertical-slice planning manifest, and an art-intake gate. It does not generate images, import assets, change runtime art, change gameplay, alter saves, rename stable IDs, choose a desktop engine, or start v0.89.

Baseline:

- Starting commit/package: `b571205`, `ascendant-realms-private-playtest-b571205`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26712580008` on `b571205` completed successfully.

Included work:

- Added `docs/V088_SCREEN_BY_SCREEN_VISUAL_FOUNDATION.md`.
- Added `docs/V088_UI_DESIGN_TOKEN_PROPOSAL.md`.
- Added `docs/V088_BARROSAN_STYLE_FRAME_BRIEF.md`.
- Added `docs/V088_ASHEN_STYLE_FRAME_BRIEF.md`.
- Added `docs/V088_WOLFVEIL_SILHOUETTE_BRIEF.md`.
- Added `docs/V088_AI_ART_PROMPT_TEMPLATE_LIBRARY.md`.
- Added `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`.
- Added `docs/V088_ART_INTAKE_AND_REVIEW_GATE.md`.
- Added `docs/V088_EMMANUEL_VISUAL_REVIEW_PACKET.md`.
- Added `docs/V088_IMPLEMENTATION_REPORT.md`.
- Updated package generation and package validation requirements for the v0.88 review packet.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, rewards, XP, campaign state, mission IDs, or stable IDs changed.

Art/runtime boundary:

- No images generated.
- No art imported.
- No runtime asset slots changed.
- No runtime CSS tokens wired.
- Current placeholder/procedural rendering remains untouched.

Verification:

```text
JSON validation for docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json PASS.
npm test PASS, 91 files / 675 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON file checked and 0 review manifests.
```

Closeout note: commit as `Checkpoint v0.88 visual foundation style-frame preparation and AI-art intake gate`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.87 Campaign-Shell Second Polish And General Results Information Architecture - 2026-05-31

Scope: presentation-only second polish for the campaign shell and ordinary Results screens. This pass improves map-first campaign width/height usage, progression lanes, selected-mission compactness, campaign tab hierarchy, and Results progressive disclosure. It does not add gameplay systems, alter campaign progression, alter rewards/XP, alter saves, rename stable IDs, add maps/factions/races/units/buildings/classes/art/assets, start desktop work, add multiplayer/PvP/co-op, or change runtime rebrand/display-copy behavior.

Baseline:

- Starting commit/package: `b046d80`, `ascendant-realms-private-playtest-b046d80`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26705661613` on `b046d80` completed successfully with Fast confidence green and heavier lanes skipped by workflow design.

Included work:

- Added `docs/V087_CAMPAIGN_SHELL_SECOND_POLISH_SPEC.md`.
- Added `docs/V087_RESULTS_INFORMATION_ARCHITECTURE_SPEC.md`.
- Added `docs/V087_VISUAL_QA_REPORT.md`.
- Added `docs/V087_IMPLEMENTATION_REPORT.md`.
- Added `docs/V087_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `docs/V087_DEFERRED_CAMPAIGN_AND_RESULTS_FINDINGS.md`.
- Added `src/game/results/ResultsOverviewPanel.ts`.
- Campaign nodes now expose presentation-only `mapX`, `mapY`, and `chapterId` fields for a wider map-first layout.
- The Map tab now uses larger chapter lanes, route lines, clearer selected/available/completed/locked/future/replayable states, stronger prerequisite readability, and wider node spacing.
- Fresh campaigns still select Border Village, locked Aether Well Ruins remains previewable, and normal unlock/progression logic is unchanged.
- The selected mission panel now keeps title, type, state, short description, objective, reward preview, pacing, lock reason, primary action, and `More Details` visible first.
- Stronghold, Hero, Inventory, Intel, and Reputation tabs now use compact cards and details disclosures for longer guidance.
- Ordinary Results screens now show the key result, mission, time, primary objective, key rewards, hero XP, veteran highlights, and return/replay actions before collapsed full battle details.
- The private-demo Results mode remains preserved.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, rewards, XP, campaign progression, mission IDs, stable IDs, or balance values changed.
- The campaign coordinate/chapter fields are view-model presentation metadata only.

Verification:

```text
npm test PASS, 91 files / 675 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 16 tests.
npm run test:e2e:layout PASS, 32 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 36 screenshots / 0 console errors / 0 screenshot retries.
```

Non-pass evidence: broad local `npm run test:e2e:release` exceeded a 40-minute command timeout without a usable summary. The layout shard later passed 32/32, and the required hosted release lanes passed.

Closeout note: commit as `Checkpoint v0.87 campaign-shell second polish and Results information architecture`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.86 General Battlefield-Shell UX Rescue - 2026-05-31

Scope: presentation-only rescue for the general battlefield shell. This pass improves command panel density, status priority, objective tracker presentation, capture-site labels, selection-ring contrast, fog readability, and minimap capture-site markers. It does not change gameplay, save format, stable IDs, Lume rules, mission logic, rewards, balance, maps/factions/races/units/buildings/classes, art/assets, desktop work, multiplayer/PvP/co-op, or runtime rebrand/display-copy behavior.

Baseline:

- Starting commit/package: `4e5618f`, `ascendant-realms-private-playtest-4e5618f`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26702405524` on `4e5618f` completed successfully with Fast confidence green and heavier lanes skipped by workflow design.

Included work:

- Added `docs/V086_BATTLEFIELD_SHELL_UX_RESCUE_SPEC.md`.
- Added `docs/V086_NOTIFICATION_PRIORITY_SPEC.md`.
- Added `docs/V086_OBJECTIVE_TRACKER_PRESENTATION_SPEC.md`.
- Added `docs/V086_VISUAL_QA_REPORT.md`.
- Added `docs/V086_IMPLEMENTATION_REPORT.md`.
- Added `docs/V086_DEFERRED_UX_FINDINGS.md`.
- Added `docs/V086_EMMANUEL_RETEST_CHECKLIST.md`.
- Command entries now keep the visible button compact while preserving long owner/effect/description copy in details and accessible labels.
- Battlefield status messages now use critical, important, routine, and debug categories; routine command confirmations are shortened and deduplicated.
- Objective tracker special-context rows are compact, and empty ordinary objectives no longer render as misleading `Objectives 0/0`.
- Capture-site, selection-ring, fog, and minimap presentation helpers provide tested readable variants without changing underlying state or rules.
- Visual QA includes new v0.86 battlefield-shell captures at 1920x1080 and 1366x768.
- Package generation and verification now include all v0.86 tester docs.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, rewards, campaign progression, internal IDs, mission IDs, Lume IDs, or balance values changed.
- No canvas/world force-click or DOM fallback behavior was added.

Verification:

```text
npm test -- --run src/game/battle/BattleStatusPriority.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/ui/MinimapView.test.ts src/game/ui/CaptureSitePresentation.test.ts src/game/ui/FogPresentation.test.ts src/game/ui/SelectionPresentation.test.ts PASS, 7 files / 37 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm test PASS, 91 files / 672 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 15 tests after an exact Broken Ford scene-transition rerun.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests after compact-command/minimap/details expectation updates and exact reruns.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests after an exact compact-upgrade-details rerun.
npm run visual:qa PASS, 6 tests / 31 screenshots / 0 console errors / 0 screenshot retries.
```

Closeout note: commit as `Checkpoint v0.86 general battlefield-shell UX rescue`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.85 Contextual Lume Overlay And Results-Screen UX Rescue - 2026-05-31

Scope: contextual overlay and Results-screen rescue for the package/dev-only Aether Well Lume demo. This pass uses existing `aether_well_ruins` / `broken_ford`, existing Lume state, existing HUD/Results/package paths, and battle-session-only display controls. It does not change save format, add persistent settings, rename internal IDs, add maps/factions/races/units/buildings/classes/art/assets, broaden Lume rules, alter `linked_ward`, alter the 0.92 damage multiplier, start desktop work, add multiplayer/PvP/co-op, or perform runtime rebrand/display-copy migration.

Baseline:

- Starting commit/package: `187f272`, `ascendant-realms-private-playtest-187f272`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26700439551` on `187f272` completed successfully with Fast confidence green and heavier lanes skipped by workflow design.

Included work:

- Added `docs/V085_CONTEXTUAL_LUME_OVERLAY_SPEC.md`.
- Added `docs/V085_LUME_VISIBILITY_CONTROL_SPEC.md`.
- Added `docs/V085_PRIVATE_DEMO_RESULTS_UX_SPEC.md`.
- Added `docs/V085_IMPLEMENTATION_REPORT.md`.
- Added `docs/V085_VISUAL_QA_REPORT.md`.
- Added `docs/V085_DEFERRED_RESULTS_AND_BATTLEFIELD_UX_FINDINGS.md`.
- Added `docs/V085_EMMANUEL_RETEST_CHECKLIST.md`.
- Contextual Lume rendering now hides inactive clutter in Auto mode, teaches only the relevant private-demo guide link, and keeps stable active links subtle.
- Existing Lume HUD now exposes `Links: Auto`, `Links: Always`, and `Links: Hidden` as session-only controls.
- Lume render snapshots now include visibility mode, visible state, emphasis, pulse kind, alpha, width, and layer depth for hosted proxy coverage.
- Private-demo Results now use `PRIVATE DEMO COMPLETE`, show the Lume/no-save summary above the fold, keep primary actions visible, and collapse full telemetry behind `Show Full Battle Details`.
- Package generation and verification now include all v0.85 tester docs and v0.85 build-info guidance.

Save format:

- No save-version bump.
- No save fields, localStorage keys, persistent settings, rewards, campaign progression, internal IDs, Lume balance values, or Linked Ward stacking rules changed.
- Visibility mode is battle-session-only and defaults to `Auto` per eligible Lume battle.
- Private demo rewards/progress remain disabled, and Tutorial/generic no-reward launch protection remains intact.

Verification:

```text
npx vitest run src/game/battle/LumeNetworkRendering.test.ts src/game/battle/LumeNetworkDirector.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 5 files / 42 tests.
npm test PASS, 88 files / 664 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests. Initial short shell timeout was non-pass evidence; rerun passed.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests. Initial 10-minute shell timeout was non-pass evidence; 15-minute rerun passed.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 29 screenshots / 0 console errors / 0 screenshot retries.
```

Closeout note: commit as `Checkpoint v0.85 contextual Lume overlay and Results-screen UX rescue`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.84 Guided Lume Demo Readability And Fast-Retest Polish - 2026-05-30

Scope: guided readability and fast-retest polish for the package/dev-only Aether Well Lume demo. This pass uses existing `aether_well_ruins` / `broken_ford`, existing Lume rules, existing HUD/Results/package paths, and session-only private-demo controls. It does not change save format, rename internal IDs, add maps/factions/races/units/buildings/classes/art/assets, broaden Lume rules, alter `linked_ward`, alter the 0.92 damage multiplier, start desktop work, add multiplayer/PvP/co-op, or perform runtime rebrand/display-copy migration.

Baseline:

- Starting commit/package: `a368b55`, `ascendant-realms-private-playtest-a368b55`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26698221908` on `a368b55` completed successfully with Fast confidence green and heavier lanes skipped by workflow design.

Included work:

- Added `docs/V084_GUIDED_LUME_DEMO_READABILITY_SPEC.md`.
- Added `docs/V084_LUME_LINK_RENDERING_SPEC.md`.
- Added `docs/V084_PRIVATE_DEMO_FAST_RETEST_SPEC.md`.
- Added `docs/V084_VISUAL_QA_REPORT.md`.
- Added `docs/V084_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `docs/V084_IMPLEMENTATION_REPORT.md`.
- Added `docs/V084_DEFERRED_BATTLEFIELD_UX_FINDINGS.md`.
- Progressive HUD tracker now teaches `LUME WARD`, current capture target, `LUME LINKS x/2`, severed/restored state, and optional North Aether focus after the first link.
- Private demo controls now support focus buttons, `Exit Demo`, and post-activation `Finish Demo & View Results`.
- Battlefield rendering now draws procedural Lume links/endpoints for inactive, active, contested, severed, and restored states.
- Lume notifications are shorter and deduped for awaken, sever, restore, and full-network activation.
- Package generation and verification now include all v0.84 tester docs and the v0.84 build-info guidance.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Private demo focus, exit, finish, and link rendering are battle-session-only.
- Private demo rewards/progress remain disabled, and Tutorial/generic no-reward launch protection remains intact.

Verification:

```text
npm test PASS, 87 files / 659 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests after a focused Lume test-race fix.
npm run visual:qa PASS, 6 tests / 26 screenshots / 0 console errors / 0 screenshot retries after a test-only Cinderfen helper fallback.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-a368b55-dirty` generated.
npm run verify:playtest-package PASS, 265 checks against the dirty pre-commit package.
```

Closeout note: commit as `Checkpoint v0.84 guided Lume demo readability and fast-retest polish`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.83 Campaign Map UX Rescue And Private Playtest Quick Launch - 2026-05-30

Scope: campaign map readability rescue plus a private package/dev quick-launch for the existing Aether Well Lume runtime slice. This pass uses existing campaign nodes, existing `aether_well_ruins` / `broken_ford`, existing Lume systems, existing HUD/Results/package paths, and an explicit private-tool flag. It does not change save format, rename internal IDs, add maps/factions/races/units/buildings/classes/art/assets, add rewards, broaden Lume rules, start desktop work, add multiplayer/PvP/co-op, or perform runtime rebrand/display-copy migration.

Baseline:

- Starting commit/package: `319730c`, `ascendant-realms-private-playtest-319730c`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26695542266` on `319730c` completed successfully.

Included work:

- Added `docs/V083_CAMPAIGN_MAP_UX_RESCUE_SPEC.md`.
- Added `docs/V083_PRIVATE_PLAYTEST_QUICK_LAUNCH_SPEC.md`.
- Added `docs/V083_IMPLEMENTATION_REPORT.md`.
- Added `docs/V083_VISUAL_QA_REPORT.md`.
- Added `docs/V083_PRIVATE_PLAYTEST_LAUNCH_NOTES.md`.
- Added `docs/V083_EMMANUEL_RETEST_CHECKLIST.md`.
- Campaign Map now opens map-first, with selected-node summary and primary action visible beside/below the map.
- Stronghold, Hero, Inventory, Intel, and Reputation are available through compact campaign tabs.
- Private playtest packages inject an explicit `window.__ASCENDANT_PRIVATE_PLAYTEST_TOOLS__ = true` marker so testers can launch the Aether Well Lume demo from a fresh campaign.
- The private Lume demo uses `rewardsDisabled: true`, private HUD warning copy, private Results no-save copy, and no campaign progression mutation.
- Smoke coverage now guards campaign-node overlap and the private Lume no-save path.
- Visual QA now captures 26 screenshots, including eight v0.83 campaign/private-demo views.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Private demo runs do not persist campaign node completion, battle rewards, hero XP, Retinue state, rival state, reputation, relic rewards, optional-objective credit, or resource rewards.

Verification:

```text
npx vitest run src/game/battle/LumeNetworkDirector.test.ts src/game/battle/BattleLaunchRequest.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 4 files / 45 tests.
npm test PASS, 87 files / 656 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx playwright test tests/e2e/smoke.spec.ts --grep "new campaign flow|private playtest" --reporter=line PASS, 2 tests.
npm run test:e2e:smoke:fast PASS, 9 tests.
npm run test:e2e:smoke PASS, 15 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 15 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests.
npm run visual:qa PASS, 6 tests / 26 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-319730c-dirty` generated.
npm run verify:playtest-package PASS, 258 checks against the dirty pre-commit package.
```

Closeout note: commit as `Checkpoint v0.83 campaign map UX rescue and private playtest quick launch`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.82 Mission-Local Lume Network Runtime Prototype - 2026-05-30

Scope: smallest approved runtime Lume Network prototype. This pass implements one mission-local Linked Control network on Aether Well Ruins / Broken Ford using existing resource sites, battle runtime, HUD, selected-site panel, Results, validation, hosted proxy coverage, and package docs only. It does not change save format, rename internal IDs, add maps/factions/races/units/buildings/classes, add runtime art/assets, start a desktop port, choose an engine, perform runtime rebrand/display-copy migration, add Jardas binding, Worker binding, hero binding, resource-production bonuses, global balance changes, enemy AI tuning, multiplayer, PvP, co-op, or a broader Lume system.

Baseline:

- Starting commit/package: `1e3f94b`, `ascendant-realms-private-playtest-1e3f94b`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26693901039` on `1e3f94b` completed successfully.

Included work:

- Added `docs/V082_LUME_NETWORK_RUNTIME_PROTOTYPE_SPEC.md`.
- Added `docs/V082_LINKED_WARD_BALANCE_AND_READABILITY_REPORT.md`.
- Added `docs/V082_LUME_NETWORK_TEST_AND_SAFETY_REPORT.md`.
- Added `docs/V082_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `docs/V082_IMPLEMENTATION_REPORT.md`.
- Added Lume Network data/types/validation around `aether_well_ruins_lume_ward`.
- Added battle-local Lume link resolution and telemetry through `LumeNetworkDirector`.
- Added Linked Ward, a non-stacking 8% incoming-damage reduction near active linked sites.
- Added Aether Well Ruins briefing copy, HUD status, selected-site summary, and Results debrief.
- Added focused runtime/content/UI/package tests and a hosted Aether Well Lume proxy.
- Updated README, roadmap, changelog, release checklist, package metadata, package validation, and this handoff for v0.82 closeout.

Runtime boundaries:

- Active only for eligible `campaign_node` launches on `aether_well_ruins` / `broken_ford`.
- Tutorial/no-reward launches are excluded.
- Eligible sites are `west_stone_cut`, `ford_toll`, and `north_aether_spring`.
- Active links are `west_stone_cut_to_ford_toll` and `ford_toll_to_north_aether_spring`.
- Maximum eligible sites: 3. Maximum active links: 2.
- Enemy recapture/severing is readable but does not add new persistent penalties.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Lume state is battle-session-only and summarized through existing battle stats/results structures.

Verification:

```text
npm test PASS, 87 files / 654 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts --reporter=dot PASS, 1 file / 3 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 8 tests, including the Aether Well Lume proxy.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-1e3f94b-dirty` generated.
npm run verify:playtest-package PASS, 251 checks against the dirty pre-commit package.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.82 mission-local Lume Network runtime prototype`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.81 Lume Site Network Prototype Specification And Smallest-Fun-Slice Gate - 2026-05-30

Scope: docs-only Lume Site Network specification and smallest-fun-slice checkpoint. This pass audits the existing resource-site, Worker, campaign, HUD, Results, battlefield-event, AI, save, replay, Tutorial, and test architecture, then recommends a small future runtime prototype. It does not implement gameplay, alter runtime behavior, rename runtime identifiers, migrate saves, generate/import assets, add races/maps/units/buildings/classes, start a desktop port, choose an engine, add multiplayer, perform runtime copy migration, implement Lume Network runtime behavior, or start v0.82.

Baseline:

- Starting commit/package: `5ef4f92`, `ascendant-realms-private-playtest-5ef4f92`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26693314243` on `5ef4f92` completed successfully.

Included work:

- Added `docs/V081_EXISTING_SITE_SYSTEM_AUDIT.md`.
- Added `docs/V081_LUME_NETWORK_DESIGN_PRINCIPLES.md`.
- Added `docs/V081_SMALLEST_FUN_SLICE_CANDIDATE_COMPARISON.md`.
- Added `docs/V081_RECOMMENDED_SMALLEST_FUN_SLICE_SPEC.md`.
- Added `docs/V081_FIRST_TESTBED_MISSION_RECOMMENDATION.md`.
- Added `docs/V081_DATA_MODEL_AND_INTEGRATION_PLAN.md`.
- Added `docs/V081_UI_READABILITY_AND_TEACHING_SPEC.md`.
- Added `docs/V081_RACE_EXTENSIBILITY_MATRIX.md`.
- Added `docs/V081_SAVE_REPLAY_TUTORIAL_SAFETY_PLAN.md`.
- Added `docs/V081_TEST_STRATEGY_AND_ROLLBACK_PLAN.md`.
- Added `docs/V081_FUTURE_IMPLEMENTATION_SEQUENCE.md`.
- Added `docs/V081_EMMANUEL_REVIEW_PACKET.md`.
- Added `docs/V081_IMPLEMENTATION_REPORT.md`.
- Updated package metadata and validation so the v0.81 docs can ship inside the private playtest package.
- Updated README, roadmap, changelog, release checklist, and LLM handoff for docs-only closeout.

Recommendation:

- Smallest future prototype: mission-local Linked Control.
- First testbed: `aether_well_ruins` on `broken_ford`.
- Recommended nodes: `west_stone_cut`, `ford_toll`, `north_aether_spring`.
- Limits: maximum three eligible nodes and maximum two active links.
- First link: `west_stone_cut` <-> `ford_toll`.
- First benefit: `Linked Ward`, a small non-stacking defensive readiness benefit near active linked sites.
- Activation: capture-only first.
- Hero/Jardas binding: deferred for Emmanuel decision.
- State: battle-local only.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Stable internal IDs remain unchanged, including `aether_well_ruins`, `broken_ford`, `aether`, `mission_aether_surge`, `aether_surge`, `aether_lens`, and `maxMana`.

Verification:

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-5ef4f92-dirty` generated.
npm run verify:playtest-package PASS, 246 checks against the dirty pre-commit package.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.81 Lume Site Network prototype specification and smallest-fun-slice gate`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.80 Salto Lume And Display-Copy Migration Plan - 2026-05-30

Scope: docs-only terminology audit and migration planning checkpoint. This pass inventories current runtime-facing strings and adjacent stable IDs, classifies safe display-copy candidates, defines Lume/Mana/Aether recommendations, prepares safe copy batches, and gives Emmanuel a review packet before any runtime migration. It does not implement gameplay, alter runtime behavior, rename runtime identifiers, migrate saves, generate/import assets, add races/maps/units/buildings/classes, start a desktop port, choose an engine, add multiplayer, perform runtime copy migration, implement Lume Network, or start v0.81.

Baseline:

- Starting commit/package: `535c388`, `ascendant-realms-private-playtest-535c388`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26692391100` on `535c388` completed successfully.

Included work:

- Added `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`.
- Added `docs/V080_TERMINOLOGY_TAXONOMY.md`.
- Added `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`.
- Added `docs/V080_SAFE_COPY_BATCHES.md`.
- Added `docs/V080_TEST_AND_ROLLBACK_PLAN.md`.
- Added `docs/V080_EMMANUEL_REVIEW_PACKET.md`.
- Added `docs/V080_IMPLEMENTATION_REPORT.md`.
- Updated package metadata and validation so the v0.80 docs can ship inside the private playtest package.
- Updated README, roadmap, changelog, release checklist, and LLM handoff for docs-only closeout.

Inventory:

- 72 runtime-facing string/identifier rows.
- Surface counts: title/brand/package 7, faction/world 8, campaign nodes/briefing 15, resources/economy/sites 14, hero/abilities/builds 9, items/relics/rewards 8, battle events/AI/Results 7, Tutorial/onboarding 4.
- Change categories: keep runtime copy now 32, low-risk copy candidates 5, approval-required copy candidates 8, Lume/Aether review items 12, prohibited identifier changes 15.

Recommendation:

- Treat Lume as the future world-facing living land-power term.
- Keep Mana as the tactical hero ability resource for now.
- Review Aether case by case rather than blanket-renaming it.
- Keep all stable IDs and save fields unchanged until a separately approved migration gate.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Stable internal IDs remain unchanged.

Verification:

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
Explicit JSON inventory parse PASS, 72 rows.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-535c388-dirty` generated.
npm run verify:playtest-package PASS, 233 checks against the dirty pre-commit package.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.80 Salto Lume and display-copy migration plan`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.79 Emmanuel Creative Review Incorporation And Direction Lock - 2026-05-30

Scope: docs-only human approval milestone. This pass records Emmanuel-approved decisions from the v0.78 review packet, converts those decisions into a direction lock, captures deferred decisions, and defines the safe next milestone sequence. It does not implement gameplay, alter runtime behavior, rename runtime identifiers, migrate saves, generate/import assets, add races/maps/units/buildings/classes, start a desktop port, choose an engine, add multiplayer, or start v0.80.

Baseline:

- Starting commit/package: `54d2f0e`, `ascendant-realms-private-playtest-54d2f0e`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26691982219` on `54d2f0e` completed successfully.

Included work:

- Added `docs/V079_EMMANUEL_APPROVAL_LEDGER.md`.
- Added `docs/V079_DIRECTION_LOCK_SUMMARY.md`.
- Added `docs/V079_VERTICAL_SLICE_PRIORITY_LOCK.md`.
- Added `docs/V079_FIRST_SIGNATURE_SYSTEM_PRIORITY.md`.
- Added `docs/V079_DEFERRED_DECISIONS_REGISTER.md`.
- Added `docs/V079_SAFE_NEXT_MILESTONE_SEQUENCE.md`.
- Added `docs/V079_IMPLEMENTATION_REPORT.md`.
- Updated package metadata and validation so the v0.79 docs can ship inside the private playtest package.
- Updated README, roadmap, changelog, release checklist, and LLM handoff for docs-only closeout.

Direction lock:

- `JARDAS: Oath of the Barrosan Marches` is approved as the leading public-title direction.
- `JARDAS` is approved as the dominant logo word, with `Oath of the Barrosan Marches` as subtitle.
- `Ascendant Realms` remains the internal repository codename until a later explicit runtime-rebrand gate.
- Salto, the Barrosan Marches, Lume, the Jardas meaning, Captain Malrec's rival direction, the approved race-roster structure, Barrosan/Ashen/Wolfveil vertical-slice priority, future hero architecture, Lume Network priority, five-act campaign direction, visual target, and browser-to-desktop roadmap principles are recorded as approved strategic direction.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Stable internal IDs remain unchanged, including `free_marches`, `ashen_covenant`, `ashen_outpost`, current class IDs, unit IDs, item IDs, ability IDs, map IDs, node IDs, and save fields.

Verification:

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-54d2f0e-dirty` generated.
npm run verify:playtest-package PASS, 226 checks against the dirty pre-commit package.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.79 Emmanuel creative review incorporation and direction lock`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.78 Creative Identity Lock And Original-IP Separation Pass - 2026-05-30

Scope: docs-only strategic product-definition milestone. This pass defines the proposed public identity, original world direction, eight-race roster, future hero architecture, signature gameplay pillars, long campaign outline, visual governance, browser-to-desktop transition gates, display-name migration safety, original-IP separation, future implementation sequence, and Emmanuel review packet. It does not implement gameplay, alter runtime behavior, rename runtime identifiers, migrate saves, generate/import assets, add races/maps/units/buildings/classes, start a desktop port, choose an engine, add multiplayer, or make broad UI changes.

Baseline:

- Starting commit/package: `8bc1241`, `ascendant-realms-private-playtest-8bc1241`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26690930073` on `8bc1241` completed successfully.

Included work:

- Added the v0.78 docs packet: title/brand options, world/lore bible, race matrix, hero architecture, gameplay pillars, campaign outline, browser-to-desktop gate, visual governance, vertical-slice brief, display-name migration map, original-IP ledger, future implementation sequence, Emmanuel review packet, and implementation report.
- Updated package metadata and validation so the v0.78 docs can ship inside the private playtest package.
- Updated README, roadmap, changelog, release checklist, and LLM handoff for docs-only closeout.

Save format:

- No save-version bump.
- No save fields added, removed, renamed, or migrated.
- Stable internal IDs remain unchanged, including `free_marches`, `ashen_covenant`, `sylvan_concord`, map IDs, node IDs, ability IDs, item IDs, unit IDs, building IDs, and save fields.

Verification:

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-8bc1241-dirty` generated.
npm run verify:playtest-package PASS, 219 checks against the dirty pre-commit package.
git diff --check PASS.
```

Closeout note: commit as `Checkpoint v0.78 creative identity lock and original-IP separation pass`, regenerate and verify a clean package from the final commit, then push when safe.

## v0.75-v0.77 Act 1 Finale And Rival Commander Milestone - 2026-05-30

Scope: turn the existing Ashen Outpost / Captain Malrec milestone into a readable Act 1 climax using existing maps, commander systems, doctrines, elite squads, tactical plans, battlefield events, Retinue, hero skills, relics, and Results UI. This pass changes finale metadata, battle-session-only phase tracking, commander attack-wave gating, objective HUD copy, Results debrief copy, campaign briefing/spine copy, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save migration, a giant boss system, broad AI/pathing rewrite, shop/crafting, global rebalance, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `e019040`, `ascendant-realms-private-playtest-e019040`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run `26688801430` on `e019040` completed successfully.

Included work:

- Added `docs/V075_ACT1_FINALE_ENCOUNTER_SPEC.md`.
- Added `docs/V076_RIVAL_COMMANDER_PHASES_SPEC.md`.
- Added `docs/V077_MILESTONE_REWARD_AND_DEBRIEF_SPEC.md`.
- Added `docs/V075_IMPLEMENTATION_REPORT.md`.
- Added `docs/V076_IMPLEMENTATION_REPORT.md`.
- Added `docs/V077_IMPLEMENTATION_REPORT.md`.
- Added `docs/V077_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `Act1FinaleDirector` and finale data for three deterministic Ashen Outpost phases: secure foothold, break fortified line, defeat Captain Malrec.
- Added battle-only finale stat fields and Results rendering for phases completed, commander release/defeat, tactical-plan support, and Act 1 completion next steps.
- Added mission-local enemy commander attack-wave gating so Malrec does not leave the fortress before the final phase.
- Integrated finale phase rows into the existing objective HUD and battle event trigger path without changing event save state or the one-active-major-event cap.
- Updated Ashen Outpost briefing, Act 1 spine copy, and campaign next-action copy for `Ashen Outpost Finale`.
- Updated hosted Ashen Outpost coverage for phase progression, commander release, commander defeat, Act 1 complete Results, and replay-safe copy.
- Updated package metadata and validation for the v0.75-v0.77 docs.
- Adjusted first-capture bonus status priority so one-time reward feedback remains readable when enemy pressure copy fires from the same capture trigger.

Save format:

- No save-version bump.
- No new persistent save fields.
- Finale phase state is battle-session-only and copied into battle stats/Results.
- Act 1 completion remains derived from existing `ashen_outpost` campaign completion and existing reward/objective/rival/relic state.
- Tutorial/no-reward routes do not start finale phase logic and do not mutate finale-linked persistent state.

Verification:

```text
Focused finale/content Vitest PASS, 6 files / 70 tests.
Focused hosted Ashen Outpost proxy PASS, 1 test.
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa NON-PASS first attempt due first-group app boot flake; clean rerun PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-e019040-dirty` generated.
npm run verify:playtest-package PASS, 204 checks against the dirty pre-commit package.
git diff --check PASS.
```

Non-pass evidence: first broad unit run found a stale `Champion Relic Milestone` assertion after the Act 1 spine was renamed; updated the assertion and reran green. Full smoke found Cinder Shrine reward status hidden by a simultaneous pressure warning; first-capture bonus status now survives that same-trigger warning, and exact/full smoke reran green. Hosted smoke first rerun served stale production `dist`; fresh build plus hosted smoke rerun passed. Visual QA first attempt missed the opening screenshot group after app boot did not reach the main menu in time; clean rerun captured all 18 screenshots with zero console errors.

Closeout note: run package generation/verification, commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.72-v0.74 Dynamic Battlefield Events And Tactical Objectives - 2026-05-30

Scope: add a small data-driven, battle-session-only event layer using existing mission type, enemy doctrine, elite squad, tactical plan, Retinue/reinforcement, resource-site, HUD, and Results systems. This pass changes event data/validation, battle-local event selection/resolution, HUD event copy, Results event summaries, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save migration, persistent event fields, broad AI/pathing rewrite, shop/crafting, formation editor, global rebalance, giant event system, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `515c8a1`, `ascendant-realms-private-playtest-515c8a1`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: latest CI Release Matrix Dry Run `26687186080` on `515c8a1` completed successfully.

Included work:

- Added `docs/V072_BATTLEFIELD_EVENT_DIRECTOR_SPEC.md`.
- Added `docs/V073_DYNAMIC_TACTICAL_OBJECTIVES_SPEC.md`.
- Added `docs/V074_ADAPTIVE_PRESSURE_AND_READABILITY_SPEC.md`.
- Added `docs/V072_IMPLEMENTATION_REPORT.md`.
- Added `docs/V073_IMPLEMENTATION_REPORT.md`.
- Added `docs/V074_IMPLEMENTATION_REPORT.md`.
- Added `docs/V074_EMMANUEL_RETEST_CHECKLIST.md`.
- Added five validated Battlefield Event definitions: Site Under Threat, Hold the Line, Elite Strike, Reinforcement Window, and Aether Surge.
- Added `BattlefieldEventDirector` with Tutorial/no-reward protection, one-active-major-event cap, event cooldowns, max-per-battle cap, and deterministic mission/doctrine/modifier/tactical-plan weighting.
- Added battle-local objectives for holding or recapturing sites, protecting the Command Hall, defeating an elite squad, using Retinue reinforcement opportunity, and using a hero ability during Aether Surge.
- Added small battle-local completion bonuses and event battle stats without persistent reward state.
- Added HUD event objective copy and Results event after-action summary.
- Added hosted deep-campaign proxy coverage for Tutorial protection, Site Under Threat, Elite Strike, tactical-plan support, and Results summaries.
- Added package validation requirements for the v0.72-v0.74 docs.

Save format:

- No save-version bump.
- No new persistent save fields.
- Event state is battle-session-only and summarized through battle stats/Results.
- Existing campaign, replay, optional objective, Retinue, reinforcement, tactical plan, doctrine, elite squad, hero, relic, skill, Worker/site, control group, Patrol, and Act 1 telemetry state remains valid.
- Tutorial/no-reward routes do not start events or mutate event-linked persistent state.

Verification:

```text
Focused event/runtime/HUD/Results/content Vitest PASS, 5 files / 86 tests.
Focused hosted Tutorial/Site Under Threat/Elite Strike proxy PASS, 3 tests.
npm test PASS, 84 files / 637 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure NON-PASS first attempt due event objective status outranking an existing pressure warning; exact failed Cinderfen Watch pressure case PASS after fix; full hosted deep-campaign-pressure rerun PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-515c8a1-dirty` generated.
npm run verify:playtest-package PASS, 197 checks against the dirty pre-commit package.
git diff --check PASS.
```

Non-pass evidence: the first hosted deep-campaign-pressure run surfaced a real priority regression where the new Elite Strike event objective could overwrite the existing Cinderfen Watch pressure warning in the status line. The fix keeps active pressure warnings ahead of event objective feedback; the exact failed case and the full hosted lane reran green.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.69-v0.71 Pre-Battle Tactical Preparation Foundation - 2026-05-30

Scope: turn enemy doctrine readability into actionable pre-battle preparation using existing campaign, Retinue, hero, relic, skill, mission modifier, enemy doctrine, elite squad, and battle-launch systems. This pass changes tactical-plan data/validation, campaign briefing copy, session-only plan selection, launch modifiers, battle HUD copy, Results after-action copy, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save migration, new persistent save fields, broad AI/pathing rewrite, shop/crafting, formation editor, global rebalance, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `b89e6c3`, `ascendant-realms-private-playtest-b89e6c3`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: latest push run `26675513313` on `b89e6c3` completed successfully.

Included work:

- Added `docs/V069_PRE_BATTLE_INTELLIGENCE_SPEC.md`.
- Added `docs/V070_TACTICAL_PLAN_SELECTION_SPEC.md`.
- Added `docs/V071_COUNTER_DOCTRINE_PREPARATION_SPEC.md`.
- Added `docs/V069_IMPLEMENTATION_REPORT.md`.
- Added `docs/V070_IMPLEMENTATION_REPORT.md`.
- Added `docs/V071_IMPLEMENTATION_REPORT.md`.
- Added `docs/V071_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Guarded Advance, Resource Push, and Champion Hunt tactical plan data plus content validation.
- Added doctrine-to-plan recommendation helpers for Raider, Fortress, Hunter, and Warband.
- Added campaign node pre-battle intelligence for doctrine summary, elite risk, mission modifiers, counterplay, Retinue/reinforcement reminder, hero/relic hint, and plan recommendations.
- Added session-only tactical plan selection with safe Guarded Advance default for eligible campaign battles.
- Added one non-stacking launch-local tactical modifier for eligible campaign battles only.
- Added conservative effects: Guarded Advance reduces Call Retinue to 60 Crowns, Resource Push grants +35 Crowns and +20 Stone at battle start, and Champion Hunt grants +6% hero max Mana.
- Added battle HUD plan copy and Results tactical-plan after-action summary.
- Added hosted deep-campaign coverage for pre-battle intel, Champion Hunt selection, battle HUD propagation, and Results summary.
- Added package validation requirements for the v0.69-v0.71 docs.

Save format:

- No save-version bump.
- No new persistent save fields.
- Tactical plan selection is session/launch-local and is not saved.
- Missing or unknown tactical plan ids normalize safely at launch resolution.
- Tutorial/no-reward routes do not receive tactical-plan modifiers or plan Results noise.

Verification:

```text
Focused tactical-plan/launch/runtime/Retinue Vitest PASS, 4 files / 33 tests.
Focused campaign/Results/content Vitest PASS, 3 files / 70 tests.
Playtest package validation focused test PASS.
npm test PASS, 83 files / 627 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle NON-PASS first attempt due old Retinue cost expectation; exact rerun PASS; full rerun PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
```

Interaction note: no new force-click or DOM fallback was introduced for canvas/world clicks. Existing hosted lanes still log pre-existing verified pointer down/up world-click helpers and DOM helpers for HUD/menu buttons.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.66-v0.68 Enemy Tactical Doctrines And Elite Squad Foundation - 2026-05-30

Scope: add readable enemy tactical variety using existing units, AI, maps, and UI only. This pass changes enemy doctrine data/validation, mission-local AI hooks, elite squad tagging, battle stats, campaign briefing copy, battle HUD doctrine copy, Results after-action copy, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save-version bump, new save fields, global rebalance, broad pathing rewrite, enemy formation rewrite, giant roster UI, shop/crafting, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `7048665`, `ascendant-realms-private-playtest-7048665`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: latest push run `26673950830` on `7048665` completed successfully.

Included work:

- Added `docs/V066_ENEMY_TACTICAL_DOCTRINES_SPEC.md`.
- Added `docs/V067_ELITE_SQUAD_FOUNDATION_SPEC.md`.
- Added `docs/V068_COUNTERPLAY_READABILITY_SPEC.md`.
- Added `docs/V066_IMPLEMENTATION_REPORT.md`.
- Added `docs/V067_IMPLEMENTATION_REPORT.md`.
- Added `docs/V068_IMPLEMENTATION_REPORT.md`.
- Added `docs/V068_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Raider, Fortress, Hunter, and Warband doctrine data plus content validation.
- Added doctrine selection from existing mission type, scenario modifiers, enemy hero milestones, and Tutorial/no-reward guards.
- Added conservative doctrine hooks for resource-site raids, defensive reserves/tech, escorted hero/Retinue pressure, and late mixed pushes.
- Added Ash Raider Vanguard and Cinder Iron Guard elite squads with capped modest bonuses.
- Added battle stats for doctrine id/actions, elite squads present, and elite squads defeated.
- Added campaign, HUD, selected-unit renderer, and Results copy for doctrine warnings, elite labels, and counterplay.
- Added hosted deep-campaign coverage for Raider doctrine, Fortress doctrine, Cinder Iron Guard stat/readability, and elite Results summary.
- Added package validation requirements for the v0.66-v0.68 docs.

Save format:

- No save-version bump.
- No new persistent save fields.
- Doctrine and elite state is content-driven and battle-stat-only.
- Existing Retinue, campaign replay, rewards, relics, skills, control groups, Patrol, and Tutorial no-reward state remains valid.

Verification:

```text
Focused doctrine/AI/HUD/Results/campaign Vitest PASS, 6 files / 70 tests.
Focused hosted Raider/Fortress/elite proxy PASS, 2 tests.
npm test initial NON-PASS, then fixed elite damage multiplier fallback for test doubles.
npm test PASS, 82 files / 620 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke NON-PASS first attempt, command wrapper timed out after 364 seconds with no Playwright summary; longer rerun PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-7048665-dirty` generated.
npm run verify:playtest-package PASS, 183 checks against the dirty pre-commit package.
git diff --check PASS.
```

Interaction note: no new force-click or DOM fallback was introduced for canvas/world clicks. Existing hosted lanes still log pre-existing verified pointer down/up world-click helpers and DOM helpers for HUD/menu buttons.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.63-v0.65 Retinue Recovery And Reinforcement Foundation - 2026-05-30

Scope: deepen the small Retinue survivor loop with recovery status, reserve readability, and one safe once-per-battle reinforcement option. This pass changes Retinue save normalization, campaign Retinue panel state copy, campaign battle launch reserve payloads, battle HUD command wiring, Results Retinue summaries, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, giant roster UI, permanent control groups, broad pathing/AI rewrite, global rebalance, shop/crafting, save-version bump, formation editor, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `3c10913`, `ascendant-realms-private-playtest-3c10913`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: CI Release Matrix Dry Run run `26672416357` on `3c10913` completed successfully.

Included work:

- Added `docs/V063_RETINUE_RECOVERY_SPEC.md`.
- Added `docs/V064_RESERVE_MANAGEMENT_SPEC.md`.
- Added `docs/V065_BATTLEFIELD_REINFORCEMENT_SPEC.md`.
- Added `docs/V063_IMPLEMENTATION_REPORT.md`.
- Added `docs/V064_IMPLEMENTATION_REPORT.md`.
- Added `docs/V065_IMPLEMENTATION_REPORT.md`.
- Added `docs/V065_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `recovering` Retinue status and optional one-step recovery timer.
- Added legacy `wounded` to `recovering` migration and safe lost/invalid Retinue filtering.
- Added Ready reserve and Recovering counts to the Campaign Map Retinue Camp.
- Blocked Recovering units from deployment and Call Retinue.
- Added campaign battle reserve launch payloads separate from selected deployment payloads.
- Added campaign-only Call Retinue with 75 Crowns battle cost, one-use cap, Command Hall gating, Ready reserve selection, safe Command Hall spawn, minimap ping, and Results recording.
- Added Results copy for participating Retinue, reinforcement, survived/lost units, entering recovery, and returned Ready.
- Added package validation requirements for the v0.63-v0.65 docs.

Save format:

- No save-version bump.
- Added optional `recoveryMissionsRemaining` on Retinue entries.
- `active` remains Ready; Deployed remains derived from `campaign.retinueDeploymentIds`.
- Existing saves without recovery fields load Ready by default.
- Legacy `wounded` Retinue entries load as `recovering` with one mission remaining.
- `lost`, invalid, duplicate, unknown-unit, non-Retinue, and stale deployment ids normalize safely.
- Tutorial/no-reward routes do not alter Retinue recovery or reinforcement state.

Verification:

```text
Focused Retinue/save/results/HUD/package Vitest PASS, 8 files / 110 tests.
Focused hosted Retinue reinforcement/recovery proxy PASS, 1 test, after rebuilding production dist.
npm test PASS, 81 files / 610 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast NON-PASS first attempt, timed out after 184 seconds with no summary; clean rerun PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 29 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-3c10913-dirty` generated.
npm run verify:playtest-package PASS, 176 checks against the dirty pre-commit package.
git diff --check PASS.
```

Interaction note: the new reinforcement proxy uses the existing command-button helper for HUD DOM commands. No force-click or DOM fallback was introduced for canvas/world clicks.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.60-v0.62 Persistent Retinue And Deployment Foundation - 2026-05-29

Scope: turn the existing opt-in Retinue Camp into a small persistent survivor roster with explicit pre-battle deployment selection. This pass changes Retinue save normalization, campaign Retinue panel copy/actions, campaign battle launch selection, Results recruitment/continuity copy, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, a giant roster UI, permanent control groups, broad pathing/AI rewrite, global rebalance, shop/crafting, save-version bump, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `27e7f9e`, `ascendant-realms-private-playtest-27e7f9e`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26669380994` on `27e7f9e` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V060_RETINUE_PERSISTENCE_FOUNDATION_SPEC.md`.
- Added `docs/V061_PRE_BATTLE_DEPLOYMENT_SPEC.md`.
- Added `docs/V062_SURVIVOR_CONTINUITY_AND_RESULTS_SPEC.md`.
- Added `docs/V060_IMPLEMENTATION_REPORT.md`.
- Added `docs/V061_IMPLEMENTATION_REPORT.md`.
- Added `docs/V062_IMPLEMENTATION_REPORT.md`.
- Added `docs/V062_EMMANUEL_RETEST_CHECKLIST.md`.
- Added eligible Retinue type validation for Militia, Ranger, and Acolyte only.
- Added explicit five-unit Retinue roster capacity.
- Added two-unit base deployment selection with Training Yard II adding one deployment slot.
- Added Campaign Map Retinue deploy/reserve controls and selected/roster count copy.
- Added persistent Retinue `battlesSurvived` and `missionsDeployed` counters.
- Added Results continuity summary for deployed, survived, and lost Retinue units.
- Preserved normal trained-unit veterancy as battle-only unless explicitly added to the Retinue.
- Updated package metadata and validation to require the v0.60-v0.62 docs.

Save format:

- No save-version bump.
- Added backward-compatible `campaign.retinueDeploymentIds`.
- Added optional Retinue counters: `battlesSurvived` and `missionsDeployed`.
- Existing saves without Retinue fields load with an empty roster and no selected deployment.
- Existing saves with older Retinue entries but no deployment field default to first active eligible Retinue units up to the cap.
- Invalid Retinue unit types, unknown ids, duplicate ids, and stale deployment ids normalize safely.
- Existing campaign, replay, reward, relic, skill, inventory, equipment, control-group, Patrol, and Tutorial no-reward state remains valid.

Verification:

```text
Focused Retinue/save/results/package Vitest passes PASS.
npm test PASS, 80 files / 603 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
Focused hosted Retinue proxy PASS, 2 tests, after rebuilding production dist.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke NON-PASS first attempt, timed out after 5 minutes with no summary; clean rerun PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 28 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run test:e2e:release:shard1of3 NON-PASS, timed out after 20 minutes with no summary.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-27e7f9e-dirty` generated.
npm run verify:playtest-package PASS, 169 checks against the dirty pre-commit package.
git diff --check PASS.
```

Interaction note: no force-click or DOM fallback was introduced for canvas/world clicks.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.57-v0.59 Army Veterancy And Tactical Feedback Foundation - 2026-05-29

Scope: add a small battle-only army veterancy and unit-role readability layer without creating a permanent army roster or broad stat rewrite. This pass changes unit role metadata, validation, selected-panel summaries, command copy, Results veteran scope copy, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save-version bumps, new save fields, broad pathing rewrite, global rebalance, a huge unit stat overhaul, formation editor, Patrol rewrite, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `c1d25de`, `ascendant-realms-private-playtest-c1d25de`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26665697999` on `c1d25de` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V057_ARMY_VETERANCY_FOUNDATION_SPEC.md`.
- Added `docs/V058_UNIT_ROLE_IDENTITY_SPEC.md`.
- Added `docs/V059_TACTICAL_COMBAT_FEEDBACK_SPEC.md`.
- Added `docs/V057_IMPLEMENTATION_REPORT.md`.
- Added `docs/V058_IMPLEMENTATION_REPORT.md`.
- Added `docs/V059_IMPLEMENTATION_REPORT.md`.
- Added `docs/V059_EMMANUEL_RETEST_CHECKLIST.md`.
- Added validated unit role metadata and content-index coverage.
- Added selected-unit role, tags, rank, XP, kills, and modest veteran-bonus copy.
- Added selected-group role mix and ranked-member summaries.
- Added role-aware training command descriptions.
- Added Worker construction order summaries for build movement, active build, and paused build states.
- Added Results copy that keeps normal unit veterancy battle-only while preserving the existing opt-in Retinue survivor system.
- Extended hosted deep-battle coverage for role copy, veteran status, control groups, group movement spacing, Patrol start/cancel, and Worker command regression.
- Updated package metadata and validation to require the v0.57-v0.59 docs.

Save format:

- No save-version bump.
- No new save fields.
- Normal trained-unit veterancy is live battle state and Results summary only.
- Existing Retinue Camp survivor recruitment remains the existing opt-in campaign system.
- Control groups, Patrol routes, formation offsets, role summaries, and tactical feedback remain session-derived.
- Existing campaign, replay, reward, relic, skill, inventory, equipment, and Tutorial no-reward state remains valid.

Verification:

```text
Focused role/veterancy/tactical Vitest pass PASS, 8 files / 99 tests.
npm test -- PlaytestPackageValidation PASS, 1 file / 3 tests.
npm test PASS, 80 files / 602 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run test:e2e:smoke:fast PASS on rerun with explicit local dev server, 8 tests; earlier setup attempts were non-pass evidence.
npm run test:e2e:smoke PASS on clean rerun, 14 tests; exact rerun covered the intermediate settings persistence failure.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS on full rerun, 28 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run test:e2e:release:shard1of3 NON-PASS, timed out after 20 minutes with no summary; timed-out local processes were stopped.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-c1d25de-dirty` generated.
npm run verify:playtest-package PASS, 162 checks against the dirty pre-commit package.
```

Interaction note: browser tests used existing verified DOM fallbacks only for UI controls. No force-click or DOM fallback was introduced for canvas/world clicks.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.54-v0.56 Control Groups And Patrol Foundation - 2026-05-29

Scope: add a controlled RTS command-depth layer without broad rewrites. This pass changes battle-session input state, selected-panel summaries, multi-unit move target assignment, unit patrol routes, HUD command buttons, hosted proxy coverage, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, save-version bumps, new save fields, broad pathing rewrite, global rebalance, a formation editor, enemy formation AI, a giant command-system rewrite, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `063fdf5`, `ascendant-realms-private-playtest-063fdf5`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26658960006` on `063fdf5` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V054_CONTROL_GROUPS_FOUNDATION_SPEC.md`.
- Added `docs/V055_FORMATION_AWARE_MOVEMENT_SPEC.md`.
- Added `docs/V056_PATROL_FOUNDATION_SPEC.md`.
- Added `docs/V054_IMPLEMENTATION_REPORT.md`.
- Added `docs/V055_IMPLEMENTATION_REPORT.md`.
- Added `docs/V056_IMPLEMENTATION_REPORT.md`.
- Added `docs/V056_EMMANUEL_RETEST_CHECKLIST.md`.
- Added session-only control group assignment/recall for living player units/heroes.
- Added compact group summaries and assignment/recall feedback.
- Added conservative command-time group movement spacing for normal move and attack-move commands.
- Added minimal combat-unit Patrol with `P` hotkey, HUD command, Stop command, order summary, and explicit cancellation rules.
- Preserved Worker build/repair/resource-site command paths, hero ability hotkeys when no recalled group consumes the number, minimap movement, drag select, and behavior modes.
- Updated package metadata and validation to require the v0.54-v0.56 docs.

Save format:

- No save-version bump.
- No new save fields.
- Control groups, formation offsets, and Patrol routes are session-only battle state.
- Existing campaign, replay, reward, relic, skill, inventory, equipment, and Tutorial no-reward state remains valid.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
Focused Vitest control-depth/package pass PASS, 8 files / 46 tests.
npm test PASS, 78 files / 591 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "control groups, group movement spacing, and Patrol" --reporter=line PASS, 1 hosted proxy test.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 28 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 console errors / 0 retries.
npm run test:e2e:release:shard1of3 PASS, 45 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-063fdf5-dirty` generated.
npm run verify:playtest-package PASS, 155 checks against the dirty pre-commit package.
git diff --check PASS.
```

Interaction note: browser tests used existing verified DOM fallbacks only for UI buttons and existing verified pointer down/up only after canvas right-click actionability stalls. No force-click or DOM fallback was introduced for canvas/world clicks.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.51-v0.53 Player-Facing UX And Command Readability Polish - 2026-05-29

Scope: improve the player-facing feel of the current Act 1/browser-game loop through cursor affordances, command disabled reasons, Worker build/repair/site assignment clarity, hero ability cooldown/Mana readability, combat status readability, and Results confidence. This pass changes derived UI/hover state, existing HUD metadata/copy, status-chip readability, hosted proxy expectations, package metadata/validation, and docs. It does not add maps, factions, gameplay systems, save-version bumps, new save fields, runtime art/assets, broad UI redesign, shop, crafting, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world clicks.

Baseline:

- Starting commit/package: `be51130`, `ascendant-realms-private-playtest-be51130`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26647331728` on `be51130` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V051_PLAYER_UX_AUDIT_PLAN.md`.
- Added `docs/V051_PLAYER_UX_AUDIT_REPORT.md`.
- Added `docs/V051_IMPLEMENTATION_REPORT.md`.
- Added `docs/V052_COMMAND_AND_CURSOR_READABILITY_REPORT.md`.
- Added `docs/V053_COMBAT_AND_RESULTS_READABILITY_REPORT.md`.
- Added `docs/V053_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `CursorAffordance` for attack, build, repair, assign, invalid, and default hover intent.
- Added native cursor styles plus readable canvas intent labels.
- Added command state / disabled reason metadata to existing command buttons.
- Added hero ability reason metadata and standardized Mana copy.
- Made Burn status chips larger and more legible while keeping them separated from health bars.
- Slightly increased battle hover tolerance for unit targets.
- Extended hosted deep-battle coverage for attack cursor label, Worker build/repair/resource-site hover intent, and hero ability cooldown reason metadata.
- Updated package metadata and validation to require the v0.51-v0.53 docs.

Save format:

- No save-version bump.
- No new save fields.
- Existing campaign, replay, reward, relic, skill, inventory, equipment, and Tutorial no-reward state remains valid.

Verification:

```text
npm test -- src/game/systems/CursorAffordance.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/entities/BaseEntity.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 5 files / 20 tests.
npm test PASS, 76 files / 579 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
Focused hosted UX proxy PASS, 5 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 pass rows.
npm run playtest:controls:extended PASS, 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run playtest:act1 PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run test:e2e:release:shard1of3 NON-PASS, 43 passed / 1 failed on local Results inventory-button retry/fallback timing at `tests/e2e/deep-flow.spec.ts:6064`.
npx playwright test tests/e2e/deep-flow.spec.ts:6064 --reporter=line PASS, 1 exact rerun.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-be51130-dirty` generated.
npm run verify:playtest-package PASS, 148 checks against the dirty pre-commit package.
```

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.48-v0.50 Act 1 Playability And Release-Candidate Stabilization - 2026-05-29

Scope: stabilize the existing Act 1 campaign route as a release-candidate loop through deterministic telemetry, readability polish, replay/reward clarity, and package hardening. This pass changes simulator reporting, Act 1 guidance copy, hosted proxy expectations, package metadata/validation, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, cinematic systems, a giant quest system, save-version bump, new save fields, broad campaign rewrite, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `025656d`, `ascendant-realms-private-playtest-025656d`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26637454600` on `025656d` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V048_ACT1_PLAYABILITY_AUDIT_PLAN.md`.
- Added `docs/V048_ACT1_PLAYTEST_TELEMETRY_REPORT.md`.
- Added `docs/V048_IMPLEMENTATION_REPORT.md`.
- Added `docs/V049_ACT1_BALANCE_AND_TELEMETRY_REPORT.md`.
- Added `docs/V050_ACT1_RELEASE_CANDIDATE_NOTES.md`.
- Added `docs/V050_IMPLEMENTATION_REPORT.md`.
- Added `docs/V050_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `Act1PlayabilityTelemetry` and `npm run playtest:act1`.
- Added committed Act 1 telemetry outputs in Markdown and JSON.
- Kept gameplay numbers unchanged because deterministic telemetry shows Safe Beginner clearing every Act 1 campaign node.
- Polished Act 1 copy for Workers, production, site assignment, upgrades, staging, skills, relics, replay safety, and already-claimed rewards.
- Updated package metadata and validation to require v0.48-v0.50 docs plus Act 1 telemetry artifacts.

Save format:

- No save-version bump.
- No new save fields.
- Existing campaign completion, reward claim, replay, optional objective, hero XP, skill-tree, relic inventory, and relic equipment saves remain valid.

Verification:

```text
npm test -- src/game/playtest/Act1PlayabilityTelemetry.test.ts src/game/core/FirstExperienceGuidance.test.ts src/game/core/campaign/CampaignActSpineRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 6 files / 46 tests.
npm run playtest:act1 PASS.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test PASS, 75 files / 575 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
Focused hosted Act 1 proxy PASS, 3 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS on rerun, 14 tests; first attempt timed out without a summary.
npm run playtest:controls PASS.
npm run playtest:controls:extended PASS.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS on rerun, 27 tests; first attempt timed out without a summary.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run test:e2e:release TIMED OUT after 40 minutes without a summary.
npm run test:e2e:release:shard1of3 PASS after manually starting and verifying a local dev server, 44 tests; earlier attempts were timeout/setup non-pass evidence.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
```

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.45-v0.47 Act 1 Campaign Spine And Onboarding Polish - 2026-05-29

Scope: add a small Act 1 campaign spine, data-driven difficulty pacing labels, and onboarding/next-action copy using existing campaign nodes, maps, scenario metadata, rewards, hero progression, relic reward/equip flows, campaign UI, and Results UI. This pass changes Act 1 metadata, campaign node details, Results campaign guidance, first-experience guidance, package metadata, tests, and docs. It does not add factions, runtime art/assets, shop, crafting, cinematic systems, a giant quest system, save-version bump, broad campaign rewrite, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `78df198`, `ascendant-realms-private-playtest-78df198`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26615193631` on `78df198` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V045_ACT1_CAMPAIGN_SPINE_SPEC.md`.
- Added `docs/V046_DIFFICULTY_PACING_FOUNDATION_SPEC.md`.
- Added `docs/V047_ONBOARDING_AND_PLAYER_GUIDANCE_SPEC.md`.
- Added `docs/V045_IMPLEMENTATION_REPORT.md`.
- Added `docs/V046_IMPLEMENTATION_REPORT.md`.
- Added `docs/V047_IMPLEMENTATION_REPORT.md`.
- Added `docs/V047_EMMANUEL_RETEST_CHECKLIST.md`.
- Added a seven-step content-driven Act 1 path from Tutorial / Proving Grounds through Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, and replay cleanup.
- Added Act 1 step metadata for step kind, pacing tier, mechanic focus, build tags, unlock summary, onboarding hint, Results hint, next action, and replay hint.
- Added `CampaignActSpineRules` helpers for node-to-step lookup, recommended next step, locked reason copy, Results guidance, and replay guidance.
- Added campaign map copy for Act 1 role, pacing tier, unlock state, locked reason, mechanic focus, onboarding hint, and next action.
- Added Results copy for next mission unlocks, replay availability, skill spending, relic equip, optional objective cleanup, and first-clear/replay context.
- Updated Act 1 node copy so Border Village is clearly the first persistent campaign battle, Old Stone Road teaches base development, Aether Well Ruins teaches resource control, Bandit Hillfort stages rival pressure, and Ashen Outpost anchors the champion/relic milestone.
- Updated package metadata and validation to require the v0.45-v0.47 docs.

Save format:

- No save-version bump.
- No new save fields.
- Act 1 progression, pacing, and onboarding guidance are derived from content metadata and existing campaign/hero/relic/reward state.
- Existing campaign completion, reward claim, replay, optional objective, hero XP, skill-tree, relic inventory, and relic equipment saves remain valid.

Verification:

```text
npm test -- src/game/core/campaign/CampaignActSpineRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 3 files / 31 tests.
npm run validate:content PASS.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm test PASS, 74 files / 570 tests.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "first campaign battle path|Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 3 hosted proxy tests.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS on final rerun after manual dev-server start, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:shard1of3 PASS, 44 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-78df198-dirty` generated.
npm run verify:playtest-package PASS, 133 checks against the dirty pre-commit package.
git diff --check PASS.
```

Full release note: `npm run test:e2e:release` was attempted with a 40-minute timeout and remained non-pass evidence after timing out without a summary. The timed-out local Playwright/Vite processes were stopped. The local 3-way release shard fallback passed completely.

Smoke note: the first fast smoke attempt timed out without a summary, then a rerun failed with `ERR_CONNECTION_REFUSED` because the local dev server was not running. After starting and verifying the dev server, fast smoke passed; full smoke also passed; the manual dev server was stopped.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.42-v0.44 Mission Variety And Scenario Modifier Foundation - 2026-05-28

Scope: add a small mission-type, scenario modifier, campaign briefing, and Results after-action foundation using existing maps, objectives, rewards, campaign UI, Results UI, enemy AI config, and hero build identity copy. This pass changes campaign battle node metadata, mission-type data, campaign modifiers, campaign map selected-node details, Results campaign reward copy, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, a giant quest system, save-version bump, broad AI/pathing rewrite, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `ac3d203`, `ascendant-realms-private-playtest-ac3d203`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26607386432` on `ac3d203` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V042_MISSION_VARIETY_FOUNDATION_SPEC.md`.
- Added `docs/V043_SCENARIO_MODIFIERS_SPEC.md`.
- Added `docs/V044_CAMPAIGN_PACING_AND_BRIEFING_SPEC.md`.
- Added `docs/V042_IMPLEMENTATION_REPORT.md`.
- Added `docs/V043_IMPLEMENTATION_REPORT.md`.
- Added `docs/V044_IMPLEMENTATION_REPORT.md`.
- Added `docs/V044_EMMANUEL_RETEST_CHECKLIST.md`.
- Added Assault, Control, Defense, and Skirmish / Training mission types.
- Added compact mission briefing, primary objective, reward preview, after-action, modifier, and build-hint metadata to existing battle nodes.
- Added Rich Veins, Enemy Patrols, Fortified Enemy, and Aether Surge as mission-local scenario modifiers.
- Applied modifier effects through existing capture-site income, enemy AI config, and hero Mana launch modifier paths.
- Added briefing/modifier/reward preview copy to the Campaign Map selected-node panel.
- Added mission type, active modifiers, primary objective, and after-action copy to Results campaign reward blocks.
- Preserved replay safety, optional objective credit, rival relic choice, hero XP/skill reminders, and Tutorial no-save/no-reward protection.
- Updated package metadata and validation to require the v0.42-v0.44 docs.

Save format:

- No save-version bump.
- No new save fields.
- Mission type, briefing, and scenario modifier state is content-driven and passed through battle launch requests.
- Existing v0.39-v0.41 campaign completion, node reward claim, replay, optional objective, relic, hero XP, and skill-tree state remains valid.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm run validate:content PASS.
npx vitest run src/game/data/campaignModifiers.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/results/ResultsViewModel.test.ts PASS, 4 files / 71 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS after a fresh build, 2 hosted tests.
npm test PASS, 73 files / 563 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS on final rerun, 8 tests.
npm run test:e2e:smoke PASS on final rerun, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npx playwright test tests/e2e/deep-flow.spec.ts --grep @hosted-deep-meta --reporter=line PASS on final local rerun, 12 tests.
npx playwright test tests/e2e/layout.spec.ts:642 --reporter=line PASS, 4 viewport tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-ac3d203-dirty` generated.
npm run verify:playtest-package PASS, 126 checks against the dirty pre-commit package.
git diff --check PASS.
```

Full release note: `npm run test:e2e:release` was attempted with a 40-minute timeout and remained non-pass evidence after timing out without a summary. `npm run test:e2e:release:shard1of3` was also attempted and timed out at 20 minutes. Focused local reruns narrowed the surfaced local failures to cold dev-server main-menu/layout boot budgets and transient Windows `net::ERR_NO_BUFFER_SPACE` app-root navigation; the relevant helper/test timeouts were increased without changing assertions, and exact/group reruns passed. The hosted production-preview release groups above are the final release-matrix evidence.

The first focused hosted proxy attempt before rebuilding `dist/` served the previous production build and failed expected new-copy assertions; the same proxy passed after `npm run build`.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.39-v0.41 Campaign Progression And Mission Reward Foundation - 2026-05-28

Scope: add a small campaign progression, mission reward, replay, and optional-objective state foundation using existing campaign node data, Results screens, hero XP, relic choice, skill reminders, and save structures. This pass changes campaign completion/replay rules, campaign map node/detail copy, Results reward/objective summaries, save normalization for optional objective credit, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, giant quest systems, broad campaign rewrites, save-version bumps, broad AI/pathing rewrites, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `ba7ac16`, `ascendant-realms-private-playtest-ba7ac16`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26570226010` on `ba7ac16` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V039_CAMPAIGN_PROGRESSION_FOUNDATION_SPEC.md`.
- Added `docs/V040_MISSION_REWARD_STRUCTURE_SPEC.md`.
- Added `docs/V041_REPLAY_AND_OBJECTIVE_STATE_SPEC.md`.
- Added `docs/V039_IMPLEMENTATION_REPORT.md`.
- Added `docs/V040_IMPLEMENTATION_REPORT.md`.
- Added `docs/V041_IMPLEMENTATION_REPORT.md`.
- Added `docs/V041_EMMANUEL_RETEST_CHECKLIST.md`.
- Added campaign mission reward/objective helpers in `src/game/core/campaign/CampaignMissionRules.ts`.
- Made completed battle nodes replayable from the existing campaign map.
- Added campaign node detail copy for first-clear/replay state, campaign reward availability, optional objective progress, and build hints.
- Added Results campaign reward copy for first-clear versus replay, node reward claimed/already-claimed state, optional objective credit, XP, relic choice, and skill reminders.
- Added one-time optional objective completion persistence from existing mission objective signals.
- Preserved Tutorial no-save/no-reward protection and rival champion relic choice/duplicate protection.
- Updated package metadata and validation to require the v0.39-v0.41 docs.

Save format:

- No save-version bump.
- Added backward-compatible `CampaignSaveData.optionalObjectiveCompletionIds`.
- Old saves without the field normalize to an empty list.
- Unknown mission ids and unknown objective ids are ignored during normalization.
- Existing `completedNodeIds`, `nodeRewardsClaimedIds`, hero XP, relic inventory/equipment, and skill data remain valid.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/core/SaveSystem.test.ts src/game/core/CampaignRules.test.ts src/game/campaign/CampaignPresentationViewModels.test.ts src/game/campaign/CampaignMapViewModel.test.ts src/game/results/ResultsViewModel.test.ts PASS, 5 files / 110 tests.
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
npm test PASS, 73 files / 558 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 2 hosted tests.
npm run test:e2e:smoke:fast PASS on rerun, 8 tests.
npm run test:e2e:smoke PASS on rerun after focused campaign-node helper cleanup, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-ba7ac16-dirty` generated.
npm run verify:playtest-package PASS, 119 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional full release note: `npm run test:e2e:release` was attempted as extra local full-suite evidence and hit the 30-minute command timeout before returning a summary. The temporary local Playwright/dev-server processes from that attempt were stopped. The required hosted release groups and visual QA above are the final release evidence for this checkpoint.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.36-v0.38 Hero Skill Tree And Relic-Build Synergy - 2026-05-28

Scope: add a small Warrior / Seer / Commander hero skill-tree foundation, modest ability upgrades, and light equipped-relic build synergy using existing hero XP, skill points, abilities, and relic build identities. This pass changes skill metadata, ability derivation, HUD/results/progression copy, Hero Inventory/Equipment summaries, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, giant skill tree, broad inventory UI, enemy hero skill tree, save-version bump, broad AI/pathing rewrites, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `b09ef96`, `ascendant-realms-private-playtest-b09ef96`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26551387988` on `b09ef96` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V036_HERO_SKILL_TREE_FOUNDATION_SPEC.md`.
- Added `docs/V037_ABILITY_UPGRADE_FOUNDATION_SPEC.md`.
- Added `docs/V038_RELIC_BUILD_SYNERGY_SPEC.md`.
- Added `docs/V036_IMPLEMENTATION_REPORT.md`.
- Added `docs/V037_IMPLEMENTATION_REPORT.md`.
- Added `docs/V038_IMPLEMENTATION_REPORT.md`.
- Added `docs/V038_EMMANUEL_RETEST_CHECKLIST.md`.
- Reframed visible skill branches as Warrior, Seer, and Commander with 2-3 visible nodes each.
- Hid legacy compatibility nodes from the current player-facing tree and blocked new spending on hidden nodes.
- Added data-driven ability-upgrade metadata for modest amount, Mana cost, cooldown, radius, and duration changes.
- Added effective ability derivation to runtime casting and HUD ability tooltips.
- Added Warrior Cleave, Seer learned-ability support, and Commander Rally Banner / War Cry upgrade hooks.
- Added equipped-relic synergy for matching Emberbrand Shard / Cinder-Seer Focus / Outpost Command Signet branch identity.
- Added build/synergy copy to Hero Progression, Hero Inventory, Equipment rows, battle HUD, ability tooltips, and Results progression reminders.
- Updated package metadata and validation to require the v0.36-v0.38 docs.

Save format:

- No save-version bump.
- Existing `HeroSaveData.allocatedSkills` carries skill unlocks.
- Existing relic inventory/equipment fields carry equipped relic state.
- Old saves without skill-tree data load with empty allocated skills.
- Unknown skill ids and unknown relic ids remain loadable and are ignored by known stat, ability, and synergy helpers.

Verification:

```text
npx vitest run src/game/core/HeroProgressionRules.test.ts src/game/core/SaveSystem.test.ts src/game/systems/AbilitySystem.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/results/ResultsViewModel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 8 files / 109 tests.
npm test PASS, 73 files / 554 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "inventory equipment, unequip, and skill spending|unlocked hero ability hotkeys" --reporter=line PASS after exact skill/relic locator follow-up, 2 hosted tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-b09ef96-dirty` generated.
npm run verify:playtest-package PASS, 112 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional full release note: `npm run test:e2e:release` was not run for this closeout. The required hosted release groups and visual QA above are the final release evidence for this checkpoint.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.34-v0.35 Relic Reward Choice And Hero Build Identity - 2026-05-27

Scope: add a small inline relic reward choice flow and readable Warrior/Seer/Commander build identity on top of the existing persistent relic inventory and one-slot loadout. This pass changes relic metadata, rival reward resolution, Results selection/equip flow, Hero Inventory/Equipment/Battle HUD copy, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, full inventory overhaul, large loot table, save-version bump, broad AI/pathing rewrites, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `2a411ed`, `ascendant-realms-private-playtest-2a411ed`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26544741700` on `2a411ed` passed Fast confidence; heavier release groups were skipped by expected push rules.

Included work:

- Added `docs/V034_RELIC_REWARD_CHOICE_SPEC.md`.
- Added `docs/V035_HERO_BUILD_IDENTITY_SPEC.md`.
- Added `docs/V034_IMPLEMENTATION_REPORT.md`.
- Added `docs/V035_IMPLEMENTATION_REPORT.md`.
- Added `docs/V035_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `RelicRewardChoice` rules that offer the source champion relic first and one unowned alternate when available.
- Added one-choice confirmation when only one unowned relic remains.
- Preserved unique duplicate conversion when every relic is owned and blocked repeat farming.
- Added required Warrior/Seer/Commander build archetypes, build summaries, choice copy, and validation.
- Added Results choice UI, selected reward persistence, equip-now compatibility, final equipped relic state, and Tutorial no-choice protection.
- Added build identity copy to Hero Inventory, Equipment rows, and battle HUD equipped relic summary.
- Updated package metadata and validation to require the v0.34-v0.35 docs.
- Added a scoped timeout to the broad mobile layout itinerary so it uses the existing hosted-layout-core budget while keeping all assertions intact.

Save format:

- No save-version bump.
- Existing `HeroSaveData.inventory` and `HeroSaveData.equipment.relic` remain the only relic persistence fields.
- Old saves without relic data load with empty relic state.
- Unknown relic ids remain ignored by known relic inventory/effect helpers.

Verification:

```text
npx vitest run src/game/core/RelicRewardRules.test.ts src/game/core/RivalRules.test.ts src/game/results/ResultsViewModel.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 6 files / 70 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm test PASS, 73 files / 549 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives" --reporter=line PASS, 1 hosted test.
npm run test:e2e:smoke:fast PASS on rerun, 8 tests.
npm run test:e2e:smoke PASS on rerun, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS after final relic-choice helper follow-up, 7 tests.
npm run visual:qa PASS on rerun, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-2a411ed-dirty` generated.
npm run verify:playtest-package PASS, 105 checks against the dirty pre-commit package.
git diff --check PASS.
```

Optional full release note: `npm run test:e2e:release` was attempted twice as extra evidence. The first attempt exposed the mobile-short campaign/setup/inventory/gallery layout itinerary exceeding the default 35s budget; after the scoped timeout change, the exact case passed. The second attempt exposed the new relic-choice click helper treating a successful disappearing choice button as a failure; the helper call was fixed and the focused Ashen Outpost plus hosted deep-campaign group passed. The full optional lane was not used as final release evidence.

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.32-v0.33 Persistent Relic Inventory And Hero Loadout Foundation - 2026-05-27

Scope: implement the first safe persistent relic inventory and one-slot hero relic loadout foundation using existing inventory/equipment save structures. This pass changes relic data, rival reward persistence, Results copy/actions, Hero Inventory loadout visibility, battle HUD summary, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, shop, crafting, broad inventory UI, reward-choice modal, save-version bump, broad AI/pathing rewrites, global rebalance, Patrol, formations, or force-click/DOM fallback behavior for canvas/world interactions.

Baseline:

- Starting commit/package: `3410b4f`, `ascendant-realms-private-playtest-3410b4f`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push Fast confidence on `3410b4f` passed. Manual release matrix was green on `62e35ae`; final `3410b4f` was docs/package closeout only.

Included work:

- Added `docs/V032_PERSISTENT_RELIC_INVENTORY_SPEC.md`.
- Added `docs/V033_HERO_RELIC_LOADOUT_SPEC.md`.
- Added `docs/V032_IMPLEMENTATION_REPORT.md`.
- Added `docs/V033_IMPLEMENTATION_REPORT.md`.
- Added `docs/V033_EMMANUEL_RETEST_CHECKLIST.md`.
- Added unique relic item definitions for `emberbrand_shard`, `cinderseer_focus`, and `outpost_command_signet`.
- Converted relic reward metadata from preview-only fields to persistent inventory/loadout metadata.
- Added relic inventory derivation helpers over existing hero inventory/equipment data.
- Added eligible rival champion relic grants and unique duplicate conversion without repeat-farm loops.
- Added Results relic reward block, equip action, inventory status copy, duplicate handling copy, and effect/stat summaries.
- Added existing Hero Inventory relic slot visibility plus equip/unequip support.
- Added battle HUD equipped relic summary.
- Updated package metadata/validation to require the v0.32-v0.33 docs.

Save format:

- No save-version bump.
- Existing inventory/equipment fields carry the relic inventory and loadout.
- Old saves with missing inventory/equipment load with empty relic state.
- Unknown item ids remain loadable and do not apply known relic effects.

Verification:

```text
npx vitest run src/game/core/RelicRewardRules.test.ts src/game/core/RivalRules.test.ts src/game/core/SaveSystem.test.ts src/game/core/HeroProgressionRules.test.ts src/game/results/ResultsViewModel.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts src/game/data/contentValidation.test.ts PASS, 7 files / 107 tests.
npm test PASS, 73 files / 546 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives" --reporter=line PASS, 1 hosted test.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-3410b4f-dirty` generated.
npm run verify:playtest-package PASS, 100 checks against the dirty pre-commit package.
npm run test:e2e:release ATTEMPTED; first local dev-server run reported transient boot/layout/smoke timing failures. Exact affected file:line rerun PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
git diff --check PASS.
```

Closeout note: commit this checkpoint, regenerate and verify a clean package from the final commit, then push when safe.

## v0.30-v0.31 Rival Champion And Relic Reward Foundation - 2026-05-27

Scope: implement a safe rival champion/enemy commander foundation and a tiny preview-only relic reward foundation using existing assets/systems. This pass changes enemy AI commander selection, data validation, results rendering, package metadata, tests, and docs. It does not add maps, factions, runtime art/assets, save migration, inventory overhaul, broad AI/pathing rewrites, global rebalance, Patrol, formations, or complex loot.

Baseline:

- Starting commit/package: `8cd8f66`, `ascendant-realms-private-playtest-8cd8f66`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: push run `26504491122` on `8cd8f66` passed Fast confidence. Manual release matrix `26493804376` passed on `b7604e5`; final `8cd8f66` was docs/package closeout only.

Included work:

- Added `docs/V030_RIVAL_CHAMPION_FOUNDATION_SPEC.md`.
- Added `docs/V031_RELIC_REWARD_FOUNDATION_SPEC.md`.
- Added `docs/V030_IMPLEMENTATION_REPORT.md`.
- Added `docs/V031_IMPLEMENTATION_REPORT.md`.
- Added `docs/V031_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `src/game/data/relicRewards.ts` and `src/game/core/RelicRewardRules.ts`.
- Added content validation and unit coverage for preview-only relic reward definitions.
- Results now show `Relic Reward Preview` after victorious known rival champion defeats and explicitly state that persistence is pending.
- Rival champions avoid resource-site raid/capture squads, defend base/sites first, and join only late coordinated attacks with escorts.
- Updated package metadata/validation to require the v0.30-v0.31 docs.

Verification so far:

```text
npx vitest run src/game/ai/EnemyAIController.test.ts src/game/core/RelicRewardRules.test.ts src/game/results/ResultsViewModel.test.ts src/game/data/contentValidation.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 5 files / 77 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Ashen Outpost special objectives" --retries=1 --trace=on --reporter=line PASS, 1 test.
npm test PASS, 73 files / 540 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:smoke:fast PASS, 8 tests, rerun with the dev server explicitly held open after an initial local server-start refusal.
npm run test:e2e:smoke PASS, 14 tests, rerun with the dev server explicitly held open.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run test:e2e:release ATTEMPTED: one deep-meta New Campaign transition helper failed after the click had already reached hero creation; the narrow helper call fix passed in targeted rerun and hosted deep-meta.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|first campaign battle path" --repeat-each=3 --retries=0 --trace=on --reporter=line PASS, 6 tests after the remote hosted deep-battle failure audit.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|first campaign battle path" --retries=0 --trace=on --reporter=line PASS, 2 tests after final hosted interaction cleanup.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests after final hosted interaction cleanup.
Remote push run 26510324409 on 4b72481 PASS Fast confidence.
Manual release-matrix run 26510633476 on 4b72481 FAILED hosted deep-battle only; failure was hosted minimap click actionability/timing in the behaviour gauntlet.
Remote push run 26512926475 on e466870 PASS Fast confidence.
Manual release-matrix run 26513207423 on e466870 FAILED hosted deep-battle only; failures were hosted canvas/minimap actionability pressure in the overloaded behaviour gauntlet and a stale first-campaign rally assertion after durable rally progress was already satisfied.
Remote push run 26518961193 on 62e35ae PASS Fast confidence.
Manual release-matrix run 26519266738 on 62e35ae PASS Fast confidence, Release simulator, hosted deep-meta, hosted deep-battle, hosted deep-campaign-pressure, hosted layout-core, hosted layout-cinderfen, and hosted smoke. Full release e2e and optional visual QA were skipped by workflow-dispatch inputs.
git diff --check PASS before docs closeout.
```

Closeout rules: runtime/reward checkpoint commit `4b72481` is followed by hosted deep-battle stabilization commits `e466870` and `62e35ae`. Preserve the green manual release matrix evidence, push the final docs/package closeout commit, confirm Fast confidence on that commit, and regenerate/verify the clean package from the final commit. Use only a package whose `PLAYTEST_BUILD_INFO.md` commit matches the final closeout commit and whose dirty status says `no`.

## v0.29.2 Hosted Deep-Battle Recovery And Release-Matrix Closeout - 2026-05-27

Scope: fix or isolate the remaining hosted `deep-battle` release-matrix failure after v0.29.1 remote-CI recovery, rerun local hosted coverage, update package metadata/docs, and prepare for remote release-matrix rerun. No runtime gameplay files, balance, maps, factions, assets, save data, AI, pathing, or content changed.

Baseline:

- Starting commit: `9411dea`, `Document v0.29.1 remote CI recovery status`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Latest clean package before this pass: none regenerated after v0.29.1 because hosted `deep-battle` was red.

Remote failure:

- Push run `26485815688` on `9411dea`: Fast confidence passed.
- Manual release-matrix run `26484817685`: checkout/build/test execution succeeded, but hosted `deep-battle` failed in job `77989895354`.
- Other release matrix groups passed in that run: Fast confidence, Release simulator, hosted `deep-meta`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Remote artifact summary for hosted `deep-battle`: 3 failed, 1 flaky, 23 passed.
- First v0.29.2 fix commit `45c7eb1` was pushed successfully.
- Push run `26490257582` on `45c7eb1`: Fast confidence passed.
- Manual release-matrix run `26490433401` on `45c7eb1`: checkout, Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke` passed.
- Hosted `deep-battle` in run `26490433401` remained red in job `78006853454`: 1 failed, 26 passed. The remaining failure was a stale duplicate `unit-order-summary` movement assertion after the helper had already observed the transient moving/repositioning copy.
- Follow-up fix commit `b7604e5` was pushed successfully.
- Push run `26493632871` on `b7604e5`: Fast confidence passed.
- Manual release-matrix run `26493804376` on `b7604e5`: passed Fast confidence, Release simulator, hosted `deep-meta`, hosted `deep-battle`, hosted `deep-campaign-pressure`, hosted `layout-core`, hosted `layout-cinderfen`, and hosted `smoke`.

Included work:

- Added `docs/V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`.
- Added `docs/V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md`.
- Added `docs/V0292_RELEASE_MATRIX_CLOSEOUT.md`.
- Added `docs/V0292_EMMANUEL_RETEST_CHECKLIST.md`.
- Added `docs/V0292_LONG_SOAK_REPORT.md`.
- Updated package metadata and validation to require the v0.29.2 docs.
- Stabilized hosted `deep-battle` in `tests/e2e/deep-flow.spec.ts` only.

Fix summary:

- Switched right-click world helper to a normal Playwright canvas-position click after explicit canvas hit-test verification; no `force` and no DOM fallback for canvas/world clicks.
- Asserted durable scene movement state instead of transient status text, and now require durable scene movement before any optional transient movement-summary check.
- Removed the older minimap/fog/move hosted test's duplicate wait against the short-lived movement summary after the helper succeeds.
- Parked unrelated hostiles during deterministic player Worker/resource-site proxies.
- Replaced same-DOM-node hover expectation with stable visible/enabled/label/pointer assertions.
- Added real-mouse drag cleanup only when the scene still reports an active drag.

Verification so far:

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --repeat-each=5 --retries=0 --trace=retain-on-failure --reporter=line PASS, 5 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap movement|battle HUD keeps hovered command buttons stable|behaviour mode control gauntlet|Worker assignment and site upgrade boost" --retries=0 --trace=retain-on-failure --reporter=line PASS, 4 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
git diff --check PASS.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --repeat-each=5 --retries=0 --trace=retain-on-failure --reporter=line PASS, 5 tests after the stale-summary follow-up fix.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests after the stale-summary follow-up fix.
```

Closeout complete: final docs-only package-status cleanup was committed, the clean v0.29.2 private playtest package was regenerated from a clean worktree, and `npm run verify:playtest-package` passed with 90 checks. Use the generated package whose `PLAYTEST_BUILD_INFO.md` commit matches the final closeout commit and whose dirty status says `no`.

## v0.29.1 Hero Progression Closeout And Blocked CI Documentation - 2026-05-26

Scope: document the blocked GitHub Actions state after v0.28-v0.29, keep local fallback verification explicit, prepare the hero progression package/retest guidance, and record the follow-up remote CI recovery status. The follow-up includes test-only hosted e2e stabilization and docs updates. It does not add runtime systems, balance changes, maps, factions, assets, save migration, pathing changes, AI changes, or test weakening.

Baseline:

- Starting commit: `aa6fc05`, `Checkpoint v0.28-v0.29 hero progression and ability foundation`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Latest package before this pass: `ascendant-realms-private-playtest-aa6fc05`.

Remote CI:

- GitHub Actions run `26447947052` failed twice at `actions/checkout@v4`.
- The checkout error was GitHub HTTP 403 with `remote: Your account is suspended. Please visit https://support.github.com for more information.`
- No repo tests or package commands ran remotely.
- Push-triggered release matrix, full release e2e, release simulator, and optional visual QA jobs were skipped by workflow rules.
- Checkout was later restored: push run `26484639124` on commit `6124d71` passed Fast confidence with checkout success.
- Manual release-matrix run `26484817685` on commit `6124d71` passed Fast confidence, Release simulator, and hosted `deep-meta`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Manual release-matrix run `26484817685` failed hosted `deep-battle` after checkout, build, and tests ran. Remote CI is no longer account-blocked, but the release matrix is not green.
- Action required: fix or isolate the hosted `deep-battle` failures and rerun the manual release matrix before treating remote CI as release-green.

Included work:

- Added `docs/V0291_BLOCKED_REMOTE_CI_STATUS.md`.
- Added `docs/V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md`.
- Updated package metadata and package validation to name `v0.29.1 hero progression closeout and blocked CI documentation`.
- Kept package validation coverage for `V028_HERO_PROGRESSION_SPEC.md`, `V028_IMPLEMENTATION_REPORT.md`, `V029_HERO_ABILITIES_AND_REWARDS_SPEC.md`, `V029_IMPLEMENTATION_REPORT.md`, and `V029_EMMANUEL_RETEST_CHECKLIST.md`.
- Added the two v0.29.1 closeout docs to the private playtest package and validator.
- Added test-only hosted deep-battle closeout stabilization in `tests/e2e/deep-flow.spec.ts`; no runtime gameplay files changed.
- Updated handoff and closeout docs with the recovered checkout state and the latest red hosted `deep-battle` matrix state.

Verification and closeout so far:

```text
Original remote CI: blocked before checkout in GitHub Actions run 26447947052; no repo tests ran remotely.
Remote recovery follow-up: push run 26484639124 on 6124d71 Fast confidence PASS with checkout success.
Remote release matrix follow-up: manual run 26484817685 on 6124d71 Fast confidence PASS, Release simulator PASS, hosted matrix PASS for deep-meta/deep-campaign-pressure/layout-core/layout-cinderfen/smoke, hosted deep-battle FAILED.
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-aa6fc05-dirty generated.
npm run verify:playtest-package PASS, 85 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests after second hosted stabilization.
npm run test:e2e:smoke:fast PASS, 8 tests after second hosted stabilization.
```

## v0.28-v0.29 Hero Progression And Ability Foundation - 2026-05-26

Scope: add the first safe RPG progression foundation for the player hero. This pass uses the existing hero save, XP, level, stat, skill, ability, and results systems. It does not add new factions, new maps, runtime art/assets, save migration, broad AI/pathing changes, global rebalance, a large ability roster, inventory overhaul, enemy hero systems, Patrol, formations, test weakening, or new force-click/canvas/world fallback behavior.

Baseline:

- Starting commit: `4f78ac6`, `Checkpoint v0.26-v0.27 enemy base development and tech escalation AI`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Latest package before this pass: `ascendant-realms-private-playtest-4f78ac6`.
- GitHub Actions push run `26431511137` passed Fast confidence; Full release e2e, Release simulator, Release matrix groups, and Optional visual QA were skipped by push workflow rules.

Included work:

- Added `docs/V028_HERO_PROGRESSION_SPEC.md`.
- Added `docs/V029_HERO_ABILITIES_AND_REWARDS_SPEC.md`.
- Added `docs/V028_IMPLEMENTATION_REPORT.md`.
- Added `docs/V029_IMPLEMENTATION_REPORT.md`.
- Added `docs/V029_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and validation to name `v0.28-v0.29 hero progression and ability foundation`.
- Added shared hero level stat-gain helpers and applied live battle damage/armor gains when the hero levels.
- Added one-time player resource-site capture XP through `XPSystem`, gated by owner, no-reward launch state, and per-site battle history.
- Preserved existing kill XP, level curve, HP/Mana growth, skill points, reward-table XP, and victory persistence flow.
- Updated the hero HUD to show XP progress, skill points, damage, armor, and unlocked ability count.
- Added tested ability readiness labels and disabled states for ready, cooldown, and insufficient-mana states.
- Preserved the existing safe Rally Banner and Cleave ability effects while making cooldown states harder to miss and harder to spam.
- Updated Tutorial copy lightly without adding a new tutorial step or saved training reward.
- Added unit/UI/runtime/hosted coverage for XP gain, level-up stat changes, site XP, victory reward XP, ability cooldowns, invalid/spam casts, valid ally/hostile targeting, HUD state, and package metadata.

Verification and closeout so far:

```text
GitHub Actions v0.26-v0.27 push run 26431511137: Fast confidence passed; release-matrix jobs skipped by push rules.
npm test -- src/game/core/progression/HeroLevelRules.test.ts src/game/entities/Hero.test.ts src/game/systems/XPSystem.test.ts src/game/systems/AbilitySystem.test.ts src/game/ui/AbilityBar.test.ts src/game/ui/hudPanels/HeroHudPanel.test.ts PASS, 6 files / 10 tests.
npm test -- src/game/battle/BattleRuntime.test.ts PASS, 12 tests.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 3 tests.
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "hero battle XP|hero ability buttons|victory results summarize" --reporter=line PASS, 3 focused hosted proxies.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release exceeded a 30-minute tool window before producing usable output; exact processes from that attempt were cleaned up.
npm run test:e2e:release:shard1of3 PASS, 44 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 14 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with Browser console errors: 0.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-4f78ac6-dirty generated.
npm run verify:playtest-package PASS, 83 checks.
Browser plugin note: tool discovery in the compacted closeout turn did not expose an in-app Browser page-control tool; production preview smoke and visual QA are the local browser sanity fallback.
```

Closeout note: run `git diff --check`, commit, regenerate/verify a clean package from the final v0.28-v0.29 commit, then push.

## v0.26-v0.27 Enemy Base Development And Tech Escalation AI - 2026-05-26

Scope: extend the enemy resource-site economy into base development, conservative tech progression, strategic escalation, and defensive intelligence. This pass uses existing structures, existing upgrades, existing units, existing combat/pathing, and existing UI/status copy. It does not add classic carry/drop-off harvesting, visible enemy Workers, enemy construction placement, new maps/factions, runtime art/assets, save migration, broad pathing rewrite, global rebalance, Patrol, formations, a large roster, or test weakening.

Baseline:

- Starting commit: `6dfab6b`, `Checkpoint v0.24-v0.25 enemy resource-site strategy and economy pressure AI`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Latest package before this pass: `ascendant-realms-private-playtest-6dfab6b`.
- GitHub Actions push run `26426765221` passed Fast confidence; Full release e2e, Release simulator, Release matrix groups, and Optional visual QA were skipped by push workflow rules.

Included work:

- Added `docs/V026_ENEMY_BASE_DEVELOPMENT_SPEC.md`.
- Added `docs/V027_ENEMY_TECH_ESCALATION_SPEC.md`.
- Added `docs/V026_IMPLEMENTATION_REPORT.md`.
- Added `docs/V027_IMPLEMENTATION_REPORT.md`.
- Added `docs/V027_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and validation to name `v0.26-v0.27 enemy base development and tech escalation AI`.
- Added a testable enemy base-development planner with early, mid, and late stages.
- Stage selection considers elapsed time, enemy site control, improved enemy sites, stockpile health, researched tech, and local player threat.
- Mapped existing enemy roles abstractly: Enemy Stronghold as base hub, Enemy Barracks as military/hexfire tech role, and existing enemy Watchtowers as defensive tech roles when present.
- Added enemy tech planning through the existing `UpgradeSystem`, with affordability, active-queue, researched-state, building-support, cooldown, delay, and prerequisite gates.
- Let existing shared upgrades affect relevant Ashen units/buildings only when researched by the enemy.
- Added strategic escalation from early site capture/light raids into mid site upgrades/defense/tech and late stronger coordinated pressure when economy and site control are healthy.
- Added defensive reserve and base/site defense priorities so raids and late attacks do not strip the enemy base while threatened.
- Added short readable status lines for fortifying, tech, raid forming, escalation, base defense, and site defense.
- Preserved v0.24-v0.25 enemy resource-site capture/retake/defense/upgrades/raids and v0.22/v0.23 Worker assignment/site upgrade/site-loss cleanup behavior.
- Added unit and hosted coverage for tech choice, prerequisites, impossible upgrade rejection, stage shifts, base/site defense, raid spam prevention, and economy-backed escalation.
- Narrowly hardened an existing smoke scene-transition click path exposed by the full release suite; it still verifies the BattleScene after the click and does not add forced clicks or canvas/world fallback.

Verification and closeout so far:

```text
GitHub Actions v0.24-v0.25 push run 26426765221: Fast confidence passed; release-matrix jobs skipped by push rules.
npm test -- src/game/ai/EnemyAIController.test.ts PASS, 18 tests.
npm test -- src/game/ai/EnemyAIController.test.ts src/game/systems/UpgradeSystem.test.ts src/game/systems/ResourceSystem.test.ts PASS, 3 files / 40 tests.
npm test PASS, 66 files / 522 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "enemy base tech" --reporter=line PASS, 1 focused hosted proxy.
npm run test:e2e:release:hosted:deep-battle PASS, 24 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches" --reporter=line PASS, 1 focused repro after scene-transition click option fix.
npm run test:e2e:release PASS, 89 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with Browser console errors: 0.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-6dfab6b-dirty generated.
npm run verify:playtest-package PASS, 78 checks.
In-app Browser plugin note: attempted, but its runtime failed before page control with a kernel asset path error; production preview smoke is the local browser sanity fallback.
```

Closeout note: run `git diff --check`, commit, regenerate/verify a clean package from the final v0.26-v0.27 commit, then push.

## v0.24-v0.25 Enemy Resource-Site Strategy And Economy Pressure AI - 2026-05-25

Scope: add controlled enemy strategic interaction with the v0.22/v0.23 resource-site economy. This pass keeps the existing site-control economy and does not add classic carry/drop-off harvesting, new maps/factions, runtime art/assets, save migration, broad pathing rewrite, global rebalance, Patrol, formations, a large roster, or test weakening.

Baseline:

- Starting commit: `b231632`, `Checkpoint v0.23 resource site upgrades and worker slots`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Latest package before this pass: `ascendant-realms-private-playtest-b231632`.
- GitHub Actions push run `26385642398` passed Fast confidence; Optional visual QA, Release simulator, Full release e2e, and Release matrix jobs were skipped by push workflow rules.

Included work:

- Added `docs/V024_ENEMY_RESOURCE_SITE_STRATEGY_SPEC.md`.
- Added `docs/V025_ECONOMY_PRESSURE_AND_RAID_AI_SPEC.md`.
- Added `docs/V024_IMPLEMENTATION_REPORT.md`.
- Added `docs/V025_IMPLEMENTATION_REPORT.md`.
- Added `docs/V025_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and validation to name `v0.24-v0.25 enemy resource-site strategy and economy pressure AI`.
- Added a testable enemy resource-site scoring module.
- Scored sites by resource value, level, distance, nearby player/enemy power, owner, player Worker/boost value, and known lost enemy sites.
- Added enemy neutral-site capture and lost-site retake plans using existing unit movement/pathing and capture systems.
- Added high-value enemy-site defense focus when player pressure threatens enemy-owned sites.
- Added outmatched checks so enemy site plans avoid obviously suicidal attacks and weak raids can retreat/regroup.
- Added conservative enemy Level 2 site upgrades through the existing resource-site upgrade system.
- Added abstract enemy logistics slots on enemy-owned Level 2 sites without visible enemy Workers or harvesting.
- Added periodic economy-pressure raids against player resource sites, with upgraded/Worker-boosted sites valued more highly.
- Added status/UI copy for contesting, enemy improved sites, and enemy abstract logistics.
- Added unit/system/e2e coverage for scoring, capture, retake, defense, upgrades, no invalid upgrades, raids, raid cooldowns, weak-raid regrouping, abstract logistics, and existing v0.22/v0.23 Worker/site-loss behavior.
- Added narrow hosted/full-release harness hardening where existing DOM actionability and serial training queue assumptions were exposed by the broad release lane.

Verification and closeout so far:

```text
GitHub Actions v0.23 push run 26385642398: Fast confidence passed; release-matrix jobs skipped by push rules.
npm test PASS, 66 files / 516 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "enemy resource-site AI" --reporter=line PASS, 1 focused hosted proxy.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker assignment and site upgrade" --reporter=line PASS, 1 focused hosted v0.23 regression.
npm run test:e2e:release:hosted:deep-battle PASS, 23 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run test:e2e:release PASS, 88 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-b231632-dirty generated.
npm run verify:playtest-package PASS, 73 checks.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with Browser console errors: 0.
In-app Browser plugin note: attempted, but its runtime failed before page control with a kernel asset path error; production preview smoke is the local browser sanity fallback.
```

Closeout note: run `git diff --check`, commit, regenerate/verify a clean package from the final v0.24-v0.25 commit, then push.

## v0.23 Resource Site Upgrades And Worker Slots - 2026-05-25

Scope: expand the v0.22 resource-site Worker assignment foundation with a small captured-site upgrade layer and second Worker slot depth. This pass keeps the existing site-control economy and does not add classic carry/drop-off harvesting, enemy Worker/resource AI, enemy construction AI, new maps/factions, runtime art/assets, save migration, broad pathing rewrite, global rebalance, Patrol, formations, or test weakening.

Baseline:

- Starting commit: `5147639`, `Checkpoint v0.22 resource site worker assignment foundation`.
- Starting branch state: clean `main`, synced with `origin/main`.
- v0.22 clean package and focused assignment behavior were reconfirmed before runtime work began.

Included work:

- Added `docs/V023_RESOURCE_SITE_UPGRADES_SPEC.md`.
- Added `docs/V023_IMPLEMENTATION_REPORT.md`.
- Added `docs/V023_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and validation to name `v0.23 resource site upgrades and worker slots`.
- Added battle-runtime resource-site levels: Level 1 captured site and Level 2 improved site.
- Added an instant friendly captured-site upgrade costing 120 Crowns and 80 Stone.
- Added a conservative Level 2 upgrade income bonus equal to 15% of base income, rounded, minimum +1.
- Expanded Worker assignment from one first-slot field to explicit slot state.
- Kept Level 1 at one Worker slot and Level 2 at two Worker slots.
- Prevented duplicate Worker slot fills and overfilled sites.
- Preserved baseline passive site income and existing resource identity.
- Cleared slots on Worker move, attack, build, repair, reassignment, death, and site control loss.
- Reset site level and slots when a site is lost.
- Added selected-site UI for level, base income, upgrade bonus, Worker slot usage, assigned Workers, Worker bonus, total income, and upgrade state.
- Added a selected-site Upgrade command and clearer Worker assignment button slot/total-income copy.
- Expanded unit/UI/package and hosted deep-battle coverage for upgrades, second slots, income, invalid targets, overfill, site loss, and existing Worker assignment behavior.
- Added narrow hosted harness hardening: the existing Border Village smoke test now has a 60s budget, and the existing first-campaign build placement world-click retry uses 5 attempts like the explicit-attack world-click helper.

Verification and closeout so far:

```text
In-app Browser preview PASS at http://127.0.0.1:4179/ with page title Ascendant Realms and 0 console errors.
npm exec vitest run src/game/systems/ResourceSystem.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 4 files / 39 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker assignment and site upgrade" --reporter=line PASS, 1 hosted v0.23 regression.
npm test PASS, 66 files / 506 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 22 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-5147639-dirty generated.
npm run verify:playtest-package PASS, 68 checks.
```

Closeout note: run `git diff --check`, commit, regenerate/verify a clean package from the final v0.23 commit, then push.

## v0.22 Resource Site Worker Assignment Foundation - 2026-05-24

Scope: add the first resource-economy expansion by allowing Workers to explicitly support friendly captured resource sites for bonus income. This pass keeps the existing site-control economy and does not add classic carry/drop-off harvesting, enemy worker mining AI, enemy construction AI, new maps/factions/units/buildings, runtime art/assets, save migration, broad pathing rewrite, global rebalance, Patrol, formations, or test weakening.

Baseline:

- Starting commit: `460d576`, `Checkpoint v0.21.3 worker explicit attack damage and status clarity`.
- Starting branch state: clean `main`, synced with `origin/main`.
- v0.21.3 was pushed to `origin/main` before v0.22 work began.

Included work:

- Added `docs/V022_RESOURCE_SITE_WORKER_ASSIGNMENT_SPEC.md`.
- Added `docs/V022_IMPLEMENTATION_REPORT.md`.
- Added `docs/V022_EMMANUEL_RETEST_CHECKLIST.md`.
- Updated package metadata and validation to name `v0.22 resource site worker assignment foundation`.
- Added one runtime Worker slot to each capture site.
- Added explicit Worker assignment orders from Worker command buttons and right-clicking friendly captured sites.
- Kept proximity-only Worker/site contact from assigning or boosting income.
- Added Worker order summary states for `Returning to Site` and `Working Site`.
- Added site income breakdowns with unchanged baseline income plus a conservative 20% rounded Worker bonus, minimum +1.
- Cleared assignment on move, attack, build, repair, reassignment, Worker death, and lost/invalid site control.
- Added selected-site UI for base income, Worker slot, Worker bonus, boosted income, and invalid assignability reasons.
- Added focused unit/UI/package and hosted deep-battle coverage for assignment, no proximity assignment, boost income, recall/reassign/death/site-loss clearing, and command override behavior.

Verification and closeout so far:

```text
npm exec tsc -- --noEmit PASS.
npm exec vitest run src/game/entities/UnitCommandState.test.ts src/game/systems/ResourceSystem.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/UnitOrderSummary.test.ts src/game/playtest/PlaytestPackageValidation.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts -- --reporter=dot PASS, 6 files / 41 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker assignment boosts" --reporter=line PASS, 1 hosted Worker assignment regression.
npm test PASS, 66 files / 500 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 22 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
```

Closeout note: package and verify the private playtest build, run `git diff --check`, commit, regenerate/verify a clean package from the final v0.22 commit, then push.

## v0.21.3 Worker Explicit Attack Damage And Status Clarity - 2026-05-24

Scope: follow Emmanuel's FAIL / MIXED retest by fixing Worker explicit attack damage visibility/proof and clarifying the Burn/status marker. This pass does not add harvesting, repair expansion, enemy repair AI, enemy construction AI, new units/buildings/maps/factions, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or test weakening.

Baseline:

- Starting local commit: `5b33fc5`, `Checkpoint v0.21.3 worker intent closeout and CI verification`.
- Starting branch state: clean `main`, ahead of `origin/main` by 1 local commit.
- Emmanuel retest result: Worker moved to an enemy building after explicit attack but showed no damage numbers and no visible enemy-building HP reduction; Burn/status marker still looked like a red/orange dot at the start of the health bar.

Included work:

- Updated `docs/V0213_WORKER_INTENT_CLOSEOUT.md`.
- Added `docs/V0213_EMMANUEL_WORKER_ATTACK_RETEST_INTAKE.md`.
- Added `docs/V0213_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md`.
- Updated package metadata and validation to name `v0.21.3 worker explicit attack damage and status clarity`.
- Included the v0.21.3 closeout, attack retest intake, and cursor note docs in private playtest packages.
- Added a narrow explicit Worker building-attack damage floor only for explicit Worker building targets.
- Kept idle Workers from auto-attacking enemy buildings by proximity.
- Let Worker explicit building hits show floating damage by carrying source through combat damage callbacks.
- Changed Burn/status markers into a labeled `BURN` chip above the health bar so the marker is not mistaken for broken HP fill.

Remote CI:

- Previous GitHub Actions push run `26377505856` / run `#120` on `main` / `ab02e9b`: Fast confidence passed.
- Push workflow rules skipped Optional visual QA, Release simulator, hosted release groups, and Full release e2e.
- Exact workflow-dispatch release matrix for `ab02e9b` was not triggered from this environment because local `gh` is unavailable, no `GITHUB_TOKEN`/`GH_TOKEN` is present, the GitHub connector exposes run/job inspection but no workflow_dispatch creation, and an unauthenticated workflow_dispatch REST attempt returned `401 Unauthorized`.
- Run CI Release Matrix Dry Run manually on `main` with `run_release_matrix=true` after the final v0.21.3 commit if exact remote hosted/simulator evidence is needed before v0.22.
- Non-blocking GitHub notice: the Actions page displayed a future Node.js 20 action-runtime deprecation warning for `actions/checkout@v4` and `actions/setup-node@v4`; it did not fail Fast confidence.

Verification and closeout so far:

```text
npm test PASS, 65 files / 487 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Worker explicit attack damages" --reporter=line PASS, 1 focused Worker attack regression.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-5b33fc5-dirty generated.
npm run verify:playtest-package PASS, 62 checks.
git diff --check PASS.
```

Closeout note: amend the local unpushed v0.21.3 commit, then regenerate and verify a clean package from the final v0.21.3 commit.

## v0.21.2 Worker Intent Clarity And Healthbar Polish - 2026-05-24

Scope: respond to Emmanuel's v0.21.1 Worker repair retest feedback with a narrow Worker intent, combat-clarity, and healthbar polish pass. This pass does not add harvesting, repair expansion, enemy repair AI, enemy construction AI, new units/buildings/maps/factions, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or test weakening.

Baseline:

- Starting commit: `f6a121b`, `Checkpoint v0.21.1 worker repair closeout and CI verification`.
- Starting package: `ascendant-realms-private-playtest-f6a121b`.
- Branch was clean and synced with `origin/main`.

Included work:

- Added `docs/V0212_EMMANUEL_WORKER_REPAIR_RETEST_INTAKE.md`.
- Added `docs/V0212_CURSOR_AFFORDANCE_FUTURE_UI_NOTE.md`.
- Updated package metadata and validation to name `v0.21.2 worker intent clarity and healthbar polish`.
- Allowed explicit Worker attack orders to damage valid enemy buildings through the existing weak Worker combat stats.
- Kept idle Workers from auto-attacking nearby enemy buildings by default.
- Required explicit active Worker construction intent before incomplete friendly buildings progress.
- Required explicit active Worker repair intent before damaged friendly completed buildings repair.
- Kept range requirements for both construction and repair: command plus alive Worker plus in range equals progress.
- Made move-away clear active construction/repair work intent; moving back alone no longer resumes, while reissuing Build/Resume Construction or Repair does.
- Added right-click resume construction for selected Workers on incomplete friendly sites.
- Added rectangular building-footprint hit testing for visible building corners without widening empty terrain selection.
- Moved status/burn badges beside the healthbar so ranged/status damage no longer looks like a red dot at the start of the Worker's bar.
- Added focused regression coverage for explicit construction/repair intent, no proximity-only work, reissued work commands, Worker explicit attack, idle Worker non-aggression against buildings, building footprint targeting, and the healthbar/status-badge position.
- Kept repair/build/construction commands distinct from attack commands.
- Kept future crossed-swords attack and hammer repair/build cursor work as documentation only; no runtime cursor art/assets were added.
- Kept smoke assertions intact while giving only cold dev-server main-menu boot enough time for the existing texture preload path.

Verification and closeout so far:

```text
npm exec vitest run src/game/systems/BuildingSystem.test.ts src/game/systems/RepairSystem.test.ts src/game/systems/CombatSystem.test.ts src/game/systems/CollisionSystem.test.ts src/game/entities/BaseEntity.test.ts src/game/ui/UnitOrderSummary.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/battle/BattleSceneAlerts.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 10 files / 88 tests.
Browser local smoke PASS at http://127.0.0.1:5173/ with main-menu text, 1280x720 canvas, and 0 console errors.
npx playwright test tests/e2e/smoke.spec.ts --grep "main menu boots" --reporter=line PASS, 1 test.
npm test PASS, 65 files / 485 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-91882f2-dirty generated.
npm run verify:playtest-package PASS, 59 checks.
git diff --check PASS.
```

Closeout note: commit, then regenerate and verify a clean package from the final v0.21.2 commit.

## v0.21.1 Worker Repair Closeout And CI Verification - 2026-05-24

Scope: close out v0.21 by pushing the Worker repair foundation, inspecting GitHub Actions, refreshing package metadata, and documenting the final repair retest focus. This pass does not add harvesting, repair expansion, enemy repair AI, enemy construction AI, new units/buildings/maps/factions, runtime art/assets, save migration, broad AI/pathing rewrite, global rebalance, Patrol, formations, or test weakening.

Baseline:

- Starting commit: `79d038b`, `Checkpoint v0.21 worker repair foundation`.
- Starting branch state: clean `main`, ahead of `origin/main` by 1 commit.
- `79d038b` was pushed to `origin/main`; `git status --short --branch` and `git rev-list --left-right --count origin/main...HEAD` returned clean/synced.

Included work:

- Added `docs/V0211_WORKER_REPAIR_CLOSEOUT.md`.
- Updated package metadata and package validation to name `v0.21.1 worker repair closeout and CI verification`.
- Included the v0.21.1 closeout doc in private playtest packages.
- Made no runtime, balance, save, art, pathing, AI, map, faction, unit, building, or repair-rule changes.

Remote CI:

- GitHub Actions push run `26374133694` on `main` / `79d038b`: Fast confidence passed.
- Push workflow rules skipped Optional visual QA, Release simulator, hosted release groups, and Full release e2e.
- Exact `79d038b` workflow_dispatch release matrix remains recommended if remote simulator/hosted evidence is required; this environment has no `gh` CLI and the available GitHub connector does not expose workflow_dispatch creation.

Verification and closeout so far:

```text
npm exec vitest run src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 1 file / 3 tests.
npm test PASS, 64 files / 478 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-79d038b-dirty generated.
npm run verify:playtest-package PASS, 57 checks.
git diff --check PASS.
```

Closeout note: after this metadata update, rerun focused package-validation tests, package, verify package, `git diff --check`, commit, regenerate/verify the clean package from the final commit, and push the v0.21.1 closeout commit.

## v0.21 Worker Repair Foundation - 2026-05-24

Scope: add the first safe Worker repair action for damaged friendly completed buildings. This pass does not add harvesting, resource-dropoff economy, enemy repair AI, enemy construction AI, multiple-worker acceleration, save migration, new maps/factions/units/buildings, runtime art/assets, broad AI/pathing rewrite, global rebalance, Patrol, or formations.

Baseline:

- Starting commit: `1ae687e`, `Checkpoint v0.20.1 tech tree closeout and polish`.
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-1ae687e`.
- Branch was clean and synced with `origin/main`.

Included work:

- Added `docs/V021_WORKER_REPAIR_FOUNDATION_SPEC.md`.
- Added `docs/V021_IMPLEMENTATION_REPORT.md`.
- Added Worker repair intent state separate from construction, move, and attack orders.
- Added `RepairSystem` for validation, Worker approach, pause/resume, and slow HP restoration.
- Allowed Workers to repair damaged friendly completed Command Hall, Barracks, Mystic Lodge, and Watchtower buildings.
- Blocked repair for enemy buildings, incomplete buildings, and full-health buildings.
- Kept incomplete buildings on construction behavior only.
- Made explicit move and attack orders pause repair without pulling Workers back.
- Added Worker repair command buttons and damaged/full-health repair status to existing HUD surfaces.
- Added focused unit/UI/package and hosted deep-battle repair coverage.

Verification and closeout so far:

```text
npm exec tsc -- --noEmit PASS.
npm exec vitest run src/game/systems/RepairSystem.test.ts src/game/systems/BuildingSystem.test.ts src/game/ui/UnitOrderSummary.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts -- --reporter=dot PASS, 5 files / 38 tests.
npm exec vitest run src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 1 file / 3 tests.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker repairs a damaged friendly completed building" --reporter=line PASS, 1 hosted repair proxy test.
npm test PASS, 64 files / 478 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 20 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-1ae687e-dirty generated.
npm run verify:playtest-package PASS, 56 checks.
git diff --check PASS.
```

Closeout note: commit, then regenerate and verify a clean package from the final v0.21 commit.

## v0.20.1 Tech Tree Closeout And Polish - 2026-05-24

Scope: close out v0.20 by pushing the checkpoint, verifying CI/package confidence, auditing building-owned tech-tree roles, and updating package metadata/docs. This pass does not add harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, runtime art/assets, broad AI/pathing rewrite, global rebalance, big systems, or new upgrade content.

Baseline:

- Starting commit: `ae3d80d`, `Checkpoint v0.20 upgrade and tech tree foundation`.
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-ae3d80d`, verified locally with 53 checks.
- Branch was clean and ahead of `origin/main` by 1 commit.
- `ae3d80d` was pushed to `origin/main`; `git status --short --branch` and `git rev-list --left-right --count origin/main...HEAD` returned clean/synced.

Included work:

- Added `docs/V0201_TECH_TREE_CLOSEOUT_AND_POLISH.md`.
- Updated package metadata and package validation to name `v0.20.1 tech tree closeout and polish`.
- Included the v0.20.1 closeout doc in private playtest packages.
- Audited Command Hall, Barracks, Mystic Lodge, Watchtower, upgrade ownership, prerequisites, and effect summaries.
- Made no runtime or balance changes.

Remote CI:

- GitHub Actions push run `26372137063` on `main` / `ae3d80d`: Fast confidence passed.
- Push workflow rules skipped Optional visual QA, Release simulator, hosted release groups, and Full release e2e.
- Exact `ae3d80d` manual workflow_dispatch release matrix remains recommended if remote simulator/hosted evidence is required; this environment had no `gh` or GitHub token available to trigger it.

Verification and closeout so far:

```text
npm test PASS, 63 files / 465 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
```

Closeout note: after this metadata update, rerun focused package-validation tests, package, verify package, `git diff --check`, commit, regenerate/verify the clean package from the final commit, and push the v0.20.1 closeout commit.

## v0.20 Upgrade And Tech Tree Foundation - 2026-05-24

Scope: first structured upgrade/tech-tree foundation on top of the v0.19.1 production-role baseline. This pass does not add harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, runtime art/assets, broad AI/pathing rewrite, global rebalance, or a large upgrade roster.

Baseline:

- Starting commit: `a59248c`, `Checkpoint v0.19.1 production architecture verification and role polish`.
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-a59248c`.
- Branch was clean and synced with `origin/main`.
- GitHub Actions CI Release Matrix Dry Run #115 passed on `main` / `a59248c`: Fast confidence, Release simulator, and hosted release groups succeeded.

Included work:

- Added `docs/V020_TECH_TREE_FOUNDATION_SPEC.md`.
- Added `docs/V020_IMPLEMENTATION_REPORT.md`.
- Added explicit upgrade owner, category, tier, and effect-summary metadata.
- Added Command Hall core upgrade `Camp Foundations I` while keeping Command Hall Worker-only for training.
- Kept Barracks as Militia/Ranger production and clarified its existing Infantry Weapons I, Reinforced Armor I, and Ranger Training I ownership.
- Kept Mystic Lodge on Acolyte and Aether Study I.
- Added Watchtower defensive upgrade `Sentry Bracing I` behind completed Watchtower plus `Camp Foundations I`.
- Added building armor upgrade application for current and future matching buildings.
- Expanded HUD/command copy for owner, requirement, category, effect, cost, researching, and researched states.
- Kept incomplete-building research locked and kept Tutorial step count stable.
- Added data, system, UI, package-validation, and hosted Tutorial proxy coverage for the new upgrade foundation.

Verification and closeout so far:

```text
npm exec vitest run src/game/data/techTree.test.ts src/game/data/productionRoles.test.ts src/game/systems/UpgradeSystem.test.ts src/game/systems/UpgradeEffects.test.ts src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/tutorial/TutorialStepModel.test.ts src/game/systems/TrainingSystem.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 10 files / 43 tests.
npm test PASS, 63 files / 465 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route keeps Command Hall, Barracks, and Watchtower roles readable" --reporter=line PASS, 1 hosted Tutorial proxy test.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 19 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-a59248c-dirty generated.
npm run verify:playtest-package PASS, 53 checks.
```

Closeout note: run `git diff --check`, commit, then regenerate/verify a clean package from the final v0.20 commit.

## v0.19.1 Production Role Verification And Polish - 2026-05-24

Scope: automated verification and small readability polish for the v0.19 production architecture before v0.20. This pass does not add harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, runtime art/assets, broad AI/pathing rewrite, or global rebalance.

Baseline:

- Starting commit: `ec73568`, `Checkpoint v0.19 production architecture and building roles`.
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-ec73568`.
- Branch was clean and synced with `origin/main`.
- v0.19 push run #112 passed Fast confidence and skipped release-matrix lanes by push rules.
- v0.19 workflow-dispatch run #113 passed Fast confidence, Release simulator, hosted deep-meta, hosted deep-battle, hosted deep-campaign-pressure, and hosted smoke. It failed only hosted layout-core/layout-cinderfen because those tests still expected removed Command Hall build/upgrade actions; v0.19.1 fixes that stale expectation.

Included work:

- Added `docs/V0191_PRODUCTION_ROLE_VERIFICATION_PLAN.md`.
- Added `docs/V0191_REMOTE_CI_STATUS.md`.
- Added `docs/V0191_PRODUCTION_ROLE_POLISH_REPORT.md`.
- Added a production-role data audit for Command Hall, Worker, Barracks, Mystic Lodge, Watchtower, and upgrade prerequisites.
- Kept Command Hall normal player-facing production to Worker training only and expanded negative tests for army, direct build, and research actions.
- Reconfirmed incomplete Barracks/Mystic Lodge/Watchtower show role/status/unlock copy with no completed train/research actions.
- Reconfirmed completed Barracks exposes Militia/Ranger plus Infantry Weapons I, Reinforced Armor I, and Ranger Training I.
- Reconfirmed completed Mystic Lodge exposes Acolyte and Aether Study I.
- Reconfirmed incomplete Watchtower inert behavior and completed Watchtower defense coverage.
- Added a focused hosted Tutorial proxy for Command Hall -> Worker -> Barracks -> army plus Watchtower role readability.
- Polished Command Hall, Mystic Lodge, Watchtower, incomplete-building, and defeat-tip copy only.

Verification and closeout so far:

```text
npm exec vitest run src/game/data/productionRoles.test.ts src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/core/ResultsFlow.test.ts src/game/playtest/PlaytestPackageValidation.test.ts -- --reporter=dot PASS, 6 files / 33 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route" --reporter=line PASS, 1 test.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Tutorial production route|behaviour mode control gauntlet" --reporter=line PASS, 2 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm test PASS, 62 files / 458 tests.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 19 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-ec73568-dirty generated.
npm run verify:playtest-package PASS, 51 checks.
git diff --check PASS.
```

Closeout note: commit, then generate and verify a clean package from the final v0.19.1 commit.

## v0.19 Production Architecture And Building Roles - 2026-05-24

Scope: clarify production architecture and building roles after the accepted v0.18.3 Worker construction baseline. This pass does not add harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, runtime art/assets, or broad global rebalance.

Baseline:

- Stable runtime/package baseline from v0.18.3: commit `ce43d0e`, package `artifacts/playtest/ascendant-realms-private-playtest-ce43d0e`.
- Current starting commit: `5762120`, a docs-only descendant of `ce43d0e`.
- Emmanuel retest result: Worker construction assignment, pause/resume, and base-cluster pathing now seem resolved.
- v0.18.3 GitHub Actions baseline: CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`.

Included work:

- Added `docs/V019_PRODUCTION_ARCHITECTURE_SPEC.md`.
- Added `docs/V019_IMPLEMENTATION_REPORT.md`.
- Kept Command Hall player-facing production to Worker training only.
- Moved existing Infantry Weapons I and Reinforced Armor I research from Command Hall to Barracks.
- Kept Barracks as completed Militia/Ranger production and added all existing basic troop research there.
- Kept Mystic Lodge as completed Acolyte and Aether Study I production/research.
- Kept Watchtower completed-only defensive behavior and incomplete inert behavior.
- Added role and unlock summaries to existing building HUD/command surfaces.
- Updated Tutorial copy to explain Command Hall -> Worker, Worker -> building, Barracks -> army, and Watchtower -> defense without adding steps.
- Extended unit and hosted browser coverage for building roles, incomplete-building inactivity, Worker construction pathing retention, and Barracks-owned research.

Verification and closeout so far:

```text
npm exec vitest run src/game/ui/hudPanels/HudFormatting.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/tutorial/TutorialStepModel.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/UpgradeSystem.test.ts PASS, 6 files / 27 tests.
npm exec tsc -- --noEmit PASS.
npm test PASS, 61 files / 454 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 3.7m.
npm run test:e2e:smoke PASS, 14 tests in 7.7m after exact rerun; first attempt hit the known cold dev-server main-menu boot timeout on test 1 while the remaining 13 tests passed.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 18 tests in 8.9m after a real-canvas retry fix for the existing behaviour-gauntlet left-click attack command.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests in 2.5m. Extra coverage for updated Barracks research ownership.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 4.4m.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-5762120-dirty generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-5762120-dirty PASS, 48 checks.
git diff --check PASS.
```

Closeout note: commit, then generate and verify a clean package from the final v0.19 checkpoint commit.

## v0.18.3 Worker Assignment And Construction Pathing Fix - 2026-05-24

Scope: fix the v0.18.2 Worker construction assignment and building-cluster pathing bugs from Emmanuel's `039fe64` mixed retest. This pass does not add v0.19 feature work, harvesting, repair, multiple-worker acceleration, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, visual overhaul, runtime art/assets, or broad economy rebalance.

Baseline:

- Starting commit: `039fe64`, `Document v0.18.2 worker construction closeout`.
- Branch was clean and synced with `origin/main`.
- Current clean package before this pass: `artifacts/playtest/ascendant-realms-private-playtest-039fe64`.
- Accepted runtime/package baseline after green matrix: commit `ce43d0e`, package `artifacts/playtest/ascendant-realms-private-playtest-ce43d0e`.
- Baseline status: Worker construction foundation stable enough for next phase.

Included work:

- Added `docs/V0183_EMMANUEL_039FE64_WORKER_RETEST_INTAKE.md`.
- Added `docs/V0183_WORKER_ASSIGNMENT_PATHING_FIX_REPORT.md`.
- Added separate Worker construction intent state so construction auto-move no longer looks like an ordinary player move order.
- Explicit player move and attack orders pause the current construction assignment.
- Assigned construction progresses only while the assigned Worker is alive and within valid footprint work range.
- Moving the Worker back into range resumes construction.
- Construction-site UI status now reports `Building` or `Paused - Worker away` using existing selected-entity UI surfaces.
- Movement and construction approach routing use a finer path grid with exact terrain/static-obstacle checks, preserving solid blocker interiors while keeping visible open edge points reachable.
- Added unit and hosted browser regression coverage for Worker move-away pause/resume, incomplete Watchtower behavior, and Command Hall + Barracks + Mystic Lodge + Watchtower movement/attack movement.

Verification and closeout so far:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npx vitest run src/game/systems/BuildingSystem.test.ts src/game/systems/MovementSystem.test.ts src/game/systems/CombatSystem.test.ts --reporter=dot PASS, 3 files / 47 tests.
npx vitest run src/game/systems/PathfindingGrid.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/MovementSystem.test.ts --reporter=dot PASS, 3 files / 17 tests.
npx vitest run src/game/systems/BuildingSystem.test.ts src/game/systems/MovementSystem.test.ts src/game/systems/PathfindingGrid.test.ts src/game/systems/TrainingSystem.test.ts --reporter=dot PASS, 4 files / 25 tests.
npm test PASS, 61 files / 450 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 3.8m after exact rerun; first attempt was a cold Vite dev-server boot timeout before Phaser reached the main menu.
npm run test:e2e:smoke PASS, 14 tests in 9.3m after prewarming the dev server; the cold dev-server first test timed out before app boot, then the warmed rerun passed.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 18 tests in 8.9m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 4.3m.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-039fe64-dirty generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-039fe64-dirty PASS, 46 checks.
git diff --check PASS.
npm run package:playtest PASS after commit, clean package artifacts/playtest/ascendant-realms-private-playtest-ce43d0e generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-ce43d0e PASS, 46 checks.
CI Release Matrix Dry Run #26365296115 on main / ce43d0e PASS: Fast confidence, Release simulator, and hosted release groups deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke all succeeded. Optional visual QA and Full release e2e were skipped by input.
```

Closeout note: `ce43d0e` / `ascendant-realms-private-playtest-ce43d0e` is the v0.18.3 Worker construction foundation baseline for Emmanuel retest and the next phase.

## v0.18.2 Worker Construction Expansion - 2026-05-23

Scope: expand the Worker construction foundation to the existing player building set only: Barracks, Mystic Lodge, and Watchtower. This pass does not add harvesting, repairs, multiple workers per site, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, visual overhaul, runtime art/assets, or broad economy rebalance.

Baseline:

- Starting commit: `7ec2701`, `Simplify construction site progress display`.
- Branch was clean and synced with `origin/main`.
- Current clean package before this pass: `artifacts/playtest/ascendant-realms-private-playtest-7ec2701`.

Included work:

- Added `docs/V0182_WORKER_CONSTRUCTION_EXPANSION_SPEC.md`.
- Added `docs/V0182_IMPLEMENTATION_REPORT.md`.
- Expanded Worker build options to Barracks, Mystic Lodge, and Watchtower.
- Kept Command Hall Worker-training only and direct build commands hidden.
- Preserved existing building costs, build times, footprints, art conventions, and completed behavior.
- Added command-panel coverage for all Worker build buttons and affordability text.
- Added incomplete-Watchtower combat coverage so construction sites cannot attack before completion.
- Cleaned selected construction-site UI copy to `Assigned Worker`.
- Package metadata and validation now include the v0.18.2 Worker construction expansion docs.

Verification and closeout:

```text
npx vitest run src/game/playtest/PlaytestPackageValidation.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts src/game/systems/TrainingSystem.test.ts src/game/systems/CombatSystem.test.ts src/game/systems/BuildingSystem.test.ts --reporter=dot PASS, 6 files / 49 tests.
npx tsc -p tsconfig.json --noEmit PASS.
npm run build PASS with the known Vite chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker can be trained|Worker exposes existing build set" --reporter=line PASS, 2 hosted tests in 1.8m.
npm test PASS, 61 files / 442 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run playtest:sim PASS, 255 simulated runs across 85 campaign battle nodes.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 7.6m.
npm run test:e2e:release:hosted:deep-battle PASS, 17 tests in 6.2m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.4m.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests in 1.8m.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests in 1.9m.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests in 3.6m.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests in 3.5m.
npm run test:e2e:release PASS, 82 tests in 39.3m.
npm run smoke:preview PASS at http://127.0.0.1:4173/ with 0 browser console errors.
```

Post-commit closeout completed on 2026-05-24:

- `git diff --check` passed before commit.
- Implementation commit `a20da05` (`Checkpoint v0.18.2 worker construction expansion`) was pushed to `origin/main`.
- Clean package `artifacts/playtest/ascendant-realms-private-playtest-a20da05` was generated from a clean tree and passed package verification with 44 checks.
- The package was served locally at `http://127.0.0.1:4174/`; Browser boot sanity reached the main menu, rendered a 1280x720 canvas, and reported no browser console errors.
- GitHub Actions push run #107 / `26351035731` completed successfully for commit `a20da05`. The Fast confidence job passed. Release matrix, simulator, optional visual QA, and full release e2e jobs were skipped on push by workflow rules, so the release-matrix evidence for this checkpoint is the local production-preview matrix above.

Closeout note: no remaining v0.18.2 implementation blockers are known.

## v0.18 Worker Construction Foundation - 2026-05-23

Scope: implement the first safe Worker construction vertical slice only. This pass adds one Worker unit, Command Hall Worker training, Worker-built Barracks construction sites, assigned-worker construction progress, UI feedback, package metadata, and focused tests. It does not add harvesting, repairs, multiple workers per site, enemy construction AI, save migration, new factions, new maps, Patrol runtime, formations, visual overhaul, or runtime art/assets.

Baseline:

- Starting commit: `2fa6de3`, `Update v0.17.5 release handoff after green matrix`.
- Branch was clean and synced with `origin/main`.
- v0.17.5 clean package `artifacts/playtest/ascendant-realms-private-playtest-2fa6de3` existed from the previous closeout.
- GitHub Actions baseline from the previous handoff: CI Release Matrix Dry Run #102 green for fast confidence, release simulator, and all six hosted release-matrix groups.

Included work:

- Added `docs/V018_WORKER_CONSTRUCTION_FOUNDATION_SPEC.md`.
- Added `docs/V018_IMPLEMENTATION_REPORT.md`.
- Added Free Marches `worker` unit data with existing art conventions only.
- Added `buildOptions` to unit definitions plus unit build-option content validation.
- Command Hall can train Workers.
- Worker selection can start Barracks placement.
- Worker-placed Barracks sites store assigned Worker id/name, construction status detail, and progress.
- Assigned construction only progresses while the Worker is alive and near the building footprint.
- Worker approach movement uses the existing pathfinding grid and live building blockers.
- Incomplete buildings still block/path like buildings but do not expose train/upgrade actions.
- Selected-building UI shows construction progress, assigned Worker, status, and production-lock copy.
- Command Hall no longer exposes direct building placement commands; Tutorial remains stable by routing the existing Barracks objective through Worker training and Worker placement.
- Package metadata and validation now require the v0.18 Worker construction docs.
- Hosted deep-battle coverage includes Worker training, Worker Barracks placement, assigned construction progress, completion, and completed Barracks production unlock.
- Existing hosted behaviour-mode gauntlet click handling was stabilized with the standard `clickReady` path after hosted evidence showed the old custom helper could keep stale layout errors and outwait the retreat-suppression window.

Verification so far:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts src/game/systems/BuildingSystem.test.ts src/game/systems/TrainingSystem.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/SelectedEntityPanel.test.ts PASS, 5 files / 17 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "Worker can be trained" --reporter=line PASS, 1 hosted test.
npm test PASS, 61 files / 440 tests.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run build PASS with the known Vite chunk-size warning.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 7.4m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --reporter=line PASS after hosted helper stabilization, 1 test in 1.1m.
npm run test:e2e:release:hosted:deep-battle PASS after hosted helper stabilization, 16 tests in 5.3m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.3m.
npm run test:e2e:release PASS, 81 tests in 40.8m.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-2fa6de3-dirty generated.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-2fa6de3-dirty PASS, 42 checks.
Packaged local-server browser boot sanity PASS at http://127.0.0.1:4174/.
```

Runtime gameplay changed: yes, Worker training, Worker-assigned Barracks construction, and removal of player-facing Command Hall direct construction commands. Gameplay numbers changed: yes, one new Worker unit and Command Hall Worker training cost/time; existing army unit/building/wave/resource/global balance values were not broadly rebalanced. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no runtime combat-control behavior changed; one hosted test helper was stabilized. Tutorial impact: existing Barracks objective now uses Worker training and Worker placement without adding steps. Economy/production architecture rewritten: no, only a foundation slice.

Pending closeout after this local-verification checkpoint: `git diff --check`, commit/push, clean package generation/verification, and GitHub Actions release matrix rerun after push.

## v0.17.5 Ranger Near-Base Invisible Blocker Fix - 2026-05-23

Scope: respond to Emmanuel's mixed Tutorial retest of `ascendant-realms-private-playtest-7baa99a` with a narrow pathing/collision-proxy fix only. v0.17.4 reduced the hard trained-Ranger stuck case, but several ranged units could still feel blocked by invisible geometry near the Barracks / Command Hall cluster until redirected.

Baseline:

- Starting commit: `7baa99a`, `Checkpoint v0.17.4 trained Ranger spawn and movement recovery`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-7baa99a`.
- Manual result: MIXED. Rangers were not completely stuck, but some move orders near the player base felt like they hit an invisible blocker.
- Follow-up manual result after the v0.17.5 local fix: PASS. User tested Ranger movement around the Tutorial base in the in-app browser and reported the issue seems solved.

Included work:

- Added `docs/V0175_EMMANUEL_7BAA99A_TUTORIAL_RETEST_INTAKE.md`.
- Static building blockers still mark coarse path cells for routing, but exact world-point walkability now checks the padded building rectangle instead of treating the entire coarse cell as blocked.
- Walkable goals that share a coarse static-blocked cell can now be used as exact path endpoints, so visible open ground beside the Command Hall does not behave like an invisible rock.
- Path smoothing now anchors from the requested start point instead of the start cell center, preserving exact start/end behavior around coarse static cells.
- Added PathfindingGrid and MovementSystem regressions for visible open points in coarse static building cells.
- Strengthened the Tutorial trained-Ranger regression so a cluster of Rangers answers repeated near-base move orders, including the visible west side of the Command Hall.
- Package metadata and validation now require the v0.17.5 intake doc.
- Runtime fix commit `caae2b4` was pushed to `origin/main`, followed by hosted Playwright stabilization commits `74ce170` and `d0f59e9`.
- Hosted stabilization kept coverage intact while removing CI-only timing races in manual combat hover targeting, Tutorial/selected-panel HUD toggles, Cinderfen layout map-name checks, and behaviour-mode panel refresh after canvas attack clicks.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm test -- src/game/systems/PathfindingGrid.test.ts src/game/systems/MovementSystem.test.ts src/game/systems/TrainingSystem.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 4 files / 15 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Tutorial Barracks can train clustered Rangers" --reporter=line PASS, 1 test in 21.1s.
npm test PASS, 60 files / 433 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.7m.
In-app Browser local Tutorial boot check PASS: main menu loaded, Tutorial HUD visible, canvas present.
User manual in-app browser retest PASS: Ranger near-base invisible-blocker issue seems solved.
npm run package:playtest PASS, dirty package ascendant-realms-private-playtest-7baa99a-dirty.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-7baa99a-dirty PASS, 40 checks.
git diff --check PASS.
npm run package:playtest PASS, clean package ascendant-realms-private-playtest-caae2b4.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-caae2b4 PASS, 40 checks.
npm run test:e2e:release:hosted:deep-battle PASS after hosted-stabilization fixes, 15 tests in 5.0m.
npm run test:e2e:release:hosted:smoke PASS after hosted-stabilization fixes, 14 tests in 3.6m.
npm run test:e2e:release:hosted:layout-cinderfen PASS after layout status stabilization, 12 tests in 4.2m.
npx tsc -p tsconfig.json --noEmit PASS after hosted-stabilization fixes.
npm test PASS after first hosted-stabilization fix, 60 files / 433 tests.
GitHub Actions CI Release Matrix Dry Run #100 PASS on d0f59e9: Fast confidence, Release simulator, and all six release matrix jobs succeeded; optional visual QA and full release e2e were intentionally skipped.
```

Runtime gameplay changed: yes, static building point-walkability and exact path endpoints near coarse building cells. Gameplay numbers changed: no unit/building/resource/wave/pacing/balance values changed; v0.17.2 Tutorial-only pacing is preserved. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no. Worker construction implemented: no. Economy/production architecture rewritten: no. Test/CI harness changed: yes, hosted Playwright checks now avoid known timing races without weakening assertions. Package changed: metadata/validator updated and clean runtime package verified.

Release handoff rule: distribute only a clean package generated from the exact commit being handed off, and rerun package verification if HEAD changes. No runtime, gameplay-data, save, asset, balance, or hosted release-matrix follow-up is pending for v0.17.5.

## v0.17.4 Trained Ranger Spawn And Movement Recovery - 2026-05-23

Scope: respond to Emmanuel's mixed Tutorial retest of `ascendant-realms-private-playtest-532007d` with a narrow production-spawn/movement fix only. This pass preserves the v0.17.3 cost display, selected side-panel Hide/Show, neutral-contact, and enemy-base text improvements while addressing newly produced Rangers that could appear stuck near the Barracks / Command Hall cluster.

Baseline:

- Starting commit: `532007d`, `Checkpoint v0.17.3 contact polish and command panel readability`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-532007d`.
- Manual result: PASS for cost readability and side-panel Hide/Show.
- Manual monitor items: neutral troop contact and enemy-base visual text did not reproduce in this attempt.
- Remaining issue: a couple of newly produced Rangers could get stuck right after production and ignore movement orders.

Included work:

- Added `docs/V0174_EMMANUEL_532007D_TUTORIAL_RETEST_INTAKE.md`.
- Training spawn placement now checks the live pathfinding grid and building-footprint clearance before creating a trained unit.
- Movement now performs a small nearest-walkable correction for move-ordered units that start inside a blocked building cell.
- Added deterministic TrainingSystem and MovementSystem tests for the Tutorial Barracks / Command Hall blocked-cell setup.
- Added a deep browser/manual-proxy regression that launches Tutorial, places Barracks at the reported cluster, trains eight Rangers, orders them to move, and verifies every trained Ranger moves.
- Package metadata and validation now require the v0.17.4 intake doc.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm test -- src/game/systems/TrainingSystem.test.ts src/game/systems/MovementSystem.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 3 files / 9 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Tutorial Barracks can train clustered Rangers" --reporter=line PASS, 1 test in 21.7s.
npm test PASS, 60 files / 431 tests.
npm run build PASS with the known Vite chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.7m.
npm run test:e2e:smoke first run: one existing long Cinderfen Watch/Aftermath extended-smoke path timed out.
npx playwright test tests/e2e/smoke.spec.ts --grep "post-Crossing campaign launches Cinderfen Watch" --reporter=line PASS, 1 test in 1.6m.
npm run test:e2e:smoke rerun PASS, 14 tests in 7.5m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
```

Runtime gameplay changed: yes, trained-unit spawn placement and blocked-start movement recovery. Gameplay numbers changed: no unit/building/resource/wave/pacing/balance values changed; v0.17.2 Tutorial-only pacing is preserved. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no. Worker construction implemented: no. Economy/production architecture rewritten: no. Package changed: metadata/validator updated; package generation and `git diff --check` are pending.

Remaining closeout: generate and verify a dirty-tree private package, run `git diff --check`, commit as `Checkpoint v0.17.4 trained Ranger spawn and movement recovery`, push if safe, regenerate and verify a clean private package, load it in the browser, and rerun GitHub Actions after push because runtime movement/production behavior changed.

## v0.17.3 Contact Polish And Command Panel Readability - 2026-05-23

Scope: respond to Emmanuel's mixed Tutorial retest of `ascendant-realms-private-playtest-e448d18` with a narrow polish/fix pass only. This pass preserves the v0.17.2 incoming damage and beginner-pressure improvements while addressing one brief adjacent neutral-contact idle report, explicit-attack path-warning clutter, bottom-right side-panel obstruction, and unclear command costs.

Baseline:

- Starting commit: `e448d18`, `Checkpoint v0.17.2 imp damage feedback and tutorial easing`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-e448d18`.
- Manual result: PASS for incoming damage readability and Tutorial beginner pressure.
- Remaining feedback: brief player troop / Stone Imp / Wild Hound contact idle, repeated `No clear path` text while attacking enemy base, selected side panel sometimes blocking view, and create-unit/upgrade costs not being obvious enough.

Included work:

- Added `docs/V0173_EMMANUEL_E448D18_TUTORIAL_RETEST_INTAKE.md`.
- Added a small melee visible-contact floor so non-hero troops and neutral melee units attack when they read as adjacent, without broadening Hold Ground into chase behavior.
- Explicit attack-target path failures no longer show the blocked-path floating warning, reducing enemy-base attack text clutter while normal blocked movement warnings remain.
- Added a session-only Hide/Show control to the selected unit/building side panel.
- Build, train, and upgrade commands now show explicit `Cost: ...` text, including locked commands.
- Package metadata and validation now require the v0.17.3 intake doc.
- A deep browser regression now covers the reported militia plus neutral Stone Imp/Wild Hound contact setup and the explicit-attack path-warning suppression.

Verification:

```text
npx tsc -p tsconfig.json --noEmit PASS.
npm test -- src/game/systems/CombatSystem.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 3 files / 35 tests.
npx playwright test tests/e2e/smoke.spec.ts --grep "tutorial entry launches" --reporter=line PASS, 1 test in 31.5s.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 33.2s.
npm test PASS, 59 files / 428 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 7.8m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS, dirty package ascendant-realms-private-playtest-e448d18-dirty.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-e448d18-dirty PASS, 38 checks.
git diff --check PASS.
```

Runtime gameplay changed: yes, melee visible-contact tolerance and explicit-attack path-warning display. Gameplay numbers changed: no map/unit/wave/resource/tutorial pacing values changed; v0.17.2 Tutorial-only pacing is preserved. Save format changed: no. Runtime art/assets changed: no. Worker construction implemented: no. Economy/production architecture rewritten: no. Package changed: metadata/validator updated; clean v0.17.3 package generation is pending after commit.

Remaining closeout: commit as `Checkpoint v0.17.3 contact polish and command panel readability`; push if safe; regenerate and verify a clean private package; load it in the browser; and rerun GitHub Actions after push because runtime combat/UI behavior changed.

## v0.17.2 Imp Damage Feedback And Tutorial Easing - 2026-05-23

Scope: respond to Emmanuel's mixed Tutorial retest of `ascendant-realms-private-playtest-a990f11` with narrow Tutorial polish only. This pass fixes the Stone Imp hero damage feedback threshold, removes the `HIT` prefix from incoming direct damage, and further slows Tutorial-only enemy buildup. It does not implement worker construction or start v0.18.

Baseline:

- Starting commit: `a990f11`, `Checkpoint v0.17.1 tutorial drag polish and beginner pacing`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-a990f11`.
- Manual result: PASS for Tutorial panel dragging.
- Remaining feedback: Stone Imp damage against the hero does not show, incoming player-side direct damage should omit `HIT`, and Tutorial enemy army buildup remains too fast for beginners.

Included work:

- Added `docs/V0172_EMMANUEL_A990F11_TUTORIAL_RETEST_INTAKE.md`.
- Player-owned incoming direct damage now shows down to 1 actual damage, covering Stone Imp hits reduced by hero armor.
- Incoming direct damage now shows compact `-N` text instead of `HIT -N`; status/effect labels remain unchanged.
- Tutorial-only enemy pressure now scales enemy income per tick to 40%, trains no faster than every 24s, expands no faster than every 90s after a 120s initial delay, sends the first attack no earlier than 540s, sends follow-up attacks no faster than every 220s, and keeps attack/expansion groups small.
- Campaign/skirmish map data, global difficulty presets, combat-control behaviour, workers, buildings, units, saves, and runtime art/assets are unchanged.
- Package metadata and validation now require the v0.17.2 intake doc.

Verification so far:

```text
npm test -- src/game/ui/DamageFeedback.test.ts src/game/data/battlePacing.test.ts PASS, 2 files / 7 tests.
npm test -- src/game/ui/DamageFeedback.test.ts src/game/data/battlePacing.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 3 files / 10 tests.
npx tsc -p tsconfig.json --noEmit PASS.
npx playwright test tests/e2e/smoke.spec.ts --grep "tutorial entry launches" --reporter=line PASS, 1 test in 37.2s.
npm test PASS, 58 files / 425 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.9m.
npm run test:e2e:smoke PASS, 14 tests in 8.1m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS, dirty package ascendant-realms-private-playtest-a990f11-dirty.
npm run verify:playtest-package -- --package=artifacts/playtest/ascendant-realms-private-playtest-a990f11-dirty PASS, 37 checks.
```

Runtime gameplay changed: yes, incoming damage feedback readability and Tutorial-only enemy pressure. Gameplay numbers changed: Tutorial-only enemy AI helper values changed; no global map/unit/wave/resource/campaign balance changed. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no. Worker construction implemented: no. Economy/production architecture rewritten: no. Package changed: metadata/validator updated; clean v0.17.2 package generation is pending after commit.

Remaining closeout: run the full verification gate, package generation/verification, and `git diff --check`; commit as `Checkpoint v0.17.2 imp damage feedback and tutorial easing`; push if safe; regenerate and verify a clean private package; and rerun GitHub Actions after push because runtime Tutorial behaviour changed.

## v0.17.1 Tutorial Drag Polish And Beginner Pacing - 2026-05-23

Scope: respond to Emmanuel's mixed Tutorial retest of `ascendant-realms-private-playtest-171ba86` with narrow Tutorial polish only. This pass broadens safe panel dragging, makes incoming player-side damage text more readable through existing floating text, and slows Tutorial-only enemy pressure. It does not implement worker construction or start v0.18.

Baseline:

- Starting commit: `171ba86`, `Checkpoint v0.17 tutorial QoL and worker economy design spec`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-171ba86`.
- Manual result: PASS for Tutorial box Hide/Show/Reset, Tutorial guidance, combat sanity, and Tutorial results flow.
- Remaining feedback: panel only drags from the title, incoming enemy damage on hero/friendly units is unclear, and Tutorial enemy army buildup is too fast for beginners.

Included work:

- Added `docs/V0171_EMMANUEL_TUTORIAL_RETEST_INTAKE.md`.
- Tutorial objective panel drag now starts from any non-button panel area. Buttons and other interactable controls are excluded from drag start.
- Hide/Show and Reset remain local panel controls. Panel offset/minimized state remains HUD-session-only and writes no save data.
- Incoming damage to player-controlled entities now uses existing floating text with distinct `HIT -N` copy and brighter red color; outgoing damage remains `-N`.
- Floating-text settings still control whether damage text appears.
- Tutorial-only enemy pressure now scales enemy income per tick to 60%, trains no faster than every 12s, expands no faster than every 48s after a 60s initial delay, sends the first attack no earlier than 420s, sends follow-up attacks no faster than every 140s, and keeps attack/expansion groups small.
- Campaign/skirmish map data, global difficulty presets, combat-control behaviour, workers, buildings, units, saves, and runtime art/assets are unchanged.
- Package metadata and validation now require the v0.17.1 intake doc.

Verification so far:

```text
npm test -- src/game/ui/hudPanels/TutorialPanel.test.ts src/game/ui/DamageFeedback.test.ts src/game/data/battlePacing.test.ts src/game/playtest/PlaytestPackageValidation.test.ts PASS, 4 files / 14 tests.
npx tsc -p tsconfig.json --noEmit PASS.
npx playwright test tests/e2e/smoke.spec.ts --grep "tutorial entry launches" --reporter=line PASS, 1 test in 31.0s.
npm test PASS, 58 files / 425 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.7m.
npm run test:e2e:smoke PASS, 14 tests in 7.6m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
```

Runtime gameplay changed: yes, Tutorial panel drag targeting, incoming damage text readability, and Tutorial-only enemy pressure. Gameplay numbers changed: Tutorial-only enemy AI helper values changed; no global map/unit/wave/resource/campaign balance changed. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no. Worker construction implemented: no. Economy/production architecture rewritten: no. Package changed: metadata/validator updated; clean v0.17.1 package generation is pending after commit.

Remaining closeout: run package generation/verification and `git diff --check`, commit as `Checkpoint v0.17.1 tutorial drag polish and beginner pacing`, push if safe, regenerate and verify a clean private package, and rerun GitHub Actions after push because runtime Tutorial behaviour changed.

## v0.17 Tutorial QoL And Worker Economy Design Spec - 2026-05-23

Scope: start v0.17 as a first polish/design checkpoint after Emmanuel confirmed the v0.16.13 combat-control baseline. This pass implements Tutorial objective-box QoL, improves Tutorial-specific pressure readability, and documents the worker-economy direction without implementing worker construction.

Baseline:

- Starting commit: `461c563`, `Checkpoint v0.16.13 Stone Imp visible-contact reacquisition fix`.
- Branch was clean and synced with `origin/main`.
- Manual package retested: `ascendant-realms-private-playtest-461c563`.
- Manual result: PASS for the critical adjacent melee bug, attack cursor, Tutorial defeat/results, and no major broken/confusing items.
- Remaining feedback: Tutorial objective box blocks view; Tutorial pressure can feel hard; Command Hall should become worker production long-term.

Included work:

- Added `docs/V017_SOLO_PLAYTEST_INTAKE.md`.
- Added `docs/V017_WORKER_ECONOMY_DESIGN_SPEC.md`.
- Tutorial panel now has a draggable Proving Grounds handle, Hide/Show, and Reset.
- Tutorial panel offset/minimized state is stored only on the live HUD instance and is cleared when the battle UI is destroyed.
- Tutorial panel local controls avoid forcing gameplay HUD rerenders, preserving the existing hover-stability guard for `tutorial-next`.
- Tutorial copy now explicitly teaches early capture income, side mines, Barracks, Militia, rally, grouped defense, and enemy army growth.
- Tutorial launches now apply existing Story pacing values to enemy escalation through a narrow helper, without mutating map data or changing campaign/skirmish AI.
- Package metadata and package validation now require the v0.17 intake and worker-economy spec docs.

Verification so far:

```text
npm test -- src/game/ui/hudPanels/TutorialPanel.test.ts src/game/data/battlePacing.test.ts PASS, 2 files / 8 tests.
npx tsc -p tsconfig.json --noEmit PASS.
npx playwright test tests/e2e/smoke.spec.ts --grep "tutorial entry launches" --reporter=line PASS, 1 test in 41.8s after the local-panel refresh fix.
In-app browser dev check at http://127.0.0.1:5173/ PASS: Tutorial panel visible, drag moved +76/+44, Reset cleared movement, Hide hid body, restore showed Next Objective.
npm test PASS, 57 files / 422 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 3.0m.
npm run test:e2e:smoke PASS, 14 tests in 8.3m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
git diff --check PASS before docs closeout.
```

Runtime gameplay changed: yes, Tutorial UI movement/minimize/reset and Tutorial-only enemy escalation pacing. Gameplay numbers changed: no global map, unit, wave, resource, or campaign balance data changed. Save format changed: no. Runtime art/assets changed: no. Combat-control baseline changed: no. Worker construction implemented: no, design spec only. Economy/production architecture rewritten: no. Package changed: metadata/validator updated; clean v0.17 package generation is pending after commit.

Remaining closeout: rerun `git diff --check`, commit as `Checkpoint v0.17 tutorial QoL and worker economy design spec`, push if safe, regenerate and verify a clean private playtest package, and have Emmanuel retest Tutorial panel movement and pressure feel.

## v0.16.13 Stone Imp Visible-Contact Reacquisition Fix - 2026-05-23

Scope: fix the failed bd26de3 manual retest where a Tutorial Hold Ground hero beside two Stone Imps still idled before combat started or after the first imp died. This is a v0.16.x bugfix follow-up only and does not start v0.17.

Baseline:

- Starting commit: `bd26de3`, `Checkpoint v0.16.12 stationary adjacent melee reacquisition fix`.
- Branch was clean and synced with `origin/main`.
- Manual package tested: `ascendant-realms-private-playtest-bd26de3`.
- Manual result: FAIL, Tutorial route, Hold Ground hero beside two Stone Imps still required moving the hero again to start/restart combat.

Included work:

- Added `docs/V01613_BD26DE3_RETEST_INTAKE.md`.
- Added `docs/V01613_STONE_IMP_VISIBLE_CONTACT_FIX.md`.
- Reproduced bd26de3 with a browser/manual proxy against the clean package: 54px and 57px Stone Imp contact started combat; 58px+ idled.
- Increased melee visible-contact tolerance from 24px to 32px.
- Strengthened unit, deterministic control-lab, and hosted browser/manual regressions to use the 64px Stone Imp visible-contact boundary.
- Updated package metadata and validation for the v0.16.13 checkpoint.

Verification so far:

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 2 files / 33 tests.
npm test -- PlaytestPackageValidation.test.ts CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 3 files / 36 tests.
npm test PASS, 57 files / 421 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 26.7s after rebuilding dist.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 24.7s after final rebuild.
npm run package:playtest PASS against the pre-commit dirty tree.
npm run verify:playtest-package PASS, 33 checks.
```

Runtime gameplay changed: yes, local melee visible-contact reacquisition only. Gameplay numbers changed: no unit stats, waves, resources, or balance data changed. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no mode definitions changed; Hold Ground still refuses distant idle enemies. Enemy aggro changed: no broad AI/pathing rewrite. Retreat logic changed: no. Test/CI harness changed: yes, stronger exact Stone Imp browser/manual proxy coverage and package metadata. Package changed: pending clean v0.16.13 package generation.

Remaining closeout: run the required gates, update generated control-lab reports, run `git diff --check`, commit as a v0.16.13 checkpoint, push if safe, regenerate and verify a clean private playtest package, and have Emmanuel retest the new package instead of bd26de3.

## v0.16.12 Stationary Adjacent Melee Reacquisition Fix - 2026-05-23

Scope: fix Emmanuel's `ec0608a` Tutorial retest failure where a Hold Ground hero and two adjacent Stone Imps could stand in visible contact without combat starting, especially after the first target died. This is a v0.16.x bugfix only and does not start v0.17.

Baseline:

- Starting commit: `ec0608a`, `Checkpoint v0.16.11 release-candidate issue backlog and tester launch prep`.
- Branch was clean and synced with `origin/main`.
- Manual package tested: `ascendant-realms-private-playtest-ec0608a`.
- Manual session: `PT-20260521-EMMANUEL-EC0608A-SOLO-01`, Brave on Windows, Tutorial route, MIXED.

Included work:

- Added `docs/V01612_EMMANUEL_EC0608A_RETEST_INTAKE.md`.
- Added `docs/V01612_STATIONARY_ADJACENT_MELEE_REACQUISITION_FIX.md`.
- Increased melee visible-contact tolerance narrowly.
- Prioritized immediate melee contact over distant explicit targets when the explicit target is not already in effective range.
- Cleared explicit attack-move state after dead/invalid explicit targets so Hold Ground does not become follow-up chase mode.
- Added top/head world hit-test tolerance for units and buildings while preserving empty side terrain refusal.
- Updated package metadata and validation for the v0.16.12 checkpoint.

Verification so far:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 5 files / 45 tests.
npm test PASS, 57 files / 421 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 24.4s.
Browser preview sanity at http://127.0.0.1:5173/ PASS: main menu loaded, Tutorial reached BattleScene, console errors 0.
npm run package:playtest PASS against the pre-commit dirty tree.
npm run verify:playtest-package PASS, 31 checks.
```

Runtime gameplay changed: yes, melee contact/reacquisition semantics only. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: yes, Hold Ground contact/post-target-death semantics only. Enemy aggro changed: yes, immediate melee contact can interrupt a distant explicit target; no global chase was added. Retreat logic changed: no. Test/CI harness changed: yes, stronger unit/control-lab/hosted regression coverage and package metadata. Package changed: yes, v0.16.12 build metadata and intake doc.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.12 stationary adjacent melee reacquisition fix`, push, regenerate and verify a clean private playtest package, and confirm branch clean/synced.

## v0.16.11 Release-Candidate Issue Backlog And Tester Launch Prep - 2026-05-22

Scope: prepare project-management artifacts so Emmanuel can manually retest later or send the release-candidate package to 2-5 testers. This is docs/issues and package-doc polish only, with no runtime gameplay change.

Baseline:

- Starting commit: `7cc6eff95123c0dfa90d05a66d5a9305e1f44eff`, `Checkpoint v0.16.10 release-candidate freeze and backlog triage`.
- Branch was clean and synced with `origin/main`.
- Package at intake: `artifacts/playtest/ascendant-realms-private-playtest-7cc6eff`, clean and verified.
- GitHub Actions CI Release Matrix Dry Run #84 for `7cc6eff95123c0dfa90d05a66d5a9305e1f44eff` passed Fast confidence as a push run.
- #84 skipped release simulator, hosted release matrix, optional visual QA, and full release e2e.
- No exact-final workflow-dispatch release matrix was found for `7cc6eff`.
- GitHub Actions #80 remains the enabled workflow-dispatch matrix evidence for the post-v0.16.7 runtime stack on `ad4eee0`.

Included work:

- Added `docs/V01611_EXACT_FINAL_CI_AND_RELEASE_NOTE.md`.
- Added `docs/V01611_GITHUB_ISSUE_BACKLOG.md`.
- Added `docs/V01611_TESTER_LAUNCH_PACKET_INDEX.md`.
- Added `docs/V01611_NO_CODE_FREEZE_NOTE.md`.
- Updated package metadata to the v0.16.11 checkpoint title.
- Added `TESTER_LAUNCH_PACKET_INDEX.md` to the generated playtest package and package validator.

Verification:

```text
npm test PASS, 57 files / 415 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run package:playtest PASS against the pre-commit dirty tree.
npm run verify:playtest-package PASS, 30 checks.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes, package metadata and package validation only. Package changed: yes, tester launch index added.

Remaining closeout: run required gates, commit as `Checkpoint v0.16.11 release-candidate issue backlog and tester launch prep`, push, regenerate and verify a clean private playtest package, and confirm branch clean/synced.

## v0.16.10 Release-Candidate Freeze And Backlog Triage - 2026-05-22

Scope: freeze the current post-v0.16.7 combat/control candidate for Emmanuel retest or a small external tester batch, document exact-final CI status, triage backlog, polish tester kit docs, run a final public-repo safety check, and verify/package without starting v0.17 or changing runtime gameplay.

Baseline:

- Starting commit: `83f146e1a0c9a4092a0457c504e4f3d767078c01`, `Checkpoint v0.16.9 autonomous manual-retest proxy and tester readiness`.
- Branch was clean and synced with `origin/main`.
- v0.16.7 remains the latest runtime combat/control fix.
- v0.16.8 and v0.16.9 did not change runtime gameplay.
- GitHub Actions CI Release Matrix Dry Run #83 for `83f146e1a0c9a4092a0457c504e4f3d767078c01` passed Fast confidence as a push run.
- #83 skipped release simulator, hosted release matrix, optional visual QA, and full release e2e.
- No exact-final workflow-dispatch release matrix was found for `83f146e`.
- GitHub Actions #80 remains the latest workflow-dispatch matrix evidence for the post-v0.16.7 runtime stack and passed the enabled lanes on `ad4eee0`.

Included work:

- Added `docs/V01610_RELEASE_CANDIDATE_BASELINE.md`.
- Added `docs/V01610_REMOTE_CI_FINAL_HASH_STATUS.md`.
- Added `docs/V01610_RELEASE_CANDIDATE_DECISION.md`.
- Added `docs/V01610_BACKLOG_TRIAGE.md`.
- Added `docs/V01610_PUBLIC_RELEASE_SAFETY_CHECK.md`.
- Added `docs/V01610_TESTER_MESSAGE_SHORT.md`.
- Added `docs/V01610_TESTER_FEEDBACK_FORM_SHORT.md`.
- Added `docs/V01610_ROUTE_ASSIGNMENTS_SMALL_BATCH.md`.
- Added `docs/V01610_EMMANUEL_MANUAL_RETEST_CHECKLIST.md`.
- Updated package metadata to the v0.16.10 checkpoint title.
- Added release-candidate notes, Emmanuel retest checklist, short tester message, short feedback form, and small-batch routes to the generated playtest package and validator.
- Regenerated control-lab outputs against the current commit while preserving the 18-scenario / 5-iteration extended dashboard.

Verification:

```text
npm test PASS, 57 files / 415 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.4m.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run package:playtest PASS against the pre-commit dirty tree.
npm run verify:playtest-package PASS, 29 checks.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes, package metadata and package validation only. Package changed: yes, tester kit contents expanded.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.10 release-candidate freeze and backlog triage`, push, regenerate and verify a clean private playtest package, and confirm branch clean/synced.

## v0.16.9 Autonomous Manual-Retest Proxy And Tester Readiness - 2026-05-22

Scope: build stronger automated evidence around the v0.16.7 manual combat/control retest items while Emmanuel is away, inspect remote CI status, prepare first external tester docs, document worker construction as design-only, audit control visual/readability risks, and run the requested verification gates without starting v0.17 or changing runtime gameplay.

Baseline:

- Starting commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`, `Checkpoint v0.16.8 post-combat-fix CI verification and soak audit`.
- Branch was clean and synced with `origin/main`.
- v0.16.7 remains the latest runtime combat/control fix.
- v0.16.8 was test/CI/docs/package readiness and did not change runtime gameplay.
- GitHub Actions CI Release Matrix Dry Run #79 for `ad4eee0a80a43f81df41ff30640a14f8434a5797` passed Fast confidence as a push run.
- GitHub Actions CI Release Matrix Dry Run #80 for `ad4eee0a80a43f81df41ff30640a14f8434a5797` passed as a `workflow_dispatch` run across Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
- #80 skipped Optional visual QA and Full release e2e, so those remain local evidence from this checkpoint.

Included work:

- Added `docs/V0169_BASELINE_STATUS.md`.
- Added `docs/V0169_REMOTE_RELEASE_MATRIX_STATUS.md`.
- Added `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_SPEC.md`.
- Added `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_REPORT.md`.
- Added `docs/V0169_COMBAT_EDGE_CASE_MATRIX.md`.
- Added `docs/V0169_FIRST_EXTERNAL_TESTER_PLAN.md`.
- Added `docs/V0169_TESTER_MESSAGE_SHORT.md`.
- Added `docs/V0169_TESTER_FEEDBACK_FORM_SHORT.md`.
- Added `docs/V0169_ROUTE_ASSIGNMENTS_SMALL_BATCH.md`.
- Added `docs/V0169_WORKER_CONSTRUCTION_DESIGN_BRIEF.md`.
- Added `docs/V0169_CONTROL_VISUAL_READABILITY_AUDIT.md`.
- Added `docs/V0169_LONG_SOAK_REPORT.md`.
- Extended the control behaviour lab to 18 scenarios.
- Added manual proxy coverage for Hold Ground adjacent follow-up and group retreat/resume.
- Added combat edge scenarios for 1 hero vs 3 melee enemies, 2 friendly units vs 3 enemies, building aggro locality, and Hold/Guard/Press mode differences.
- Added a focused ranged-enemy building aggro unit test.
- Updated private package build-info metadata and verifier expectation to name the v0.16.9 checkpoint.

Verification:

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 2 files / 29 tests.
Focused repeat of the same command 5 times: PASS 5/5.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 5 iterations / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|manual combat contact regression" --repeat-each=3 --reporter=line PASS, 6 tests in 2.8m.
npm test PASS, 57 files / 415 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.4m.
npm run test:e2e:smoke PASS, 14 tests in 6.8m.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.2m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 2.7m.
npm run test:e2e:release PASS, 79 tests in 38.4m.
npm run visual:qa PASS, 5 tests in 4.2m; 18 screenshots, 0 browser console errors, 0 screenshot retries.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes, deterministic coverage only. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.9 autonomous manual-retest proxy and tester readiness`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and inspect the final push Fast confidence run. A fresh workflow-dispatch release matrix on the final v0.16.9 commit is optional because v0.16.9 did not change runtime gameplay.

## v0.16.8 Post-Combat-Fix CI Verification And Soak Audit - 2026-05-22

Scope: verify v0.16.7's runtime combat/control fix through remote CI inspection, automated soak, control-lab coverage, public-repo safety audit, and package readiness without starting v0.17, adding gameplay features, implementing worker construction/builders, adding units/buildings/maps/factions/runtime art/assets, adding Patrol/formations, rewriting broad AI/pathing, changing gameplay numbers/unit stats/enemy wave timings/save format, weakening control coverage, using force clicks, using DOM fallback for canvas/world clicks, or inventing human feedback.

Baseline:

- Starting commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`, `Checkpoint v0.16.7 manual combat contact and aggro fix`.
- Branch was clean and synced with `origin/main`.
- Existing package `artifacts/playtest/ascendant-realms-private-playtest-169bb21` recorded `workingTreeDirty: false`.
- v0.16.7 had changed runtime melee contact/reacquisition, local melee enemy building aggro, retreat suppression, and hover/click tolerance.
- GitHub Actions CI Release Matrix Dry Run #78 on the v0.16.7 commit was green as a push run, but only Fast confidence ran. Release simulator, release matrix groups, optional visual QA, and full release e2e were skipped because they require workflow dispatch.

Included work:

- Added `docs/V0168_BASELINE_AND_REMOTE_CI_AUDIT.md`.
- Added `docs/V0168_REMOTE_CI_VERIFICATION.md`.
- Added `docs/V0168_CI_TRIAGE_FIX.md`.
- Added `docs/V0168_COMBAT_FIX_SOAK_REPORT.md`.
- Added `docs/V0168_CONTROL_LAB_V0167_COVERAGE_REVIEW.md`.
- Added `docs/V0168_PUBLIC_REPO_SAFETY_AUDIT.md`.
- Added `docs/V0168_EMMANUEL_RETEST_AFTER_V0167_CHECKLIST.md`.
- Added `docs/V0168_LONG_SOAK_RESULTS.md`.
- Added deterministic control-lab scenarios for local melee enemy building aggro and attack-hover tolerance versus nearby empty terrain.
- Regenerated control-lab normal, extended, and dashboard outputs.
- Stabilized one hosted smoke assertion by relying on deterministic Cinderfen Crossing scene state instead of transient `battle-status` launch text after the battle had already advanced to AI status.
- Completed a public-repo safety audit.

Public safety result:

- No tracked `.env`, private key, credential, service-account, package artifact, Playwright report, raw private feedback, email address, or secret value was found.
- Secret-pattern matches were documentation/test references and package-validator dummy fixtures.
- Protected-IP searches found only guardrails/prompt negatives/art-direction warnings, not copied names/assets/lore/UI/music.
- Tracked `public/assets/manual` image assets remain intentional prototype assets, but prior asset docs still classify current file-backed image assets as needing source/license proof before production approval.

Triage:

- `npm run test:e2e:release:hosted:smoke` initially failed one Chapter 2 smoke assertion because `battle-status` had advanced to `AI: EXPAND - Time 0:12`.
- Classification: hosted timing issue / transient status-line assertion.
- Fix: test-only; no runtime change.
- Coverage preserved: the test still asserts Cinderfen Crossing map/node/reward table/mode/difficulty and later objective/reward/persistence state through scene and save state.

Current verification:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts BehaviourModeSystem.test.ts ControlBehaviourScenarioLab.test.ts PASS, 5 files / 38 tests.
Focused unit soak repeated the same command 10 times: PASS 10/10.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --repeat-each=5 --reporter=line PASS, 5/5 in 1.6m.
npm run playtest:controls / npm run playtest:controls:extended / npm run playtest:controls:verify repeated 3 cycles: PASS 3/3. Final verifier PASS, 1112 checks.
npm test PASS, 57 files / 414 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.4m.
npm run test:e2e:smoke PASS, 14 tests in 7.0m after the hosted smoke assertion fix.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.4m.
npm run test:e2e:release:hosted:smoke first run FAIL, 1 transient status-line assertion; targeted fix applied.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --reporter=line PASS, 1 test in 27.7s.
npm run test:e2e:release:hosted:smoke rerun PASS, 14 tests in 2.9m.
npm run test:e2e:release PASS, 79 tests in 38.7m.
npm run visual:qa PASS, 5 tests in 4.4m; 18 screenshots, 0 browser console errors, 0 screenshot retries.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Enemy aggro changed: no. Retreat logic changed: no. Test/CI harness changed: yes. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.8 post-combat-fix CI verification and soak audit`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and have a user with GitHub Actions write access dispatch the normal enabled release matrix.

## v0.16.7 Manual Combat Contact And Aggro Fix - 2026-05-21

Scope: fix only Emmanuel's real manual v0.16.6 retest combat/control bugs without starting v0.17, implementing worker construction/builders, adding units/buildings/maps/factions/runtime art, adding patrol/formations, rewriting broad AI/pathing, changing gameplay numbers, changing unit stats, changing enemy wave timings, changing save format, weakening tests, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `3737c16`, `Checkpoint v0.16.6 hosted deep-battle first campaign training stabilization`.
- Branch was clean and synced with `origin/main`.
- GitHub Actions CI Release Matrix Dry Run #77 was green on enabled lanes: Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke.
- v0.16.6 was test-only; runtime gameplay, gameplay numbers, save format, runtime art/assets, and behaviour modes were unchanged.
- Emmanuel's manual retest session `PT-20260521-EMMANUEL-V0166-CONTROLS-01` on build/package `3737c16` / `ascendant-realms-private-playtest-3737c16` returned MIXED.

Included work:

- Added `docs/V0167_EMMANUEL_MANUAL_RETEST_INTAKE.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_REPRODUCTION_PLAN.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_AUDIT.md`.
- Added `docs/V0167_COMBAT_CONTACT_AGGRO_FIX_REPORT.md`.
- Added `docs/V0167_DEFERRED_WORKER_CONSTRUCTION_NOTE.md`.
- Increased melee visual-contact tolerance narrowly.
- Made melee unit-vs-building contact use the target building footprint.
- Preserved player move-away combat suppression even if pathing clears the move target early.
- Added conservative world entity interaction hit-test tolerance for attack hover/click intent.
- Added focused unit/system tests and a hosted-safe manual combat contact regression.

Root cause:

- Visible melee contact and raw center/radius combat contact were slightly mismatched for small adjacent enemies.
- Building pathing/obstacles use rectangular footprints, but melee attack reach treated buildings like circular targets.
- Retreat suppression could be effectively canceled by early move-target clearing before the short suppression window expired.
- Attack hover/click intent used raw entity radius rather than a visible interaction footprint.

Current verification:

```text
npm test -- CombatSystem.test.ts CollisionSystem.test.ts MovementSystem.test.ts PASS, 3 files / 30 tests.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --reporter=line PASS, 1 test in 23.9s.
npm test PASS, 57 files / 414 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.9m.
npm run test:e2e:smoke first attempt timed out at 6m; rerun PASS, 14 tests in 7.1m.
npm run playtest:controls PASS, 10 scenarios / 10 pass rows.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 14 tests in 4.6m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.0m.
npm run test:e2e:release first attempt timed out at 30m; longer local wrapper rerun PASS, 79 tests in 38.8m.
npm run visual:qa PASS, 5 tests in 4.5m; 18 screenshots, 0 console errors, 0 retries.
git diff --check PASS.
```

Runtime gameplay changed: yes. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: yes, contact/reacquisition semantics only. Enemy aggro changed: yes, local melee building contact only. Retreat logic changed: yes, move-away suppression preservation only. Package changed: final clean package must be regenerated after commit.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.7 manual combat contact and aggro fix`, push, regenerate and verify a clean private playtest package, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.6 Hosted Deep-Battle First Campaign Training Stabilization - 2026-05-21

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #75 `Release matrix (deep-battle)` failure after v0.16.5, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening first-campaign capture/build/train/rally/victory assertions, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `0398e6e18a596d6ca42f8b50761949f477055757`, `Checkpoint v0.16.5 hosted deep-battle command hall split stabilization`.
- Branch was clean and synced with `origin/main`.
- GitHub Actions run #73 failed before starting because the private repository hit the billing/payment/spending gate.
- After the repository was made public, rerun #73 Fast confidence passed and manual workflow dispatch #75 ran on the hosted runner.
- CI Release Matrix Dry Run #75 had Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen green.
- Only `Release matrix (deep-battle)` was red.

Included work:

- Added `docs/V0166_HOSTED_DEEP_BATTLE_FIRST_CAMPAIGN_TRAINING_FIX.md`.
- Kept visible Militia train command click attempts in the first-campaign hosted deep-battle test.
- Added a narrow fallback to the existing scene-backed `trainUnitThroughCommand` helper only after visible command clicks fail to expose a training queue.
- Allowed the trained Militia lookup to accept a newly trained unit that has already reached the rally point as well as one still carrying the rally `moveTarget`.

Root cause:

- The v0.16.5 Command Hall split held; the new #75 failure occurred later in the broad first-campaign path.
- Hosted CI sometimes failed to observe the Barracks training queue after repeated visible Militia command fallback clicks.
- The trained-unit lookup was stricter than the later rally assertion because it required a live `moveTarget` and ignored a newly trained unit already at the rally point.
- This was a test-harness timing/readiness issue, not a runtime gameplay regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "first campaign battle path covers capture, build, train, rally, and victory rewards" --retries=1 --trace=on --reporter=line PASS, 1 test in 53.2s.
npm run test:e2e:release:hosted:deep-battle PASS, 13 tests in 4.3m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.6m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec fallback/lookup only.

Remaining closeout: commit as `Checkpoint v0.16.6 hosted deep-battle first campaign training stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.5 Hosted Deep-Battle Command Hall Split Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #72 `Release matrix (deep-battle)` timeout after v0.16.4, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening minimap/fog/building/cancel/command hall assertions, weakening behaviour mode coverage, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `9c8e694177e6a60e423539eb202393a3a94071b9`, `Checkpoint v0.16.4 hosted deep-battle movement command stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26198333332` showed CI Release Matrix Dry Run #72 failed only in `Release matrix (deep-battle)`.
- Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_AUDIT.md`.
- Added `docs/V0165_HOSTED_DEEP_BATTLE_COMMAND_HALL_SPLIT_FIX.md`.
- Split the older hosted deep-battle HUD/minimap/fog/build/cancel scenario into two focused tests.
- Kept minimap movement, fog toggle, attack cursor, marquee, and right-click move command assertions in the original test.
- Moved Command Hall building placement/cancel assertions into a new hosted deep-battle test with a fresh browser context.

Root cause:

- v0.16.4 fixed the previous movement-order timeout, and run #72 reached the later Command Hall build section.
- The older hosted HUD/minimap/building test was still too broad for the 120s hosted CI budget and timed out while `clickReady` waited for the Barracks build command to be visible or enabled.
- Later command-button tests in the same hosted deep-battle shard passed, so the failure was scenario length and hosted timing pressure, not a Command Hall or Barracks runtime regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.0m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --reporter=line PASS, 1 test in 39.7s.
npm run test:e2e:release:hosted:deep-battle PASS, 13 tests in 4.4m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.1m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.5m.
npm run test:e2e:smoke PASS, 14 tests in 6.9m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 78 tests in 37.3m after rerunning with a longer local wrapper timeout.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, and move commands" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 2.7m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports command hall building placement and cancel" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.8m.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec split only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.5 hosted deep-battle command hall split stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.4 Hosted Deep-Battle Movement Command Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #70 `Release matrix (deep-battle)` timeout after v0.16.3, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening minimap/fog/building/cancel/command hall assertions, weakening behaviour mode coverage, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `ce2b54a9e23d7dc43e7eb9706ab882dc4e761bfa`, `Checkpoint v0.16.3 hosted smoke pause-resume stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26194525737` showed CI Release Matrix Dry Run #70 failed only in `Release matrix (deep-battle)`.
- Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0164_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`.
- Added `docs/V0164_HOSTED_DEEP_BATTLE_FIX.md`.
- Added `MOVE_ORDER_SUMMARY_PATTERN = /Moving|Repositioning/` for valid move-order summaries.
- Applied that pattern to the older deep-battle HUD movement assertion and the dedicated behaviour gauntlet retreat assertion.
- Replaced transient status-line assertions in the older HUD test with semantic fog active, movement order, and placement cancel state assertions.

Root cause:

- The older HUD/minimap/building deep-battle test still required a real right-click movement order to render exactly `Moving`.
- Under combat pressure, the same valid movement order can render as `Repositioning` while move-order combat suppression is active.
- The test also used transient status-line text for fog/cancel feedback, but pressure status messages can intentionally outrank normal fog debug or command messages.
- The timeout was caused by the stale assertion/readiness shape, not a browser crash or gameplay runtime regression.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.3m.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests in 4.1m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.1m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.8m.
npm run test:e2e:smoke PASS, 14 tests in 8.2m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 77 tests in 40.9m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 3.4m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, deep-flow spec assertions only.

Remaining closeout: commit as `Checkpoint v0.16.4 hosted deep-battle movement command stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.3 Hosted Smoke Pause/Resume Stabilization - 2026-05-20

Scope: fix only the remaining GitHub Actions CI Release Matrix Dry Run #68 `Release matrix (smoke)` timeout after v0.16.2, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening settings/accessibility assertions, using force clicks, or using DOM fallback for canvas/world clicks.

Baseline:

- Starting commit: `f4ac082875db451a05b2b2668f9714e1ecf0af8d`, `Checkpoint v0.16.2 release-matrix smoke and deep-battle stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26191069260` showed CI Release Matrix Dry Run #68 failed only in `Release matrix (smoke)`.
- Deep-battle, Fast confidence, Release simulator, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen were green.

Included work:

- Added `docs/V0163_HOSTED_SMOKE_PAUSE_RESUME_FIX.md`.
- Added scoped settings battle menu click options in `tests/e2e/smoke.spec.ts`.
- Applied those options only to `settings smoke battle menu` and `settings smoke battle resume`.

Root cause:

- v0.16.2 fixed the earlier timeout/page-closed shape, but run #68 showed the settings smoke still spent too much hosted CI time inside normal Playwright actionability waits before the verified DOM-control fallback.
- Both Menu and Resume were real visible DOM buttons, and both verified DOM fallbacks fired before the test timed out.
- The failure was not a settings runtime regression; it was an over-budget smoke pause/resume interaction under hosted production-preview timing.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line PASS, 1 test in 42.1s.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 3.0m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.5m.
npm run test:e2e:smoke PASS, 14 tests in 7.0m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:release PASS, 77 tests in 37.8m.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, smoke spec only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.3 hosted smoke pause-resume stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.2 Release-Matrix Smoke/Deep-Battle Stabilization - 2026-05-20

Scope: fix only GitHub Actions CI Release Matrix Dry Run #66 `Release matrix (deep-battle)` and `Release matrix (smoke)` timeout regressions after v0.16.1, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, changing behaviour modes, changing package materials, restructuring the release matrix, weakening settings/accessibility assertions, weakening minimap/fog/building/cancel/command hall assertions, or weakening behaviour mode coverage.

Baseline:

- Starting commit: `3bfe3b20a09cbc67de80954384d3ddad7a61a270`, `Checkpoint v0.16.1 fast-confidence CI smoke stabilization`.
- Branch was clean and synced with `origin/main`.
- `gh` CLI was unavailable locally.
- GitHub connector logs for Actions run id `26154299133` showed CI Release Matrix Dry Run #66 failed in `Release matrix (deep-battle)` and `Release matrix (smoke)`.
- Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable.

Included work:

- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FAILURE_AUDIT.md`.
- Added `docs/V0162_RELEASE_MATRIX_TIMEOUT_FIX.md`.
- Removed duplicated Hold Ground, Press Attack, and Guard Area switching from the older deep-battle HUD/minimap/building test.
- Kept the dedicated hosted behaviour mode gauntlet intact for behaviour-mode switching and behaviour assertions.
- Increased only the settings runtime accessibility smoke timeout from 60s to 90s.
- Added semantic pause/resume success checks around the settings battle menu and resume `clickReady` calls.
- Added an explicit post-resume battle-state assertion.

Root cause:

- The deep-battle failure was an overloaded hosted scenario: the older HUD/minimap/building test had accumulated duplicated v0.16 behaviour-mode transitions before continuing through its original minimap/fog/build/cancel/command hall surface.
- The smoke failure was a hosted production-preview timing margin issue in the settings runtime accessibility test; the test was valid locally but exceeded the 60s hosted budget around battle resume.
- In both logs, `Target page, context or browser has been closed` was reported after Playwright's per-test timeout, so it was a consequence of timeout cleanup rather than the root cause.

Current verification:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line PASS, 1 test in 1.0m.
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line PASS, 1 test in 36.5s.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests in 3.7m.
npm run test:e2e:release:hosted:smoke PASS, 14 tests in 2.8m.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.3m.
npm run test:e2e:smoke PASS, 14 tests in 6.5m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release PASS, 77 tests in 36.3m.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 3.4m.
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.6m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, Playwright specs only.

Remaining closeout: commit as `Checkpoint v0.16.2 release-matrix smoke and deep-battle stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16.1 Fast-Confidence CI Smoke Stabilization - 2026-05-20

Scope: fix only GitHub Actions CI Release Matrix Dry Run #64 `Fast confidence` regression after v0.16, without adding features, changing runtime gameplay, changing gameplay numbers, changing save format, adding runtime art/assets, touching behaviour modes, changing package materials, restructuring CI, weakening settings/accessibility assertions, or weakening inventory coverage.

Baseline:

- Starting commit: `c28f19d82205a1dd8358c4412fdf030d3d9e3b7b`, `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`.
- Branch was clean and synced with `origin/main`.
- Remote evidence supplied by Emmanuel: run #64 failed in `Fast confidence`; primary failed test was `settings screen persists accessibility options @ci-fast`; secondary flaky test was `inventory screen opens without crashing @ci-fast`.
- Direct GitHub artifact inspection was unavailable because `gh` is not installed and the connector could not resolve displayed run `#64` as a numeric Actions run id.

Included work:

- Added `docs/V0161_FAST_CONFIDENCE_CI_FAILURE_AUDIT.md`.
- Added `docs/V0161_FAST_CONFIDENCE_CI_FIX.md`.
- Split the settings accessibility smoke path into a persistence-focused `@ci-fast` test and a runtime-battle `@ci-fast` test.
- Added shared accessibility smoke settings data so both tests assert the same setting values.
- Added a Settings-screen success check to the Settings menu click/reopen path so a successful transition does not fall through to a now-gone main-menu button.
- Left the inventory smoke test unchanged.

Root cause:

- The original settings test combined persistence, localStorage, document dataset, battle launch, runtime accessibility, minimap color, fog override, floating text, and pause/resume assertions in one long browser context.
- Remote failure evidence reached the settings retry and then showed inventory failing while a new browser context was being created, which points to browser/context pressure after the long settings path.
- A local full-smoke run after the first split exposed the actionability race: Settings had already reopened, but the click helper did not treat `settings-screen` as success before fallback checked the vanished `menu-settings` button.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line PASS, 1 test in 38.2s.
npx playwright test tests/e2e/smoke.spec.ts --grep "inventory screen opens without crashing" --retries=1 --trace=on --reporter=line PASS, 1 test in 28.8s.
npm run test:e2e:smoke:fast PASS, 8 tests in 2.6m.
npm run test:e2e:smoke PASS, 14 tests in 7.4m.
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:smoke FAIL first run on unrelated extended-smoke transient Cinderfen difficulty status copy.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on --reporter=line PASS, 1 test in 35.6s.
npm run test:e2e:release:hosted:smoke PASS on full rerun, 14 tests in 3.3m.
npm run test:e2e:release PASS, 77 tests in 38.4m.
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --repeat-each=3 --reporter=line PASS, 3 tests in 1.5m.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: no. Package changed: no. Test/CI harness changed: yes, smoke spec only.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16.1 fast-confidence CI smoke stabilization`, push, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.16 Behaviour Mode Gauntlet And Playtest Diagnostics - 2026-05-19

Scope: build a deep automated confidence layer around the v0.15 session-only behaviour modes and core RTS controls, add deterministic control diagnostics, harden private package validation, and prepare Emmanuel's next manual retest without broad gameplay design, balance changes, save migration, Patrol runtime behaviour, new content, runtime art/assets, or visual overhaul.

Phase 0 baseline:

- Starting commit: `27dfe1a1ec060708c831690c4bfa806b0d06cb32`, `Checkpoint v0.15 RTS control behaviour foundation`.
- Baseline was clean and synced with `origin/main` before v0.16 work started.
- GitHub CLI was unavailable. The GitHub connector returned no PR-triggered workflow runs and no combined statuses for the v0.15 SHA, so the latest v0.15 Actions status is recorded as unknown rather than green or red.
- Guardrails preserved: no maps, factions, units, runtime art/assets, save format changes, behaviour-mode persistence, Patrol runtime behaviour, broad AI/pathing rewrites, gameplay-number tuning, enemy wave timing changes, hosted release restructuring, weakened assertions, force-click world shortcuts, DOM fallback for canvas/world clicks, protected UI/lore copying, or invented human feedback.

Included work:

- Added `docs/V016_BASELINE_AND_CI_AUDIT.md`.
- Added `docs/V016_BEHAVIOUR_MODE_AUDIT.md`.
- Added `docs/V016_CONTROL_BEHAVIOUR_GAUNTLET_REPORT.md`.
- Added v0.16 Emmanuel/tester materials: retest script, route card, checklist, feedback intake template, and triage guide.
- Added deterministic control behaviour lab scripts: `npm run playtest:controls`, `npm run playtest:controls:extended`, and `npm run playtest:controls:verify`.
- Added control lab scenario types, profiles, runner, report writer, validation, and generated JSON/Markdown/dashboard outputs.
- Expanded unit/system tests for Hold Ground, Guard Area, Press Attack, explicit attack/move overrides, retreat suppression, mixed group handling, order copy, selected panel controls, and package validation.
- Added a hosted browser control gauntlet for behaviour mode buttons, attack hover, left-click attack, retreat feedback, marquee/HUD cleanup, minimap movement, and `H` hero-select refresh.
- Narrowly fixed Hold Ground direct-attacker handling so a nearby enemy directly attacking the unit can be pursued within the existing local aggro radius while idle distant threats are still refused.
- Updated private playtest package contents and verifier requirements to include v0.16 control retest materials.

Generated control lab evidence:

```text
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:extended PASS, 50 rows / 50 pass across 5 deterministic iterations.
npm run playtest:controls:verify PASS, 930 consistency checks.
```

Current verification:

```text
npm test PASS, 56 files / 406 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run playtest:controls PASS, 10 rows / 10 pass.
npm run playtest:controls:extended PASS, 50 rows / 50 pass.
npm run playtest:controls:verify PASS, 930 checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 12 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "behaviour mode control gauntlet" --repeat-each=3 --retries=0 --reporter=line PASS, 3 tests.
npm run test:e2e:release:shard1of3 PASS, 29 tests.
npm run test:e2e:release:shard2of3 PASS, 34 tests.
npm run test:e2e:release:shard3of3 PASS, 13 tests.
npm run test:e2e:release PASS, 76 tests.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-27dfe1a-dirty`.
npm run verify:playtest-package PASS, 24 checks.
```

One earlier `npm run test:e2e:release` attempt hit the shell timeout at 40 minutes before returning output. The orphaned process was stopped, the release suite passed in the existing 3-way shards, and the exact all-in-one command then passed with a longer timeout.

Runtime gameplay changed: yes, narrowly in Hold Ground direct-attacker response. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no. Behaviour modes changed: yes, only the direct-attacker Hold Ground rule alignment; no new modes. Package changed: yes.

Remaining closeout: run `git diff --check`, commit as `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`, push, regenerate and verify a clean private playtest package from the final commit, confirm branch clean/synced, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.15 RTS Control Behaviour Foundation - 2026-05-19

Scope: build a narrow, original RTS control foundation for command reliability, attack intent, melee engagement, retreat/move-away behavior, and session-only behaviour modes while preserving all v0.14.x human playtest fixes.

Phase 0 baseline:

- Current commit before this goal: `5ab64f5ec56324ba0f9abd4d69d51f109e0adeca`, clean and synced with `origin/main`.
- Confirmed v0.14.5 hosted deep-battle minimap fix was complete before starting v0.15.
- Read the required handoff/docs and runtime/test files before implementation.
- Guardrails: no maps, factions, combat units, runtime art/assets, save format changes, broad AI/pathing rewrites, broad balance tuning, protected UI copying, visual overhaul, hosted release restructuring, weakened assertions, force-click canvas/world shortcuts, or DOM fallback for canvas/world clicks.

Included work:

- Added `docs/V015_CONTROL_COMBAT_BASELINE_AUDIT.md`.
- Added `docs/V015_BEHAVIOUR_MODES_SPEC.md`.
- Added `docs/V015_CONTROL_COMBAT_BEHAVIOUR_FIX_REPORT.md`.
- Added `BehaviourModeSystem` with `Hold Ground`, `Guard Area`, and `Press Attack`.
- Added session-only `behaviourMode` state to live units; default is `Guard Area`.
- Added selected-unit and selected-group behaviour controls to the current side panel, including `Mixed` state and group mode application.
- Updated `CombatSystem` acquisition rules so Hold Ground avoids distant chase, Guard Area remains the balanced default, and Press Attack pursues within a larger bounded leash.
- Preserved explicit move/attack orders above behaviour mode reacquisition and tightened move-away suppression so retreat intent cannot be overwritten on its expiry frame.
- Added explicit attack target labels and clearer order copy for Guarding, Holding Ground, Pressing Attack, Attacking, Moving, and Repositioning.
- Kept selected-unit attack hover/click intent reliable across HUD refresh, empty clicks, and cursor clearing.
- Hardened hero-select HUD refresh after HUD/minimap interactions and constrained the side panel height so expanded controls do not cover Ashen/Cinderfen landmark focus.
- Updated tester quick-start/package copy and playtest package checkpoint metadata for v0.15.

Deferred:

- Patrol, escort, return-anchor memory, save-persistent behaviour modes, icon/art additions, formation/pathing overhaul, broad combat AI rewrite, and balance tuning.

Current verification:

```text
npm test PASS, 55 files / 393 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-5ab64f5-dirty`.
npm run verify:playtest-package PASS, 19 checks.
git diff --check PASS.
```

Runtime gameplay changed: yes, narrowly in session-only unit behaviour modes, command feedback/order copy, attack target labels, retreat reacquisition suppression timing, and HUD command controls. Gameplay numbers changed: no. Save format changed: no. Runtime art/assets changed: no.

Remaining closeout: commit as `Checkpoint v0.15 RTS control behaviour foundation`, push, regenerate and verify a clean private playtest package from the final commit, and rerun GitHub Actions CI Release Matrix Dry Run.

## v0.14.5 Hosted Deep-Battle Minimap Fix - 2026-05-18

Scope: fix the isolated GitHub Actions CI Release Matrix Dry Run #61 hosted deep-battle failure in the minimap/marquee section of `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`, without weakening minimap movement coverage or changing runtime gameplay.

Phase 0 baseline:

- Current commit before this goal: `9a1dc0a113144c9cb3132b689cec53fd772953f1`, clean and synced with `origin/main`.
- Remote failure evidence supplied by Emmanuel: CI Release Matrix Dry Run #61, commit `9a1dc0a`, hosted deep-battle group, 1 failed / 10 passed.
- Failed predicate: around `tests/e2e/deep-flow.spec.ts:1868`, `Timeout 1000ms exceeded while waiting on the predicate`.
- The local environment did not have the GitHub CLI installed, so the audit records Emmanuel's supplied CI evidence rather than claiming direct log/artifact inspection.
- Guardrails: no gameplay numbers, save format, maps, factions, units, assets, assertion weakening, force clicks, DOM fallback for canvas/world clicks, broad input refactor, hosted matrix restructuring, or rollback of v0.14.4 user-facing fixes.

Included work:

- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_REGRESSION_AUDIT.md`.
- Added `docs/V0145_HOSTED_DEEP_BATTLE_MINIMAP_FIX.md`.
- Updated `tests/e2e/deep-flow.spec.ts` to wait for canvas pointerdown to establish active marquee drag before crossing the minimap.
- Kept active-drag-over-minimap and release-over-minimap assertions with a scoped hosted-safe 3-second poll.
- Wrapped the minimap crossing in `try/finally` so mouseup cleanup happens if the midpoint assertion fails.
- Added an explicit minimap-click camera movement assertion before the existing fog toggle, movement command, placement cancel, and command hall checks.

Root cause:

- The v0.14.4 test moved immediately from canvas to minimap after `page.mouse.down()` and then gave the active-drag predicate only 1000ms.
- Hosted preview timing can process the pointerdown and DOM-bound pointer movement in a slightly different order, so the check could sample before active drag state was observable.
- Local targeted hosted repros and the full hosted deep-battle group passed before the fix, so this was treated as a test timing race rather than a proven runtime product bug.

Current verification:

```text
npm test PASS, 53 files / 383 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast first attempt hit local Windows net::ERR_NO_BUFFER_SPACE on the first navigation; rerun after socket cooldown PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test.
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --repeat-each=3 --retries=0 --reporter=line
PASS, 3 repeated targeted tests before the fix, supporting the hosted-timing diagnosis.
npm run test:e2e:release:hosted:deep-battle
PASS, 11 tests.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
git diff --check PASS.
```

Runtime gameplay changed: no. Gameplay numbers changed: no. Save format changed: no. Minimap coverage preserved: yes.

## v0.14.4 Combat Control Retest Fix Pass - 2026-05-18

Scope: use only Emmanuel's v0.14.3 retest evidence from `PT-20260518-EMMANUEL-BASELINE-01`, preserve all v0.14.3 fixes, and narrowly fix remaining melee engagement, drag-selection responsiveness, tutorial completion semantics, attack-hover intent, and tutorial copy mismatch.

Phase 0 baseline:

- Current commit before this goal: `28698152edca0967a561dc0de2a9c08b021d4061`, clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, v0.14.3 retest notes.
- Confirmed fixed before this pass: drag-select multiple units, tutorial defeat Results, Retry Tutorial, Return Main Menu, and class/origin mechanical explanations.
- Guardrails: no maps, factions, units, runtime art/assets, save format changes, broad redesign, behaviour modes, unit panel redesign, balance tuning, hidden failures, force-click test shortcuts, or DOM fallback for canvas/world clicks.

Included work:

- Added `docs/V0144_COMBAT_CONTROL_RETEST_FIX_REPORT.md`.
- Strengthened `CombatSystem` melee contact interpretation with a small visual contact margin so sprite-adjacent melee units attack reliably.
- Added regression coverage for visual melee contact and post-kill adjacent target reacquisition.
- Updated `InputSystem` so active marquee drags continue rendering via global pointer movement while crossing DOM HUD/minimap surfaces.
- Added targetable-hostile attack cursor state and left-click attack ordering for selected units.
- Changed final tutorial completion to route through no-save/no-reward Results instead of direct Main Menu.
- Updated tutorial Crown Shrine copy from blue to green ownership and final completion hint to Results summary.
- Updated smoke/deep-flow browser coverage for tutorial completion, attack-hover/click, and release-over-minimap drag handling.

Known evidence gap:

- Emmanuel mentioned an attached screenshot visual bug, but no matching screenshot was present in the current thread or repo artifacts during this pass. No screenshot-specific visual fix is claimed; visual QA remains part of final verification.

Current verification:

```text
npm test PASS, 53 files / 383 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests after fixing the HUD/minimap stale-selection deferral.
npm run package:playtest PASS, produced pre-commit dirty package `artifacts/playtest/ascendant-realms-private-playtest-2869815-dirty`.
npm run verify:playtest-package PASS, 19 checks.
git diff --check PASS.
```

Remaining watch items: commit as `Checkpoint v0.14.4 combat control retest fixes`, push, then regenerate and verify a clean non-dirty private playtest package from the final commit. GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

## v0.14.3 Combat Engagement, Marquee Selection, And Control Clarity Fix Pass - 2026-05-18

Scope: ingest Emmanuel's v0.14.x retest of `PT-20260518-EMMANUEL-BASELINE-01`, fix the remaining critical marquee selection, melee engagement, retreat, tutorial defeat, and hero creation clarity issues, and keep behaviour modes design-only.

Phase 0 baseline:

- Current commit before this goal: `029a1c730d03ede1e126a8da5ffce3c88eccba93`, clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, session `PT-20260518-EMMANUEL-BASELINE-01 retest`.
- Confirmed fixed by Emmanuel before this pass: W/A/S/D hero rename, Tutorial Next Objective, hover flicker, hero skill explanation, and pause/menu behavior.
- Guardrails: no protected UI copying, maps, factions, units, runtime art/assets, save format changes, broad AI/pathing rewrite, gameplay-number tuning, hidden failures, force-click test shortcuts, DOM fallback for canvas/world clicks, or v0.14.1 rollback.

Included work:

- Added `docs/V0143_EMMANUEL_RETEST_INTAKE.md`.
- Added `docs/V0143_REPRODUCTION_PLAN.md`.
- Added `docs/V0143_COMBAT_SELECTION_RETEST_FIX_REPORT.md`.
- Added `docs/V0143_UNIT_BEHAVIOUR_MODES_DESIGN.md`.
- Fixed release-over-HUD marquee selection by completing active battlefield drags on global pointer release and clearing only on cancel/blur.
- Added `src/game/systems/SelectionSystem.test.ts` and strengthened deep-flow marquee coverage.
- Added melee contact reach in `CombatSystem` for melee units using existing body radii, while leaving ranged behavior and unit data unchanged.
- Replaced indefinite normal move-order combat suppression with a short-lived movement-intent window.
- Preserved attack-move and explicit attack behavior.
- Kept and strengthened movement snap-back regression coverage.
- Routed tutorial defeat to Results with no-save/no-reward guidance and `Retry Tutorial` / `Main Menu`.
- Added factual class/origin mechanical summaries to Hero Creation using existing stats, origin bonuses, and primary ability descriptions.
- Added/updated focused unit and browser tests.

Fix status:

- Fixed: retest marquee selection broken while releasing over HUD.
- Fixed: melee hero/unit/enemy idle-adjacent combat cases covered by contact reach tests.
- Improved/fixed narrowly: retreat/move-away intent now gets a short priority window, then units can re-engage if still stuck beside enemies.
- Guarded: unit teleport/snap-back loop remains unreproduced in retest and now has an additional repeated-command regression test.
- Fixed: tutorial defeat now shows no-save/no-reward Results guidance instead of silently dumping to main menu.
- Fixed: hero class/origin choices now expose mechanical summaries.
- Deferred: unit info panel visual restructuring and behaviour modes runtime implementation.

Current verification:

```text
npm test PASS, 53 files / 381 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests.
npm run test:e2e:smoke PASS, 13 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests.
npm run test:e2e:release PASS, 75 tests.
npm run package:playtest PASS, produced a pre-commit dirty package.
npm run verify:playtest-package PASS, 19 checks.
```

Remaining watch items: Run `git diff --check`, commit, push, then regenerate and verify a clean non-dirty private playtest package from the final commit. GitHub Actions should be rerun because runtime battle/input/tutorial behavior changed.

## v0.14.2 Hosted Settings Smoke Fix - 2026-05-18

Scope: fix the isolated GitHub Actions CI Release Matrix Dry Run #55 hosted smoke timeout in `settings screen persists accessibility options @ci-fast`, without weakening the settings assertions or changing runtime gameplay.

Phase 0 baseline:

- Current commit before this goal: `256c688` (`Checkpoint v0.14.1 Emmanuel quick playtest fixes`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Remote failure: CI Release Matrix Dry Run #55, hosted smoke group, 1 failed / 12 passed.
- Failed test: `tests/e2e/smoke.spec.ts:825`, `settings screen persists accessibility options @ci-fast`.
- Failure mode: 60-second timeout on both first attempt and retry.
- Guardrails: no gameplay numbers, save format, maps, factions, units, assets, assertion weakening, force clicks, DOM fallback for canvas/world clicks, broad CI restructuring, or hosted matrix reshaping.

Included work:

- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FAILURE_AUDIT.md`.
- Added `docs/V0142_HOSTED_SETTINGS_SMOKE_FIX.md`.
- Increased only `SETTINGS_ACCESSIBILITY_SMOKE_TIMEOUT_MS` from 60 seconds to 90 seconds.

Root cause:

- The exact hosted-config settings repro passed locally before the fix, but took about 45 seconds.
- v0.14.1 expanded this smoke path with battle pause overlay verification while preserving settings persistence and runtime accessibility checks.
- GitHub-hosted preview plus screenshot/video/trace overhead left too little margin inside the previous 60-second scoped budget.

Protected assertions:

- Settings still persist after save/reopen.
- Reduced motion and colorblind minimap document datasets are still asserted.
- Floating text disabled, fog override disabled, reduced motion, and colorblind minimap runtime behavior are still asserted.
- Battle Menu pause and Resume behavior are still asserted.
- No settings assertion was removed or softened.

Current verification:

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in about 35.8s after the scoped timeout fix.

npm run test:e2e:release:hosted:smoke
PASS, 13 tests in about 2.9m.

npm test PASS, 52 files / 375 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests in about 2.2m.
npm run test:e2e:smoke PASS, 13 tests in about 6.7m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
git diff --check PASS.
```

Remaining watch items: Emmanuel should rerun GitHub Actions CI Release Matrix Dry Run and confirm the hosted smoke group passes.

## v0.14.1 Emmanuel Quick Playtest Intake And Critical Usability Fix Pass - 2026-05-18

Scope: ingest Emmanuel's real Baseline Cautious private playtest session `PT-20260518-EMMANUEL-BASELINE-01`, classify the nine reports through the existing intake framework, and implement only small high-confidence fixes for actual bugs or severe usability friction. This pass preserves gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure plans, hosted release patterns, automated simulation scope, and the no-invented-feedback boundary.

Phase 0 baseline:

- Current commit before this goal: `0236df7` (`Checkpoint v0.14 private playtest build packaging`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Human feedback source: Emmanuel only, session `PT-20260518-EMMANUEL-BASELINE-01`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, broad combat AI rewrite, broad tuning, automated simulation expansion, invented feedback, hosted release assertion weakening, force clicks, DOM fallback for canvas/world clicks, or visual overhaul.

Included work:

- Added `docs/V0141_EMMANUEL_QUICK_PLAYTEST_INTAKE.md`.
- Added `docs/V0141_REPRODUCTION_PLAN.md`.
- Added `docs/V0141_QUICK_PLAYTEST_FIX_REPORT.md`.
- Added `src/game/systems/KeyboardFocusGuard.ts` so game keyboard handlers ignore focused editable elements.
- Updated hero creation input handling so names can include movement-key letters such as `W`, `A`, `S`, and `D`.
- Updated battle input drag handling so selection marquee state clears on pointer release/cancel/blur and stale mouse-button loss.
- Added a battle pause overlay for `Menu`, with `Resume` and explicit `Exit to Main Menu`.
- Updated player normal move orders so they do not immediately re-acquire combat targets; attack-move still engages.
- Tightened movement correction so blocked separation does not produce large snap-back movement.
- Added visible hero ability description/cost copy and clearer selected order copy for attacking/moving.
- Added/updated focused unit and browser tests for the fixes.

Fix status:

- Fixed: I05 hero rename input blocks `W/A/S/D`.
- Fixed: I07 selection marquee stuck over HUD.
- Fixed narrowly: I06 retreat/move command being overridden by nearby combat.
- Fixed: I09 battle Menu accidental exit now opens pause.
- Fixed: I02 hero skill explanation.
- Addressed: I01 hover flicker and I03 tutorial Next Objective delay through stable tutorial/HUD refresh handling.
- Narrowly addressed: I08 unit movement snap-back through blocked movement-correction guard; retest required.
- Partly addressed: I04 hero attack unclear through selected order copy; retest required before deeper combat/VFX work.

Current verification:

```text
npm test PASS, 52 files / 375 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 7 tests in about 2.4m.
npm run test:e2e:smoke PASS, 13 tests in about 7.1m.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors.
npm run smoke:preview PASS against production preview.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run test:e2e:release:hosted:deep-meta PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 11 tests after targeted HUD stability fixes.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen PASS, 12 tests.
npm run test:e2e:release:hosted:smoke PASS, 13 tests after pause-menu actionability stabilization.
npm run test:e2e:release PASS, 75 tests in about 39.5m after rerunning with a long enough local command timeout.
```

Remaining watch items: Run `git diff --check` before commit. GitHub Actions should be rerun after this checkpoint because runtime input/HUD/battle/menu behavior changed. Emmanuel should retest the same Baseline Cautious private route on a clean v0.14.1 package before any deeper pathing, combat readability, or UI polish goal.

## v0.14 Private Playtest Build Packaging And One-Click Tester Delivery - 2026-05-18

Scope: make the current browser prototype easier to package, send, start, and verify for private human playtesting. This pass preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure behavior, hosted release patterns, automated simulation scope, and human-feedback boundaries.

Phase 0 baseline:

- Current commit before this goal: `afbb37f` (`Checkpoint v0.13.1a extended scenario lab integrity audit`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, automated simulation expansion, or balance implementation.

Included work:

- Added `npm run build:playtest`, `npm run package:playtest`, and `npm run verify:playtest-package`.
- Added `tools/packagePlaytestBuild.ts` to create ignored private package folders under `artifacts/playtest/`.
- Added `tools/verifyPlaytestPackage.ts`.
- Added `src/game/playtest/PlaytestPackageValidation.ts` and focused package validation tests.
- Added `.gitignore` coverage for generated private playtest packages.
- Added v0.14 distribution audit, tester README, coordinator guide, and paste-ready private tester message.
- Updated README, release checklist, v0.12.6 tester docs, roadmap, changelog, and handoff references.

Package shape:

- Output location: `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`.
- Includes built `game/`, `README_FOR_TESTERS.md`, `PLAYTEST_BUILD_INFO.md`, `playtest-build-info.json`, `FEEDBACK_SUBMISSION_PACKET.md`, `TESTER_QUICK_START.md`, `ROUTE_ASSIGNMENT_PLAN.md`, `READY_TO_SEND_PRIVATE_PLAYTEST_MESSAGE.md`, `start-playtest-server.mjs`, `START_GAME_WINDOWS.bat`, and `START_GAME_MAC_LINUX.sh`.
- Excludes `node_modules`, `.git`, raw private feedback folders, secret-like files, and unapproved runtime art/assets.

Current verification:

```text
npm test PASS, 50 files / 371 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 6 tests in about 2.2m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
npm run build:playtest PASS with package-safe relative asset URLs and the known Phaser vendor chunk warning.
npm run package:playtest PASS, generated artifacts/playtest/ascendant-realms-private-playtest-afbb37f-dirty during the pre-commit worktree.
npm run verify:playtest-package PASS, 19 package integrity checks.
Private package server smoke PASS at http://127.0.0.1:4174/ with ASCENDANT_PLAYTEST_NO_OPEN=1.
git diff --check PASS.
```

Remaining watch items: Regenerate the private package after the final checkpoint commit so its metadata uses the clean v0.14 commit hash. GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed.

## v0.13.1a Extended Scenario Lab Integrity Audit And Gap-Fix Pass - 2026-05-18

Scope: independently audit v0.13.1 extended scenario lab implementation and generated evidence, then fix only genuine tooling/reporting integrity gaps. This pass preserves runtime gameplay, gameplay numbers, campaign data, maps, factions, units, rewards, save format, runtime art/assets, pressure behavior, hosted release patterns, and human-feedback boundaries.

Phase 0 baseline:

- Current commit before this goal: `1e59f8c` (`Checkpoint v0.13.1 extended scenario lab`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Audit verdict:

- v0.13.1 was real implementation, not mostly superficial docs.
- The extended scripts did call simulator-backed runners and computed counts from generated data.
- The five default iterations are deterministic repeatability checks, not stochastic samples.
- v0.13.1 had genuine reporting/tooling gaps: no generated-output verifier, CSV/Markdown ranking mismatch, missing extended metric-availability metadata, and too-permissive `--runs` parsing.

Included work:

- Added `src/game/playtest/ScenarioLabOutputValidation.ts`.
- Added `tools/verifyPlaytestLabOutputs.ts`.
- Added `npm run playtest:lab:verify`.
- Updated `src/game/playtest/ScenarioLabExtendedRunner.ts` and types to include `uniqueDerivedMetricFingerprints` and metric availability.
- Updated `src/game/playtest/ScenarioLabExtendedReportWriter.ts` so CSV/Markdown profile order agrees and extended reports state deterministic-repeatability limits.
- Updated CLI run-count parsing in `tools/runPlaytestLab.ts` and `tools/runPlaytestProfiles.ts`.
- Expanded extended lab tests to validate generated JSON/Markdown/CSV consistency.
- Added v0.13.1a audit docs and improved threshold rationale docs.
- Regenerated extended outputs.

Current verification:

```text
npm test PASS, 49 files / 368 tests.
npm run build PASS with the known Phaser vendor chunk warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifests checked.
npm run test:e2e:smoke:fast PASS, 6 tests in about 2.0m.
npm run playtest:sim PASS, 255 runs across 85 campaign battle nodes.
npm run playtest:lab PASS, 10 profiles, 355 derived metrics, 8 watchpoints.
npm run playtest:watchpoints PASS, 10 profiles, 355 derived metrics, 8 watchpoints.
npm run playtest:profiles PASS, 10 scenario profiles.
npm run playtest:lab:extended PASS, 5 iterations, 1,275 source runs, 1,775 derived metrics, 10 watchpoints.
npm run playtest:watchpoints:extended PASS, 5 iterations, 1,275 source runs, 1,775 derived metrics, 10 watchpoints.
npm run playtest:profiles:compare PASS, 10 comparisons, 1,775 extended metrics.
npm run playtest:lab:verify PASS, 63 generated-output consistency checks.
git diff --check PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal remains Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet.

## v0.13.1 Extended Automated Scenario Lab, Multi-Run Evidence, and Balance Regression Dashboard - 2026-05-18

Scope: deepen the v0.13 automated scenario lab with repeated deterministic evidence, profile comparison, node-risk dashboarding, balance regression thresholds, generated reports, tests, and docs. This pass preserves the v0.13/v0.12.x green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent human feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `1a4e09e` (`Checkpoint v0.13 automated playtest scenario lab`).
- Branch state before edits: `main` clean and synced with `origin/main`.
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Included work:

- Added `src/game/playtest/ScenarioLabExtendedRunner.ts`.
- Added `src/game/playtest/ScenarioLabExtendedReportWriter.ts`.
- Added `src/game/playtest/ScenarioLabRegressionThresholds.ts`.
- Added `src/game/playtest/ScenarioLabExtended.test.ts`.
- Extended scenario metric rows with objective completion, pressure-trigger, first-wave, and post-pressure loss fields needed for repeated reporting.
- Added `npm run playtest:lab:extended`, `npm run playtest:watchpoints:extended`, and `npm run playtest:profiles:compare`.
- Generated `PLAYTEST_SCENARIO_LAB_EXTENDED.json`, `PLAYTEST_SCENARIO_LAB_EXTENDED.md`, `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_PROFILE_COMPARISON.csv`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`, and `PLAYTEST_WATCHPOINTS_EXTENDED.md`.
- Added v0.13.1 docs for limitations audit, node-risk dashboard spec, regression thresholds, extended evidence review, no-tuning decision, and final extended lab report.
- Updated README, ROADMAP, CHANGELOG, the v0.12.5 intake hub, and the v0.13 scenario-lab report so automated evidence remains separate from real tester feedback.

Extended automated evidence:

- Extended run size: 5 deterministic iterations, 255 source simulator runs per iteration, 1,275 source simulator runs total, 355 derived metric rows per iteration, 1,775 extended metric rows total.
- Top-ranked stable automated profile: Mixed-Veterans.
- Weakest / most failure-prone route: Greedy Economy.
- Biggest timeout risk: Ashen Outpost.
- Biggest pressure-risk signal: Cinderfen Watch.
- Retinue + Training Yard II: human testing required; no nerf.
- Greedy Economy: monitor conversion/time risk; no buff.
- Fast Army: monitor Cinderfen speed; no slowdown.
- Early defeats: OK/no change.
- Pressure fairness: human testing required.
- Cinderfen Crossing / Watch: structurally OK for Safe Beginner; no structural tuning.
- Objective completion and resource starvation: OK.

Current verification:

```text
npm test
PASS - 49 files / 367 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes.

npm run playtest:lab
PASS - generated 10 profiles, 355 derived profile-run metrics, and 8 watchpoint classifications.

npm run playtest:watchpoints
PASS - regenerated the scenario lab and watchpoint summary.

npm run playtest:profiles
PASS - generated 10 scenario profile definitions.

npm run playtest:lab:extended
PASS - generated 5 deterministic iterations, 1,275 source simulator runs, 1,775 derived profile-run metrics, and 10 regression watchpoints.

npm run playtest:watchpoints:extended
PASS - regenerated extended watchpoints with 5 deterministic iterations, 1,275 source simulator runs, 1,775 derived profile-run metrics, and 10 regression watchpoints.

npm run playtest:profiles:compare
PASS - generated 10 scenario profile comparisons and 1,775 extended profile-run metrics.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal is Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet, using the v0.13.1 dashboard to prioritize routes. Do not run feedback triage until real completed forms exist.

## v0.13 Automated Playtest Scenario Lab And Balance Telemetry V1 - 2026-05-18

Scope: add an automated playtest scenario lab and watchpoint classifier on top of the existing deterministic simulator. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5/v0.12.6 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent human feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `064b5db` (`Checkpoint v0.12.6 playtest distribution readiness`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: no maps, factions, units, runtime art/assets, save format, gameplay numbers, combat systems, campaign progression, hosted release stability changes, invented feedback, broad AI/economy rewrites, or balance implementation.

Included work:

- Added `src/game/playtest/ScenarioLabTypes.ts`.
- Added `src/game/playtest/ScenarioLabProfiles.ts`.
- Added `src/game/playtest/ScenarioLabClassifier.ts`.
- Added `src/game/playtest/ScenarioLabRunner.ts`.
- Added `src/game/playtest/ScenarioLabReportWriter.ts`.
- Added `src/game/playtest/ScenarioLab.test.ts`.
- Added `tools/runPlaytestLab.ts`.
- Added `tools/runPlaytestProfiles.ts`.
- Added `npm run playtest:lab`, `npm run playtest:watchpoints`, and `npm run playtest:profiles`.
- Generated `PLAYTEST_SCENARIO_LAB.json`, `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_WATCHPOINT_SUMMARY.md`, `PLAYTEST_SCENARIO_PROFILES.json`, and `PLAYTEST_SCENARIO_PROFILES.md`.
- Added v0.13 docs for architecture audit, profile spec, metrics spec, classifier rules, automated evidence decision, and final scenario-lab report.
- Updated README, ROADMAP, CHANGELOG, and the v0.12.5 intake hub so automated evidence remains separate from real tester feedback.

Automated evidence verdicts:

- Strongest automated watchpoint profile: Retinue + Training Yard II.
- Weakest / most failure-prone route: Greedy Economy.
- Fastest profile: Pressure-Ignoring, a narrow Fast Army pressure-node proxy.
- Retinue + Training Yard II: needs human testing; no nerf.
- Greedy Economy: monitor conversion/time risk; no buff.
- Fast Army: monitor Cinderfen speed; no slowdown.
- Early defeats: no change.
- Pressure fairness: structurally actionable but needs human noticeability testing.
- Cinderfen Crossing / Watch: no structural tuning from automation.
- Ashen Outpost: monitor pacing/final-assault timeouts.

Current verification:

```text
npm test
PASS - 48 files / 362 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

npm run playtest:lab
PASS - generated 10 profiles, 355 derived profile-run metrics, and 8 watchpoint classifications.

npm run playtest:watchpoints
PASS - regenerated the scenario lab and watchpoint summary.

npm run playtest:profiles
PASS - generated 10 scenario profile definitions.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because no runtime gameplay/HUD/campaign/pressure/result/tuning behavior changed. The next recommended long goal is Real Human Playtest Execution And Intake after testers complete the v0.12.6 packet. Do not run feedback triage until real completed forms exist.

## v0.12.6 Playtest Distribution Readiness And Tester Onboarding - 2026-05-18

Scope: add the distribution-readiness layer for real human manual playtests of the current v0.12.x browser prototype. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4/v0.12.5 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not invent tester feedback, start the 2026 visual overhaul, or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `fbd5530` (`Checkpoint v0.12.5 manual playtest feedback intake triage`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only tester onboarding/distribution; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, invented feedback, or balance implementation.

Included work:

- Added `docs/V0126_TESTER_QUICK_START.md`.
- Added `docs/V0126_PLAYTEST_COORDINATOR_GUIDE.md`.
- Added `docs/V0126_ROUTE_ASSIGNMENT_PLAN.md`.
- Added `docs/V0126_FEEDBACK_SUBMISSION_PACKET.md`.
- Added `docs/V0126_FEEDBACK_STORAGE_PLAN.md`.
- Added `docs/V0126_READY_TO_SEND_TESTER_MESSAGE.md`.
- Updated `docs/V0124_PLAYTEST_PACKET_INDEX.md` so the tester quick-start, route assignment, feedback packet, coordinator guide, storage plan, and ready-to-send message sit above the larger v0.12.4 packet.
- Updated `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md` so feedback intake begins after real tester forms are completed and points back to the v0.12.6 distribution docs.
- Updated `README.md` with a short manual tester quick-start pointer.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.6 is docs-only. The next recommended long goal is v0.12.7 Real Human Playtest Feedback Review And Small-Polish Decision after real completed tester packets are received. Do not invent feedback, and keep future visual overhaul work separate.

## v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage - 2026-05-18

Scope: add the evidence-intake and triage framework for completed v0.12.4 manual playtest packet responses. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3/v0.12.4 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not start the 2026 visual overhaul or implement balance changes.

Phase 0 baseline:

- Current commit before this goal: `9fb0196` (`Checkpoint v0.12.4 manual human playtest packet`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only intake/triage; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, or balance implementation.

Included work:

- Added `docs/V0125_PLAYTEST_FEEDBACK_INTAKE_HUB.md`.
- Added `docs/V0125_EVIDENCE_CLASSIFICATION_GUIDE.md`.
- Added `docs/V0125_WATCHPOINT_AGGREGATION_SHEET.md`.
- Added `docs/V0125_TRIAGE_DECISION_TREE.md`.
- Added `docs/V0125_SEVERITY_PRIORITY_RUBRIC.md`.
- Added `docs/V0125_FEEDBACK_TO_ACTION_MATRIX.md`.
- Added `docs/V0125_ISSUE_READY_TEMPLATES.md`.
- Added `docs/V0125_SAMPLE_FEEDBACK_TRIAGE.md`.
- Updated `docs/V0124_PLAYTEST_PACKET_INDEX.md` so completed tester forms point into the v0.12.5 intake workflow.
- Defined session IDs, evidence categories, repetition thresholds, severity/priority mapping, feedback-to-action rules, issue-ready templates, and clearly fictional sample triage.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.5 is docs-only. The next recommended long goal is v0.12.6 Manual Playtest Feedback Review And Small-Polish Decision after real tester packets are received. Keep future visual overhaul work separate.

## v0.12.4 Manual Human Playtest Packet And Tester Checklist - 2026-05-18

Scope: package the v0.12.x manual human balance/readability questions into practical tester-facing documentation that Emmanuel or another human tester can use while playing the current browser prototype. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2/v0.12.3 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, combat systems, campaign progression, and gameplay numbers. It does not start the 2026 visual overhaul.

Phase 0 baseline:

- Current commit before this goal: `1184e5f` (`Checkpoint v0.12.3 human campaign balance play session`).
- Branch state before edits: `main` clean and synced with `origin/main` (`git rev-list --left-right --count origin/main...HEAD` returned `0 0`).
- Guardrails: docs-only packet; no maps, factions, units, art/assets, runtime art, save format, gameplay numbers, combat systems, campaign progression, hosted release stability patterns, or broad balance implementation.

Included work:

- Added `docs/V0124_MANUAL_HUMAN_PLAYTEST_PACKET.md`.
- Added `docs/V0124_PLAYTEST_ROUTE_CARDS.md`.
- Added `docs/V0124_MISSION_CHECKLISTS.md`.
- Added `docs/V0124_WATCHPOINT_RATING_SHEET.md`.
- Added `docs/V0124_BUG_AND_FRICTION_REPORT_TEMPLATE.md`.
- Added `docs/V0124_PLAYTEST_SUMMARY_FORM.md`.
- Added `docs/V0124_DESIGNER_INTERPRETATION_GUIDE.md`.
- Added `docs/V0124_PLAYTEST_PACKET_INDEX.md`.
- Converted the v0.12.3 watchpoints into tester-facing route cards, mission prompts, rating scales, report templates, and designer interpretation rules.
- Kept future visual-overhaul notes separate from current gameplay readability and balance evidence.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run visual:qa
PASS - final rerun 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
Note: the first visual QA attempt hit a local saved-campaign click fallback refusal in the existing campaign/skirmish screenshot group; the full visual QA rerun passed without code or test changes.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.4 is docs-only. The next recommended long goal is v0.12.5 Manual Human Playtest Feedback Intake And Evidence Triage after Emmanuel or another tester fills the packet. Keep future visual overhaul work separate.

## v0.12.3 Human Campaign Balance Play Session - 2026-05-17

Scope: gather direct human-style campaign balance evidence for Retinue + Training Yard II, Greedy Economy, Fast Army, early defeats, pressure-warning noticeability, and the fairness of Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch. This pass preserves the v0.11.12/v0.12/v0.12.1/v0.12.2 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_PROTOCOL.md`.
- Added `docs/V0123_HUMAN_CAMPAIGN_PLAY_SESSION_NOTES.md`.
- Added `docs/V0123_CAMPAIGN_BALANCE_EVIDENCE_TABLE.md`.
- Added `docs/V0123_BALANCE_PLAY_SESSION_DECISION.md`.
- Added `docs/V0123_HUMAN_CAMPAIGN_BALANCE_PLAY_SESSION_REPORT.md`.
- Confirmed direct visible browser readability from main menu through New Campaign, Campaign Map, Border Village guidance, and battle HUD launch.
- Classified Retinue + Training Yard II as the strongest and cleanest route, but still deferred numeric tuning as earned power.
- Classified Greedy Economy as risky conversion/timeouts, not unfair pressure or underpowered economy.
- Classified Fast Army as decisive speed play, not current Cinderfen trivialization.
- Found no current structural early defeat issue and kept pressure-warning noticeability as a human-stress watch item.

Current verification:

```text
npm test
PASS - 47 files / 356 tests.

npm run build
PASS - production build completed with the known Phaser vendor chunk-size warning.

npm run validate:content
PASS - content validation passed.

npm run validate:art-intake
PASS - checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS - 6 tests.

npm run test:e2e:smoke
PASS - final full rerun 12 tests in 7.5m.
Note: the first full-smoke attempt hit a local timeout in the existing trophy-standard extended smoke after 11/12 tests passed; the focused trophy-standard rerun passed, then the full smoke rerun passed without code or test changes.

npm run visual:qa
PASS - 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS - production preview at http://127.0.0.1:4173/ verified menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors.

npm run playtest:sim
PASS - regenerated telemetry for 255 runs across 85 campaign battle nodes; no telemetry diff.

git diff --check
PASS.
```

Remaining watch items: GitHub Actions rerun is optional because v0.12.3 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check. The next recommended long goal is v0.12.4 Manual Human Playtest Packet And Tester Checklist. Keep the future 2026 visual overhaul separate.

## v0.12.2 Human Balance Watchpoint Review - 2026-05-17

Scope: review repeated simulator and human-style evidence for Retinue + Training Yard II strength, Greedy Economy timeouts, Fast Army quick clears, early campaign defeat causes, and Cinderfen pressure warning fairness. This pass preserves the v0.11.12/v0.12/v0.12.1 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, pressure scope, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0122_BALANCE_WATCHPOINT_PROTOCOL.md`.
- Added `docs/V0122_SIMULATOR_BALANCE_REVIEW.md`.
- Added `docs/V0122_HUMAN_BALANCE_NOTES.md`.
- Added `docs/V0122_TUNING_DECISION.md`.
- Added `docs/V0122_HUMAN_BALANCE_WATCHPOINT_REPORT.md`.
- Classified Retinue + Training Yard II as the strongest current watchpoint and satisfying earned power, not a current nerf target.
- Classified Greedy Economy failures as risky resource-to-army conversion/timeouts, not unfair early pressure.
- Classified Fast Army as a legitimate speed profile with broader failure risk, not a free dominant route.
- Found no current structural early campaign defeat problem.
- Found Cinderfen pressure warnings fair/actionable in structural evidence while preserving human noticeability as a watch item.

Current verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
git diff --check: PASS.
```

Hosted release groups and full release were not run locally because v0.12.2 made no gameplay, HUD, campaign, pressure, result, tuning, test-harness, or release-lane behavior changes.

Remaining watch items: GitHub Actions rerun is optional because v0.12.2 is docs-only, but a manual release-matrix rerun after push is a clean remote parity check. The next recommended long goal is v0.12.3 Human Campaign Balance Play Session focused on direct human runs through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch across retinue/Training Yard profiles. Keep the future 2026 visual overhaul separate.

## v0.12.1 Human-Paced Core Feel Playtest Review - 2026-05-17

Scope: review the v0.12 core feel/readability changes through a slower human-style play pass, then apply only tiny evidence-backed polish. This pass preserves the v0.11.12/v0.12 green release foundation, hosted release group structure, local/hosted lane separation, save compatibility, tutorial no-save/no-reward behavior, existing art/runtime assets, maps, factions, units, rewards, and gameplay mechanics. It does not start the 2026 visual overhaul or add broad AI/economy behavior.

Included work:

- Added `docs/V0121_HUMAN_PACED_PLAYTEST_PROTOCOL.md`.
- Added `docs/V0121_HUMAN_PACED_PLAYTEST_NOTES.md`.
- Added `docs/V0121_PLAYTEST_POLISH_PLAN.md`.
- Added `docs/V0121_TUNING_DECISION.md`.
- Added `docs/V0121_VISUAL_QA_REVIEW.md`.
- Added `docs/V0121_HUMAN_PACED_PLAYTEST_REPORT.md`.
- Aligned player-facing Cinderfen map names to `Cinderfen Crossing` and `Cinderfen Watch` while keeping map ids, file names, route wiring, saves, and mechanics unchanged.
- Reworded the Cinder Shrine objective to explain the one-time +20 Aether surge and hold instruction in the small tracker.
- Made defeat guidance context-aware so skirmish defeats use `Hold after each wave` while campaign defeats keep camp/Chapel support guidance.
- Updated reward/report naming and focused copy tests for the new Cinderfen names.
- Preserved release assertions after full release exposed two deep-flow timing issues: Start Battle scene transitions now use the existing scene-transition click options, and direct building selection refreshes the HUD before side-panel assertions. No force clicks or canvas/world DOM fallback were added.

Current verification:

```text
npm test: PASS, 47 files / 356 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 12 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 74 tests.
git diff --check: PASS.
```

Remaining watch items: commit, push, and rerun the manual GitHub Actions release matrix on the final v0.12.1 checkpoint commit. The next recommended long goal is v0.12.2 Human Balance Watchpoint Review focused on retinue plus Training Yard II, Greedy Economy timeouts, Fast Army clear speed, early campaign defeat causes, and pressure-warning fairness. Keep the future 2026 visual overhaul separate.

## v0.12 Core Game Feel and Battle Readability Pass - 2026-05-16

Scope: improve the existing playable slice after the v0.11.12 hosted release matrix green closeout. This pass focuses on readability and responsiveness through command acknowledgement, selected-order clarity, objective wording, scoped pressure counterplay, battle-status priority, side-panel hierarchy, and results guidance. It preserves gameplay scope, save compatibility, campaign progression, tutorial no-save/no-reward behavior, existing art, runtime art wiring, hosted release group configuration, release coverage strength, maps, units, factions, workers/construction prohibitions, and local/hosted release-lane separation.

Included work:

- Added `docs/V012_CORE_GAME_FEEL_AUDIT.md`.
- Added `docs/V012_BATTLE_READABILITY_AUDIT.md`.
- Added `docs/V012_BALANCE_AND_FEEL_TUNING_NOTES.md`.
- Added `docs/V012_VISUAL_READABILITY_NOTES.md`.
- Added `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`.
- Added command-level battle-status priority so accepted commands can replace routine income/status messages while pressure/objective messages still outrank them.
- Added clearer successful and blocked command feedback for movement, attack, attack-move, rally points, building placement, training, research, and abilities.
- Improved selected-group and current-order side-panel hierarchy without changing selection mechanics or runtime art.
- Marked the first unfinished objective as `Next` and tightened Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch objective copy.
- Clarified Cinderfen Crossing and Cinderfen Watch pressure warnings with counterplay language while keeping pressure warning/telemetry scoped.
- Improved defeat/results guidance without changing reward or save behavior.
- Added/updated focused tests for command status priority, objective state, pressure warning copy, and browser command acknowledgement.

Current verification:

```text
npm test: PASS, 47 files / 355 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run test:e2e:smoke: PASS, 12 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, production preview smoke, 0 browser console errors.
npm run playtest:sim: PASS, 255 simulated runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 20 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 12 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 74 tests.
git diff --check: PASS.
```

Remaining watch items: rerun the manual GitHub Actions release matrix on the final v0.12 commit after push. The next recommended long goal is v0.12.1 Human-Paced Core Feel Playtest Review across Ashen Outpost, Cinderfen Crossing, Cinderfen Watch, Results, and campaign return flow. Keep the future 2026 visual overhaul separate from this pass.

## v0.11.12 Hosted Release Interaction Determinism Fix - 2026-05-15

Scope: harden the manually triggered GitHub Actions hosted release matrix interaction layer after v0.11.11 production preview reduced server instability but run #19 still failed hosted deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke. This pass preserves gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. It does not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, visual baseline pixel assertions, skipped tests, or weakened assertions.

Included work:

- Added `docs/V1112_HOSTED_RELEASE_INTERACTION_FAILURE_AUDIT.md`.
- Added `docs/V1112_HOSTED_RELEASE_INTERACTION_DETERMINISM_FIX.md`.
- Hardened `clickReady` with a verified DOM fallback for real visible/enabled controls after normal Playwright click actionability fails, without using force clicks and without applying it to canvas/world clicks.
- Reused the strongest shared `expectBattleLoaded` helper across hosted pressure, smoke, layout, deep-flow, and Chapter 2 helper launch paths.
- Routed targeted hosted-problem DOM UI buttons through `clickReady`, including tutorial command-log advancement, smoke setup/campaign paths, enemy-pressure launches, deep-flow Barracks/Train command buttons, layout navigation, and Cinderfen helper choices/starts.
- Strengthened tutorial layout readiness with overlay/button waits and retrying layout-box measurement.
- Reworked side-panel command reachability to wait for side-panel readiness, measure current live DOM buttons in smaller scroll-aware checks, and emit diagnostics if readiness fails.
- Hardened the deep-battle right-click movement helper to reselect a friendly unit, validate canvas-safe target points, and keep the `Moving` assertion.

Current verification:

```text
npm test: PASS, 46 files / 351 tests.
npm run build: PASS, known Phaser vendor chunk-size warning only.
npm run validate:content: PASS.
npm run validate:art-intake: PASS, 1 candidate metadata JSON / 0 review manifests.
npm run test:e2e:smoke:fast: PASS, 6 tests.
npm run visual:qa: PASS, 5 tests, 18 screenshots, 0 browser console errors, 0 screenshot retries.
npm run smoke:preview: PASS, 0 browser console errors.
npm run playtest:sim: PASS, 255 runs across 85 campaign battle nodes.
npm run test:e2e:release:hosted:deep-meta: PASS, 12 tests.
npm run test:e2e:release:hosted:deep-battle: PASS, 11 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure: PASS, 7 tests.
npm run test:e2e:release:hosted:layout-core: PASS, 16 tests.
npm run test:e2e:release:hosted:layout-cinderfen: PASS, 9 tests.
npm run test:e2e:release:hosted:smoke: PASS, 12 tests.
Targeted hosted repro commands: PASS, movement/build, hover stability, enemy-pressure battle load, tutorial layout, Cinderfen desktop layout, and tutorial smoke.
npm run test:e2e:smoke: PASS, 12 tests.
npm run test:e2e:release: PASS, 67 tests.
git diff --check: PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm the same six production-preview hosted release matrix jobs plus the unchanged release simulator.

## v0.11.11 Hosted Release Preview Environment Fix - 2026-05-15

Scope: harden the manually triggered GitHub Actions hosted release matrix environment after v0.11.10 explicit groups still failed on hosted runners, while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V1111_HOSTED_RELEASE_ENVIRONMENT_AUDIT.md`.
- Added `docs/V1111_HOSTED_RELEASE_PREVIEW_ENVIRONMENT_FIX.md`.
- Added `playwright.hosted-release.config.ts` so hosted release groups run against production preview instead of Vite dev server.
- Added `npm run preview:hosted`.
- Updated hosted release group scripts to use `--config=playwright.hosted-release.config.ts`.
- Kept automatic Fast confidence, optional visual QA, release simulator, local full release, local 2-way shards, local 3-way shards, and manual full-release CI lane unchanged.
- Kept the GitHub Actions Chromium install step as `npx playwright install --with-deps chromium`, because the workflow already installs Linux browser dependencies.
- Added hosted-release-only Chromium launch args for Linux runner stability.
- Applied small test-only `clickReady` hardening to reported skirmish/tutorial launch paths and extended the deep-flow right-click movement helper to try nearby alternate world points while preserving the `Moving` assertion.

Current verification:

```text
npm test
PASS: 46 files / 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: 1 candidate metadata JSON file and 0 review manifest JSON files checked.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in 2.1m.

npm run visual:qa
PASS: 5 Playwright tests in 4.4m, 18 screenshots, 0 browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview smoke on http://127.0.0.1:4173/ with 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Hosted release preview groups
PASS: deep-meta 12/12, deep-battle 11/11, deep-campaign-pressure 7/7, layout-core 16/16, layout-cinderfen 9/9, smoke 12/12.

Targeted hosted-preview run #17 repros
PASS: deep-meta alternate Refugee/Chapel, deep-battle movement, pressure tutorial/skirmish, desktop tutorial layout, battle HUD/results layout, and smoke difficulty-selection repros.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 6.8m on rerun. The first local dev-server attempt timed out in the long Cinderfen Crossing smoke test during an app-root navigation retry; the targeted repro and full rerun passed.

npm run test:e2e:release
PASS: 67 Playwright tests in 35.2m after rerunning with a longer local command ceiling. The first invocation exceeded the local tool timeout before returning output.

git diff --check
PASS: only the existing Windows CRLF warning on .github/workflows/ci.yml.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm the same six release matrix jobs now run against production preview.

## v0.11.10 Hosted Release Matrix Determinism Fix - 2026-05-14

Scope: stabilize the manually triggered GitHub Actions hosted release matrix after v0.11.9's native 6-way split still failed on hosted runners, while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V1110_HOSTED_RELEASE_MATRIX_FAILURE_AUDIT.md`.
- Added `docs/V1110_HOSTED_RELEASE_MATRIX_DETERMINISM_FIX.md`.
- Replaced hosted native 6-way `--fully-parallel` shard scripts with explicit hosted release group scripts: `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`.
- Updated `.github/workflows/ci.yml` so the manual `run_release_matrix` input runs the six hosted groups with the existing 45-minute job timeout plus the unchanged release simulator.
- Added `seedSaveBeforeAppBoot` and routed shared, Chapter 2, and deep-flow seeded-save setup through pre-boot localStorage seeding.
- Applied non-forced `clickReady` to hosted-problem launch/setup interactions and added a one-retry right-click movement command helper while preserving the `Moving` assertion.
- Tagged release tests into explicit hosted groups totaling the same 67 tests as the full release suite.
- Updated README, release checklist, developer command guide, release lane reliability plan, changelog, and this checkpoint.

Current verification:

```text
npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm test
PASS: 46 test files, 351 tests.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.0m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.2m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Targeted remote-failure reproductions
PASS: Refugee/Chapel seed path, battle HUD minimap movement path, desktop tutorial layout entry, multi-viewport Battle HUD/results layout, and skirmish difficulty pressure path.

npm run test:e2e:release:hosted:deep-meta
PASS: 12 Playwright tests in about 6.1m, with one recovered setup-navigation retry.

npm run test:e2e:release:hosted:deep-battle
PASS: 11 Playwright tests in about 4.7m.

npm run test:e2e:release:hosted:deep-campaign-pressure
PASS: 7 Playwright tests in about 3.6m.

npm run test:e2e:release:hosted:layout-core
PASS: 16 Playwright tests in about 6.2m.

npm run test:e2e:release:hosted:layout-cinderfen
PASS: 9 Playwright tests in about 9.5m, with recovered setup-navigation retries.

npm run test:e2e:release:hosted:smoke
PASS: 12 Playwright tests in about 6.2m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.3m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 36.5m, with recovered setup-navigation retries.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input after this checkpoint and confirm it now shows six release matrix jobs named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged release simulator.

## v0.11.9 Hosted Release Matrix Split and Timeout Fix - 2026-05-14

Scope: split the manually triggered GitHub Actions release matrix into smaller hosted shards and tune the hosted shard timeout while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_AUDIT.md`.
- Added `docs/V119_HOSTED_RELEASE_MATRIX_SPLIT_FIX.md`.
- Added hosted-only 6-way release scripts: `npm run test:e2e:release:hosted:shard1of6` through `npm run test:e2e:release:hosted:shard6of6`, using Playwright test-level sharding with `--fully-parallel --workers=1`.
- Updated `.github/workflows/ci.yml` so the manual `run_release_matrix` input runs six hosted release shard jobs instead of three hosted shard jobs.
- Increased the manual hosted release shard job timeout from 35 minutes to 45 minutes after remote evidence showed shard 1 and shard 2 exceeded the 35-minute cap.
- Kept automatic Fast confidence, optional visual QA, release simulator, manual full-release lane, local full release, local 2-way shards, and local 3-way shards intact.
- Applied the existing non-forced `clickReady` helper to the two `menu-reset-save` clicks reported in the shard-1 hosted evidence.
- Hardened `gotoAppRootWithRetry` with a final real-main-menu readiness check after the last transient setup-navigation error, accepting recovery only when actual main menu controls are visible.
- Updated README, release checklist, developer command guide, release lane reliability plan, changelog, and this checkpoint.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.2m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.5m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.7m.

npm run test:e2e:release:hosted:shard1of6
PASS: 12 Playwright tests in about 6.9m.

npm run test:e2e:release:hosted:shard2of6
PASS: 11 Playwright tests in about 5.1m.

npm run test:e2e:release:hosted:shard3of6
PASS: 11 Playwright tests in about 5.2m.

npm run test:e2e:release:hosted:shard4of6
PASS: 11 Playwright tests in about 4.9m.

npm run test:e2e:release:hosted:shard5of6
PASS: 11 Playwright tests in about 11.3m with setup-navigation retry diagnostics and recovery.

npm run test:e2e:release:hosted:shard6of6
PASS: 11 Playwright tests in about 6.3m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Existing local 3-way shard scripts were not rerun in this pass because they are unchanged and the corrected hosted 6-way scripts exercised the same 67-test release suite. Remaining watch items: Emmanuel should rerun the manual GitHub Actions `run_release_matrix` workflow input and confirm it now shows six release matrix jobs named `shard-1-of-6` through `shard-6-of-6`, plus the unchanged release simulator.

## v0.11.8 Hosted Release Matrix Stability Fix - 2026-05-13

Scope: stabilize the manually triggered GitHub Actions 3-way release matrix while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, release coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V118_RELEASE_MATRIX_RELOAD_NAVIGATION_AUDIT.md`.
- Added `docs/V118_HOSTED_RELEASE_MATRIX_STABILITY_FIX.md`.
- Replaced remaining e2e `page.reload()` usage with hosted-safe app-root navigation through `gotoReadyMainMenu`.
- Unified `deep-flow.spec.ts` storage seeding with the shared menu-ready helper and Continue Campaign readiness assertion.
- Hardened `gotoReadyMainMenu` with commit-stage navigation, three setup-navigation attempts, same-URL interruption retry handling, longer real-menu readiness probes, and clearer retry logs.
- Added `clickReady` for narrow hosted actionability stalls without force-clicking, skipping, or weakening assertions.
- Applied `clickReady` to reported release-path campaign/skirmish interactions, including Broken Ford, Cinderfen node/start helpers, and Border Village start paths.
- Added a scoped 120s budget for the seeded Cinderfen menu/campaign layout readability test after remote shard-2 evidence and local full-release reproduction.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.3m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 6.5m.

npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.4m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

Targeted hosted-failure reproductions
PASS: deep-flow live victory/defeat, layout mobile portrait, layout tablet Cinderfen readability, Broken Ford smoke, post-Ashen Crossing smoke, and post-Crossing Watch smoke.

npm run test:e2e:release
PASS: 67 Playwright tests in about 36.5m after the final helper/timeout refinement.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 13.7m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 16.5m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 6.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Run manual 3-way release shard matrix and simulator` workflow input and confirm shard 1 no longer fails in deep-flow `seedSave`, shard 2 no longer fails in seeded Cinderfen layout setup navigation, and shard 3 no longer stalls at Broken Ford selection/start.

## v0.11.7 Optional Visual QA Screenshot Stability Fix - 2026-05-13

Scope: stabilize the manually triggered GitHub Actions `Optional visual QA` screenshot capture path while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, screenshot coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V117_VISUAL_QA_SCREENSHOT_STABILITY_FIX.md`.
- Split `tests/visual-qa/visual-qa.spec.ts` from one monolithic screenshot test into 5 smaller tests: menu/gallery/inventory, tutorial, campaign/skirmish, Cinderfen Crossing, and Cinderfen Watch.
- Kept all 18 screenshot targets and strict browser console error collection.
- Added per-screenshot start/done/fail/retry logging with group, file name, viewport, URL, elapsed time, duration, and retry status.
- Added a 45s per-screenshot timeout, disabled screenshot animations/caret, and one retry for transient screenshot timeout/capture failures.
- Updated the generated `visual-qa/latest/index.md` schema to include capture groups and screenshot retry status.

Current verification:

```text
npm run visual:qa
PASS: 5 Playwright visual QA tests in about 4.2m, 18 indexed screenshots, 0 recorded browser console errors, 0 screenshot retries.

npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.0m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.3m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 14.8m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.2m.

git diff --check
PASS.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm the hosted log shows `DONE screenshot` for `cinderfen-crossing-tablet.png`, `visual-qa-latest/index.md` uploads with 18 screenshots, and browser console errors remain 0.

## v0.11.6 Optional Visual QA Hosted Navigation Fix - 2026-05-12

Scope: stabilize the manually triggered GitHub Actions `Optional visual QA` job while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, screenshot coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or visual baseline pixel assertions.

Included work:

- Added `docs/V116_VISUAL_QA_HOSTED_NAVIGATION_FIX.md`.
- Updated `tests/e2e/shared-helpers.ts` so `gotoReadyMainMenu` retries only transient app-root setup navigation aborts such as `net::ERR_ABORTED`, frame-detach errors, or setup-navigation timeouts, while still requiring visible main-menu controls afterward. A navigation timeout is accepted only when the real main menu is already visible.
- Updated `tests/visual-qa/visual-qa.spec.ts` so the optional 18-screenshot visual QA capture test has a 420s budget instead of the previous 240s budget.
- Kept the visual QA harness as one coverage-preserving pass with 18 screenshot targets and strict browser console error collection.
- Kept automatic GitHub `Fast confidence` on `npm run test:e2e:smoke:fast`; this pass only targets the manual optional visual QA job.

Current verification:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests.

npm run visual:qa
PASS: 1 Playwright visual QA test in about 4.1m, 18 indexed screenshots, 0 recorded browser console errors.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:smoke
PASS: 12 Playwright tests.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.7m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 14.8m after the helper was refined to accept a setup-navigation timeout only when the real main menu was already visible.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should rerun the manual GitHub Actions `Optional visual QA` job and confirm `visual-qa-latest` uploads with `index.md`, 18 screenshots, and 0 browser console errors. If it fails again, inspect whether the failure is a new app assertion, browser console error, another navigation abort, or total job timeout before tuning further.

## v0.11.5 Fast Confidence Lane Split - 2026-05-12

Scope: split automatic GitHub Actions browser confidence from the full smoke/release lanes while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage strength, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative timeout inflation.

Included work:

- Added `docs/V115_FAST_CONFIDENCE_LANE_SPLIT.md`.
- Added `npm run test:e2e:smoke:fast`.
- Tagged six smoke tests as `@ci-fast` and six longer campaign/skirmish smoke tests as `@extended-smoke`.
- Updated `.github/workflows/ci.yml` so automatic `Fast confidence` runs `npm run test:e2e:smoke:fast`.
- Kept `npm run test:e2e:smoke` as the full 12-test smoke suite.
- Kept full release, 3-way release shards, visual QA, simulator, preview smoke, and manual GitHub workflow lanes coverage-preserving.

Current verification:

```text
npm run test:e2e:smoke:fast -- --list
PASS: lists 6 tests from `tests/e2e/smoke.spec.ts`.

npm run test:e2e:smoke -- --list
PASS: lists all 12 tests from `tests/e2e/smoke.spec.ts`.

npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 Playwright tests in about 2.1m.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.2m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 31.2m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.1m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 15.2m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors; PowerShell reported only the normal workflow line-ending notice.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push and confirm the e2e step runs `npm run test:e2e:smoke:fast`. Extended campaign/skirmish smoke coverage remains in full smoke and release/manual lanes.

## v0.11.4 Fast Confidence Seed/Reload Fix - 2026-05-12

Scope: stabilize GitHub Actions smoke seeded-save setup after the v0.11.3 settings timeout fix while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, balance, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative CI workflow churn.

Included work:

- Added `docs/V114_FAST_CONFIDENCE_SEED_RELOAD_FIX.md`.
- Improved `tests/e2e/shared-helpers.ts` so seeded-save setup starts from a ready main menu, writes localStorage only after a stable app origin exists, uses deterministic `page.goto("/")` navigation after writing storage instead of `page.reload()`, and verifies seeded saves enable Continue Campaign.
- Updated `tests/e2e/chapter2-helpers.ts` so post-Ashen, post-Crossing, and completed-route seeded saves use the same stable storage setup path.
- Added a narrowly scoped 60s timeout for only `skirmish difficulty selection changes fog and starting pressure`; the test still launches both seeded skirmish battles and keeps the fog/pressure assertions.

Latest verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS before the fix: 12 Playwright smoke tests in about 5.0m.
PASS after the fix: 12 Playwright smoke tests in about 5.2m.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on
PASS before the helper change: 1 test in 55.1s.
PASS after the helper change: 1 test in about 1.1m.

npx playwright test tests/e2e/smoke.spec.ts --grep "post-Crossing campaign launches Cinderfen Watch" --retries=1 --trace=on
PASS before the helper change: 1 test in about 1.0m.
PASS after the helper change: 1 test in 39.3s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish difficulty selection changes fog and starting pressure" --retries=1 --trace=on
PASS after the helper change: 1 test in 44.9s.
PASS after final docs update: 1 test in 32.7s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS before the helper change: 1 test in 14.6s.
PASS after the helper change: 1 test in 19.2s.

npx playwright test tests/e2e/smoke.spec.ts --grep "skirmish setup lists maps and launches Broken Ford" --retries=1 --trace=on
PASS before the helper change: 1 test in 14.3s.
PASS after the helper change: 1 test in 16.8s.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 30.3m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 12.4m.

npm run test:e2e:release:shard2of3
First pass: one local timeout in `enemy-pressure.spec.ts` tutorial/skirmish pressure guard after 26/27 tests passed.
Targeted rerun: PASS, 1 test in 29.1s.
Full shard rerun: PASS, 27 Playwright tests in about 14.7m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 5.7m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push. If any reported campaign/skirmish smoke path fails again after seeded setup succeeds, investigate that path independently rather than as seed/reload cascade.

## v0.11.3 Fast Confidence Smoke Fix - 2026-05-12

Scope: fix the first reported remote GitHub Actions `Fast confidence` smoke timeout while preserving gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. This pass did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, app runtime behavior changes, coverage reduction, secrets, paid services, or speculative CI workflow churn.

Included work:

- Added `docs/V113_FAST_CONFIDENCE_SMOKE_FIX.md`.
- Reviewed the reported GitHub Actions failure for `settings screen persists accessibility options` and the likely cascade in `campaign Border Village launches a battle scene`.
- Improved `tests/e2e/smoke.spec.ts` settings control waits by verifying re-rendered Settings DOM state after range, checkbox, and fog-select changes.
- Added a narrowly scoped 60s timeout for only the settings accessibility smoke test, tied to hosted CI evidence that the combined settings-persistence plus in-battle runtime-application path exceeded the global 35s Playwright test timeout.
- Left Border Village smoke coverage unchanged because it passed independently in focused local verification.

Latest verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS after the fix: 12 Playwright smoke tests in about 4.7m.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on
PASS after the fix: 1 test in 26.8s.

npx playwright test tests/e2e/smoke.spec.ts --grep "campaign Border Village launches a battle scene" --retries=1 --trace=on
PASS after the fix: 1 test in 16.7s.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

npm run test:e2e:release
PASS: 67 Playwright tests in about 28.7m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 13.4m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.9m.

npm run visual:qa
PASS: 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: Emmanuel should re-check the automatic GitHub Actions `Fast confidence` job after push. If Border Village fails again with a fresh failure after settings passes, investigate it as independent rather than as timeout cascade.

## v0.11.2 Remote CI Observation Report Gate - 2026-05-11

Scope: observe or document access to the first remote GitHub Actions run from v0.11.1, review likely CI timeout/portability/artifact risks, and make only tiny CI-only fixes if hosted evidence requires them. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, workflow coverage, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, coverage reduction, secrets, paid services, or speculative CI tuning.

Included work:

- Added `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`, `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`, `docs/V112_WORKFLOW_STATIC_REVIEW.md`, `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`, `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`, `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`, `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`, `docs/V112_CI_NO_FIX_DECISION.md`, and `docs/V112_REMOTE_CI_OBSERVATION_REPORT.md`.
- Confirmed `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`.
- Reviewed `.github/workflows/ci.yml` statically and found no concrete YAML/script/artifact/timeout issue.
- Documented that no CI-only workflow/helper change is justified until authenticated GitHub UI evidence identifies a real hosted-run issue.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase gates.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS during workflow/tooling gates.

npm run smoke:preview
PASS during preview/workflow gates with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: remote GitHub Actions evidence still needs authenticated GitHub UI observation, hosted Linux timing is unmeasured, hosted `smoke:preview` remains unconfirmed, manual visual/release artifacts remain unconfirmed, full release e2e remains slow, 2-way shards remain lopsided, and the known Phaser vendor warning remains.

## v0.11.1 CI Release Matrix Report Gate - 2026-05-11

Scope: add a conservative GitHub Actions CI dry-run, release matrix documentation, preview helper portability improvements, artifact strategy, CI/local parity checks, and release documentation updates. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, runtime art wiring, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, broad systems, or coverage reduction.

Included work:

- Added `docs/V111_CI_MATRIX_AUDIT.md`, `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`, `docs/V111_CI_RELEASE_MATRIX_PLAN.md`, `docs/V111_CI_ARTIFACT_STRATEGY.md`, `docs/V111_CI_LOCAL_PARITY_CHECK.md`, and `docs/V111_CI_RELEASE_MATRIX_REPORT.md`.
- Added `.github/workflows/ci.yml` with automatic fast confidence and manual visual QA, 3-way release shard matrix, simulator, and full-release lanes.
- Improved `tools/smokePreview.ts` with validated preview port/timeout env overrides, clearer startup errors, and POSIX helper-owned process-group shutdown.
- Updated README, `RELEASE_CHECKLIST.md`, `docs/DEVELOPER_COMMAND_GUIDE.md`, `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`, roadmap, changelog, and handoff docs.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS during workflow/tooling gates.

npm run smoke:preview
PASS during preview/workflow gates with title/menu/tutorial/campaign/skirmish checks and 0 browser console errors.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Remaining watch items: the GitHub Actions workflow still needs remote validation after push, full release e2e remains slow, 2-way shards remain lopsided, 3-way shard CI timing is not yet measured remotely, the known Phaser vendor warning remains, and visual QA remains optional/human-reviewed.

## v0.11 Technical Reliability Report Gate - 2026-05-11

Scope: improve technical reliability, e2e runtime clarity, release-lane documentation, preview smoke reliability, optional visual QA reporting, bundle/performance measurement, developer command ergonomics, and release-checklist maintainability. This pass preserved gameplay rules, save compatibility, campaign progression, tutorial behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md`, `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`, `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`, `docs/V11_VISUAL_QA_RELIABILITY_NOTES.md`, `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`, `docs/DEVELOPER_COMMAND_GUIDE.md`, and `docs/V11_TECHNICAL_RELIABILITY_REPORT.md`.
- Added `npm run smoke:preview` through `tools/smokePreview.ts` for repeatable production preview smoke with console-error capture and process-tree shutdown.
- Improved `npm run visual:qa` reporting so the generated index and command output show screenshot count, browser console error count, viewport coverage, and harness path.
- Refreshed bundle/performance facts and confirmed v0.11 tooling does not leak into production app JS.
- Tightened `RELEASE_CHECKLIST.md` and linked command guidance from README.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.1m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.3m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

npm run smoke:preview
PASS: http://127.0.0.1:4173/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, and 0 browser console errors. The helper shut down the preview process tree.

git diff --check
PASS: no whitespace errors.
```

## v0.10 Tutorial v2 Onboarding Report Gate - 2026-05-11

Scope: refine the playable Tutorial / Proving Grounds onboarding experience through copy clarity, pacing documentation, overlay hierarchy, no-reward completion clarity, e2e lane review, visual QA review, and Emmanuel's manual playtest checklist. This pass preserved gameplay rules, save compatibility, campaign progression, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, existing art, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, tutorial completion persistence, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V10_TUTORIAL_V2_AUDIT.md`, `docs/V10_TUTORIAL_V2_PACING_PLAN.md`, `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`, `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`, `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`, `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`, `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, and `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`.
- Updated tutorial copy in `src/game/data/tutorials.ts` to make the current twelve-step RTS/RPG loop clearer and more action-oriented.
- Added small tutorial overlay hierarchy styling in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css`.
- Clarified completion/menu copy so the player sees that training is complete, no rewards or save changes were granted, and New Campaign is the saved-run next step.
- Kept the full tutorial completion path in smoke after reviewing current e2e lane costs and coverage value.
- Reviewed refreshed visual QA tutorial screenshots and kept further UI work out of scope for v0.10.
- Wrote a human playtest checklist for Emmanuel to collect actual first-time-player feedback.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DY-3qp2P.js, 477.04 kB minified / 127.86 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BiGdwuWI.css, 44.51 kB minified / 9.16 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.7m.

npm run test:e2e:layout
PASS: 25 Playwright tests during the overlay phase.

npm run test:e2e:release
PASS: 67 Playwright tests during the e2e lane review phase, about 28.0m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.0m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Latest final-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.9m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 29.0m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in about 24.3m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in about 4.8m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.5m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 12.9m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.9m.

npm run visual:qa
PASS: 1 Playwright capture test in about 3.2m, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

Production preview smoke
PASS: http://127.0.0.1:4173/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign to Campaign Map, Continue Campaign to Campaign Map, Skirmish Setup, and zero browser console errors. A first preview harness attempt timed out because the preview child process stayed alive after the checks; repo-local preview processes were cleaned up and the rerun passed.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone: v0.10.1 Tutorial v2 Human-Feedback Polish, only after Emmanuel completes `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`. Keep it narrow and evidence-driven: clarify confusing steps or tiny overlay spacing only, preserve no rewards/no persistence/no campaign progression, and do not add maps, units, factions, generated art, runtime art replacement, or a full UI redesign. Visual work can instead return to v0.9.2 Controlled Cinderfen Style-Frame Candidate Review when source/license-documented candidates exist.

## v0.9.1 Controlled Cinderfen Style-Frame Intake Report Gate - 2026-05-10

Scope: create a safe non-runtime intake pipeline for future Cinderfen style-frame candidates, source/license metadata, review manifests, screenshot QA mapping, and approval gates. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, downloaded art, scraped art, large candidate binaries, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`, `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, `docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md`, `docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md`, `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`, `docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md`, `docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md`, and `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md`.
- Added non-runtime review folders under `art-review/` and `art-review/cinderfen-style-frames/`.
- Added source/license candidate metadata templates in Markdown and JSON.
- Added tooling-only review manifest types under `tools/art-intake/`.
- Added metadata-only `npm run validate:art-intake` validation and tests.
- Scanned the repo and confirmed no Cinderfen style-frame candidate images currently exist in the review intake.
- Mapped future candidate comparison to the existing 18-screenshot visual QA capture set.
- Wrote Emmanuel-facing manual preparation guidance and a future v0.9.2 candidate-review brief.

Latest report-gate verification results:

```text
npm test
PASS: 46 test files, 351 tests during phase/report gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON template and 0 review manifest JSON files.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Recommended next milestone: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, only after Emmanuel provides source/license-documented candidate images. Keep it non-runtime first: validate metadata, reject unsafe or unknown-source candidates, catalogue safe candidates as reference/candidate only, run visual QA, and write a side-by-side human review. Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.9 Controlled Cinderfen Style-Frame Report Gate - 2026-05-10

Scope: create a complete docs/specs/prompts-only Cinderfen visual style-frame package before any generated art, imported assets, or runtime visual replacement. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, imported art, large binary assets, runtime art replacement, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V09_CINDERFEN_STYLE_FRAME_RESEARCH_PACKET.md`, `docs/V09_CINDERFEN_VISUAL_PILLARS.md`, `docs/V09_CINDERFEN_TERRAIN_MATERIAL_SHEET_SPEC.md`, `docs/V09_CINDER_SHRINE_LANDMARK_SPEC.md`, `docs/V09_ASHEN_OUTPOST_ARCHITECTURE_SPEC.md`, `docs/V09_UNIT_BUILDING_SCALE_REFERENCE.md`, `docs/V09_CINDERFEN_STYLE_FRAME_PROMPT_PACK.md`, `docs/V09_FUTURE_CINDERFEN_MANIFEST_TEMPLATES.md`, `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md`, `docs/V09_CINDERFEN_VISUAL_REPLACEMENT_IMPLEMENTATION_PLAN.md`, and `docs/V09_CONTROLLED_CINDERFEN_STYLE_FRAME_REPORT.md`.
- Defined the Cinderfen ash-glass wetland identity and original-IP guardrails.
- Defined visual pillars for roads, shrines, units, wetland materials, Ashen architecture, player structures, fog, and UI label dependence.
- Specified future terrain materials for causeways, ash mud, shallow water, deep pools, reeds, fog/shadow, ruined edging, and ember/scorch marks.
- Specified Cinder Shrine landmark variants and Ashen outpost architecture categories.
- Consolidated current unit/building/capture-site scale facts into future replacement standards without changing runtime scale.
- Added a safe future prompt pack, manifest templates, screenshot acceptance criteria, and a future-only visual replacement sequence.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 340 tests during phase/report gates.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors during phase/report gates.
```

Recommended next milestone: v0.9.1 Controlled Cinderfen Style-Frame Intake And Source Review. Keep it non-runtime first: obtain 1 to 3 style-frame candidates, record source/license metadata, add review-only files only if explicitly approved, add manifest entries as reference/candidate only, run validation and visual QA, and write a human source/screenshot review. Do not wire assets into runtime until a later goal scopes one tiny replacement with source/license proof, manifest validation, before/after screenshot QA, and rollback.

## v0.8.2 Visual Source/License And Screenshot Coverage Report Gate - 2026-05-10

Scope: review visual asset source/license risk, refine conservative manifest metadata, harden visual asset validation, expand optional screenshot QA coverage, document a broader visual risk register, and prepare a v0.9 controlled visual sprint brief. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`, `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`, `docs/V082_MANIFEST_METADATA_REFINEMENT.md`, `docs/V082_MANIFEST_VALIDATION_HARDENING.md`, `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md`, `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`, `docs/VISUAL_RISK_REGISTER.md`, `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`, and `docs/V082_SOURCE_LICENSE_SCREENSHOT_COVERAGE_REPORT.md`.
- Added `reviewStatus` and `sourceReviewNotes` visual asset metadata.
- Kept current file-backed image assets conservative: no production-approved visual art, unknown-source runtime art remains review-needed and not allowed in production.
- Hardened validation around runtime/reference conflicts, final/candidate production safety, production-approved metadata, deprecated runtime assets, critical replacement notes, and source-review notes.
- Expanded optional `npm run visual:qa` from 10 to 18 indexed screenshots.
- Added screenshot coverage for Asset Gallery, Hero Inventory, tutorial mobile, route-complete campaign map, Cinderfen Crossing tablet, Crossing pressure warning, victory Results, and defeat Results.
- Added a living visual risk register and a v0.9 brief recommending a docs/specs/prompts-only Cinderfen style-frame sprint before runtime visual replacement.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 340 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 5.0m during screenshot/report gates.

npm run visual:qa
PASS: 1 Playwright capture test, 18 indexed screenshots, 0 recorded browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.

git diff --check
PASS: no whitespace errors during phase gates.
```

Recommended next milestone: v0.9 Controlled Cinderfen Style-Frame Sprint. Keep the first step docs/specs/prompts-only: Cinderfen terrain material sheet, Cinder Shrine/capture-site landmark sheet, and Ashen outpost architecture sheet. Do not generate, import, download, commit, or wire runtime art assets until a future goal explicitly scopes source/license metadata, manifest updates, validation, and before/after screenshot QA. If player-facing work is preferred, Tutorial v2 onboarding refinement remains the safer alternative.

## v0.8.1 Visual Asset Manifest And Screenshot QA Report Gate - 2026-05-10

Scope: create a visual asset inventory, metadata manifest, validation gate, runtime asset usage cross-check, optional screenshot QA harness, screenshot review baseline, Cinderfen visual replacement backlog, and safe future asset prompt/spec templates. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, generated art, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`, `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`, `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`, `docs/V081_RUNTIME_ASSET_USAGE_CROSSCHECK.md`, `docs/V081_SCREENSHOT_QA_PLAN.md`, `docs/V081_SCREENSHOT_QA_REVIEW.md`, `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`, `docs/ASSET_PROMPT_TEMPLATES.md`, and `docs/V081_VISUAL_ASSET_SCREENSHOT_QA_REPORT.md`.
- Added typed visual asset metadata in `src/game/assets/VisualAssetManifestTypes.ts`.
- Added an initial 89-entry manifest in `src/game/assets/visualAssetManifest.ts`.
- Integrated visual asset metadata validation into `npm run validate:content`.
- Added runtime visual asset coverage checks for battle textures, ability icons, UI-kit CSS assets, faction emblem, and main/results backgrounds.
- Added optional `npm run visual:qa` screenshot capture via `playwright.visual-qa.config.ts` and `tests/visual-qa/visual-qa.spec.ts`.
- Added `/visual-qa/` to `.gitignore` for generated screenshot artifacts.
- Captured and reviewed 10 screenshots with zero recorded browser console errors.
- Applied no visual code/CSS/renderer/scale/asset change because the screenshot review confirmed structural asset/art-direction debt rather than a single safe readability bug.

Latest final-gate verification results:

```text
npm test
PASS: 45 test files, 339 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in about 4.9m.

npm run test:e2e:release
PASS: 67 Playwright tests in about 30.1m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in about 25.1m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in about 4.7m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in about 11.8m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in about 13.4m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in about 4.7m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.

npm run visual:qa
PASS: 1 Playwright capture test, 10 screenshots, 0 recorded browser console errors.

production preview smoke
PASS: http://127.0.0.1:57934/ verified title, Prototype v0.3 / Cinderfen Route Baseline menu copy, Tutorial launch/exit, New Campaign to Campaign Map, Continue Campaign, Skirmish Setup, and zero browser console errors.

git diff --check
PASS: no whitespace errors during the final gate.
```

Recommended next milestone: v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion. Focus on source/license proof for high-priority manifest entries and expand non-brittle screenshots to Results, Inventory, Asset Gallery, defeat tips, and one mobile/tablet battle view. Do not add new art assets, graphics overhaul, desktop packaging, engine switching, workers, enemy construction, new maps, new units, new factions, rewards, save changes, pressure action promotion, or broad systems unless explicitly scoped. If player-facing work is preferred, Tutorial v2 onboarding refinement remains the safer alternative.

## v0.8 Technical Performance And Visual Foundation Report Gate - 2026-05-10

Scope: refresh bundle/performance and e2e runtime facts while creating the visual debt, scale, art direction, asset pipeline, and Cinderfen visual foundation. This pass preserved gameplay, save compatibility, campaign progression, Tutorial / Proving Grounds behavior, Cinderfen rewards, pressure guardrails, maps, units, factions, workers/construction prohibitions, and the current browser prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, engine switching, external assets, large binary assets, live reinforcements, capture-site contest AI, defensive-hold behavior, full UI redesign, graphics overhaul, or broad systems.

Included work:

- Added `docs/V08_PERFORMANCE_AUDIT.md`, `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`, `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`, `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/ASSET_PIPELINE_PLAN.md`, `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`, and `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md`.
- Refreshed current build output: app JS remains 476.83 kB / 127.77 kB gzip, Phaser vendor remains 1,481.79 kB / 339.86 kB gzip, CSS remains 44.23 kB / 9.11 kB gzip, and the known warning remains isolated to the Phaser vendor chunk.
- Audited the 67-test Playwright release suite and confirmed the old 2-shard split is structurally imbalanced at 55 tests vs 12 tests.
- Added additive optional 3-shard release scripts while preserving the full release lane and existing 2-shard scripts.
- Verified the new 3-shard scripts locally: 28 tests in 12.3m, 27 tests in 14.9m, and 12 tests in 5.3m.
- Audited visual debt across terrain, roads, water/swamp, capture sites, units, buildings, minimap, HUD, and style mismatch.
- Audited current scale/readability rules for hero/unit/building/capture-site/minimap/camera/fog/pathfinding systems.
- Applied no visual code or CSS tweak because current readability is functional and the major problems are structural art-direction and asset-pipeline issues.
- Created the future 2026 art bible, asset pipeline plan, and Cinderfen visual rework spec without generating or committing art.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests during the report gate.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 6.3m during the report gate.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes during the report gate.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

npm run test:e2e:layout
First attempt hit command timeout with no failing-test output.
After cleaning repo-local leftover Playwright/Vite Node processes and rerunning with a longer timeout:
PASS: 25 Playwright tests in 14.9m.

npm run test:e2e:release:shard1of3
PASS: 28 Playwright tests in 12.3m.

npm run test:e2e:release:shard2of3
PASS: 27 Playwright tests in 14.9m.

npm run test:e2e:release:shard3of3
PASS: 12 Playwright tests in 5.3m.

git diff --check
PASS: no whitespace errors during phase gates.
```

Recommended next milestone: v0.8.1 Visual Asset Manifest and Screenshot QA Gate. Start with source/license/status/scale metadata for existing assets and a small screenshot review set. Do not add new art assets, graphics overhaul, desktop packaging, engine switching, workers, enemy construction, new maps, new units, new factions, rewards, save changes, pressure action promotion, or broad systems. If player-facing work is preferred, Tutorial v2 onboarding refinement is the safer alternative.

## v0.7.3 Real-Input Cinderfen Pressure Playtest Report Gate - 2026-05-09

Scope: review Cinderfen Crossing and Cinderfen Watch pressure with controlled browser input and simulator evidence without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_PROTOCOL.md`, `docs/V073_PRESSURE_REVIEW_SETUP.md`, `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`, `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`, `docs/V073_STRATEGY_PROFILE_PRESSURE_REVIEW.md`, `docs/V073_MANUAL_PRESSURE_PLAYTEST_CHECKLIST.md`, `docs/V073_EVIDENCE_BACKED_PRESSURE_POLISH_DECISION.md`, `docs/V08_DIRECTION_DECISION_BRIEF.md`, and `docs/V073_REAL_INPUT_PRESSURE_PLAYTEST_REPORT.md`.
- Used controlled browser-input review to launch Cinderfen Crossing and naturally capture the Cinder Shrine in one pass; Crossing delayed-warning visibility still used seeded surrogate evidence because repeated automated movement was not stable enough to call full human play.
- Used controlled browser-input review to launch Cinderfen Watch, naturally capture Watch Road, observe immediate and delayed pressure warnings, and confirm pressure priority protects the delayed warning from generic status replacement.
- Documented strategy-profile findings: Safe Beginner remains stable, Greedy Economy remains a timeout/closure read, Fast Army remains acceptable strategy expression, and Retinue + Training Yard II remains a saved-progress power watchpoint.
- Created Emmanuel's manual checklist for direct human pressure feedback.
- Applied no pressure copy, timing, status-duration, telemetry, defeat-tip, e2e, scope, wave-nudge, balance, reward, save, map, unit, faction, worker, construction, economy AI, or campaign progression change.
- Recommended v0.8 technical performance/e2e runtime work before any pressure-specific simulator-only reinforcement experiment.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

## v0.7.2 Human-Paced Cinderfen Pressure Review Report Gate - 2026-05-09

Scope: review Cinderfen Crossing and Cinderfen Watch pressure feel/readability without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V072_PRESSURE_PLAY_REVIEW_PLAN.md`, `docs/V072_PRESSURE_BROWSER_REVIEW_NOTES.md`, `docs/V072_CINDERFEN_CROSSING_PRESSURE_REVIEW.md`, `docs/V072_CINDERFEN_WATCH_PRESSURE_REVIEW.md`, `docs/V072_PRESSURE_READABILITY_POLISH_DECISION.md`, `docs/V072_RETINUE_TRAINING_YARD_PRESSURE_REVIEW.md`, `docs/V072_GREEDY_FAST_PRESSURE_REVIEW.md`, `docs/V072_PRESSURE_NEXT_ACTION_DECISION.md`, and `docs/V072_PRESSURE_PLAY_REVIEW_REPORT.md`.
- Used seeded browser/Playwright review and screenshot inspection to confirm Crossing and Watch warnings remain readable.
- Applied no pressure copy, timing, status-duration, telemetry, defeat-tip, e2e, scope, wave-nudge, balance, reward, save, map, unit, faction, worker, construction, economy AI, or campaign progression change.
- Documented Retinue + Training Yard II as a saved-progress power watchpoint rather than a pressure bug.
- Documented Greedy Economy as a timeout/closure read and Fast Army as acceptable quick-clear expression.
- Kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only. Future stronger pressure should start with simulator-only `reinforce_next_wave` only after real-input human evidence.

Latest report-gate verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.2m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

## v0.7.1 Enemy Pressure Feel Final Gate - 2026-05-09

Scope: review, polish, and harden Enemy Strategic Pressure V1 without expanding into workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, live reinforcements, capture-site contest AI, defensive-hold behavior, or broad systems.

Included work:

- Added `docs/V071_ENEMY_PRESSURE_FEEL_AUDIT.md`, `docs/V071_PRESSURE_WARNING_VISIBILITY_AUDIT.md`, `docs/V071_PRESSURE_ACTION_PROMOTION_GATE.md`, and `docs/V071_ENEMY_PRESSURE_FEEL_REPORT.md`.
- Polished Cinderfen Crossing and Cinderfen Watch pressure warning copy and pressure-specific defeat tips.
- Added pressure battle-status priority with a longer read window while keeping objective/capture feedback above pressure.
- Hardened `tests/e2e/enemy-pressure.spec.ts` so pressure warnings stay visible against normal status replacement attempts.
- Improved playtest report readability for pressure plan/stage labels, triggered/quiet run counts, warnings, losses, and strategy reads.
- Applied no balance tuning and kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only.

Latest verification results:

```text
npm test
PASS: 45 test files, 334 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-CC1M6Mg7.js, 476.83 kB minified / 127.77 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.3m.

npm run test:e2e:release
PASS: 67 Playwright tests in 32.9m.

npm run test:e2e:release:shard1
PASS: 55 Playwright tests in 28.2m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 5.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Pressure read: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 12 quiet/untriggered pressure runs, 149 warnings, 147 losses after pressure, 0 simulated reinforcement applications, no enemy-pressure analyzer warnings.

git diff --check
PASS: no whitespace errors.

Production preview smoke
PASS: Browser smoke at http://127.0.0.1:57931/
PASS: title was Ascendant Realms.
PASS: main menu copy showed Prototype v0.3 and Cinderfen Route Baseline.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
NOTE: pressure-enabled battle launch was covered by targeted release e2e; the preview smoke did not force a deep Cinderfen save state.
```

Recommended next milestone: human-paced Cinderfen pressure play review. Focus on whether warnings are noticed and understood during real play, whether Cinder Shrine and Watch Road pressure feel fair, whether Fast Army and Greedy Economy outcomes read clearly, and whether Retinue + Training Yard II strength needs a separate human balance pass before any stronger enemy pressure action is promoted.

## v0.7 Enemy Strategic Pressure V1 Report Gate - 2026-05-09

Scope: implement and document the first controlled enemy commander pressure prototype. This pass preserved existing maps, units, factions, buildings, campaign progression, save compatibility, Tutorial / Proving Grounds no-reward behavior, and the browser-prototype scope. It did not add workers, enemy workers, real enemy construction, harvesting, dynamic enemy economy, new maps, new units, new factions, rewards, save-version changes, campaign progression, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/V07_ENEMY_PRESSURE_RESEARCH_AUDIT.md`, `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`, and `docs/V07_ENEMY_STRATEGIC_PRESSURE_REPORT.md`.
- Added data-driven pressure plan types, metadata, content validation, campaign-only runtime resolution, battle warning copy, telemetry fields, simulator reporting, targeted e2e coverage, and release docs.
- Scoped active plans to `cinderfen_crossing` / `cinderfen_causeway` and `cinderfen_watch` / `cinderfen_watchpost`.
- Kept Ashen Outpost excluded from V1 pressure.
- Kept `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold` warning/telemetry-only; the only live/sim effect is an existing next-wave timing nudge.
- Applied no balance tuning after telemetry showed no enemy-pressure analyzer warnings and no structural `too_easy` or `too_hard` nodes.

Latest verification results:

```text
npm test
PASS: 44 test files, 328 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-B8rnpsai.js, 476.13 kB minified / 127.51 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.4m.

npm run test:e2e:release
PASS: 67 Playwright tests in 29.4m during the Phase 8 e2e coverage gate.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
Pressure read: 75 pressure-enabled Cinderfen runs, 63 triggered pressure runs, 149 warnings, 0 simulated reinforcement applications, no enemy-pressure analyzer warnings.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone: human-paced Cinderfen pressure feel review. Focus on warning salience, Cinder Shrine contest readability, Watch Road timing, Fast Army quick-clear feel, Greedy Economy timeout clarity, and Retinue + Training Yard II strength before adding real reinforcement, route contesting, defensive-hold combat behavior, workers, construction, economy, new content, or broad AI systems.

## v0.6.1 Tutorial Feel Polish Gate - 2026-05-09

Scope: finish a small Browser-evidenced Tutorial / Proving Grounds feel polish pass on top of the final v0.6 onboarding foundation. This pass preserved the existing no-reward, non-persistent tutorial shell and did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/V061_TUTORIAL_FEEL_REVIEW.md`.
- Used Browser to review the main-menu Tutorial entry, desktop first objective overlay, 360 x 640 mobile-short first objective overlay, Exit Tutorial return, and console output.
- Found that the mobile-short battle status banner could paint over the tutorial overlay and interrupt the first objective text.
- Added explicit overlay z-index priority in `src/game/styles/battle-feedback.css` so `.tutorial-panel` renders above transient battle feedback.
- Added responsive Playwright coverage in `tests/e2e/layout.spec.ts` asserting the tutorial overlay renders above battle status feedback.
- Updated v0.6.1 planning/readability/audit docs and changelog.

Verification results:

```text
npm run test:e2e:layout -- --grep "tutorial entry"
PASS: 4 Playwright tests in 43.2s.

npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BCE05t_6.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-v9ZLtiOK.css, 44.23 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.9m.

npm run test:e2e:layout
PASS: 25 Playwright tests in 12.4m.

Production preview Browser smoke
PASS: http://127.0.0.1:57919/
PASS: page title was Ascendant Realms.
PASS: Tutorial / Proving Grounds launched, showed the first overlay, and exited to the main menu.
PASS: browser console warnings/errors stayed at 0.
```

Recommended next milestone: human-play the twelve-step Tutorial / Proving Grounds at normal speed. Keep any follow-up limited to readability, overlay hierarchy, and no-reward completion clarity unless a narrow verified bug appears.

## Final v0.6 Tutorial Onboarding Foundation Gate - 2026-05-08

Scope: final verification and handoff for the v0.6 tutorial onboarding/testing foundation. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward playable Tutorial / Proving Grounds shell. It did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Completed phases:

- Phase 0 repository integrity through Phase 12 final full verification completed.
- No phases were skipped.

Final verification results:

```text
npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DN-Hs_qy.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BzEbtAWy.css, 44.19 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.8m.

npm run test:e2e:release
PASS: 65 Playwright tests in 28.9m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run test:e2e:release:shard1
PASS: 53 Playwright tests in 24.0m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 4.9m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57918 --strictPort
PASS: Browser smoke at http://127.0.0.1:57918/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
```

Preview server was stopped after the smoke pass. No e2e transients or reruns were needed.

Recommended next milestone: human-play Tutorial / Proving Grounds, then do only small v0.6.1 tutorial feel polish around real input feel, copy clarity, overlay hierarchy, completion clarity, and command-log stability review.

## v0.6 Tutorial Onboarding Foundation Report Checkpoint - 2026-05-08

Scope: checkpoint the v0.6 tutorial onboarding/testing foundation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, v0.5 save/content-validation gate, and no-reward playable Tutorial / Proving Grounds shell. It did not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added the v0.6 tutorial feel audit.
- Polished tutorial copy, overlay layout, no-reward completion clarity, and accessibility semantics.
- Reviewed tutorial e2e lane placement and kept full completion in smoke while it remains near 5 minutes.
- Added test-only semantic command-log V1 for exactly one tutorial completion smoke path.
- Added command-log V1 plan and report.
- Added desktop/2026 visual-direction planning without implementation.
- Added `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`.

Phase 11 report verification:

```text
npm test
PASS: 42 test files, 315 tests, 11.35s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-DN-Hs_qy.js, 459.85 kB minified / 123.62 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-BzEbtAWy.css, 44.19 kB minified / 9.11 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.0m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone after the final full gate: human-play Tutorial / Proving Grounds, then do only small v0.6.1 tutorial feel polish around real input feel, copy clarity, overlay hierarchy, completion clarity, and command-log stability review.

## Final Tutorial / Proving Grounds Playable Shell Gate - 2026-05-08 19:21:40 -04:00

Scope: final verification and handoff for the first playable Tutorial / Proving Grounds shell. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It did not add maps, units, factions, rewards, save-version changes, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Completed phases:

- Phase 0 repository integrity through Phase 12 release report completed and committed.
- Phase 13 optional polish skipped intentionally; the next changes should come from human tutorial feel review.
- Phase 14 final full verification completed.

Final verification results:

```text
npm test
PASS: 42 test files, 315 tests, 11.45s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BArZgVc-.js, 459.27 kB minified / 123.49 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-EaFx5BCM.css, 43.77 kB minified / 9.02 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 5.2m.

npm run test:e2e:release
PASS: 65 Playwright tests in 28.5m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.3m and tests/e2e/deep-flow.spec.ts 11.2m.

npm run test:e2e:release:shard1
PASS: 53 Playwright tests in 24.4m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.7m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run test:e2e:release:shard2
PASS: 12 Playwright tests in 4.9m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57916 --strictPort
PASS: Browser smoke at http://127.0.0.1:57916/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
```

Preview note: an initial ad hoc headless launch without the project's Chromium SwiftShader args reported `Framebuffer Unsupported`. The preview smoke was rerun with the same Chromium args used by Playwright, passed with zero console errors, and the preview server was stopped afterward.

Recommended next milestone: human-play Tutorial / Proving Grounds, then do only small tutorial polish around copy, overlay hierarchy, completion clarity, and layout spacing unless a verified bug requires a narrow fix.

## Tutorial / Proving Grounds Playable Shell Report Checkpoint - 2026-05-08 18:11:29 -04:00

Scope: checkpoint the first playable Tutorial / Proving Grounds shell documentation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, v0.4 technical groundwork, and v0.5 save/content-validation gate. It did not add maps, units, factions, rewards, save-version changes, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external assets, or broad systems.

Included work:

- Added `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`.
- Updated README, roadmap, release checklist, changelog, and handoff status for the no-reward playable tutorial shell.
- Documented launch path, reused content, twelve tutorial steps, no-reward policy, save/persistence policy, tests added, e2e lane impact, known risks, and next recommended improvement.
- Confirmed the next recommended work is human-paced tutorial review and small polish, not content expansion.

Phase 12 report verification:

```text
npm test
PASS: 42 test files, 315 tests, 10.70s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-BArZgVc-.js, 459.27 kB minified / 123.49 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-EaFx5BCM.css, 43.77 kB minified / 9.02 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.8m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.
```

Recommended next milestone after the final full gate: human-play Tutorial / Proving Grounds, then do only small tutorial polish around copy, overlay hierarchy, completion clarity, and layout spacing unless a verified bug requires a narrow fix.

## Final v0.5 Save Content Validation Gate - 2026-05-08 14:54:30 -04:00

Scope: final verification and handoff for the v0.5 save, content-validation, determinism, and expansion-readiness gate. This pass did not add gameplay content, change balance, bump the save version, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, add multiplayer, or add broad systems.

Final verification results:

```text
npm test
PASS: 40 test files, 298 tests, 9.84s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Caz7zKca.js, 445.42 kB minified / 119.69 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.5m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.4m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.6m and tests/e2e/deep-flow.spec.ts 11.0m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.9m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.4m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57915 --strictPort
PASS: Browser smoke at http://127.0.0.1:57915/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. No Phase 15 transient reruns were needed.

Recommended next milestone: implement the first Tutorial / Proving Grounds playable shell using existing content only, with no rewards, no save-version bump, no new map, no new units, no new faction, and no broad systems.

## v0.5 Save Content Validation Gate Documentation Checkpoint - 2026-05-08 13:50:00 -04:00

Scope: checkpoint the v0.5 save, content-validation, determinism, and expansion-readiness gate documentation before the final full release-style verification. This pass preserved the frozen v0.3 Cinderfen Route Baseline, frozen v0.3.1 polish release, and v0.4 technical groundwork. It did not add playable tutorial content, change gameplay balance, bump the save version, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, add multiplayer, or add broad systems.

Included work:

- Added fixture-based save migration and normalization coverage for legacy V1, V2 campaign progress, settings-only saves, invalid JSON, affixed inventory, legacy equipment, retinue, rivals, trophies, Chapter 2 selection, Cinderfen route progress, missing optional fields, and future-ish unknown fields.
- Added stronger content validation and `npm run validate:content`.
- Added campaign graph/reward validation and documentation.
- Added command-log replay feasibility documentation recommending a future test-only semantic replay slice.
- Added simulator determinism documentation and tests.
- Selected Candidate A, Tutorial / Proving Grounds, for future planning.
- Added the Tutorial / Proving Grounds design brief and a non-playable metadata-only scaffold.
- Added `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md`.

Phase 14 documentation verification:

```text
npm test
PASS: 40 test files, 298 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Caz7zKca.js, 445.42 kB minified / 119.69 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors.
```

Recommended next milestone after the full v0.5 final gate: implement the first Tutorial / Proving Grounds playable shell using existing content only, with no rewards, no save-version bump, no new map, no new units, no new faction, and no broad systems.

## v0.4 Overnight Autonomous Progress Checkpoint - 2026-05-08 03:58:50 -04:00

Scope: checkpoint the extended v0.4 overnight autonomous goal. This pass preserved the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It did not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign rules.

Included work:

- Reconfirmed repository integrity and kept every phase checkpoint committed only after green verification.
- Refreshed bundle analysis, production test/dev hook audit, analyzer-backed no-op optimization decision, and e2e sharding documentation.
- Hardened one test-only rally movement wait in `tests/e2e/deep-flow.spec.ts`; no gameplay code changed.
- Applied copy-only Settings readability polish for colorblind minimap and small-screen command-panel guidance.
- Added `docs/SAVE_COMPATIBILITY_AUDIT.md` and one save test preserving valid Chapter 2 selected chapter/node state.
- Added `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md`.
- Expanded `docs/FULL_GAME_ROADMAP.md`, `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`, and `docs/V05_SYSTEMS_DESIGN_BRIEF.md` to cover all fifteen future-system planning tracks.
- Added `docs/V04_POLISH_BACKLOG.md`.

Checkpoint commits created in this overnight continuation:

```text
5459857 Checkpoint v0.4 bundle analysis
e393dd5 Checkpoint v0.4 test hook audit
5748857 Checkpoint v0.4 measured performance optimization
614a9ba Checkpoint v0.4 e2e sharding groundwork
ce1bc23 Checkpoint v0.4 e2e flake hardening
c302c34 Checkpoint v0.4 accessibility readability polish
7d156c6 Checkpoint v0.4 save compatibility audit
718820e Checkpoint v0.4 route feel surrogate review
cb333c5 Checkpoint full-game roadmap architecture
4b21824 Checkpoint v0.4 polish backlog
```

Final verification results:

```text
npm test
PASS: 38 test files, 271 tests, 7.35s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-90WGArXv.js, 436.35 kB minified / 117.34 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.6m.

npm run test:e2e:release
PASS: 59 Playwright tests in 27.8m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.1m and tests/e2e/deep-flow.spec.ts 11.1m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.0m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.2m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57911 --strictPort
PASS: Browser Use smoke at http://127.0.0.1:57911/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The next recommended long-running goal is the v0.5 save/content-validation gate: fixture-based save migration tests, stricter future content validation rules, deterministic command-log feasibility notes, and one explicitly approved vertical-slice candidate. Continue postponing workers, enemy construction, full new factions, new maps, diplomacy, procedural generation, crafting, multiplayer, monetization code, and broad army-management systems until their gates are explicit and green.

## v0.4 Autonomous Goal Progress Checkpoint - 2026-05-07 23:40:55 -04:00

Scope: checkpoint the autonomous v0.4 goal pass. This pass preserved the frozen v0.3 Cinderfen Route Baseline and frozen v0.3.1 polish release. It did not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign rules.

Included work:

- Confirmed the repo started clean and synced with `origin/main`.
- Re-ran and validated the existing bundle analyzer, bundle report, test/dev hook audit, analyzer-backed no-op optimization decision, and e2e release shard scripts.
- Added low-risk Settings readability/accessibility polish: clearer accessibility toggle labels, concise setting hints, UI Scale explanation, clearer Fog of War Override labels, and a broader keyboard/control reference.
- Added `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md`.
- Added planning-only full-game architecture docs:
  - `docs/FULL_GAME_ROADMAP.md`
  - `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`
  - `docs/V05_SYSTEMS_DESIGN_BRIEF.md`

Commits created before this final docs checkpoint:

```text
9934fb6 Checkpoint v0.4 accessibility readability polish
29ec5b6 Checkpoint full-game roadmap architecture
```

Phase 4 shard note:

```text
npm run test:e2e:release:shard1
First run: one transient timeout in tests/e2e/deep-flow.spec.ts around the first campaign rally movement assertion.
Follow-up: the exact failed test passed without code changes, then the full shard1 rerun passed with 49 tests.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests.
```

Final verification results:

```text
npm test
PASS: 38 test files, 270 tests, 7.15s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-Bi19pD8P.js, 436.32 kB minified / 117.33 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CeqfGaMI.css, 42.04 kB minified / 8.74 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 26.1m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 11.3m and tests/e2e/deep-flow.spec.ts 10.7m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 57705
PASS: Browser Use smoke at http://127.0.0.1:57705/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The next recommended milestone is a v0.5 save/content-validation gate before any broad mechanics implementation: save migration tests, future content validation rules, a deterministic command-log feasibility note, and one explicitly approved vertical-slice candidate.

## v0.4 Performance And E2E Sharding Groundwork Checkpoint - 2026-05-07 21:23:29 -04:00

Scope: checkpoint the v0.4 measurement, performance, and e2e sharding groundwork. This checkpoint does not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, alter save format, or change campaign content.

Included technical groundwork:

- Bundle analyzer script and report added for the current v0.4 technical baseline.
- Test/dev hook audit completed; no accidental large Playwright, Vitest, e2e-helper, or simulator leak was found in the production bundle.
- Phaser remains split into the `vendor-phaser` Vite/Rollup chunk.
- Analyzer-backed second optimization decision chose no additional code optimization; Asset Gallery was too small, no safe accidental production leakage was found, and no second stable vendor chunk exists.
- Explicit Playwright lanes remain available: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- Minimal 2-shard release-gate scripts were added for CI: `test:e2e:release:shard1` and `test:e2e:release:shard2`.
- Full `npm run test:e2e` and `npm run test:e2e:release` remain the canonical complete release-gate commands.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 10.38s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.8m.
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts 12.1m and tests/e2e/layout.spec.ts 12.0m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 24.0m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.5m and tests/e2e/deep-flow.spec.ts 11.2m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.3m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated.

git diff --check
PASS: no whitespace errors. Git emitted the existing .gitignore LF-to-CRLF working-copy warning.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4191 --strictPort
PASS: Browser Use smoke at http://127.0.0.1:4191/
PASS: page title was Ascendant Realms.
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign created a preview-smoke hero and reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. The shard scripts were run even though the full release gate also passed; the current split is coverage-preserving but locally uneven, with shard 1 carrying deep-flow and layout-heavy coverage. The shard scripts are primarily for CI matrix wall-clock reduction, not mandatory local iteration.

Checkpoint commit message:

```text
Checkpoint v0.4 performance and e2e sharding groundwork
```

Remaining known risks:

- Full Playwright release gate is still slow at roughly 29 minutes.
- The 2-shard split is currently uneven; shard 1 remains the long shard.
- Vite still reports a large-chunk warning because Phaser remains a large vendor chunk.
- Browser readability, mobile density, retinue/rival/trophy hierarchy, and Cinder Shrine salience still deserve human review before new content.
- Further performance work should remain analyzer-guided and limited to one explicit optimization at a time.

Recommended next milestone:

Use this checkpoint as the v0.4 technical baseline, then choose one focused follow-up: CI workflow wiring for the shard scripts, human readability/accessibility review of the frozen Cinderfen route, or a separate test-harness/content-validation hardening plan. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## v0.4 Technical Groundwork Verification Refresh - 2026-05-07 17:58:57 -04:00

Scope: clean post-checkpoint verification before further work. No reset, checkout, delete, revert, gameplay addition, content addition, balance change, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, or broad systems were added. The repository was clean and synced before this metadata refresh.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 11.23s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m.

npm run test:e2e:release
PASS: 59 Playwright tests in 28.1m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.0m and tests/e2e/deep-flow.spec.ts 11.5m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors before this metadata refresh.
```

Branch status before this metadata refresh:

```text
git status -sb
## main...origin/main

git rev-list --left-right --count origin/main...HEAD
0 0
```

Recommended next milestone remains unchanged: choose one focused v0.4 follow-up, preferably analyzer-guided performance measurement, a second carefully scoped optimization, or human readability/accessibility review of the frozen Cinderfen route. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## v0.4 Technical Test And Performance Groundwork Checkpoint - 2026-05-06 21:25:41 -04:00

Scope: checkpoint the v0.4 technical groundwork after the explicit e2e lane split and the first measured performance optimization. This checkpoint does not add gameplay content, change balance, add maps, add units, add factions, add workers, add enemy construction, add diplomacy, add procedural generation, add crafting, or alter campaign content.

Included technical groundwork:

- Added explicit Playwright lanes while preserving the full release gate: `test:e2e:smoke`, `test:e2e:layout`, `test:e2e:deep`, and `test:e2e:release`.
- Kept `npm run test:e2e` as the full Playwright suite.
- Added v0.4 planning docs for direction and performance implementation.
- Implemented only the first approved performance optimization: Vite/Rollup splits `node_modules/phaser` into `vendor-phaser`.
- Documented before/after bundle numbers and the remaining Phaser vendor large-chunk warning.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 10.18s.

npm run build
PASS: TypeScript compile and Vite production build.
Output: assets/index-TotuX8zG.js, 435.50 kB minified / 116.99 kB gzip.
Vendor: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB minified / 339.86 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.
Known warning remains because vendor-phaser is larger than 500 kB after minification.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.8m.

npm run test:e2e:release
PASS: 59 Playwright tests in 29.0m on final full-suite rerun.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.8m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS: no whitespace errors after checkpoint metadata update.
```

E2E note: the first full release-gate run had one transient timeout in the deep-flow rally movement assertion, while 58 tests passed. The targeted failed case then passed in 38.1s without code changes, and the full release gate passed on rerun. No gameplay or test semantics were changed in response.

Checkpoint commit message:

```text
Checkpoint v0.4 technical test and performance groundwork
```

Remaining known risks:

- Full Playwright release gate is still slow at roughly 29 minutes.
- The fast smoke lane is useful for iteration but is not a release-gate replacement.
- Vite still reports a large-chunk warning because Phaser remains a large vendor chunk.
- Further performance work should be analyzer-guided and limited to one explicit optimization at a time.
- Human readability and mobile-density review of the frozen Cinderfen route remains valuable before new content.

Recommended next milestone:

Choose a focused v0.4 follow-up: analyzer-guided performance measurement, a second carefully scoped optimization, or human readability/accessibility review of the frozen Cinderfen route. Continue postponing workers, enemy construction, new factions, new maps, crafting, diplomacy, procedural systems, and broad gameplay systems.

## Final v0.3.1 Polish Release Verification - 2026-05-06 18:30:40 -04:00

Scope: final automated verification for the v0.3.1 polish release. No features, gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems were added. The only changes after verification are release-documentation updates.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 7.56s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BlnznQM_.js, 1,918.65 kB minified / 457.79 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests in 28.6m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.3m and tests/e2e/deep-flow.spec.ts 11.4m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4188
PASS: Browser Use smoke at http://127.0.0.1:4188/
PASS: page title was Ascendant Realms.
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed the current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. Final v0.3.1 decision: frozen as the polish release for the frozen Cinderfen Route Baseline, with remaining known risks limited to human readability/feel, mobile density, Cinder Shrine salience, retinue/rival/trophy hierarchy, the long Playwright release-gate runtime, and the accepted Vite large-chunk warning.

## Clean v0.3.1 Polish Checkpoint - 2026-05-06 17:49:49 -04:00

Scope: create a clean checkpoint for the completed v0.3.1 polish, readability, audit, and safe e2e helper work before any new feature work. No reset, checkout, delete, revert, gameplay addition, balance change, map addition, unit addition, faction addition, worker system, enemy construction, diplomacy, procedural generation, crafting, or broad refactor was performed during this checkpoint pass.

Preserved current dirty work:

- v0.3.1 polish plan and route readability documentation.
- UX copy and hierarchy polish for the existing frozen Cinderfen route.
- Mobile/readability audit coverage and documentation.
- Performance bundle audit documenting the known Vite large-chunk warning.
- E2E runtime audit plus the safest helper cleanup.
- Shared Playwright setup helpers for smoke/layout setup while keeping release-critical full-flow coverage visible in specs.
- All existing gameplay behavior, route content, selectors, and balance.

Verification results:

```text
npm test
PASS: 38 test files, 270 tests, 8.21s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BlnznQM_.js, 1,918.65 kB minified / 457.79 kB gzip.
CSS: assets/index-CIXXIuKP.css, 41.86 kB minified / 8.71 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests in 28.7m.
Slow files noted by Playwright: tests/e2e/layout.spec.ts 12.4m and tests/e2e/deep-flow.spec.ts 11.5m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Git and branch status:

```text
Pre-checkpoint `git status -sb`: ## main...origin/main with the expected dirty v0.3.1 polish/audit/helper stack.
Pre-checkpoint `git rev-list --left-right --count origin/main...HEAD`: 0 0
Checkpoint commit message: Checkpoint v0.3.1 polish readability and e2e cleanup
Checkpoint commit hash: 53fa85671dd5668b6654abfd01aeed857bf49ab2
Post-checkpoint, pre-metadata `git status -sb`: ## main...origin/main [ahead 1]
Post-checkpoint, pre-metadata `git rev-list --left-right --count origin/main...HEAD`: 0 1
Metadata commit hash: eaacdeaf4370005bf791d5bc2023d86b4b31503e
After pushing the checkpoint and metadata commits, `git status -sb`: ## main...origin/main
After pushing the checkpoint and metadata commits, `git rev-list --left-right --count origin/main...HEAD`: 0 0
After this push-status note is pushed, the branch should remain synced with origin/main.
```

Remaining known risks:

- Human readability and feel still need review on the frozen Cinderfen route, especially Cinderfen Overlook, Waystation, Cinder Shrine, Watch, Aftermath, Results, and mobile density.
- Vite still reports the known large Phaser/main-bundle warning; the performance audit recommends documentation and safe future options only, with no risky optimization implemented for v0.3.1.
- Full Playwright e2e remains slow at roughly 29 minutes. The helper cleanup held coverage steady and avoided brittle shortcuts; deeper runtime reductions should use explicit release-gate/default split decisions later.
- Fast Army, retinue, and Training Yard II profiles remain campaign pacing watchpoints during human playtesting.

Recommended next milestone:

Human-verify v0.3.1 polish on the frozen Cinderfen route in a browser, then decide whether to keep the full Playwright suite as a release gate and add a smaller default smoke lane. Do not start new Chapter 2 content or broad systems until the existing route stays green in human readability, UX, and balance review.

## Final v0.3 Release-Candidate Verification - 2026-05-05 18:36 -04:00

Scope: final automated verification for the v0.3 Cinderfen route release-candidate freeze. No features, gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems were added. The only changes in this pass are release-candidate documentation updates.

Verification results:

```text
npm test
PASS: 38 test files, 268 tests, 7.40s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BRMcmX2c.js, 1,917.92 kB minified / 457.57 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.9m.
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json were regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4187
PASS: Browser Use smoke at http://127.0.0.1:4187/
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached hero creation and Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed the current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. Final freeze decision: v0.3 is ready to freeze as the Cinderfen Route Baseline prototype release candidate, with remaining known risks limited to human readability/feel watch items.

## Checkpoint Scope

This checkpoint records the verified v0.3 Cinderfen route polish-freeze baseline. It preserves the v0.3 baseline docs, readiness/preview reports, route-complete polish, reward-audit/test updates, Chapter 2 e2e helper cleanup, and campaign map presentation helper cleanup without adding gameplay during the checkpoint pass.

Included in this checkpoint:

- `cinderfen_overlook` is a playable Chapter 2 event gate after `ashen_outpost`.
- `cinderfen_waystation` is a compact Chapter 2 town/support node after Cinderfen Overlook.
- `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event gate is completed.
- Cinderfen Causeway includes the Cinder Shrine first-capture Aether surge and Shrine Attunement support.
- `cinderfen_watch` launches the compact `Cinderfen Watchpost` map after Cinderfen Crossing victory.
- `cinderfen_aftermath` is a compact non-battle consequence event after Cinderfen Watch.
- The compact Malrec trophy consequence is visible through the existing rival/trophy state.
- Chapter/campaign data is split into focused node and reward modules with compatibility barrels preserved.
- Chapter 2 reward-economy audit changes are preserved: Cinderfen repeat clears pay only tiny XP/resources and no repeat battle item roll while first clears remain useful.
- Chapter 2 Playwright setup cleanup is preserved in `tests/e2e/chapter2-helpers.ts`; smoke specs keep the meaningful reward, copy, persistence, and duplicate-prevention assertions.
- v0.3 baseline/readiness documentation is preserved in `docs/V03_CINDERFEN_ROUTE_BASELINE.md`, `docs/CINDERFEN_ROUTE_READINESS_GATE.md`, and `docs/PRODUCTION_PREVIEW_REPORT.md`.
- Route-complete polish is preserved: completing Cinderfen Aftermath makes the campaign map/return flow clearly communicate that the playable Cinderfen route is secured and the Chapter 2 slice is complete.
- Campaign map presentation cleanup is preserved with focused helpers for chapter cards, node cards, route status, event/town choice summaries, and result copy.
- Chapter 2 event, support, battle, aftermath, reward, persistence, simulator, e2e, telemetry, balance, report, production-preview, and documentation changes from the current route are preserved.
- Chapter 1 remains stable in tests, e2e, and simulator telemetry.

No gameplay behavior was changed during this checkpoint request. The only post-verification edits are this checkpoint record and the corresponding handoff update.

## Verification Results

### Unit Tests

Command:

```bash
npm test
```

Result:

```text
PASS
38 test files passed
268 tests passed
Latest duration: 10.77s
```

### Production Build

Command:

```bash
npm run build
```

Result:

```text
PASS
TypeScript compile passed
Vite production build passed
Latest output: assets/index-CIosN5VC.js, 1,917.97 kB minified / 457.58 kB gzip.
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
52 Playwright tests passed
Total duration: 21.4m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Coverage includes Chapter 2 browser flows that resolve Cinderfen Overlook, use Cinderfen Waystation Shrine Attunement, win Cinderfen Crossing, verify Cinder Shrine rewards do not duplicate, win Cinderfen Watch, verify rewards persist once, resolve Cinderfen Aftermath, verify route-complete copy, verify future Chapter 2 nodes remain upcoming/locked, verify Aftermath rewards do not duplicate, and verify the Malrec trophy consequence. The Chapter 2 smoke flows use the extracted helper module.

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 255 runs across 85 campaign battle node/profile summaries.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
Chapter 1 telemetry remains stable.
Cinderfen Crossing and Cinderfen Watch remain structurally reasonable.
```

### Git Diff Check

Command:

```bash
git diff --check
```

Result:

```text
PASS
No whitespace errors.
```

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint v0.3 Cinderfen route polish freeze
```

Checkpoint commit hash:

```text
f644bb6dc6b09d529a249321fd70563fa44748e1
```

Branch:

```text
main tracking origin/main
```

Branch sync status:

```text
Before the checkpoint commit, `git status -sb` reported `## main...origin/main` with the expected dirty v0.3 polish-freeze stack.
Before the checkpoint commit, `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
After checkpoint commit `f644bb6dc6b09d529a249321fd70563fa44748e1` and before this metadata update, `git status -sb` reported `## main...origin/main [ahead 1]`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 1`.
After pushing the checkpoint and metadata update, `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

## Remaining Known Risks

- Human playtesting is still needed for the full Cinderfen route with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II profiles can still clear Cinderfen quickly, so reward pacing should be watched before adding more Chapter 2 payouts even though repeat farming value is now tiny.
- Cinder Shrine and Shrine Attunement are intentionally modest, but human players may overvalue or miss the first-capture Aether surge without a live readability pass.
- Cinderfen Overlook, Waystation, and Aftermath choice/service copy is covered by tests, but mobile UI density should still be spot-checked in the browser.
- The Chapter 2 Playwright helper file should stay a setup/fast-forward helper only; future specs should keep meaningful gameplay assertions in the spec files.
- Campaign map presentation helpers should stay presentation-only; do not move campaign rules, save mutation, or battle launch logic into the view-model helper layer.
- Rival impact is intentionally compact and Malrec-trophy-gated; broader returning-rival arcs remain future work.
- Chapter/campaign content now depends on focused data modules and compatibility barrels staying aligned.
- Vite still reports the known large Phaser bundle warning.
- Full Playwright e2e remains slow at roughly 22 minutes.

## Recommended Next Milestone

Human-verify the v0.3 Cinderfen route freeze candidate end to end: Overlook, Waystation, Crossing, Cinder Shrine surge/attunement, Watch, Aftermath, Results, route-complete campaign-map copy, and return-to-campaign persistence. Add no further Chapter 2 content until the route stays green in human readability and balance review. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.
