import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0308-route-c-final-pre-integration-proof');
const real = join(pack, 'real-rendered');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0308_route_c_final_pre_integration_proof.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0308_route_c_final_pre_integration_proof.gd');
const report = join(repo, 'docs', 'V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF_REPORT.md');
const manifestPath = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0308', 'final-pre-integration-proof', 'v0308-route-c-final-pre-integration-proof-runtime.json');
const pkg = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];
const images = existsSync(real) ? readdirSync(real).filter((name) => name.endsWith('.png')) : [];
if (images.length < 24) errors.push(`insufficient real rendered captures: ${images.length}`);
for (const name of images) {
  const bytes = readFileSync(join(real, name));
  if (bytes.length < 10000 || !bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) errors.push(`invalid or blank PNG: ${name}`);
}
if (!existsSync(manifestPath)) errors.push('missing v0.308 runtime manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  for (const key of ['prototypeOnly','prototypeOptIn','productionIntegration','gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (!(key in manifest)) errors.push(`manifest missing ${key}`);
  if (manifest.prototypeOnly !== true || manifest.prototypeOptIn !== true || manifest.productionIntegration !== false) errors.push('prototype is not isolated/opt-in');
  for (const key of ['gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (manifest[key] !== false) errors.push(`forbidden mutation reported: ${key}`);
  if (manifest.integrationDecision !== 'REVISE_ONCE_MORE') errors.push('explicit final decision missing or inconsistent');
  if (manifest.terrain?.naturalEdges !== true || manifest.terrain?.bankCuts !== true || manifest.terrain?.rectangularPlates !== false || manifest.terrain?.floatingPlates !== false) errors.push('terrain edge contract missing');
  if (manifest.river?.deepChannel !== true || manifest.river?.shallowShelf !== true || manifest.river?.flowMotionToggle !== true || manifest.river?.bridgeContact !== true || manifest.river?.waterBelowLand !== true) errors.push('river/water contract missing');
  if (manifest.utilityBuilding?.completedRoof !== true || manifest.utilityBuilding?.ridge !== true || manifest.utilityBuilding?.eaves !== true || manifest.utilityBuilding?.drainage !== true || manifest.utilityBuilding?.gameplayFootprintChanged !== false) errors.push('completed utility building contract missing');
  if (manifest.unitContracts?.filter((unit) => unit.id === 'V0308U3WBarrosanWorker').length !== 1) errors.push('U3-W contract missing');
  if (manifest.unitContracts?.filter((unit) => unit.id === 'V0308U3MBarrosanMilitia').length !== 1) errors.push('U3-M contract missing');
}
const requiredPack = ['00_read_me_first.md','final-human-verdict.md','integration-decision.md','authored-u3-unit-register.md','worker-register.md','militia-register.md','terrain-edge-register.md','river-water-register.md','utility-building-register.md','environmental-density-register.md','gameplay-framing-register.md','material-value-register.md','production-cost-register.md','production-risk-register.md','honest-scorecard.md','capture-manifest.json','rejected-capture-register.md','v0308-scorecard.json'];
for (const name of requiredPack) if (!existsSync(join(pack, name))) errors.push(`missing pack file: ${name}`);
for (let index = 1; index <= 14; index++) if (!existsSync(join(pack, 'contact-sheets', `${String(index).padStart(2, '0')}_review.png`))) errors.push(`missing contact sheet ${index}`);
if (!existsSync(scene)) errors.push('missing isolated v0.308 scene');
if (!existsSync(script)) errors.push('missing v0.308 script');
const source = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['V0308_CHECKPOINT','V0308NaturalWestLandform','V0308DeepWaterChannel','V0308ShallowWaterShelf','V0308WaterFlowBandA','V0308BridgeContactFoam','V0308CompletedBarrosanUtilityStorehouse','V0308U3WBarrosanWorker','V0308U3MBarrosanMilitia','V0308V0307U3Comparison','V0308GameplayObliqueCamera','REVISE_ONCE_MORE']) if (!source.includes(token)) errors.push(`source token missing: ${token}`);
if (!pkg.scripts['godot:capture:salto-route-c-final-pre-integration-proof']) errors.push('missing v0.308 capture command');
if (!pkg.scripts['godot:validate:salto-route-c-final-pre-integration-proof']) errors.push('missing v0.308 validator command');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_spike_root.tscn'))) errors.push('true default launcher missing');
if (!existsSync(join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_barrosan_playable_runtime_skin.gd'))) errors.push('v0.303 fallback/debug renderer missing');
if (!existsSync(join(repo, 'artifacts', 'manual-review', 'v0307-route-c-production-viability-slice'))) errors.push('v0.307 recovery pack missing');
if (!existsSync(join(repo, 'artifacts', 'manual-review', 'v0306-route-c-barrosan-art-direction-convergence'))) errors.push('v0.306 recovery pack missing');
if (!existsSync(join(pack, 'historical-reference', 'v0141-env-r1-gameplay-first-barrosan.png'))) errors.push('historical R1 reference missing');
if (!existsSync(report)) errors.push('v0.308 report missing');
else for (const token of ['Executive verdict','Human correction','U3-W','U3-M','REVISE_ONCE_MORE','v0.309','reference-only','74/100','production integration']) if (!readFileSync(report, 'utf8').includes(token)) errors.push(`report token missing: ${token}`);
let status = '';
try { status = execSync('git status --short', { cwd: repo, encoding: 'utf8' }); } catch (error) { errors.push(`git status failed: ${error.message}`); }
const allowed = ['package.json','desktop-spikes/godot-salto/scenes/salto_v0308_route_c_final_pre_integration_proof.tscn','desktop-spikes/godot-salto/scripts/salto_v0308_route_c_final_pre_integration_proof.gd','tools/godot/captureGodotV0308RouteCFinalPreIntegrationProofWindows.ps1','tools/godot/buildV0308RouteCFinalPreIntegrationProofPack.py','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs','docs/V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF_REPORT.md','artifacts/manual-review/v0308-route-c-final-pre-integration-proof/'];
const v0315Continuation = ['desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd','desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd','desktop-spikes/godot-salto/scripts/salto_spike_root.gd','desktop-spikes/godot-salto/scripts/salto_v0315_h3_animation_runtime_proof_recovery_capture.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py','tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs','tools/godot/captureGodotV0315H3AnimationRuntimeProofRecoveryWindows.ps1','tools/godot/buildV0315H3AnimationRuntimeProofRecoveryPack.py','tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs','docs/V0314_H3_DIRECTIONAL_ANIMATION_MICRO_PILOT_REPORT.md','docs/V0315_H3_ANIMATION_RUNTIME_PROOF_RECOVERY_REPORT.md','artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/','tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs','tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs','tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs'];
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd.uid','docs/V0316_H3_VISIBLE_ANIMATION_AND_DIRECTIONAL_CLOSURE_REPORT.md','tools/godot/buildV0316H3VisibleAnimationDirectionalClosurePack.py','tools/godot/captureGodotV0316H3VisibleAnimationDirectionalClosureWindows.ps1','tools/godot/saltoV0316H3VisibleAnimationDirectionalClosureTool.mjs','artifacts/manual-review/v0316-h3-visible-animation-directional-closure/','package.json');
v0315Continuation.push('tools/godot/saltoV0304VisualArchaeologyStyleLockRecoveryTool.mjs','artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/v0304-validation-report.json','artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/v0305-validation-report.json','artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence/v0306-validation-report.json','artifacts/manual-review/v0307-route-c-production-viability-slice/v0307-validation-report.json','artifacts/manual-review/v0308-route-c-final-pre-integration-proof/v0308-validation-report.json','artifacts/manual-review/v0309-route-c-final-integration-gate/v0309-validation-report.json');
for (const line of status.split(/\r?\n/).filter(Boolean)) { const path = line.slice(3).trim().replaceAll('\\', '/'); if (![...allowed, ...v0315Continuation].some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected mutation: ${path}`); }
const out = { status: errors.length ? 'FAIL_V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF' : 'PASS_V0308_ROUTE_C_FINAL_PRE_INTEGRATION_PROOF', realRenderedCaptureCount: images.length, decision: 'REVISE_ONCE_MORE', v0307Overall: 72, environment: 76, utilityBuilding: 80, U3W: 76, U3M: 78, mixedUnitReadability: 80, routeCReadiness: 74, U3TechnicalStrategy: 88, productionScalability: 78, errors };
if (existsSync(pack)) writeFileSync(join(pack, 'v0308-validation-report.json'), JSON.stringify(out, null, 2) + '\n');
console.log(out.status);
console.log(`Real rendered captures: ${images.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
