# v0.233R Blender-Authored Modular RTS Environment Kit Pipeline

Status: `PARTIAL`

## Blender execution

- Blender path: `C:\Program Files\Blender Foundation\Blender 5.1\blender.exe`
- Version: `5.1.2`
- Initial command:

```powershell
"C:\Program Files\Blender Foundation\Blender 5.1\blender.exe" `
  -b --python tools/blender/generate_v0233_salto_modular_kit.py
```

The reusable repository command remains:

```powershell
npm run blender:generate:salto-modular-kit
```

## Asset locations

- Blender source: `art-source/blender/v0233/salto_modular_environment_kit.blend`
- Runtime GLB: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb`
- Export metadata: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.export.json`
- Contract: `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.contract.json`

The Blender source intentionally lives outside the Godot project. Godot therefore
imports one canonical runtime asset—the GLB—without invoking its editor-only Blender importer.

## Verified result

- GLB size: 1,728,616 bytes.
- Meshes: 189.
- Exact module roots: 19 / 19.
- Exact materials: 12 / 12.
- Godot import status: `PASS_V0233R_IMPORTED_GLTF`.
- Isolated scene displayed asset: yes.
- Real rendered captures: 6.

## Review path

- scene: `res://scenes/salto_blender_modular_kit_spike.tscn`
- script: `res://scripts/salto_blender_modular_kit_spike.gd`
- private flag: `--salto-blender-modular-kit-spike`
- review pack: `artifacts/manual-review/v0233-blender-modular-kit/`

## Acceptance boundary

The export/import pipeline passes. The art verdict remains `PARTIAL`: the module
family is real and materially more authored than the procedural foundation, but the
floating low-poly showroom does not prove integrated production-quality battlefield art.

Do not reconnect gameplay or begin v0.234 without a new explicit milestone.
