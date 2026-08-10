import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { evaluateK1BeginnerEconomyContract } from './v0436K1BeginnerEconomyValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const root = process.env.ASCENDANT_V0436_K1_ROOT || 'D:\\CodexData\\evidence\\ascendant-realms-playtest3-continuation-k';
const godot = () => process.env.ASCENDANT_REALMS_GODOT || 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe';
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const executableSha = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

function launchEnv() {
  return { ...process.env, ASCENDANT_V0436_R1H_CAPTURE: '1', ASCENDANT_V0436_E1R2_CAPTURE: '1', ASCENDANT_V0436_K1_BEGINNER_ECONOMY_CAPTURE: '1', ASCENDANT_V0436_K1_OUT: root + path.sep, ASCENDANT_V0436_R1H_SOURCE_SHA: git(['rev-parse', 'HEAD']), ASCENDANT_V0436_R1H_BRANCH: git(['branch', '--show-current']), ASCENDANT_V0436_R1H_SESSION: 'A' };
}

async function capture() {
  await fs.mkdir(root, { recursive: true });
  await writeJson(path.join(root, 'preflight.json'), { schema: 'v0436-k1-beginner-economy-preflight-v1', status: 'CAPTURE_STARTED', branch: git(['branch', '--show-current']), source_sha: git(['rev-parse', 'HEAD']), executable: godot(), executable_sha256: executableSha(), headed: true, public_configuration: { player_race: 'barrosan', opponent: 'lioraen easy', map: 'hollowspan', resources: 'rich', mode: 'skirmish', victory: 'conquest', game_speed: 2 }, no_player_offense_before_simulation_seconds: 600 });
  let exitStatus = 0;
  try { execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], { cwd: root, stdio: 'inherit', env: launchEnv() }); } catch (error) { exitStatus = error.status ?? null; }
  await writeJson(path.join(root, 'runner-process-result.json'), { exit_status: exitStatus, note: 'GDScript owns truthful K1 status; process status is retained independently.' });
  const files = await fs.readdir(root).catch(() => []);
  await writeJson(path.join(root, 'capture-manifest.json'), { schema: 'v0436-k1-beginner-economy-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: git(['rev-parse', 'HEAD']), branch: git(['branch', '--show-current']), files, root });
  await writeMarkdown();
}

async function writeMarkdown() {
  const benchmark = await readJson(path.join(root, 'k1-benchmark.json')).catch(() => null);
  const final = benchmark?.final || {};
  const lines = ['# K1 Beginner Economy Driver Benchmark', '', `Status: ${benchmark?.status || 'MISSING'}`, `Reason: ${benchmark?.reason || 'missing capture result'}`, '', '## Contract', '- Barrosan vs Lioraen Easy / Hollowspan / Rich / Conquest / 2.0x', '- public actions only; no player offense before simulation time 600 seconds', '- five-second economy and production samples', '', '## Final predicates', `- Workers: ${final.workers_total ?? 'n/a'}`, `- Housing: ${final.housing_count ?? 'n/a'}`, `- Completed War Hall: ${final.war_hall_built ?? 'n/a'}`, `- Completed combat units: ${final.completed_combat_units ?? 'n/a'}`, `- Resource transactions: ${final.resource_transaction_count ?? 'n/a'}`, `- Player offense count: ${final.player_offense_count ?? 'n/a'}`, '', 'The benchmark uses the existing public placement, worker, gather, HQ queue, and War Hall queue paths. It does not change production balance or combat behavior.'];
  await fs.writeFile(path.join(root, 'k1-benchmark.md'), lines.join('\n') + '\n');
}

async function validate() {
  const benchmark = await readJson(path.join(root, 'k1-benchmark.json')).catch(() => null);
  const configuration = await readJson(path.join(root, 'k1-match-configuration.json')).catch(() => null);
  const files = await fs.readdir(root).catch(() => []);
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8');
  const result = evaluateK1BeginnerEconomyContract({ benchmark, configuration, files, source });
  result.evidence_root = root;
  result.branch = git(['branch', '--show-current']);
  result.head = git(['rev-parse', 'HEAD']);
  result.godot = godot();
  result.godot_sha256 = executableSha();
  await writeMarkdown();
  await writeJson(path.join(root, 'k1-validation.json'), result);
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

async function focused() {
  const result = evaluateK1BeginnerEconomyContract({ benchmark: { status: 'PASS_K1_BEGINNER_ECONOMY_DRIVER', samples_every_simulation_seconds: 5, samples: Array(10), action_trace: ['TRAIN_WORKER', 'ASSIGN_WORKER', 'BUILD_HOUSING', 'BUILD_WAR_HALL', 'QUEUE_MILITARY', 'BUILD_MORE_HOUSING', 'QUEUE_NEXT_MILITARY'], final: { workers_total: 6, peak_workers: 6, war_hall_built: true, housing_count: 1, completed_combat_units: 5, player_offense_count: 0 }, public_actions_only: true, state_injection: false }, configuration: { observed: { player_race: 'barrosan', map: 'hollowspan', start_resources: 'rich', mode: 'skirmish', victory: 'conquest' } }, files: ['01_K1_OPENING_BASELINE.png', '02_K1_ECONOMY_AND_FORCE_READY.png', 'k1-benchmark.json', 'k1-blocker.json', 'k1-match-configuration.json'], source: '' });
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') await focused();
else await validate();
