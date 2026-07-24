import bpy
import math
import os
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_BLEND = os.path.join(ROOT, "art-source/blender/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.blend")
OUT_GLB = os.path.join(ROOT, "desktop-spikes/godot-salto/assets/v0377/terrain-infrastructure/barrosan_terrain_infrastructure_v0377.glb")
ITERATION = int(os.environ.get("V0377_ITERATION", "1"))

bpy.ops.wm.read_factory_settings(use_empty=True)
MATERIALS = {}


def material(name, color, roughness=0.88):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1.0)
    value.use_nodes = True
    bsdf = value.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    MATERIALS[name] = value
    return value


GRASS = material("Barrosan_Stage1_Grass", (0.145, 0.205, 0.105))
GRASS_DARK = material("Barrosan_Stage1_Grass_Dark", (0.075, 0.115, 0.072))
GRASS_LIGHT = material("Barrosan_Stage1_Grass_Light", (0.235, 0.275, 0.135))
MEADOW = material("Barrosan_Stage1_Meadow", (0.19, 0.245, 0.12))
EARTH = material("Barrosan_Stage1_Compacted_Earth", (0.235, 0.145, 0.072))
ROAD = material("Barrosan_Stage1_Worn_Road", (0.17, 0.095, 0.042))
ROAD_DARK = material("Barrosan_Stage1_Road_Wear", (0.085, 0.052, 0.032))
WET = material("Barrosan_Stage1_Wet_Bank", (0.075, 0.105, 0.082))
WET_LIGHT = material("Barrosan_Stage1_Wet_Bank_Light", (0.145, 0.155, 0.105))
RIVERBED = material("Barrosan_Stage1_Riverbed", (0.065, 0.105, 0.095))
WATER = material("Barrosan_Stage1_Subdued_Water", (0.025, 0.105, 0.135), 0.44)
WATER_GLINT = material("Barrosan_Stage1_Water_Glint", (0.07, 0.19, 0.19), 0.38)
GRANITE = material("Barrosan_Stage1_Granite", (0.255, 0.255, 0.22))
GRANITE_DARK = material("Barrosan_Stage1_Granite_Dark", (0.105, 0.115, 0.105))
MOSS = material("Barrosan_Stage1_Moss", (0.15, 0.205, 0.105))
TIMBER = material("Barrosan_Stage1_Bridge_Timber", (0.205, 0.105, 0.042))
TIMBER_DARK = material("Barrosan_Stage1_Bridge_Timber_Dark", (0.095, 0.045, 0.022))


def apply_material(obj, mat):
    if obj.data and hasattr(obj.data, "materials"):
        obj.data.materials.append(mat)


def mesh(name, verts, faces, materials, indices=None):
    data = bpy.data.meshes.new(name + "_Mesh")
    data.from_pydata(verts, [], faces)
    data.update()
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    mats = materials if isinstance(materials, list) else [materials]
    for mat in mats:
        data.materials.append(mat)
    if indices:
        for polygon, index in zip(data.polygons, indices):
            polygon.material_index = min(index, len(mats) - 1)
    if name.startswith(("Continuous_", "Recessed_", "Subdued_", "Irregular_Wet_")):
        for polygon in data.polygons:
            polygon.use_smooth = True
    return obj


def cube(name, loc, scale, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_material(obj, mat)
    if bevel:
        modifier = obj.modifiers.new("HandTooledEdge", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
    return obj


def cylinder(name, loc, radius, depth, mat, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    apply_material(obj, mat)
    return obj


def cone(name, loc, radius1, radius2, depth, mat, vertices=6):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=loc)
    obj = bpy.context.object
    obj.name = name
    apply_material(obj, mat)
    return obj


def rock(name, loc, scale, mat=GRANITE):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_material(obj, mat)
    return obj


def river_x(y):
    return 1.15 * math.sin(y * 0.16) + 0.42 * math.sin(y * 0.39) + 0.16 * math.sin(y * 0.71)


def river_width(y):
    return 1.55 + 0.30 * math.sin(y * 0.23 + 0.5) + 0.18 * math.cos(y * 0.44)


def terrain_z(x, y):
    value = 0.30 + 0.10 * math.sin(x * 0.18 + 0.4) + 0.10 * math.cos(y * 0.21)
    value += 0.14 * math.sin((x + y) * 0.11)
    value += 0.52 * math.exp(-((x + 13.0) ** 2 + (y - 11.0) ** 2) / 58.0)
    value += 0.42 * math.exp(-((x - 15.0) ** 2 + (y + 10.0) ** 2) / 78.0)
    value += 0.26 * math.exp(-((x + 3.0) ** 2 + (y + 19.0) ** 2) / 42.0)
    return value


def bank_land(name, side):
    rows, cols = 48, 20
    verts, faces, indices = [], [], []
    for iy in range(rows + 1):
        y = -38.0 + iy * 76.0 / rows
        cx = river_x(y)
        width = river_width(y)
        inner = cx - width - 1.5 if side < 0 else cx + width + 1.5
        outer = -38.0 + 1.2 * math.sin(y * 0.17) if side < 0 else 38.0 + 1.2 * math.sin(y * 0.17)
        for ix in range(cols + 1):
            t = ix / cols
            x = outer * (1.0 - t) + inner * t if side < 0 else inner * (1.0 - t) + outer * t
            z = terrain_z(x, y)
            z += 0.06 * math.sin(ix * 0.8 + iy * 0.31 + side)
            verts.append((x, y, z))
    for iy in range(rows):
        for ix in range(cols):
            a = iy * (cols + 1) + ix
            faces.append((a, a + 1, a + cols + 2, a + cols + 1))
            zone = math.sin(x * 0.17 + 0.65 * math.sin(y * 0.11 + side))
            zone += 0.42 * math.cos(y * 0.23 + x * 0.06)
            indices.append(1 if zone < -0.82 else 2 if zone > 0.86 else 0)
    return mesh(name, verts, faces, [GRASS, GRASS_DARK, GRASS_LIGHT], indices)


def river_channel():
    rows, cols = 52, 8
    verts, faces, indices = [], [], []
    for iy in range(rows + 1):
        y = -40.0 + iy * 80.0 / rows
        cx, width = river_x(y), river_width(y)
        for ix in range(cols + 1):
            t = ix / cols - 0.5
            x = cx + t * width * 2.0
            z = -0.92 + 0.07 * math.sin(y * 0.37 + ix * 0.8)
            verts.append((x, y, z))
    for iy in range(rows):
        for ix in range(cols):
            a = iy * (cols + 1) + ix
            faces.append((a, a + 1, a + cols + 2, a + cols + 1))
            indices.append(0)
    return mesh("Recessed_Riverbed_Continuous", verts, faces, [RIVERBED, GRANITE_DARK], indices)


def water_surface():
    rows, cols = 52, 6
    verts, faces, indices = [], [], []
    for iy in range(rows + 1):
        y = -40.0 + iy * 80.0 / rows
        cx, width = river_x(y), river_width(y)
        for ix in range(cols + 1):
            t = ix / cols - 0.5
            x = cx + t * width * 1.75
            z = -0.73 + 0.018 * math.sin(y * 0.42 + ix * 1.7)
            verts.append((x, y, z))
    for iy in range(rows):
        for ix in range(cols):
            a = iy * (cols + 1) + ix
            faces.append((a, a + 1, a + cols + 2, a + cols + 1))
            indices.append(0)
    return mesh("Subdued_Water_Surface", verts, faces, [WATER, WATER_GLINT], indices)


def bank_slopes():
    for side, label in [(-1, "West"), (1, "East")]:
        rows = 52
        verts, faces, indices = [], [], []
        for iy in range(rows + 1):
            y = -40.0 + iy * 80.0 / rows
            cx, width = river_x(y), river_width(y)
            edge = cx + side * width * 0.88
            outer = cx + side * (width + 1.62 + 0.24 * math.sin(y * 0.33 + side))
            wet_x = edge + side * 0.16
            mid_x = edge + side * 0.78
            verts.extend([
                (edge, y, -0.67 + 0.05 * math.sin(y * 0.4)),
                (mid_x, y, -0.35 + 0.08 * math.sin(y * 0.23 + side)),
                (outer, y, terrain_z(outer, y) - 0.015),
            ])
        for iy in range(rows):
            a = iy * 3
            faces.extend([(a, a + 1, a + 4, a + 3), (a + 1, a + 2, a + 5, a + 4)])
            zone = math.sin(y * 0.22 + side * 1.4) + 0.35 * math.cos(y * 0.47)
            indices.extend([1 if zone > 0.96 else 0, 2 if zone < -0.74 else 0])
        mesh("Irregular_Wet_Bank_Slope_" + label, verts, faces, [WET, WET_LIGHT, EARTH], indices)


def road_segment(name, points, widths):
    verts, faces, indices = [], [], []
    for i, (x, y) in enumerate(points):
        prev = Vector(points[max(i - 1, 0)])
        nxt = Vector(points[min(i + 1, len(points) - 1)])
        direction = (nxt - prev).normalized()
        normal = Vector((-direction.y, direction.x, 0.0))
        width = widths[i]
        # Keep the worn surface visibly seated on the land mesh. The small lift
        # prevents the coarse terrain interpolation from swallowing road spans
        # between authored control points while remaining below bridge deck level.
        base = terrain_z(x, y) + 0.18
        verts.extend([
            (x - normal.x * width * 0.5, y - normal.y * width * 0.5, base - 0.005),
            (x + normal.x * width * 0.5, y + normal.y * width * 0.5, base - 0.005),
        ])
    for i in range(len(points) - 1):
        a = i * 2
        faces.append((a, a + 1, a + 3, a + 2))
        wear = math.sin(i * 0.82 + points[i][1] * 0.12)
        indices.append(1 if wear > 0.35 else 0)
    return mesh(name, verts, faces, [ROAD, ROAD_DARK], indices)


def grass_tuft(name, loc, scale=1.0):
    for i in range(3):
        blade = cone(name + "_Blade_%02d" % i, (loc[0] + (i - 1) * 0.10 * scale, loc[1] + (i % 2) * 0.07 * scale, loc[2] + 0.24 * scale), 0.06 * scale, 0.012, 0.56 * scale, GRASS_LIGHT, 5)
        blade.rotation_euler[1] = (i - 1) * 0.17


def reeds(name, loc, scale=1.0):
    for i in range(5):
        blade = cone(name + "_Reed_%02d" % i, (loc[0] + (i - 2) * 0.11 * scale, loc[1] + (i % 2) * 0.08 * scale, loc[2] + 0.34 * scale), 0.045 * scale, 0.01, 0.75 * scale, GRASS_DARK, 5)
        blade.rotation_euler[1] = (i - 2) * 0.14


def bridge():
    for x in (-3.75, 3.75):
        for y in (-0.98, 0.98):
            rock("Bridge_Granite_Abutment_Rubble", (x, y, 0.18), (0.80, 0.72, 0.52), GRANITE_DARK)
            cube("Bridge_Granite_Abutment_Block", (x, y, 0.63), (0.92, 1.12, 0.76), GRANITE, 0.08)
            cube("Bridge_Granite_Abutment_Cap", (x, y, 1.05), (1.04, 1.22, 0.16), GRANITE_DARK, 0.04)
    for i in range(12):
        x = -3.65 + i * 0.665
        cube("Bridge_Timber_Deck_Plank_%02d" % i, (x, 0.0, 1.07), (0.60, 3.05, 0.20), TIMBER, 0.025)
        if i % 3 == 0:
            cube("Bridge_Deck_Wear_Band_%02d" % i, (x, 0.0, 1.18), (0.075, 3.08, 0.045), TIMBER_DARK)
    for x in (-3.2, -1.6, 0.0, 1.6, 3.2):
        for y in (-1.58, 1.58):
            cylinder("Bridge_Railing_Post", (x, y, 1.72), 0.075, 1.15, TIMBER_DARK, 6)
        cube("Bridge_Railing_Left_%02d" % int((x + 3.2) * 10), (x, -1.58, 2.08), (0.11, 0.11, 0.11), TIMBER_DARK)
        cube("Bridge_Railing_Right_%02d" % int((x + 3.2) * 10), (x, 1.58, 2.08), (0.11, 0.11, 0.11), TIMBER_DARK)
    cube("Bridge_Railing_West_Run", (0.0, -1.58, 2.05), (6.65, 0.11, 0.14), TIMBER)
    cube("Bridge_Railing_East_Run", (0.0, 1.58, 2.05), (6.65, 0.11, 0.14), TIMBER)
    for x in (-1.65, 0.0, 1.65):
        cube("Bridge_Under_Timber_Beam_%02d" % int((x + 1.65) * 10), (x, 0.0, 0.50), (0.24, 3.10, 0.25), TIMBER_DARK)


def infrastructure_dressing():
    rocks = [(-19, 10, 0.9, 0.7), (-16, 13, 1.1, 0.8), (-11, 18, 0.9, 0.65), (11, 16, 1.1, 0.75), (17, 11, 0.8, 0.6), (18, -9, 1.0, 0.75), (14, -14, 1.2, 0.8), (-14, -15, 0.8, 0.6), (-20, -7, 1.0, 0.7), (-8, 8, 0.7, 0.55), (7, -3, 0.72, 0.52), (-4.0, -6.0, 0.62, 0.46), (4.0, 7.0, 0.58, 0.42), (-3.4, 12.0, 0.7, 0.46), (3.0, -17.0, 0.64, 0.48)]
    for i, (x, y, sx, sy) in enumerate(rocks):
        rock("Highland_Stone_Formation_%02d" % i, (x, y, terrain_z(x, y) + 0.36), (sx, sy, 0.45 + (i % 3) * 0.14), GRANITE if i % 3 else GRANITE_DARK)
        if i % 2 == 0:
            rock("Moss_On_Stone_%02d" % i, (x + 0.10, y - 0.12, terrain_z(x, y) + 0.70), (sx * 0.45, sy * 0.35, 0.08), MOSS)
    reeds_data = [(-1.7, -12), (0.9, -7), (-1.1, -3.7), (1.8, 4.2), (-0.6, 9.2), (1.2, 15.5), (-1.4, 21.0)]
    for i, (x, y) in enumerate(reeds_data):
        reeds("River_Reed_Cluster_%02d" % i, (x + river_x(y), y, -0.25), 0.9 + (i % 3) * 0.14)
    tufts = [(-17, 8), (-12, 5), (-8, 12), (6, 9), (13, 7), (20, 2), (17, -5), (-17, -11), (-10, -18), (8, -15), (22, -17)]
    for i, (x, y) in enumerate(tufts):
        grass_tuft("Highland_Grass_Cluster_%02d" % i, (x, y, terrain_z(x, y) + 0.02), 0.8 + (i % 4) * 0.13)
    for i, (x, y) in enumerate([(-23, 18), (24, 16), (-26, -18), (26, -20), (20, 23), (-18, -25)]):
        for j in range(2):
            grass_tuft("Boundary_Meadow_%02d_%02d" % (i, j), (x + j * 0.45, y + 0.35 * j, terrain_z(x, y) + 0.02), 1.1)


def build_scene():
    bank_land("Continuous_Highland_Land_West", -1)
    bank_land("Continuous_Highland_Land_East", 1)
    river_channel()
    water_surface()
    bank_slopes()
    road_segment("Embedded_Road_West_Approach", [(-36, -20), (-33, -19), (-29, -16.8), (-25, -14.6), (-21, -12.6), (-17, -10), (-13.5, -8), (-10.5, -6), (-7.5, -3.8), (-5.5, -1.8), (-3.7, 0)], [3.25, 3.15, 3.05, 2.9, 2.75, 2.58, 2.45, 2.4, 2.5, 2.85, 3.65])
    road_segment("Embedded_Road_East_Approach", [(3.7, 0), (5.2, 0.6), (7.2, 1.6), (9.3, 3.0), (11.7, 4.6), (14.5, 6.8), (17.3, 8.9), (20.5, 11.4), (24.5, 14.2), (29, 16.8), (36, 19)], [3.65, 2.9, 2.6, 2.45, 2.4, 2.45, 2.55, 2.7, 2.85, 3.05, 3.25])
    road_segment("Embedded_Road_Upper_Threshold", [(-29, 19), (-26.5, 18.2), (-23, 16.6), (-20, 15.0), (-17, 13.0), (-14.5, 11.0), (-12, 9.0), (-10, 7.0), (-8, 5.0), (-6.4, 3.2), (-5.0, 1.8), (-3.7, 0)], [2.75, 2.65, 2.55, 2.4, 2.3, 2.2, 2.12, 2.08, 2.05, 2.2, 2.6, 3.65])
    bridge()
    infrastructure_dressing()
    if ITERATION >= 2:
        for x, y in [(-21, -4), (-8, -13), (10, -12), (19, 4), (5, 18)]:
            rock("Iteration_02_Bank_Rubble", (x, y, terrain_z(x, y) + 0.24), (0.50, 0.42, 0.32), GRANITE_DARK)
    if ITERATION >= 3:
        for x, y in [(-5.8, -1.0), (4.9, 1.8), (-2.8, 0.65), (2.6, -0.4)]:
            reeds("Iteration_03_Bridge_Wet_Cluster", (x, y, -0.26), 1.1)
        for x, y in [(-5.8, -1.5), (5.2, 1.2), (-4.4, 0.8), (4.0, -0.7)]:
            rock("Iteration_03_Landing_Stone", (x, y, 0.70), (0.36, 0.28, 0.22), GRANITE)
    if ITERATION >= 4:
        for x, y in [(-24, -15), (-20, 14), (18, 14), (24, -14), (-9, 19), (10, -20)]:
            rock("Iteration_04_Shelf_Outcrop", (x, y, terrain_z(x, y) + 0.58), (0.95, 0.62, 0.60), GRANITE)
    if ITERATION >= 5:
        for i, (x, y) in enumerate([(-2.35, -18), (1.45, -15), (-1.85, -10), (2.1, -4), (-2.05, 5), (1.72, 10), (-2.3, 17), (1.9, 23)]):
            rock("Iteration_05_River_Edge_Stone_%02d" % i, (x + river_x(y), y, -0.26), (0.42 + (i % 3) * 0.12, 0.30, 0.22), GRANITE_DARK if i % 2 else GRANITE)
            reeds("Iteration_05_River_Edge_Reed_%02d" % i, (x * 0.78 + river_x(y), y + 0.24, -0.22), 0.72 + (i % 2) * 0.12)
        for i, (x, y) in enumerate([(-28, -10), (-24, 8), (-14, 20), (14, 20), (24, 7), (28, -8), (11, -20), (-12, -22)]):
            grass_tuft("Iteration_05_Meadow_Clump_%02d" % i, (x, y, terrain_z(x, y) + 0.02), 1.0 + (i % 3) * 0.14)
    if ITERATION >= 6:
        for i, (x, y) in enumerate([(-6.2, -2.2), (6.4, 2.1), (-7.4, 4.6), (7.0, 6.2), (-13.0, -5.0), (14.0, 8.0), (-17.0, 3.0), (18.0, -3.0)]):
            rock("Iteration_06_Road_Contact_Stone_%02d" % i, (x, y, terrain_z(x, y) + 0.22), (0.32 + (i % 2) * 0.15, 0.23, 0.18), GRANITE_DARK)
        for i, (x, y) in enumerate([(-30, -16), (-22, -4), (-15, 11), (15, 14), (23, 4), (30, 16), (20, -12), (-18, -19)]):
            grass_tuft("Iteration_06_Road_Edge_Grass_%02d" % i, (x, y, terrain_z(x, y) + 0.025), 0.9 + (i % 3) * 0.16)


build_scene()
os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format="GLB", export_cameras=False, export_lights=False, export_materials="EXPORT")
print("V0377_BARROSAN_TERRAIN_INFRASTRUCTURE_EXPORTED", ITERATION, OUT_BLEND, OUT_GLB)
