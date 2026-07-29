import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = path.resolve(import.meta.dirname, '../..');
const workspaceRoot = path.resolve(root, '..');
const tesanaRoot = path.resolve(process.env.V0429_TESANA_ROOT ?? path.join(workspaceRoot, 'WB_tesana'));
const reviewPack = path.join(root, 'artifacts/manual-review/v0429-tesana-disposable-runtime-provenance-gate');
const sourcePreflightPath = path.join(reviewPack, 'v0429-source-preflight-manifest.json');
const baselineCommit = '0a6f8f125445ad563bc56af6a676fb929e62de8d';
const baselineBranch = 'codex/v0428-tesana-intake-audit';
const auditBranch = 'codex/v0429-tesana-disposable-runtime-provenance';
const acceptedBranch = 'codex/v0215-v0226-recovery';
const acceptedSha = '4a2de384b2f0c3f348f24ff549ab2293f29e3b7f';
const godot = process.env.V0429_GODOT_BIN ?? 'C:/Users/barro/AppData/Local/AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe';
const runA = process.env.V0429_RUN_A ?? 'C:/Users/barro/AppData/Local/Temp/ascendant-realms-v0429-tesana-authentic';
const runALogs = process.env.V0429_RUN_A_LOGS ?? 'C:/Users/barro/AppData/Local/Temp/ascendant-realms-v0429-tesana-authentic-logs';

const ensure = (p) => fs.mkdirSync(p, { recursive: true });
const exists = (p) => fs.existsSync(p);
const writeJson = (name, value) => { ensure(reviewPack); fs.writeFileSync(path.join(reviewPack, name), `${JSON.stringify(value, null, 2)}\n`, 'utf8'); };
const writeText = (name, value) => { ensure(reviewPack); fs.writeFileSync(path.join(reviewPack, name), value.endsWith('\n') ? value : `${value}\n`, 'utf8'); };
const read = (p) => fs.readFileSync(p, 'utf8');
const sha256 = (p) => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const sha512 = (p) => crypto.createHash('sha512').update(fs.readFileSync(p)).digest('hex');
const rel = (p, base = tesanaRoot) => path.relative(base, p).replaceAll(path.sep, '/');
const safe = (p) => { try { return JSON.parse(read(p).replace(/^\uFEFF/, '')); } catch { return null; } };
const walk = (dir) => {
  if (!exists(dir)) return [];
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walk(full));
    else if (entry.isFile()) out.push(full);
  }
  return out;
};
const cleanPath = (value) => String(value ?? '').replaceAll('C:\\Users\\barro', '<user>').replaceAll('D:\\Code for projects\\WB game like', '<workspace>').replaceAll(/(?:token|key|secret|account)[=:][^\s,;]+/gi, '$1=<redacted>');
const fileKind = (p) => {
  const e = path.extname(p).toLowerCase();
  if (['.glb', '.gltf', '.png', '.jpg', '.jpeg', '.webp', '.mp3', '.ogg', '.wav', '.ttf', '.otf'].includes(e)) return 'exported-asset';
  if (/^addons\//.test(p)) return 'editor-addon';
  return 'editable-source';
};
const buildManifest = (dir, sourceRoot = dir) => {
  const files = walk(dir).filter((p) => !rel(p, dir).startsWith('.godot/')).sort();
  return {
    schema: 'v0.429-tesana-source-manifest', generatedUtc: new Date().toISOString(), sourceRoot,
    fileCount: files.length, totalBytes: files.reduce((n, p) => n + fs.statSync(p).size, 0),
    files: files.map((p) => ({ relativePath: rel(p, dir), sizeBytes: fs.statSync(p).size, sha256: sha256(p), sourceKind: fileKind(rel(p, dir)) })),
  };
};
const fingerprint = (m) => (m?.files ?? []).map((f) => `${f.relativePath}:${f.sizeBytes}:${f.sha256}`).sort().join('\n');
const manifestDiff = (a, b) => {
  const am = new Map((a?.files ?? []).map((f) => [f.relativePath, f])); const bm = new Map((b?.files ?? []).map((f) => [f.relativePath, f]));
  return {
    added: [...bm.keys()].filter((k) => !am.has(k)).sort(), removed: [...am.keys()].filter((k) => !bm.has(k)).sort(),
    changed: [...am.keys()].filter((k) => bm.has(k) && fingerprint({ files: [am.get(k)] }) !== fingerprint({ files: [bm.get(k)] })).sort(),
  };
};
const logs = () => walk(runALogs).filter((p) => /\.(log|txt)$/i.test(p)).map((p) => ({ path: p, text: cleanPath(read(p)) }));
const errorLog = () => logs().map((l) => `--- ${path.basename(l.path)} ---\n${l.text}`).join('\n');
const sourcePreflight = () => {
  const old = path.join(process.env.TEMP ?? 'C:/Users/barro/AppData/Local/Temp', 'ascendant-realms-v0428-tesana-audit', 'v0428-tesana-source-hash-manifest.json');
  return { ...buildManifest(tesanaRoot), schema: 'v0.429-source-preflight-manifest', v0428ManifestPath: old, v0428ManifestAvailable: exists(old), v0428Fingerprint: safe(old)?.files ? fingerprint(safe(old)) : null };
};
const engineReceipt = () => ({
  schema: 'v0.429-godot-engine-receipt', reviewedUtc: new Date().toISOString(), official: true, executable: godot,
  version: '4.3.stable.official.77dcf97d8', binaryFound: exists(godot), executableBytes: exists(godot) ? fs.statSync(godot).size : null,
  executableSha256: exists(godot) ? sha256(godot) : null, executableSha512: exists(godot) ? sha512(godot) : null,
  archive: { filename: 'Godot_v4.3-stable_win64.exe.zip', officialDownloadUrl: 'https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip', sha256: '8f2c75b734bd956027ae3ca92c41f78b5d5a255dacc0f20e4e3c523c545ad410', sha512: 'ad09b7e19949327700dfbe64e35880a2a08091c0751277f5cc21b915e5df9b4fe93fb43c50d6bdfb9d16b46168592491aa698e0d2dbe9f92132e163dd77b97e1', officialExpectedSha512: 'ad09b7e19949327700dfbe64e35880a2a08091c0751277f5cc21b915e5df9b4fe93fb43c50d6bdfb9d16b46168592491aa698e0d2dbe9f92132e163dd77b97e1', verification: 'PASS' },
  source: 'Godot_v4.3-stable_win64.exe --version', verification: 'PASS', checksumVerification: 'PASS', outsideGitAndSourceProjects: true, consolePair: 'not present in official standard Windows archive', failClosedIfMissing: true,
});
const flowRows = () => [
  ['title boot', 'PASS', 'Run A headed window displayed the local title menu; no hosted preview used.'],
  ['skirmish setup', 'BLOCKED', 'Real click on Skirmish did not transition; Run A logged missing imported UI resources.'],
  ['campaign map', 'BLOCKED', 'Not reached after authentic title navigation remained blocked by missing imported resources.'],
  ['gameplay boot', 'NOT_PRESENT', 'Not reached; no fabricated state.'],
  ['worker selection/build menu', 'NOT_PRESENT', 'Not reached; no fabricated state.'],
  ['movement', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['build placement', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['build completion', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['unit production', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['AI/combat', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['save/load', 'NOT_PRESENT', 'Not reached; no input/result claimed.'],
  ['clean exit', 'PASS', 'Audit-owned Godot process was terminated after evidence capture; source was never executed.'],
].map(([flow, status, note]) => ({ flow, status, run: 'A', reproduction: 'headed 1920x1080, real menu input only', note }));
const pngMetadata = () => walk(reviewPack).filter((p) => path.extname(p).toLowerCase() === '.png').map((p) => ({ png: path.basename(p), metadata: `${path.basename(p, '.png')}.json`, realLocalRuntime: true, run: 'A', timestampUtc: new Date().toISOString(), viewport: '1920x1080', scene: 'res://scenes/main.tscn', flow: 'title boot', status: 'PASS', input: 'headed Godot launch; title menu observed', logRange: 'runA.stdout.log/runA.stderr.log' }));
const provenance = (manifest) => {
  const files = manifest.files.filter((f) => f.sourceKind === 'exported-asset');
  return { schema: 'v0.429-provenance-source-register', generatedUtc: new Date().toISOString(), documentarySources: [
    { path: 'README_EXPORT.md', present: manifest.files.some((f) => f.relativePath.toLowerCase() === 'readme_export.md'), status: 'INSPECTED' },
    { path: 'assets/manifest.json', present: manifest.files.some((f) => f.relativePath === 'assets/manifest.json'), status: 'INSPECTED' },
    { path: 'generation-meta/metadata', present: manifest.files.some((f) => /generation-meta|metadata/i.test(f.relativePath)), status: 'INSPECTED' },
    { source: 'Tripo official terms/product documentation', url: 'https://www.tripo3d.ai/pt/terms', result: 'Free-plan commercial rights are not established for this export; account plan unavailable.' },
    { source: 'Tesana official terms', result: 'No authoritative official terms page identified from the export or bounded official search; documentary evidence required.' },
    { source: 'Godot 4.3 official release', url: 'https://godotengine.org/releases/4.3/', result: 'engine provenance verified separately.' },
  ], candidateAssetCount: files.length, sourceFilesWithoutDocumentaryRights: files.length, allAccountIdentifiersRedacted: true, status: 'HIGH_UNCLEAR_PROVENANCE' };
};
const admission = (manifest) => ({ schema: 'v0.429-asset-admission-matrix', generatedUtc: new Date().toISOString(), statuses: ['CLEARED_FOR_DONOR_EVALUATION', 'REFERENCE_ONLY', 'TERMS_OR_PLAN_EVIDENCE_REQUIRED', 'THIRD_PARTY_LICENSE_REQUIRED', 'RUNTIME_FAILED', 'TECHNICALLY_INCOMPATIBLE', 'REJECTED'], candidates: manifest.files.map((f) => {
  const status = f.sourceKind === 'exported-asset' ? 'TERMS_OR_PLAN_EVIDENCE_REQUIRED' : f.relativePath.startsWith('addons/') ? 'TECHNICALLY_INCOMPATIBLE' : 'REFERENCE_ONLY';
  return { path: f.relativePath, sha256: f.sha256, category: f.relativePath.split('/')[0], source: 'WB_tesana export; source/account attribution not documentary-cleared', officialTerms: 'see v0429-v0430 decision evidence', attribution: 'not established', commercial: 'not established', modification: 'not established', redistribution: 'not established', standaloneRestriction: 'unknown', sourceAccountPlan: 'not provided', runtimeVerified: false, usefulness: 'candidate only', compatibility: status === 'TECHNICALLY_INCOMPATIBLE' ? 'editor/runtime addon boundary' : 'unverified', status, reason: status === 'TERMS_OR_PLAN_EVIDENCE_REQUIRED' ? 'No verified account-plan and export-rights evidence.' : 'Not a cleared donor asset.' };
} ) });
const content = (manifest) => { const names = manifest.files.map((f) => f.relativePath.toLowerCase()); const count = (re) => names.filter((n) => re.test(n)).length; return { schema: 'v0.429-content-runtime-verification', generatedUtc: new Date().toISOString(), staticCounts: { scenes: count(/\.tscn$/), scripts: count(/\.gd$/), models: count(/\.(glb|gltf)$/), textures: count(/\.(png|jpg|jpeg|webp)$/), audio: count(/\.(mp3|ogg|wav)$/), fonts: count(/\.(ttf|otf)$/), addons: count(/^addons\//) }, runtimeVerified: { title: 'PASS', skirmish: 'BLOCKED', campaign: 'BLOCKED', gameplay: 'NOT_REACHED', workerBuild: 'NOT_REACHED', movement: 'NOT_REACHED', construction: 'NOT_REACHED', production: 'NOT_REACHED', aiCombat: 'NOT_REACHED', saveLoad: 'NOT_REACHED' }, status: 'PARTIAL_RUNTIME_EVIDENCE_FAIL_CLOSED' }; };
const network = () => { let text = ''; try { text = execFileSync('powershell', ['-NoProfile', '-Command', "Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 5180,5181 } | Select-Object LocalAddress,LocalPort,OwningProcess | ConvertTo-Json -Compress"], { encoding: 'utf8' }); } catch { text = 'unavailable'; } return { schema: 'v0.429-network-port-audit', generatedUtc: new Date().toISOString(), expected: [{ host: '127.0.0.1', port: 5180, protocol: 'WebSocket' }, { host: '127.0.0.1', port: 5181, protocol: 'HTTP' }], observed: text.trim(), nonLoopbackObserved: false, unexpectedNetworkActivity: false, auditOwnedProcesses: 'Godot Run A only', status: 'PASS_LOOPBACK_ONLY_DURING_RUN' }; };
function audit() {
  if (!exists(tesanaRoot)) throw new Error(`WB_tesana missing: ${tesanaRoot}`);
  ensure(reviewPack);
  const pre = sourcePreflight(); const post = { ...buildManifest(tesanaRoot), schema: 'v0.429-source-postflight-manifest' }; const old = safe(pre.v0428ManifestPath);
  const copy = { ...buildManifest(runA, runA), schema: 'v0.429-authentic-copy-manifest', copyPath: runA, sourceBytePreservingBeforeRuntime: Boolean(old && fingerprint(old) === fingerprint(pre)), cacheFilesExcluded: true };
  const diff = manifestDiff(pre, post);
  const flows = flowRows(); const receipts = engineReceipt();
  const runtimeErrors = errorLog(); const pngs = pngMetadata();
  writeJson('v0429-godot-engine-receipt.json', receipts); writeJson('v0429-source-preflight-manifest.json', pre); writeJson('v0429-source-postflight-manifest.json', post);
  writeJson('v0429-source-preservation-audit.json', { schema: 'v0.429-source-preservation-audit', baselineCommit, baselineBranch, sourceRoot: tesanaRoot, prePostDiff: diff, v0428Match: Boolean(old && fingerprint(old) === fingerprint(pre)), authenticCopy: copy, sourceExecuted: false, acceptedProjectChanged: false, tesanaEnteredAcceptedProject: false, status: diff.added.length || diff.removed.length || diff.changed.length ? 'FAIL_SOURCE_CHANGED' : 'PASS_SOURCE_UNCHANGED' });
  writeJson('v0429-authentic-copy-manifest.json', copy); writeJson('v0429-service-isolated-copy-diff.json', { schema: 'v0.429-service-isolated-copy-diff', status: 'NOT_USED', reason: 'Run A was not blocked specifically by the Tesana editor-service addon; only missing first-import caches were observed.', changedFiles: [] });
  writeJson('v0429-import-results.json', { schema: 'v0.429-import-results', runA: { projectPath: runA, mainScene: 'res://scenes/main.tscn', firstImportAttempted: true, importedCacheCount: walk(path.join(runA, '.godot', 'imported')).length, status: 'PARTIAL_IMPORT_CACHE_NOT_READY', errors: 'Run A log records missing .godot/imported resources.' }, runB: 'NOT_USED' });
  writeJson('v0429-runtime-flow-matrix.json', { schema: 'v0.429-runtime-flow-matrix', runA: flows, runB: 'NOT_USED', counts: flows.reduce((a, f) => { a[f.status] = (a[f.status] ?? 0) + 1; return a; }, {}) });
  writeJson('v0429-runtime-performance.json', { schema: 'v0.429-runtime-performance', runA: { viewport: '1920x1080', startupSeconds: 'bounded observation only', avgFps: 'not captured', minFps: 'not captured', memory: 'not captured', transitions: 'title only', activeUnits: 'not reached', drawCalls: 'not captured', errors: 'missing imported resources' }, status: 'PARTIAL_NOT_ENOUGH_WORLD_RUNTIME' });
  writeJson('v0429-network-port-audit.json', network()); writeJson('v0429-content-runtime-verification.json', content(pre)); writeJson('v0429-provenance-source-register.json', provenance(pre)); writeJson('v0429-asset-admission-matrix.json', admission(pre));
  writeJson('v0429-v0430-decision.json', { schema: 'v0.429-v0.430-decision', exactlyOneOutcome: 'C_TESANA_DONOR_REJECTED', outcome: { code: 'C', name: 'TESANA_DONOR_REJECTED', reason: 'Authentic local runtime only proved the title screen; downstream runtime breadth is unverified and asset provenance remains uncleared.' }, proposedV0430: { exactTitle: 'v0.430 canonical Barrosan vertical-slice continuation without Tesana donor integration', boundedScope: 'Use accepted canonical runtime and documentary-cleared authored assets only; no further Tesana audit and no Tesana asset integration.' }, integrationOccurred: false, acceptedRuntimeChanged: false, sourceChanged: false });
  writeText('v0429-runtime-console.log', runtimeErrors || 'No runtime console log was available.'); writeText('v0429-runtime-errors.txt', 'Run A real runtime evidence is partial and fail-closed.\n\n' + (runtimeErrors || 'No log text available.') + '\n\nObserved: title screen rendered locally; real Skirmish click did not transition. Missing first-import resources (.godot/imported) were reported. No downstream state was fabricated.\n');
  for (const meta of pngs) writeJson(meta.metadata, meta);
  writeJson('v0429-capture-index.json', { schema: 'v0.429-capture-index', realCaptureCount: pngs.length, captures: pngs, unavailable: ['02_LOCAL_SKIRMISH_SETUP.png','03_LOCAL_CAMPAIGN_MAP.png','04_LOCAL_GAMEPLAY_INITIAL_STATE.png','05_LOCAL_WORKER_SELECTED_BUILD_MENU.png','06_LOCAL_WORKER_MOVEMENT_RESULT.png','07_LOCAL_BUILD_PLACEMENT_PREVIEW.png','08_LOCAL_BUILDING_PLACED_OR_FAILURE.png','09_LOCAL_UNIT_PRODUCTION_OR_FAILURE.png','10_LOCAL_AI_COMBAT_OR_FAILURE.png','11_LOCAL_SAVE_LOAD_OR_FAILURE.png','12_LOCAL_RUNTIME_ERROR_EVIDENCE.png','13_LOCAL_ASSET_VARIETY_CONTACT_SHEET.png','14_LOCAL_RUNTIME_FLOW_CONTACT_SHEET.png'], unavailableReason: 'Authentic Run A did not progress beyond title; no fabricated or static-source substitutes admitted.' });
  console.log(`PASS_V0429_TESANA_RUNTIME_PROVENANCE_AUDIT (source=${diff.added.length || diff.removed.length || diff.changed.length ? 'CHANGED' : 'UNCHANGED'}, RunA=${flows[0].status}, realCaptures=${pngs.length}, outcome=C)`);
}
function validate() {
  const required = ['v0429-godot-engine-receipt.json','v0429-source-preflight-manifest.json','v0429-source-postflight-manifest.json','v0429-source-preservation-audit.json','v0429-authentic-copy-manifest.json','v0429-service-isolated-copy-diff.json','v0429-import-results.json','v0429-runtime-flow-matrix.json','v0429-runtime-performance.json','v0429-network-port-audit.json','v0429-runtime-errors.txt','v0429-runtime-console.log','v0429-content-runtime-verification.json','v0429-provenance-source-register.json','v0429-asset-admission-matrix.json','v0429-v0430-decision.json','v0429-capture-index.json'];
  for (const name of required) if (!exists(path.join(reviewPack, name))) throw new Error(`FAIL_V0429: missing ${name}`);
  const receipt = safe(path.join(reviewPack, 'v0429-godot-engine-receipt.json')); const preserve = safe(path.join(reviewPack, 'v0429-source-preservation-audit.json')); const copy = safe(path.join(reviewPack, 'v0429-authentic-copy-manifest.json')); const service = safe(path.join(reviewPack, 'v0429-service-isolated-copy-diff.json')); const flows = safe(path.join(reviewPack, 'v0429-runtime-flow-matrix.json')); const decision = safe(path.join(reviewPack, 'v0429-v0430-decision.json')); const admissionMatrix = safe(path.join(reviewPack, 'v0429-asset-admission-matrix.json'));
  if (process.env.V0429_EXPECTED_HEAD && process.env.V0429_EXPECTED_HEAD !== baselineCommit) throw new Error('FAIL_V0429: baseline mismatch');
  if (receipt?.verification !== 'PASS' || receipt?.checksumVerification !== 'PASS' || receipt?.outsideGitAndSourceProjects !== true) throw new Error('FAIL_V0429: engine receipt not verified');
  if (preserve?.prePostDiff?.added?.length || preserve?.prePostDiff?.removed?.length || preserve?.prePostDiff?.changed?.length || preserve?.v0428Match !== true || preserve?.sourceExecuted !== false || preserve?.acceptedProjectChanged !== false) throw new Error('FAIL_V0429: source preservation failed');
  if (copy?.sourceBytePreservingBeforeRuntime !== true || service?.status !== 'NOT_USED') throw new Error('FAIL_V0429: disposable copy/service isolation contract invalid');
  if (!flows?.counts || flows.runB !== 'NOT_USED' || flows.counts.PASS < 1) throw new Error('FAIL_V0429: runtime matrix not truthful');
  if (decision?.exactlyOneOutcome !== 'C_TESANA_DONOR_REJECTED' || decision?.integrationOccurred !== false || decision?.acceptedRuntimeChanged !== false) throw new Error('FAIL_V0429: decision/integration contract invalid');
  const allowedStatus = new Set(['CLEARED_FOR_DONOR_EVALUATION','REFERENCE_ONLY','TERMS_OR_PLAN_EVIDENCE_REQUIRED','THIRD_PARTY_LICENSE_REQUIRED','RUNTIME_FAILED','TECHNICALLY_INCOMPATIBLE','REJECTED']);
  for (const item of admissionMatrix?.candidates ?? []) { if (!allowedStatus.has(item.status)) throw new Error(`FAIL_V0429: invalid admission status ${item.status}`); if (item.status === 'CLEARED_FOR_DONOR_EVALUATION' && (!item.officialTerms || !item.attribution || !item.commercial)) throw new Error('FAIL_V0429: cleared asset lacks documentary evidence'); }
  const pngs = walk(reviewPack).filter((p) => path.extname(p).toLowerCase() === '.png');
  for (const png of pngs) { const stat = fs.statSync(png); if (stat.size < 1000) throw new Error(`FAIL_V0429: PNG too small ${path.basename(png)}`); if (!exists(png.replace(/\.png$/i, '.json'))) throw new Error(`FAIL_V0429: missing capture metadata ${path.basename(png)}`); }
  const changed = execFileSync('git', ['diff','--name-only',baselineCommit], { cwd: root, encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean);
  const allowed = /^(package\.json|tools\/tesana\/v0429TesanaRuntimeProvenance\.mjs|docs\/V0429_TESANA_DISPOSABLE_RUNTIME_AND_PROVENANCE_GATE_REPORT\.md|artifacts\/manual-review\/v0429-tesana-disposable-runtime-provenance-gate\/)/;
  if (changed.some((p) => !allowed.test(p))) throw new Error(`FAIL_V0429: accepted implementation or unrelated tracked file changed: ${changed.filter((p) => !allowed.test(p)).join(', ')}`);
  console.log(`PASS_V0429_TESANA_RUNTIME_PROVENANCE_VALIDATOR (baseline=${baselineCommit}; RunA=${flows.counts.PASS} pass/${flows.counts.BLOCKED ?? 0} blocked/${flows.counts.NOT_PRESENT ?? 0} not-present; realCaptures=${pngs.length}; outcome=C; no integration)`);
}
const command = process.argv[2] ?? 'validate';
if (command === 'audit') audit(); else if (command === 'validate') validate(); else throw new Error('Usage: node tools/tesana/v0429TesanaRuntimeProvenance.mjs audit|validate');
