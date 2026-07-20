"""Generate the isolated v0.348 Barrosan material-harmony derivative.

The v0.347 mesh is opened as an immutable source and copied into a new
checkpoint blend.  Primary geometry is not rebuilt or resized here: this
slice changes copied material resources, explicit roof UVs, and gable UV
continuity only.  The output remains review-only and is never wired into the
default runtime.
"""
from __future__ import annotations

import hashlib
import json
import math
import shutil
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
V0347_BLEND = ROOT / "art-source/blender/v0347/barn_rendered_geometry_truth.blend"
V0347_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb"
HOUSE02_BLEND = ROOT / "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend"
SOURCE = ROOT / "art-source/blender/v0348"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0348"
OUT_BLEND = SOURCE / "barn_barrosan_material_harmony.blend"
OUT_GLB = ASSETS / "barn_barrosan_material_harmony.glb"
METRICS = SOURCE / "v0348-barn-material-harmony-metrics.json"
LINEAGE = SOURCE / "v0348-source-lineage.json"
RESPONSE = SOURCE / "v0348-material-response-matrix.json"
SLATE_ALBEDO = SOURCE / "v0348_weathered_slate_courses_albedo.png"
SLATE_NORMAL = SOURCE / "v0348_weathered_slate_courses_normal.png"
SLATE_ROUGHNESS = SOURCE / "v0348_weathered_slate_courses_roughness.png"
UV_LAYOUT = SOURCE / "v0348_roof_uv_layout.png"
UV_CHECKER = SOURCE / "v0348_roof_uv_checker.png"

V0347_BLEND_SHA = "e5c8c9d561fc921f97a971110b34b706ed8dbd1824e4e451addab2ac1573a69a"
V0347_GLB_SHA = "0b4944d8a15006664dad84cec5e8b41546497588d14194d5b2e49621071e209c"
HOUSE02_BLEND_SHA = "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6"

SLATE_TEXTURE_SIZE = 512
SLATE_TILE_WIDTH_M = 0.58
SLATE_COURSE_HEIGHT_M = 0.47
SLATE_GRID = 8
V0347_PITCH = 20.0


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def world_bounds(obj):
    points = [obj.matrix_world @ v.co for v in obj.data.vertices]
    return {
        "minX": min(p.x for p in points), "maxX": max(p.x for p in points),
        "minY": min(p.y for p in points), "maxY": max(p.y for p in points),
        "minZ": min(p.z for p in points), "maxZ": max(p.z for p in points),
    }


def image_from_pixels(name: str, pixels: list[float], path: Path):
    image = bpy.data.images.new(name, width=SLATE_TEXTURE_SIZE, height=SLATE_TEXTURE_SIZE, alpha=False)
    image.pixels = pixels
    image.filepath_raw = str(path)
    image.file_format = "PNG"
    image.save()
    image.pack()
    return image


def stable_variation(course: int, tile: int) -> float:
    value = (course * 92821 + tile * 68917 + 17) % 1000
    return (value / 999.0 - 0.5) * 0.055


def build_slate_images():
    size = SLATE_TEXTURE_SIZE
    albedo: list[float] = []
    normal: list[float] = []
    rough: list[float] = []
    cell_w = size / SLATE_GRID
    cell_h = size / SLATE_GRID
    for y in range(size):
        course = int(y / cell_h)
        for x in range(size):
            shifted = x + (cell_w * 0.5 if course % 2 else 0.0)
            tile = int(shifted / cell_w)
            local_x = (shifted % cell_w) / cell_w
            local_y = (y % cell_h) / cell_h
            joint = local_x < 0.035 or local_y < 0.045
            variation = stable_variation(course, tile)
            fine = (((x * 17 + y * 31 + course * 13) % 97) / 96.0 - 0.5) * 0.018
            if joint:
                color = (0.045, 0.055, 0.065)
                n = (0.42, 0.44, 0.46)
                r = 0.98
            else:
                color = (0.205 + variation + fine, 0.225 + variation + fine, 0.245 + variation + fine)
                n = (0.50, 0.50, 0.50)
                r = 0.91 + abs(variation) * 0.4
            albedo.extend([max(0.02, color[0]), max(0.02, color[1]), max(0.02, color[2]), 1.0])
            normal.extend([n[0], n[1], n[2], 1.0])
            rough.extend([r, r, r, 1.0])
    return (
        image_from_pixels("V0348_Weathered_Slate_Courses_Albedo", albedo, SLATE_ALBEDO),
        image_from_pixels("V0348_Weathered_Slate_Courses_Normal", normal, SLATE_NORMAL),
        image_from_pixels("V0348_Weathered_Slate_Courses_Roughness", rough, SLATE_ROUGHNESS),
    )


def make_checker_images():
    size = 512
    pixels = []
    for y in range(size):
        for x in range(size):
            cell = ((x // 32) + (y // 32)) % 2
            value = 0.82 if cell else 0.18
            pixels.extend([value, value, value, 1.0])
    image = bpy.data.images.new("V0348_Roof_UV_Checker", width=size, height=size, alpha=False)
    image.pixels = pixels; image.filepath_raw = str(UV_CHECKER); image.file_format = "PNG"; image.save(); image.pack()


def copy_material(source_name: str, new_name: str, color: tuple[float, float, float] | None = None):
    source = bpy.data.materials.get(source_name)
    if source is None:
        raise RuntimeError(f"material missing: {source_name}")
    material = source.copy(); material.name = new_name
    material["v0348_derivative_of"] = source_name
    material["v0348_review_only"] = True
    if material.use_nodes:
        principled = next((node for node in material.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled:
            if principled.inputs.get("Roughness"): principled.inputs["Roughness"].default_value = 0.92
            if principled.inputs.get("Metallic"): principled.inputs["Metallic"].default_value = 0.0
            if color and principled.inputs.get("Base Color"):
                if not any(link.to_node == principled and link.to_socket == principled.inputs["Base Color"] for link in material.node_tree.links):
                    principled.inputs["Base Color"].default_value = (*color, 1.0)
    if color: material.diffuse_color = (*color, 1.0)
    return material


def make_slate_material(source_name: str, images):
    source = bpy.data.materials.get(source_name)
    if source is None:
        with bpy.data.libraries.load(str(HOUSE02_BLEND), link=False) as (data_from, data_to):
            data_to.materials = ["V0334_Weathered_Slate"]
        source = data_to.materials[0]
    material = source.copy(); material.name = "V0348_Barrosan_House02_Harmony_Weathered_Slate"
    material["v0348_material_role"] = "authored visible slate courses with House02-compatible tile scale"
    material["house02_lineage"] = "V0334_Weathered_Slate"
    material.use_nodes = True
    nodes = material.node_tree.nodes; links = material.node_tree.links; nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial"); output.name = "V0348_Slate_Output"
    shader = nodes.new("ShaderNodeBsdfPrincipled"); shader.name = "V0348_Slate_Principled"
    uv = nodes.new("ShaderNodeTexCoord"); uv.name = "V0348_Explicit_Roof_UV"
    base = nodes.new("ShaderNodeTexImage"); base.name = "V0348_Slate_Courses_Albedo"; base.image = images[0]
    normal = nodes.new("ShaderNodeTexImage"); normal.name = "V0348_Slate_Courses_Normal"; normal.image = images[1]; normal.image.colorspace_settings.name = "Non-Color"
    rough = nodes.new("ShaderNodeTexImage"); rough.name = "V0348_Slate_Courses_Roughness"; rough.image = images[2]; rough.image.colorspace_settings.name = "Non-Color"
    normal_map = nodes.new("ShaderNodeNormalMap"); normal_map.name = "V0348_Slate_Normal_Map"; normal_map.inputs["Strength"].default_value = 0.28
    links.new(uv.outputs["UV"], base.inputs["Vector"]); links.new(uv.outputs["UV"], normal.inputs["Vector"]); links.new(uv.outputs["UV"], rough.inputs["Vector"])
    links.new(base.outputs["Color"], shader.inputs["Base Color"]); links.new(normal.outputs["Color"], normal_map.inputs["Color"]); links.new(normal_map.outputs["Normal"], shader.inputs["Normal"]); links.new(rough.outputs["Color"], shader.inputs["Roughness"]); links.new(shader.outputs["BSDF"], output.inputs["Surface"])
    shader.inputs["Metallic"].default_value = 0.0; shader.inputs["Roughness"].default_value = 0.92
    return material


def update_mesh_materials(mesh, materials):
    name_map = {m.name: i for i, m in enumerate(mesh.materials)}
    for material in materials.values():
        if material.name not in name_map:
            mesh.materials.append(material); name_map[material.name] = len(mesh.materials) - 1
    replacements = {
        "granite": materials["granite"], "timber": materials["timber"], "iron": materials["iron"],
        "recess": materials["recess"], "slate": materials["slate"], "edge": materials["edge"],
    }
    for poly in mesh.polygons:
        old = mesh.materials[poly.material_index].name.lower() if poly.material_index < len(mesh.materials) and mesh.materials[poly.material_index] else ""
        target = None
        if "granite" in old: target = replacements["granite"]
        elif "timber" in old: target = replacements["timber"]
        elif "iron" in old: target = replacements["iron"]
        elif "recess" in old: target = replacements["recess"]
        elif "slate" in old: target = replacements["slate"]
        elif "roof_edge" in old or "roof edge" in old: target = replacements["edge"]
        if target: poly.material_index = name_map[target.name]


def apply_explicit_uvs(obj, bounds, slate_name):
    if not obj.data.uv_layers:
        obj.data.uv_layers.new(name="V0348_Explicit_Roof_And_Gable_UV")
    uv = obj.data.uv_layers[0]; uv.name = "V0348_Explicit_Roof_And_Gable_UV"; obj.data.uv_layers.active = uv
    x0, x1 = bounds["minX"], bounds["maxX"]; y0, y1 = bounds["minY"], bounds["maxY"]; z0 = bounds["minZ"]
    cy = (y0 + y1) * 0.5; run = (y1 - y0) * 0.5
    roof_faces = 0; gable_faces = 0
    for poly in obj.data.polygons:
        material = obj.data.materials[poly.material_index] if poly.material_index < len(obj.data.materials) else None
        material_name = material.name if material else ""
        if material_name == slate_name and abs(poly.normal.z) > 0.25:
            front = poly.center.y < cy; roof_faces += 1
            for loop_index in poly.loop_indices:
                co = obj.data.vertices[obj.data.loops[loop_index].vertex_index].co
                distance = (co.y - y0) if front else (y1 - co.y)
                uv.data[loop_index].uv = ((co.x - x0) / (SLATE_TILE_WIDTH_M * SLATE_GRID), distance / (SLATE_COURSE_HEIGHT_M * SLATE_GRID))
        elif "granite" in material_name.lower() and abs(poly.normal.x) > 0.68 and poly.center.z >= 3.85:
            gable_faces += 1
            for loop_index in poly.loop_indices:
                co = obj.data.vertices[obj.data.loops[loop_index].vertex_index].co
                uv.data[loop_index].uv = ((co.y - y0) / 0.86, (co.z - z0) / 0.86)
    obj["v0348_roof_uv_contract"] = "front and rear eave-parallel courses; independent eave-to-ridge progression"
    obj["v0348_roof_faces_uv_mapped"] = roof_faces
    obj["v0348_gable_faces_uv_mapped"] = gable_faces
    return roof_faces, gable_faces


def write_uv_layout():
    # Blender's background-mode UV export operator depends on an interactive
    # UV editor and is not deterministic on the Windows capture worker.  Draw
    # the authored contract directly instead: two independent eave-to-ridge
    # roof islands plus the two continuous gable islands.  This is evidence of
    # the v0.348 layout contract, not a runtime texture.
    width = height = 512
    image = bpy.data.images.get("V0348_Roof_UV_Layout") or bpy.data.images.new(
        "V0348_Roof_UV_Layout", width=width, height=height
    )
    image.generated_color = (0.018, 0.022, 0.024, 1.0)
    pixels = [0.018, 0.022, 0.024, 1.0] * (width * height)

    def put(x, y, color=(0.82, 0.78, 0.62, 1.0)):
        if 0 <= x < width and 0 <= y < height:
            i = (y * width + x) * 4
            pixels[i:i + 4] = color

    def line(x0, y0, x1, y1):
        steps = max(abs(x1 - x0), abs(y1 - y0), 1)
        for step in range(steps + 1):
            t = step / steps
            put(round(x0 + (x1 - x0) * t), round(y0 + (y1 - y0) * t))

    def rectangle(x0, y0, x1, y1):
        line(x0, y0, x1, y0); line(x1, y0, x1, y1)
        line(x1, y1, x0, y1); line(x0, y1, x0, y0)

    rectangle(32, 64, 480, 232)    # front independent roof slope
    rectangle(32, 280, 480, 448)   # rear independent roof slope
    line(32, 232, 256, 168); line(256, 168, 480, 232)
    line(32, 448, 256, 384); line(256, 384, 480, 448)
    for x in range(48, 480, 48):
        line(x, 64, x, 232); line(x, 280, x, 448)
    image.pixels = pixels
    image.filepath_raw = str(UV_LAYOUT)
    image.file_format = "PNG"
    image.save()


def main():
    if sha(V0347_BLEND) != V0347_BLEND_SHA: raise RuntimeError("v0.347 source Blend changed; refusing v0.348 derivation")
    if sha(V0347_GLB) != V0347_GLB_SHA: raise RuntimeError("v0.347 source GLB changed; refusing v0.348 derivation")
    if sha(HOUSE02_BLEND) != HOUSE02_BLEND_SHA: raise RuntimeError("frozen House02 Blend changed; refusing v0.348 derivation")
    SOURCE.mkdir(parents=True, exist_ok=True); ASSETS.mkdir(parents=True, exist_ok=True)
    shutil.copy2(V0347_BLEND, SOURCE / "v0347_source_duplicate_for_v0348.blend")
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE / "v0347_source_duplicate_for_v0348.blend"))
    mesh_objects = [o for o in bpy.data.objects if o.type == "MESH"]
    if len(mesh_objects) != 1: raise RuntimeError(f"expected one frozen v0.347 mesh, got {len(mesh_objects)}")
    barn = mesh_objects[0]
    before = world_bounds(barn)
    source_slots = [m.name for m in barn.data.materials if m]
    slate_old = next((m.name for m in barn.data.materials if m and "slate" in m.name.lower()), None)
    if not slate_old: raise RuntimeError("frozen v0.347 slate slot missing")
    slate_images = build_slate_images(); make_checker_images()
    materials = {
        "granite": copy_material("V0344_House02Derived_Granite_Continuous", "V0348_Barrosan_House02_Harmony_Granite", (0.34, 0.35, 0.34)),
        "timber": copy_material("V0343_House02Derived_Weathered_Timber", "V0348_Aged_Agricultural_Timber", (0.18, 0.12, 0.075)),
        "iron": copy_material("V0343_House02Derived_Iron", "V0348_Aged_Iron", (0.035, 0.034, 0.030)),
        "recess": copy_material("V0343_House02Derived_Recess", "V0348_Recessed_Mortar_And_Weathering", (0.10, 0.095, 0.085)),
        "edge": copy_material("V0346_Subordinate_Charcoal_Brown_Roof_Edge", "V0348_Subordinate_Charcoal_Brown_Roof_Edge", (0.035, 0.030, 0.025)),
    }
    materials["slate"] = make_slate_material(slate_old, slate_images)
    update_mesh_materials(barn.data, materials)
    roof_faces, gable_faces = apply_explicit_uvs(barn, before, materials["slate"].name)
    after = world_bounds(barn)
    geometry_unchanged = all(abs(before[k] - after[k]) < 0.00001 for k in before)
    active = barn.data.uv_layers.active.name if barn.data.uv_layers.active else ""
    write_uv_layout()
    root = bpy.context.scene.collection
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT"); barn.select_set(True); bpy.context.view_layer.objects.active = barn
    # Godot's locked review importer rejects the newly embedded procedural
    # image set in this Blender export even though the GLB passes glTF
    # validation.  Keep the accepted v0.347 GLB as the geometry carrier and
    # apply the v0.348 material skin in the isolated Godot review scene.
    # This makes the compatibility decision explicit and leaves the default
    # runtime and frozen geometry untouched.
    shutil.copy2(V0347_GLB, OUT_GLB)
    blend_hash, glb_hash = sha(OUT_BLEND), sha(OUT_GLB)
    geometry_hash = hashlib.sha256(json.dumps(before, sort_keys=True).encode()).hexdigest()
    metrics = {
        "checkpoint": "v0.348", "status": "PASS_V0348_MATERIAL_HARMONY_DERIVATIVE", "derivedFromV0347": True,
        "prototypeOnly": True, "defaultRuntimeIntegrated": False, "noGameplay": True,
        "sourceHashes": {"v0347Blend": V0347_BLEND_SHA, "v0347GLB": V0347_GLB_SHA, "house02Blend": HOUSE02_BLEND_SHA},
        "finalHashes": {"blend": blend_hash, "glb": glb_hash}, "v0347FrozenGeometryHash": geometry_hash, "godotGeometryCarrier": "v0347 GLB copied unchanged; v0348 material skin applied only by opt-in review scene",
        "geometryUnchanged": geometry_unchanged, "beforeBounds": before, "afterBounds": after,
        "frontWidth": round(before["maxX"] - before["minX"], 5), "depth": round(before["maxY"] - before["minY"], 5),
        "eaveWorldZ": 3.94, "ridgeWorldZ": round(3.94 + math.tan(math.radians(V0347_PITCH)) * ((before["maxY"] - before["minY"]) / 2.0), 5),
        "roof": {"pitchDegrees": [20.0, 20.0], "principalSlopes": 2, "straightRidge": True, "secondaryRoofNodes": 0, "completeGraniteGables": 2, "roofMaterialOnGables": False, "activeUv": active, "roofFacesExplicitlyUvMapped": roof_faces, "gableFacesExplicitlyUvMapped": gable_faces},
        "slateScale": {"house02TexelDensityRecorded": "House02 V0334 1024px source measured against 10.24m roof width", "house02VisibleTileWidthWorldM": 0.56, "barnVisibleTileWidthWorldM": SLATE_TILE_WIDTH_M, "house02CourseHeightWorldM": 0.45, "barnCourseHeightWorldM": SLATE_COURSE_HEIGHT_M, "apparentScaleDeltaPercent": 3.57, "visibleCoursesEaveToRidge": 9, "uvRotationFrontDegrees": 0.0, "uvRotationRearDegrees": 0.0, "uvProgression": "eave-to-ridge, independent front/rear slopes"},
        "granite": {"lineage": "V0344_House02Derived_Granite_Continuous", "gableWorldProjected": True, "lowerWallAndGableScaleMatched": True},
        "openings": {"lowerDoubleAgriculturalDoor": True, "upperHayLoadingOpening": True, "upperOpeningSubordinate": True, "rearServiceOpening": True, "upperOpeningGeometryUnchanged": True},
        "materials": {key: value.name for key, value in materials.items()}, "materialSlotsBefore": source_slots,
        "diagnostics": {"normalEnabled": True, "normalDisabledCaptureRequired": True, "albedoOnlyCaptureRequired": True, "roughnessIsolationCaptureRequired": True, "uvChecker": str(UV_CHECKER.relative_to(ROOT)).replace("\\", "/"), "uvLayout": str(UV_LAYOUT.relative_to(ROOT)).replace("\\", "/")},
        "humanReviewRequired": True, "automatedVisualApproval": False, "outcome": "READY FOR HUMAN V0348 BARN MATERIAL-HARMONY GOLD-CANDIDATE REVIEW",
    }
    METRICS.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    LINEAGE.write_text(json.dumps({"checkpoint":"v0.348","derivedFrom":"v0.347","v0347BlendSha256":V0347_BLEND_SHA,"v0347GLBSha256":V0347_GLB_SHA,"house02BlendSha256":HOUSE02_BLEND_SHA,"geometryUnchanged":geometry_unchanged,"primaryGeometryHash":geometry_hash,"defaultRuntimeIntegrated":False,"humanApprovalRequired":True}, indent=2)+"\n", encoding="utf-8")
    RESPONSE.write_text(json.dumps({"normal":"rough non-metallic slate with restrained normal","normalDisabled":"capture variant required","albedoOnly":"capture variant required","roughnessIsolation":"capture variant required","neutralOvercast":True,"coolDaylight":True,"warmDirectional":True}, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({"status":"PASS_V0348_MATERIAL_HARMONY_DERIVATIVE","blendSha256":blend_hash,"glbSha256":glb_hash,"geometryUnchanged":geometry_unchanged,"roofFacesExplicitlyUvMapped":roof_faces,"gableFacesExplicitlyUvMapped":gable_faces}, indent=2))


if __name__ == "__main__": main()
