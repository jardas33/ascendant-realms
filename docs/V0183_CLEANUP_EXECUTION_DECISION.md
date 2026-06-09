# v0.183 Cleanup Execution Decision

Status: `PASS_V0183_CLEANUP_EXECUTION_DECISION`

Scope: documentation-only cleanup decision after v0.182. No archive move, broad delete, runtime cleanup, source-art deletion, metadata deletion, fallback deletion, or evidence deletion is authorized in this checkpoint.

## Current Cleanup State

v0.183 cleanup evidence:

- Targeted cleanup dry-run: `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`.
- Cleanup-scope files scanned: `26`.
- Cleanup-scope bytes scanned: `1083549`.
- Known safe sidecar candidates: `0`.
- Unknown cleanup-scope files: `0`.
- Safe-only cleanup application needed: no.

v0.182 cleanup evidence:

- Broad inventory: `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN`.
- Files scanned: `5297`.
- Bytes scanned: `2282856529`.
- Broad safe-delete candidates: `98`.
- Archive candidates: `2967`.
- Manual-review candidates: `665`.
- Targeted cleanup dry-run: `PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN`.
- Targeted unknown cleanup-scope files: `0`.
- Safe-only cleanup: `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`.
- Known sidecars deleted: `18`.
- Deleted bytes: `7719`.
- Retention after cleanup: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.
- Unknown sidecars after cleanup: `0`.

## Decision

Do not execute archive-first cleanup in v0.184.

The safe-only sidecar cleanup has already been completed for the current comparator sidecars. The broad inventory still contains historical packages, old captures, generated evidence, and manual-review candidates. Those files may be large, but they are not safe to delete or archive without an explicit human decision and a narrow command list.

## Retain

Retain:

- Selected Worker, Barracks material, Militia, Aster, Ashen Raider, ground material, and road material derivatives.
- Matching metadata files.
- Tracked diagnostic fallbacks and fallback contracts.
- Latest v0.181 validation/capture/benchmark/boundary evidence.
- Latest v0.182 inventory, cleanup, and retention evidence.
- Unknown/manual-review files.
- Historical evidence until Emmanuel approves a narrower archive/delete packet.

## Future Cleanup Path

If Emmanuel chooses cleanup as a future milestone, the next cleanup prompt should:

- Start from the v0.183 or later clean/synced checkpoint.
- Produce a candidate manifest before any deletion.
- Separate archive moves from deletion.
- Use exact file lists, not broad folder globs.
- Preserve all selected art, active derivatives, metadata, tracked fallbacks, latest required evidence, and unknown files.
- Require a dry-run report and human approval before applying archive/delete commands.

v0.184 should remain a manual review decision packet, not cleanup execution.
