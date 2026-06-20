# v0.233 Blender Modular Kit Target

This directory contains the runtime-facing asset contract and exported GLB.

v0.233R produced the real GLB with Blender 5.1.2 and verified its isolated
Godot import. The current art verdict is `PARTIAL`.

Expected local outputs after running the checked-in authoring script:

- `salto_modular_environment_kit.glb`

The Blender authoring source is kept outside the Godot project so Godot has one
canonical import path and does not invoke its editor-only `.blend` importer:

- `art-source/blender/v0233/salto_modular_environment_kit.blend`
- `salto_modular_environment_kit.export.json`

The Godot importer scene fails closed when the GLB is absent. No substitute primitive scene is treated as v0.233 art.
