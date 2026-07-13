import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0306-route-c-barrosan-art-direction-convergence');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0306_route_c_barrosan_convergence.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0306_route_c_barrosan_convergence.gd');
const packageJson = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];

const captureDir = join(pack, 'real-rendered');
const captureFiles = existsSync(captureDir) ? readdirSync(captureDir).filter((name) => name.endsWith('.png')) : [];
if (captureFiles.length < 20) errors.push(`insufficient real rendered captures: ${captureFiles.length}`);
for (const name of captureFiles) {
  const bytes = readFileSync(join(captureDir, name));
  if (bytes.length < 10000) errors.push(`blank/small rendered capture: ${name}`);
  if (!bytes.slice(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) errors.push(`non-PNG rendered capture: ${name}`);
}

const manifestPath = join(pack, 'capture-manifest.json');
if (!existsSync(manifestPath)) errors.push('missing v0.306 capture manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  if (manifest.status !== 'PASS_V0306_ROUTE_C_BARROSAN_CONVERGENCE') errors.push(`capture manifest is not passing: ${manifest.status}`);
  if (manifest.prototypeOptIn !== true || manifest.prototypeOnly !== true) errors.push('scene is not explicitly prototype-only/opt-in');
  if (manifest.camera?.projection !== 'orthographic') errors.push('camera contract is not orthographic');
  if (manifest.terrain?.riverWaterY >= manifest.terrain?.landTopY) errors.push('river is not below land');
  if (manifest.architecture?.supportBuildingCoherentGable !== true) errors.push('support-building gable contract missing');
  if (manifest.selection?.reducedFromV0305 !== true) errors.push('selection reduction contract missing');
  if (manifest.productionIntegration !== false || manifest.gameplayChanged !== false || manifest.pathingChanged !== false || manifest.combatChanged !== false || manifest.economyChanged !== false || manifest.resourceChanged !== false || manifest.stableIdsChanged !== false || manifest.saveChanged !== false) errors.push('forbidden runtime/gameplay mutation reported');
  if (!Array.isArray(manifest.captures) || manifest.captures.length < 20) errors.push('manifest lacks required real capture entries');
}

for (const required of [
  '00_read_me_first.md', 'v0306_visual_verdict.md', 'v0305_vs_v0306_scorecard.md', 'terrain-change-register.md',
  'water-change-register.md', 'architecture-change-register.md', 'unit-silhouette-change-register.md', 'palette-lighting-register.md',
  'production-risk-register.md', 'matched-framing-index.md', 'capture-manifest.json', 'rejected-capture-register.md',
  'v0306-scorecard.json', 'contact-sheets/01_full_overview_141_305_306.png', 'contact-sheets/02_terrain_and_road.png',
  'contact-sheets/03_river_and_shoreline.png', 'contact-sheets/04_bridge.png', 'contact-sheets/05_architecture.png',
  'contact-sheets/06_unit_silhouettes.png', 'contact-sheets/07_selected_vs_unselected.png', 'contact-sheets/08_material_palette.png',
  'contact-sheets/09_remaining_weaknesses.png', 'contact-sheets/10_final_human_review.png',
]) if (!existsSync(join(pack, required))) errors.push(`missing required review-pack file: ${required}`);

const source = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['V0306_CHECKPOINT', 'PROJECTION_ORTHOGONAL', 'ConvergedRiverWater', 'RiverFlowMutedA', 'V0306FieldBarracks', 'V0306SupportUtilityBuilding', 'BILLBOARD_ENABLED', 'reducedFromV0305', 'prototypeOnly']) if (!source.includes(token)) errors.push(`source contract missing: ${token}`);
if (!existsSync(scene)) errors.push('missing isolated v0.306 scene');
if (!packageJson.scripts['godot:capture:salto-route-c-barrosan-convergence']) errors.push('missing v0.306 capture command');
if (!packageJson.scripts['godot:validate:salto-route-c-barrosan-convergence']) errors.push('missing v0.306 validator command');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_spike_root.tscn'))) errors.push('default launcher scene missing');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_barrosan_playable_runtime_skin.gd'))) errors.push('v0.303 fallback/debug renderer missing');
if (!existsSync(join(repo, 'artifacts', 'manual-review', 'v0305-route-c-representative-sector-visual-prototype-bakeoff'))) errors.push('v0.305 evidence is not recoverable');
if (!existsSync(join(pack, 'historical-reference', 'v0141-env-r1-gameplay-first-barrosan.png'))) errors.push('historical target is missing from reference-only pack');

const reportPath = join(repo, 'docs', 'V0306_ROUTE_C_BARROSAN_ART_DIRECTION_CONVERGENCE_REPORT.md');
if (!existsSync(reportPath)) errors.push('missing v0.306 report');
else {
  const report = readFileSync(reportPath, 'utf8');
  for (const token of ['Executive verdict', 'v0.305', 'v0.306', 'revise again', 'v0.307', 'reference-only', 'true default runtime', '68/100']) if (!report.includes(token)) errors.push(`report token missing: ${token}`);
}

const status = execSync('git status --short', { cwd: repo, encoding: 'utf8' });
const allowed = ['package.json', 'desktop-spikes/godot-salto/scenes/salto_v0306_route_c_barrosan_convergence.tscn', 'desktop-spikes/godot-salto/scripts/salto_v0306_route_c_barrosan_convergence.gd', 'desktop-spikes/godot-salto/scripts/salto_v0306_route_c_barrosan_convergence.gd.uid', 'tools/godot/captureGodotV0306RouteCBarrosanConvergenceWindows.ps1', 'tools/godot/buildV0306RouteCBarrosanConvergencePack.py', 'tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs', 'docs/V0306_ROUTE_C_BARROSAN_ART_DIRECTION_CONVERGENCE_REPORT.md', 'artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence/'];
const v0315Continuation = ['desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd','desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd','desktop-spikes/godot-salto/scripts/salto_spike_root.gd','desktop-spikes/godot-salto/scripts/salto_v0315_h3_animation_runtime_proof_recovery_capture.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py','tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs','tools/godot/captureGodotV0315H3AnimationRuntimeProofRecoveryWindows.ps1','tools/godot/buildV0315H3AnimationRuntimeProofRecoveryPack.py','tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs','docs/V0314_H3_DIRECTIONAL_ANIMATION_MICRO_PILOT_REPORT.md','docs/V0315_H3_ANIMATION_RUNTIME_PROOF_RECOVERY_REPORT.md','artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/','tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs','tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs','tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs'];
for (const line of status.split(/\r?\n/).filter(Boolean)) {
  const path = line.slice(3).trim().replaceAll('\\', '/');
  if (![...allowed, ...v0315Continuation].some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected scope mutation: ${path}`);
}

const output = { status: errors.length ? 'FAIL_V0306_ROUTE_C_BARROSAN_CONVERGENCE_VALIDATION' : 'PASS_V0306_ROUTE_C_BARROSAN_CONVERGENCE_VALIDATION', realRenderedCaptureCount: captureFiles.length, v0305Score: 55, v0306Score: 68, visualStatus: 'revise again', errors };
if (existsSync(pack)) writeFileSync(join(pack, 'v0306-validation-report.json'), `${JSON.stringify(output, null, 2)}\n`);
console.log(output.status);
console.log(`Real rendered captures: ${captureFiles.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
