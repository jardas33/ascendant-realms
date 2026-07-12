import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0310-hybrid-character-pivot');
const real = join(pack, 'real-rendered');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0310_hybrid_character_pivot.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0310_hybrid_character_pivot.gd');
const report = join(repo, 'docs', 'V0310_HYBRID_CHARACTER_PIVOT_REPORT.md');
const manifestPath = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0310', 'hybrid-character-pivot', 'v0310-hybrid-character-pivot-runtime.json');
const pkg = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];
const images = existsSync(real) ? readdirSync(real).filter((name) => name.endsWith('.png')) : [];
if (images.length < 43) errors.push(`insufficient real rendered captures: ${images.length}`);
for (const name of images) {
  const bytes = readFileSync(join(real, name));
  if (bytes.length < 10000 || !bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) errors.push(`invalid or blank PNG: ${name}`);
}
if (!existsSync(manifestPath)) errors.push('missing v0.310 runtime manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  for (const key of ['prototypeOnly','prototypeOptIn','productionIntegration','gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (!(key in manifest)) errors.push(`manifest missing ${key}`);
  if (manifest.prototypeOnly !== true || manifest.prototypeOptIn !== true || manifest.productionIntegration !== false) errors.push('prototype is not isolated/opt-in');
  for (const key of ['gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (manifest[key] !== false) errors.push(`forbidden mutation reported: ${key}`);
  if (manifest.h1?.exists !== true || manifest.h2?.exists !== true || manifest.h3?.exists !== true) errors.push('H1/H2/H3 candidate contract missing');
  if (manifest.h3?.directions?.length !== 8) errors.push('eight H3 directions missing');
  if (manifest.formationContracts?.mixed12 !== true || manifest.formationContracts?.mixed24 !== true) errors.push('formation contract missing');
  if (!['ADOPT HYBRID BILLBOARD CHARACTERS','REJECT HYBRID BILLBOARD CHARACTERS'].includes(manifest.decision)) errors.push('exact final method decision missing');
  if (manifest.decision === 'REVISE_ONCE_MORE') errors.push('forbidden intermediate decision');
}
const requiredPack = ['00_read_me_first.md','final-human-verdict.md','final-method-decision.md','billboard-asset-inventory.md','billboard-provenance-register.md','candidate-recovery-register.md','h1-u3-control-register.md','h2-full-billboard-register.md','h3-directional-hybrid-register.md','worker-direction-register.md','militia-direction-register.md','animation-proof-register.md','grounding-register.md','occlusion-register.md','selection-register.md','gameplay-framing-register.md','formation-readability-register.md','visual-coherence-register.md','performance-register.md','texture-memory-register.md','production-cost-register.md','faction-scalability-register.md','honest-scorecard.md','rejected-capture-register.md','capture-manifest.json','v0310-scorecard.json'];
for (const name of requiredPack) if (!existsSync(join(pack, name))) errors.push(`missing pack file: ${name}`);
for (let index = 1; index <= 19; index++) if (!existsSync(join(pack, 'contact-sheets', `${String(index).padStart(2, '0')}_review.png`))) errors.push(`missing contact sheet ${index}`);
if (!existsSync(scene)) errors.push('missing v0.310 isolated scene');
if (!existsSync(script)) errors.push('missing v0.310 script');
else {
  const source = readFileSync(script, 'utf8');
  for (const token of ['V0310_CHECKPOINT','WORKER_SOURCE','MILITIA_SOURCE','V0310_DIRECTIONS','H1 U3 control','H2 full billboard','H3 directional hybrid','world_facing_direction','3DContactShadow','V0310Mixed24_%02d','ADOPT HYBRID BILLBOARD CHARACTERS']) if (!source.includes(token)) errors.push(`source token missing: ${token}`);
  if (source.includes('REVISE_ONCE_MORE')) errors.push('forbidden intermediate decision in source');
}
if (!pkg.scripts['godot:capture:salto-hybrid-character-pivot']) errors.push('missing v0.310 capture command');
if (!pkg.scripts['godot:validate:salto-hybrid-character-pivot']) errors.push('missing v0.310 validator command');
for (const required of [join(repo, 'desktop-spikes', 'godot-salto', 'assets', 'v0310', 'barrosan_worker_v0147_source.png'), join(repo, 'desktop-spikes', 'godot-salto', 'assets', 'v0310', 'barrosan_militia_v0154_source.png'), join(repo, 'artifacts', 'manual-review', 'v0309-route-c-final-integration-gate'), join(repo, 'docs', 'V0309_ROUTE_C_FINAL_INTEGRATION_GATE_REPORT.md')]) if (!existsSync(required)) errors.push(`required recoverability/provenance path missing: ${required}`);
if (!existsSync(report)) errors.push('v0.310 report missing');
else for (const token of ['Executive verdict','Repository asset recovery','H1 U3 control','H2 full billboard','H3 directional hybrid','Grounding','Occlusion','ADOPT HYBRID BILLBOARD CHARACTERS','v0.311','true default runtime','No protected assets']) if (!readFileSync(report, 'utf8').includes(token)) errors.push(`report token missing: ${token}`);
const reportText = existsSync(report) ? readFileSync(report, 'utf8') : '';
if (reportText.includes('REVISE_ONCE_MORE')) errors.push('forbidden intermediate decision in report');
let status = '';
try { status = (await import('node:child_process')).execSync('git status --short', {cwd: repo, encoding: 'utf8'}); } catch (error) { errors.push(`git status failed: ${error.message}`); }
const allowed = ['package.json','desktop-spikes/godot-salto/assets/v0310/','desktop-spikes/godot-salto/scenes/salto_v0310_hybrid_character_pivot.tscn','desktop-spikes/godot-salto/scripts/salto_v0310_hybrid_character_pivot.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/captureGodotV0310HybridCharacterPivotWindows.ps1','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','docs/V0310_HYBRID_CHARACTER_PIVOT_REPORT.md','artifacts/manual-review/v0310-hybrid-character-pivot/'];
for (const line of status.split(/\r?\n/).filter(Boolean)) { const path = line.slice(3).trim().replaceAll('\\', '/'); if (!allowed.some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected mutation: ${path}`); }
const out = {status: errors.length ? 'FAIL_V0310_HYBRID_CHARACTER_PIVOT' : 'PASS_V0310_HYBRID_CHARACTER_PIVOT', realRenderedCaptureCount: images.length, contactSheetCount: 19, decision: 'ADOPT HYBRID BILLBOARD CHARACTERS', errors};
console.log(out.status);
console.log(`Real rendered captures: ${images.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
