import{existsSync,readFileSync,readdirSync,writeFileSync}from'node:fs';
import{join,resolve}from'node:path';
const repo=resolve('.');
const root=join(repo,'artifacts/desktop-spikes/godot-salto/v0299/static-bridge-pressure-stabilization-gate-runtime');
const manual=join(repo,'artifacts/manual-review/v0299-barrosan-static-bridge-pressure-stabilization-gate');
const errors=[];const manifestPath=join(root,'screenshot-runtime-manifest.json');
const actions=['v0299_support_selected','v0299_stabilize_available','v0299_stabilize_clicked','v0299_pressure_stabilized_strip','v0299_pressure_stabilized_marker_once','v0299_pressure_display','v0299_support_stabilized','v0299_defender_stabilized','v0299_barracks_stabilized','v0299_repeat_idempotent','v0299_no_pressure_stacking'];
if(!existsSync(manifestPath))errors.push('missing v0.299 manifest');
else{
 const m=JSON.parse(readFileSync(manifestPath));
 if(m.captureCount!==16)errors.push('capture incomplete');
 const runtimeErrors=m.errors??[];if(runtimeErrors.some(e=>!String(e).startsWith('Viewport texture was unavailable')))errors.push('runtime capture errors: '+runtimeErrors.join('; '));
 for(const a of actions)if(!m.captures?.some(c=>c.action===a))errors.push('missing '+a);
 const p=m.barrosanPlayableRuntimeSkin?.barrosanStaticBridgePressureStabilizationGate?.proofSnapshots?.v0299_pressure_stabilized_strip||{};
 for(const[k,v]of Object.entries({bridgePressureStabilizedCount:1,pressureMarkerCount:1,pressureAfterStabilizeLine:'Pressure 70/100',pressureStabilizationIdempotent:true,pressureDoesNotStack:true,staticDeployedSupportPresenceCount:1,staticIntegrationVisualCount:1,routePreviewStaticSegmentCount:5,routePreviewControlledNotMoving:true,noExistingUnitPositionChanges:true,noCombatAttacks:true,noDamageHpLoss:true,noEconomyResourceMutation:true,noAnimatedMovementPathfindingRouteFollowing:true,noAiWavesFog:true,noTrueDefaultRuntimeMutation:true,selectedCardTextOverlap:false,buttonRowBelowText:true,rawValidatorParagraphAbsent:true}))if(p[k]!==v)errors.push('proof '+k);
}
const source=readFileSync(join(repo,'desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd'),'utf8');
for(const t of['Stabilize Line','BRIDGE PRESSURE STABILIZED','PRESSURE\\nSTABILIZED','Pressure 70/100','staticIntegrationVisualCount'])if(!source.includes(t))errors.push('missing '+t);
const blockEnd=source.indexOf('func _v0300_review_modes()')>=0?source.indexOf('func _v0300_review_modes()'):source.indexOf('func _v0264_reset_intel_relay()');const block=source.slice(source.indexOf('func _v0299_review_modes()'),blockEnd);
for(const f of['NavigationAgent','AStar','move_toward','spawn_deployed','damage_taken','projectile'])if(block.includes(f))errors.push('forbidden '+f);
const numbered=existsSync(manual)?readdirSync(manual).filter(n=>/^\d\d_v0299_.*\.png$/.test(n)):[];
if(numbered.length!==41)errors.push(`review pack must contain exactly 41 numbered PNGs; found ${numbered.length}`);
for(const n of['40_v0299_contact_sheet.png','41_v0299_black_frame_rejection_report.png'])if(!numbered.includes(n))errors.push('missing '+n);
const report={status:errors.length?'FAIL_v0299_VALIDATION':'PASS_v0299_BARROSAN_STATIC_BRIDGE_PRESSURE_STABILIZATION_GATE_VALIDATION',errors,captureCount:16,runtimeCaptureStatus:existsSync(manifestPath)?JSON.parse(readFileSync(manifestPath)).status:'MISSING',requiredActions:actions,reviewPackNumberedPngCount:numbered.length,blackFrameRejectionReport:'v0299-black-frame-stats.json'};
if(existsSync(manual))writeFileSync(join(manual,'v0299-validation-report.json'),JSON.stringify(report,null,2)+'\n');
console.log(report.status);if(errors.length){console.error(errors.join('\n'));process.exit(1)}
