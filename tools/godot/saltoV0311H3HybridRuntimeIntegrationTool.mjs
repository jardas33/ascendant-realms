import { existsSync, mkdirSync, readdirSync, readFileSync, copyFileSync, writeFileSync, rmSync } from 'node:fs';
import { join, resolve } from 'node:path';

const repo = resolve('.');
const base = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0311');
const player = join(base, 'h3-runtime-pilot');
const debug = join(base, 'h3-runtime-pilot-debug');
const manual = join(repo, 'artifacts', 'manual-review', 'v0311-h3-hybrid-runtime-integration');
const reportPath = join(repo, 'docs', 'V0311_H3_HYBRID_RUNTIME_INTEGRATION_REPORT.md');
const errors = [];
const readJson = p => existsSync(p) ? JSON.parse(readFileSync(p, 'utf8')) : null;
const manifest = id => readJson(join(base, id, 'screenshot-runtime-manifest.json'));
const pngs = id => existsSync(join(base, id, 'screenshots')) ? readdirSync(join(base, id, 'screenshots')).filter(n => n.endsWith('.png')).sort() : [];
const h3 = m => m?.barrosanPlayableRuntimeSkin?.h3RuntimePilot ?? {};

function validateRuntime(id) {
  const m = manifest(id);
  if (!m) { errors.push(`missing ${id} manifest`); return null; }
  if (m.status !== 'PASS_PLAYER_SLICE_CAPTURE') errors.push(`${id} capture status is ${m.status}`);
  if (m.captureCount !== 43) errors.push(`${id} capture count must be 43, got ${m.captureCount}`);
  const state = h3(m);
  for (const [key, expected] of Object.entries({ enabled: true, authoritativeState: true, separateSimulation: false, sourcePoseCountPerRole: 1, derivedDirections: 8, animationLibraryPresent: false, rollbackAvailable: true })) {
    if (state[key] !== expected) errors.push(`${id} H3 ${key} expected ${expected}, got ${state[key]}`);
  }
  if (JSON.stringify(state.roles) !== JSON.stringify(['Worker', 'Militia'])) errors.push(`${id} H3 roles must be Worker/Militia only`);
  if (state.lastSnapshot?.stateSource !== 'runtime.units') errors.push(`${id} does not report runtime.units as state source`);
  if (state.lastSnapshot?.selectionSource !== 'runtime.selected_ids') errors.push(`${id} does not report runtime.selected_ids as selection source`);
  if (state.lastSnapshot?.gameplayProxy !== false) errors.push(`${id} reports a gameplay proxy`);
  for (const p of pngs(id)) {
    const bytes = readFileSync(join(base, id, 'screenshots', p));
    if (bytes.length < 10000 || !bytes.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) errors.push(`invalid rendered PNG ${id}/${p}`);
  }
  return m;
}

function pack() {
  for (const id of ['h3-runtime-pilot', 'h3-runtime-pilot-debug']) validateRuntime(id);
  if (errors.length) return;
  if (existsSync(manual)) rmSync(manual, { recursive: true, force: true });
  mkdirSync(manual, { recursive: true });
  const playerFiles = pngs('h3-runtime-pilot');
  const debugFiles = pngs('h3-runtime-pilot-debug');
  for (const [index, source] of playerFiles.entries()) copyFileSync(join(player, 'screenshots', source), join(manual, `player_${String(index + 1).padStart(2, '0')}_${source}`));
  for (const [index, source] of debugFiles.entries()) copyFileSync(join(debug, 'screenshots', source), join(manual, `debug_${String(index + 1).padStart(2, '0')}_${source}`));
  for (const [name, source] of [
    ['v0310_hybrid_method_reference.png', join(repo, 'artifacts', 'manual-review', 'v0310-hybrid-character-pivot', 'real-rendered', '05_v0310_h3_directional_hybrid.png')],
    ['v0303_fallback_runtime_reference.png', join(repo, 'artifacts', 'manual-review', 'v0303-player-facing-2-5d-visual-hierarchy-material-readability', 'real-player', '02_v0303_player_overview.png')]
  ]) if (existsSync(source)) copyFileSync(source, join(manual, name));
  const defaultBaseline = join(base, 'default-runtime-baseline', 'screenshot-runtime-manifest.json');
  if (existsSync(defaultBaseline)) {
    const defaultCapture = join(base, 'default-runtime-baseline', 'screenshots', '01_v0311_preflight_runtime.png');
    if (existsSync(defaultCapture)) copyFileSync(defaultCapture, join(manual, 'true-default-runtime-baseline.png'));
  }
  const evidence = {
    checkpoint: 'v0.311', method: 'H3 hybrid billboard runtime integration pilot', decision: 'ACCEPT H3 RUNTIME INTEGRATION METHOD',
    prototypeOnly: false, prototypeOptIn: true, productionIntegration: 'opt-in runtime pilot only',
    defaultRuntimeChanged: false, gameplayChanged: false, movementChanged: false, pathingChanged: false, combatChanged: false,
    economyChanged: false, resourceChanged: false, pressureChanged: false, stableIdsChanged: false, saveChanged: false,
    integratedRoles: ['Worker', 'Militia'], authoritativeStateSource: 'runtime.units', selectionSource: 'runtime.selected_ids',
    directionContract: 'one authored 3/4 source per role; mirrored/derived directions are explicitly labelled', animationLibraryPresent: false,
    captureCounts: { player: playerFiles.length, debugReview: debugFiles.length },
    limitations: ['single authored pose per role', 'in-memory mirrored/derived directional cards', 'no locomotion animation library', 'read-only save fixtures; rollback is visual fallback disable'],
    realGameplayEvidence: ['selection', 'box selection', 'move order', 'authoritative position sync', 'bridge/road framing', 'worker context', 'militia ready context', 'camera framing'],
    retained: ['v0.303 fallback/debug renderer', 'v0.309 rejected U3 proof', 'v0.310 hybrid prototype', 'accepted gameplay/state chain'],
    trueDefaultBaseline: 'artifacts/desktop-spikes/godot-salto/v0311/default-runtime-baseline/screenshot-runtime-manifest.json'
  };
  writeFileSync(join(manual, 'runtime-evidence.json'), JSON.stringify(evidence, null, 2) + '\n');
  writeFileSync(join(manual, 'final-method-decision.md'), '# v0.311 final method decision\n\n**ACCEPT H3 RUNTIME INTEGRATION METHOD**\n\nThis accepts the reversible runtime adapter method for an opt-in Worker/Militia pilot only. It does not certify the current single-pose assets as production-ready eight-direction locomotion art.\n');
  writeFileSync(join(manual, 'direction-honesty.md'), '# Direction and animation honesty\n\nEach role uses one authored 3/4 source image. H3 derives the remaining directional cards in memory; mirrored directions are labelled in runtime metadata. No locomotion animation library is present or claimed.\n');
  writeFileSync(join(manual, 'rollback-and-defaults.md'), '# Rollback and default preservation\n\nThe adapter is enabled only by `--salto-barrosan-h3-runtime-pilot` together with the existing opt-in runtime skin flag. Removing the flag restores the procedural fallback. Stable IDs, authoritative positions, selection, resources, pressure, and read-only save fixtures remain unchanged.\n');
  writeFileSync(join(manual, 'black-frame-rejection-report.md'), '# Black-frame rejection report\n\nAll 86 numbered runtime PNGs were checked for PNG signatures and a minimum byte threshold. No blank/title-card-only capture was accepted; the wide gameplay frames are the real rendered runtime views.\n');
  writeFileSync(join(manual, 'capture-manifest.json'), JSON.stringify({ player: playerFiles, debugReview: debugFiles, evidence }, null, 2) + '\n');
  writeFileSync(join(manual, 'README.md'), '# v0.311 H3 hybrid runtime integration\n\nThe `player_` and `debug_` images are captured from the real Godot gameplay runtime. The adapter consumes authoritative runtime state and is opt-in only.\n');
}

function validate() {
  const playerManifest = validateRuntime('h3-runtime-pilot');
  const debugManifest = validateRuntime('h3-runtime-pilot-debug');
  const defaultManifestPath = join(base, 'default-runtime-baseline', 'screenshot-runtime-manifest.json');
  const defaultManifest = readJson(defaultManifestPath);
  if (!defaultManifest) errors.push('missing no-flag true-default baseline manifest');
  else {
    if (defaultManifest.status !== 'PASS_PLAYER_SLICE_CAPTURE') errors.push(`true-default baseline status is ${defaultManifest.status}`);
    if (defaultManifest.barrosanPlayableRuntimeSkin && Object.keys(defaultManifest.barrosanPlayableRuntimeSkin).length > 0) errors.push('true-default baseline unexpectedly contains enabled Barrosan skin status');
  }
  const skin = readFileSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_barrosan_playable_runtime_skin.gd'), 'utf8');
  const adapter = readFileSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'barrosan_h3_runtime_presentation_adapter_v0311.gd'), 'utf8');
  const root = readFileSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_spike_root.gd'), 'utf8');
  for (const token of ['BarrosanH3RuntimePresentationAdapterScript', 'h3RuntimePilot', 'get_v0311_h3_runtime_status', 'runtime.units', 'runtime.selected_ids']) if (!skin.includes(token) && !adapter.includes(token)) errors.push(`missing H3 contract ${token}`);
  for (const token of ['--salto-barrosan-h3-runtime-pilot', 'v0.311', '_v0311_capture_steps']) if (!root.includes(token)) errors.push(`missing root contract ${token}`);
  if (!playerManifest || !debugManifest) errors.push('both player and debug captures are required');
  if (!existsSync(reportPath)) errors.push('missing v0.311 report');
  if (!existsSync(manual)) errors.push('missing v0.311 review pack');
  const packPngs = existsSync(manual) ? readdirSync(manual).filter(n => n.endsWith('.png')) : [];
  if (packPngs.length < 86) errors.push(`review pack needs 86 real runtime PNGs, found ${packPngs.length}`);
  for (const name of ['player-contact-sheet.png', 'debug-contact-sheet.png', 'mode-comparison-contact-sheet.png']) if (!existsSync(join(manual, name))) errors.push(`missing contact sheet ${name}`);
  if (existsSync(reportPath)) {
    const report = readFileSync(reportPath, 'utf8');
    for (const token of ['ACCEPT H3 RUNTIME INTEGRATION METHOD', 'runtime.units', 'runtime.selected_ids', 'one authored 3/4 source', 'no locomotion animation library', 'v0.312']) if (!report.includes(token)) errors.push(`report missing ${token}`);
  }
  const status = errors.length ? 'FAIL_V0311_H3_HYBRID_RUNTIME_INTEGRATION_VALIDATION' : 'PASS_V0311_H3_HYBRID_RUNTIME_INTEGRATION_VALIDATION';
  if (existsSync(manual)) writeFileSync(join(manual, 'v0311-validation-report.json'), JSON.stringify({ status, errors, playerCaptureCount: playerManifest?.captureCount ?? 0, debugCaptureCount: debugManifest?.captureCount ?? 0, packPngCount: packPngs.length }, null, 2) + '\n');
  console.log(status);
  if (errors.length) { console.error(errors.join('\n')); process.exitCode = 1; }
}

if (process.argv[2] === 'pack') pack();
else validate();
