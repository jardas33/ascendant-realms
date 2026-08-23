import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-first-complete-conquest-victory');
const baseSha = '642fcb67bf38f1ca76874b33bfb8dd254ee6eeff';
const branchName = 'codex/v0436-first-complete-conquest-victory';
const frames = [
  '01_V0436_REAL_SKIRMISH_INITIAL_STATE.png','02_V0436_PLAYER_WAR_HALL_BUILT.png','03_V0436_PLAYER_ASSAULT_FORCE_READY.png',
  '04_V0436_ENEMY_COMMANDER_TARGET.png','05_V0436_HQ_DAMAGE_AND_COLLAPSE.png','06_V0436_ALL_ENEMY_BUILDINGS_DESTROYED.png',
  '07_V0436_LAST_REBUILD_WORKER_CONTACT.png','08_V0436_VICTORY_RESULT_CONQUEST.png','09_V0436_VICTORY_ENEMIES_DEFEATED.png',
  '10_V0436_VICTORY_BUILDING_KILLS.png','11_V0436_GAME_OVER_FREEZE_ACTIVE.png','12_V0436_RESULT_SNAPSHOT_HUD.png',
  '13_V0436_CONTINUE_BUTTON.png','14_V0436_PLAY_AGAIN_BUTTON.png','15_V0436_FRESH_REPLAY_INITIAL_STATE.png',
  '16_V0436_FRESH_REPLAY_NEW_AI_AND_BANK.png','17_V0436_NO_STALE_RESULT_OR_REWARD.png','18_V0436_FRESH_REPLAY_HUD.png',
  '19_V0436_FRESH_REPLAY_REAL_SCENE.png','20_V0436_CONQUEST_VICTORY_CONTACT_SHEET.png'
];
const evidence = ['v0436-conquest-root-cause-audit.json','v0436-navigation-root-cause-audit.json','v0436-navigation-boundary-contract.json','v0436-invalid-next-point-audit.json','v0436-avoidance-velocity-audit.json','v0436-boundary-recovery-audit.json','v0436-unit-position-watchdog.json','v0436-navigation-regression-audit.json','v0436-match-config-audit.json','v0436-building-damage-audit.json','v0436-building-destruction-audit.json','v0436-queue-refund-population-audit.json','v0436-dropoff-destruction-audit.json','v0436-commander-defeat-audit.json','v0436-conquest-predicate-audit.json','v0436-game-over-idempotence-audit.json','v0436-simulation-freeze-audit.json','v0436-result-snapshot-audit.json','v0436-profile-recording-audit.json','v0436-victory-hud-audit.json','v0436-play-again-replay-audit.json','v0436-continue-button-audit.json','v0436-defeat-symmetry-test-audit.json','v0436-v0435-regression-audit.json','v0436-v0434-regression-audit.json','v0436-v0433-regression-audit.json','v0436-v0432-regression-audit.json','v0436-preservation-audit.json','v0436-network-audit.json','v0436-performance-observation.json','v0436-headed-capture-audit.json','v0436-black-frame-rejection.json','v0436-validation.json'];
const exists = async p => { try { await fs.access(p); return true; } catch { return false; } };
const readJson = async name => JSON.parse(await fs.readFile(path.join(pack, name), 'utf8'));
const writeJson = async (name, value) => { await fs.mkdir(pack, { recursive: true }); await fs.writeFile(path.join(pack, name), JSON.stringify(value, null, 2) + '\n'); };
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
function run(args, env = {}) { execFileSync(godot(), args, { cwd: repo, stdio: 'inherit', env: { ...process.env, ...env } }); }

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  run(['--path', project, '--resolution', '1920x1080', '--verbose', '--log-file', path.join(pack, 'v0436-headed-runtime.log')], { ASCENDANT_V0436_CAPTURE: '1' });
  await writeJson('v0436-capture-command.json', { schema: 'v0436-first-complete-conquest-victory-capture-v1', baseSha, captureSourceSha: git(['rev-parse','HEAD']), branch: git(['branch','--show-current']), productionScene: 'scenes/main.tscn', method: 'headed Godot Forward Plus using RTSController player assault and real production combat/destruction paths', directAiCommands: false, directHpWrites: false, directDeathCalls: false, matchConfig: { playerRace:'barrosan', opponentRace:'lioraen', difficulty:'easy', startResources:'standard', map:'hollowspan', mode:'skirmish', victory:'conquest', gameSpeed:2.0 } });
}
function smoke() { run(['--headless','--path',project,'--quit-after','30','--log-file',path.join(pack,'v0436-smoke.log')]); }
function focused() { run(['--headless','--path',project,'--script','res://tests/v0436_conquest_victory.gd','--quit-after','20']); }
async function validate() {
  const failures = [], head = git(['rev-parse','HEAD']), branch = git(['branch','--show-current']);
  if (branch !== branchName) failures.push(`branch ${branch}`);
  try { execFileSync('git',['merge-base','--is-ancestor',baseSha,'HEAD'],{cwd:repo,stdio:'ignore'}); } catch { failures.push('base SHA is not an ancestor'); }
  if (await exists(path.join(pack,'v0436-capture-failure-audit-attempt-03.json'))) {
    const blocked = { schema:'v0436-first-complete-conquest-victory-validator-v1', baseSha, validationInputSha:head, branch, status:'BLOCKED_PREEXISTING_NAVIGATION_SYSTEM', passed:false, failures:['three repaired headed attempts did not produce a genuine Victory result; stale victory evidence rejected'], failureAudits:['v0436-capture-failure-audit-attempt-01.json','v0436-capture-failure-audit-attempt-02.json','v0436-capture-failure-audit-attempt-03.json'], victoryReviewPackAccepted:false };
    await writeJson('v0436-validation.json', blocked);
    console.error(JSON.stringify(blocked,null,2));
    process.exitCode = 1;
    return;
  }
  for (const f of frames) { const p = path.join(pack,f); if (!(await exists(p))) failures.push(`missing frame ${f}`); else if ((await fs.stat(p)).size < 1024) failures.push(`small frame ${f}`); }
  for (const f of evidence.filter(f => !['v0436-validation.json','v0436-black-frame-rejection.json'].includes(f))) if (!(await exists(path.join(pack,f)))) failures.push(`missing evidence ${f}`);
  const world = await fs.readFile(path.join(project,'scripts/world/game_world.gd'),'utf8');
  const building = await fs.readFile(path.join(project,'scripts/buildings/building.gd'),'utf8');
  const root = await fs.readFile(path.join(project,'scripts/world/game_root.gd'),'utf8');
  const unit = await fs.readFile(path.join(project,'scripts/units/unit.gd'),'utf8');
  const projectFile = await fs.readFile(path.join(project,'project.godot'),'utf8');
  if (!world.includes('match_ended') || !world.includes('result_snapshot') || !world.includes('building_destruction_events')) failures.push('authoritative v0436 world contract missing');
  if (!building.includes('v0436_destroyed_once') || !building.includes('hp_before')) failures.push('building destruction contract missing');
  const captureBootstrap = await fs.readFile(path.join(project, 'tests', 'capture_bootstrap.gd'), 'utf8');
  if (!root.includes('ASCENDANT_V0436_CAPTURE') || !captureBootstrap.includes('ASCENDANT_V0436_CAPTURE') || !captureBootstrap.includes('V0436Capture')) failures.push('capture wiring missing');
  if (!world.includes('playable_bounds_contract') || !world.includes('navigation_watchdog_snapshot')) failures.push('shared navigation boundary/watchdog contract missing');
  if (!unit.includes('invalid_next_path_point') || !unit.includes('boundary_recovery_started') || !unit.includes('rejected_avoidance_velocity')) failures.push('bounded navigation containment source contract missing');
  if (await exists(path.join(pack,'v0436-black-frame-rejection.json'))) { const b = await readJson('v0436-black-frame-rejection.json'); if (b.rejected_black?.length || b.rejected_blank?.length || b.all_real_gameplay !== true) failures.push('black/blank rejection failed'); }
  else failures.push('missing black-frame report');
  if (await exists(path.join(pack,'v0436-validation.json'))) { const v = await readJson('v0436-validation.json'); if (v.victory !== true || v.reason !== 'Conquest' || v.game_over_count !== 1 || v.enemy_defeated !== true) failures.push('runtime conquest proof failed'); }
  else failures.push('missing runtime validation');
  const result = { schema:'v0436-first-complete-conquest-victory-validator-v1', baseSha, validationInputSha:head, branch, frames, evidence, failures, passed: failures.length === 0 };
  await writeJson('v0436-validation.json', result);
  if (failures.length) { console.error(JSON.stringify(result,null,2)); process.exitCode = 1; } else console.log(JSON.stringify(result,null,2));
}
const command = process.argv[2] || 'validate';
if (command === 'capture') await capture(); else if (command === 'smoke') smoke(); else if (command === 'focused-tests') focused(); else await validate();
