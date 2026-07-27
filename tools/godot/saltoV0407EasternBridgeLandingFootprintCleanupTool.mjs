import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0407_eastern_bridge_landing_footprint_cleanup.gd');
const scene = path.join(root, 'desktop-spikes/godot-salto/scenes/v0407_eastern_bridge_landing_footprint_cleanup.tscn');
const runtime = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0407');
const pack = path.join(root, 'artifacts/manual-review/v0407-eastern-bridge-landing-footprint-cleanup');
const required = ['01_PRIMARY_RTS_COLOUR.png','02_EASTERN_LANDING_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_EASTERN_LANDING_CLOSE_GRAYSCALE.png','05_EASTERN_COMPONENT_DIAGNOSTIC.png','06_V0406_V0407_WIDE_COMPARISON.png','07_V0406_V0407_CLOSE_COMPARISON.png','v0407-preservation-audit.json'];
const forbidden = ['move_and_slide','NavigationAgent','damage','projectile','queue_free','attack','hp_loss','economy_mutation'];
function fail(message) { throw new Error(`FAIL_V0407: ${message}`); }
function exists(file) { return fs.existsSync(file); }
function readJson(file) { return JSON.parse(fs.readFileSync(file, 'utf8')); }
function validate() {
  if (!exists(script) || !exists(scene)) fail('v0.407 script/scene missing');
  const text = fs.readFileSync(script, 'utf8');
  if (!text.includes('Bridge_Abutment_+1') || !text.includes('materialAssignmentOnly')) fail('existing eastern abutment material assignment contract missing');
  if (forbidden.some(token => text.toLowerCase().includes(token))) fail('forbidden gameplay token in v0.407 script');
  for (const file of required) {
    if (!exists(path.join(runtime, file))) fail(`runtime evidence missing: ${file}`);
    if (!exists(path.join(pack, file))) fail(`review-pack evidence missing: ${file}`);
  }
  const audit = readJson(path.join(runtime, 'v0407-preservation-audit.json'));
  if (audit.status !== 'RENDERED_CANDIDATE') fail(`audit status ${audit.status}`);
  if (audit.responsibleComponent !== 'Bridge_Abutment_+1') fail('wrong eastern component');
  if (audit.materialAssignmentOnly !== true || audit.verticalCorrection !== 0) fail('candidate is not material-only with zero Y correction');
  if (audit.xCoordinatesChanged || audit.zCoordinatesChanged || audit.topologyChanged || audit.indicesChanged || audit.newGeometry) fail('geometry preservation contract failed');
  if (audit.defaultRuntime !== 'unchanged' || audit.gameplay !== false) fail('runtime preservation contract failed');
  for (const file of required.filter(name => name.endsWith('.png'))) {
    const size = fs.statSync(path.join(runtime, file)).size;
    if (size < 10000) fail(`capture is blank or too small: ${file}`);
  }
  console.log('PASS_V0407_EASTERN_BRIDGE_LANDING_FOOTPRINT_CLEANUP_VALIDATOR (material-only; zero Y correction; 7 real captures; fail-closed audit)');
}
if (process.argv[2] === 'validate') validate(); else fail('usage: node tools/godot/saltoV0407EasternBridgeLandingFootprintCleanupTool.mjs validate');
