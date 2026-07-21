import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const failures = [];
const abs = (p) => path.join(root, p);
const exists = (p) => fs.existsSync(abs(p));
const read = (p) => fs.readFileSync(abs(p), 'utf8').replace(/^\uFEFF/u, '');
const json = (p) => JSON.parse(read(p));
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(abs(p))).digest('hex');
const check = (condition, message) => { if (!condition) failures.push(message); };
const noMojibake = (value) => !/[ÃƒÃ‚Ã¢][\x80-\xBFÃƒÃ‚Ã¢]/u.test(value) && !/ÃƒÆ’|Ãƒâ€š/u.test(value);
const decision = `V0.354 HUMAN-APPROVED ${String.fromCharCode(0x2014)} BARROSAN BARN VISUAL GOLD AND FINAL EVIDENCE CLOSEOUT ACCEPTED; ALL ACCEPTED LINEAGE FROZEN`;

const scenePath = 'desktop-spikes/godot-salto/scenes/gold/barrosan/BarrosanBarnGold.tscn';
const sourcePath = 'artifacts/runtime/v0355/screenshots/04_canonical_barn_square_256.png';
const sceneHash = 'ffaf4c4eeb7c0dabc3a483b0137ad2d92d2b2f6dd496b84b86584ae4a7e86a4a';
const sourceHash = '13a761a2b60658a0d261c89d9046b752f052a5e32924381075a4b24ca7c3d6a3';
const roofHash = '0077e19143517e2850aee3bdb6ce9408d55bc7e2bfdc958d61ac1b141ab684f9';
const manifestPath = 'docs/gold/V0355_BARROSAN_BARN_GOLD_MANIFEST.json';
const ledgerPath = 'docs/gold/V0355_BARROSAN_BARN_ACCEPTANCE_LEDGER.md';
const runtimeManifestPath = 'artifacts/runtime/v0359/capture-manifest.json';
const performancePath = 'artifacts/performance/v0359-barrosan-barn/v0359-performance.json';
const pack = 'artifacts/manual-review/v0359-barrosan-barn-capture-integrity-performance-closeout/UPLOAD_TO_CHAT';
const expectedPack = ['00_READ_ME_FIRST.md','01_HUMAN_DECISION_AND_SINGLE_SLOT_AUTHORITY.png','02_EXACT_SINGLE_SLOT_DEFAULT_VS_OPT_IN.png','03_HOUSE02_BARN_WORKER_SCALE_AND_CONTEXT.png','04_RTS_DISTANCE_AND_TERRAIN_CONTACT.png','05_FRONT_REAR_AND_EXTERIOR_ROOF.png','06_FOUR_FAIL_CLOSED_STATES.png','07_EXACT_ROLLBACK_AND_DEFAULT_PRESERVATION.png','08_UNCAPPED_PERFORMANCE_RESOURCE_AND_NODE_LEDGER.png','compact-evidence-summary.json'];

check(process.argv[2] === 'validate', 'usage: node tools/godot/saltoV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutTool.mjs validate');
for (const p of [scenePath, sourcePath, manifestPath, ledgerPath, runtimeManifestPath, performancePath, pack, 'docs/V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CLOSEOUT_REPORT.md', 'desktop-spikes/godot-salto/scenes/review/V0359BarrosanBarnCaptureIntegrityPerformanceCloseout.tscn', 'desktop-spikes/godot-salto/scripts/v0359_barrosan_barn_capture_integrity_performance_closeout.gd', 'tools/godot/launchGodotV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutWindows.ps1', 'tools/godot/captureGodotV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutWindows.ps1', 'tools/godot/buildV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutPack.ps1']) check(exists(p), `missing v0.359 artifact: ${p}`);
check(exists(scenePath) && sha(scenePath) === sceneHash, 'canonical BarnGold scene changed');
check(exists(sourcePath) && sha(sourcePath) === sourceHash, 'accepted canonical 256 source changed');
const gold = exists(manifestPath) ? json(manifestPath) : {};
const ledger = exists(ledgerPath) ? read(ledgerPath) : '';
check(gold.assetStatus === 'HUMAN_APPROVED_VISUAL_GOLD' && gold.canonicalScenePath === scenePath && gold.productionIntegrated === false, 'frozen gold manifest authority changed');
check(gold.humanDecision === decision && ledger.includes(decision), 'frozen human decision missing or changed');
check(gold.acceptedV0354Raw256SourceHash === sourceHash && gold.frozenRoofRepairHash === roofHash, 'frozen source/roof authority changed');

const integration = `${read('desktop-spikes/godot-salto/scripts/v0359_barrosan_barn_capture_integrity_performance_closeout.gd')}\n${read('tools/godot/captureGodotV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutWindows.ps1')}\n${read('tools/godot/buildV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutPack.ps1')}`;
for (const required of ['V0359_CHECKPOINT','V0359_VIEW_PREFIX','_set_v0359_camera','settleFrames":8','V0359_WARMUP_FRAMES := 600','V0359_MEASUREMENT_FRAMES_PER_PASS := 1200','DisplayServer.VSYNC_DISABLED','Engine.max_fps = 0','humanDiagnosticsReadable','rollbackR0R2PixelMatch','captureDuplicationRootCause']) check(integration.includes(required), `v0.359 implementation contract missing: ${required}`);
for (const forbidden of ['StaticBody3D','NavigationRegion3D','CollisionShape3D','move_and_slide','NavigationAgent3D','apply_damage','instantiate_projectile']) check(!integration.includes(forbidden), `forbidden gameplay/runtime symbol in v0.359 layer: ${forbidden}`);

const changed = Array.from(new Set([
  ...execFileSync('git', ['diff', '--name-only'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u),
  ...execFileSync('git', ['ls-files', '--others', '--exclude-standard'], { cwd: root, encoding: 'utf8' }).split(/\r?\n/u)
])).filter(Boolean).map((p) => p.replace(/\\/gu, '/'));
const allowed = (p) => p === 'package.json' || p.startsWith('artifacts/runtime/v0359/') || p.startsWith('artifacts/performance/v0359-barrosan-barn/') || p.startsWith('artifacts/manual-review/v0359-barrosan-barn-capture-integrity-performance-closeout/') || p === 'docs/V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CLOSEOUT_REPORT.md' || p.includes('V0359BarrosanBarnCaptureIntegrityPerformanceCloseout') || p.includes('v0359_barrosan_barn_capture_integrity_performance_closeout') || p.includes('V0359BarrosanBarnCaptureIntegrityPerformanceCloseoutPack') || p.includes('V0359BarrosanBarnCaptureIntegrityPerformanceCloseoutWindows') || p === 'tools/godot/saltoV0359BarrosanBarnCaptureIntegrityPerformanceCloseoutTool.mjs';
check(changed.every(allowed), `scope boundary changed outside v0.359 evidence layer: ${changed.filter((p) => !allowed(p)).join(', ')}`);

const runtime = exists(runtimeManifestPath) ? json(runtimeManifestPath) : {};
const performance = exists(performancePath) ? json(performancePath) : {};
const summaryPath = `${pack}/compact-evidence-summary.json`;
const summary = exists(summaryPath) ? json(summaryPath) : {};
check(runtime.checkpoint === 'v0.359' && Array.isArray(runtime.panels) && runtime.panels.length >= 17, 'capture manifest missing the complete raw panel ledger');
check(runtime.duplicationWasInRawCaptures === true && runtime.duplicationWasInBoardComposition === true, 'v0.358 duplication diagnosis not recorded');
check(typeof runtime.correctedCaptureSequencing === 'string' && runtime.correctedCaptureSequencing.includes('waits 8 rendered frames'), 'corrected capture sequencing not recorded');
check(summary.board03PanelsDistinct === true && summary.board04PanelsDistinct === true && summary.board05AllViewsDistinct === true, 'distinct corrected view evidence missing');
check(summary.board06DiagnosticsReadable === true && summary.board06PanelHashesDistinct === true, 'four human-readable fail-closed panels not proven');
check(summary.board07R0R2PixelMatch === true && summary.board07R0Hash !== summary.board07R1Hash, 'rollback identity evidence invalid');
check(performance.vsyncDisabledForBenchmark === true && performance.engineMaxFps === 0 && performance.frameCapDetected === false && performance.performanceUncappedValid === true, 'uncapped benchmark configuration invalid');
check(performance.warmupFramesPerMode >= 600 && performance.measurementFramesPerPass >= 1200 && performance.performancePassCount >= 3, 'performance protocol below v0.359 minimum');
for (const mode of ['default','optIn']) {
  const metrics = performance[mode] || {};
  check(metrics.sample_count >= 3600 && Array.isArray(metrics.rawFrameTimesMs) && metrics.rawFrameTimesMs.length >= 3600, `raw uncapped ${mode} samples missing`);
  check(metrics.median_fps > 5 && metrics.p95_frame_time_ms < 200, `uncapped ${mode} metrics invalid`);
}
check(performance.deliberateSleep === false && performance.screenshotDuringSampling === false, 'benchmark contains deliberate sleep or screenshot cadence');

const panelHashes = Object.fromEntries((runtime.panels || []).filter((p) => p.rawCapturePath).map((p) => [p.boardPanelId, p.rawCaptureSha256]));
for (const id of ['wide_wide','close-scale_close_scale','rts-distance_rts_distance','terrain-contact_terrain_contact','front_front','rear_rear','roof_roof','missing-scene-fail-closed_missing_scene','hash-mismatch-fail-closed_hash_mismatch','invalid-authority-fail-closed_invalid_authority','unknown-slot-rejected_unknown_slot']) check(typeof panelHashes[id] === 'string' && panelHashes[id].length === 64, `raw panel hash missing: ${id}`);
const readPng = (p) => { const b = fs.readFileSync(abs(p)); return { genuine: b.readUInt32BE(0) === 0x89504e47 && b.readUInt32BE(12) === 0x49484452, width: b.readUInt32BE(16), height: b.readUInt32BE(20), bytes: b.length }; };
for (const panel of runtime.panels || []) if (panel.rawCapturePath) { const info = readPng(panel.rawCapturePath); check(info.genuine && info.width >= 1200 && info.height >= 700 && info.bytes > 10000, `raw capture is not a genuine wide render: ${panel.rawCapturePath}`); }

const files = exists(pack) ? fs.readdirSync(abs(pack)).filter((f) => fs.statSync(abs(`${pack}/${f}`)).isFile()).sort() : [];
check(JSON.stringify(files) === JSON.stringify([...expectedPack].sort()), 'v0.359 upload pack must contain exactly ten files');
check(files.filter((f) => f.endsWith('.png')).length === 8 && !files.some((f) => /\.(mp4|webm|mov)$/iu.test(f)), 'v0.359 pack must contain exactly eight PNGs and no video');
for (const file of files.filter((f) => f.endsWith('.png'))) { const info = readPng(`${pack}/${file}`); check(info.genuine && info.width >= 1200 && info.height >= 700 && info.bytes > 10000, `review board is not a genuine wide render: ${file}`); }
for (const p of [`${pack}/00_READ_ME_FIRST.md`, `${pack}/compact-evidence-summary.json`, 'docs/V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CLOSEOUT_REPORT.md']) { const contents = read(p); check(noMojibake(contents), `mojibake detected in ${p}`); check(contents.includes(decision), `human decision missing from ${p}`); }
check(read('package.json').includes('godot:validate:salto-v0359-barrosan-barn-capture-integrity-performance-closeout'), 'v0.359 package validator command missing');

if (failures.length) { console.error('FAIL_V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CLOSEOUT_VALIDATION'); for (const failure of failures) console.error(`- ${failure}`); process.exit(1); }
console.log('PASS_V0359_BARROSAN_BARN_CAPTURE_INTEGRITY_PERFORMANCE_CLOSEOUT_VALIDATION');
