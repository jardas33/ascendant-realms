"""Read-only geometry inventory for the production Clan Levy GLB."""

import bpy
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
MODEL = ROOT / "production/ascendant-realms-godot/assets/characters/barrosan_clan_levy/barrosan_clan_levy.glb"
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(MODEL))

items = []
for obj in bpy.data.objects:
    if obj.type not in {"MESH", "ARMATURE"}:
        continue
    entry = {
        "name": obj.name,
        "type": obj.type,
        "parent": obj.parent.name if obj.parent else None,
        "dimensions": [round(v, 3) for v in obj.dimensions],
        "location": [round(v, 3) for v in obj.location],
        "materials": [m.name for m in obj.data.materials] if obj.type == "MESH" else [],
        "vertices": len(obj.data.vertices) if obj.type == "MESH" else None,
        "triangles": sum(len(p.vertices) - 2 for p in obj.data.polygons) if obj.type == "MESH" else None,
        "bones": [b.name for b in obj.data.bones] if obj.type == "ARMATURE" else [],
        "vertex_groups": [g.name for g in obj.vertex_groups] if obj.type == "MESH" else [],
    }
    items.append(entry)
print("CHARACTER_INVENTORY=" + json.dumps(items))
print("IMAGES=" + json.dumps([{"name": i.name, "size": list(i.size), "packed": bool(i.packed_file)} for i in bpy.data.images]))
print("ACTIONS=" + json.dumps([a.name for a in bpy.data.actions]))
arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
print("KEY_BONES=" + json.dumps({name: {"head": [round(v, 3) for v in arm.data.bones[name].head_local], "tail": [round(v, 3) for v in arm.data.bones[name].tail_local]} for name in ["Hips", "Spine", "Chest", "UpperChest", "Neck", "Head", "LeftShoulder", "RightShoulder", "LeftUpperArm", "RightUpperArm"]}))
