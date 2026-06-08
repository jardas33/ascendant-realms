# Pre-v0.166 Godot Generated Sidecar Audit

Start HEAD: `0fbc91132f8f2f7a887e98ba75e46550edc4a9c2`

Start sync state: `HEAD...@{u} = 0 0`

## Inventory

All untracked files were under `desktop-spikes/godot-salto/comparators/runtime_art_pipeline`.

### SAFE_IGNORE_GENERATED_SIDECAR

- `ashen_raider_billboard_single_slot_comparator.gd.uid`
- `ashen_raider_visual_restraint_replacement_comparator.gd.uid`
- `aster_billboard_single_slot_comparator.gd.uid`
- `barracks_material_seam_repair_comparator.gd.uid`
- `barracks_material_single_slot_comparator.gd.uid`
- `hybrid_mixed_combat_readability_stress_comparator.gd.uid`
- `militia_billboard_single_slot_comparator.gd.uid`
- `runtime_art_pipeline_comparator.gd.uid`
- `worker_billboard_single_slot_comparator.gd.uid`
- `fallback/ashen_raider_billboard_static_v0156_fallback.png.import`
- `fallback/aster_billboard_static_v0151_fallback.png.import`
- `fallback/barrosan_barracks_material_v0149_fallback.png.import`
- `fallback/militia_billboard_static_v0154_fallback.png.import`
- `fallback/worker_billboard_static_v0147_fallback.png.import`

## Reasoning

The repository intentionally tracks core Godot `.gd.uid` files in `scripts/` and `tests/`, and a scaffold test covers one of those stable core script sidecars. The untracked comparator `.gd.uid` files are different: no tracked source references their UID values, and the comparator scripts are loaded by explicit `res://comparators/runtime_art_pipeline/*.gd` paths. Their UID contents are generated sidecar identifiers, not deterministic source inputs for the normal Salto slice.

The untracked `.png.import` files are Godot import remap sidecars for tracked fallback PNGs. They point to `res://.godot/imported/*.ctex`, and `.godot/` is already ignored. No tracked source references the `.png.import` files. The tracked fallback PNGs and their contract JSON files remain preserved.

## Resolution

The exact untracked sidecars above are safe generated residue. They are deleted during the unblock and ignored narrowly so future Godot validation can regenerate them without dirtying the repository. No selected local art, selected derivatives, metadata, tracked fallbacks, launchers, gameplay code, browser runtime, saves, stable IDs, or visual posture are modified.
