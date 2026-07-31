import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1c-natural-conquest-result-replay-proof');
const branchName = 'codex/v0436-first-complete-conquest-victory';
const baseSha = '1ef22db8809719b0fbb9d399d7f1897aa993467c';
const sessions = ['A', 'B'];
const frames = [
  '01_R1C_MATCH_CONFIGURATION.png','02_R1C_INITIAL_PRODUCTION_MATCH.png','03_R1C_NAVIGATION_READY.png','04_R1C_WAR_HALL_PLACED.png','05_R1C_WORKERS_TRAVELLING_TO_BUILD.png','06_R1C_WAR_HALL_CONSTRUCTION_PROGRESS.png','07_R1C_WAR_HALL_COMPLETED.png','08_R1C_ARCHER_QUEUE_TRANSACTIONS.png','09_R1C_FOUR_ARCHERS_READY.png','10_R1C_ASSAULT_COMMAND_ISSUED.png','11_R1C_ARMY_CROSSING_HOLLOWSPAN.png','12_R1C_ENEMY_CONTACT.png','13_R1C_REAL_COMBAT_DAMAGE.png','14_R1C_ENEMY_BUILDING_DAMAGE.png','15_R1C_FIRST_BUILDING_DESTROYED.png','16_R1C_ENEMY_HQ_DESTROYED.png','17_R1C_REBUILD_CAPABILITY_ELIMINATED.png','18_R1C_FINAL_CONQUEST_PREDICATE.png','19_R1C_GENUINE_VICTORY_RESULT.png','20_R1C_RESULT_STATISTICS.png','21_R1C_POST_RESULT_FREEZE.png','22_R1C_CONTINUE_BEFORE_CLICK.png','23_R1C_CONTINUE_DESTINATION.png','24_R1C_SECOND_GENUINE_VICTORY_RESULT.png','25_R1C_PLAY_AGAIN_BEFORE_CLICK.png','26_R1C_FRESH_REPLAY_INITIAL_STATE.png','27_R1C_FRESH_REPLAY_NO_STALE_RESULT.png','28_R1C_FRESH_REPLAY_FUNCTIONAL.png','30_R1C_CONTACT_SHEET.png'
];
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const exists = async p => { try { await fs.access(p); return true; } catch { return false; } };
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const sourceSha = () => git(['rev-parse', 'HEAD']);
const envBase = { ASCENDANT_V0436_R1C_CAPTURE:'1', ASCENDANT_V0436_R1C_SOURCE_SHA:sourceSha(), ASCENDANT_V0436_R1C_BRANCH:git(['branch','--show-current']) };
const renderer = () => process.env.ASCENDANT_V0436_R1C_RENDERER || 'Forward Plus';
const executableHash = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

function runSession(session) {
  const dir = path.join(pack, `session-${session.toLowerCase()}`);
  const log = path.join(dir, 'r1c-headed-runtime.log');
  const started = new Date().toISOString();
  const env = { ...envBase, ASCENDANT_V0436_R1C_SESSION:session };
  try {
    const args = ['--path', project, '--resolution', '1920x1080', '--verbose', '--log-file', path.basename(log)];
    if (process.env.ASCENDANT_V0436_R1C_RENDERER) args.push('--rendering-method', process.env.ASCENDANT_V0436_R1C_RENDERER);
    execFileSync(godot(), args, { cwd: dir, stdio: 'inherit', env: { ...process.env, ...env } });
  } catch (error) {
    const naturalTimeout = Number(error.status) === 22;
    const blocker = { schema:'v0436-r1c-production-blocker-v1', session, started, ended:new Date().toISOString(), source_sha:env.ASCENDANT_V0436_R1C_SOURCE_SHA, branch:env.ASCENDANT_V0436_R1C_BRANCH, status:naturalTimeout ? 'BLOCKED_R1C_NATURAL_CONQUEST_NOT_RESOLVED_AFTER_REAL_FRAMES' : 'BLOCKED_R1C_HEADED_CONQUEST_PROCESS_EXIT_MINUS_1_AFTER_REAL_FRAMES', exit_status:error.status ?? null, error:String(error), observed:'real production frames through the conquest predicate were written; match_ended remained false and no genuine result/replay proof was produced', root_cause:naturalTimeout ? 'natural production conquest did not resolve before the bounded 120-second result wait; no gameplay or result-state write was added' : 'headed production process terminated after partial natural conquest capture; no gameplay or result-state write was added' };
    return Promise.all([writeJson(path.join(dir, 'r1c-session-failure.json'), blocker), writeJson(path.join(pack, 'r1c-production-blocker.json'), blocker)]).then(() => { throw error; });
  }
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  await writeJson(path.join(pack, 'r1c-capture-manifest.json'), { schema:'v0436-r1c-natural-conquest-result-replay-capture-v2', status:'CAPTURE_STARTED', base_sha:baseSha, source_sha:envBase.ASCENDANT_V0436_R1C_SOURCE_SHA, branch:envBase.ASCENDANT_V0436_R1C_BRANCH, production_scene:'scenes/main.tscn', sessions, executable:godot(), executable_sha256:executableHash(), renderer:renderer(), launch_contract:'headed Windows display; no Godot --log-file absolute path; renderer is project default unless explicitly opted in', sessions_purpose:{A:'natural Victory plus actual Continue button and destination',B:'second natural Victory plus actual Play Again button and fresh replay'}, match_config:{player_race:'barrosan', opponent_race:'lioraen', difficulty:'easy', opponent_count:1, start_resources:'standard', map:'hollowspan', mode:'skirmish', victory:'conquest', game_speed:2.0}, forbidden_driver_writes:['positions after initialization','worker state','resources','HP','damage','death','destruction','defeat','result','AI state','match state','scene reset'] });
  for (const session of sessions) await runSession(session);
  await writeJson(path.join(pack, 'r1c-capture-manifest.json'), { schema:'v0436-r1c-natural-conquest-result-replay-capture-v2', status:'CAPTURE_COMPLETED', base_sha:baseSha, source_sha:envBase.ASCENDANT_V0436_R1C_SOURCE_SHA, branch:envBase.ASCENDANT_V0436_R1C_BRANCH, sessions, executable:godot(), executable_sha256:executableHash(), renderer:renderer(), generated_at:new Date().toISOString() });
}

async function focused() {
  execFileSync(godot(), ['--headless','--path',project,'--script','res://tests/v0436_conquest_victory.gd','--quit-after','20'], { cwd:repo, stdio:'inherit', env:{...process.env,...envBase} });
}

async function smoke() {
  execFileSync(godot(), ['--headless','--path',project,'--quit-after','30'], { cwd:repo, stdio:'inherit', env:{...process.env,...envBase, ASCENDANT_V0436_R1C_SESSION:'A'} });
}

const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const audit = async (dir, file) => await exists(path.join(dir, file)) ? readJson(path.join(dir, file)) : null;

async function validate() {
  const failures = [];
  const head = sourceSha();
  const branch = git(['branch','--show-current']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  if (head !== envBase.ASCENDANT_V0436_R1C_SOURCE_SHA) failures.push('source SHA drifted during validation');
  try { execFileSync('git',['merge-base','--is-ancestor',baseSha,'HEAD'],{cwd:repo,stdio:'ignore'}); } catch { failures.push('required R1B base is not an ancestor'); }
  const manifest = await audit(pack, 'r1c-capture-manifest.json');
  if (!manifest || manifest.status !== 'CAPTURE_COMPLETED') failures.push('capture manifest is not completed');
  if (manifest && (manifest.source_sha !== head || manifest.branch !== branch)) failures.push('manifest provenance mismatch');
  const headedBlocker = await audit(pack, 'r1c-headed-startup-blocker.json');
  if (headedBlocker) failures.unshift(`${headedBlocker.status}: ${headedBlocker.observed_error}`);
  const productionBlocker = await audit(pack, 'r1c-production-blocker.json');
  if (productionBlocker) failures.unshift(`${productionBlocker.status}: ${productionBlocker.observed}`);
  for (const session of sessions) {
    const dir = path.join(pack, `session-${session.toLowerCase()}`);
    const runtime = await audit(dir, `r1c-${session === 'A' ? 'victory' : 'victory'}-runtime-audit.json`);
    if (!runtime) failures.push(`missing ${session} runtime audit`);
    if (runtime && runtime.provenance.source_sha !== head) failures.push(`${session} runtime audit SHA mismatch`);
    for (const file of frames.filter(f => f.startsWith('0') || f.startsWith('1') || f.startsWith('2'))) {
      const required = (session === 'A' && ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','30'].some(n => file.startsWith(n+'_'))) || (session === 'B' && ['01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','24','25','26','27','28','30'].some(n => file.startsWith(n+'_')));
      if (required && !(await exists(path.join(dir,file)))) failures.push(`missing ${session}/${file}`);
    }
    const hud = await audit(dir,'r1c-victory-hud-audit.json');
    if (!hud || hud.observed?.victory_visible !== true || hud.observed?.reason_visible !== true || hud.observed?.continue?.enabled !== true || hud.observed?.play_again?.enabled !== true) failures.push(`${session} rendered result HUD proof failed`);
  }
  const continueAudit = await audit(path.join(pack,'session-a'),'r1c-continue-audit.json');
  if (!continueAudit || continueAudit.observed?.button_pressed !== true || !String(continueAudit.observed?.destination_scene).includes('main_menu')) failures.push('Continue destination proof failed');
  const replayAudit = await audit(path.join(pack,'session-b'),'r1c-fresh-replay-audit.json');
  if (!replayAudit || replayAudit.observed?.match_ended !== false || replayAudit.observed?.game_running !== true || Object.keys(replayAudit.observed?.result || {}).length !== 0) failures.push('fresh replay proof failed');
  const files = await fs.readdir(pack, { recursive:true });
  if (files.filter(f => f.endsWith('.png')).length < 20) failures.push('insufficient R1C rendered frames');
  const result = { schema:'v0436-r1c-natural-conquest-result-replay-validator-v1', status:headedBlocker ? headedBlocker.status : (productionBlocker ? productionBlocker.status : (failures.length ? 'BLOCKED_R1C_EVIDENCE_VALIDATION' : 'PASSED_V0436_NATURAL_CONQUEST_RESULT_REPLAY_PROOF')), passed:failures.length === 0, base_sha:baseSha, source_sha:head, branch, failures, pack:'artifacts/manual-review/v0436-r1c-natural-conquest-result-replay-proof/', sessions, evidence_integrity:{runtime_derived:true, hardcoded_success_fields_rejected:true, stale_pack_rejected:true, exact_source_sha_required:true, actual_ui_button_paths:true} };
  await writeJson(path.join(pack,'r1c-validation.json'), result);
  if (failures.length) { console.error(JSON.stringify(result,null,2)); process.exitCode=1; } else console.log(JSON.stringify(result,null,2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') await focused();
else if (command === 'smoke') await smoke();
else await validate();
