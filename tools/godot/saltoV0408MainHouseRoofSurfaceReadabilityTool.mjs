import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0408_main_house_roof_surface_readability.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0408_main_house_roof_surface_readability.tscn');
const router = path.join(root, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const pkg = path.join(root, 'package.json');
const report = path.join(root, 'docs/V0408_MAIN_HOUSE_ROOF_SURFACE_READABILITY_REPORT.md');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0408');
const pack = path.join(root, 'artifacts/manual-review/v0408-main-house-roof-surface-readability');
const files = ['01_PRIMARY_RTS_COLOUR.png','02_MAIN_HOUSE_ROOF_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_MAIN_HOUSE_ROOF_GRAYSCALE.png','05_MAIN_HOUSE_ROOF_MATERIAL_DIAGNOSTIC.png','06_V0407_V0408_WIDE_COMPARISON.png','07_V0407_V0408_ROOF_CLOSE_COMPARISON.png','v0408-preservation-audit.json'];
const forbidden = ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','queue_free','combat','construct_building','new_geometry'];
const must = (condition, message) => { if (!condition) throw new Error(`FAIL_V0408: ${message}`); };
const read = file => fs.readFileSync(file, 'utf8');
const png = file => { const bytes = fs.readFileSync(file); must(bytes.readUInt32BE(0) === 0x89504e47, `not PNG: ${file}`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20), bytes: bytes.length }; };
function validate() {
  for (const [file, label] of [[script,'script'],[scene,'scene'],[router,'router'],[pkg,'package'],[report,'report']]) must(fs.existsSync(file), `${label} missing`);
  const g = read(script), r = read(router), p = read(pkg), d = read(report);
  for (const token of ['v0407_eastern_bridge_landing_footprint_cleanup.gd','V0400_Main_House_Roof_Left_Plane','V0400_Main_House_Roof_Right_Plane','V0400_Main_House_Left_Roof_Visual_Closure','V0400_Main_House_Right_Roof_Visual_Closure','V0400_Main_House_Ridge_Beam','V0400_Main_House_Left_Eave','V0400_Main_House_Right_Eave','v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png','materialOnly','uvArraysChanged','geometryChanged']) must(g.includes(token), `script contract missing: ${token}`);
  for (const token of ['--v0408-main-house-roof-capture','--v0408-main-house-roof-smoke','v0408_main_house_roof_surface_readability.gd']) must(r.includes(token), `router contract missing: ${token}`);
  for (const token of ['godot:play:v0408-main-house-roof','godot:smoke:v0408-main-house-roof','godot:capture:v0408-main-house-roof','godot:validate:v0408-main-house-roof']) must(p.includes(token), `package command missing: ${token}`);
  for (const token of ['v0.407','material-only','UV','chimney','ridge','eaves','grayscale','default runtime']) must(d.toLowerCase().includes(token.toLowerCase()), `report evidence missing: ${token}`);
  for (const file of files) {
    const runtimeFile = path.join(runtime, file), packFile = path.join(pack, file);
    must(fs.existsSync(runtimeFile), `runtime evidence missing: ${file}`);
    must(fs.existsSync(packFile), `review pack evidence missing: ${file}`);
    if (file.endsWith('.png')) { const image = png(runtimeFile); must(image.width === (file.startsWith('06_') || file.startsWith('07_') ? 3840 : 1920) && image.height === 1080 && image.bytes > 10000, `invalid capture: ${file}`); }
  }
  must(!forbidden.some(token => g.toLowerCase().includes(token.toLowerCase())), 'forbidden gameplay or geometry token in script');
  const audit = JSON.parse(read(path.join(runtime, 'v0408-preservation-audit.json')));
  must(audit.status === 'RENDERED_CANDIDATE', `audit status ${audit.status}`);
  must(audit.materialOnly === true && audit.geometryChanged === false && audit.uvArraysChanged === false, 'material-only preservation failed');
  must(audit.topologyChanged === false && audit.indicesChanged === false && audit.verticesChanged === false && audit.transformsChanged === false && audit.aabbChanged === false, 'mesh preservation failed');
  must(audit.newGeometry === false && audit.duplicateMeshes === false && audit.duplicateSurfaces === false && audit.overlays === false && audit.decals === false, 'duplicate/overlay contract failed');
  must(audit.gameplay === false && audit.defaultRuntime === 'unchanged' && audit.fallbackRenderer === 'unchanged' && audit.debugRenderer === 'unchanged', 'runtime preservation failed');
  must(audit.requiredRoofNodes === 5, 'expected five existing roof material nodes');
  console.log('PASS_V0408_MAIN_HOUSE_ROOF_SURFACE_READABILITY_VALIDATOR (material-only; existing roof nodes; UV-preserving; 7 real captures)');
}
if (process.argv[2] !== 'validate') throw new Error('usage: node tools/godot/saltoV0408MainHouseRoofSurfaceReadabilityTool.mjs validate');
validate();
