# v0.233 Blender-Authored Modular RTS Environment Kit Pipeline

Status: `BLOCKED_FOR_LOCAL_BLENDER_EXPORT`

## Tooling result

Blender is not installed or callable in the current execution environment. The check covered:

- `blender` on `PATH`;
- Blender Foundation 3.6 through 4.4 standard installation folders;
- Windows uninstall registry entries;
- user-local Programs and WindowsApps locations;
- Scoop and Chocolatey locations;
- common Steam libraries.

No installer or asset was downloaded because the milestone explicitly requires an honest blocked result when Blender is unavailable.

## Checked-in authoring source

The complete procedural authoring source is:

`tools/blender/generate_v0233_salto_modular_kit.py`

It defines nineteen named modules and twelve named material slots, applies bevel/chamfer modifiers, separates roofs/walls/foundations, creates contact layers, and exports both:

- `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.blend`
- `desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb`

Expected command:

```powershell
blender --background --factory-startup `
  --python tools/blender/generate_v0233_salto_modular_kit.py -- `
  --output=desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb
```

The repository wrapper is:

```powershell
npm run blender:generate:salto-modular-kit
```

## Godot importer scaffold

The isolated importer is:

- scene: `res://scenes/salto_blender_modular_kit_spike.tscn`;
- script: `res://scripts/salto_blender_modular_kit_spike.gd`;
- private flag: `--salto-blender-modular-kit-spike`.

The importer expects the tracked GLB path from the asset contract. The current blocked execution emits `BLOCKED_FOR_LOCAL_BLENDER_EXPORT` and does not substitute the v0.232 primitive scene.

## Acceptance boundary

This checkpoint is not a visual PASS. It creates no `.blend`, no `.glb`, no imported Godot asset and no visual improvement over v0.232.

The quality gate may be reopened only after a real Blender export exists and Godot visibly imports it. Until then:

- no production-art claim;
- no v0.234;
- no gameplay reconnection;
- no engine change;
- no replacement primitive scene presented as authored art.
