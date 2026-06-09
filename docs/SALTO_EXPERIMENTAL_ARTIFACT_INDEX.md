# Salto Experimental Artifact Index

Status: `ACTIVE_V0176_RETENTION_INDEX`

This index is the retention source of truth for the Godot Salto experimental-art path. It protects selected local art, active derivatives, metadata, tracked fallbacks, current evidence, and unknown files from broad cleanup.

This v0.176 index supersedes `ACTIVE_V0175_RETENTION_INDEX`, `ACTIVE_V0174_RETENTION_INDEX`, `ACTIVE_V0173_RETENTION_INDEX`, `ACTIVE_V0172_RETENTION_INDEX`, `ACTIVE_V0171_RETENTION_INDEX`, and `ACTIVE_V0170_RETENTION_INDEX` while retaining their protected evidence.

## Selected Local Source Art And Active Derivatives

| Slot | Current posture | Required file | SHA-256 |
| --- | --- | --- | --- |
| Worker | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png` | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Militia | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png` | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Aster | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Ashen Raider | active normal-slice opt-in; slot `ashen_raider_billboard_static_v0156` | `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |
| Barrosan foothold ground material | selected private comparator evidence only; not normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png` | `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8` |

## Required Metadata

Retain the matching `.metadata.json` files beside each selected derivative above. They protect slot ID, derivative kind, dimensions, alpha bounds, pivot, and hash provenance.

## Tracked Fallbacks

Retain all tracked fallback `.png` and `.contract.json` files under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/` for Worker, Barracks, Militia, Aster, Ashen Raider, and the v0.175 private Barrosan foothold ground-material comparator.

## Latest Required Evidence

Retain the latest v0.166/v0.167/v0.168/v0.169/v0.170 evidence until a later checkpoint explicitly supersedes it:

- `artifacts/desktop-spikes/godot-salto/v0166/v0166-three-slot-visual-coherence-scorecard.json`
- `artifacts/desktop-spikes/godot-salto/v0166/review/worker-barracks-militia/`
- `artifacts/desktop-spikes/godot-salto/v0166/real-input/worker-barracks-militia-post-mine-flow/`
- `artifacts/desktop-spikes/godot-salto/v0166/artifact-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0167/`
- `artifacts/desktop-spikes/godot-salto/v0168/`
- `artifacts/desktop-spikes/godot-salto/v0169/`
- `artifacts/desktop-spikes/godot-salto/v0170/`
- `artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/`
- `docs/V0171_FIVE_SLOT_VISUAL_COHESION_QA.md`
- `docs/V0171_FIVE_SLOT_BENCHMARK_FALLBACK_AND_BOUNDARY_REPORT.md`
- `docs/V0171_ARTIFACT_CLEANUP_APPROVAL_PACKET.md`
- `docs/V0171_CHARACTER_INTEGRATION_FREEZE_DECISION.md`
- `docs/V0171_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0172/cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0172/launcher-validation/`
- `docs/V0172_SAFE_CLEANUP_EXECUTION_REPORT.md`
- `docs/V0172_DOCUMENTATION_BUDGET_POLICY.md`
- `docs/V0172_ENVIRONMENT_PHASE_SCORECARD.md`
- `docs/V0172_ENVIRONMENT_PHASE_ROADMAP.md`
- `docs/V0172_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0173/validation/`
- `artifacts/desktop-spikes/godot-salto/v0173/capture/`
- `artifacts/desktop-spikes/godot-salto/v0173/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0173/boundary/`
- `docs/V0173_ENVIRONMENT_SHELL_HARDENING_QA_AND_BENCHMARK.md`
- `docs/V0173_ENVIRONMENT_SHELL_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0173_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0174/validation/`
- `artifacts/desktop-spikes/godot-salto/v0174/capture/`
- `artifacts/desktop-spikes/godot-salto/v0174/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0174/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0174/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0174/artifact-retention/`
- `artifacts/desktop-spikes/godot-salto/v0174/final-safe-only/`
- `artifacts/desktop-spikes/godot-salto/v0174/final-retention/`
- `docs/V0174_TACTICAL_ENVIRONMENT_READABILITY_QA_AND_BENCHMARK.md`
- `docs/V0174_ENVIRONMENT_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0174_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0175/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0175/cleanup-dry-run/`
- `docs/V0175_GROUND_MATERIAL_COMPARATOR_QA_AND_BENCHMARK.md`
- `docs/V0175_PRIVATE_COMPARATOR_BOUNDARY_AND_ROLLBACK.md`
- `docs/V0175_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0176/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0176/artifact-retention/`
- `docs/V0176_TERRAIN_MATERIAL_OPT_IN_READINESS_PACKET.md`
- `docs/V0176_TERRAIN_MATERIAL_RISK_AND_ROLLBACK.md`
- `docs/art-prompts/V0177_01_TERRAIN_MATERIAL_OPT_IN_INTEGRATION.md`
- `docs/V0176_IMPLEMENTATION_REPORT.md`

## Character Integration Freeze

Character-slot expansion is frozen after the selected Worker, Barracks material, Militia, Aster, and Ashen Raider opt-in slots. v0.176 is documentation-only readiness for exactly one future terrain-material opt-in slot. It generated zero images, added zero slots, modified no runtime code, did not import terrain material into the player-facing slice, and did not wire browser runtime. Future work may consider the prepared v0.177 prompt only after v0.176 is clean, pushed, and remote-green.

## Archive Candidates

Older comparator screenshots, older paired-benchmark captures, superseded derivative matrices, and older generated report duplicates are archive candidates only. Do not delete or move them without explicit human approval.

## Safe-Delete Candidates

The only currently approved safe-delete class is known Godot-generated transient sidecars:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/*.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/*.png.import`

Deletion requires the explicit safe-only cleanup path.

## Manual-Review Candidates And Unknown Files

Unknown files are preserved and block cleanup. Broad deletion or archive moves are not authorized by this index.
