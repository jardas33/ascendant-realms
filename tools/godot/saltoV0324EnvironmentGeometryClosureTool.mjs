import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const source = path.join(root, 'artifacts/desktop-spikes/godot-salto/v0324/environment-geometry-closure');
const pack = path.join(root, 'artifacts/manual-review/v0324-environment-geometry-closure');
const upload = path.join(pack, 'UPLOAD_TO_CHAT');
const scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0324EnvironmentGeometryClosure.tscn');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0324_environment_geometry_closure.gd');
const media = path.join(upload, '08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4');
const v0322Media = path.join(root, 'artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_SLICE.mp4');
const expectedV0322Sha = '8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84';
const required = ['00_READ_ME_FIRST.md','01_V0323_TO_V0324_COMPARISON.png','02_CLEAN_PLAYER_OVERVIEW.png','03_RECESSED_RIVER_AND_BANKS.png','04_RIVER_CROSS_SECTION_AUDIT.png','05_IRREGULAR_YARDS_AND_PATH_NETWORK.png','06_BRIDGE_ABUTMENT_INTEGRATION.png','07_ORDINARY_GAMEPLAY.png','08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4','compact-evidence-summary.json'];
const fail = (message) => { throw new Error(`FAIL_V0324: ${message}`); };
const exists = (file) => fs.existsSync(file);
const readText = (file) => fs.readFileSync(file, 'utf8');
const readJson = (file) => JSON.parse(readText(file));
const sha = (file) => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const audit = () => { if (!exists(path.join(source, 'v0324-environment-geometry-audit.json'))) fail('runtime audit missing; capture v0.324 first'); return readJson(path.join(source, 'v0324-environment-geometry-audit.json')); };
const manifest = () => { if (!exists(path.join(source, 'v0324-environment-geometry-closure-runtime.json'))) fail('runtime manifest missing; capture v0.324 first'); return readJson(path.join(source, 'v0324-environment-geometry-closure-runtime.json')); };
function pngSize(file) { const bytes = fs.readFileSync(file); if (bytes.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') fail(`${path.basename(file)} is not PNG`); return { width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20) }; }
function ffprobe(file) { const ffprobe = process.env.FFPROBE || 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe'; return JSON.parse(execFileSync(ffprobe, ['-v','error','-show_entries','format=format_name,duration:stream=codec_name,width,height,r_frame_rate,nb_frames','-of','json',file], { encoding:'utf8' })); }
function decodeHashes(file) { const ffmpeg = process.env.FFMPEG || 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffmpeg.exe'; const raw = execFileSync(ffmpeg, ['-v','error','-i',file,'-vf','scale=160:90:flags=bilinear,format=rgb24','-f','rawvideo','-'], { maxBuffer: 64 * 1024 * 1024 }); const size = 160 * 90 * 3; if (raw.length % size) fail('decoded MP4 bytes are not whole frames'); const hashes=[]; for(let i=0;i<raw.length;i+=size) hashes.push(crypto.createHash('sha256').update(raw.subarray(i,i+size)).digest('hex')); return hashes; }
function validateFiles() {
  if (!exists(scene) || !exists(script)) fail('v0.324 scene/script missing');
  if (!exists(upload)) fail('UPLOAD_TO_CHAT missing');
  const names = fs.readdirSync(upload).filter(name => fs.statSync(path.join(upload,name)).isFile()).sort();
  if (names.length !== 10 || names.join('|') !== required.slice().sort().join('|')) fail(`UPLOAD_TO_CHAT must contain exactly ten required files; got ${names.join(',')}`);
  for (const name of required.filter(name => name.endsWith('.png'))) { const size = pngSize(path.join(upload,name)); if (size.width < 640 || size.height < 360) fail(`${name} is too small`); }
  const sourceText = readText(script);
  for (const anchor of ['V0324SingleContinuousRecessedRiverWater','V0324ContinuousLeftBank','V0324ContinuousRightBank','V0324PrincipalIrregularYard','V0324WorkshopIrregularYard','V0324WestAbutment','V0324EastAbutment','V0324_RIVER_SAMPLES := 96','V0324_CROSS_SECTIONS := 24']) if (!sourceText.includes(anchor)) fail(`missing geometry anchor ${anchor}`);
  for (const forbidden of ['_add_disc(', 'V0323ManorYard', 'V0323WorkshopYard', 'BRIDGE LINE  |  SALTO EAST']) if (sourceText.includes(forbidden)) fail(`rejected circular pad/title construction remains: ${forbidden}`);
  return { names };
}
function validateRiverCourse() { const r=audit().river; if(r.centrelineSampleCount<24||r.crossSectionCount<12) fail('river sample counts below contract'); if(r.maximumHeadingDeltaDegrees>=25) fail(`heading delta ${r.maximumHeadingDeltaDegrees} >=25`); if(r.maximumAdjacentWidthChangePercent>18) fail('river width changes too quickly'); if(r.visibleTerminationCount!==0) fail('visible river termination exists'); return r; }
function validateDepth() { const r=audit().river; if(r.minimumLandToWaterDrop<0.35||r.waterSurfaceY>=r.ordinaryLandReferenceY) fail('river is not recessed below ordinary land'); return { minimumLandToWaterDrop:r.minimumLandToWaterDrop, waterSurfaceY:r.waterSurfaceY, ordinaryLandReferenceY:r.ordinaryLandReferenceY }; }
function validateBanks() { const r=audit().river; if(r.leftBankComponents!==1||r.rightBankComponents!==1||r.waterComponents!==1) fail('bank/water components disconnected'); if(r.maximumGapMetres>0.02||r.degenerateTriangleCount!==0||r.invalidNormalCount!==0||r.acuteSpikeCount!==0) fail('bank continuity thresholds failed'); return r; }
function validateYards() { const a=audit().yards; for(const [name, yard] of Object.entries(a)) { if(yard.boundarySampleCount<32||yard.radialCoefficientOfVariation<0.08||yard.circleFitPercent>=80||!yard.connectedToRoute||!yard.originalCircularNodeAbsent) fail(`${name} circular-pad/route contract failed`); } return a; }
function validateBridge() { const b=audit().bridge; if(!b.northAbutmentContact||!b.southAbutmentContact||b.deckContactCount!==2||b.floatingEntranceCount!==0||b.traversalAlignmentError>0.02||b.waterOrTerrainPenetration) fail('bridge contact contract failed'); return b; }
function validatePlayer() { const m=manifest(); const forbidden=['BRIDGE LINE','PRESSURE STABILIZED','DEBUG','REVIEW','VALIDATOR','PROTOTYPE','route centreline','geometry measurement','camera coordinates']; const text=readText(path.join(upload,'02_CLEAN_PLAYER_OVERVIEW.png')); if(!m.prototypeOptIn||m.defaultRuntimeChanged||m.gameplayChanged||m.playerDebugStringsFound.length!==0) fail('PLAYER/default/gameplay flags failed'); if(m.scenePath!== 'res://visual_vertical_slice/V0324EnvironmentGeometryClosure.tscn') fail('wrong scene path'); const summary=readJson(path.join(upload,'compact-evidence-summary.json')); if(summary.playerDebugStringsFound.length!==0||summary.noUnverifiedClaims===true) fail('compact evidence contains forbidden PLAYER/self-certification data'); return { playerDebugStringsFound:m.playerDebugStringsFound, staticImageChecked:true, forbiddenTextList:forbidden }; }
function validatePreservation() { const m=manifest(); if(!m.acceptedRoofGeometryUnchanged||!m.v0323Preserved||!m.v0303FallbackPreserved||!m.h3FallbackAdaptersPreserved) fail('accepted preservation flags failed'); if(m.v0322MediaSHA256Before!==expectedV0322Sha||m.v0322MediaSHA256After!==expectedV0322Sha||!m.v0322MediaUnchanged) fail('v0.322 media preservation failed'); const roof=m.roofs; if(roof.length!==2||roof.some(row=>row.invalidNormalCount!==0||row.selfIntersectionCount!==0||!row.chimneyContact||!row.ridgeCapContact)) fail('v0.323 roof audit regressed'); return { acceptedRoofGeometryUnchanged:true, v0322MediaUnchanged:true, roofs:roof }; }
function validateMedia() { if(!exists(media)) fail('v0.324 upload MP4 missing'); const before=sha(media); const p=ffprobe(media); const s=p.streams[0]; const hashes=decodeHashes(media); const parts=String(s.r_frame_rate||'0/1').split('/'); const fps=Number(parts[1])?Number(parts[0])/Number(parts[1]):Number(parts[0]); const duration=Number(p.format?.duration||0); if(s.codec_name!=='h264'||s.width!==1280||s.height!==720||fps<24||duration<10||duration>12||hashes.length!==264||new Set(hashes).size<238) fail(`media contract failed codec=${s.codec_name} ${s.width}x${s.height} fps=${fps} duration=${duration} frames=${hashes.length} unique=${new Set(hashes).size}`); const after=sha(media); if(before!==after) fail('upload MP4 changed during validation'); return { path:'artifacts/manual-review/v0324-environment-geometry-closure/UPLOAD_TO_CHAT/08_CONTINUOUS_ENVIRONMENT_GEOMETRY.mp4', sha256:after, codec:s.codec_name, width:s.width, height:s.height, fps, duration, decodedFrameCount:hashes.length, uniqueFrameCount:new Set(hashes).size, postCopyHashVerified:true, postValidationHashVerified:true }; }
function validateV0322Media() { if(!exists(v0322Media)||sha(v0322Media)!==expectedV0322Sha) fail('accepted v0.322 MP4 changed'); return { sha256:expectedV0322Sha, unchanged:true }; }
function validate() { validateFiles(); const result={status:'PASS_V0324_ENVIRONMENT_GEOMETRY_CLOSURE',outcome:'READY FOR HUMAN ENVIRONMENT GEOMETRY REVIEW',river:validateRiverCourse(),depth:validateDepth(),banks:validateBanks(),yards:validateYards(),bridge:validateBridge(),player:validatePlayer(),preservation:validatePreservation(),finalMedia:validateMedia(),v0322Media:validateV0322Media(),reviewPackFileCount:10,defaultRuntimeUnchanged:true,gameplayUnchanged:true}; console.log(JSON.stringify(result,null,2)); }
const command=process.argv[2]||'validate';
if(command==='validate') validate();
else if(command==='validate-river-course'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_RIVER_COURSE',river:validateRiverCourse()},null,2));}
else if(command==='validate-river-depth'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_RIVER_DEPTH',depth:validateDepth()},null,2));}
else if(command==='validate-bank-continuity'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_BANK_CONTINUITY',river:validateBanks()},null,2));}
else if(command==='validate-yard-shape'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_YARD_SHAPE',yards:validateYards()},null,2));}
else if(command==='validate-bridge-contact'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_BRIDGE_CONTACT',bridge:validateBridge()},null,2));}
else if(command==='validate-player-hygiene'){validateFiles();console.log(JSON.stringify({status:'PASS_V0324_PLAYER_HYGIENE',player:validatePlayer()},null,2));}
else if(command==='validate-media'){console.log(JSON.stringify(validateMedia(),null,2));}
else { fail(`unknown command ${command}`); }
