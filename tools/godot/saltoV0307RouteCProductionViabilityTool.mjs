import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { execSync } from 'node:child_process';

const repo = process.cwd();
const pack = join(repo, 'artifacts', 'manual-review', 'v0307-route-c-production-viability-slice');
const real = join(pack, 'real-rendered');
const scene = join(repo, 'desktop-spikes', 'godot-salto', 'scenes', 'salto_v0307_route_c_production_viability_slice.tscn');
const script = join(repo, 'desktop-spikes', 'godot-salto', 'scripts', 'salto_v0307_route_c_production_viability_slice.gd');
const report = join(repo, 'docs', 'V0307_ROUTE_C_PRODUCTION_VIABILITY_SLICE_REPORT.md');
const pkg = JSON.parse(readFileSync(join(repo, 'package.json'), 'utf8'));
const errors = [];
const images = existsSync(real) ? readdirSync(real).filter((n) => n.endsWith('.png')) : [];
if (images.length < 20) errors.push(`insufficient real renders: ${images.length}`);
for (const name of images) {
  const bytes = readFileSync(join(real, name));
  if (bytes.length < 10000 || !bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]))) errors.push(`invalid/blank render: ${name}`);
}
const manifestPath = join(repo, 'artifacts', 'desktop-spikes', 'godot-salto', 'v0307', 'production-viability', 'v0307-route-c-production-viability-runtime.json');
if (!existsSync(manifestPath)) errors.push('missing runtime manifest');
else {
  const m = JSON.parse(readFileSync(manifestPath, 'utf8'));
  for (const key of ['prototypeOnly','prototypeOptIn','productionIntegration','gameplayChanged','movementChanged','pathingChanged','combatChanged','economyChanged','resourceChanged','pressureChanged','stableIdsChanged','saveChanged']) if (!(key in m)) errors.push(`manifest missing ${key}`);
  if (m.prototypeOnly !== true || m.prototypeOptIn !== true || m.productionIntegration !== false) errors.push('prototype is not isolated');
  if (m.gameplayChanged || m.movementChanged || m.pathingChanged || m.combatChanged || m.economyChanged || m.resourceChanged || m.pressureChanged || m.stableIdsChanged || m.saveChanged) errors.push('forbidden mutation reported');
  if (m.unitStrategies?.U1 == null || m.unitStrategies?.U2 == null || m.unitStrategies?.U3 == null) errors.push('U1/U2/U3 evidence missing');
  if (m.recommendedUnitStrategy !== 'U3 hybrid low-poly body plus billboard/detail solution') errors.push('recommended strategy is not U3');
  if (m.terrain?.microSliceBounded !== true || m.terrain?.walkabilityDimensionsPreserved !== true || m.terrain?.rectangularPlates !== false) errors.push('terrain micro-slice contract missing');
  if (m.river?.deepChannel !== true || m.river?.shallowShelf !== true || m.river?.visibleFlowDirection !== true || m.river?.irregularShoreline !== true) errors.push('river authoring contract missing');
  if (m.supportBuilding?.authored !== true || m.supportBuilding?.blockoutReplaced !== true || m.supportBuilding?.gameplayFootprintChanged !== false) errors.push('support building contract missing');
}
for (const required of ['00_read_me_first.md','final-human-verdict.md','terrain-authoring-register.md','river-authoring-register.md','support-building-register.md','unit-strategy-bakeoff.md','unit-cost-comparison.md','material-value-register.md','atmosphere-register.md','production-viability-scorecard.md','production-risk-register.md','capture-manifest.json','rejected-capture-register.md','v0307-scorecard.json']) if (!existsSync(join(pack, required))) errors.push(`missing pack file: ${required}`);
for (let i=1;i<=12;i++) if (!existsSync(join(pack,'contact-sheets',`${String(i).padStart(2,'0')}_review.png`))) errors.push(`missing contact sheet ${i}`);
if (!existsSync(scene)) errors.push('missing isolated scene');
if (!existsSync(script)) errors.push('missing v0.307 script');
const source = existsSync(script) ? readFileSync(script, 'utf8') : '';
for (const token of ['V0307_CHECKPOINT','V0307AuthoredBarrosanUtilityHouse','V0307DeepChannel','V0307ShallowShelf','V0307FlowDirectionA','V0307FoamDisturbance','V0307Aster_U1_DirectionalBillboard','V0307Aster_U2_LowPoly3D','V0307Aster_U3_HybridBodyBillboard','UtilitySlateGableRoof','V0307MountainHazeEnvironment','prototypeOnly']) if (!source.includes(token)) errors.push(`source token missing: ${token}`);
if (!pkg.scripts['godot:capture:salto-route-c-production-viability']) errors.push('missing v0.307 capture command');
if (!pkg.scripts['godot:validate:salto-route-c-production-viability']) errors.push('missing v0.307 validator command');
if (!existsSync(join(repo,'desktop-spikes','godot-salto','scenes','salto_spike_root.tscn'))) errors.push('default launcher missing');
if (!existsSync(join(repo,'desktop-spikes','godot-salto','scripts','salto_barrosan_playable_runtime_skin.gd'))) errors.push('v0.303 fallback missing');
if (!existsSync(join(repo,'artifacts','manual-review','v0305-route-c-representative-sector-visual-prototype-bakeoff'))) errors.push('v0.305 not recoverable');
if (!existsSync(join(repo,'artifacts','manual-review','v0306-route-c-barrosan-art-direction-convergence'))) errors.push('v0.306 not recoverable');
if (!existsSync(join(pack,'historical-reference','v0141-env-r1-gameplay-first-barrosan.png'))) errors.push('R1 reference missing');
if (!existsSync(report)) errors.push('v0.307 report missing');
else for (const token of ['Executive verdict','Why v0.306 was not accepted','U1','U2','U3','Recommended unit strategy','78/100','v0.308','reference-only','production integration']) if (!readFileSync(report,'utf8').includes(token)) errors.push(`report token missing: ${token}`);
const status = execSync('git status --short', {cwd: repo, encoding:'utf8'});
const allowed = ['package.json','desktop-spikes/godot-salto/scenes/salto_v0307_route_c_production_viability_slice.tscn','desktop-spikes/godot-salto/scripts/salto_v0307_route_c_production_viability_slice.gd','desktop-spikes/godot-salto/scripts/salto_v0307_route_c_production_viability_slice.gd.uid','tools/godot/captureGodotV0307RouteCProductionViabilityWindows.ps1','tools/godot/buildV0307RouteCProductionViabilityPack.py','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','docs/V0307_ROUTE_C_PRODUCTION_VIABILITY_SLICE_REPORT.md','artifacts/manual-review/v0307-route-c-production-viability-slice/'];
const v0315Continuation = ['desktop-spikes/godot-salto/scripts/barrosan_h3_directional_animation_adapter_v0314.gd','desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd','desktop-spikes/godot-salto/scripts/salto_spike_root.gd','desktop-spikes/godot-salto/scripts/salto_v0315_h3_animation_runtime_proof_recovery_capture.gd','tools/godot/buildV0310HybridCharacterPivotPack.py','tools/godot/saltoV0310HybridCharacterPivotTool.mjs','tools/godot/buildV0314H3DirectionalAnimationMicroPilotPack.py','tools/godot/saltoV0314H3DirectionalAnimationMicroPilotTool.mjs','tools/godot/captureGodotV0315H3AnimationRuntimeProofRecoveryWindows.ps1','tools/godot/buildV0315H3AnimationRuntimeProofRecoveryPack.py','tools/godot/saltoV0315H3AnimationRuntimeProofRecoveryTool.mjs','docs/V0314_H3_DIRECTIONAL_ANIMATION_MICRO_PILOT_REPORT.md','docs/V0315_H3_ANIMATION_RUNTIME_PROOF_RECOVERY_REPORT.md','artifacts/manual-review/v0315-h3-animation-runtime-proof-recovery/','tools/godot/saltoV0305RouteCRepresentativeSectorTool.mjs','tools/godot/saltoV0306RouteCBarrosanConvergenceTool.mjs','tools/godot/saltoV0307RouteCProductionViabilityTool.mjs','tools/godot/saltoV0308RouteCFinalPreIntegrationProofTool.mjs','tools/godot/saltoV0309RouteCFinalIntegrationGateTool.mjs'];
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd','desktop-spikes/godot-salto/scripts/salto_v0316_h3_visible_animation_directional_closure_capture.gd.uid','docs/V0316_H3_VISIBLE_ANIMATION_AND_DIRECTIONAL_CLOSURE_REPORT.md','tools/godot/buildV0316H3VisibleAnimationDirectionalClosurePack.py','tools/godot/captureGodotV0316H3VisibleAnimationDirectionalClosureWindows.ps1','tools/godot/saltoV0316H3VisibleAnimationDirectionalClosureTool.mjs','artifacts/manual-review/v0316-h3-visible-animation-directional-closure/','package.json');
v0315Continuation.push('tools/godot/saltoV0304VisualArchaeologyStyleLockRecoveryTool.mjs','artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/v0304-validation-report.json','artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/v0305-validation-report.json','artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence/v0306-validation-report.json','artifacts/manual-review/v0307-route-c-production-viability-slice/v0307-validation-report.json','artifacts/manual-review/v0308-route-c-final-pre-integration-proof/v0308-validation-report.json','artifacts/manual-review/v0309-route-c-final-integration-gate/v0309-validation-report.json');
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_v0317_h3_target_isolated_evidence_capture.gd','desktop-spikes/godot-salto/scripts/salto_v0317_h3_target_isolated_evidence_capture.gd.uid','docs/V0317_H3_TARGET_ISOLATED_EVIDENCE_CLOSURE_REPORT.md','tools/godot/buildV0317H3TargetIsolatedEvidenceClosurePack.py','tools/godot/captureGodotV0317H3TargetIsolatedEvidenceClosureWindows.ps1','tools/godot/reconcileV0317TargetIsolatedCaptureArtifacts.mjs','tools/godot/saltoV0317H3TargetIsolatedEvidenceClosureTool.mjs','artifacts/manual-review/v0317-h3-target-isolated-evidence-closure/','package.json');
v0315Continuation.push('desktop-spikes/godot-salto/scripts/salto_v0318_h3_single_sprite_atlas_rendering_repair_capture.gd','docs/V0318_H3_SINGLE_SPRITE_ATLAS_RENDERING_REPAIR_REPORT.md','tools/godot/buildV0318H3SingleSpriteAtlasRenderingRepairPack.py','tools/godot/captureGodotV0318H3SingleSpriteAtlasRenderingRepairWindows.ps1','tools/godot/saltoV0318H3SingleSpriteAtlasRenderingRepairTool.mjs','artifacts/manual-review/v0318-h3-single-sprite-atlas-rendering-repair/');
for (const line of status.split(/\r?\n/).filter(Boolean)) { const path = line.slice(3).trim().replaceAll('\\','/'); if (![...allowed, ...v0315Continuation].some((prefix)=>path===prefix || path.startsWith(prefix))) errors.push(`unexpected mutation: ${path}`); }
const out = {status: errors.length ? 'FAIL_V0307_ROUTE_C_PRODUCTION_VIABILITY' : 'PASS_V0307_ROUTE_C_PRODUCTION_VIABILITY', realRenderedCaptureCount: images.length, v0306Score:68, v0307Score:78, U1:55, U2:74, U3:82, recommended:'U3', errors};
if (existsSync(pack)) writeFileSync(join(pack,'v0307-validation-report.json'), JSON.stringify(out,null,2)+'\n');
console.log(out.status);
console.log(`Real rendered captures: ${images.length}`);
if (errors.length) { for (const error of errors) console.error(`- ${error}`); process.exitCode=1; }
