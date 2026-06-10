# v0.204 Structure Shell Material Binding Report

Status: `PASS_V0204_STRUCTURE_SHELL_MATERIAL_BINDING_REPORT`

v0.204 binds the selected v0.202 Barrosan structure-finish material only to the isolated shell-v2 review posture. The default launcher, legacy shell, browser runtime, gameplay systems, character slots, and production runtime-art slot counts remain unchanged.

## Selected Material

- Candidate: `STRUCTURE_FINISH_MATERIAL_LOCAL_1024`
- Source checkpoint: `v0.202`
- Selected derivative: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.png`
- Metadata: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0202\local-structure-finish-material-slot\barrosan_structure_finish_material_v0202_1024.metadata.json`
- SHA-256: `94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef`
- Provenance: private-comparator-only, player-slice production approval forbidden, browser integration forbidden, runtime art slot added false.

## Binding Scope

The material is enabled only with the v0.204 shell-v2 structure-material review flag and only after the v0.203 shell-v2 environmental-cohesion posture is active.

Allowed structure families:

- Command Hall wall, timber, and roof planes
- West Stone Cut mine retaining stone, tier, and timber support planes
- Barracks wall, roof, scaffold, and restored-state shell planes

Excluded surfaces:

- Terrain, roads, road shoulders, river water, riverbanks, bridge deck, bridge abutments, Lume visuals, HUD, minimap, site markers, character billboards, legacy shell, default launcher, browser runtime, and production manifests.

## Visual Result

Normal RTS overview shows a stronger practical Barrosan structure identity without broad material masks. Command Hall reads as the main anchor, the mine remains a utility/resource structure, and the Barracks remains distinct while restoring and restored. The selected UV scale remains restrained enough to avoid giant scaling, stretched panels, and distracting seam repetition in the review captures.

Manual review PNG pack:

`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0204-structure-shell-material\`

Required files:

- `01_before_after_structures.png`
- `02_overview.png`
- `03_command_hall.png`
- `04_mine.png`
- `05_barracks_restoring.png`
- `06_barracks_restored.png`
- `07_material_scale_seam_diagnostic.png`
- `08_missing_hash_mismatch_fallback.png`

## Fallback Behavior

The selected material fails closed to the prior shell-v2 visual presentation when art is missing or when the expected hash does not match. Fallback validation covered both a missing source path and an intentional expected-hash mismatch. No unknown substitute art is loaded.

## Evidence

- Identity report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0204\validation\structure-material-identity-report.json`
- Runtime validation report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0204\validation\structure-shell-material-validation-report.json`
- Capture report: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0204\capture\structure-shell-material-capture-report.json`
- Boundary scan: `D:\Code for projects\WB game like\ascendant-realms\artifacts\desktop-spikes\godot-salto\v0204\boundary\structure-shell-material-boundary-report.json`
