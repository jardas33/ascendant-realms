import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const repo = process.cwd();
const scene = path.join(repo, 'desktop-spikes/godot-salto/scenes/v0373_autonomous_visual_direction_rts_sector.tscn');
const script = path.join(repo, 'desktop-spikes/godot-salto/scripts/v0373_autonomous_visual_direction_rts_sector.gd');
const rootScript = path.join(repo, 'desktop-spikes/godot-salto/scripts/salto_spike_root.gd');
const packageJson = path.join(repo, 'package.json');
const report = path.join(repo, 'docs/V0373_AUTONOMOUS_VISUAL_DIRECTION_RTS_SCENE_RECOVERY_REPORT.md');
const audit = path.join(repo, 'artifacts/work/v0373-internal-visual-audit.md');
const pack = path.join(repo, 'artifacts/manual-review/v0373-autonomous-visual-direction');
const raw = path.join(repo, 'artifacts/runtime/v0373');
const intake = path.join(repo, 'desktop-spikes/godot-salto/assets/third_party/quaternius/v0370');
const smoke = path.join(raw, 'v0373-autonomous-visual-direction-smoke.json');
const packFiles = ['00_READ_ME_FIRST.md','01_FINAL_PRIMARY_RTS_COMPOSITION.png','02_FINAL_SETTLEMENT_AND_RESOURCE.png','03_FINAL_BRIDGE_AND_HOSTILE_CAMP.png','04_FINAL_TOPDOWN_SPACING_AUDIT.png','05_SELF_REVIEW_SCORECARD.md','06_VALIDATION.json'];

const mustExist = (file, label) => { if (!fs.existsSync(file)) throw new Error(`missing ${label}: ${path.relative(repo, file)}`); };
const text = (file) => fs.readFileSync(file, 'utf8');
const includes = (value, needle, label) => { if (!value.includes(needle)) throw new Error(`${label} missing: ${needle}`); };
const no = (value, needle, label) => { if (value.includes(needle)) throw new Error(`${label} contains forbidden token: ${needle}`); };
const png = (file) => { const b = fs.readFileSync(file); if (b.length < 24 || b.toString('ascii',1,4) !== 'PNG') throw new Error(`not a PNG: ${path.basename(file)}`); return {width:b.readUInt32BE(16),height:b.readUInt32BE(20),bytes:b.length}; };

function retainedClean() {
  for (const file of ['desktop-spikes/godot-salto/scenes/v0370_quaternius_visual_proof.tscn','desktop-spikes/godot-salto/scripts/v0370_quaternius_visual_proof.gd','desktop-spikes/godot-salto/scenes/v0371_first_cohesive_quaternius_rts_sector.tscn','desktop-spikes/godot-salto/scripts/v0371_first_cohesive_quaternius_rts_sector.gd','desktop-spikes/godot-salto/scenes/v0372_quaternius_rts_visual_recovery.tscn','desktop-spikes/godot-salto/scripts/v0372_quaternius_rts_visual_recovery.gd']) {
    try { execFileSync('git',['diff','--quiet','--',file],{cwd:repo,stdio:'ignore'}); } catch { throw new Error(`retained scene/script has a worktree diff: ${file}`); }
  }
}

function validatePack() {
  mustExist(pack,'human review pack');
  const names = fs.readdirSync(pack).filter(n => fs.statSync(path.join(pack,n)).isFile()).sort();
  if (names.length !== packFiles.length || names.some((n,i)=>n !== [...packFiles].sort()[i])) throw new Error(`review pack must contain exactly seven files; found ${names.join(', ')}`);
  for (const name of packFiles) { const file = path.join(pack,name); mustExist(file,`pack file ${name}`); if (name.endsWith('.png')) { const d=png(file); if(d.width!==1920||d.height!==1080||d.bytes<100000) throw new Error(`${name} is not a rendered 1920x1080 frame`); } }
  const readme = text(path.join(pack,'00_READ_ME_FIRST.md')); includes(readme,'READY FOR HUMAN V0373 AUTONOMOUS VISUAL-DIRECTION REVIEW','README'); no(readme,'accepted','README');
  const score = text(path.join(pack,'05_SELF_REVIEW_SCORECARD.md')); includes(score,'Total score:','scorecard'); includes(score,'Visual iterations:','scorecard');
  const manifest = JSON.parse(text(path.join(pack,'06_VALIDATION.json'))); if (manifest.status !== 'READY_FOR_HUMAN_REVIEW' || manifest.packFiles !== 7) throw new Error('validation manifest is not human-review ready');
}

function packManifest() {
  fs.mkdirSync(pack,{recursive:true});
  const captures = packFiles.filter(n=>n.endsWith('.png')).map(n=>({file:n,...png(path.join(pack,n)),rendered:true}));
  fs.writeFileSync(path.join(pack,'06_VALIDATION.json'),JSON.stringify({checkpoint:'v0.373',status:'READY_FOR_HUMAN_REVIEW',primary:captures[0],captures,packFiles:7,hud:false,gameplay:false,defaultRuntime:'unchanged',selfReviewRequired:true},null,2)+'\n','utf8');
}

function validate() {
  for (const [file,label] of [[scene,'isolated scene'],[script,'scene script'],[rootScript,'route script'],[packageJson,'package'],[report,'report'],[audit,'internal audit']]) mustExist(file,label);
  const pkg = JSON.parse(text(packageJson)); for(const key of ['godot:play:autonomous-visual-direction','godot:smoke:autonomous-visual-direction','godot:capture:autonomous-visual-direction','godot:validate:autonomous-visual-direction']) if(!pkg.scripts?.[key]) throw new Error(`missing package command: ${key}`);
  const s=text(scene), g=text(script), r=text(rootScript); includes(s,'V0373AutonomousVisualDirectionRtsSector','scene'); includes(g,'Camera3D.PROJECTION_ORTHOGONAL','camera'); includes(g,'One_Continuous_Recessed_River','river'); includes(g,'Central_Timber_Bridge','bridge'); includes(g,'Hostile_Territory_Camp','camp'); includes(g,'Worked_Resource_Yard','resource'); includes(g,'seed(373)','determinism'); includes(r,'--v0373-autonomous-visual-direction','route'); includes(r,'v0373_autonomous_visual_direction_rts_sector.tscn','route scene'); includes(r,'v0368_playable_slice_visual_coherence.tscn','default route retained');
  for(const forbidden of ['CanvasLayer','Label3D','Control.new()','NavigationAgent3D','CharacterBody3D','AnimationPlayer','Area3D','v0368_playable_slice_visual_coherence.gd']) no(g,forbidden,'world-only scene');
  mustExist(intake,'Quaternius intake'); for(const asset of [...new Set([...g.matchAll(/"([^"\n]+\.gltf)"/g)].map(m=>m[1]))]) mustExist(path.join(intake,asset),`asset ${asset}`);
  retainedClean(); if(fs.existsSync(smoke)){const m=JSON.parse(text(smoke));if(m.status!=='PASS'||m.hud!==false||m.gameplay!==false) throw new Error('smoke is not clean');}
  const rt=text(report); includes(rt,'true default runtime','report'); includes(rt,'v0.370','report'); includes(rt,'v0.371','report'); includes(rt,'v0.372','report');
  if (rt.includes('BLOCKED — V0373 VISUAL QUALITY GATE NOT MET')) {
    if (fs.existsSync(pack)) throw new Error('blocked result must not create a human review pack');
    includes(rt,'artifacts/work/v0373-internal-visual-audit.md','blocked report');
    includes(rt,'34/60','blocked score');
    console.log('BLOCKED_V0373_VISUAL_QUALITY_GATE_NOT_MET');
    return;
  }
  validatePack(); console.log('PASS_V0373_AUTONOMOUS_VISUAL_DIRECTION');
}

const command=process.argv[2]??'validate'; if(command==='pack') packManifest(); else if(command==='validate') validate(); else throw new Error(`unsupported command: ${command}`);
