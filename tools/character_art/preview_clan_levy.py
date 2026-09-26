"""Render honest neutral-light turntable stills for the production Clan Levy."""

import bpy
import json
import math
from pathlib import Path
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
MODEL = ROOT / "production/ascendant-realms-godot/assets/characters/barrosan_clan_levy/barrosan_clan_levy.glb"
OUT = Path(r"D:\CodexData\evidence\astra-character-quality-r1")
OUT.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(MODEL))
print("ACTIONS=" + json.dumps([a.name for a in bpy.data.actions]))
print("MATERIALS=" + json.dumps([{"name": m.name, "nodes": [(n.type, getattr(getattr(n, 'image', None), 'filepath', None)) for n in m.node_tree.nodes] if m.use_nodes else []} for m in bpy.data.materials]))

world = bpy.context.scene.world
world.color = (0.16, 0.19, 0.22)
world.use_nodes = True
world.node_tree.nodes.get("Background").inputs[0].default_value = (0.18, 0.22, 0.25, 1)
world.node_tree.nodes.get("Background").inputs[1].default_value = 0.7

def area(name, loc, power, size):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = power
    data.shape = "DISK"
    data.size = size
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = loc
    obj.rotation_euler = (Vector((0, 0, 0.9)) - obj.location).to_track_quat("-Z", "Y").to_euler()

area("Key", (3, -4, 5), 600, 4)
area("Fill", (-3, -1, 3), 260, 5)
area("Rim", (0, 3, 4), 800, 3)

camera_data = bpy.data.cameras.new("Review Camera")
camera = bpy.data.objects.new("Review Camera", camera_data)
bpy.context.collection.objects.link(camera)
bpy.context.scene.camera = camera
camera_data.type = "ORTHO"
camera_data.ortho_scale = 2.6

scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 48
scene.render.resolution_x = 840
scene.render.resolution_y = 960
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.film_transparent = False
scene.view_settings.view_transform = "AgX"

for name, loc in [("front", (2.8, -4.8, 2.5)), ("back", (-2.8, 4.8, 2.5)), ("rts", (3, -4.8, 6.5))]:
    camera.location = loc
    camera.rotation_euler = (Vector((0, 0, 0.9)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = str(OUT / f"baseline_{name}.png")
    bpy.ops.render.render(write_still=True)
    print("RENDERED=" + scene.render.filepath)
