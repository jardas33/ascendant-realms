# v0.312 H3 Runtime Evidence-Integrity Recovery

## Executive correction

v0.311 is corrected to **EVIDENCE INVALID — H3 RUNTIME METHOD REMAINS UNPROVEN**. The H3 adapter implementation is retained; only the acceptance claim is withdrawn. The v0.311 pack remains preserved as failed historical evidence under `artifacts/manual-review/v0312-h3-runtime-evidence-integrity-recovery/v0311-audit/`.

## Why v0.311 acceptance was withdrawn

The prior pack contained 91 physical PNG files when all pack PNGs were audited, but only 10 unique SHA-256 images. The 86 numbered PLAYER/DEBUG_REVIEW runtime frames also contained the confirmed duplicate semantic groups. Nonblank-file validation could not prove that movement, bridge crossing, occlusion, camera changes, Worker work, Militia ready, save/reload, or rollback had occurred.

PLAYER and DEBUG_REVIEW views were also counted as separate evidence even when they depicted the same moment. v0.312 therefore separates physical files, unique images, paired views, and semantically accepted events.

## Duplicate-frame audit

The audit records SHA-256, dimensions, byte size, perceptual hash, exact duplicate groups, and pixel-difference evidence for every retained v0.311 PNG. It identifies semantic labels whose images were identical and records the old count-inflation and save/rollback limitations. Historical v0.311 files are not deleted or rewritten.

## Semantic evidence standard

Every v0.312 rendered PNG has a sidecar containing its filename, runtime timestamp, frame number, scenario, authoritative IDs, role, world position, destination, facing, command/activity state, selected IDs, camera position/zoom, H3/fallback flags, save identifier where relevant, screenshot SHA-256, and related-frame SHA-256. Exact duplicate frames inside one semantic scenario are rejected. PLAYER/DEBUG_REVIEW paired views share an event accounting policy and are not double-counted.

## Runtime integration status

The adapter remains opt-in and consumes `runtime.units` and `runtime.selected_ids`. Only Barrosan Worker and Militia are integrated. The v0.303 fallback/debug renderer remains available. Presentation metadata for command/activity/facing is derived from the existing workload runtime; no separate visual simulation owns gameplay positions.

## Movement proof

Worker and Militia sequences use stable IDs and real `issue_move_order` plus workload-runtime frame advancement. Before-command, post-command, progress, destination, and stop records show changing authoritative positions, destination/facing metadata, selection attachment, and H3 presentation synchronization. Duplicate frames are rejected rather than counted.

## Bridge proof

Worker and Militia each have a seven-frame bridge sequence: bank approach, entry, first quarter, centre, third quarter, exit, and beyond bridge. The same stable ID is retained and authoritative positions progress across the route. Bridge evidence is accepted as runtime movement evidence; the current single-pose asset limitation remains separately documented.

## Occlusion proof

Road, storehouse, and bridge-railing sequences capture multiple moving positions around the existing terrain/structure presentation. The sidecars record changing world coordinates and camera state. These are retained for visual review; no occlusion claim is promoted to a gameplay claim beyond what the rendered transitions show.

## Camera proof

Camera-pan captures record changed camera world coordinates with unchanged unit state. Camera-zoom captures separately record minimum, ordinary, and maximum supported gameplay zoom. No pan frame is reused as zoom evidence.

## Worker state proof

The existing Worker move-to-mine and assignment action is exercised through the runtime. The assignment record reports `activityState=working`. The runtime work state is proven; authored work animation is absent and is not claimed.

## Militia state proof

Militia idle, move-command, and arrival evidence is captured. The current runtime has no supported Militia ready/hold state. The required ready-state claim is therefore explicitly rejected as unsupported rather than inferred from a selected card or static pose.

## Selection proof

Worker unselected/selected, Militia selected, mixed selection, box selection, cleared selection, post-movement selection, and selection-after-reload records include changing authoritative `selectedIds` metadata.

## Real save/write/load proof

The opt-in capture harness writes a real JSON save to `user://v0312-h3-runtime-save.json`, records its checksum, resets the runtime, reloads the written state, restores stable IDs, positions, health, orders, resources, and selection, and captures before-save, reset, load, and post-load selection views. This is capture-harness save proof; it does not alter the default launcher or replace the wider save architecture.

## Real rollback proof

Using the same authoritative state, the capture disables H3 presentation, captures the procedural fallback, then re-enables H3 and captures reconstruction. The adapter exposes a reversible presentation toggle; gameplay state, IDs, positions, and selection remain sourced from the same runtime.

## Player/debug evidence accounting

The regenerated pack contains 154 physical PNGs and 154 sidecars across PLAYER and DEBUG_REVIEW modes. It contains 127 unique screenshot SHA-256 images, 128 semantically accepted records, and 26 rejected records. Exact duplicate frames and the unsupported Militia-ready record are listed in the rejection register. Player/debug pairs are evidence views of moments, not two gameplay events.

## Visual scale review

The pack includes current v0.311 scale, 12% smaller, and 24% smaller bounded presentation captures. The smaller treatments improve environmental scale plausibility, but the one-pose source limitation remains. No source art was modified.

## Worker/Militia readability

Worker and Militia remain distinguishable through their retained authored source images and role metadata. Grounding, selection, shadow attachment, and scale are captured. Direction changes are derived from authoritative travel direction and are not presented as a complete authored directional library.

## Evidence-integrity scorecard

| Area | Result |
|---|---|
| Unique capture integrity | Pass; SHA-256 and sidecar checks pass |
| Semantic-label accuracy | Pass for accepted records; unsupported/duplicate claims rejected |
| Metadata consistency | Pass |
| Sequence completeness | Movement/bridge/camera/selection/save/rollback pass; Militia ready incomplete |
| Save proof | Pass for opt-in capture-harness write/reload |
| Rollback proof | Pass for H3/fallback/H3 presentation reconstruction |

## Runtime scorecard

| Area | Result |
|---|---|
| Entity binding | Pass for Worker/Militia |
| Movement synchronisation | Pass |
| Bridge crossing | Pass as bounded runtime evidence |
| Facing switching | Pass as derived-direction evidence |
| State switching | Worker work pass; Militia ready unproven |
| Grounding/selection | Pass in rendered evidence |
| Camera behaviour | Pass |
| Save/load | Pass in opt-in capture harness |
| Rollback | Pass for presentation only |

## Visual scorecard

Worker and Militia readability, grounding, selection, and bounded scale are reviewable. The current single-pose billboards remain visually limited and are not production-ready directional animation. No evidence based on a duplicate frame is used to upgrade that conclusion.

## Production scorecard

Current asset completeness, direction completeness, animation completeness, and wider-faction readiness remain incomplete. The adapter is suitable for continued isolated evidence work, not production-wide conversion.

## Remaining limitations

- The runtime does not expose a genuine Militia ready/hold state in this checkpoint.
- Worker work animation is absent; only runtime work state is proven.
- Directional cards beyond the authored 3/4 source are derived/mirrored.
- Occlusion and visual quality remain review evidence rather than a full production art certification.

## Final decision

**H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN**

The method is not rejected solely because v0.311 evidence failed. Acceptance is withheld because the current runtime does not provide the required Militia ready/hold semantic proof and the current authored directional/animation asset set remains incomplete.

## Exact v0.313

**H3 runtime adapter defect isolation and minimal reproducible gameplay harness.**

## Validation

The dedicated command `npm run godot:validate:salto-h3-evidence-integrity` passes with 154 physical PNGs, 127 unique SHA-256 images, and 128 accepted semantic gameplay records. The v0.311 validator passes. The v0.304-v0.310 retained validators pass from an isolated clean v0.311 validation worktree with the retained runtime evidence restored; v0.303 passes in the v0.312 worktree. The full repository gates also pass: 887 tests, production build, content validation, art-intake validation, runtime-art-slot validation, artifact-retention validation, `npm run godot:all`, and `git diff --check`. The final exact-SHA CI run is recorded after push.

## Final repo state

Branch: `codex/v0215-v0226-recovery`  
Base HEAD: `47982ec6c2eb7d26ceae7e5a511a68402ccdde40`  
Final state: clean and synced with origin, 0 ahead / 0 behind after commit and CI closeout.
