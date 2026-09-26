"""Export the editable Groveheart source with Blender 5.2.1.

From the Godot project directory:
    blender --background --factory-startup --python tools/blender/exportLioraenGroveheart.py

The .blend sits outside the Godot project to avoid triggering its native
Blender importer. It packs its bark and canopy images, so this export does not depend on
the artist's machine. The gameplay building ID and footprint live separately
in scripts/game/building_defs.gd.
"""

import os
from pathlib import Path

import bpy


project = Path(__file__).resolve().parents[2]
source = project.parent.parent / "art-source/lioraen_groveheart_ancient_bough_r1.blend"
output = Path(os.environ.get(
    "ASCENDANT_GROVEHEART_OUTPUT",
    str(project / "assets/environment/buildings/lioraen_groveheart_ancient_bough_r1.glb"),
))

bpy.ops.wm.open_mainfile(filepath=str(source))
bpy.ops.object.select_all(action="DESELECT")
meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
assert len(meshes) == 14, f"Expected the optimized 14-mesh source, got {len(meshes)}"
for obj in meshes:
    obj.select_set(True)
bpy.context.view_layer.objects.active = meshes[0]
bpy.ops.export_scene.gltf(
    filepath=str(output), export_format="GLB", use_selection=True, export_apply=True
)
print(f"GROVEHEART_EXPORTED {output} meshes={len(meshes)} bytes={output.stat().st_size}")
