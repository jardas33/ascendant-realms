# Salto Experimental Artifact Index

Status: `ACTIVE_V0167_RETENTION_INDEX`

This index is the retention source of truth for the Godot Salto experimental-art path. It protects selected local art, active derivatives, metadata, tracked fallbacks, current evidence, and unknown files from broad cleanup.

## Selected Local Source Art And Active Derivatives

| Slot | Current posture | Required file | SHA-256 |
| --- | --- | --- | --- |
| Worker | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_1024.png` | `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc` |
| Barracks material | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0150/local-barracks-material-seam-repair/barrosan_barracks_material_v0149_768_wrapsafe_offset_blend.png` | `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f` |
| Militia | active normal-slice opt-in | `artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_1024.png` | `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb` |
| Aster | selected future candidate, not integrated | `artifacts/desktop-spikes/godot-salto/v0152/local-aster-billboard-repair/aster_billboard_static_v0151_trimmed_1024.png` | `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a` |
| Ashen Raider | selected future candidate, not integrated; preserves hostile slot `ashen_raider_billboard_static_v0156` | `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png` | `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8` |

## Required Metadata

Retain the matching `.metadata.json` files beside each selected derivative above. They protect slot ID, derivative kind, dimensions, alpha bounds, pivot, and hash provenance.

## Tracked Fallbacks

Retain all tracked fallback `.png` and `.contract.json` files under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/` for Worker, Barracks, Militia, Aster, and Ashen Raider.

## Latest Required Evidence

Retain the latest v0.166/v0.167 evidence until a later checkpoint explicitly supersedes it:

- `artifacts/desktop-spikes/godot-salto/v0166/v0166-three-slot-visual-coherence-scorecard.json`
- `artifacts/desktop-spikes/godot-salto/v0166/review/worker-barracks-militia/`
- `artifacts/desktop-spikes/godot-salto/v0166/real-input/worker-barracks-militia-post-mine-flow/`
- `artifacts/desktop-spikes/godot-salto/v0166/artifact-cleanup/`
- `artifacts/desktop-spikes/godot-salto/v0167/`

## Archive Candidates

Older comparator screenshots, older paired-benchmark captures, superseded derivative matrices, and older generated report duplicates are archive candidates only. Do not delete or move them without explicit human approval.

## Safe-Delete Candidates

The only currently approved safe-delete class is known Godot-generated transient sidecars:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/*.gd.uid`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/*.png.import`

Deletion requires the explicit safe-only cleanup path.

## Manual-Review Candidates And Unknown Files

Unknown files are preserved and block cleanup. Broad deletion or archive moves are not authorized by this index.
