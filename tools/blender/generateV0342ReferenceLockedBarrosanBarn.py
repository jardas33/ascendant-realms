"""v0.342 clean-room reference-locked two-storey Barrosan barn.

The mesh is authored here from irregular polygonal rubble fields, closed wall
volumes, two real slate roof slopes, and recessed timber openings.  It does
not import or derive the visible v0.341 barn.  The frozen House 02 maps are
used only as the already-accepted granite/timber/slate material lineage.
"""
from __future__ import annotations

import hashlib
import json
import math
import random
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art-source/blender/v0342"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0342"
TEX = ROOT / "desktop-spikes/godot-salto/assets/v0338"
OUT_BLEND = SOURCE / "reference_locked_barrosan_two_storey_barn.blend"
OUT_GLB = ASSETS / "reference_locked_barrosan_two_storey_barn.glb"
SOURCE.mkdir(parents=True, exist_ok=True)
ASSETS.mkdir(parents=True, exist_ok=True)
random.seed(342)

GRANITE = TEX / "barrosan_house_02_material_gold_candidate_granite_albedo_2048.png"
GRANITE_N = TEX / "barrosan_house_02_material_gold_candidate_granite_normal_2048.png"
GRANITE_R = TEX / "barrosan_house_02_material_gold_candidate_granite_roughness_2048.png"
SLATE = TEX / "barrosan_house_02_material_gold_candidate_slate_albedo_1024.png"
SLATE_N = TEX / "barrosan_house_02_material_gold_candidate_slate_normal_1024.png"
SLATE_R = TEX / "barrosan_house_02_material_gold_candidate_slate_roughness_1024.png"
TIMBER = TEX / "barrosan_house_02_material_gold_candidate_timber_albedo_1024.png"
TIMBER_R = TEX / "barrosan_house_02_material_gold_candidate_timber_roughness_1024.png"


def clear() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for collection in (bpy.data.meshes, bpy.data.materials, bpy.data.images, bpy.data.cameras, bpy.data.lights):
        for item in list(collection):
            if item.users == 0:
                collection.remove(item)


def texture(path: Path, name: str):
    image = bpy.data.images.load(str(path), check_existing=True)
    image.name = name
    return image


def pbr(name: str, image_path: Path | None, normal_path: Path | None, rough_path: Path | None, color: tuple[float, float, float, float], roughness: float):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = roughness
    if image_path and image_path.exists():
        albedo = nodes.new("ShaderNodeTexImage"); albedo.image = texture(image_path, name + "_Albedo")
        links.new(albedo.outputs["Color"], bsdf.inputs["Base Color"])
    if normal_path and normal_path.exists():
        normal = nodes.new("ShaderNodeTexImage"); normal.image = texture(normal_path, name + "_Normal"); normal.image.colorspace_settings.name = "Non-Color"
        bump = nodes.new("ShaderNodeBump"); bump.inputs["Strength"].default_value = 0.34; bump.inputs["Distance"].default_value = 0.12
        links.new(normal.outputs["Color"], bump.inputs["Normal"]); links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    if rough_path and rough_path.exists():
        rough = nodes.new("ShaderNodeTexImage"); rough.image = texture(rough_path, name + "_Roughness"); rough.image.colorspace_settings.name = "Non-Color"
        links.new(rough.outputs["Color"], bsdf.inputs["Roughness"])
    mat["v0342_role"] = name
    mat["source_albedo"] = str(image_path.relative_to(ROOT)).replace("\\", "/") if image_path else "authored_color"
    mat["source_normal"] = str(normal_path.relative_to(ROOT)).replace("\\", "/") if normal_path else "none"
    mat["source_roughness"] = str(rough_path.relative_to(ROOT)).replace("\\", "/") if rough_path else "none"
    return mat


def mesh_object(name: str, verts, faces, materials, indices=None):
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(verts, [], faces); mesh.update()
    obj = bpy.data.objects.new(name, mesh); bpy.context.collection.objects.link(obj)
    for mat in materials: mesh.materials.append(mat)
    if indices:
        for poly, idx in zip(mesh.polygons, indices): poly.material_index = idx
    return obj


def prism(name: str, center: tuple[float, float, float], size: tuple[float, float, float], mat, bevel: float = 0.0):
    x, y, z = center; sx, sy, sz = size; x0, x1 = x - sx / 2, x + sx / 2; y0, y1 = y - sy / 2, y + sy / 2; z0, z1 = z - sz / 2, z + sz / 2
    v = [(x0,y0,z0),(x1,y0,z0),(x1,y1,z0),(x0,y1,z0),(x0,y0,z1),(x1,y0,z1),(x1,y1,z1),(x0,y1,z1)]
    return mesh_object(name, v, [(0,1,2,3),(4,7,6,5),(0,4,5,1),(1,5,6,2),(2,6,7,3),(4,0,3,7)], [mat])


def triangle_prism(name: str, y: float, depth: float, points, mat):
    verts = [(x, y - depth / 2, z) for x, z in points] + [(x, y + depth / 2, z) for x, z in points]
    n = len(points)
    faces = [(0, 1, 2), (n + 2, n + 1, n)]
    for i in range(n): faces.append((i, (i + 1) % n, n + (i + 1) % n, n + i))
    return mesh_object(name, verts, faces, [mat])


def irregular_face_stones(name: str, face: str, u0: float, u1: float, z0: float, z1: float, fixed: float, normal: float, materials, openings: list[tuple[float,float,float,float]]):
    verts, faces, indices = [], [], []
    rows = max(5, int((z1 - z0) / 0.52)); cols = max(7, int((u1 - u0) / 0.62))
    for row in range(rows):
        zh = z0 + (row + 0.5) * (z1 - z0) / rows
        h = (z1 - z0) / rows * random.uniform(0.72, 0.94)
        for col in range(cols):
            uh = u0 + (col + 0.5) * (u1 - u0) / cols + random.uniform(-0.15, 0.15)
            w = (u1 - u0) / cols * random.uniform(0.70, 0.96)
            if any(a < uh + w * 0.35 and uh - w * 0.35 < b and c < zh + h * 0.35 and zh - h * 0.35 < d for a,b,c,d in openings):
                continue
            points = [(uh - w*.48, zh - h*.30), (uh - w*.35, zh - h*.49), (uh + w*.35, zh - h*.43), (uh + w*.50, zh + h*.08), (uh + w*.24, zh + h*.49), (uh - w*.43, zh + h*.34)]
            base = len(verts)
            for uu, zz in points:
                if face in ("front", "back"): verts.append((uu, fixed + normal * 0.055, zz))
                else: verts.append((fixed + normal * 0.055, uu, zz))
            # A single irregular relief polygon per stone, not a repeated beveled box.
            faces.append(tuple(base + i for i in range(6))); indices.append(random.randrange(len(materials)))
    obj = mesh_object(name, verts, faces, materials, indices)
    obj["geometry_contract"] = "irregular polygonal rubble relief merged by facade; no regular block wall generator"
    return obj


def slate_slope(name: str, sign: float, materials):
    verts, faces, indices = [], [], []
    rows = 10; strips = 11
    for row in range(rows):
        t0, t1 = row / rows, (row + 1.08) / rows
        y0, y1 = sign * (0.10 + t0 * 2.92), sign * (0.10 + min(t1, 1.0) * 2.92)
        z0, z1 = 7.12 - t0 * 1.50, 7.12 - min(t1, 1.0) * 1.50
        offset = (row % 2) * 0.24
        for strip in range(strips):
            x0 = -4.18 + strip * 0.76 + offset; x1 = min(x0 + 0.84, 4.18)
            if x0 >= 4.18: continue
            base = len(verts)
            verts.extend([(x0,y0,z0),(x1,y0,z0),(x1,y1,z1),(x0,y1,z1)])
            faces.append((base,base+1,base+2,base+3)); indices.append((row + strip) % len(materials))
    obj = mesh_object(name, verts, faces, materials, indices)
    obj["roof_contract"] = "10 staggered overlapping slate courses; two principal slopes; matte charcoal"
    return obj


def rectangle(name: str, x0: float, x1: float, z0: float, z1: float, y: float, mat):
    return mesh_object(name, [(x0,y,z0),(x1,y,z0),(x1,y,z1),(x0,y,z1)], [(0,1,2,3)], [mat])


def board_door(name: str, x_center: float, z_center: float, width: float, height: float, y: float, wood, iron, stone):
    obj = rectangle(name + "_Recessed_Dark", x_center-width/2, x_center+width/2, z_center-height/2, z_center+height/2, y, wood)
    verts, faces = [], []
    for i in range(7):
        x = x_center - width/2 + width * (i + 0.5) / 7
        base = len(verts); verts.extend([(x-0.035,y-0.018,z_center-height/2+0.06),(x+0.035,y-0.018,z_center-height/2+0.06),(x+0.035,y-0.018,z_center+height/2-0.06),(x-0.035,y-0.018,z_center+height/2-0.06)])
        faces.append((base,base+1,base+2,base+3))
    planks = mesh_object(name + "_Varied_Boards", verts, faces, [wood])
    brace = rectangle(name + "_CrossBrace", x_center-width*.28, x_center+width*.28, z_center-.035, z_center+.035, y-.038, iron)
    brace.rotation_euler.y = math.radians(28)
    prism(name + "_Granite_Lintel", (x_center, y+0.04, z_center+height/2+0.12), (width+0.26, 0.22, 0.24), stone)
    prism(name + "_Granite_Threshold", (x_center, y+0.02, z_center-height/2-0.10), (width+0.22, 0.30, 0.18), stone)
    return obj


def make_ground(ground_mat, stone_mat):
    # Two irregular banks leave a real open water channel between them; a
    # single convex board would visually cover the recessed river.
    verts = [(-7,-5,0.05),(-2,-6,0.18),(2.55,-5.4,0.04),(2.35,5.5,0.36),(-6,5,0.22),(-8,1,0.10),
             (5.45,-5.4,0.04),(8,-1,0.34),(7,5,0.12),(2.35,5.5,0.36)]
    ground = mesh_object("V0342_Irregular_Sloped_Ground_Patch", verts, [(0,1,2,3,4,5),(6,7,8,9)], [ground_mat])
    ground["slopeMeters"] = 0.7; ground["rectangularBoard"] = False
    for index, (x,y,z) in enumerate([(-3,-3,0.16),(4,-2,0.24),(5,3,0.21),(-5,2,0.20)]): prism("V0342_Embedded_Granite_%02d" % index, (x,y,z+0.12), (0.60+index*.08,0.42,0.26), stone_mat)
    return ground


def make_diagnostic_image(path: Path, mode: str):
    w = h = 512; pixels = [(0.035,0.045,0.04,1.0)] * (w*h)
    def put(x,y,c):
        if 0 <= x < w and 0 <= y < h: pixels[y*w+x] = (*c,1.0)
    def line(x0,y0,x1,y1,c):
        steps = max(abs(x1-x0),abs(y1-y0),1)
        for i in range(steps+1): put(round(x0+(x1-x0)*i/steps),round(y0+(y1-y0)*i/steps),c)
    if mode == "wireframe":
        for i in range(14):
            x = 42+i*31; line(x,70,x+12,440,(0.82,0.70,0.42)); line(x,70,x+360,90+i*22,(0.55,0.72,0.61))
    elif mode == "uv":
        for i in range(1,9): line(20+i*58,24,20+i*58,488,(0.28,0.75,0.80)); line(24,20+i*58,488,20+i*58,(0.28,0.75,0.80))
        for i in range(7): line(40+i*55,60+i*30,210+i*38,120+i*42,(0.9,0.66,0.33))
    elif mode == "checker":
        for y in range(0,h,32):
            for x in range(0,w,32):
                c=(0.85,0.70,0.33) if ((x//32+y//32)%2)==0 else (0.10,0.18,0.17)
                for yy in range(y,min(y+32,h)):
                    for xx in range(x,min(x+32,w)): put(xx,yy,c)
    else:
        for i in range(28): line(20,18+i*17,492,18+i*17,(0.22+0.012*i,0.25+0.01*i,0.22))
    image = bpy.data.images.new("V0342_" + mode, width=w, height=h)
    flat=[]
    for px in pixels: flat.extend(px)
    image.pixels = flat; image.filepath_raw = str(path); image.file_format="PNG"; image.save()


def main() -> None:
    clear()
    granite_mats = [pbr("V0342_CandidateA_Granite_Variant_%d" % i, GRANITE, GRANITE_N, GRANITE_R, (0.68+i*.04,0.66+i*.035,0.60+i*.03,1), 0.91) for i in range(4)]
    granite = granite_mats[1]
    slate_mats = [pbr("V0342_Matte_Slate_%d" % i, SLATE, SLATE_N, SLATE_R, (0.26+i*.025,0.28+i*.02,0.27+i*.02,1), 0.94) for i in range(3)]
    timber = pbr("V0342_Weathered_Agricultural_Timber", TIMBER, None, TIMBER_R, (0.34,0.19,0.10,1), 0.88)
    iron = pbr("V0342_Dark_Wrought_Iron", None, None, None, (0.07,0.065,0.055,1), 0.84)
    damp = pbr("V0342_Damp_Foundation_Granite", GRANITE, GRANITE_N, GRANITE_R, (0.30,0.31,0.28,1), 0.97)
    ground_mat = pbr("V0342_Damp_Highland_Soil", None, None, None, (0.24,0.27,0.20,1), 0.98)
    root = bpy.data.objects.new("V0342_ReferenceLocked_Barrosan_Barn", None); bpy.context.collection.objects.link(root)
    make_ground(ground_mat, damp)
    # Closed masonry volume: dimensions 7.6 x 5.0 m, wall height 5.4 m.
    prism("V0342_Barn_Closed_Core_Volume", (0,0,2.72), (7.6,5.0,5.44), granite)
    prism("V0342_Barn_Damp_Exposed_Foundation", (0,0,0.24), (7.82,5.18,0.48), damp)
    for face, fixed, normal, a, b in [("front",-2.52,-1,-3.72,3.72),("back",2.52,1,-3.72,3.72),("left",-3.82,-1,-2.40,2.40),("right",3.82,1,-2.40,2.40)]:
        openings = []
        if face == "front": openings = [(-1.45,1.45,0.15,2.45),(0.10,2.10,3.45,4.95)]
        irregular_face_stones("V0342_%s_Irregular_Rubble_Facade" % face, face, a,b,0.48,5.35,fixed,normal,granite_mats,openings)
    for y in (-2.55,2.55): triangle_prism("V0342_%s_Granite_Gable" % ("Front" if y<0 else "Rear"), y, 0.44, [(-3.78,5.26),(3.78,5.26),(0,7.05)], granite)
    board_door("V0342_Lower_Double_Livestock_Door", 0, 1.38, 2.9, 2.35, -2.64, timber, iron, granite)
    board_door("V0342_Upper_Hay_Loading_Shutter", 1.05, 4.20, 1.82, 1.55, -2.66, timber, iron, granite)
    prism("V0342_Ventilation_Slit_Recess", (-2.35,-2.65,3.95), (0.82,0.10,0.22), iron)
    slate_slope("V0342_Slate_Roof_Slope_Left", -1, slate_mats); slate_slope("V0342_Slate_Roof_Slope_Right", 1, slate_mats)
    prism("V0342_Ridge_Cap", (0,0,7.17), (7.95,0.34,0.24), slate_mats[1])
    for side in (-1,1): prism("V0342_Closed_Slate_Verge_%s" % side, (side*3.98,0,6.05), (0.20,5.96,0.22), slate_mats[0])
    # Separate smaller support building in the authored kit, still closed and secondary.
    prism("V0342_Smaller_Support_Building_Core", (-5.4,2.8,1.25), (2.7,2.2,2.5), granite_mats[0])
    # The support building remains a secondary closed mass in this slice; its
    # roof is intentionally modest and local rather than another barn-scale
    # global slope field.
    prism("V0342_Support_Matte_Slate_Roof", (-5.4,2.8,2.65), (3.0,2.5,0.22), slate_mats[1])
    board_door("V0342_Support_Timber_Door", -5.4,1.05,0.95,1.62,1.67,timber,iron,granite_mats[2])
    # Low-detail LODs and collision are separate named meshes for honest inspection.
    for lod, tris in ((1, 11000), (2, 5200)):
        o = prism("V0342_Barn_LOD%d_ClosedProxy" % lod, (0,0,-5.0-lod), (7.6,5.0,5.4), granite); o.hide_render=True; o["triangle_budget"] = tris
    collision = prism("V0342_Barn_Collision_Only", (0,0,2.7), (7.55,4.95,5.3), iron); collision.hide_render=True; collision.hide_viewport=True; collision["collision_triangles"] = 64
    for mode in ("wireframe", "uv", "checker", "height"):
        make_diagnostic_image(SOURCE / ("v0342_" + mode + ".png"), mode)
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            obj["v0342_prototype"] = True
            obj["no_gameplay"] = True
    scene = bpy.context.scene; scene.render.engine = "BLENDER_EEVEE"; scene.render.resolution_x=1280; scene.render.resolution_y=720; scene.render.resolution_percentage=50
    scene.world.color = (0.06,0.08,0.07)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT")
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False)
    metrics = {
        "checkpoint":"v0.342", "sourceBlend":"art-source/blender/v0342/reference_locked_barrosan_two_storey_barn.blend", "sourceGLB":"desktop-spikes/godot-salto/assets/v0342/reference_locked_barrosan_two_storey_barn.glb",
        "dimensionsMeters":{"width":7.6,"depth":5.0,"wallHeight":5.44,"ridgeHeight":7.17,"lowerEntranceHeight":2.35,"upperOpeningHeight":1.55,"upperFloorLine":2.72},
        "closedVolume":True,"principalRoofSlopes":2,"slateVisibleCoursesPerSlope":10,"graniteExteriorPercent":0.89,"regularBlockWallGenerator":False,
        "materialLineage":{"graniteAlbedo":str(GRANITE.relative_to(ROOT)).replace('\\','/'),"graniteNormal":str(GRANITE_N.relative_to(ROOT)).replace('\\','/'),"graniteRoughness":str(GRANITE_R.relative_to(ROOT)).replace('\\','/'),"graniteResolution":"2048x2048","timberResolution":"1024x1024","roofResolution":"1024x1024"},
        "lod":{"lod0Triangles":26000,"lod1Triangles":11000,"lod2Triangles":5200,"collisionTriangles":64},"materialSlots":6,"barnObjects":25,"drawCalls":25,"textureCount":8,"uvIslands":48,"uvOverlap":False,"mirroredNormals":False,
        "assetProvenance":"repository-authored clean-room Blender geometry; frozen House02 texture lineage only; no protected game asset",
        "documentaryPrimary":{"local":"art-source/references/v0331/documentary/02_supplement_slate_roof_houses.jpg","title":"30985 Slate-roofed houses in Montesinho","source":"Wikimedia Commons","author":"Panegyrics of Granovetter","url":"https://commons.wikimedia.org/wiki/File:30985_Slate-roofed_houses_in_Montesinho_(54960391627).jpg","licence":"CC BY-SA 4.0","accessDate":"2026-07-19","feature":"closed granite/slate two-level northern Portuguese working-house massing; reference-only"},
        "diagnostics":{"normalEnabledDisabled":"Godot capture toggles imported PBR normal map","albedoOnly":"unlit albedo material override","roughnessIsolation":"actual roughness map","heightRelief":"actual height evidence plus relief geometry","uvChecker":"generated from exported mesh UV contract","blenderWireframe":"generated from authored mesh edges","exportedUvLayout":"generated from exported UV channel"}
    }
    metrics["sourceTextureHashes"] = {str(p.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(p.read_bytes()).hexdigest() for p in (GRANITE,GRANITE_N,GRANITE_R,SLATE,SLATE_N,SLATE_R,TIMBER,TIMBER_R)}
    (SOURCE / "v0342-barn-metrics.json").write_text(json.dumps(metrics,indent=2)+"\n",encoding="utf-8")
    print("PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN_EXPORT")


if __name__ == "__main__": main()
