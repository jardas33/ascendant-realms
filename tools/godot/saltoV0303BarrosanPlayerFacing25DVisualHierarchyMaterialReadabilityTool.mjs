import { existsSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const repo=resolve('.');
const base=join(repo,'artifacts/desktop-spikes/godot-salto/v0303/player-facing-2-5d-visual-hierarchy-material-readability');
const manual=join(repo,'artifacts/manual-review/v0303-player-facing-2-5d-visual-hierarchy-material-readability');
const errors=[];
const readJson=p=>existsSync(p)?JSON.parse(readFileSync(p,'utf8')):null;
const player=readJson(join(base,'player-facing/screenshot-runtime-manifest.json'));
const debug=readJson(join(base,'debug-review/screenshot-runtime-manifest.json'));
if(!player) errors.push('missing PLAYER capture manifest');
if(!debug) errors.push('missing DEBUG_REVIEW capture manifest');
const skin=readFileSync(join(repo,'desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd'),'utf8');
const root=readFileSync(join(repo,'desktop-spikes/godot-salto/scripts/salto_spike_root.gd'),'utf8');
for(const token of ['v0303_player_facing_visual_hierarchy_material_readability_proof','_v0303_apply_player_material_hierarchy','_v0303_material','v0303_grass_value','v0303_road_value','v0303_water_value_surface','v0303_bridge_value_surface','v0303_building_roof','v0303_building_side','v0303_unit_value_lift','v0303_selection_accent','barrosanPlayerFacingVisualHierarchyMaterialReadability']) if(!skin.includes(token)) errors.push(`missing runtime contract ${token}`);
for(const token of ['v0.303','_v0303_player_capture_steps','_v0303_debug_capture_steps','v0303_']) if(!root.includes(token)) errors.push(`missing capture contract ${token}`);
function checkManifest(manifest,mode){
  if(!manifest) return;
  if((manifest.captureCount??0)<18) errors.push(`${mode} capture count is below dedicated proof minimum`);
  const proof=manifest.barrosanPlayableRuntimeSkin?.barrosanPlayerFacingVisualHierarchyMaterialReadability?.proofSnapshots??{};
  const snapshots=Object.values(proof); if(!snapshots.length) errors.push(`${mode} has no v0.303 proof snapshots`);
  const snapshot=snapshots.find(v=>v.presentationMode===mode)??snapshots[0]??{};
  if(!snapshots.some(v=>v.playerDebugPlayerRoundTripRestored===true)) errors.push(`${mode} lacks PLAYER -> DEBUG_REVIEW -> PLAYER round-trip proof`);
  const required={checkpoint:'v0.303',playerModeExists:true,debugReviewModeExists:true,visualHierarchyMaterialTreatment:true,terrainMaterialHierarchy:true,roadMaterialHierarchy:true,waterMaterialHierarchy:true,bridgeMaterialHierarchy:true,buildingMaterialHierarchy:true,mainHallIdentifiable:true,fieldBarracksIdentifiable:true,unitSilhouettesReadable:true,unitTerrainSeparation:true,selectionStatesReadable:true,consistentShadowDirection:true,shadowsNotGameplayZones:true,v0302CameraProjectionPreserved:true,v0302CameraPitchDegrees:-56.5,v0302CameraSize:10.6,routePreviewStaticSegmentCount:5,staticDeployedSupportPresenceCount:1,staticIntegrationVisualCount:1,pressureAfterStabilizeLine:'Pressure 70/100',selectedCardTextOverlap:false,buttonRowBelowText:true,rawValidatorParagraphAbsent:true,topStripStateUnchanged:true,selectedCardStateUnchanged:true,resourcesUnchanged:true,unitPositionsUnchanged:true,buildingPositionsUnchanged:true,buildingFootprintsUnchanged:true,minimapReadable:true,noGameplayMutation:true,noMovementPathfindingRouteFollowing:true,noCombatDamageHpProjectilesDeath:true,noAiWavesFog:true,noEconomyResourceMutation:true,noTrueDefaultRuntimeMutation:true,noDuplicateMaterialInstances:true,noDuplicateVisualNodes:true,noDuplicateShadows:true,noDuplicateLabels:true,noDuplicateMarkers:true,noDuplicateRouteSegments:true,noDuplicateSupportPresence:true,noDuplicateIntegrationVisual:true};
  for(const [key,expected] of Object.entries(required)) if(snapshot[key]!==expected) errors.push(`${mode} proof ${key} expected ${JSON.stringify(expected)} got ${JSON.stringify(snapshot[key])}`);
}
checkManifest(player,'PLAYER'); checkManifest(debug,'DEBUG_REVIEW');
const numbered=existsSync(manual)?readdirSync(manual).filter(n=>/^\d\d_v0303_.*\.png$/.test(n)):[];
if(numbered.length!==65) errors.push(`review pack must contain exactly 65 numbered PNGs; found ${numbered.length}`);
for(const name of ['62_v0303_player_contact_sheet.png','63_v0303_debug_review_contact_sheet.png','64_v0303_before_after_comparison_contact_sheet.png','65_v0303_black_frame_rejection_report.png']) if(!numbered.includes(name)) errors.push(`missing ${name}`);
const report={status:errors.length?'FAIL_v0303_VALIDATION':'PASS_v0303_BARROSAN_PLAYER_FACING_2_5D_VISUAL_HIERARCHY_MATERIAL_READABILITY_VALIDATION',errors,playerCaptureCount:player?.captureCount??0,debugCaptureCount:debug?.captureCount??0,reviewPackNumberedPngCount:numbered.length,blackFrameRejectionReport:'v0303-black-frame-stats.json'};
if(existsSync(manual)) writeFileSync(join(manual,'v0303-validation-report.json'),JSON.stringify(report,null,2)+'\n');
console.log(report.status); if(errors.length){console.error(errors.join('\n'));process.exit(1)}
