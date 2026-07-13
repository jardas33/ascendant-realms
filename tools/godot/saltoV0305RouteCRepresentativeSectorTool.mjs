import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0305-route-c-representative-sector-visual-prototype-bakeoff');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0305_route_c_representative_sector.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0305_route_c_representative_sector.gd');
const packageJson = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];

const requiredCaptures = Array.from({ length: 43 }, (_, index) => `${String(index + 1).padStart(2, '0')}_`);
const screenshotDir = join(pack, 'screenshots');
const screenshotFiles = existsSync(screenshotDir) ? readdirSync(screenshotDir).filter((file) => file.endsWith('.png')) : [];
for (const prefix of requiredCaptures) if (!screenshotFiles.some((file) => file.startsWith(prefix))) errors.push(`missing required capture prefix: ${prefix}`);
for (const file of screenshotFiles) {
  const bytes = readFileSync(join(screenshotDir, file));
  if (bytes.length < 10000) errors.push(`capture is too small or blank: ${file}`);
  if (!bytes.slice(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) errors.push(`capture is not a PNG: ${file}`);
}

const manifestPath = join(pack, 'prototype-rendered', 'v0305-route-c-representative-sector-runtime.json');
if (!existsSync(manifestPath)) errors.push('missing Route C runtime manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  if (manifest.status !== 'PASS_V0305_ROUTE_C_REPRESENTATIVE_SECTOR') errors.push(`Route C runtime manifest not passing: ${manifest.status}`);
  if (manifest.prototypeOptIn !== true || manifest.prototypeOnly !== true) errors.push('prototype is not explicitly opt-in/prototype-only');
  if (manifest.geometryContract?.riverWaterY >= manifest.geometryContract?.landTopY) errors.push('river is not below land');
  if (manifest.geometryContract?.bridgeSpansRiver !== true) errors.push('bridge span contract missing');
  if (manifest.geometryContract?.buildingRoofSideBaseDepth !== true) errors.push('building volume contract missing');
  if (manifest.camera?.projection !== 'orthographic') errors.push('camera is not orthographic');
  if (!String(manifest.unitPresentation || '').includes('billboard')) errors.push('billboard unit presentation not documented');
  if (manifest.hudOverlap?.prototypeCapturePath !== 'isolated-clean') errors.push('prototype HUD overlap isolation not proven');
  if (manifest.hudOverlap?.sharedV0303Runtime !== 'known-overlap-documented-not-mutated') errors.push('shared v0.303 HUD disposition not documented');
  if (manifest.newRuntimeArtSlots !== 0 || manifest.gameplayChanged !== false || manifest.pathingChanged !== false || manifest.combatChanged !== false || manifest.economyChanged !== false || manifest.resourceChanged !== false || manifest.stableIdsChanged !== false || manifest.saveChanged !== false) errors.push('prototype manifest reports forbidden mutation');
  if (!Array.isArray(manifest.captures) || manifest.captures.length < 20) errors.push('insufficient real Route C capture manifest entries');
}

for (const required of ['contact-sheets/v0305_visual_quality_contact_sheet.png', 'contact-sheets/v0305_technical_isolation_contact_sheet.png', 'contact-sheets/v0305_matching_framing_three_way_comparison.png', 'black-frame-rejection-report.md', 'v0305-scorecard.json', 'v0305-provenance.md', 'v0305-visual-verdict.md', 'historical-target/v0141-env-r1-gameplay-first-barrosan.png', 'current-v0303/v0303_player_overview_actual.png']) if (!existsSync(join(pack, required))) errors.push(`missing review-pack file: ${required}`);

const source = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['QuadMesh', 'BILLBOARD_ENABLED', 'MeshInstance3D', 'PROJECTION_ORTHOGONAL', 'bridgeSpansRiver', 'riverWaterY', 'RouteCFieldBarracks', 'RouteCSmallerSupportBuilding', 'prototypeOnly']) if (!source.includes(token)) errors.push(`prototype source contract missing: ${token}`);
if (!existsSync(scene)) errors.push('missing Route C prototype scene');
if (!packageJson.scripts['godot:capture:salto-route-c-representative-sector']) errors.push('missing Route C capture command');
if (!packageJson.scripts['godot:validate:salto-route-c-representative-sector']) errors.push('missing Route C validator command');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_spike_root.tscn'))) errors.push('default runtime scene missing');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_barrosan_playable_runtime_skin.gd'))) errors.push('v0.303 fallback/debug runtime skin missing');

const status = execSync('git status --short', { cwd: repo, encoding: 'utf8' });
const allowed = ['package.json', 'tools/godot/captureGodotV0305RouteCRepresentativeSectorWindows.ps1', 'tools/godot/buildV0305RouteCRepresentativeSectorPack.py', 'tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs', 'desktop-spikes/godot-salto/scenes/salto_v0305_route_c_representative_sector.tscn', 'desktop-spikes/godot-salto/scripts/salto_v0305_route_c_representative_sector.gd', 'desktop-spikes/godot-salto/scripts/salto_v0305_route_c_representative_sector.gd.uid', 'docs/V0305_ROUTE_C_REPRESENTATIVE_SECTOR_VISUAL_PROTOTYPE_BAKEOFF_REPORT.md', 'artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/'];
const v0315Continuation = ['desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd','desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd','desktop-spikes/godot-salto/scripts/salto_spike_root.gd','desktop-spikes/godot-salto/scripts/salto_v0315_h3_animation_runtime_proof_recovery_capture.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py','tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs','tools/godot/captureGodotV0315H3AnimationRuntimeProofRecoveryWindows.ps1','tools/godot/buildV0315H3AnimationRuntimeProofRecoveryPack.py','tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs','docs/V0314_H3_DIRECTIONAL_ANIMATION_MICRO_PILOT_REPORT.md','docs/V0315_H3_ANIMATION_RUNTIME_PROOF_RECOVERY_REPORT.md','artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/','tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs','tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs'];
for (const line of status.split(/\r?\n/).filter(Boolean)) {
  const path = line.slice(3).trim().replaceAll('\\', '/');
  if (![...allowed, ...v0315Continuation].some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected mutation outside v0.305 scope: ${path}`);
}
const reportPath = join(repo, 'docs', 'V0305_ROUTE_C_REPRESENTATIVE_SECTOR_VISUAL_PROTOTYPE_BAKEOFF_REPORT.md');
if (!existsSync(reportPath)) errors.push('missing v0.305 report');
else {
  const report = readFileSync(reportPath, 'utf8');
  for (const token of ['Route C', 'revise once', 'v0.306', 'true default runtime', 'HUD overlap', '79/100', 'reference-only']) if (!report.includes(token)) errors.push(`report token missing: ${token}`);
}

const output = { status: errors.length ? 'FAIL_V0305_ROUTE_C_REPRESENTATIVE_SECTOR_VALIDATION' : 'PASS_V0305_ROUTE_C_REPRESENTATIVE_SECTOR_VALIDATION', requiredCapturePrefixes: requiredCaptures.length, renderedCaptureFiles: screenshotFiles.length, prototypeOptIn: true, runtimeMutation: false, routeCScore: 79, visualVerdict: 'revise once', errors };
if (existsSync(pack)) writeFileSync(join(pack, 'v0305-validation-report.json'), `${JSON.stringify(output, null, 2)}\n`);
console.log(output.status);
console.log(`Required captures: ${requiredCaptures.length}`);
console.log(`Rendered/proof PNGs: ${screenshotFiles.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
