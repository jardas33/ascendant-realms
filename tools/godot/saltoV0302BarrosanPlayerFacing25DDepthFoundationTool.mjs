import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const repo = resolve('.');
const base = join(repo, 'artifacts/desktop-spikes/godot-salto/v0302/player-facing-2-5d-depth-foundation');
const manual = join(repo, 'artifacts/manual-review/v0302-player-facing-2-5d-depth-foundation');
const errors = [];
const readJson = path => existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : null;
const player = readJson(join(base, 'player-facing/screenshot-runtime-manifest.json'));
const debug = readJson(join(base, 'debug-review/screenshot-runtime-manifest.json'));
if (!player) errors.push('missing PLAYER capture manifest');
if (!debug) errors.push('missing DEBUG_REVIEW capture manifest');
const skin = readFileSync(join(repo, 'desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd'), 'utf8');
const root = readFileSync(join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd'), 'utf8');
for (const token of ['v0302_player_facing_2_5d_depth_foundation_proof','_v0302_apply_player_depth_foundation','_v0302_apply_presentation_mode_ui','PROJECTION_ORTHOGONAL','v0302_unit_contact_shadow','v0302_building_foundation','v0302_selection_depth','barrosanPlayerFacing2_5dDepthFoundation']) if (!skin.includes(token)) errors.push(`missing runtime contract ${token}`);
for (const token of ['v0.302','_v0302_player_capture_steps','_v0302_debug_capture_steps','--salto-barrosan-player-presentation','--salto-barrosan-debug-review-overlay']) if (!root.includes(token)) errors.push(`missing capture contract ${token}`);
function checkManifest(manifest, mode) {
  if (!manifest) return;
  if ((manifest.captureCount ?? 0) < 20) errors.push(`${mode} capture count is below dedicated proof minimum`);
  const proof = manifest.barrosanPlayableRuntimeSkin?.barrosanPlayerFacing2_5dDepthFoundation?.proofSnapshots ?? {};
  const snapshots = Object.values(proof);
  if (!snapshots.length) errors.push(`${mode} has no v0.302 proof snapshots`);
  const snapshot = snapshots.find(value => value.presentationMode === mode) ?? snapshots[0] ?? {};
  const required = {
    checkpoint:'v0.302', playerModeExists:true, debugReviewModeExists:true, controlledObliqueProjection:true,
    cameraProjection:'ORTHOGRAPHIC', terrainDepthCues:true, buildingVolumeTreatment:true, unitGroundingContactShadows:true,
    directionalShadows:true, selectionDepthTreatment:true, routePreviewStaticSegmentCount:5, staticDeployedSupportPresenceCount:1,
    staticIntegrationVisualCount:1, pressureAfterStabilizeLine:'Pressure 70/100', selectedCardTextOverlap:false, buttonRowBelowText:true,
    rawValidatorParagraphAbsent:true, topStripStateUnchanged:true, selectedCardStateUnchanged:true, resourcesUnchanged:true,
    unitPositionsUnchanged:true, buildingPositionsUnchanged:true, buildingFootprintsUnchanged:true, minimapReadable:true,
    noGameplayMutation:true, noMovementPathfindingRouteFollowing:true, noCombatDamageHpProjectilesDeath:true, noAiWavesFog:true,
    noEconomyResourceMutation:true, noTrueDefaultRuntimeMutation:true, noDuplicateVisualNodes:true, noDuplicateShadows:true,
    noDuplicateLabels:true, noDuplicateMarkers:true, noDuplicateRouteSegments:true, noDuplicateSupportPresence:true, noDuplicateIntegrationVisual:true
  };
  if (mode === 'DEBUG_REVIEW') required.debugReviewPreserved = true;
  for (const [key, expected] of Object.entries(required)) if (snapshot[key] !== expected) errors.push(`${mode} proof ${key} expected ${JSON.stringify(expected)} got ${JSON.stringify(snapshot[key])}`);
}
checkManifest(player, 'PLAYER');
checkManifest(debug, 'DEBUG_REVIEW');
const numbered = existsSync(manual) ? readdirSync(manual).filter(name => /^\d\d_v0302_.*\.png$/.test(name)) : [];
if (numbered.length !== 59) errors.push(`review pack must contain exactly 59 numbered PNGs; found ${numbered.length}`);
for (const name of ['56_v0302_player_mode_contact_sheet.png','57_v0302_debug_review_mode_contact_sheet.png','58_v0302_before_after_visual_comparison_contact_sheet.png','59_v0302_black_frame_rejection_report.png']) if (!numbered.includes(name)) errors.push(`missing ${name}`);
const report = { status: errors.length ? 'FAIL_v0302_VALIDATION' : 'PASS_v0302_BARROSAN_PLAYER_FACING_2_5D_DEPTH_FOUNDATION_VALIDATION', errors, playerCaptureCount: player?.captureCount ?? 0, debugCaptureCount: debug?.captureCount ?? 0, reviewPackNumberedPngCount: numbered.length, blackFrameRejectionReport:'v0302-black-frame-stats.json' };
if (existsSync(manual)) writeFileSync(join(manual, 'v0302-validation-report.json'), JSON.stringify(report, null, 2) + '\n');
console.log(report.status);
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
