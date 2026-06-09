# Salto Experimental Artifact Index

Status: `ACTIVE_V0192_RETENTION_INDEX`

This index is the retention source of truth for the Godot Salto experimental-art path. It protects selected local art, active derivatives, metadata, tracked fallbacks, current evidence, and unknown files from broad cleanup.

This v0.192 index supersedes `ACTIVE_V0191_RETENTION_INDEX`, `ACTIVE_V0190_RETENTION_INDEX`, `ACTIVE_V0189_RETENTION_INDEX`, `ACTIVE_V0188_RETENTION_INDEX`, `ACTIVE_V0187_RETENTION_INDEX`, `ACTIVE_V0186_RETENTION_INDEX`, `ACTIVE_V0185_RETENTION_INDEX`, `ACTIVE_V0184_RETENTION_INDEX`, `ACTIVE_V0183_RETENTION_INDEX`, `ACTIVE_V0182_RETENTION_INDEX`, `ACTIVE_V0181_RETENTION_INDEX`, `ACTIVE_V0180_RETENTION_INDEX`, `ACTIVE_V0179_RETENTION_INDEX`, `ACTIVE_V0178_RETENTION_INDEX`, `ACTIVE_V0177_RETENTION_INDEX`, `ACTIVE_V0176_RETENTION_INDEX`, `ACTIVE_V0175_RETENTION_INDEX`, `ACTIVE_V0174_RETENTION_INDEX`, `ACTIVE_V0173_RETENTION_INDEX`, `ACTIVE_V0172_RETENTION_INDEX`, `ACTIVE_V0171_RETENTION_INDEX`, and `ACTIVE_V0170_RETENTION_INDEX` while retaining their protected evidence.

## Selected Local Source Art And Active Derivatives

| Slot | Current posture | Required file | SHA-256 |
| --- | --- | --- | --- |
| Worker | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png` | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Militia | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png` | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Aster | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Ashen Raider | active normal-slice opt-in; slot `ashen_raider_billboard_static_v0156` | `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |
| Barrosan foothold ground material | active normal-slice environment-material opt-in; not enabled by default | `artifacts/desktop-spikes/godot-salto/v0175/local-ground-material-slot/barrosan_foothold_ground_material_v0175_1024.png` | `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8` |
| Barrosan foothold road material | active normal-slice environment-material opt-in; not enabled by default | `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/barrosan_foothold_road_material_v0180_1024.png` | `a64959ef2fd7a509fcaaa969fca3e095d590d563a4f0c578a5e96d1fb04c0e10` |
| Barrosan wet-granite bridge-riverbank material | selected private-comparator evidence only; not player-facing | `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/barrosan_wet_granite_bridge_riverbank_material_v0189_1024.png` | `638ce153d7a3d39db729dfa13ba05f3fb05c437c2802ab91b5cd248bd2036753` |

## Required Metadata

Retain the matching `.metadata.json` files beside each selected derivative above. They protect slot ID, derivative kind, dimensions, alpha bounds, pivot, and hash provenance.

## Tracked Fallbacks

Retain all tracked fallback `.png` and `.contract.json` files under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/` for Worker, Barracks, Militia, Aster, Ashen Raider, the v0.175 private Barrosan foothold ground-material comparator, the v0.180 private Barrosan foothold road-material comparator, and the v0.189 private Barrosan wet-granite bridge-riverbank material comparator.

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
- `artifacts/desktop-spikes/godot-salto/v0177/validation/`
- `artifacts/desktop-spikes/godot-salto/v0177/capture/`
- `artifacts/desktop-spikes/godot-salto/v0177/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0177/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0177/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0177/artifact-retention/`
- `docs/V0177_GROUND_MATERIAL_OPT_IN_QA_BENCHMARK.md`
- `docs/V0177_GROUND_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0177_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0178/validation/`
- `artifacts/desktop-spikes/godot-salto/v0178/capture/`
- `artifacts/desktop-spikes/godot-salto/v0178/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0178/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0178/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0178/artifact-retention/`
- `docs/V0178_GROUND_MATERIAL_VISUAL_QA_UV_HARDENING.md`
- `docs/V0178_GROUND_MATERIAL_BENCHMARK_BOUNDARY.md`
- `docs/V0178_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0179/validation/`
- `artifacts/desktop-spikes/godot-salto/v0179/capture/`
- `artifacts/desktop-spikes/godot-salto/v0179/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0179/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0179/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0179/artifact-retention/`
- `docs/V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_QA_BENCHMARK.md`
- `docs/V0179_ENVIRONMENT_BOUNDARY_ROLLBACK.md`
- `docs/V0179_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0180/local-road-material-slot/`
- `artifacts/desktop-spikes/godot-salto/v0180/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0180/cleanup-dry-run/`
- `docs/V0180_ROAD_MATERIAL_COMPARATOR_QA_BENCHMARK.md`
- `docs/V0180_PRIVATE_COMPARATOR_BOUNDARY_ROLLBACK.md`
- `docs/V0180_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0181/validation/`
- `artifacts/desktop-spikes/godot-salto/v0181/capture/`
- `artifacts/desktop-spikes/godot-salto/v0181/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0181/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0181/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0181/artifact-retention/`
- `docs/V0181_ROAD_MATERIAL_OPT_IN_QA_BENCHMARK.md`
- `docs/V0181_ROAD_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0181_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0182/artifact-inventory/`
- `artifacts/desktop-spikes/godot-salto/v0182/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0182/safe-only-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0182/artifact-retention/`
- `artifacts/desktop-spikes/godot-salto/v0182/artifact-retention-after-cleanup/`
- `docs/V0182_ENVIRONMENT_FOUNDATION_VISUAL_COHESION_QA.md`
- `docs/V0182_ENVIRONMENT_CLEANUP_FREEZE_PACKET.md`
- `docs/V0182_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0183/cleanup-dry-run/`
- `docs/V0183_POST_FREEZE_NEXT_PHASE_SCORECARD.md`
- `docs/V0183_CLEANUP_EXECUTION_DECISION.md`
- `docs/V0183_IMPLEMENTATION_REPORT.md`
- `docs/art-prompts/V0184_01_RECOMMENDED_NEXT_PHASE.md`
- `artifacts/desktop-spikes/godot-salto/v0184/validation/`
- `artifacts/desktop-spikes/godot-salto/v0184/capture/`
- `artifacts/desktop-spikes/godot-salto/v0184/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0184/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0184/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0184/safe-only-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0184/artifact-retention/`
- `artifacts/desktop-spikes/godot-salto/v0184/artifact-retention-after-cleanup/`
- `docs/V0184_ENVIRONMENT_GEOMETRY_CONVERGENCE_QA_BENCHMARK.md`
- `docs/V0184_ENVIRONMENT_GEOMETRY_BOUNDARY_ROLLBACK.md`
- `docs/V0184_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0185/validation/`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/`
- `artifacts/desktop-spikes/godot-salto/v0185/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0185/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0185/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0185/artifact-retention/`
- `artifacts/desktop-spikes/godot-salto/v0185/final-boundary/`
- `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-safe-only/`
- `docs/V0185_ENVIRONMENT_SHELL_LIVE_QA_AND_BENCHMARK.md`
- `docs/V0185_ENVIRONMENT_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0185_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0186/validation/`
- `artifacts/desktop-spikes/godot-salto/v0186/capture/`
- `artifacts/desktop-spikes/godot-salto/v0186/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0186/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0186/final-boundary/`
- `artifacts/desktop-spikes/godot-salto/v0186/final-cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0186/final-retention/`
- `docs/V0186_STRUCTURE_SHELL_HIERARCHY_QA_BENCHMARK.md`
- `docs/V0186_STRUCTURE_SHELL_BOUNDARY_ROLLBACK.md`
- `docs/V0186_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0187/validation/`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/`
- `artifacts/desktop-spikes/godot-salto/v0187/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0187/boundary/`
- `artifacts/desktop-spikes/godot-salto/v0187/final-boundary/`
- `artifacts/desktop-spikes/godot-salto/v0187/final-cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0187/final-artifact-retention/`
- `docs/V0187_RIVERBANK_BRIDGE_APPROACH_QA_BENCHMARK.md`
- `docs/V0187_RIVERBANK_BRIDGE_BOUNDARY_ROLLBACK.md`
- `docs/V0187_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0188/artifact-inventory/`
- `artifacts/desktop-spikes/godot-salto/v0188/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0188/safe-only-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0188/final-artifact-retention-after-cleanup/`
- `docs/V0188_ENVIRONMENT_SHELL_FULL_COHESION_QA.md`
- `docs/V0188_SAFE_CLEANUP_SHELL_FREEZE_PACKET.md`
- `docs/V0188_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0189/local-bridge-riverbank-material-slot/`
- `artifacts/desktop-spikes/godot-salto/v0189/evidence/`
- `artifacts/desktop-spikes/godot-salto/v0189/cleanup-dry-run/`
- `docs/V0189_BRIDGE_RIVERBANK_MATERIAL_COMPARATOR_QA_BENCHMARK.md`
- `docs/V0189_PRIVATE_COMPARATOR_BOUNDARY_ROLLBACK.md`
- `docs/V0189_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0190/cleanup-dry-run/`
- `docs/V0190_BRIDGE_RIVERBANK_MATERIAL_READINESS_PACKET.md`
- `docs/V0190_BRIDGE_RIVERBANK_RISK_ROLLBACK.md`
- `docs/art-prompts/V0191_01_BRIDGE_RIVERBANK_MATERIAL_OPT_IN.md`
- `docs/V0190_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0191/cleanup-dry-run/`
- `docs/V0191_POST_SHELL_FREEZE_SCORECARD.md`
- `docs/V0191_CLEANUP_EXECUTION_DECISION.md`
- `docs/art-prompts/V0192_01_RECOMMENDED_NEXT_PHASE.md`
- `docs/V0191_IMPLEMENTATION_REPORT.md`
- `artifacts/desktop-spikes/godot-salto/v0192/cleanup-dry-run/`
- `artifacts/desktop-spikes/godot-salto/v0192/artifact-retention/`
- `docs/V0192_PRESENTATION_SHELL_V2_ARCHITECTURE_AUDIT.md`
- `docs/V0192_PRESENTATION_SHELL_V2_CONTRACT_AND_ROLLBACK.md`
- `docs/art-prompts/V0193_01_PRESENTATION_SHELL_V2_IMPLEMENTATION.md`
- `docs/V0192_IMPLEMENTATION_REPORT.md`

## Character Integration Freeze

Character-slot expansion is frozen after the selected Worker, Barracks material, Militia, Aster, and Ashen Raider opt-in slots. v0.192 keeps the existing Barrosan foothold ground-material opt-in slot and the existing Barrosan foothold road-material opt-in slot behind `GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat`, preserves the v0.184 visual-only environment-shell geometry convergence review path, v0.185 visual-only environment-shell live-QA path, v0.186 visual-only procedural structure-shell hierarchy hardening path, and v0.187 visual-only procedural riverbank/bridge approach hardening path behind `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat`. The v0.189 wet-granite bridge-riverbank material remains private-comparator-only because human review deferred that integration until shell geometry is stronger. No bridge/riverbank/structure material slot is integrated by v0.192, no shell-v2 runtime implementation exists yet, no water shader pipeline is added, the default launcher remains procedural, browser runtime remains untouched, and the legacy shell is preserved as comparator/fallback.

## Archive Candidates

Older comparator screenshots, older paired-benchmark captures, superseded derivative matrices, and older generated report duplicates are archive candidates only. Do not delete or move them without explicit human approval.

## Safe-Delete Candidates

The only currently approved safe-delete class is known Godot-generated transient sidecars:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/*.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/*.png.import`

Deletion requires the explicit safe-only cleanup path.

## Manual-Review Candidates And Unknown Files

Unknown files are preserved and block cleanup. v0.192 cleanup dry run must remain comparator-scope and fail closed on unknown files; v0.191, v0.190, and v0.189 found `0` cleanup unknown blockers in the comparator-scope dry runs. The `684` manual-review candidates from the v0.188 broad inventory remain preserved and are not safe-delete candidates. Broad deletion or archive moves are not authorized by this index.
