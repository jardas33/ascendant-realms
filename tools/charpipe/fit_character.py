"""Fit a generated character mesh to the game's humanoid rig.

Run: blender -b --factory-startup --python fit_character.py -- <generated.glb> <concept.png> <out.glb> [target_faces] [preview.png]

1. Imports the Hunyuan3D mesh, joins it, scales it to 1.8 m, grounds and
   centres it facing -Y (the rig's forward).
2. Decimates to a game budget.
3. If the mesh has no texture, projects the concept painting onto it from
   the front (the back reuses the same projection, darkened slightly).
4. Estimates joint positions from the silhouette (legs, hips, spine, neck,
   head, shoulders and the arm line) and builds an armature with the same
   22 bone names as the existing Barrosan rig, so Godot's humanoid bone map
   and the shared animation library retarget onto it.
5. Skins with automatic (heat) weights and exports a GLB without clips; the
   unit loads <name>_animations.tres at runtime.
"""
import math
import sys

import bmesh
import bpy
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
SRC, CONCEPT, OUT = argv[0], argv[1], argv[2]
TARGET_FACES = int(argv[3]) if len(argv) > 3 else 14000
PREVIEW = argv[4] if len(argv) > 4 else ""
HEIGHT = 1.8

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
meshes = [o for o in bpy.data.objects if o.type == "MESH" and len(o.data.vertices) > 500]
meshes.sort(key=lambda o: len(o.data.vertices), reverse=True)
for o in bpy.data.objects:
    if o.type == "MESH" and o in meshes:
        # Bake any existing skin/parent pose into plain geometry first.
        o.modifiers.clear()
    o.select_set(o in meshes)
bpy.context.view_layer.objects.active = meshes[0]
if len(meshes) > 1:
    bpy.ops.object.join()
body = bpy.context.view_layer.objects.active
for o in list(bpy.data.objects):
    if o != body:
        bpy.data.objects.remove(o, do_unlink=True)
mw = body.matrix_world.copy()
body.parent = None
body.matrix_world = mw
for vg in list(body.vertex_groups):
    body.vertex_groups.remove(vg)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
had_texture = any(n.type == "TEX_IMAGE" for m in body.data.materials if m and m.use_nodes for n in m.node_tree.nodes)

# ---------------------------------------------------------------- clean
# Merge UV-seam duplicates so the surface is one connected skin (heat weights
# need that), then drop the flat ground sheets the generator bakes from the
# concept's floor shadow.
bm = bmesh.new()
bm.from_mesh(body.data)
bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=0.0008)
bm.verts.ensure_lookup_table()
all_z = [v.co.z for v in bm.verts]
span_z = max(all_z) - min(all_z)
seen = set()
drop = []
for v in bm.verts:
    if v.index in seen:
        continue
    comp, stack = [], [v]
    seen.add(v.index)
    while stack:
        a = stack.pop()
        comp.append(a)
        for e in a.link_edges:
            b = e.other_vert(a)
            if b.index not in seen:
                seen.add(b.index)
                stack.append(b)
    zs = [c.co.z for c in comp]
    xs = [c.co.x for c in comp]
    ys = [c.co.y for c in comp]
    flat_sheet = (max(zs) - min(zs)) < span_z * 0.03 and max(max(xs) - min(xs), max(ys) - min(ys)) > span_z * 0.9
    if flat_sheet or len(comp) < 12:
        drop.extend(comp)
print("FIT_DROPPED_VERTS", len(drop))
bmesh.ops.delete(bm, geom=drop, context="VERTS")
bm.to_mesh(body.data)
bm.free()
body.data.update()

# ---------------------------------------------------------------- normalise
def bounds(obj):
    xs = [v.co.x for v in obj.data.vertices]
    ys = [v.co.y for v in obj.data.vertices]
    zs = [v.co.z for v in obj.data.vertices]
    return Vector((min(xs), min(ys), min(zs))), Vector((max(xs), max(ys), max(zs)))

lo, hi = bounds(body)
dims = hi - lo
# The tallest axis is up; if the generator exported Y-up raw, rotate it.
if dims.y > dims.z * 1.2:
    body.rotation_euler = (math.radians(90), 0, 0)
    bpy.ops.object.transform_apply(rotation=True)
    lo, hi = bounds(body)
s = HEIGHT / (hi.z - lo.z)
for v in body.data.vertices:
    v.co = Vector(((v.co.x - (lo.x + hi.x) * 0.5) * s, (v.co.y - (lo.y + hi.y) * 0.5) * s, (v.co.z - lo.z) * s))
body.data.update()

# Hunyuan3D exports the figure facing glTF +Z, which Blender imports as -Y:
# already the rig's forward, so no flip. Trim the base plate the generator
# grows under the feet: anything within a few cm of the floor that lies
# outside the footprint of the boots.
bm = bmesh.new()
bm.from_mesh(body.data)
plate = [f for f in bm.faces if all(v.co.z < 0.035 * HEIGHT for v in f.verts)
         and any(math.hypot(v.co.x, v.co.y) > 0.26 for v in f.verts)]
print("FIT_PLATE_FACES", len(plate))
bmesh.ops.delete(bm, geom=plate, context="FACES")
loose = [v for v in bm.verts if not v.link_faces]
bmesh.ops.delete(bm, geom=loose, context="VERTS")
bm.to_mesh(body.data)
bm.free()
body.data.update()

# ---------------------------------------------------------------- decimate
if len(body.data.polygons) > TARGET_FACES:
    dec = body.modifiers.new("Decimate", "DECIMATE")
    dec.ratio = TARGET_FACES / len(body.data.polygons)
    bpy.context.view_layer.objects.active = body
    bpy.ops.object.modifier_apply(modifier=dec.name)

# ---------------------------------------------------------------- texture
if not had_texture:
    img = bpy.data.images.load(CONCEPT)
    w, h = img.size
    px = list(img.pixels)
    # Bounding box of the painted figure on the white background.
    x0, x1, y0, y1 = w, 0, h, 0
    for y in range(0, h, 2):
        row = y * w * 4
        for x in range(0, w, 2):
            i = row + x * 4
            if px[i] + px[i + 1] + px[i + 2] < 2.7:
                x0, x1, y0, y1 = min(x0, x), max(x1, x), min(y0, y), max(y1, y)
    lo, hi = bounds(body)
    uv = body.data.uv_layers.new(name="ConceptProjection")
    for loop in body.data.loops:
        co = body.data.vertices[loop.vertex_index].co
        u = (x0 + (co.x - lo.x) / (hi.x - lo.x) * (x1 - x0)) / w
        v = (y0 + (co.z - lo.z) / (hi.z - lo.z) * (y1 - y0)) / h
        uv.data[loop.index].uv = (u, v)
    body.data.uv_layers.active = uv
    mat = bpy.data.materials.new("ConceptPaint")
    mat.use_nodes = True
    nt = mat.node_tree
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    nt.links.new(tex.outputs["Color"], nt.nodes["Principled BSDF"].inputs["Base Color"])
    nt.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.85
    body.data.materials.clear()
    body.data.materials.append(mat)

# ---------------------------------------------------------------- joints
verts = [v.co.copy() for v in body.data.vertices]

def band(zmin, zmax):
    return [p for p in verts if zmin <= p.z <= zmax]

def centroid(ps):
    return sum(ps, Vector()) / max(1, len(ps))

H = HEIGHT
torso_half = max(abs(p.x) for p in band(0.95, 1.05)) if band(0.95, 1.05) else 0.2
left_leg = [p for p in band(0.05, 0.45) if p.x < 0]
right_leg = [p for p in band(0.05, 0.45) if p.x > 0]
lx = centroid(left_leg).x if left_leg else -0.12
rx = centroid(right_leg).x if right_leg else 0.12
# Arm line: vertices well outside the chest, between waist and shoulder height.
chest = band(1.02, 1.12)  # below the outstretched arms
chest_half = sorted(abs(p.x) for p in chest)[int(len(chest) * 0.8)] if chest else 0.2
arm = [p for p in verts if abs(p.x) > chest_half + 0.06 and 0.75 < p.z < 1.55]
reach = max((abs(p.x) for p in arm), default=0.75)
def arm_z(xabs):
    ps = [p.z for p in arm if abs(abs(p.x) - xabs) < 0.04]
    return sum(ps) / len(ps) if ps else 1.35
sh_x = chest_half * 1.0
J = {}
J["Root"] = (Vector((0, 0, 0)), Vector((0, 0, 0.44 * H)))
J["Hips"] = (Vector((0, 0, 0.53 * H)), Vector((0, 0, 0.58 * H)))
J["Spine"] = (Vector((0, 0, 0.58 * H)), Vector((0, 0, 0.72 * H)))
J["Chest"] = (Vector((0, 0, 0.72 * H)), Vector((0, 0, 0.80 * H)))
J["Neck"] = (Vector((0, 0, 0.83 * H)), Vector((0, 0, 0.88 * H)))
J["Head"] = (Vector((0, 0, 0.88 * H)), Vector((0, 0, 1.0 * H)))
for side, sx, lxz in (("Left", -1, lx), ("Right", 1, rx)):
    hip = Vector((lxz, 0, 0.50 * H))
    knee = Vector((lxz, -0.01, 0.28 * H))
    ankle = Vector((lxz, 0.0, 0.055 * H))
    J[side + "UpperLeg"] = (hip, knee)
    J[side + "LowerLeg"] = (knee, ankle)
    J[side + "Foot"] = (ankle, Vector((lxz, -0.10, 0.02)))
    J[side + "Toes"] = (Vector((lxz, -0.10, 0.02)), Vector((lxz, -0.17, 0.02)))
    shoulder = Vector((sx * sh_x, 0, arm_z(sh_x + 0.05)))
    elbow_x = sh_x + (reach - sh_x) * 0.45
    wrist_x = sh_x + (reach - sh_x) * 0.82
    elbow = Vector((sx * elbow_x, 0, arm_z(elbow_x)))
    wrist = Vector((sx * wrist_x, 0, arm_z(wrist_x)))
    tip = Vector((sx * reach, 0, arm_z(reach - 0.02)))
    J[side + "Shoulder"] = (Vector((sx * 0.02, 0, 0.80 * H)), shoulder)
    J[side + "UpperArm"] = (shoulder, elbow)
    J[side + "LowerArm"] = (elbow, wrist)
    J[side + "Hand"] = (wrist, tip)

PARENT = {"Hips": "Root", "Spine": "Hips", "Chest": "Spine", "Neck": "Chest", "Head": "Neck"}
for side in ("Left", "Right"):
    PARENT.update({side + "UpperLeg": "Hips", side + "LowerLeg": side + "UpperLeg", side + "Foot": side + "LowerLeg",
                   side + "Toes": side + "Foot", side + "Shoulder": "Chest", side + "UpperArm": side + "Shoulder",
                   side + "LowerArm": side + "UpperArm", side + "Hand": side + "LowerArm"})

arm_data = bpy.data.armatures.new("Armature")
rig = bpy.data.objects.new("Armature", arm_data)
bpy.context.scene.collection.objects.link(rig)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="EDIT")
for name, (head, tail) in J.items():
    b = arm_data.edit_bones.new(name)
    b.head, b.tail = head, tail if (tail - head).length > 1e-3 else head + Vector((0, 0, 0.05))
for name, parent in PARENT.items():
    arm_data.edit_bones[name].parent = arm_data.edit_bones[parent]
    arm_data.edit_bones[name].use_connect = False
bpy.ops.object.mode_set(mode="OBJECT")
arm_data.bones["Root"].use_deform = False

# ---------------------------------------------------------------- skin
bpy.ops.object.select_all(action="DESELECT")
body.select_set(True)
rig.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.parent_set(type="ARMATURE_AUTO")
unweighted = sum(1 for v in body.data.vertices if not v.groups)
print("FIT_UNWEIGHTED", unweighted, "of", len(body.data.vertices))
if unweighted > len(body.data.vertices) * 0.02:
    # Heat weighting failed on part of the mesh: fall back to envelopes.
    for vg in list(body.vertex_groups):
        body.vertex_groups.remove(vg)
    bpy.ops.object.parent_set(type="ARMATURE_ENVELOPE")
body.name = "Character_Body"

# Lower the arms from the generator's open pose to the Barrosan rig's A-pose
# rest (upper arm ~23 deg from vertical) and bake that as the new rest, so the
# shared clips, authored against that rest, keep the arms by the body.
from mathutils import Matrix
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
for side, sx in (("Left", -1.0), ("Right", 1.0)):
    pb = rig.pose.bones[side + "UpperArm"]
    cur = (pb.tail - pb.head).normalized()
    target = Vector((sx * 0.10, 0.0, -0.24)).normalized()
    rot = cur.rotation_difference(target).to_matrix().to_4x4()
    pivot = pb.head.copy()
    pb.matrix = Matrix.Translation(pivot) @ rot @ Matrix.Translation(-pivot) @ pb.matrix
    bpy.context.view_layer.update()
    print("FIT_ARM", side, tuple(round(c, 3) for c in cur), "->", tuple(round(c, 3) for c in (pb.tail - pb.head).normalized()), "head", tuple(round(c, 3) for c in pb.head))
    for child in (side + "LowerArm", side + "Hand"):
        cb = rig.pose.bones[child]
        cdir = (cb.tail - cb.head).normalized()
        crot = cdir.rotation_difference(Vector((sx * 0.06, -0.05, -1.0)).normalized()).to_matrix().to_4x4()
        cp = cb.head.copy()
        cb.matrix = Matrix.Translation(cp) @ crot @ Matrix.Translation(-cp) @ cb.matrix
        bpy.context.view_layer.update()
bpy.ops.object.mode_set(mode="OBJECT")
bpy.context.view_layer.objects.active = body
mod = next(m for m in body.modifiers if m.type == "ARMATURE")
bpy.ops.object.modifier_apply(modifier=mod.name)
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
bpy.ops.pose.armature_apply(selected=False)
bpy.ops.object.mode_set(mode="OBJECT")
new_mod = body.modifiers.new("Armature", "ARMATURE")
new_mod.object = rig
print("FIT_FACES", len(body.data.polygons), "textured_from_concept", not had_texture)

if PREVIEW:
    scene = bpy.context.scene
    cam = bpy.data.objects.new("Cam", bpy.data.cameras.new("Cam"))
    scene.collection.objects.link(cam)
    cam.location = (1.4, -3.4, 1.4)
    cam.rotation_euler = (math.radians(85), 0, math.radians(22))
    scene.camera = cam
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(50), 0, math.radians(20))
    scene.collection.objects.link(sun)
    scene.world = bpy.data.worlds.new("W")
    scene.world.color = (0.35, 0.37, 0.4)
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x, scene.render.resolution_y = 700, 900
    scene.render.filepath = PREVIEW
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam, do_unlink=True)
    bpy.data.objects.remove(sun, do_unlink=True)

bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_yup=True, export_animations=False,
                          export_skins=True, export_image_format="JPEG", export_jpeg_quality=90)
print("FIT_WRITTEN", OUT)
