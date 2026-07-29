import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { createHash } from 'node:crypto';

const repo = resolve('.');
const base = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0312');
const pack = join(repo, 'artifacts', 'manual-review', 'v0312-h3-runtime-evidence-integrity-recovery');
const errors = [];
const readJson = p => existsSync(p) ? JSON.parse(readFileSync(p, 'utf8')) : null;
const pngSig = Buffer.from([137,80,78,71,13,10,26,10]);
const sha = p => createHash('sha256').update(readFileSync(p)).digest('hex');
const manifest = id => readJson(join(base, id, 'semantic-capture-manifest.json'));

function requireFile(name) { if (!existsSync(join(pack, name))) errors.push(`missing ${name}`); }

function validateMode(id) {
  const m = manifest(id);
  if (!m) { errors.push(`missing ${id} semantic manifest`); return []; }
  if (m.checkpoint !== 'v0.312') errors.push(`${id} checkpoint mismatch`);
  if (m.h3OptIn !== true || JSON.stringify(m.integratedRoles) !== JSON.stringify(['Worker','Militia'])) errors.push(`${id} H3 role/opt-in contract failed`);
  if (m.captureCount < 60) errors.push(`${id} needs at least 60 semantic captures`);
  const sidecars = join(base, id, 'sidecars');
  const rows = [];
  for (const record of m.records ?? []) {
    const png = join(base, id, 'screenshots', record.captureFilename);
    const sidecarPath = join(sidecars, `${record.captureFilename.replace(/\.png$/u, '')}.json`);
    const s = readJson(sidecarPath);
    if (!s) { errors.push(`missing sidecar ${id}/${record.captureFilename}`); continue; }
    for (const key of ['captureFilename','runtimeTimestampMs','frameNumber','scenarioName','authoritativeUnitIds','units','selectedIds','cameraWorldPosition','cameraZoom','h3FlagState','fallbackState','screenshotSha256','previousRelatedScreenshotSha256']) if (!(key in s)) errors.push(`${id}/${record.captureFilename} missing sidecar field ${key}`);
    if (!existsSync(png)) { errors.push(`missing PNG ${id}/${record.captureFilename}`); continue; }
    const bytes = readFileSync(png);
    if (bytes.length < 10000 || !bytes.subarray(0,8).equals(pngSig)) errors.push(`invalid/blank PNG ${id}/${record.captureFilename}`);
    if (sha(png) !== s.screenshotSha256) errors.push(`SHA mismatch ${id}/${record.captureFilename}`);
    rows.push(s);
  }
  return rows;
}

function positions(rows, id) { return rows.filter(r => r.authoritativeUnitIds?.includes(id)).map(r => r.units?.find(u => u.id === id)?.worldPosition).filter(Boolean); }
function changed(values) { return new Set(values.map(v => JSON.stringify(v))).size > 1; }
function scenario(rows, name) { return rows.filter(r => r.scenarioName === name); }

function validate() {
  for (const name of ['v0311-audit/v0311-duplicate-file-register.md','v0311-audit/v0311-sha256-register.json','v0311-audit/v0311-perceptual-hash-register.json','v0311-audit/v0311-pixel-difference-register.json','v0311-audit/v0311-semantic-claim-failure-register.md','v0311-audit/v0311-count-inflation-register.md','v0311-audit/v0311-save-rollback-limitation-register.md','v0311-audit/v0311-corrected-verdict.md','00_read_me_first.md','evidence-integrity-report.md','semantic-capture-register.json','final-method-decision.md']) requireFile(name);
  const oldSha = readJson(join(pack,'v0311-audit','v0311-sha256-register.json')) ?? [];
  if (oldSha.length < 86) errors.push(`v0.311 audit must contain the historical physical PNG set, got ${oldSha.length}`);
  const oldUnique = new Set(oldSha.map(r => r.sha256)).size;
  if (oldUnique >= oldSha.length) errors.push(`v0.311 audit did not expose duplicate physical frames: ${oldUnique}/${oldSha.length}`);
  const playerRows = validateMode('player');
  const debugRows = validateMode('debug-review');
  const rows = [...playerRows, ...debugRows];
  const byScenario = new Map();
  for (const row of rows) {
    const list = byScenario.get(row.scenarioName) ?? [];
    list.push(row); byScenario.set(row.scenarioName, list);
  }
  for (const [name, list] of byScenario) {
    const accepted = list.filter(r => r.semanticAccepted !== false);
    const hashes = accepted.map(r => r.screenshotSha256);
    if (new Set(hashes).size !== hashes.length && !['clean_gameplay'].includes(name)) errors.push(`accepted semantic scenario ${name} contains duplicate screenshot SHA`);
  }
  if (!changed(positions(scenario(playerRows,'worker_movement'), 'worker_00'))) errors.push('worker movement positions did not change');
  if (!changed(positions(scenario(playerRows,'militia_movement'), 'friendly_00'))) errors.push('militia movement positions did not change');
  for (const name of ['worker_bridge','militia_bridge']) if (!changed(positions(scenario(playerRows,name), name.startsWith('worker') ? 'worker_00' : 'friendly_00'))) errors.push(`${name} positions did not progress`);
  const pan = scenario(playerRows,'camera_pan').map(r => JSON.stringify(r.cameraWorldPosition));
  if (new Set(pan).size < 2) errors.push('camera pan coordinates did not change');
  const zoom = scenario(playerRows,'camera_zoom').map(r => r.cameraZoom);
  if (new Set(zoom).size < 3) errors.push('camera zoom values did not change across min/ordinary/max');
  if (new Set(scenario(playerRows,'selection').map(r => JSON.stringify(r.selectedIds))).size < 4) errors.push('selection IDs did not change across selection sequence');
  const work = scenario(playerRows,'worker_work_state');
  if (!work.some(r => r.units?.some(u => u.activityState === 'working'))) errors.push('Worker work state not recorded');
  const ready = scenario(playerRows,'militia_ready_state');
  const readyUnsupported = ready.some(r => r.note?.includes('unsupported'));
  if (!readyUnsupported && !ready.some(r => r.note?.includes('not supported'))) errors.push('Militia ready-state limitation was not recorded honestly');
  const save = scenario(playerRows,'save_write_reload');
  if (!save.some(r => r.saveChecksum && r.saveChecksum.length === 64)) errors.push('real save checksum missing');
  if (save.length < 3) errors.push('save/write/load sequence incomplete');
  const rollback = scenario(playerRows,'rollback');
  if (!rollback.some(r => r.fallbackState === true) || !rollback.some(r => r.h3Enabled === true)) errors.push('rollback did not show H3/fallback/H3 presentation states');
  const manifestDecision = readFileSync(join(pack,'final-method-decision.md'),'utf8');
  if (!manifestDecision.includes('H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN')) errors.push('final decision must remain unproven');
  const report = join(repo,'docs','V0312_H3_RUNTIME_EVIDENCE_INTEGRITY_RECOVERY_REPORT.md');
  if (!existsSync(report)) errors.push('missing v0.312 report');
  else if (!readFileSync(report,'utf8').includes('H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN')) errors.push('report and pack decision disagree');
  for (const name of ['movement-sequence-register.md','bridge-sequence-register.md','occlusion-sequence-register.md','camera-sequence-register.md','Worker-state-register.md','Militia-state-register.md','selection-register.md','save-write-load-register.md','rollback-register.md','scale-register.md']) requireFile(name);
  if (!existsSync(join(repo,'desktop-spikes','godot-salto','scripts','barrosan_h3_runtime_presentation_adapter_v0311.gd'))) errors.push('H3 adapter missing');
  const status = errors.length ? 'FAIL_V0312_H3_RUNTIME_EVIDENCE_INTEGRITY_VALIDATION' : 'PASS_V0312_H3_RUNTIME_EVIDENCE_INTEGRITY_VALIDATION';
  const reportOut = {status, errors, physicalPngs: rows.length, uniqueSha256: new Set(rows.map(r=>r.screenshotSha256)).size, semanticGameplayEvents: rows.filter(r=>r.semanticAccepted !== false).length, v0311PhysicalPngs: oldSha.length, v0311UniqueSha256: oldUnique, finalDecision: 'H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN'};
  requireFile('v0311-audit/v0311-corrected-verdict.md');
  console.log(status);
  console.log(JSON.stringify(reportOut));
  process.exitCode = errors.length ? 1 : 0;
}

validate();
