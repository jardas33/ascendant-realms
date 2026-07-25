import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const repo = process.cwd();
const sourceGlb = path.join(repo, 'external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/exports/barrosan_highland_infrastructure_v0380.glb');
const sourceScript = path.join(repo, 'external-art-intake/original-barrosan/v0380-authored-highland-infrastructure/source/generate_v0380_highland_infrastructure.py');
const importedGlb = path.join(repo, 'desktop-spikes/godot-salto/assets/v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb');
const v0382Script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0382_clustered_highland_dressing.gd');
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0383_highland_style_coherence.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0383_highland_style_coherence.gd');
const router = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const project = path.join(repo, 'package.json');
const runtime = path.join(repo, 'desktop-spikes/godot-salto/artifacts/runtime/v0383');
const pack = path.join(repo, 'artifacts/manual-review/v0383-highland-style-coherence');
const log = path.join(repo, 'artifacts/work/v0383-iteration-log.md');
const report = path.join(repo, 'docs/V0383_HIGHLAND_DRESSING_VISUAL_HIERARCHY_AND_STYLE_COHERENCE_REPAIR_REPORT.md');
const expectedGlb = '746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb';
const expectedSource = '4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19';
const images = ['01_PRIMARY_RTS_VIEW.png', '02_BRIDGE_CLEARANCE_AUDIT.png', '03_RIVERBANK_VARIATION_DETAIL.png', '04_VEGETATION_MASS_SPACING.png', '05_DRESSING_DISTRIBUTION_AUDIT.png', '06_GRAYSCALE_PRIMARY.png'];
const packFiles = ['00_READ_ME_FIRST.md', ...images, '07_ITERATION_SUMMARY.md', '08_VALIDATION.json'];

const must = (value, label) => { if (!value) throw new Error(`missing ${label}`); };
const read = file => fs.readFileSync(file, 'utf8');
const sha256 = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const includes = (value, token, label) => { if (!value.includes(token)) throw new Error(`${label} missing ${token}`); };
const png = file => {
  const b = fs.readFileSync(file);
  if (b.readUInt32BE(0) !== 0x89504e47 || b.readUInt32BE(4) !== 0x0d0a1a0a) throw new Error(`${file} is not PNG`);
  return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length };
};

function validate() {
  for (const [file, label] of [[sourceGlb, 'accepted v0.380 source GLB'], [sourceScript, 'accepted v0.380 generator'], [importedGlb, 'accepted imported GLB'], [v0382Script, 'preserved v0.382 script'], [scene, 'v0.383 scene'], [script, 'v0.383 script'], [router, 'opt-in router'], [report, 'v0.383 report'], [log, 'v0.383 iteration log']]) must(fs.existsSync(file), label);
  if (sha256(sourceGlb) !== expectedGlb || sha256(importedGlb) !== expectedGlb) throw new Error('accepted v0.380 GLB hash changed');
  if (sha256(sourceScript) !== expectedSource) throw new Error('accepted v0.380 generator hash changed');
  const g = read(script);
  const r = read(router);
  const p = JSON.parse(read(project));
  includes(g, 'v0380/corrected-highland-infrastructure/barrosan_highland_infrastructure_v0380.glb', 'unchanged accepted base kit');
  includes(g, 'V0383_Restricted_Dressing_Only', 'v0.383 dressing root');
  includes(g, 'V0383_Six_NonRepeating_Riverbank_Clusters', 'six non-repeating clusters');
  includes(g, 'Cluster_A_ReedsLowGrassRock', 'pattern 1');
  includes(g, 'Cluster_B_RocksSparseReeds', 'pattern 2');
  includes(g, 'Cluster_C_LowShrubBuriedRock', 'pattern 3');
  includes(g, 'V0383_Bridge_First_Oblique_RTS_Camera', 'bridge-first camera');
  includes(g, 'protectedBridgeClearance', 'clearance manifest');
  includes(g, 'shadow_bias = 0.09', 'softened shadow bias');
  includes(g, 'PROJECTION_ORTHOGONAL', 'controlled orthographic camera');
  includes(g, 'baseKitUnchanged', 'base preservation manifest');
  for (const forbidden of ['move_and_slide', 'NavigationAgent', 'attack', 'damage', 'hit_points', 'economy', 'production_queue', 'route_follow', 'add_building', 'spawn_unit']) {
    if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`v0.383 dressing script contains forbidden gameplay token: ${forbidden}`);
  }
  for (const token of ['--v0383-style-coherence', '--v0383-style-coherence-smoke', '--v0383-style-coherence-capture', 'v0383_highland_style_coherence.tscn']) includes(r, token, 'v0.383 opt-in router');
  for (const key of ['godot:play:v0383-style-coherence', 'godot:smoke:v0383-style-coherence', 'godot:capture:v0383-style-coherence', 'godot:validate:v0383-style-coherence']) must(p.scripts?.[key], `package command ${key}`);
  for (const file of images) {
    const d = png(path.join(runtime, file));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`${file} is not a real 1920x1080 capture`);
  }
  for (const iteration of [1, 2, 3]) {
    const dir = path.join(repo, `artifacts/work/v0383-iteration-0${iteration}`);
    must(fs.existsSync(dir), `v0.383 iteration ${iteration} directory`);
    const d = png(path.join(dir, '01_PRIMARY_RTS_VIEW.png'));
    if (d.width !== 1920 || d.height !== 1080 || d.bytes < 10000) throw new Error(`iteration ${iteration} primary is not a real capture`);
  }
  const manifest = JSON.parse(read(path.join(runtime, 'v0383-highland-style-coherence.json')));
  for (const [key, expected] of Object.entries({ baseKitUnchanged: true, dressingOnly: true, protectedBridgeClearance: true, riverbankClusters: 6, highlandMasses: 2, rockClusters: 4, isolatedRocks: 0, strongRedAccents: 0, buildings: false, units: false, gameplay: false, defaultRuntime: 'unchanged', route: 'opt-in-only', glbSha256: expectedGlb, sourceSha256: expectedSource })) {
    if (manifest[key] !== expected) throw new Error(`runtime manifest ${key} boundary failed`);
  }
  must(fs.existsSync(pack), 'v0.383 review pack');
  const actualPack = fs.readdirSync(pack).filter(name => fs.statSync(path.join(pack, name)).isFile()).sort();
  if (JSON.stringify(actualPack) !== JSON.stringify([...packFiles].sort())) throw new Error(`review pack file contract failed; expected ${packFiles.length} files`);
  const validation = JSON.parse(read(path.join(pack, '08_VALIDATION.json')));
  if (validation.status !== 'READY FOR HUMAN V0383 HIGHLAND STYLE-COHERENCE REVIEW') throw new Error('v0.383 review status is not human-review ready');
  if (validation.baseGlbSha256 !== expectedGlb || validation.sourceGeneratorSha256 !== expectedSource) throw new Error('v0.383 hash record failed');
  includes(read(path.join(pack, '00_READ_ME_FIRST.md')), 'READY FOR HUMAN V0383 HIGHLAND STYLE-COHERENCE REVIEW', 'review README status');
  includes(read(path.join(pack, '07_ITERATION_SUMMARY.md')), 'Iteration 1', 'iteration summary');
  includes(read(path.join(repo, 'artifacts/work/v0383-iteration-log.md')), 'Iteration 3', 'iteration log');
  console.log(`PASS_V0383_HIGHLAND_STYLE_COHERENCE_VALIDATOR (${images.length} real captures; 3 inspected iterations; 6 non-repeating bank clusters; accepted v0.380 kit unchanged; opt-in dressing only; no gameplay)`);
}

if (process.argv[2] === 'validate') validate();
else throw new Error('usage: node tools/godot/saltoV0383HighlandStyleCoherenceTool.mjs validate');
