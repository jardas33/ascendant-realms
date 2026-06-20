# v0.235 Human/Barrosan Architecture Correction and Beauty Report

Milestone verdict: `PASS`

Overall production-art verdict: `PARTIAL`

## Asset revision

- Blender used: yes, Blender 5.1.2.
- Existing v0.233R/v0.234 GLB modified: no.
- New Blender source: `art-source/blender/v0235/salto_barrosan_architecture_kit.blend`.
- New GLB: `desktop-spikes/godot-salto/assets/v0235/salto_barrosan_architecture_kit.glb`.
- Godot scene: `res://scenes/salto_architecture_correction_beauty_pass.tscn`.
- Corrected building modules: exactly 3.
- Corrected pitched-roof assemblies: exactly 4.
- Corrected keep tower caps: exactly 4.

## Roof correction proof

The keep, barracks, workshop and mine roofs are authored mesh volumes rather than rotated box slabs. Each roof has:

- one highest central ridge line;
- two planes descending from the ridge to opposite eaves;
- eaves extending beyond the wall footprint;
- separate ridge-cap geometry;
- dark eave fascia and gable edge boards;
- no inverted, folded or center-collapsed geometry.

The dedicated gable capture shows both planes and the ridge/eave relationship directly.

## Faction architecture result

- Keep/base: tallest and most stone-heavy landmark, with layered foundations, command gate, tower bands and hipped caps.
- Barracks/workshop: long clay roof, limewashed wall, timber piers/rails/diagonal braces, awning, chimney and work-yard pieces.
- Mine/Lume: lower dark-roof industrial hall with framed mine portal, extraction gantry, pulley, rock piles and Lume crystal well.
- Bridge: retained practical deck and rails with added stone abutments and timber bracing.
- Roads: lowered and darkened into the terrain instead of reading as bright floating panels.

## Honest visual assessment

This is visibly more beautiful and intentional than v0.234 and the roof defect is resolved, so the bounded architecture milestone passes.

It is not production-quality environment art. The scene still exposes repeated terrain tiles, broad flat material fields, sparse foliage and limited surface microvariation. Those limitations keep the overall art direction at `PARTIAL`.

## Evidence

Exact review pack:

`artifacts/manual-review/v0235-architecture-correction-beauty-pass/`

## Boundaries

Gameplay, saves, economy, selection, pathing, commands, minimap, objectives, production, AI, collision, browser runtime, runtime-art slots and default launcher remain unchanged.

Stop after v0.235. Do not begin v0.236 without explicit authorization.
