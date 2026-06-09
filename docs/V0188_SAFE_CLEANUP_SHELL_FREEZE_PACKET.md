# v0.188 Safe Cleanup Shell-Freeze Packet

Status: `PASS_V0188_SAFE_CLEANUP_SHELL_FREEZE_PACKET`

Scope: inventory, sidecar scan, cleanup dry-run, safe-only cleanup, retention validation, and shell-freeze recommendation for the current Godot Salto experimental-art evidence set. No selected art, active derivative, metadata, tracked fallback, required evidence, historical review material, or manual-review candidate was broadly deleted or archived.

## Evidence

Ignored v0.188 evidence:

- `artifacts/desktop-spikes/godot-salto/v0188/artifact-inventory/`
- `artifacts/desktop-spikes/godot-salto/v0188/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0188/safe-only-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0188/final-artifact-retention-after-cleanup/`

## Inventory

Broad inventory:

- Status: `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN`.
- Total files scanned: `5607`.
- Total bytes scanned: `2621515570` (`2500.07 MB`).
- Archive candidates: `3217`.
- Manual-review candidates: `684`.
- Unknown cleanup blockers: `0`.
- Safe-delete candidates in broad inventory: `100`.
- Selected evidence hashes recorded: `12`.

The manifest category named `unknown files requiring human review` is treated as manual-review inventory, not a safe-delete class. The cleanup blocker count remained `0`, and no manual-review candidate was deleted.

## Largest Directories

| Directory | Size |
| --- | ---: |
| `desktop-spikes/godot-salto/builds` | 1107.64 MB |
| `artifacts/desktop-spikes/godot-salto/latest` | 208.56 MB |
| `artifacts/desktop-spikes/godot-salto/latest/package-staging` | 101.03 MB |
| `artifacts/desktop-spikes/godot-salto/v0175/evidence/screenshots` | 55.10 MB |
| `artifacts/desktop-spikes/godot-salto/v0180/evidence/screenshots` | 53.83 MB |
| `artifacts/desktop-spikes/godot-salto/v0150/evidence/screenshots` | 13.13 MB |
| `artifacts/desktop-spikes/godot-salto/v0130` | 10.96 MB |
| `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot` | 10.49 MB |
| `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot` | 9.70 MB |
| `artifacts/desktop-spikes/godot-salto/v0184/capture/e2-ground-road-material-opt-in-baseline/screenshots` | 8.61 MB |

## Safe-Only Cleanup

Targeted safe-only cleanup:

- Status: `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`.
- Before: `44` files / `1091268` bytes.
- Deleted: `18` files / `7719` bytes.
- After: `26` files / `1083549` bytes.
- Deleted class: only known Godot-generated comparator `.gd.uid` and fallback `.png.import` sidecars.
- Unknown cleanup-scope files: `0`.
- Tracked files retained: yes.
- Selected sources retained: yes.
- Selected metadata retained: yes.
- Tracked fallbacks retained: yes.
- Latest evidence retained: yes.

Retention after cleanup:

- Status: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.

## Protected Assets

Retain:

- Worker selected derivative and metadata.
- Barracks material selected derivative and metadata.
- Militia selected derivative and metadata.
- Aster selected derivative and metadata.
- Ashen Raider selected derivative and metadata.
- Barrosan foothold ground material selected derivative and metadata.
- Barrosan foothold road material selected derivative and metadata.
- All tracked diagnostic fallbacks and fallback contracts under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.
- Latest v0.187 validation, capture, benchmark, boundary, cleanup, and retention evidence.
- v0.188 inventory, cleanup, and retention evidence.
- Historical review material unless Emmanuel explicitly approves an archive/delete pass.

## Archive And Cleanup Decision

Archive candidates are mostly historical captures, duplicate generated reports, superseded benchmark captures, older local derivatives, and cache/build residue. They are not approved for broad deletion in v0.188.

Recoverable disk estimate from the broad inventory is approximately:

- `1112.14 MB` disposable cache/build residue.
- `481.34 MB` superseded benchmark captures.
- `304.35 MB` duplicate generated reports.
- `164.14 MB` superseded local derivatives.

Future archive-first review command, not executed in v0.188:

```powershell
node scripts/auditSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0188/archive-first-review
```

Use that as the first review step before any future archive/delete command. Do not broad-delete historical evidence or manual-review candidates from this packet alone.

## Rollback

v0.188 made no runtime or launcher changes. To roll back the checkpoint, remove only:

- `docs/V0188_ENVIRONMENT_SHELL_FULL_COHESION_QA.md`
- `docs/V0188_SAFE_CLEANUP_SHELL_FREEZE_PACKET.md`
- `docs/V0188_IMPLEMENTATION_REPORT.md`
- v0.188 entries in standard docs/index files.

Safe-only sidecar cleanup does not require rollback; Godot can regenerate those transient sidecars from tracked source/fallback files.

## Freeze Recommendation

Procedural shell work is frozen for Emmanuel manual review. No new material integration should begin until review. The default launcher remains procedural, and opt-in launchers remain experimental only.
