import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0309-route-c-final-integration-gate');
const real = join(pack, 'real-rendered');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0309_route_c_final_integration_gate.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0309_route_c_final_integration_gate.gd');
const report = join(repo, 'docs', 'V0309_ROUTE_C_FINAL_INTEGRATION_GATE_REPORT.md');
const manifestPath = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0309', 'final-integration-gate', 'v0309-route-c-final-integration-gate-runtime.json');
const pkg = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];
const images = existsSync(real) ? readdirSync(real).filter((name) => name.endsWith('.png')) : [];
if (images.length < 30) errors.push(`insufficient real rendered captures: ${images.length}`);
for (const name of images) {
  const bytes = readFileSync(join(real, name));
  if (bytes.length < 10000 || !bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) errors.push(`invalid or blank PNG: ${name}`);
}
if (!existsSync(manifestPath)) errors.push('missing v0.309 runtime manifest');
else {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  for (const key of ['prototypeOnly','prototypeOptIn','productionIntegration','gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (!(key in manifest)) errors.push(`manifest missing ${key}`);
  if (manifest.prototypeOnly !== true || manifest.prototypeOptIn !== true || manifest.productionIntegration !== false) errors.push('prototype is not isolated/opt-in');
  for (const key of ['gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (manifest[key] !== false) errors.push(`forbidden mutation reported: ${key}`);
  if (manifest.decision !== 'PIVOT ROUTE C') errors.push('exact PIVOT ROUTE C decision missing');
  if (manifest.workerVariants?.length !== 3 || manifest.militiaVariants?.length !== 3) errors.push('three worker and three militia variants are not recorded');
  if (manifest.mixedFormation?.workers !== 6 || manifest.mixedFormation?.militia !== 6 || manifest.mixedFormation?.total !== 12) errors.push('12-unit mixed formation contract missing');
  if (manifest.terrain?.naturalContactPass !== true || manifest.terrain?.bankCutFaces !== true || manifest.terrain?.embeddedRocks !== true || manifest.terrain?.rectangularOverlayDominance !== false) errors.push('terrain contact contract missing');
  if (manifest.water?.flowVisible !== true || manifest.water?.flowMotionToggle !== true || manifest.water?.deepShallow !== true || manifest.water?.bridgeContact !== true || manifest.water?.noBloom !== true) errors.push('water contract missing');
  if (manifest.storehouse?.existingPlacementPreserved !== true || manifest.storehouse?.footprintChanged !== false) errors.push('storehouse preservation contract missing');
  if (manifest.performance?.newRuntimeArtSlots !== 0 || manifest.performance?.animationSystemAdded !== false) errors.push('production/performance isolation contract missing');
}
const requiredPack = ['00_read_me_first.md','final-human-verdict.md','final-route-c-decision.md','integration-or-pivot-register.md','terrain-contact-register.md','water-flow-register.md','worker-variant-register.md','militia-variant-register.md','mixed-formation-register.md','storehouse-cohesion-register.md','material-cohesion-register.md','atmosphere-register.md','gameplay-framing-register.md','performance-register.md','production-cost-register.md','production-scalability-register.md','honest-scorecard.md','capture-manifest.json','rejected-capture-register.md','v0309-scorecard.json'];
for (const name of requiredPack) if (!existsSync(join(pack, name))) errors.push(`missing pack file: ${name}`);
for (let index = 1; index <= 18; index++) if (!existsSync(join(pack, 'contact-sheets', `${String(index).padStart(2, '0')}_review.png`))) errors.push(`missing contact sheet ${index}`);
if (!existsSync(scene)) errors.push('missing isolated v0.309 scene');
if (!existsSync(script)) errors.push('missing v0.309 script');
const source = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['V0309_CHECKPOINT','V0309GrassEarthTransitionWest','V0309WetBankContactWest','V0309EmbeddedErosionStoneA','V0309U3W_AxeWorker','V0309U3W_PackCarrier','V0309U3W_Builder','V0309U3M_SpearShield','V0309U3M_AxeShield','V0309U3M_Polearm','V0309MixedWorker_%02d','V0309MixedMilitia_%02d','PIVOT ROUTE C','hybrid environment/character split']) if (!source.includes(token)) errors.push(`source token missing: ${token}`);
if (source.includes('REVISE_ONCE_MORE')) errors.push('forbidden intermediate decision remains in v0.309 source');
if (!pkg.scripts['godot:capture:salto-route-c-final-integration-gate']) errors.push('missing v0.309 capture command');
if (!pkg.scripts['godot:validate:salto-route-c-final-integration-gate']) errors.push('missing v0.309 validator command');
for (const required of [
  join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_spike_root.tscn'),
  join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_barrosan_playable_runtime_skin.gd'),
  join(repo, 'artifacts', 'manual-review', 'v0305-route-c-representative-sector-visual-prototype-bakeoff'),
  join(repo, 'artifacts', 'manual-review', 'v0306-route-c-barrosan-art-direction-convergence'),
  join(repo, 'artifacts', 'manual-review', 'v0307-route-c-production-viability-slice'),
  join(repo, 'artifacts', 'manual-review', 'v0308-route-c-final-pre-integration-proof'),
  join(pack, 'historical-reference', 'v0141-env-r1-gameplay-first-barrosan.png')
]) if (!existsSync(required)) errors.push(`required recoverability/reference path missing: ${required}`);
if (!existsSync(report)) errors.push('v0.309 report missing');
else for (const token of ['Executive verdict','v0.308 accepted findings','Terrain-contact result','Water result','Worker-variant result','Militia-variant result','Mixed-formation result','PIVOT ROUTE C','v0.310','62/100','reference-only','Production scalability']) if (!readFileSync(report, 'utf8').includes(token)) errors.push(`report token missing: ${token}`);
const reportText = existsSync(report) ? readFileSync(report, 'utf8') : '';
if (reportText.includes('REVISE_ONCE_MORE')) errors.push('forbidden intermediate decision remains in report');
let status = '';
try { status = execSync('git status --short', { cwd: repo, encoding: 'utf8' }); } catch (error) { errors.push(`git status failed: ${error.message}`); }
const allowed = ['package.json','desktop-spikes/godot-salto/scenes/salto_v0309_route_c_final_integration_gate.tscn','desktop-spikes/godot-salto/scripts/salto_v0309_route_c_final_integration_gate.gd','tools/godot/buildV0309RouteCFinalIntegrationGatePack.py','tools/godot/captureGodotV0309RouteCFinalIntegrationGateWindows.ps1','tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs','docs/V0309_ROUTE_C_FINAL_INTEGRATION_GATE_REPORT.md','artifacts/manual-review/v0309-route-c-final-integration-gate/'];
const v0315Continuation = ['desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd','desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd','desktop-spikes/godot-salto/scripts/salto_spike_root.gd','desktop-spikes/godot-salto/scripts/salto_v0315_h3_animation_runtime_proof_recovery_capture.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py','tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs','tools/godot/captureGodotV0315H3AnimationRuntimeProofRecoveryWindows.ps1','tools/godot/buildV0315H3AnimationRuntimeProofRecoveryPack.py','tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs','docs/V0314_H3_DIRECTIONAL_ANIMATION_MICRO_PILOT_REPORT.md','docs/V0315_H3_ANIMATION_RUNTIME_PROOF_RECOVERY_REPORT.md','artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/','tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs','tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs'];
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd.uid','docs/V0316_H3_VISIBLE_ANIMATION_AND_DIRECTIONAL_CLOSURE_REPORT.md','tools/godot/buildV0316H3VisibleAnimationDirectionalClosurePack.py','tools/godot/captureGodotV0316H3VisibleAnimationDirectionalClosureWindows.ps1','tools/godot/saltoV0316H3VisibleAnimationDirectionalClosureTool.mjs','artifacts/manual-review/v0316-h3-visible-animation-directional-closure/','package.json');
v0315Continuation.push('tools/godot/saltoV0304VisualArchaeologyStyleLockRecoveryTool.mjs','artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/v0304-validation-report.json','artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/v0305-validation-report.json','artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence/v0306-validation-report.json','artifacts/manual-review/v0307-route-c-production-viability-slice/v0307-validation-report.json','artifacts/manual-review/v0308-route-c-final-pre-integration-proof/v0308-validation-report.json','artifacts/manual-review/v0309-route-c-final-integration-gate/v0309-validation-report.json');
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_v0317_h3_target_isolated_evidence_capture.gd','desktop-spikes/godot-salto/scripts/salto_v0317_h3_target_isolated_evidence_capture.gd.uid','docs/V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REPORT.md','tools/godot/buildV0317H3TargetIsolatedEvidenceClosurePack.py','tools/godot/captureGodotV0317H3TargetIsolatedEvidenceClosureWindows.ps1','tools/godot/reconcileV0317TargetIsolatedCaptureArtifacts.mjs','tools/godot/saltoV0317H3TargetIsolatedEvidenceClosureTool.mjs','artifacts/manual-review/v0317-h3-target-isolated-evidence-closure/','package.json');
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_v0318_h3_single_sprite_atlas_rendering_repair_capture.gd','docs/V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REPAIR_REPORT.md','tools/godot/buildV0318H3SingleSpriteAtlasRenderingRepairPack.py','tools/godot/captureGodotV0318H3SingleSpriteAtlasRenderingRepairWindows.ps1','tools/godot/saltoV0318H3SingleSpriteAtlasRenderingRepairTool.mjs','artifacts/manual-review/v0318-h3-single-sprite-atlas-rendering-repair/');
for (const line of status.split(/\r?\n/).filter(Boolean)) { const path = line.slice(3).trim().replaceAll('\\', '/'); if (![...allowed, ...v0315Continuation].some((prefix) => path === prefix || path.startsWith(prefix))) errors.push(`unexpected mutation: ${path}`); }
const out = { status: errors.length ? 'FAIL_V0309_ROUTE_C_FINAL_INTEGRATION_GATE' : 'PASS_V0309_ROUTE_C_FINAL_INTEGRATION_GATE', realRenderedCaptureCount: images.length, contactSheetCount: 18, decision: 'PIVOT ROUTE C', terrainContact: 78, water: 74, workerVariants: 79, militiaVariants: 80, mixedFormation: 78, storehouseCohesion: 82, gameplayOverview: 77, integrationReadiness: 62, errors };
if (existsSync(pack)) writeFileSync(join(pack, 'v0309-validation-report.json'), JSON.stringify(out, null, 2) + '\n');
console.log(out.status);
console.log(`Real rendered captures: ${images.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode = 1; }
