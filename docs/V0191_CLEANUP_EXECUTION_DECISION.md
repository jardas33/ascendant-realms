# v0.191 Cleanup Execution Decision

Status: `PASS_V0191_CLEANUP_EXECUTION_DECISION`

Scope: documentation-only cleanup decision after v0.190. No archive move, broad delete, runtime cleanup, source-art deletion, metadata deletion, fallback deletion, or evidence deletion is authorized in this checkpoint.

## Current Cleanup State

v0.190 cleanup evidence:

- Targeted cleanup dry-run: `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`.
- Unknown cleanup-scope files: `0`.
- Safe-delete candidates: `0`.
- Deletion attempted: `false`.
- Safe-only cleanup application needed: no.

v0.189 cleanup evidence:

- Targeted cleanup dry-run: `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`.
- Cleanup-scope files scanned: `29`.
- Cleanup-scope bytes scanned: `1315968`.
- Known safe sidecar candidates: `0`.
- Unknown cleanup-scope files: `0`.
- Safe-only cleanup application needed: no.

v0.188 broad inventory evidence remains preserved:

- Broad inventory: `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN`.
- Files scanned: `5607`.
- Bytes scanned: `2500.07 MB`.
- Archive candidates: `3217`.
- Manual-review candidates: `684`.
- Broad cleanup unknown blockers: `0`.
- Safe-only cleanup already deleted exactly `18` known Godot sidecars / `7719` bytes.
- Retention after cleanup: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.

## Decision

Do not execute archive-first cleanup in v0.192.

The current targeted comparator cleanup scope is clean, and the broad inventory still contains historical screenshots, packages, old captures, generated evidence, and manual-review candidates. These files are not safe to delete or archive without explicit human approval and an exact candidate manifest.

## Retain

Retain:

- Selected Worker, Barracks material, Militia, Aster, Ashen Raider, ground material, road material, and bridge-riverbank material derivatives.
- Matching metadata files.
- Tracked diagnostic fallbacks and fallback contracts.
- Latest v0.188, v0.189, v0.190, and v0.191 evidence.
- Historical review material.
- Unknown/manual-review files.

## Future Cleanup Path

If Emmanuel chooses cleanup as a future milestone, the next cleanup prompt should:

- Start from a clean/synced checkpoint.
- Produce a candidate manifest before any deletion.
- Separate archive moves from deletion.
- Use exact file lists, not broad folder globs.
- Preserve all selected art, active derivatives, metadata, tracked fallbacks, latest required evidence, historical review material, and unknown files.
- Require dry-run proof and human approval before applying archive/delete commands.

v0.192 should focus on the recommended bridge-riverbank material opt-in integration, not cleanup execution.
