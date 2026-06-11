# v0.219 Structure Shell Production Report

Status: PASS

v0.219 replaces the most blocky structure reads in the isolated Salto presentation-reboot shell-v2 path with restrained Barrosan foothold structure shells. The default stabilized launcher remains procedural, the legacy structure presentation remains available as a comparator, and the selected v0.202 structure-finish material is bound only inside the opt-in review path.

## Runtime Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoStructureShellProductionWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoStructureShellProductionWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoStructureShellProductionBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoStructureShellProductionTool.mjs`

## Selected Material

- Slot: `STRUCTURE_FINISH_MATERIAL_LOCAL_1024`
- Source: `artifacts/desktop-spikes/godot-salto/v0202/local-structure-finish-material-slot/barrosan_structure_finish_material_v0202_1024.png`
- Metadata: `artifacts/desktop-spikes/godot-salto/v0202/local-structure-finish-material-slot/barrosan_structure_finish_material_v0202_1024.metadata.json`
- SHA-256: `94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef`
- Provenance: private-comparator-only v0.202 derivative; no new image generation or downloaded asset.

## Structure Notes

- The selected path adds 50 bounded structure-shell production nodes, under the 96-node review budget.
- Command Hall now uses a stone base, wall planes, side wings, gable roof planes, timber posts, ridge beam, porch threshold, buttresses and a small warm hearth pin.
- West Stone Cut mine now reads as a utility site with quarry shadow, retaining stone tiers, timber gantry, inactive marker and active-site banner when controlled.
- Barracks now has separated wall wings, scaffold, readable roof states, a damaged gap/rubble cue, progress read, restored cap, entry trim, lantern and weapon rack.
- Aether support remains visually distinct from Barrosan structure finish through a small stone plinth, timber roof and Lume-colored pin.
- Structure locations, footprints, click targets, selection states, bridge shell, route topology and gameplay semantics are preserved.

## Comparator And Fallbacks

Fallback validation passed for:

- default procedural launcher with no presentation reboot request;
- selected v0.219 structure shell with approved v0.202 material;
- legacy structure-shell comparator through `--salto-structure-shell-legacy-comparator`;
- missing structure-finish material fallback;
- hash-mismatch structure-finish material fallback.

The selected benchmark averaged `75.28` FPS with p95 frame time `13.31` ms. The legacy structure comparator averaged `75.02` FPS with p95 frame time `13.40` ms. The selected p95 frame-time ratio was `0.993`.

## Review Pack

Manual review PNGs:

- `artifacts/manual-review/v0219-structure-shells/01_structure_overview.png`
- `artifacts/manual-review/v0219-structure-shells/02_command_hall.png`
- `artifacts/manual-review/v0219-structure-shells/03_barracks_damaged.png`
- `artifacts/manual-review/v0219-structure-shells/04_barracks_restoring.png`
- `artifacts/manual-review/v0219-structure-shells/05_barracks_restored.png`
- `artifacts/manual-review/v0219-structure-shells/06_mine_site.png`
- `artifacts/manual-review/v0219-structure-shells/07_aether_support.png`
- `artifacts/manual-review/v0219-structure-shells/08_units_beside_structures.png`
- `artifacts/manual-review/v0219-structure-shells/09_old_new_contact_sheet.png`

## Boundaries

- Generated images: zero.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

Decision: selected. The reboot structure shells now read more like practical Barrosan foothold architecture while preserving fallback and comparator paths.
