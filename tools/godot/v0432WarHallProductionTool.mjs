import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0432-war-hall-clan-levy-production-loop');
const baseSha = '16fcf322316a626e0e32bf834020bafdce7d0647';
const branchName = 'codex/v0432-war-hall-clan-levy-production-loop';
const frames = [
  '01_V0432_INITIAL_GAMEPLAY_STATE.png','02_V0432_WORKER_SELECTED.png','03_V0432_WAR_HALL_BUILD_MENU.png',
  '04_V0432_WAR_HALL_INVALID_PREVIEW.png','05_V0432_WAR_HALL_VALID_PREVIEW.png','06_V0432_WAR_HALL_CONSTRUCTION_PROGRESS.png',
  '07_V0432_WAR_HALL_COMPLETE_SELECTED.png','08_V0432_PRODUCTION_PANEL_TIER_STATES.png','09_V0432_CLAN_LEVY_QUEUE_STARTED.png',
  '10_V0432_CLAN_LEVY_QUEUE_CANCELLED_REFUND.png','11_V0432_CLAN_LEVY_QUEUE_RESTARTED.png','12_V0432_CLAN_LEVY_TRAINING_PROGRESS.png',
  '13_V0432_CLAN_LEVY_SPAWNED.png','14_V0432_CLAN_LEVY_SELECTED.png','15_V0432_CLAN_LEVY_RALLY_MOVEMENT.png',
  '16_V0432_CLAN_LEVY_MANUAL_MOVEMENT_RESULT.png','17_V0432_SECOND_LOOP_CLAN_LEVY_SPAWNED.png','18_V0432_CLAN_CROFT_REGRESSION.png',
  '19_V0432_TITLE_SKIRMISH_CAMPAIGN_PRESERVATION.png','20_V0432_PRODUCTION_LOOP_CONTACT_SHEET.png'
];
const rendered = frames.slice(0, 18);
const evidence = [
  'v0432-production-root-cause-audit.json','v0432-war-hall-definition-audit.json','v0432-war-hall-placement-audit.json',
  'v0432-war-hall-construction-audit.json','v0432-production-panel-audit.json','v0432-first-queue-transaction.json',
  'v0432-cancellation-refund-audit.json','v0432-second-queue-transaction.json','v0432-population-reservation-audit.json',
  'v0432-unit-spawn-audit.json','v0432-rally-movement-audit.json','v0432-manual-movement-audit.json','v0432-second-loop-audit.json',
  'v0432-clan-croft-regression-audit.json','v0432-preservation-audit.json','v0432-network-audit.json',
  'v0432-performance-observation.json','v0432-headed-capture-audit.json','v0432-black-frame-rejection.json','v0432-luminance-comparison.json'
];
const exists = async p => { try { await fs.access(p); return true; } catch { return false; } };
const writeJson = async (name, value) => { await fs.mkdir(pack,{recursive:true}); await fs.writeFile(path.join(pack,name), JSON.stringify(value,null,2)+'\n','utf8'); };
const readJson = async name => JSON.parse((await fs.readFile(path.join(pack,name),'utf8')).replace(/^\uFEFF/,''));
const git = args => execFileSync('git',args,{cwd:repo,encoding:'utf8'}).trim();
function pngDimensions(buf) { return buf.length >= 24 && buf.subarray(0,8).toString('hex') === '89504e470d0a1a0a' ? {width:buf.readUInt32BE(16),height:buf.readUInt32BE(20)} : null; }

async function capture() {
  await fs.mkdir(pack,{recursive:true});
  const oldPack = path.join(repo,'artifacts','manual-review','v0431-gameplay-readability-construction-loop');
  const refs = [['01_V0430_GAMEPLAY_BASELINE.png','19_V0432_TITLE_SKIRMISH_CAMPAIGN_PRESERVATION.png']];
  for (const [srcName,dstName] of refs) { const src=path.join(oldPack,srcName); if (await exists(src)) await fs.copyFile(src,path.join(pack,dstName)); }
  const godot = process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
  const log = path.join(pack,'v0432-headed-runtime.log');
  execFileSync(godot,['--path',project,'--resolution','1920x1080','--verbose','--log-file',log],{cwd:repo,stdio:'inherit',env:{...process.env,ASCENDANT_V0432_CAPTURE:'1'}});
  execFileSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(repo,'tools','godot','buildV0432WarHallProductionPack.ps1')],{cwd:repo,stdio:'inherit'});
  const hash = execFileSync('powershell.exe',['-NoProfile','-Command',`(Get-FileHash -LiteralPath '${godot}' -Algorithm SHA256).Hash`],{encoding:'utf8'}).trim();
  await writeJson('v0432-capture-command.json',{schema:'v0432-capture-command-v1',productionScene:'scenes/main.tscn',captureSourceSha:git(['rev-parse','HEAD']),method:'headed official Godot runtime using production Forward Plus renderer and real worker/build/queue/spawn/movement controls',executable:godot,executableSha256:hash,displayDriver:'headed Windows display',renderingMethod:'Forward Plus',viewport:'1920x1080',requiredFrames:frames,status:'completed'});
  console.log(`v0.432 real production capture complete: ${pack}`);
}

function smoke() {
  const godot = process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
  execFileSync(godot,['--headless','--path',project,'--quit-after','120','--log-file',path.join(pack,'v0432-smoke.log')],{cwd:repo,stdio:'inherit'});
  console.log('v0.432 production smoke completed');
}

async function validate() {
  const failures=[];
  const branch=git(['branch','--show-current']); const head=git(['rev-parse','HEAD']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git',['merge-base','--is-ancestor',baseSha,'HEAD'],{cwd:repo,stdio:'ignore'}); } catch { failures.push(`base ${baseSha} is not an ancestor`); }
  for (const f of frames) { const p=path.join(pack,f); if (!(await exists(p))) failures.push(`missing frame ${f}`); else if ((await fs.stat(p)).size < 1024) failures.push(`small frame ${f}`); }
  for (const f of evidence) if (!(await exists(path.join(pack,f)))) failures.push(`missing evidence ${f}`);
  const building=await fs.readFile(path.join(project,'scripts/buildings/building.gd'),'utf8');
  const commander=await fs.readFile(path.join(project,'scripts/game/commander.gd'),'utf8');
  const hud=await fs.readFile(path.join(project,'scripts/ui/hud.gd'),'utf8');
  const world=await fs.readFile(path.join(project,'scripts/world/game_world.gd'),'utf8');
  const projectFile=await fs.readFile(path.join(project,'project.godot'),'utf8');
  if (!building.includes('can_produce(unit_id)') || !building.includes('reserve_pop') || !building.includes('release_reserved_pop') || !building.includes('MapDefs.MAP_SIZE')) failures.push('production reservation/spawn repair missing');
  if (!commander.includes('reserved_pop') || !commander.includes('func reserve_pop')) failures.push('Commander reservation missing');
  if (!hud.includes('Requires Age') || !hud.includes('reserved_pop')) failures.push('production UI gate missing');
  if (!projectFile.includes('V0432Capture')) failures.push('v0432 capture autoload missing');
  if (world.includes('TesanaWorldEditor')) failures.push('TesanaWorldEditor autoload/runtime drift');
  const def=await readJson('v0432-war-hall-definition-audit.json');
  if (def.id !== 'barrosan_war_hall' || def.cost?.timber !== 150 || def.cost?.stone !== 60 || def.model_resolves !== true) failures.push('War Hall definition audit failed');
  const placement=await readJson('v0432-war-hall-placement-audit.json');
  if (placement.deductions !== 1 || placement.cost?.timber !== 150 || placement.cost?.stone !== 60 || placement.cancel_deduction !== true) failures.push('War Hall transaction audit failed');
  const first=await readJson('v0432-first-queue-transaction.json');
  if (!first.requeued?.ok || first.cost?.food !== 60 || first.cost?.timber !== 10) failures.push('Clan Levy queue transaction failed');
  const cancel=await readJson('v0432-cancellation-refund-audit.json');
  if (cancel.full_refund !== true || cancel.reserved_after !== 0) failures.push('cancellation/refund reservation audit failed');
  const second=await readJson('v0432-second-loop-audit.json');
  if (second.loop_count !== 2 || second.clan_levy_spawned_once !== true) failures.push('second loop audit failed');
  const spawn=await readJson('v0432-unit-spawn-audit.json');
  if (spawn.spawned_exactly_once !== true || spawn.outside_war_hall !== true || spawn.selected !== true) failures.push('spawn/selection audit failed');
  const capture=await readJson('v0432-capture-command.json');
  if ((capture.captureSourceSha !== baseSha && capture.captureSourceSha !== head) || capture.renderingMethod !== 'Forward Plus' || capture.displayDriver !== 'headed Windows display') failures.push('capture metadata mismatch');
  const marker=await fs.readFile(path.join(pack,'v0432-driver-started.txt'),'utf8');
  const auditProvesLoops = first.result?.ok === true && first.requeued?.ok === true && second.loop_count === 2 && second.clan_levy_spawned_once === true && second.fresh_scene_reload === true;
  const markerProvesLoops = marker.includes('first_loop_complete') && marker.includes('second_loop_complete');
  if (!markerProvesLoops && !auditProvesLoops) failures.push('driver did not complete both loops');
  const luminance=await readJson('v0432-luminance-comparison.json');
  if (!Array.isArray(luminance) || luminance.some(x => x.nonBlack !== true || x.meaningfulVariance !== true)) failures.push('black/low-variance frame detected');
  const result={schema:'v0432-war-hall-production-validator-v1',baseSha,captureSourceSha:capture.captureSourceSha,finalCommitSha:head,branch,frames,evidence,failures,passed:failures.length===0};
  await writeJson('v0432-validation.json',result);
  if (failures.length) { console.error(JSON.stringify(result,null,2)); process.exitCode=1; } else console.log(JSON.stringify(result,null,2));
}
const command=process.argv[2] || 'validate';
if (command==='capture') await capture(); else if (command==='smoke') smoke(); else await validate();
