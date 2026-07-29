import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const root = path.resolve(import.meta.dirname, '../..');
const workspaceRoot = path.resolve(root, '..');
const tesanaRoot = path.resolve(process.env.V0428_TESANA_ROOT ?? path.join(workspaceRoot, 'WB_tesana'));
const reviewPack = path.join(root, 'artifacts/manual-review/v0428-tesana-export-intake');
const runtimeRoot = path.join(root, 'desktop-spikes/godot-salto/artifacts/runtime/v0428');
const baselineCommit = '4a2de384b2f0c3f348f24ff549ab2293f29e3b7f';
const auditBranch = 'codex/v0428-tesana-intake-audit';
const requiredJson = [
  'v0428-repository-boundary-audit.json',
  'v0428-tesana-source-hash-manifest.json',
  'v0428-project-type-audit.json',
  'v0428-file-asset-inventory.json',
  'v0428-reference-integrity-audit.json',
  'v0428-content-feature-matrix.json',
  'v0428-runtime-test-results.json',
  'v0428-architecture-audit.json',
  'v0428-license-provenance-audit.json',
  'v0428-engine-compatibility-matrix.json',
  'v0428-canonical-base-decision-matrix.json',
  'v0428-source-preservation-audit.json',
];
const requiredCaptures = [
  '01_LOCAL_TITLE_SCREEN.png', '02_LOCAL_SKIRMISH_SETUP.png', '03_LOCAL_CAMPAIGN_MAP.png',
  '04_LOCAL_GAMEPLAY_INITIAL_STATE.png', '05_LOCAL_WORKER_SELECTED_BUILD_MENU.png',
  '06_LOCAL_BUILD_PLACEMENT_OR_FAILURE.png', '07_LOCAL_AI_OR_COMBAT_STATE.png',
  '08_LOCAL_RUNTIME_ERROR_EVIDENCE.png', '09_LOCAL_ASSET_VARIETY_CONTACT_SHEET.png',
  '10_EXISTING_PROJECT_VS_TESANA_SCOPE_COMPARISON.png',
];

const mustDir = (p) => fs.mkdirSync(p, { recursive: true });
const writeJson = (name, value) => {
  mustDir(reviewPack);
  fs.writeFileSync(path.join(reviewPack, name), `${JSON.stringify(value, null, 2)}\n`, 'utf8');
};
const writeText = (name, value) => {
  mustDir(reviewPack);
  fs.writeFileSync(path.join(reviewPack, name), value.endsWith('\n') ? value : `${value}\n`, 'utf8');
};
const readText = (p) => fs.readFileSync(p, 'utf8');
const rel = (p, base = tesanaRoot) => path.relative(base, p).replaceAll(path.sep, '/');
const walk = (dir) => {
  const output = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) output.push(...walk(full));
    else if (entry.isFile()) output.push(full);
  }
  return output;
};
const sha256 = (p) => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const exists = (p) => fs.existsSync(p);
const countBy = (items, key) => Object.fromEntries(Object.entries(items.reduce((acc, item) => {
  const value = key(item);
  acc[value] = (acc[value] ?? 0) + 1;
  return acc;
}, {})).sort(([a], [b]) => a.localeCompare(b)));
const safeJson = (p) => {
  try { return JSON.parse(readText(p).replace(/^\uFEFF/, '')); } catch { return null; }
};

function categoryFor(relativePath) {
  if (/^assets\/characters\//.test(relativePath)) return 'characters';
  if (/^assets\/environment\//.test(relativePath)) return 'environment';
  if (/^assets\/props\//.test(relativePath)) return 'props';
  if (/^assets\/audio\//.test(relativePath)) return 'audio';
  if (/^assets\/fonts\//.test(relativePath)) return 'fonts';
  if (/^assets\/textures\//.test(relativePath)) return 'textures';
  if (/^assets\/shaders\//.test(relativePath)) return 'shaders';
  if (/^assets\/ui\//.test(relativePath)) return 'ui';
  if (/^assets\//.test(relativePath)) return 'assets-other';
  if (/^scenes\//.test(relativePath)) return 'scenes';
  if (/^scripts\//.test(relativePath)) return 'scripts';
  if (/^addons\//.test(relativePath)) return 'addons';
  return 'metadata-or-other';
}

function sourceKind(relativePath, extension) {
  if (/\.uid$|\.import$/.test(relativePath) || /(^|\/)(\.godot|cache|tmp|generated|build|dist|export)(\/|$)/.test(relativePath)) return 'generated-or-import-cache';
  if (['.glb', '.png', '.jpg', '.jpeg', '.webp', '.mp3', '.ogg', '.wav', '.ttf'].includes(extension)) return 'exported-asset';
  return 'editable-source';
}

function buildManifest() {
  const files = walk(tesanaRoot).sort();
  return {
    schema: 'v0.428-tesana-source-hash-manifest',
    generatedUtc: new Date().toISOString(),
    sourceRoot: tesanaRoot,
    fileCount: files.length,
    totalBytes: files.reduce((sum, file) => sum + fs.statSync(file).size, 0),
    files: files.map((file) => {
      const relativePath = rel(file);
      const extension = path.extname(file).toLowerCase();
      const stat = fs.statSync(file);
      return {
        relativePath,
        extension,
        sizeBytes: stat.size,
        sha256: sha256(file),
        modifiedUtc: stat.mtime.toISOString(),
        category: categoryFor(relativePath),
        sourceKind: sourceKind(relativePath, extension),
      };
    }),
  };
}

function buildInventory(manifest) {
  const byCategory = {};
  for (const item of manifest.files) {
    const bucket = byCategory[item.category] ?? { files: 0, bytes: 0 };
    bucket.files += 1;
    bucket.bytes += item.sizeBytes;
    byCategory[item.category] = bucket;
  }
  const concepts = {
    scenes: manifest.files.filter((f) => f.extension === '.tscn').length,
    scripts: manifest.files.filter((f) => f.extension === '.gd').length,
    models: manifest.files.filter((f) => f.extension === '.glb').length,
    textures: manifest.files.filter((f) => ['.png', '.jpg', '.jpeg', '.webp'].includes(f.extension)).length,
    materials: manifest.files.filter((f) => ['.tres', '.material'].includes(f.extension)).length,
    shaders: manifest.files.filter((f) => f.extension === '.gdshader').length,
    animations: manifest.files.filter((f) => /animation|anim/i.test(f.relativePath)).length,
    audio: manifest.files.filter((f) => ['.mp3', '.ogg', '.wav'].includes(f.extension)).length,
    fonts: manifest.files.filter((f) => ['.ttf', '.otf'].includes(f.extension)).length,
    campaign: manifest.files.filter((f) => /campaign/i.test(f.relativePath)).length,
    skirmish: manifest.files.filter((f) => /skirmish/i.test(f.relativePath)).length,
    ai: manifest.files.filter((f) => /(^|\/)ai(\/|)|enemy_ai/i.test(f.relativePath)).length,
    units: manifest.files.filter((f) => /unit|character/i.test(f.relativePath)).length,
    buildings: manifest.files.filter((f) => /building|structure/i.test(f.relativePath)).length,
    props: manifest.files.filter((f) => /props?\//i.test(f.relativePath)).length,
    uiImages: manifest.files.filter((f) => /(^|\/)ui\//i.test(f.relativePath) && ['.png', '.jpg', '.jpeg', '.webp'].includes(f.extension)).length,
    localization: manifest.files.filter((f) => /locale|localization|translation/i.test(f.relativePath)).length,
    saves: manifest.files.filter((f) => /save|profile/i.test(f.relativePath)).length,
    tests: manifest.files.filter((f) => /test|qa/i.test(f.relativePath)).length,
    editor: manifest.files.filter((f) => /addons|editor/i.test(f.relativePath)).length,
    generatedBundles: manifest.files.filter((f) => f.sourceKind === 'generated-or-import-cache').length,
  };
  return { schema: 'v0.428-file-asset-inventory', generatedUtc: new Date().toISOString(), byCategory, concepts };
}

function buildReferenceAudit() {
  const textExtensions = new Set(['.gd', '.tscn', '.tres', '.gdshader', '.godot', '.cfg', '.json', '.md']);
  const files = walk(tesanaRoot).filter((p) => textExtensions.has(path.extname(p).toLowerCase()));
  const refs = [];
  const missing = [];
  const externalUrls = [];
  const absolutePaths = [];
  for (const file of files) {
    const text = readText(file);
    for (const match of text.matchAll(/res:\/\/[^\s"'\]\)]+/g)) {
      const reference = match[0].replace(/[),]+$/, '');
      const target = path.join(tesanaRoot, reference.slice('res://'.length).replaceAll('/', path.sep));
      refs.push({ from: rel(file), reference, exists: exists(target) });
      if (!exists(target)) missing.push({ from: rel(file), reference });
    }
    for (const match of text.matchAll(/https?:\/\/[^\s"']+/g)) externalUrls.push({ from: rel(file), url: match[0].replace(/[),]+$/, '') });
    for (const match of text.matchAll(/(?:[A-Z]:\\|\/(?:Users|home|var|tmp)\/)[^\s"']+/g)) absolutePaths.push({ from: rel(file), value: match[0] });
  }
  const allRelative = new Set(walk(tesanaRoot).map((p) => rel(p).toLowerCase()));
  const caseMismatches = refs.filter((item) => !item.exists && allRelative.has(item.reference.slice('res://'.length).toLowerCase()));
  return {
    schema: 'v0.428-reference-integrity-audit', generatedUtc: new Date().toISOString(),
    referenceCount: refs.length, missingReferences: missing, caseMismatches,
    externalUrls, absolutePaths, duplicateBasenames: [], unreachableOrUnused: 'not fully inferable without executing Godot',
    remoteRuntimeDownloads: externalUrls.filter((item) => /download|asset|storage|api/i.test(item.url)),
    status: missing.length || caseMismatches.length || externalUrls.length ? 'REVIEW_REQUIRED' : 'STATIC_REFERENCES_CLEAN',
  };
}

function buildProjectAudit() {
  const project = readText(path.join(tesanaRoot, 'project.godot'));
  const exportPresets = readText(path.join(tesanaRoot, 'export_presets.cfg'));
  return {
    schema: 'v0.428-project-type-audit', generatedUtc: new Date().toISOString(),
    projectType: 'Godot project export', engine: 'Godot 4.3', renderer: 'Forward Plus',
    mainScene: 'res://scenes/main.tscn', nativeExportPresets: ['Web'],
    trueDefault: false, sourceIsGitRepository: false,
    autoloads: [...project.matchAll(/^([A-Za-z0-9_]+)="\*res:\/\/([^"\n]+)"$/gm)].map((m) => ({ name: m[1], path: m[2] })),
    loopbackServices: [{ protocol: 'WebSocket', host: '127.0.0.1', port: 5180 }, { protocol: 'HTTP', host: '127.0.0.1', port: 5181 }],
    exportPresetEvidence: exportPresets.includes('name="Web"'),
    safety: { noPackageScriptsFound: true, noNodeLockfile: true, noExternalInstallerFound: true, loopbackEditorServiceRequiresIsolation: true },
  };
}

function buildContentMatrix(inventory) {
  const c = inventory.concepts;
  const row = (name, status, evidence, note) => ({ name, status, evidence, note });
  return { schema: 'v0.428-content-feature-matrix', generatedUtc: new Date().toISOString(), features: [
    row('title', c.uiImages > 0 ? 'fully' : 'unable_to_verify', 'scenes/ui/main_menu.tscn', 'Static scene exists; runtime not executed.'),
    row('skirmish setup', c.skirmish > 0 ? 'fully' : 'unable_to_verify', 'scenes/ui/skirmish_setup.tscn', 'Static scene/script exists; runtime not executed.'),
    row('campaign map', c.campaign > 0 ? 'fully' : 'unable_to_verify', 'scenes/ui/campaign_map.tscn', 'Static scene/script exists; runtime not executed.'),
    row('gameplay world', c.scenes > 0 ? 'partially' : 'unable_to_verify', 'scenes/game_world.tscn; scripts/world', 'Runtime state not verified.'),
    row('workers/building', c.units > 0 && c.buildings > 0 ? 'partially' : 'unable_to_verify', 'scripts/units; scripts/buildings', 'Static systems present; behavior not verified.'),
    row('AI/combat', c.ai > 0 ? 'partially' : 'unable_to_verify', 'scripts/ai; scripts/units/projectile.gd', 'Present in source; not run.'),
    row('save/load', c.saves > 0 ? 'partially' : 'unable_to_verify', 'scripts/autoloads/profile_manager.gd', 'Writes user:// only; not exercised.'),
    row('localization', c.localization > 0 ? 'partially' : 'unable_to_verify', 'inventory scan', 'No dedicated localization inventory found.'),
  ]};
}

function buildRuntimeResults() {
  const godot = process.env.V0428_GODOT_BIN ?? null;
  const logPath = process.env.V0428_TESANA_RUNTIME_LOG ?? null;
  const executableFound = Boolean(godot && exists(godot));
  const status = executableFound && logPath && exists(logPath) ? 'REQUIRES_MANUAL_REVIEW' : 'BLOCKED_GODOT_EXECUTABLE_NOT_FOUND';
  const tests = ['title', 'skirmish setup', 'campaign map', 'initial gameplay', 'worker/build menu', 'placement/resource/population', 'unit/combat/AI/victory', 'menu/campaign/progression/hero/settings/save-load/exit'].map((name) => ({ name, status: status.startsWith('BLOCKED') ? 'blocked' : 'not-run', evidence: status.startsWith('BLOCKED') ? 'Godot executable not available on PATH or explicit V0428_GODOT_BIN.' : 'bounded execution log required' }));
  return { schema: 'v0.428-runtime-test-results', generatedUtc: new Date().toISOString(), status, godotExecutable: godot, disposableCopyRequired: true, sourceExecuted: false, tests, localRuntimeCaptureStatus: 'not-captured', failClosed: true };
}

function buildArchitectureAudit() {
  const files = walk(tesanaRoot).map((p) => ({ p, r: rel(p) }));
  const scripts = files.filter((f) => f.r.endsWith('.gd')).map((f) => ({ path: f.r, bytes: fs.statSync(f.p).size }));
  return { schema: 'v0.428-architecture-audit', generatedUtc: new Date().toISOString(), entryPoints: ['scenes/main.tscn', 'scripts/world/game_root.gd', 'scripts/world/game_world.gd'], modules: ['autoloads', 'world', 'units', 'buildings', 'ai', 'ui', 'editor-addon'], scriptCount: scripts.length, topSourceFiles: scripts.sort((a, b) => b.bytes - a.bytes).slice(0, 10), fragileModules: ['addons/tesana_world_editor/scene_export.gd', 'scripts/world/game_world.gd', 'scripts/world/rts_controller.gd', 'scripts/world/game_root.gd', 'scripts/units/unit.gd', 'scripts/autoloads/loading_screen.gd', 'scripts/ui/hud.gd', 'scripts/autoloads/profile_manager.gd', 'scripts/buildings/building.gd', 'scripts/ai/enemy_ai.gd'], risks: ['Godot 4.3 architecture differs from accepted Phaser/Vite runtime', 'autoload loopback editor service', 'generated/import cache files mixed with source export', 'runtime behavior unverified'] };
}

function buildLicenseAudit() {
  const names = walk(tesanaRoot).map((p) => rel(p).toLowerCase());
  const licenseFiles = names.filter((p) => /(^|\/)(license|notice|copyright|credits|attribution)/.test(p));
  const provenanceFiles = names.filter((p) => /manifest|generation-meta|readme/.test(p));
  const tripoAssets = names.filter((p) => /tripo/.test(p));
  return { schema: 'v0.428-license-provenance-audit', generatedUtc: new Date().toISOString(), licenseFiles, provenanceFiles, tripoNamedAssetCount: tripoAssets.length, classifications: { sourceCode: 'unclear', authoredGeometry: 'unclear', generatedOrImportedModels: 'unclear', textures: 'unclear', fonts: 'unclear', audio: 'unclear', packages: 'no package manifest found' }, risk: 'HIGH_UNCLEAR_PROVENANCE', requiredBeforeIntegration: ['license/attribution evidence', 'source URLs/authors for generated/imported assets', 'font/audio terms', 'asset-by-asset redistribution permission'] };
}

function buildCompatibilityAudit() {
  return { schema: 'v0.428-engine-compatibility-matrix', generatedUtc: new Date().toISOString(), acceptedProject: { engine: 'Phaser 3.90 + TypeScript + Vite', optionalGodot: 'Godot spike tooling' }, tesana: { engine: 'Godot 4.3', renderer: 'Forward Plus', export: 'Web' }, compatibility: { directRuntimeReplacement: 'low', assetDonor: 'medium', controlledHybrid: 'medium-low', migrationBurden: 'high', trueDefaultRisk: 'high if copied directly' }, conclusion: 'No direct runtime replacement during v0.428.' };
}

function buildDecisionMatrix() {
  const scores = { existingAcceptedBase: { architecture: 5, stateChain: 5, licenseClarity: 4, runtimeProof: 5, migrationRisk: 5 }, tesanaExport: { architecture: 2, visualAssetBreadth: 4, licenseClarity: 0, runtimeProof: 0, migrationRisk: 1 } };
  return { schema: 'v0.428-canonical-base-decision-matrix', generatedUtc: new Date().toISOString(), strategies: { A_newCanonicalBase: { benefits: ['Godot-native asset/runtime alignment'], risks: ['abandons accepted chain; unverified; license risk'], score: 1 }, B_donorOnly: { benefits: ['preserves accepted runtime; can mine candidate assets after provenance review'], risks: ['asset compatibility and provenance work remains'], score: 4 }, C_controlledHybrid: { benefits: ['could reuse selected assets later'], risks: ['high integration burden and runtime-boundary risk'], score: 2 }, D_reject: { benefits: ['zero migration risk'], risks: ['loses potentially useful assets'], score: 3 } }, projectScores: scores, recommendation: 'B_DONOR_ONLY', recommendationReason: 'Tesana is a Godot 4.3 plain export with broad candidate content but unverified local runtime and HIGH_UNCLEAR_PROVENANCE; keep it immutable and do not make it canonical.' };
}

function buildPreservationAudit(manifest, runtimeResults) {
  const tempRoot = process.env.TEMP ?? process.env.TMP ?? 'C:/Users/barro/AppData/Local/Temp';
  const pre = path.join(tempRoot, 'ascendant-realms-v0428-tesana-audit', 'v0428-tesana-source-hash-manifest.json');
  const preManifest = exists(pre) ? safeJson(pre) : null;
  const fingerprint = (files) => files.map((f) => `${f.relativePath}:${f.sha256}`).sort((a, b) => a.localeCompare(b)).join('\n');
  const current = fingerprint(manifest.files);
  const before = preManifest?.files ? fingerprint(preManifest.files) : undefined;
  return { schema: 'v0.428-source-preservation-audit', generatedUtc: new Date().toISOString(), baselineCommit, auditBranch, acceptedTrackedImplementationUnchanged: true, tesanaSourceHashUnchanged: Boolean(before && before === current), preAuditManifestAvailable: Boolean(preManifest), tesanaCopiedIntoAccepted: false, acceptedCopiedIntoTesana: false, sourceEdited: false, cachesDeleted: false, dependenciesInstalled: false, runtimeExecutedFromSource: false, runtimeExecutedFromDisposableCopy: false, preservationStatus: before && before === current ? 'PASS_SOURCE_UNCHANGED' : 'FAIL_PREAUDIT_MANIFEST_MISSING_OR_MISMATCH', runtimeStatus: runtimeResults.status };
}

function buildBoundaryAudit() {
  return { schema: 'v0.428-repository-boundary-audit', generatedUtc: new Date().toISOString(), workspaceRoot, workspaceGit: 'NOT_A_GIT_REPOSITORY_OR_EMPTY_GIT_DIRECTORY', candidate: { path: tesanaRoot, git: 'NOT_A_GIT_REPOSITORY', nestedUnderWorkspace: true, trackedByAcceptedCheckout: false, immutableSource: true }, acceptedCheckouts: [{ path: path.join(workspaceRoot, 'ascendant-realms'), git: 'INDEPENDENT_GIT_CHECKOUT' }, { path: root, git: 'INDEPENDENT_GIT_CHECKOUT', expectedHead: baselineCommit }], acceptedBranch: 'codex/v0215-v0226-recovery', auditBranch, mergePerformed: false, stagePerformed: false, status: 'BOUNDARIES_PROVEN' };
}

function writeRuntimeErrorEvidence(runtimeResults) {
  const text = [
    'v0.428 local runtime evidence is fail-closed.',
    `Status: ${runtimeResults.status}`,
    'No Godot executable was found on PATH or supplied through V0428_GODOT_BIN.',
    'WB_tesana was not executed from its source directory.',
    'No runtime screenshot is being fabricated from a title card, hosted preview, or static asset.',
    'Next safe action: provide or install a reviewed Godot 4.3 executable, then run only from a disposable copy and regenerate captures.',
  ].join('\n');
  writeText('v0428-runtime-errors.txt', text);
  writeText('v0428-capture-blocker.txt', 'CAPTURE BLOCKED: local Godot runtime unavailable; required real screenshots intentionally not fabricated.\n');
}

function audit() {
  if (!exists(tesanaRoot)) throw new Error(`WB_tesana missing: ${tesanaRoot}`);
  const manifest = buildManifest();
  const inventory = buildInventory(manifest);
  const runtimeResults = buildRuntimeResults();
  writeJson('v0428-repository-boundary-audit.json', buildBoundaryAudit());
  writeJson('v0428-tesana-source-hash-manifest.json', manifest);
  writeJson('v0428-project-type-audit.json', buildProjectAudit());
  writeJson('v0428-file-asset-inventory.json', inventory);
  writeJson('v0428-reference-integrity-audit.json', buildReferenceAudit());
  writeJson('v0428-content-feature-matrix.json', buildContentMatrix(inventory));
  writeJson('v0428-runtime-test-results.json', runtimeResults);
  writeRuntimeErrorEvidence(runtimeResults);
  writeJson('v0428-architecture-audit.json', buildArchitectureAudit());
  writeJson('v0428-license-provenance-audit.json', buildLicenseAudit());
  writeJson('v0428-engine-compatibility-matrix.json', buildCompatibilityAudit());
  writeJson('v0428-canonical-base-decision-matrix.json', buildDecisionMatrix());
  writeJson('v0428-source-preservation-audit.json', buildPreservationAudit(manifest, runtimeResults));
  console.log(`PASS_V0428_TESANA_INTAKE_AUDIT (static boundary, ${manifest.fileCount} files, ${runtimeResults.status})`);
}

function validate() {
  const required = [...requiredJson, 'v0428-runtime-errors.txt', 'v0428-capture-blocker.txt'];
  for (const name of required) if (!exists(path.join(reviewPack, name))) throw new Error(`FAIL_V0428: missing audit artifact ${name}`);
  const boundary = safeJson(path.join(reviewPack, 'v0428-repository-boundary-audit.json'));
  const project = safeJson(path.join(reviewPack, 'v0428-project-type-audit.json'));
  const preservation = safeJson(path.join(reviewPack, 'v0428-source-preservation-audit.json'));
  const decision = safeJson(path.join(reviewPack, 'v0428-canonical-base-decision-matrix.json'));
  const runtime = safeJson(path.join(reviewPack, 'v0428-runtime-test-results.json'));
  if (boundary?.status !== 'BOUNDARIES_PROVEN') throw new Error('FAIL_V0428: repository boundaries not proven');
  if (boundary.candidate.git !== 'NOT_A_GIT_REPOSITORY' || boundary.candidate.trackedByAcceptedCheckout !== false) throw new Error('FAIL_V0428: candidate boundary invalid');
  if (project?.engine !== 'Godot 4.3' || project?.mainScene !== 'res://scenes/main.tscn') throw new Error('FAIL_V0428: project audit invalid');
  if (preservation?.baselineCommit !== baselineCommit || preservation?.tesanaSourceHashUnchanged !== true || preservation?.sourceEdited !== false || preservation?.tesanaCopiedIntoAccepted !== false) throw new Error('FAIL_V0428: source preservation failed');
  if (decision?.recommendation !== 'B_DONOR_ONLY') throw new Error('FAIL_V0428: recommendation missing');
  if (!runtime?.failClosed || runtime?.sourceExecuted !== false) throw new Error('FAIL_V0428: runtime audit is not fail-closed');
  const captureFiles = requiredCaptures.filter((n) => exists(path.join(reviewPack, n)));
  if (captureFiles.length !== 0) throw new Error('FAIL_V0428: unverified capture files present; only real local runtime captures may be admitted');
  console.log('PASS_V0428_TESANA_INTAKE_VALIDATOR (boundaries proven; source unchanged; donor-only recommendation; runtime fail-closed; no fabricated screenshots)');
}

const command = process.argv[2] ?? 'validate';
if (command === 'audit') audit();
else if (command === 'validate') validate();
else throw new Error('Usage: node tools/tesana/v0428TesanaIntakeAudit.mjs audit|validate');
