"""Author the timber and gold resource sites.

Run: blender -b --factory-startup --python generateTimberAndGoldNodes.py -- <rock_texture.jpg> <out_dir>
Writes resource_timber_stack.glb (a stacked log pile with ringed end grain,
stakes, a chopping stump with an axe and wood chips) and
resource_gold_vein.glb (a rock outcrop split by glowing gold veins with an
ore pile and a pickaxe). Y-up GLBs, origin at base centre. Colours are
authored in sRGB and converted to linear for the Principled BSDF.
"""
import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector, noise

argv = sys.argv[sys.argv.index("--") + 1:]
TEXTURE, OUT_DIR = argv[0], argv[1]


def lin(c):
    return tuple(x ** 2.2 for x in c)


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def flat(name, col, rough=0.9, emit=None, strength=0.0, metal=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*lin(col), 1.0)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*lin(emit), 1.0)
        b.inputs["Emission Strength"].default_value = strength
    return m


def image_mat(name, img, tint=(1, 1, 1), rough=0.9):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0
    mix.inputs["B"].default_value = (*lin(tint), 1.0)
    nt.links.new(tex.outputs["Color"], mix.inputs["A"])
    nt.links.new(mix.outputs["Result"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = rough
    return m


def obj_from(bm, name, mats):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    for m in mats:
        me.materials.append(m)
    o = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(o)
    return o


def export(path):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", export_yup=True, use_selection=True)
    print("wrote", path)


# ---------------------------------------------------------------- timber
def end_grain_image():
    n = 128
    img = bpy.data.images.new("EndGrain", n, n)
    px = []
    for y in range(n):
        for x in range(n):
            dx, dy = (x - n / 2) / (n / 2), (y - n / 2) / (n / 2)
            r = math.hypot(dx, dy) + 0.04 * math.sin(math.atan2(dy, dx) * 5)
            ring = 0.5 + 0.5 * math.sin(r * 38.0)
            base = (0.80, 0.62, 0.40) if r < 0.9 else (0.30, 0.20, 0.12)
            k = 0.82 + 0.18 * ring
            c = lin(tuple(ch * k for ch in base))
            px.extend((*c, 1.0))
    img.pixels = px
    img.pack()
    return img


def build_timber():
    reset()
    rng = random.Random(41)
    bark = flat("Bark", (0.34, 0.23, 0.15), 0.95)
    grain = image_mat("EndGrain", end_grain_image(), rough=0.8)
    stake = flat("Stake", (0.30, 0.21, 0.13), 0.9)
    chips = flat("Chips", (0.78, 0.60, 0.38), 0.9)
    iron = flat("AxeIron", (0.42, 0.42, 0.44), 0.45, metal=0.6)

    def log(center, length, radius, yaw, tilt=0.0):
        bm = bmesh.new()
        geom = bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=radius, radius2=radius * 0.94, depth=length)
        for v in geom["verts"]:
            # Knobbly bark.
            d = Vector((v.co.x, v.co.y, 0))
            if d.length > 0.01:
                v.co += d.normalized() * noise.noise(v.co * 3.0 + Vector((rng.random() * 9, 0, 0))) * radius * 0.12
        uv_layer = bm.loops.layers.uv.verify()
        for f in bm.faces:
            f.material_index = 1 if abs(f.normal.z) > 0.9 else 0
            if abs(f.normal.z) > 0.9:
                for loop in f.loops:
                    loop[uv_layer].uv = (0.5 + loop.vert.co.x / (radius * 2.1), 0.5 + loop.vert.co.y / (radius * 2.1))
        o = obj_from(bm, "Log", [bark, grain])
        o.rotation_euler = (math.pi / 2, tilt, yaw)
        o.location = center
        return o

    # Stacked pile, 4-3-2 logs, between two pairs of stakes.
    r = 0.24
    length = 3.0
    y = 0.0
    for row, count in enumerate([4, 3, 2]):
        for i in range(count):
            x = (i - (count - 1) / 2) * r * 2.05
            log(Vector((x, 0.0, r + row * r * 1.75)), length * rng.uniform(0.93, 1.0), r * rng.uniform(0.9, 1.08), 0.0)
    for sx in (-1, 1):
        for sy in (-1, 1):
            bm = bmesh.new()
            bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=0.06, radius2=0.045, depth=1.3)
            o = obj_from(bm, "Stake", [stake])
            o.location = (sx * 1.1, sy * 1.0, 0.65)
            o.rotation_euler = (sy * -0.12, sx * 0.08, 0)
    # A loose log and the chopping stump with an axe.
    log(Vector((-1.2, 1.7, r * 0.95)), 2.2, r * 0.95, 0.5)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=0.38, radius2=0.34, depth=0.55)
    uv_layer = bm.loops.layers.uv.verify()
    for f in bm.faces:
        f.material_index = 1 if f.normal.z > 0.9 else 0
        if f.normal.z > 0.9:
            for loop in f.loops:
                loop[uv_layer].uv = (0.5 + loop.vert.co.x / 0.8, 0.5 + loop.vert.co.y / 0.8)
    stump = obj_from(bm, "Stump", [bark, grain])
    stump.location = (1.3, 1.6, 0.275)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.05, 0.85), verts=bm.verts)
    handle = obj_from(bm, "AxeHandle", [stake])
    handle.location = (1.3, 1.45, 0.85)
    handle.rotation_euler = (0.55, 0.0, 0.3)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.22, 0.05, 0.13), verts=bm.verts)
    head = obj_from(bm, "AxeHead", [iron])
    head.location = (1.36, 1.64, 0.6)
    head.rotation_euler = (0.55, 0.0, 0.3)
    # Wood chips.
    bm = bmesh.new()
    for i in range(40):
        a = rng.random() * math.tau
        d = rng.uniform(0.3, 1.1)
        g = bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.scale(bm, vec=(0.09, 0.05, 0.015), verts=g["verts"])
        bmesh.ops.rotate(bm, verts=g["verts"], cent=(0, 0, 0), matrix=Matrix.Rotation(rng.random() * math.tau, 3, "Z"))
        bmesh.ops.translate(bm, verts=g["verts"], vec=(1.3 + math.cos(a) * d, 1.6 + math.sin(a) * d, 0.01))
    obj_from(bm, "Chips", [chips])
    export(os.path.join(OUT_DIR, "resource_timber_stack.glb"))


# ------------------------------------------------------------------ gold
def build_gold():
    reset()
    rng = random.Random(77)
    img = bpy.data.images.load(TEXTURE)
    rock = image_mat("VeinRock", img, (0.86, 0.82, 0.76), 0.9)
    rock_dark = image_mat("VeinRockDark", img, (0.66, 0.62, 0.58), 0.92)
    gold = flat("GoldVein", (1.0, 0.76, 0.28), 0.25, emit=(1.0, 0.70, 0.25), strength=1.6, metal=0.8)
    ore = flat("GoldOre", (0.86, 0.62, 0.22), 0.35, emit=(1.0, 0.65, 0.2), strength=0.5, metal=0.7)
    wood = flat("Handle", (0.42, 0.28, 0.16), 0.9)
    iron = flat("PickIron", (0.40, 0.40, 0.42), 0.5, metal=0.6)

    def boulder(center, size, seed, mat_i):
        bm = bmesh.new()
        geom = bmesh.ops.create_icosphere(bm, subdivisions=3, radius=1.0)
        off = Vector((seed * 2.9, seed * 1.3, seed * 4.1))
        for v in geom["verts"]:
            d = v.co.normalized()
            co = d + d * noise.noise(d * 1.6 + off) * 0.28
            co = Vector((co.x * size.x, co.y * size.y, max(co.z, -0.3) * size.z))
            v.co = co
        uv = bm.loops.layers.uv.verify()
        for f in bm.faces:
            f.material_index = mat_i
            for loop in f.loops:
                c = loop.vert.co
                loop[uv].uv = (c.x * 0.35 + c.z * 0.2, c.y * 0.35 + c.z * 0.2)
        o = obj_from(bm, "Rock", [rock, rock_dark])
        o.location = center
        return o

    boulder(Vector((0, 0, 0.0)), Vector((1.6, 1.3, 1.9)), 1, 0)
    boulder(Vector((1.4, 0.6, 0.0)), Vector((0.9, 0.8, 1.1)), 2, 1)
    boulder(Vector((-1.2, -0.7, 0.0)), Vector((0.8, 0.9, 0.9)), 3, 1)

    # Gold veins: clusters of elongated crystals breaking out of the rock.
    bm = bmesh.new()
    spots = [(0.3, -1.0, 1.1), (-0.6, -0.9, 0.7), (0.9, -0.5, 1.4), (1.6, 0.0, 0.8), (-1.3, -1.2, 0.5), (0.0, -0.6, 1.8)]
    for sx, sy, sz in spots:
        for k in range(rng.randint(3, 5)):
            g = bmesh.ops.create_cone(bm, cap_ends=True, segments=5, radius1=0.15, radius2=0.0, depth=rng.uniform(0.6, 1.1))
            d = Vector((sx, sy * 1.2, 0.4)).normalized()
            d = (d + Vector((rng.uniform(-0.4, 0.4), rng.uniform(-0.4, 0.4), rng.uniform(0, 0.5)))).normalized()
            rot = d.to_track_quat("Z", "Y").to_matrix()
            bmesh.ops.rotate(bm, verts=g["verts"], cent=(0, 0, 0), matrix=rot)
            bmesh.ops.translate(bm, verts=g["verts"], vec=(sx * 1.25 + rng.uniform(-0.15, 0.15), sy * 1.3 + rng.uniform(-0.15, 0.15), sz * 1.05 + rng.uniform(-0.1, 0.1)))
    obj_from(bm, "GoldVeins", [gold])

    # Ore pile and a pickaxe at the foot of the vein.
    bm = bmesh.new()
    for i in range(22):
        g = bmesh.ops.create_icosphere(bm, subdivisions=1, radius=rng.uniform(0.07, 0.14))
        a = rng.random() * math.tau
        d = rng.uniform(0.0, 0.5)
        bmesh.ops.translate(bm, verts=g["verts"], vec=(0.4 + math.cos(a) * d, -2.0 + math.sin(a) * d * 0.7, 0.08 + (0.5 - d) * 0.25))
    obj_from(bm, "OrePile", [ore])
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=(0.05, 0.05, 0.95), verts=bm.verts)
    h = obj_from(bm, "PickHandle", [wood])
    h.location = (-0.5, -1.9, 0.3)
    h.rotation_euler = (1.2, 0.0, 0.6)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=4, radius1=0.05, radius2=0.0, depth=0.8)
    p = obj_from(bm, "PickHead", [iron])
    p.location = (-0.78, -1.6, 0.45)
    p.rotation_euler = (0.0, 1.57, 0.6)
    export(os.path.join(OUT_DIR, "resource_gold_vein.glb"))


build_timber()
build_gold()
