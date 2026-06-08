# v0.171 Artifact Cleanup Approval Packet

Status: `PASS_V0171_ARTIFACT_CLEANUP_PACKET`

This packet records the v0.171 artifact hygiene review and the safe-only cleanup actually executed. It deletes only positively identified Godot-generated sidecars and preserves selected local art, active derivatives, metadata, tracked fallbacks, current evidence, historical evidence, and unknown files.

## Corrected Retention Scope

The v0.171 pass hardened the cleanup/audit tools so the selected evidence list now protects all five active selected derivatives and their metadata:

| Slot | Selected derivative SHA-256 |
| --- | --- |
| Worker | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Militia | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Aster | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Ashen Raider | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |

The retention validator now reports five selected active derivatives, five metadata records, and five tracked fallback pairs retained.

## Inventory Summary

Evidence: `artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/final-audit/salto-experimental-artifact-inventory.json`

- Status: `PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN`
- Total scanned files: `4540`
- Total scanned bytes: `1601825587`
- Dry-run safe-delete candidates: `61` files, `640663720` bytes.
- Dry-run archive candidates: `2402` files, `538861438` bytes.
- Manual-review candidates: `595` files, `369216531` bytes.

The broad safe-delete/archive/manual numbers are inventory only. They are not approval for broad deletion or archive moves.

Largest directories:

- `desktop-spikes/godot-salto/builds`: `632588049` bytes.
- `artifacts/desktop-spikes/godot-salto/latest`: `218203713` bytes.
- `artifacts/desktop-spikes/godot-salto/latest/package-staging`: `105442817` bytes.
- `artifacts/desktop-spikes/godot-salto/v0150/evidence/screenshots`: `13771045` bytes.
- `artifacts/desktop-spikes/godot-salto/v0130`: `11487430` bytes.
- `artifacts/desktop-spikes/godot-salto/v0168/real-input/worker-barracks-militia-aster-restart-replay/screenshots`: `8488384` bytes.
- `artifacts/desktop-spikes/godot-salto/v0165/real-input/worker-barracks-militia-restart-replay/screenshots`: `8482811` bytes.
- `artifacts/desktop-spikes/godot-salto/v0163/real-input/worker-barracks-restart-replay/screenshots`: `8169795` bytes.

## Safe-Only Cleanup Executed

Evidence: `artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/post-five-slot-safe-only/salto-experimental-cleanup-report.json`

- Status: `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`
- Deleted files: `14`
- Deleted bytes: `5505`
- Unknown files after cleanup: `0`
- Remaining cleanup-scope files after cleanup: tracked required files only.

Deleted files:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_billboard_single_slot_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/aster_billboard_single_slot_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_seam_repair_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/barracks_material_single_slot_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png.import`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png.import`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png.import`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png.import`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png.import`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/hybrid_mixed_combat_readability_stress_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/militia_billboard_single_slot_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/worker_billboard_single_slot_comparator.gd.uid`

Final dry-run evidence: `artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/final-dry-run/salto-experimental-cleanup-report.json` reports no remaining safe sidecar candidates or unknown files in the cleanup scope.

## Retain

- Selected local source derivatives and metadata for Worker, Barracks, Militia, Aster, and Ashen Raider.
- Tracked fallback `.png` and `.contract.json` files under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/`.
- Current required evidence from v0.166 through v0.171.
- Historical comparator evidence until an explicit archive-first approval is issued.
- Unknown files.

## Future Cleanup Command

Use only when the repository is clean/synced and the prompt explicitly authorizes safe-only cleanup:

```text
npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/future-safe-only --apply-safe-only
```

## Rollback Notes

The executed deletion removed only Godot-generated `.gd.uid` and `.png.import` sidecars. They are regenerable by Godot validation/export flows. No selected art, derivative, metadata, tracked fallback, tracked source, tracked document, or latest required evidence was deleted.
