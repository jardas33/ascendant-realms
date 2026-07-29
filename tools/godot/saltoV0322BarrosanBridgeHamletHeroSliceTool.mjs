import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';

const root = process.cwd();
const pack = path.join(root, 'artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice');
const upload = path.join(pack, 'UPLOAD_TO_CHAT');
const scene = path.join(root, 'desktop-spikes/godot-salto/visual_vertical_slice/V0322BarrosanBridgeHamletHeroSlice.tscn');
const script = path.join(root, 'desktop-spikes/godot-salto/scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd');
const media = path.join(upload, '08_CONTINUOUS_HERO_SLICE.mp4');
const required = ['00_READ_ME_FIRST.md','01_V0321_TO_V0322_COMPARISON.png','02_HERO_OVERVIEW.png','03_ORDINARY_GAMEPLAY.png','04_NATURAL_RIVER_AND_BRIDGE.png','05_BARROSAN_HERO_ARCHITECTURE.png','06_TERRAIN_ROAD_AND_PROPS.png','07_LIGHTING_AND_MATERIAL_DETAIL.png','08_CONTINUOUS_HERO_SLICE.mp4','compact-evidence-summary.json'];
const fullEvidenceRequired = ['01_PREFLIGHT_HEAD_BRANCH_PROOF.md','02_TRUE_DEFAULT_RUNTIME_UNCHANGED.md','03_V0304_RECOMMENDED_ROUTE_PROOF.md','04_HISTORICAL_TARGET_REFERENCE.png','05_CURRENT_V0303_PLAYER_REFERENCE.png','06_ROUTE_C_HERO_OVERVIEW.png','07_MATCHING_FRAMING_COMPARISON.png','08_OBLIQUE_RTS_CAMERA.png','09_DIRECT_TOP_DOWN_COMPARISON.png','10_RIVER_BELOW_LAND.png','11_RIVERBANK_TRANSITION.png','12_GRASS_ROAD_INTEGRATION.png','13_ROAD_BRIDGE_INTEGRATION.png','14_BRIDGE_STRUCTURE_CLOSEUP.png','15_BRIDGE_DECK_SUPPORT_DEPTH.png','16_FIELD_MANOR_FULL_VIEW.png','17_FIELD_MANOR_ROOF_SIDE_BASE.png','18_WORKSHOP_FULL_VIEW.png','19_WORKSHOP_ROOF_SIDE_BASE.png','20_ASTER_GROUNDING.png','21_DEFENDER_GROUNDING.png','22_RESERVE_SUPPORT_GROUNDING.png','23_UNIT_BUILDING_SCALE.png','24_UNIT_SILHOUETTE.png','25_SELECTION_TREATMENT.png','26_DIRECTIONAL_LIGHTING.png','27_SHADOW_DIRECTION.png','28_NO_TRANSLUCENT_DEBUG_PADS.png','29_BARROSAN_MATERIAL_LANGUAGE.png','30_TACTICAL_READABILITY.png','31_MINIMAP_HUD_RELATIONSHIP.png','32_SELECTED_CARD_NO_OVERLAP.png','33_SELECT_ASTER_OVERLAP_REPAIRED.png','34_DEBUG_PROOF_RENDERER_RETAINED.png','35_V0303_FALLBACK_RETAINED.png','36_NO_MOVEMENT_PROOF.md','37_NO_PATHFINDING_PROOF.md','38_NO_COMBAT_DAMAGE_PROOF.md','39_NO_ECONOMY_RESOURCE_MUTATION_PROOF.md','40_NO_TRUE_DEFAULT_MUTATION_PROOF.md','41_VISUAL_QUALITY_CONTACT_SHEET.png','42_TECHNICAL_ISOLATION_CONTACT_SHEET.png','43_BLACK_FRAME_REJECTION_REPORT.md'];
const fail = (m) => { throw new Error(`FAIL_V0322: ${m}`); };
const read = (p) => fs.readFileSync(p);
const text = (p) => fs.readFileSync(p, 'utf8');
const exists = (p) => fs.existsSync(p);
function pngSize(buf) { if (buf.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') fail(`not PNG: ${buf}`); return { width: buf.readUInt32BE(16), height: buf.readUInt32BE(20) }; }
const ffmpegDefault = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffmpeg.exe';
const ffprobeDefault = 'C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe';
function probe(file) { return JSON.parse(execFileSync(process.env.FFPROBE || (fs.existsSync(ffprobeDefault) ? ffprobeDefault : 'ffprobe'), ['-v','error','-show_entries','format=format_name,duration:stream=codec_name,width,height,r_frame_rate,nb_frames','-of','json',file], { encoding: 'utf8' })); }
function decodeHashes(file) { const w=160,h=90,size=w*h*3; const raw=execFileSync(process.env.FFMPEG || (fs.existsSync(ffmpegDefault) ? ffmpegDefault : 'ffmpeg'), ['-v','error','-i',file,'-vf',`scale=${w}:${h}:flags=bilinear,format=rgb24`,'-f','rawvideo','-'], { maxBuffer: 64 * 1024 * 1024 }); if(raw.length%size!==0) fail('decoded raw bytes are not whole frames'); const hashes=[]; for(let i=0;i<raw.length;i+=size) hashes.push(crypto.createHash('sha256').update(raw.subarray(i,i+size)).digest('hex')); return hashes; }
function validateMedia() {
  if (!exists(media)) fail('exact UPLOAD_TO_CHAT MP4 missing');
  const bytes=read(media); if (bytes.subarray(4,8).toString('ascii') !== 'ftyp') fail(`uploaded media magic is ${bytes.subarray(0,12).toString('hex')}, not ISO Base Media`);
  const before=crypto.createHash('sha256').update(bytes).digest('hex'); const p=probe(media); const s=(p.streams||[]).find(x=>x.codec_name); if(!s) fail('no decoded video stream');
  const hashes=decodeHashes(media); const duration=Number(p.format?.duration||0); const fps=String(s.r_frame_rate||'0/1').split('/').map(Number); const fpsValue=fps[1] ? fps[0]/fps[1] : fps[0];
  if(duration<10) fail(`duration ${duration} < 10 sec`); if(fpsValue<24) fail(`fps ${fpsValue} < 24`); if(hashes.length<240) fail(`decoded frames ${hashes.length} < 240`); if(new Set(hashes).size<=100) fail('unique decoded hashes <= 100');
  const after=crypto.createHash('sha256').update(read(media)).digest('hex'); if(before!==after) fail('uploaded media changed during validation');
  return { sha256: after, magic: bytes.subarray(0,12).toString('hex'), mime:'video/mp4', container:p.format?.format_name, codec:s.codec_name, width:s.width, height:s.height, durationSeconds:duration, fps:fpsValue, decodedFrameCount:hashes.length, uniqueDecodedFrameHashes:new Set(hashes).size, postValidationHashVerified:true };
}
function validate() {
  if(!exists(scene)||!exists(script)) fail('v0.322 scene/script missing');
  const source=text(script); if(!source.includes('V0322_CHECKPOINT') || !source.includes('prototypeOnly')) fail('prototype opt-in contract missing'); if(source.includes('Sprite3D') || source.includes('QuadMesh') || source.includes('BillboardMesh')) fail('billboard geometry code detected in Route C prototype'); if(!source.includes('V0322AnimatedRiverBelowLand')||!source.includes('V0322GraniteTimberBridge')||!source.includes('V0322PrincipalBarrosanManor')||!source.includes('V0322SecondaryWorkshopStorehouse')) fail('hero composition anchors missing');
  if(!exists(upload)) fail('UPLOAD_TO_CHAT missing'); const names=fs.readdirSync(upload).filter(n=>fs.statSync(path.join(upload,n)).isFile()).sort(); if(names.length!==10||names.join('|')!==required.slice().sort().join('|')) fail(`UPLOAD_TO_CHAT must contain exactly 10 required files; got ${names.join(',')}`);
  const summary=JSON.parse(text(path.join(upload,'compact-evidence-summary.json'))); if(summary.defaultRuntimeChanged||summary.gameplayChanged||summary.movementChanged||summary.pathfindingChanged||summary.combatChanged||summary.economyChanged||summary.resourceChanged) fail('preservation flags are not false'); if(summary.unitPresentation!=='true 3D, no billboards') fail('unit presentation contract missing');
  for(const n of required.filter(n=>n.endsWith('.png'))) { const size=pngSize(read(path.join(upload,n))); if(size.width<640||size.height<360) fail(`${n} is too small`); }
  const audit=validateMedia(); const auditJson=JSON.parse(text(path.join(pack,'full-evidence/continuous-media-audit.json'))); if(auditJson.finalMediaSHA256!==audit.sha256) fail('audit SHA does not match exact upload');
  for(const n of fullEvidenceRequired) if(!exists(path.join(pack,'full-evidence',n))) fail(`missing full-evidence capture ${n}`);
  console.log(JSON.stringify({status:'PASS_V0322_BARROSAN_BRIDGE_HAMLET_HERO_SLICE', exactUploadMedia:audit, compactFileCount:names.length, trueDefaultRuntimeUnchanged:true, gameplayUnchanged:true},null,2));
}
const command=process.argv[2]||'validate'; if(command==='validate-media') { console.log(JSON.stringify(validateMedia(),null,2)); } else if(command==='validate') validate(); else fail(`unknown command ${command}`);
