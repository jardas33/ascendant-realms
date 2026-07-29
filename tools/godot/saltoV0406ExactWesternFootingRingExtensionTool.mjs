import fs from 'node:fs';
import path from 'node:path';
const repo = process.cwd();
const file = p => path.join(repo, p);
const must = (value, label) => { if (!value) throw new Error(`missing ${label}`); };
const png = p => { const b = fs.readFileSync(p); must(b.readUInt32BE(0) === 0x89504e47, `${p} PNG signature`); return { width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length }; };
function validate() {
  const script = file('desktop-spikes/godot-salto/scripts/v0406_exact_western_footing_ring_extension.gd');
  const scene = file('desktop-spikes/godot-salto/scenes/v0406_exact_western_footing_ring_extension.tscn');
  const router = file('desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
  const pkg = file('package.json');
  const runtime = file('desktop-spikes/godot-salto/artifacts/runtime/v0406');
  const pack = file('artifacts/manual-review/v0406-exact-western-footing-ring-extension');
  for (const [p, label] of [[script,'v0.406 script'],[scene,'v0.406 scene'],[router,'router'],[pkg,'package']]) must(fs.existsSync(p), label);
  const g = fs.readFileSync(script, 'utf8');
  const r = fs.readFileSync(router, 'utf8');
  const p = fs.readFileSync(pkg, 'utf8');
  for (const t of ['Bridge_Footing_-1','V0406_INDICES := [2, 3, 4, 6]','Vector3(0.444089, 0.0, 0.106548)','V0406_MAX_DISPLACEMENT := 0.46','topologyChanged','verticesMoved": 4','overlays": false','gameplay": false','defaultRuntime']) must(g.includes(t), `script contract ${t}`);
  for (const t of ['--v0406-western-footing-capture','--v0406-western-footing-smoke','v0406_exact_western_footing_ring_extension.gd']) must(r.includes(t), `router contract ${t}`);
  for (const t of ['godot:play:v0406-western-footing','godot:smoke:v0406-western-footing','godot:capture:v0406-western-footing','godot:validate:v0406-western-footing']) must(p.includes(t), `package contract ${t}`);
  for (const forbidden of ['move_and_slide','NavigationAgent','pathfinding','route_follow','attack','damage','hit_points','economy','production_queue','spawn_unit','add_building','combat','construct_building']) if (g.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`forbidden gameplay token ${forbidden}`);
  const images = ['01_PRIMARY_RTS_COLOUR.png','02_WESTERN_LANDING_CLOSE_COLOUR.png','03_PRIMARY_RTS_GRAYSCALE.png','04_WESTERN_LANDING_CLOSE_GRAYSCALE.png','05_MOVED_RING_DIAGNOSTIC.png'];
  for (const n of images) { const pth = file(`desktop-spikes/godot-salto/artifacts/runtime/v0406/${n}`); must(fs.existsSync(pth), `runtime ${n}`); const i = png(pth); if (i.width !== 1920 || i.height !== 1080 || i.bytes < 10000) throw new Error(`${n} invalid dimensions`); }
  for (const n of ['06_V0401_V0406_WIDE_COMPARISON.png','07_V0401_V0406_CLOSE_COMPARISON.png']) { const pth = file(`desktop-spikes/godot-salto/artifacts/runtime/v0406/${n}`); must(fs.existsSync(pth), `runtime ${n}`); const i = png(pth); if (i.width !== 3840 || i.height !== 1080 || i.bytes < 10000) throw new Error(`${n} invalid dimensions`); }
  const auditPath = file('desktop-spikes/godot-salto/artifacts/runtime/v0406/v0406-preservation-audit.json');
  must(fs.existsSync(auditPath), 'v0.406 audit');
  const audit = JSON.parse(fs.readFileSync(auditPath, 'utf8'));
  must(audit.status === 'RENDERED_CANDIDATE', 'rendered candidate status');
  must(audit.affectedNode === 'Bridge_Footing_-1' && JSON.stringify(audit.affectedVertexIndices) === JSON.stringify([2,3,4,6]), 'exact affected ring');
  must(audit.verticesMoved === 4 && audit.verticesAdded === 0 && audit.verticesDeleted === 0 && audit.indicesChanged === false && audit.topologyChanged === false, 'mesh preservation');
  must(audit.maxHorizontalDisplacement <= 0.46 && audit.yDeltaPerVertex === 0, 'bounded displacement');
  must(fs.existsSync(pack), 'review pack');
  for (const n of [...images,'06_V0401_V0406_WIDE_COMPARISON.png','07_V0401_V0406_CLOSE_COMPARISON.png','v0406-preservation-audit.json']) must(fs.existsSync(path.join(pack,n)), `review pack ${n}`);
  console.log('PASS_V0406_EXACT_WESTERN_FOOTING_RING_EXTENSION_VALIDATOR (7 real captures; four existing vertices; fail-closed audit)');
}
if (process.argv[2] === 'validate') validate(); else throw new Error('usage: node tools/godot/saltoV0406ExactWesternFootingRingExtensionTool.mjs validate');
