import bpy
import math
import os
from mathutils import Vector

OUT_BLEND = os.environ.get("V0376_BLEND", "art-source/blender/v0376/original_barrosan/barrosan_original_kit_v0376.blend")
OUT_GLB = os.environ.get("V0376_GLB", "desktop-spikes/godot-salto/assets/v0376/original_barrosan/barrosan_original_kit_v0376.glb")

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

GRASS = material("Barrosan_Grass", (0.16, 0.25, 0.15))
GRASS_LIGHT = material("Barrosan_Grass_Light", (0.31, 0.38, 0.20))
GRASS_DARK = material("Barrosan_Grass_Shadow", (0.09, 0.16, 0.11))
YARD = material("Barrosan_Settlement_Yard", (0.34, 0.27, 0.16))
EARTH = material("Barrosan_Earth", (0.29, 0.18, 0.10))
ROAD = material("Barrosan_Worn_Road", (0.27, 0.18, 0.11))
ROAD_EDGE = material("Barrosan_Road_Edge", (0.16, 0.12, 0.08))
WATER = material("Barrosan_Recessed_Water", (0.035, 0.16, 0.20), 0.30)
WATER_HIGHLIGHT = material("Barrosan_Water_Highlight", (0.08, 0.29, 0.31), 0.26)
BANK = material("Barrosan_Riverbank", (0.25, 0.17, 0.10))
BANK_DARK = material("Barrosan_Wet_Bank", (0.13, 0.12, 0.09))
STONE = material("Barrosan_Granite", (0.36, 0.35, 0.30))
STONE_DARK = material("Barrosan_Granite_Shadow", (0.12, 0.14, 0.14))
LIME = material("Barrosan_Limewash", (0.62, 0.56, 0.40))
LIME_DARK = material("Barrosan_Limewash_Shadow", (0.30, 0.27, 0.20))
TIMBER = material("Barrosan_Weathered_Timber", (0.22, 0.11, 0.06))
TIMBER_LIGHT = material("Barrosan_Timber_Light", (0.44, 0.25, 0.11))
SLATE = material("Barrosan_Slate", (0.075, 0.085, 0.09))
SLATE_LIGHT = material("Barrosan_Slate_Edge", (0.19, 0.20, 0.18))
GOLD = material("Barrosan_Gold_Ore", (0.56, 0.32, 0.08), 0.68)
GOLD_SEAM = material("Barrosan_Gold_Seam", (0.80, 0.48, 0.10), 0.65)
HOSTILE = material("Barrosan_Hostile_Camp", (0.10, 0.075, 0.065))
HOSTILE_GROUND = material("Barrosan_Hostile_Worked_Ground", (0.13, 0.10, 0.075))
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
    rows, cols = 22, 9
    for iy in range(rows + 1):
        y = -24.0 + iy * 48.0 / rows
        river_x = 1.1 * math.sin(y * 0.19) + 0.35 * math.sin(y * 0.47)
        edge = river_x - 1.25 if left else river_x + 1.25
        for ix in range(cols + 1):
            t = ix / cols
            outer = -24.0 + 1.1 * math.sin(y * 0.23) + 0.6 * math.sin(y * 0.51) if left else 24.0 + 1.1 * math.sin(y * 0.23) + 0.6 * math.sin(y * 0.51)
            x = (outer * (1-t) + edge * t) if left else (edge * (1-t) + outer * t)
            shelf = 0.22 + 0.20 * math.sin(x * 0.24) + 0.16 * math.cos(y * 0.22)
            shelf += 0.18 * math.exp(-((x + 7.0) ** 2 + (y + 5.0) ** 2) / 70.0)
            shelf += 0.12 * math.exp(-((x - 9.0) ** 2 + (y - 5.0) ** 2) / 55.0)
            z = shelf + 0.05 * math.sin((x+y) * 0.8)
            verts.append((x, y, z))
    for iy in range(rows):
        for ix in range(cols):
            a = iy * (cols + 1) + ix
            b = a + 1
            c = a + cols + 2
            d = a + cols + 1
            faces.append((a, b, c, d))
    return mesh(name, verts, faces, GRASS)

def ground_patch(name, loc, radius_x, radius_y, mat, z=0.48, points=8):
    verts = [(loc[0], loc[1], z)]
    for i in range(points):
        a = math.tau * i / points
        wobble = 0.82 + 0.16 * math.sin(i * 2.7 + loc[0])
        verts.append((loc[0] + math.cos(a) * radius_x * wobble, loc[1] + math.sin(a) * radius_y * wobble, z + 0.015 * math.sin(i)))
    faces = []
    for i in range(points):
        faces.append((0, i + 1, ((i + 1) % points) + 1))
    return mesh(name, verts, faces, mat)

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
    cube(name+"_Front_Facade_Panel", (x,y+length/2+0.055,z+height*0.68), (width*0.72,0.06,height*0.18), wall_mat)
    for sx in (-width*0.28, width*0.28):
        cube(name+"_Window", (x+sx,y+length/2+0.08,z+height*0.60), (width*0.13,0.06,height*0.20), ACCENT, 0.02)
    if military:
        for sx in (-width*0.48, width*0.48):
            cube(name+"_Corner_Buttress", (x+sx,y+length*0.20,z+0.56), (0.28,0.30,1.12), STONE)
        for px in (-width*0.72, width*0.72):
            cylinder(name+"_Yard_Post", (x+px,y-length*0.92,z+0.72), 0.10, 1.45, TIMBER, 6)
            cube(name+"_Yard_Rail", (x+px*0.55,y-length*0.92,z+0.70), (width*0.48,0.10,0.12), TIMBER_LIGHT)
        for px in (-width * 0.30, 0.0, width * 0.30):
            cylinder(name+"_Training_Post", (x+px,y-length*0.88,z+0.85), 0.09, 1.35, TIMBER, 6)
        cube(name+"_Lean_To", (x+width*0.62,y-length*0.08,z+0.72), (0.75,1.7,0.16), SLATE)
        cube(name+"_Shield_Rack", (x-width*0.63,y+length*0.22,z+0.78), (0.10,1.0,0.95), TIMBER)
        cube(name+"_Red_Field_Banner", (x+width*0.57,y+length/2+0.08,z+height*0.88), (0.08,0.05,0.62), ACCENT)
    else:
        cube(name+"_Porch", (x,y+length*0.62,z+0.42), (width*0.48,0.62,0.16), TIMBER_LIGHT)
        cube(name+"_Threshold", (x,y+length*0.86,z+0.28), (width*0.62,0.18,0.16), STONE)
    return base

def tree(name, loc, scale=1.0):
    x,y,z=loc
    cylinder(name+"_Trunk", (x,y,z+0.9*scale), 0.18*scale, 1.8*scale, TIMBER, 7)
    cone(name+"_Lower_Crown", (x,y,z+2.2*scale), 0.95*scale, 0.22*scale, 1.9*scale, GRASS_LIGHT, 7)
    cone(name+"_Upper_Crown", (x,y,z+3.45*scale), 0.68*scale, 0.12*scale, 1.65*scale, GRASS, 7)

def bush(name, loc, scale=1.0):
    for i in range(3):
        irregular_rock(name+"_Leaf_"+str(i), (loc[0]+(i-1)*0.28*scale,loc[1]+(i%2)*0.18*scale,loc[2]+0.35*scale), (0.48*scale,0.42*scale,0.40*scale), GRASS_LIGHT)

def broadleaf_tree(name, loc, scale=1.0):
    x,y,z = loc
    cylinder(name+"_Trunk", (x,y,z+0.9*scale), 0.22*scale, 1.8*scale, TIMBER, 7)
    for i in range(4):
        a = math.tau * i / 4.0
        irregular_rock(name+"_Crown_"+str(i), (x+math.cos(a)*0.42*scale,y+math.sin(a)*0.42*scale,z+2.05*scale+(i%2)*0.18), (0.72*scale,0.56*scale,0.64*scale), GRASS_LIGHT if i%2 else GRASS)

def reed_cluster(name, loc, scale=1.0):
    for i in range(5):
        blade = cone(name+"_Reed_"+str(i), (loc[0]+(i-2)*0.12*scale,loc[1]+math.sin(i)*0.08*scale,loc[2]+0.38*scale), 0.055*scale, 0.012, 0.82*scale, GRASS_DARK, 5)
        blade.rotation_euler[1] = (i-2)*0.16

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
    ground_patch("Hostile_Camp_Worked_Ground", (x,y), 3.5, 2.8, HOSTILE_GROUND, 0.40, 9)
    # Deliberate bridge-facing defensive entry rather than a civilian yard.
    for i,(px,py,rot) in enumerate(((x-2.7,y-1.8,-0.18),(x-1.2,y-2.25,0.12),(x+0.35,y-2.30,-0.08),(x+1.9,y-1.95,0.14))):
        barricade = cube("Camp_Barricade_%02d"%i, (px,py,0.86), (1.15,0.18,0.95), TIMBER, 0.04)
        barricade.rotation_euler[2] = rot
    for px in (x-1.55,x+1.55):
        cylinder("Camp_Watch_Post", (px,y+0.25,1.55), 0.13, 2.5, TIMBER, 6)
        cube("Camp_Watch_Cross", (px,y+0.25,2.5), (0.95,0.18,0.14), TIMBER_LIGHT)
    cube("Camp_Command_Canopy_Back", (x,y+0.75,1.05), (3.1,0.25,1.75), HOSTILE)
    gable_roof("Camp_Command_Canopy_Roof", (x,y+0.45,0), 3.6, 2.35, 2.02, 2.62, HOSTILE)
    for px in (x-1.45,x+1.45): cylinder("Camp_Canopy_Post", (px,y-0.48,1.0), 0.10, 1.75, TIMBER, 6)
    cube("Camp_Storage_Crate", (x+1.85,y+1.1,0.72), (0.95,0.82,0.72), TIMBER_LIGHT, 0.04)
    cube("Camp_Weapon_Rack", (x-2.10,y+0.95,0.88), (0.12,1.15,1.25), TIMBER)
    for i in range(3):
        cylinder("Camp_Spear_%02d"%i, (x-2.08,y+0.55+i*0.35,1.52), 0.035, 1.55, TIMBER_LIGHT, 5)
    cylinder("Camp_Dead_Timber", (x+2.15,y+1.55,0.92), 0.16, 1.75, TIMBER, 6).rotation_euler[1] = 0.55
    cylinder("Camp_Fire_Bowl", (x-0.75,y-0.55,0.48), 0.42, 0.18, STONE_DARK, 8)
    cone("Camp_Fire", (x-0.75,y-0.55,0.92), 0.30, 0.02, 0.78, FIRE, 6)

def resource_yard():
    x,y=-10.4,1.7
    ground_patch("Worked_Ore_Yard", (x,y), 2.9, 2.25, EARTH, 0.43, 9)
    irregular_rock("Gold_Mine_Granite_Face_A", (x-1.28,y-0.52,1.05), (0.76,0.88,1.18), STONE)
    irregular_rock("Gold_Mine_Granite_Face_B", (x-1.28,y+0.60,1.05), (0.72,0.78,1.10), STONE_DARK)
    cube("Gold_Mine_Extraction_Opening", (x-1.87,y+0.12,0.96), (0.12,1.2,0.88), HOSTILE, 0.06)
    for i,(dx,dy,s) in enumerate(((-0.55,0,1.0),(0.2,0.35,0.75),(1.0,-0.5,0.62))):
        irregular_rock("Gold_Ore_Outcrop_%d"%i,(x+dx,y+dy,0.65*s),(0.62*s,0.48*s,0.50*s),GOLD)
    for i,(dy,dz) in enumerate(((-0.62,0.92),(0.0,1.26),(0.56,0.76))):
        seam = cube("Gold_Embedded_Seam_%02d"%i, (x-1.92,y+dy,dz), (0.05,0.35,0.09), GOLD_SEAM)
        seam.rotation_euler[2] = 0.22 * (i-1)
    cube("Ore_Cart", (x+0.9,y+1.0,0.48), (1.2,0.62,0.42), TIMBER_LIGHT, 0.05)
    for wx in (x+0.5,x+1.3): cylinder("Ore_Cart_Wheel", (wx,y+1.0,0.28),0.28,0.12,TIMBER,8).rotation_euler[1]=math.pi/2
    cube("Ore_Wooden_A_Frame", (x-0.75,y-1.0,1.0), (0.12,0.12,1.65), TIMBER)
    cube("Ore_Wooden_A_Frame_Right", (x+0.12,y-1.0,1.0), (0.12,0.12,1.65), TIMBER)
    cube("Ore_Wooden_A_Cross", (x-0.31,y-1.0,1.65), (1.55,0.12,0.12), TIMBER)
    cylinder("Ore_Hoist_Rope", (x-0.31,y-1.0,1.32), 0.04, 0.72, TIMBER_LIGHT, 5)
    cube("Ore_Tool_Crate", (x+0.15,y-1.05,0.62), (0.75,0.6,0.55), TIMBER_LIGHT, 0.04)

def scene():
    terrain_patch("Original_Grass_Terrain_West", True)
    terrain_patch("Original_Grass_Terrain_East", False)
    # recessed curved water and its irregular raised banks
    river = [(1.1*math.sin(y*0.19)+0.35*math.sin(y*0.47),y) for y in [i*-1.2 for i in range(-15,16)]]
    ribbon("Recessed_Curved_Stream_Water", river, [2.0+0.22*math.sin(i*0.7) for i in range(len(river))], -0.24, WATER)
    left_bank=[]; right_bank=[]
    for x,y in river:
        left_bank.append((x-1.12,y)); right_bank.append((x+1.12,y))
    ribbon("Raised_Stream_Bank_West", left_bank, [0.50+0.14*math.sin(i) for i in range(len(left_bank))], 0.34, BANK)
    ribbon("Raised_Stream_Bank_East", right_bank, [0.48+0.14*math.cos(i) for i in range(len(right_bank))], 0.34, BANK)
    ribbon("Wet_Sloped_Bank_West", [(x-0.78,y) for x,y in river], [0.34+0.1*math.sin(i) for i in range(len(river))], 0.16, BANK_DARK)
    ribbon("Wet_Sloped_Bank_East", [(x+0.78,y) for x,y in river], [0.32+0.1*math.cos(i) for i in range(len(river))], 0.16, BANK_DARK)
    for i,(x,y) in enumerate(river[3:-3:3]):
        irregular_rock("Stream_Stone_%02d"%i,(x-1.25,y,0.44),(0.32,0.45,0.28),STONE)
        irregular_rock("Stream_Stone_E_%02d"%i,(x+1.25,y+0.35,0.42),(0.28,0.34,0.24),STONE_DARK)
    # embedded roads follow the land, terminating at the actual bridge deck.
    ribbon("Embedded_Worn_Road_West", [(-15,-9),(-11,-8),(-8,-6.7),(-5,-5),(-3,-3),(-2,0)], [2.2,1.9,1.75,1.55,1.45,1.38],0.49,ROAD)
    ribbon("Embedded_Worn_Road_East", [(2,0),(3.8,1.8),(5.8,3.5),(7.5,4.7),(8,5)], [1.4,1.55,1.7,1.9,2.1],0.49,ROAD)
    ribbon("Embedded_Resource_Track", [(-11,-7),(-10,-4),(-10.4,1.7)], [1.6,1.35,1.7],0.49,ROAD_EDGE)
    for i,(px,py) in enumerate(((-11,-7),(-8,-6.6),(-5,-5.1),(-3,-3.0),(4,1.7),(6,3.5),(7.7,4.8))):
        irregular_rock("Road_Wear_Stone_%02d"%i,(px,py,0.54),(0.16,0.25,0.10),STONE_DARK)
    building("Main_Hall", (-8.0,-5.5,0.34), 4.6, 4.0, 2.62, 2.05, LIME, SLATE)
    cube("Main_Hall_Entrance_Porch", (-8.0,-3.20,1.05), (1.65,0.82,0.18), STONE, 0.04)
    for px in (-8.62,-7.38): cylinder("Main_Hall_Porch_Post", (px,-3.58,1.62), 0.10, 1.25, TIMBER, 6)
    cube("Main_Hall_Entrance_Arch", (-8.0,-3.72,1.58), (1.75,0.12,0.16), TIMBER_LIGHT)
    cube("Main_Hall_Civic_Tower", (-9.25,-5.7,3.42), (1.20,1.20,1.95), STONE)
    gable_roof("Main_Hall_Civic_Tower_Roof", (-9.25,-5.7,0.34), 1.42, 1.42, 4.44, 5.18, SLATE_LIGHT)
    cylinder("Main_Hall_Civic_Banner_Pole", (-9.25,-6.38,4.42), 0.035, 2.25, TIMBER, 6)
    cube("Main_Hall_Civic_Banner", (-9.25,-6.38,5.08), (0.44,0.06,0.58), ACCENT)
    cube("Main_Hall_Bell_Frame", (-9.25,-5.7,5.22), (0.72,0.72,0.16), TIMBER)
    building("Field_Barracks", (-4.8,-7.4,0.34), 4.3, 3.35, 2.18, 1.48, TIMBER_LIGHT, SLATE, True)
    cylinder("Field_Barracks_Chimney", (-5.75,-7.3,3.36), 0.18, 0.78, STONE_DARK, 7)
    cube("Field_Barracks_Equipment_Lean_To", (-3.2,-7.0,0.72), (0.88,1.55,0.16), SLATE)
    building("Barrosan_House", (-11.0,-6.1,0.34), 3.1, 2.75, 1.62, 1.18, LIME, SLATE_LIGHT)
    cube("Barrosan_House_Side_Wing", (-12.05,-5.55,0.72), (0.92,1.55,0.95), LIME_DARK, 0.04)
    bridge()
    resource_yard()
    hostile_camp()
    for i,(x,y,s) in enumerate([(-18,-12,1.2),(-17,10,1.0),(-5,12,0.9),(15,12,1.1),(16,-10,1.0)]): tree("Original_Pine_%02d"%i,(x,y,0.28),s)
    for i,(x,y,s) in enumerate([(-14,-1,0.8),(-3,-11,0.7),(5,10,0.75),(14,-1,0.8),(6,-10,0.65)]): bush("Original_Bush_%02d"%i,(x,y,0.28),s)
    for i,(x,y,s) in enumerate([(-15,-4,0.95),(-1,9,0.8),(13,-6,0.9),(12,7,0.72)]): broadleaf_tree("Original_Broadleaf_%02d"%i,(x,y,0.28),s)
    for i,(x,y) in enumerate([(-6,-1),(-2,6),(5,-5),(10,0),(-14,5)]): irregular_rock("Original_Rock_Formation_%02d"%i,(x,y,0.48),(0.7,0.5,0.55),STONE_DARK)
    for i,(x,y,s) in enumerate([(-12,-7,1.0),(-7,-1,0.8),(-2,4,0.9),(4,-4,0.85),(9,0,0.9),(13,7,0.75),(-14,4,0.75)]): grass_tuft("Original_Meadow_Tuft_%02d"%i,(x,y,0.30),s)
    for i,(x,y) in enumerate([(-1.3,-8.8),(0.2,-5.8),(1.2,0.3),(-0.8,6.5),(1.0,12.0)]): reed_cluster("River_Reed_Cluster_%02d"%i,(x,y,0.22),1.0)
    for i,(x,y,rx,ry,mat) in enumerate([(-13,-5,1.8,1.2,YARD),(-7,-1,1.7,1.2,GRASS_LIGHT),(-2,5,1.9,1.0,GRASS_DARK),(6,-5,1.8,1.2,GRASS_LIGHT),(12,3,1.7,1.1,HOSTILE_GROUND)]):
        ground_patch("Irregular_Terrain_Transition_%02d"%i,(x,y),rx,ry,mat,0.46,9)
    # Functional settlement props cluster around thresholds and work routes.
    ground_patch("Settlement_Main_Yard", (-5.8,-4.0), 2.3, 1.8, YARD, 0.47, 8)
    cube("Settlement_Wood_Pile", (-5.8,-3.6,0.55), (1.4,0.7,0.45), TIMBER_LIGHT, 0.04)
    for i in range(3): cylinder("Settlement_Log_%d"%i,(-5.8,-3.6+i*0.16,0.78+i*0.12),0.14,1.35,TIMBER,7).rotation_euler[1]=math.pi/2
    cube("House_Bench", (-12.0,-4.45,0.55), (0.9,0.28,0.24), TIMBER_LIGHT, 0.04)
    cube("House_Barrel", (-12.65,-4.1,0.55), (0.32,0.32,0.58), TIMBER, 0.04)
    for i,(px,py,s) in enumerate(((-9.0,-3.0,0.65),(-6.2,-2.6,0.52),(-3.0,-1.8,0.58),(5.8,6.6,0.55),(10.7,6.2,0.48))):
        bush("Functional_Moss_Bush_%02d"%i,(px,py,0.30),s)

scene()

os.makedirs(os.path.dirname(OUT_BLEND), exist_ok=True)
os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=OUT_BLEND)
bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format='GLB', export_cameras=False, export_lights=False, export_materials='EXPORT')
print("V0375_ORIGINAL_BARROSAN_KIT_EXPORTED", OUT_BLEND, OUT_GLB)
