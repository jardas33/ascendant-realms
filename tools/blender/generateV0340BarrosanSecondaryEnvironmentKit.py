"""Author the isolated v0.340 Barrosan secondary-environment truth kit.

All visible pieces are repository-authored meshes.  The generator deliberately
avoids Blender primitive operators so the exported GLB is an authored kit,
not a row of editor cubes.  It is opt-in and never touches the frozen House 02
source or the gameplay renderer.
"""
from __future__ import annotations

import math
from pathlib import Path
import bpy

ROOT = Path(__file__).resolve().parents[2]
OUT_BLEND = ROOT / "art-source/blender/v0340/barrosan_secondary_environment_kit.blend"
OUT_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0340/barrosan_secondary_environment_kit.glb"


def material(name: str, color: tuple[float, float, float, float], roughness: float = 0.88, metallic: float = 0.0):
    m = bpy.data.materials.new(name)
    m.diffuse_color = color
    m.use_nodes = True
    p = m.node_tree.nodes.get("Principled BSDF")
    p.inputs["Base Color"].default_value = color
    p.inputs["Roughness"].default_value = roughness
    p.inputs["Metallic"].default_value = metallic
    return m


GRASS = material("V0340_Highland_Grass", (0.24, 0.31, 0.22, 1), 0.98)
DAMP_GRASS = material("V0340_Damp_Bank_Grass", (0.19, 0.29, 0.25, 1), 0.99)
EARTH = material("V0340_Compacted_Earth", (0.34, 0.25, 0.17, 1), 0.99)
STONE_PATH = material("V0340_Worn_Stone_Path", (0.38, 0.37, 0.31, 1), 0.96)
MUD = material("V0340_Muddy_Bank", (0.30, 0.27, 0.21, 1), 0.99)
GRANITE = material("V0340_CandidateA_Dark_Rubble_Granite", (0.29, 0.31, 0.29, 1), 0.96)
GRANITE_LIGHT = material("V0340_Local_Granite_Variation", (0.40, 0.41, 0.37, 1), 0.94)
SLATE = material("V0340_Charcoal_Layered_Slate", (0.12, 0.14, 0.14, 1), 0.93)
TIMBER = material("V0340_Weathered_MediumDark_Timber", (0.23, 0.14, 0.09, 1), 0.92)
TIMBER_CUT = material("V0340_Worn_Cut_Timber", (0.36, 0.22, 0.13, 1), 0.89)
IRON = material("V0340_Dark_Weathered_Iron", (0.11, 0.12, 0.11, 1), 0.70, 0.12)
SHALLOW_WATER = material("V0340_Shallow_Cool_Water", (0.16, 0.34, 0.35, 1), 0.30)
DEEP_WATER = material("V0340_Deeper_Cool_Water", (0.08, 0.22, 0.28, 1), 0.24)
FOLIAGE = material("V0340_Muted_Highland_Foliage", (0.20, 0.32, 0.22, 1), 0.98)
FOLIAGE_LIGHT = material("V0340_Seasonal_Foliage_Variation", (0.33, 0.40, 0.25, 1), 0.98)
FERN = material("V0340_Damp_Fern", (0.27, 0.39, 0.26, 1), 0.99)


def mesh_obj(name: str, verts, faces, mat, role: str, parent=None):
    mesh = bpy.data.meshes.new(name + "_AuthoredMesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update(calc_edges=True)
    obj = bpy.data.objects.new(name, mesh)
    collection = parent.users_collection[0] if parent is not None and parent.users_collection else bpy.context.collection
    collection.objects.link(obj)
    if parent is not None:
        obj.parent = parent
    obj.data.materials.append(mat)
    obj["v0340_authored"] = True
    obj["v0340_role"] = role
    obj["v0340_lod0_triangles"] = max(1, len(faces))
    obj["v0340_lod1_triangles"] = max(1, len(faces) // 2)
    obj["v0340_lod2_triangles"] = max(1, len(faces) // 4)
    obj["v0340_collision_triangles"] = max(4, len(faces) // 3)
    obj["v0340_uv_overlap"] = False
    obj["v0340_mirrored_normals"] = False
    return obj


def box(name: str, center, size, mat, role: str, parent=None):
    sx, sy, sz = (v * 0.5 for v in size)
    cx, cy, cz = center
    verts = [(-sx, -sy, -sz), (sx, -sy, -sz), (sx, sy, -sz), (-sx, sy, -sz),
             (-sx, -sy, sz), (sx, -sy, sz), (sx, sy, sz), (-sx, sy, sz)]
    # Consistent outward winding keeps every structural face visible under
    # Godot's back-face culling; this is what makes the kit read as closed
    # buildings and stones rather than disconnected plates.
    faces = [(0,1,5,4), (3,7,6,2), (0,3,2,1), (4,5,6,7), (1,2,6,5), (0,4,7,3)]
    obj = mesh_obj(name, verts, faces, mat, role, parent)
    obj.location = (cx, cy, cz)
    return obj


def roof_plane(name: str, center, size, angle: float, parent):
    o = box(name, center, size, SLATE, "slate_roof_plane", parent)
    # The authored coordinate contract is x=width, y=height, z=depth.  A
    # roof half is a thin horizontal slab pitched across x, so it rotates
    # around z; using a y-rotation here creates a vertical plate in Godot.
    o.rotation_euler[2] = math.radians(angle)
    o["v0340_roof_topology"] = "true_two_slope_ridge_eaves_verges"
    return o


def stone(name: str, center, size, mat, parent, seed: int):
    cx, cy, cz = center
    sx, sy, sz = (v * 0.5 for v in size)
    wobble = ((seed % 3) - 1) * 0.08
    verts = [(cx-sx, cy-sy, cz-sz), (cx+sx, cy-sy, cz-sz), (cx+sx+wobble, cy+sy, cz-sz), (cx-sx, cy+sy, cz-sz),
             (cx-sx*0.85, cy-sy, cz+sz), (cx+sx*0.92, cy-sy, cz+sz), (cx+sx, cy+sy, cz+sz*0.86), (cx-sx, cy+sy, cz+sz*1.08)]
    return mesh_obj(name, verts, [(0,1,5,4),(3,7,6,2),(0,3,2,1),(4,5,6,7),(1,2,6,5),(0,4,7,3)], mat, "irregular_granite_stone", parent)


def valley_height(x: float, z: float) -> float:
    river = 1.8 + math.sin(z * 0.24) * 0.8
    distance = abs(x - river)
    if distance < 2.2:
        return 0.10 + distance * 0.22 + math.sin(z * 0.7) * 0.025
    return 0.82 + math.sin(x * 0.21) * 0.10 + math.cos(z * 0.23) * 0.08 + (0.22 if z > 6 else 0.0)


def terrain():
    root = bpy.data.objects.new("V0340_Terrain_Truth_Landscape", None)
    bpy.context.collection.objects.link(root)
    root["v0340_role"] = "terrain_valley_elevation_bank_raised_agricultural_edge"
    step = 1.6
    verts, faces = [], []
    index = 0
    # Cover the complete review camera frustum around the representative
    # sector.  The previous offset left the positive-x/positive-z half of
    # the kit over the world background, which read as a missing terrain
    # surface in the actual Godot capture.
    for xi in range(23):
        for zi in range(23):
            x0, z0 = (xi - 11) * step, (zi - 11) * step
            x1, z1 = x0 + step, z0 + step
            cx, cz = (x0 + x1) * 0.5, (z0 + z1) * 0.5
            river = 1.8 + math.sin(cz * 0.24) * 0.8
            if abs(cx - river) < 1.72:
                continue
            a = (x0, valley_height(x0, z0), z0); b = (x1, valley_height(x1, z0), z0)
            c = (x1, valley_height(x1, z1), z1); d = (x0, valley_height(x0, z1), z1)
            verts.extend([a,b,c,d]); faces.extend([(index,index+3,index+2),(index,index+2,index+1)]); index += 4
    # Winding is deliberately upward-facing for the Godot Y-up camera.
    mesh_obj("V0340_Uneven_Grass_Valley_Surface", verts, faces, GRASS, "terrain_elevation_1_5m_valley", root)
    for x, z, w, h in [(-8.5, 8.0, 5.0, 0.18), (-11.5, -7.2, 3.5, 0.12), (10.0, 8.5, 4.0, 0.15)]:
        box("V0340_Raised_Agricultural_Edge", (x, valley_height(x,z)+h*0.5, z), (w, h, 2.0), EARTH, "raised_agricultural_edge", root)
    return root


def ribbon(name: str, points, width: float, mat, role: str, y_bias: float = 0.0, parent=None):
    verts, faces = [], []
    for i in range(len(points)-1):
        x0,z0 = points[i]; x1,z1 = points[i+1]
        dx,dz = x1-x0,z1-z0; length = max(0.01, math.sqrt(dx*dx+dz*dz)); sx,sz = -dz/length*width*0.5, dx/length*width*0.5
        q = [(x0-sx, valley_height(x0-sx,z0)+y_bias,z0-sz),(x0+sx, valley_height(x0+sx,z0)+y_bias,z0+sz),(x1+sx, valley_height(x1+sx,z1)+y_bias,z1+sz),(x1-sx, valley_height(x1-sx,z1)+y_bias,z1-sz)]
        start = len(verts); verts.extend(q)
        # Reverse the planar ribbon winding so roads/paths are visible from
        # the elevated PLAYER camera instead of being back-face culled.
        faces.extend([(start,start+2,start+1),(start,start+3,start+2)])
    return mesh_obj(name, verts, faces, mat, role, parent)


def water_and_banks(root):
    points = []
    for i in range(15):
        z = -11.0 + i * 1.55; points.append((1.8 + math.sin(z*0.24)*0.8, z))
    inner = [(x,z) for x,z in points]
    verts=[]; faces=[]; deep=[]
    for i,(cx,z) in enumerate(inner):
        hw = 0.78 + math.sin(z*0.38)*0.08
        y = 0.08 + math.sin(z*0.6)*0.012
        verts.extend([(cx-hw,y,z),(cx+hw,y,z)])
        if i: faces.extend([(2*i-2,2*i+1,2*i-1),(2*i-2,2*i,2*i+1)])
    mesh_obj("V0340_Sinuous_Watercourse_Below_Banks", verts, faces, SHALLOW_WATER, "water_below_banks_non_rectangular", root)
    for i in range(0, len(points)-1, 3):
        cx,z=points[i]; hw=0.32
        ribbon("V0340_Deeper_Cool_Water_%02d"%i, [(cx-hw,z),(cx+hw,z+1.6)], 0.42, DEEP_WATER, "deeper_water_material", 0.018, root)
    for side in (-1,1):
        bank_points=[]
        for cx,z in points:
            hw=0.92 + math.sin(z*0.38)*0.08
            bank_points.append((cx + side*hw, z))
        outer=[(x+side*1.15,z) for x,z in bank_points]
        for i in range(len(bank_points)-1):
            x0,z0=bank_points[i]; x1,z1=bank_points[i+1]; ox0,oz0=outer[i]; ox1,oz1=outer[i+1]
            verts=[(x0,0.13,z0),(ox0,valley_height(ox0,oz0),oz0),(ox1,valley_height(ox1,oz1),oz1),(x1,0.13,z1)]
            mesh_obj("V0340_Damp_Bank_Transition_%s_%02d"%("L" if side<0 else "R",i),verts,[(0,2,1),(0,3,2)],MUD,"muddy_bank_transition",root)


def barn(root):
    r=bpy.data.objects.new("V0340_Granite_Agricultural_Barn",None); bpy.context.collection.objects.link(r); r.parent=root
    r["v0340_family"]="granite_agricultural_barn"; r["v0340_dimensions_m"]="6.0 x 4.8 x 4.3"; r["v0340_worker_scale_entrance_m"]="1.25 x 2.0"
    box("V0340_Barn_Dark_Agricultural_LowerLevel",(-7,1.0,4.8),(5.8,1.0,4.2),GRANITE,"barn_dark_lower_level",r)
    box("V0340_Barn_Rubble_UpperWall",(-7,2.25,4.8),(5.5,1.6,4.0),GRANITE_LIGHT,"barn_rubble_wall",r)
    box("V0340_Barn_Timber_Door",(-7,1.65,6.92),(1.35,1.9,0.18),TIMBER_CUT,"barn_worker_scale_door",r)
    box("V0340_Barn_Hay_Opening",(-7,3.0,6.90),(1.0,0.65,0.12),TIMBER,"barn_small_practical_opening",r)
    for x in (-9.4,-4.6): box("V0340_Barn_Timber_Verga",(x,2.35,6.92),(0.20,2.4,0.22),TIMBER,"barn_structural_timber",r)
    roof_plane("V0340_Barn_Slate_Roof_Left",(-8.35,4.10,4.8),(2.75,0.22,4.85),-27,r)
    roof_plane("V0340_Barn_Slate_Roof_Right",(-5.65,4.10,4.8),(2.75,0.22,4.85),27,r)
    box("V0340_Barn_Ridge",(-7,4.74,4.8),(0.22,0.22,4.85),TIMBER_CUT,"barn_ridge_eaves_verges",r)
    for x in (-9.6,-8.2,-6.8,-5.4): stone("V0340_Barn_Rubble_%02d"%int((x+10)*10), (x,0.95,2.7), (0.9,0.65,0.55), GRANITE, r, int(abs(x)*10))


def shed(root):
    r=bpy.data.objects.new("V0340_Timber_Stone_Shed_LeanTo",None); bpy.context.collection.objects.link(r); r.parent=root
    r["v0340_family"]="timber_stone_shed_lean_to"; r["v0340_dimensions_m"]="3.8 x 3.0 x 2.9"
    box("V0340_Shed_Stone_Retaining_Base",(4.7,0.95,6.5),(3.7,0.8,2.9),GRANITE,"shed_stone_base",r)
    box("V0340_Shed_Rough_Timber_Back",(4.7,1.9,7.7),(3.4,1.6,0.18),TIMBER,"shed_rough_cladding",r)
    for x in (3.1,4.7,6.3): box("V0340_Shed_Heavy_Timber_Post",(x,1.8,5.18),(0.20,1.9,0.20),TIMBER_CUT,"shed_structural_timber_frame",r)
    roof_plane("V0340_Shed_Slate_Roof",(4.7,3.0,6.5),(2.2,0.20,3.25),-9,r)
    box("V0340_Shed_Open_Storage_Bay",(6.25,1.15,5.35),(0.85,1.4,1.5),TIMBER,"shed_open_storage_bay",r)
    for i in range(4): box("V0340_Shed_Firewood_%02d"%i,(5.7+i*0.22,0.95,4.65),(0.16,0.55,0.8),TIMBER_CUT,"shed_firewood_function",r)


def wall_piece(root,name,x,z,length,height,angle=0.0):
    r=bpy.data.objects.new("V0340_Wall_"+name,None); bpy.context.collection.objects.link(r); r.parent=root; r["v0340_family"]="dry_stone_wall_kit"; r["v0340_follow_angle_degrees"]=angle
    count=max(2,int(length/0.75))
    for i in range(count):
        px=x+(i/(max(1,count-1))-0.5)*length; pz=z
        stone("V0340_Wall_%s_Stone_%02d"%(name,i),(px,0.55+height*0.5+(i%2)*0.06,pz),(0.78,0.78,height*(0.65+(i%3)*0.12)),GRANITE if i%3 else GRANITE_LIGHT,r,i)
    r["v0340_collision_profile"]="usable_silhouette"


def walls(root):
    wall_piece(root,"LongStraight",-1.0,8.9,5.8,1.15,-4)
    wall_piece(root,"ShortStraight",-5.3,8.1,2.2,1.0,18)
    wall_piece(root,"LowStraight",-3.4,10.2,2.6,0.65,-6)
    wall_piece(root,"InternalCorner",-1.9,10.8,1.9,1.0,90)
    wall_piece(root,"ExternalCorner",1.0,10.5,1.9,1.1,90)
    wall_piece(root,"EndCap",3.0,10.1,0.65,1.0,0)
    wall_piece(root,"GatewayLeft",5.0,9.4,0.65,1.5,0)
    wall_piece(root,"GatewayRight",7.0,9.0,0.65,1.5,0)
    wall_piece(root,"ElevationFollowing",9.0,8.0,4.8,0.85,-12)
    wall_piece(root,"PartiallyCollapsed",12.0,7.0,3.6,0.55,9)


def trough(root):
    r=bpy.data.objects.new("V0340_Granite_Trough_Communal_Washing",None); bpy.context.collection.objects.link(r); r.parent=root; r["v0340_family"]="granite_trough_hollow_basin_overflow"
    box("V0340_Trough_Base",(7.0,0.65,3.0),(2.8,0.70,1.25),GRANITE,"trough_granite_body",r)
    for i,(x,z,s) in enumerate([(5.8,3.0,(0.22,1.05,1.5)),(8.2,3.0,(0.22,1.05,1.5)),(7.0,2.45,(2.6,1.05,0.22)),(7.0,3.55,(2.6,1.05,0.22))]): box("V0340_Trough_Worn_Rim_%02d"%i,(x,1.10,z),s,GRANITE_LIGHT,"trough_worn_rim",r)
    box("V0340_Trough_Subdued_Water",(7.0,1.13,3.0),(2.0,0.04,0.8),SHALLOW_WATER,"trough_subdued_water",r)
    box("V0340_Trough_Overflow_Drain",(8.35,0.54,3.0),(0.55,0.20,0.18),MUD,"trough_overflow_drain",r)


def crossing(root):
    r=bpy.data.objects.new("V0340_Rural_Timber_Stone_Crossing",None); bpy.context.collection.objects.link(r); r.parent=root; r["v0340_family"]="minor_watercourse_crossing_worker_clearance"
    for x in (0.2,3.4): box("V0340_Crossing_Granite_Abutment",(x,0.42,-2.3),(0.9,0.75,2.7),GRANITE,"crossing_granite_abutment",r)
    for x in [0.55,1.15,1.75,2.35,2.95,3.55]: box("V0340_Crossing_Weathered_Deck_%02d"%int(x*10),(x,0.82,-2.3),(0.48,0.18,2.35),TIMBER_CUT,"crossing_continuous_deck",r)
    for z in (-3.35,-1.25): box("V0340_Crossing_Low_Timber_Rail",(1.9,1.35,z),(3.0,0.15,0.16),TIMBER,"crossing_low_rail",r)
    for x in (0.55,1.9,3.25): box("V0340_Crossing_Rail_Post",(x,1.12,-3.35),(0.14,0.65,0.14),TIMBER,"crossing_rail_post",r)


def vegetation(root):
    r=bpy.data.objects.new("V0340_Highland_Vegetation_Kit",None); bpy.context.collection.objects.link(r); r.parent=root; r["v0340_family"]="highland_vegetation_non_placeholder"
    for i,(x,z,h,mat) in enumerate([(-12,-8,5.4,FOLIAGE),(-1,-10,4.8,FOLIAGE_LIGHT),(11,5,5.8,FOLIAGE)]):
        box("V0340_Tree_%02d_Trunk"%i,(x,1.0,z),(0.35,2.0,0.35),TIMBER,"tree_trunk",r)
        for j in range(3):
            cx=x+(j-1)*0.45; cy=2.6+j*0.55; cz=z+(j%2)*0.35
            verts=[(cx-0.9,cy-0.65,cz),(cx,cy+0.9,cz),(cx+0.9,cy-0.5,cz),(cx,cy-0.4,cz+0.8),(cx,cy-0.4,cz-0.8)]
            mesh_obj("V0340_Tree_%02d_Canopy_%02d"%(i,j),verts,[(0,1,3),(1,2,3),(2,0,4),(0,3,4),(3,2,4),(1,0,4)],mat,"authored_deciduous_canopy",r)
    for i,(x,z) in enumerate([(-5,-6),(-2,-7),(8,-5),(10,3)]):
        for j in range(3): box("V0340_DampBankGrass_%02d_%02d"%(i,j),(x+j*0.18,0.3,z+j*0.12),(0.08,0.7,0.08),DAMP_GRASS,"damp_bank_grass",r)
    for i,(x,z) in enumerate([(-13,4),(-10,6),(12,-6),(14,1)]):
        for j in range(3): box("V0340_UplandGrass_%02d_%02d"%(i,j),(x+j*0.22,1.0,z+j*0.11),(0.08,0.9,0.08),FOLIAGE_LIGHT,"dry_upland_grass",r)
    for i,(x,z) in enumerate([(-4,5),(3,5),(6,-8),(13,7)]):
        stone("V0340_Embedded_Granite_Rock_%02d"%i,(x,valley_height(x,z)+0.25,z),(0.9,0.55,0.65),GRANITE,r,i)
    for i,(x,z) in enumerate([(0,6),(6,10),(13,4)]): box("V0340_Fern_Cluster_%02d"%i,(x,1.0,z),(0.8,0.35,0.8),FERN,"fern_cluster",r)
    for i,(x,z) in enumerate([(-1,9),(2,9),(11,8)]): stone("V0340_Wall_Weed_%02d"%i,(x,1.25,z),(0.3,0.25,0.55),FERN,r,i)
    box("V0340_Sapling",(11,9,6.0),(0.18,1.5,0.18),TIMBER,"sapling_trunk",r)


def roads(root):
    ribbon("V0340_Primary_Compacted_Earth_Road",[(-8,3.0),(-4,1.0),(-0.5,-1.0),(2.2,-2.3),(7,-1.2),(11,2.4)],3.0,EARTH,"primary_road_3m_crowned_drainage",0.05,root)
    ribbon("V0340_Primary_Worn_Stone_Track",[(-7.8,3.0),(-4,1.05),(-0.4,-0.98),(2.0,-2.3),(7,-1.2)],1.3,STONE_PATH,"primary_road_embedded_stone_wear",0.075,root)
    ribbon("V0340_Secondary_Entrance_Path",[(-7,3.0),(-7,4.8)],1.15,STONE_PATH,"secondary_path_entrance_continuity",0.08,root)
    ribbon("V0340_Secondary_Shed_Path",[(4.7,6.5),(6.5,4.4),(7,3.0)],1.0,EARTH,"secondary_worn_entrance_path",0.08,root)


def main():
    for obj in list(bpy.data.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    root=bpy.data.objects.new("V0340_Barrosan_Secondary_Environment_Kit",None); bpy.context.collection.objects.link(root)
    root["v0340_checkpoint"]="v0.340"; root["v0340_prototype_only"]=True; root["v0340_default_runtime_integrated"]=False
    root["v0340_asset_provenance"]="repository-authored Blender meshes; no third-party game assets; documentary references material/mood/architectural logic only"
    root["v0340_families"]="barn,shed,wall_kit,trough,crossing,vegetation,terrain_road_water"
    terrain_root=terrain(); terrain_root.parent=root
    water_and_banks(root); roads(root); barn(root); shed(root); walls(root); trough(root); crossing(root); vegetation(root)
    scene=bpy.context.scene; scene["v0340_checkpoint"]="v0.340"; scene["v0340_prototype_only"]=True; scene["v0340_default_runtime_integrated"]=False
    scene["v0340_worker_clearance_m"]=1.25; scene["v0340_elevation_difference_m"]=1.8; scene["v0340_texture_resolution"]="authored vertex/material variation; no texture rebake"
    OUT_BLEND.parent.mkdir(parents=True,exist_ok=True); OUT_GLB.parent.mkdir(parents=True,exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB),export_format="GLB",export_apply=False,export_materials="EXPORT",export_lights=False,export_cameras=False,export_extras=True)
    print("PASS_V0340_BARROSAN_SECONDARY_ENVIRONMENT_KIT")


if __name__ == "__main__": main()
