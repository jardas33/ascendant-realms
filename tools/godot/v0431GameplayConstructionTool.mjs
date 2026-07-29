import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {execFileSync} from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0431-gameplay-readability-construction-loop');
const basePack = path.join(repo, 'artifacts', 'manual-review', 'v0430-tesana-canonical-production-rebase');
const baseSha = '044a14de65c4b1308a21f402d04f89b881f291a6';
const requiredFrames = [
  '01_V0430_GAMEPLAY_BASELINE.png','02_V0431_GAMEPLAY_READABILITY_AFTER.png','03_V0430_V0431_MATCHED_GAMEPLAY_COMPARISON.png',
  '04_V0431_WORKER_SELECTED.png','05_V0431_WORKER_MOVEMENT_DESTINATION.png','06_V0431_CLAN_CROFT_BUILD_MENU.png',
  '07_V0431_CLAN_CROFT_VALID_PREVIEW.png','08_V0431_CLAN_CROFT_INVALID_PREVIEW.png','09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png',
  '10_V0431_CONSTRUCTION_EARLY_PROGRESS.png','11_V0431_CONSTRUCTION_LATE_PROGRESS.png','12_V0431_CLAN_CROFT_COMPLETE.png',
  '13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png','14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png','15_V0431_TITLE_PRESERVATION.png',
  '16_V0431_SKIRMISH_PRESERVATION.png','17_V0431_CAMPAIGN_PRESERVATION.png','18_V0431_GAMEPLAY_CONSTRUCTION_CONTACT_SHEET.png'
];
const requiredRenderedFrames = [
  '02_V0431_GAMEPLAY_READABILITY_AFTER.png','04_V0431_WORKER_SELECTED.png','05_V0431_WORKER_MOVEMENT_DESTINATION.png',
  '06_V0431_CLAN_CROFT_BUILD_MENU.png','07_V0431_CLAN_CROFT_VALID_PREVIEW.png','08_V0431_CLAN_CROFT_INVALID_PREVIEW.png',
  '09_V0431_PLACEMENT_CONFIRMED_RESOURCE_DEDUCTION.png','10_V0431_CONSTRUCTION_EARLY_PROGRESS.png',
  '11_V0431_CONSTRUCTION_LATE_PROGRESS.png','12_V0431_CLAN_CROFT_COMPLETE.png','13_V0431_COMPLETED_CLAN_CROFT_SELECTED.png',
  '14_V0431_REPLAY_SECOND_LOOP_COMPLETE.png'
];
const evidence = ['v0431-gameplay-visual-root-cause-audit.json','v0431-luminance-comparison.json','v0431-environment-settings-before-after.json',
  'v0431-first-playthrough-input-trace.json','v0431-second-playthrough-input-trace.json','v0431-worker-movement-audit.json',
  'v0431-placement-validation-audit.json','v0431-resource-transaction-audit.json','v0431-construction-state-audit.json',
  'v0431-navigation-collision-audit.json','v0431-menu-campaign-preservation-audit.json','v0431-original-source-preservation-audit.json',
  'v0431-network-audit.json','v0431-performance-observation.json','v0431-headed-capture-audit.json',
  'v0431-black-frame-rejection.json'];

async function exists(p) { try { await fs.access(p); return true; } catch { return false; } }
async function writeJson(name, value) { await fs.mkdir(pack, {recursive:true}); await fs.writeFile(path.join(pack,name), JSON.stringify(value,null,2)+'\n','utf8'); }
async function readJson(name) { return JSON.parse((await fs.readFile(path.join(pack,name),'utf8')).replace(/^\uFEFF/, '')); }
function git(args) { return execFileSync('git', args, {cwd:repo, encoding:'utf8'}).trim(); }
function readPngDimensions(buffer) {
  if (buffer.length < 24 || buffer.subarray(0, 8).toString('hex') !== '89504e470d0a1a0a') return null;
  return {width: buffer.readUInt32BE(16), height: buffer.readUInt32BE(20)};
}

async function capture() {
  await fs.mkdir(pack, {recursive:true});
  const baseline = path.join(basePack, '07_PRODUCTION_GAMEPLAY_INITIAL_STATE.png');
  const title = path.join(basePack, '01_PRODUCTION_TITLE_SCREEN.png');
  const setup = path.join(basePack, '02_PRODUCTION_SKIRMISH_SETUP.png');
  const campaign = path.join(basePack, '05_PRODUCTION_CAMPAIGN_MAP.png');
  // These are real production frames from the immediately preceding candidate;
  // only the baseline/preservation references are seeded here. Gameplay frames
  // are deliberately fail-closed until the headed v0.431 loop writes them.
  for (const [src,dst] of [[baseline,'01_V0430_GAMEPLAY_BASELINE.png'],[title,'15_V0431_TITLE_PRESERVATION.png'],[setup,'16_V0431_SKIRMISH_PRESERVATION.png'],[campaign,'17_V0431_CAMPAIGN_PRESERVATION.png']]) {
    if (await exists(src)) await fs.copyFile(src,path.join(pack,dst));
  }
  const godot = process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
  const captureLog = path.join(pack, 'v0431-headed-runtime.log');
  await fs.rm(captureLog, {force:true});
  // Visual evidence must come from the actual headed production renderer. The
  // driver owns its bounded lifetime and quits after the real scene completes;
  // do not use --quit-after here because that counts frames and can terminate
  // during the title-to-battle transition.
  execFileSync(godot,['--path',project,'--resolution','1920x1080','--verbose','--log-file',captureLog],{cwd:repo,stdio:'inherit',env:{...process.env,ASCENDANT_V0431_CAPTURE:'1'}});
  execFileSync('powershell.exe',['-NoProfile','-ExecutionPolicy','Bypass','-File',path.join(repo,'tools','godot','buildV0431GameplayConstructionPack.ps1')],{cwd:repo,stdio:'inherit'});
  await writeJson('v0431-capture-command.json',{schema:'v0431-capture-command-v3',productionScene:'scenes/main.tscn',
    method:'headed official Godot runtime using production Forward Plus renderer; capture driver over real GameWorld, RTSController, HUD, Unit and Building runtime nodes; no final-state injection',
    executable:godot,displayDriver:'headed Windows display',renderingMethod:'Forward Plus',viewport:'1920x1080',requiredFrames,
    seededReferences:['01_V0430_GAMEPLAY_BASELINE.png'],runtimeLog:'v0431-headed-runtime.log',status:'completed'});
  console.log(`v0.431 real production capture complete: ${pack}`);
}

function smoke() {
  const godot = process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
  execFileSync(godot,['--headless','--path',project,'--quit-after','120','--log-file',path.join(pack,'v0431-smoke.log')],{cwd:repo,stdio:'inherit'});
  console.log('v0.431 production smoke completed');
}

async function validate() {
  const failures=[];
  const branch=git(['branch','--show-current']);
  const head=git(['rev-parse','HEAD']);
  if (branch !== 'codex/v0431-gameplay-readability-construction-loop') failures.push(`branch ${branch}`);
  try { execFileSync('git', ['merge-base','--is-ancestor',baseSha,'HEAD'], {cwd:repo, stdio:'ignore'}); }
  catch { failures.push(`v0.430 base ${baseSha} is not an ancestor of HEAD ${head}`); }
  if (!(await exists(project))) failures.push('production project missing');
  for (const f of requiredFrames) {
    const p=path.join(pack,f); if (!(await exists(p))) failures.push(`missing capture ${f}`);
    else if ((await fs.stat(p)).size < 1024) failures.push(`capture too small ${f}`);
    else if (requiredRenderedFrames.includes(f)) { const dimensions=readPngDimensions(await fs.readFile(p)); if (!dimensions || dimensions.width < 1920 || dimensions.height < 1000) failures.push(`invalid rendered capture dimensions ${f}: ${JSON.stringify(dimensions)}`); }
  }
  for (const f of evidence) if (!(await exists(path.join(pack,f)))) failures.push(`missing evidence ${f}`);
  const world=await fs.readFile(path.join(project,'scripts/world/game_world.gd'),'utf8');
  const rts=await fs.readFile(path.join(project,'scripts/world/rts_controller.gd'),'utf8');
  if (!world.includes('v0431_transaction_id') || !world.includes('get_v0431_construction_audit')) failures.push('construction audit hooks missing');
  if (!world.includes('tonemap_white = 3.2') || !world.includes('glow_enabled = false')) failures.push('readability environment correction missing');
  if (!rts.includes('can_afford') || !rts.includes('enter_build_mode')) failures.push('real placement path not present');
  const productionProject=await fs.readFile(path.join(project,'project.godot'),'utf8');
  if (productionProject.includes('TesanaWorldEditor')) failures.push('TesanaWorldEditor autoload remains in production project');
  const captureCommand=await readJson('v0431-capture-command.json');
  if (captureCommand.renderingMethod !== 'Forward Plus' || captureCommand.displayDriver !== 'headed Windows display') failures.push('capture command is not headed Forward Plus');
  if (String(captureCommand.method).toLowerCase().includes('headless') || String(captureCommand.method).toLowerCase().includes('gl_compatibility')) failures.push('visual capture command advertises headless/compatibility rendering');
  const captureAudit=await readJson('v0431-headed-capture-audit.json');
  if (captureAudit.processExitStatus !== 0 || captureAudit.renderingMethod !== 'Forward Plus' || captureAudit.viewport !== '1920x1080') failures.push('headed capture audit did not pass');
  const luminance=await readJson('v0431-luminance-comparison.json');
  if (!Array.isArray(luminance) || luminance.some((entry) => entry.nonBlack !== true || entry.meaningfulVariance !== true)) failures.push('black/low-variance gameplay capture detected');
  const construction=await readJson('v0431-construction-state-audit.json');
  if (construction.loop_count !== 2 || construction.first_loop?.completed_count !== 1 || construction.second_loop?.completed_count !== 1) failures.push('two-loop construction audit incomplete');
  for (const loopName of ['first_loop','second_loop']) {
    const tx=construction[loopName]?.transactions?.[0];
    if (!tx || tx.building_id !== 'barrosan_clan_croft' || tx.deductions !== 1 || tx.cost?.timber !== 60 || tx.cost?.stone !== 20 || tx.resources_before?.timber !== 300 || tx.resources_after?.timber !== 240 || tx.resources_before?.stone !== 180 || tx.resources_after?.stone !== 160 || tx.completed !== true) failures.push(`${loopName} construction transaction contract failed`);
  }
  const marker=await fs.readFile(path.join(pack,'v0431-driver-started.txt'),'utf8');
  if (!marker.includes('second_loop')) failures.push('capture driver did not complete fresh second loop');
  for (const stale of ['00_desktop.png','01_window.png','02_gameplay_try.png']) if (await exists(path.join(pack,stale))) failures.push(`rejected desktop diagnostic remains: ${stale}`);
  const result={schema:'v0431-production-gameplay-construction-validator-v1',baseSha,branch,head,requiredFrames,requiredRenderedFrames,evidence,failures,passed:failures.length===0};
  await writeJson('v0431-validation.json',result);
  if (failures.length) { console.error(JSON.stringify(result,null,2)); process.exitCode=1; }
  else console.log(JSON.stringify(result,null,2));
}

const command=process.argv[2]||'validate';
if (command==='capture') await capture();
else if (command==='smoke') smoke();
else await validate();
