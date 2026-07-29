import bpy
import math
import os
from mathutils import Vector

OUT_BLEND = os.environ.get("V0375_BLEND", "art-source/blender/v0375/original_barrosan/barrosan_original_kit.blend")
OUT_GLB = os.environ.get("V0375_GLB", "desktop-spikes/godot-salto/assets/v0375/original_barrosan/barrosan_original_kit.glb")

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT_BLEND = os.path.join(ROOT, OUT_BLEND)
OUT_GLB = os.path.join(ROOT, OUT_GLB)

bpy.ops.wm.read_factory_settings(use_empty=True)

MATERIALS = {}

def material(name, color, roughness=0.88, metallic=0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*color, 1.0)
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    MATERIALS[name] = m
    return m

GRASS = material("Barrosan_Grass", (0.12, 0.21, 0.13))
GRASS_LIGHT = material("Barrosan_Grass_Light", (0.23, 0.31, 0.18))
EARTH = material("Barrosan_Earth", (0.24, 0.16, 0.09))
ROAD = material("Barrosan_Worn_Road", (0.34, 0.23, 0.13))
ROAD_EDGE = material("Barrosan_Road_Edge", (0.18, 0.13, 0.08))
WATER = material("Barrosan_Recessed_Water", (0.045, 0.20, 0.24), 0.30)
WATER_HIGHLIGHT = material("Barrosan_Water_Highlight", (0.10, 0.33, 0.34), 0.26)
BANK = material("Barrosan_Riverbank", (0.30, 0.22, 0.13))
STONE = material("Barrosan_Granite", (0.30, 0.31, 0.29))
STONE_DARK = material("Barrosan_Granite_Shadow", (0.15, 0.17, 0.16))
LIME = material("Barrosan_Limewash", (0.48, 0.46, 0.36))
LIME_DARK = material("Barrosan_Limewash_Shadow", (0.24, 0.24, 0.19))
TIMBER = material("Barrosan_Weathered_Timber", (0.24, 0.13, 0.08))
TIMBER_LIGHT = material("Barrosan_Timber_Light", (0.42, 0.26, 0.13))
SLATE = material("Barrosan_Slate", (0.08, 0.10, 0.11))
SLATE_LIGHT = material("Barrosan_Slate_Edge", (0.16, 0.18, 0.18))
GOLD = material("Barrosan_Gold_Ore", (0.62, 0.43, 0.15), 0.68)
HOSTILE = material("Barrosan_Hostile_Camp", (0.14, 0.12, 0.12))
ACCENT = material("Barrosan_Cerulean_Cloth", (0.16, 0.34, 0.39))
FIRE = material("Barrosan_Campfire", (0.85, 0.30, 0.08), 0.55)
ROOF_RIDGE = material("Barrosan_Roof_Ridge", (0.34, 0.22, 0.13))

def apply_mat(obj, mat):
    if obj.data and hasattr(obj.data, "materials"):
        obj.data.materials.append(mat)

def cube(name, loc, scale, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc)
    o = bpy.context.object
    o.name = name
    o.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_mat(o, mat)
    if bevel:
        mod = o.modifiers.new("Softened_Hand_Tooled_Edges", "BEVEL")
        mod.width = bevel
        mod.segments = 1
    return o

def cylinder(name, loc, radius, depth, mat, vertices=8):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    o = bpy.context.object
    o.name = name
    apply_mat(o, mat)
    return o

def cone(name, loc, radius1, radius2, depth, mat, vertices=8):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=loc)
    o = bpy.context.object
    o.name = name
    apply_mat(o, mat)
    return o

def mesh(name, verts, faces, mat):
    me = bpy.data.meshes.new(name + "_Mesh")
    me.from_pydata(verts, [], faces)
    me.update()
    o = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(o)
    apply_mat(o, mat)
    return o

def terrain_patch(name, left=True):
    verts, faces = [], []
    rows, cols = 16, 7
    for iy in range(rows + 1):
        y = -18.0 + iy * 36.0 / rows
        river_x = 1.1 * math.sin(y * 0.19) + 0.35 * math.sin(y * 0.47)
        edge = river_x - 1.25 if left else river_x + 1.25
        for ix in range(cols + 1):
            t = ix / cols
            x = (-18.0 * (1-t) + edge * t) if left else (edge * (1-t) + 18.0 * t)
            z = 0.22 + 0.13 * math.sin(x * 0.42) + 0.08 * math.cos(y * 0.31) + 0.05 * math.sin((x+y) * 0.8)
            verts.append((x, y, z))
    for iy in range(rows):
        for ix in range(cols):
            a = iy * (cols + 1) + ix
            b = a + 1
            c = a + cols + 2
            d = a + cols + 1
            faces.append((a, b, c, d))
    return mesh(name, verts, faces, GRASS)

def ribbon(name, points, widths, z, mat):
    verts, faces = [], []
    for i, (x, y) in enumerate(points):
        prev = Vector(points[max(0, i-1)])
        nxt = Vector(points[min(len(points)-1, i+1)])
        side = Vector((-(nxt-prev).y, (nxt-prev).x, 0)).normalized() * widths[i] * 0.5
        verts.extend([(x-side.x, y-side.y, z), (x+side.x, y+side.y, z)])
    for i in range(len(points)-1):
        a = i*2
        faces.append((a, a+1, a+3, a+2))
    return mesh(name, verts, faces, mat)

def irregular_rock(name, loc, scale, mat=STONE):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.0, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    apply_mat(o, mat)
    return o

def gable_roof(name, loc, width, length, wall_top, ridge, mat=SLATE):
    x0, x1 = -width/2, width/2
    z0, z1 = wall_top, ridge
    y0, y1 = -length/2, length/2
    verts = [(x0,y0,z0),(0,y0,z1),(x1,y0,z0),(x0,y1,z0),(0,y1,z1),(x1,y1,z0)]
    faces = [(0,1,4,3),(1,2,5,4),(0,3,5,2),(0,2,1),(3,4,5)]
    o = mesh(name, [(x+loc[0],y+loc[1],z+loc[2]) for x,y,z in verts], faces, mat)
    return o

def building(name, loc, width, length, height, roof_height, wall_mat, roof_mat, military=False):
    x,y,z = loc
    base = cube(name+"_Granite_Foundation", (x,y,z+0.22), (width+0.45,length+0.45,0.44), STONE_DARK, 0.08)
    walls = cube(name+"_Limewashed_Walls", (x,y,z+0.22+height/2), (width,length,height), wall_mat, 0.05)
    # side-plane band and exposed timber frame make the volume read at tactical distance.
    cube(name+"_Front_Timber_Beam", (x,y+length/2+0.035,z+height*0.58), (width*0.82,0.08,0.18), TIMBER)
    cube(name+"_Rear_Timber_Beam", (x,y-length/2-0.035,z+height*0.58), (width*0.82,0.08,0.18), TIMBER)
    cube(name+"_Side_Granite_Course", (x+width/2+0.035,y,z+0.62), (0.08,length*0.72,0.16), STONE_DARK)
    for sx in (-width*0.36, width*0.36):
        cube(name+"_Front_Post", (x+sx,y+length/2+0.045,z+height*0.44), (0.14,0.10,height*0.78), TIMBER)
    gable_roof(name+"_Slate_Gable_Roof", (x,y,z), width+0.32, length+0.30, z+height+0.02, z+height+roof_height, roof_mat)
    cube(name+"_Roof_Ridge", (x,y,z+height+roof_height+0.07), (0.20,length+0.34,0.16), ROOF_RIDGE)
    cube(name+"_Door", (x,y+length/2+0.07,z+height*0.35), (width*0.18,0.10,height*0.52), TIMBER_LIGHT, 0.03)
    for sx in (-width*0.28, width*0.28):
        cube(name+"_Window", (x+sx,y+length/2+0.08,z+height*0.60), (width*0.13,0.06,height*0.20), ACCENT, 0.02)
    if military:
        for sx in (-width*0.48, width*0.48):
            cube(name+"_Corner_Buttress", (x+sx,y+length*0.20,z+0.56), (0.28,0.30,1.12), STONE)
        for px in (-width*0.72, width*0.72):
            cylinder(name+"_Yard_Post", (x+px,y-length*0.92,z+0.72), 0.10, 1.45, TIMBER, 6)
            cube(name+"_Yard_Rail", (x+px*0.55,y-length*0.92,z+0.70), (width*0.48,0.10,0.12), TIMBER_LIGHT)
    return base

def tree(name, loc, scale=1.0):
    x,y,z=loc
    cylinder(name+"_Trunk", (x,y,z+0.9*scale), 0.18*scale, 1.8*scale, TIMBER, 7)
    cone(name+"_Lower_Crown", (x,y,z+2.2*scale), 0.95*scale, 0.22*scale, 1.9*scale, GRASS_LIGHT, 7)
    cone(name+"_Upper_Crown", (x,y,z+3.45*scale), 0.68*scale, 0.12*scale, 1.65*scale, GRASS, 7)

def bush(name, loc, scale=1.0):
    for i in range(3):
        irregular_rock(name+"_Leaf_"+str(i), (loc[0]+(i-1)*0.28*scale,loc[1]+(i%2)*0.18*scale,loc[2]+0.35*scale), (0.48*scale,0.42*scale,0.40*scale), GRASS_LIGHT)

def grass_tuft(name, loc, scale=1.0):
    for i in range(3):
        blade = cone(name+"_Blade_"+str(i), (loc[0]+(i-1)*0.11*scale, loc[1]+(i%2)*0.08*scale, loc[2]+0.28*scale), 0.075*scale, 0.012, 0.64*scale, GRASS_LIGHT, 5)
        blade.rotation_euler[1] = (i-1)*0.18

def bridge():
    # A bridge across the north/south stream, with actual deck thickness and stone abutments.
    for x in (-2.8, 2.8):
        for y in (-0.72, 0.72):
            cube("Bridge_Granite_Abutment", (x,y,0.62), (0.78,1.35,0.78), STONE, 0.06)
    for i in range(9):
        x = -3.0 + i*0.75
        cube("Bridge_Timber_Deck_%02d" % i, (x,0,1.16), (0.70,2.35,0.22), TIMBER_LIGHT, 0.025)
        if i % 2 == 0:
            cube("Bridge_Deck_Plank_%02d" % i, (x,0,1.30), (0.10,2.42,0.08), TIMBER)
    for x in (-2.7,-1.35,0,1.35,2.7):
        for y in (-1.18,1.18):
            cylinder("Bridge_Rail_Post", (x,y,1.82), 0.08, 1.15, TIMBER, 6)
        cube("Bridge_Rail", (x,0,1.98), (0.12,2.45,0.12), TIMBER)
    for x in (-1.5, 0, 1.5):
        cylinder("Bridge_Under_Support", (x,0,0.40), 0.20, 0.62, STONE_DARK, 8)

def hostile_camp():
    x,y=8.0,5.4
    cube("Hostile_Camp_Ground", (x,y,0.31), (5.0,4.0,0.12), HOSTILE)
    for px in (x-1.9,x-0.65,x+0.65,x+1.9): cube("Camp_Barricade", (px,y-1.85,0.75), (0.9,0.16,0.8), TIMBER)
    cube("Camp_Shelter_Back", (x,y+0.55,1.0), (2.4,0.22,1.45), HOSTILE)
    gable_roof("Camp_Dark_Shelter_Roof", (x,y+0.55,0), 2.9, 2.2, 1.65, 2.35, HOSTILE)
    cylinder("Camp_Fire_Bowl", (x,y-0.55,0.48), 0.42, 0.18, STONE_DARK, 8)
    cone("Camp_Fire", (x,y-0.55,0.92), 0.30, 0.02, 0.78, FIRE, 6)

def resource_yard():
    x,y=-10.4,1.7
    cube("Worked_Ore_Yard", (x,y,0.30), (4.6,3.5,0.10), EARTH)
    for i,(dx,dy,s) in enumerate(((-0.8,0,1.0),(0.2,0.35,0.75),(1.2,-0.5,0.62))):
        irregular_rock("Gold_Ore_Outcrop_%d"%i,(x+dx,y+dy,0.65*s),(0.72*s,0.55*s,0.60*s),GOLD)
    cube("Ore_Cart", (x+0.9,y+1.0,0.48), (1.2,0.62,0.42), TIMBER_LIGHT, 0.05)
    for wx in (x+0.5,x+1.3): cylinder("Ore_Cart_Wheel", (wx,y+1.0,0.28),0.28,0.12,TIMBER,8).rotation_euler[1]=math.pi/2
    cube("Ore_Wooden_A_Frame", (x-1.0,y-1.0,1.0), (0.12,0.12,1.65), TIMBER)
    cube("Ore_Wooden_A_Cross", (x-1.0,y-1.0,1.65), (1.4,0.12,0.12), TIMBER)

def scene():
    terrain_patch("Original_Grass_Terrain_West", True)
    terrain_patch("Original_Grass_Terrain_East", False)
    # recessed curved water and its irregular raised banks
    river = [(1.1*math.sin(y*0.19)+0.35*math.sin(y*0.47),y) for y in [i*-1.2 for i in range(-15,16)]]
    ribbon("Recessed_Curved_Stream_Water", river, [2.0+0.22*math.sin(i*0.7) for i in range(len(river))], -0.24, WATER)
    left_bank=[]; right_bank=[]
    for x,y in river:
        left_bank.append((x-1.12,y)); right_bank.append((x+1.12,y))
    ribbon("Raised_Stream_Bank_West", left_bank, [0.36+0.1*math.sin(i) for i in range(len(left_bank))], 0.34, BANK)
    ribbon("Raised_Stream_Bank_East", right_bank, [0.34+0.1*math.cos(i) for i in range(len(right_bank))], 0.34, BANK)
    for i,(x,y) in enumerate(river[3:-3:3]):
        irregular_rock("Stream_Stone_%02d"%i,(x-1.25,y,0.44),(0.32,0.45,0.28),STONE)
        irregular_rock("Stream_Stone_E_%02d"%i,(x+1.25,y+0.35,0.42),(0.28,0.34,0.24),STONE_DARK)
    # embedded roads follow the land, terminating at the actual bridge deck.
    ribbon("Embedded_Worn_Road_West", [(-13,-8),(-9,-7),(-6,-5),(-3,-3),(-2,0)], [2.0,1.8,1.7,1.5,1.35],0.43,ROAD)
    ribbon("Embedded_Worn_Road_East", [(2,0),(4,2),(6,4),(8,5)], [1.35,1.5,1.7,1.8],0.43,ROAD)
    ribbon("Embedded_Resource_Track", [(-9,-6),(-10,-3),(-10.4,1.7)], [1.4,1.25,1.5],0.43,ROAD_EDGE)
    building("Main_Hall", (-8.0,-5.5,0.34), 4.5, 4.1, 2.35, 1.75, LIME, SLATE)
    cube("Main_Hall_Civic_Tower", (-9.25,-5.7,3.20), (1.05,1.10,1.60), STONE)
    gable_roof("Main_Hall_Civic_Tower_Roof", (-9.25,-5.7,0.34), 1.25, 1.30, 4.04, 4.72, SLATE_LIGHT)
    cylinder("Main_Hall_Civic_Banner_Pole", (-9.25,-6.38,4.15), 0.035, 2.0, TIMBER, 6)
    cube("Main_Hall_Civic_Banner", (-9.25,-6.38,4.72), (0.38,0.06,0.52), ACCENT)
    building("Field_Barracks", (-4.8,-7.4,0.34), 4.0, 3.2, 2.05, 1.45, LIME_DARK, SLATE, True)
    cylinder("Field_Barracks_Chimney", (-5.75,-7.3,3.18), 0.18, 0.75, STONE_DARK, 7)
    building("Barrosan_House", (-11.0,-6.1,0.34), 3.0, 2.8, 1.65, 1.25, LIME, SLATE_LIGHT)
    bridge()
    resource_yard()
    hostile_camp()
    for i,(x,y,s) in enumerate([(-15,-9,1.2),(-15,8,1.0),(-5,10,0.9),(11,11,1.1),(14,-8,1.0),(14,1,0.8)]): tree("Original_Pine_%02d"%i,(x,y,0.28),s)
    for i,(x,y,s) in enumerate([(-13,-2,0.8),(-3,-10,0.7),(5,9,0.75),(12,-1,0.8),(6,-9,0.65)]): bush("Original_Bush_%02d"%i,(x,y,0.28),s)
    for i,(x,y) in enumerate([(-6,-1),(-2,6),(5,-5),(10,0),(-14,5)]): irregular_rock("Original_Rock_Formation_%02d"%i,(x,y,0.48),(0.7,0.5,0.55),STONE_DARK)
    for i,(x,y,s) in enumerate([(-12,-7,1.0),(-7,-1,0.8),(-2,4,0.9),(4,-4,0.85),(9,0,0.9),(13,7,0.75),(-14,4,0.75)]): grass_tuft("Original_Meadow_Tuft_%02d"%i,(x,y,0.30),s)
    # Limited original props to sell inhabited scale without clutter.
    cube("Settlement_Wood_Pile", (-5.8,-3.6,0.55), (1.4,0.7,0.45), TIMBER_LIGHT, 0.04)
    for i in range(3): cylinder("Settlement_Log_%d"%i,(-5.8,-3.6+i*0.16,0.78+i*0.12),0.14,1.35,TIMBER,7).rotation_euler[1]=math.pi/2

scene()

os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format='GLB', export_cameras=False, export_lights=False, export_materials='EXPORT')
print("V0375_ORIGINAL_BARROSAN_KIT_EXPORTED", OUT_BLEND, OUT_GLB)
