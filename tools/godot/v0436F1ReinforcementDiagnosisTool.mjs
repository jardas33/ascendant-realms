import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { evaluateF1ReinforcementContract } from './v0436F1ReinforcementDiagnosisValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const root = process.env.ASCENDANT_V0436_F1_ROOT || 'D:\\CodexData\\evidence\\ascendant-realms-core-playability-e\\F1_REINFORCEMENT_DIAGNOSIS';
const session = path.join(root, 'session-a') + path.sep;
const godot = () => process.env.ASCENDANT_REALMS_GODOT || 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe';
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const executableSha = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

function launchEnv() {
  return { ...process.env, ASCENDANT_V0436_R1H_CAPTURE: '1', ASCENDANT_V0436_E1R2_CAPTURE: '1', ASCENDANT_V0436_F1_REINFORCEMENT_CAPTURE: '1', ASCENDANT_V0436_F1_OUT: session, ASCENDANT_V0436_R1H_SOURCE_SHA: git(['rev-parse', 'HEAD']), ASCENDANT_V0436_R1H_BRANCH: git(['branch', '--show-current']), ASCENDANT_V0436_R1H_SESSION: 'A' };
}

async function capture() {
  await fs.mkdir(session, { recursive: true });
  await writeJson(path.join(root, 'preflight.json'), { schema: 'v0436-f1-reinforcement-preflight-v1', status: 'CAPTURE_STARTED', branch: git(['branch', '--show-current']), source_sha: git(['rev-parse', 'HEAD']), executable: godot(), executable_sha256: executableSha(), headed: true, public_configuration: { player_race: 'barrosan', opponent: 'lioraen easy', map: 'hollowspan', resources: 'rich', mode: 'skirmish', victory: 'conquest', game_speed: 2 }, no_player_offense_before_simulation_seconds: 600 });
  let exitStatus = 0;
  try { execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], { cwd: session, stdio: 'inherit', env: launchEnv() }); } catch (error) { exitStatus = error.status ?? null; }
  await writeJson(path.join(root, 'runner-process-result.json'), { exit_status: exitStatus, note: 'GDScript owns truthful F1 status; process status is retained independently.' });
  const files = await fs.readdir(session).catch(() => []);
  await writeJson(path.join(root, 'capture-manifest.json'), { schema: 'v0436-f1-reinforcement-diagnosis-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: git(['rev-parse', 'HEAD']), branch: git(['branch', '--show-current']), files, session });
  await writeMarkdown();
}

async function writeMarkdown() {
  const throughput = await readJson(path.join(session, 'reinforcement-throughput.json')).catch(() => null);
  const blocker = await readJson(path.join(session, 'f1-blocker.json')).catch(() => null);
  const theory = throughput?.theoretical_cost_time?.totals || {};
  const reasons = throughput?.queue_reason_counts || {};
  const lines = ['# F1 Reinforcement Throughput Diagnosis', '', 'Status: ' + (throughput?.status || blocker?.status || 'MISSING'), 'Reason: ' + (throughput?.reason || blocker?.reason || 'missing capture result'), '', '## Configuration', '- Barrosan vs Lioraen Easy', '- Hollowspan / Rich / Conquest / 2.0x', '- No player offense before simulation time 600 seconds', '', '## Authoritative 5 / 10 / 15 theory', '| Count | Food | Timber | Stone | Gold | Base build seconds |', '|---:|---:|---:|---:|---:|---:|'];
  for (const count of ['5', '10', '15']) { const row = theory[count] || {}; lines.push('| ' + count + ' | ' + (row.food ?? 'n/a') + ' | ' + (row.timber ?? 'n/a') + ' | ' + (row.stone ?? 'n/a') + ' | ' + (row.gold ?? 'n/a') + ' | ' + (row.build_time_seconds ?? 'n/a') + ' |'); }
  const resourceTransactions = blocker?.resource_transactions?.length || throughput?.economy_timeline?.at(-1)?.resource_transaction_count || 0;
  lines.push('', '## Observed evidence', '- 10-second simulation samples: ' + (throughput?.samples?.length || 0), '- Queue attempts: ' + (throughput?.queue_results?.length || 0), '- Resource transactions: ' + resourceTransactions, '- Queue reason counts: ' + JSON.stringify(reasons), '', 'The result is a diagnosis of the existing normal public production path. It does not change balance, costs, build times, resources, population, or combat behavior.');
  await fs.writeFile(path.join(root, 'reinforcement-throughput.md'), lines.join('\n') + '\n');
}

async function focused() { execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436F1ReinforcementDiagnosisValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' }); }

async function validate() {
  const throughput = await readJson(path.join(session, 'reinforcement-throughput.json')).catch(() => null);
  const configuration = await readJson(path.join(session, 'match-configuration.json')).catch(() => null);
  const files = await fs.readdir(session).catch(() => []);
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8');
  const result = evaluateF1ReinforcementContract({ branch: git(['branch', '--show-current']), head: git(['rev-parse', 'HEAD']), configuration, throughput, files, sourceWritesRejected: !['set("hp"', 'set("is_dead"', 'set("defeated"', 'spawn_unit(', 'free_units'].some(value => source.includes(value)) });
  result.evidence_root = root;
  result.files = files;
  if (throughput) await fs.copyFile(path.join(session, 'reinforcement-throughput.json'), path.join(root, 'reinforcement-throughput.json'));
  await writeMarkdown();
  await writeJson(path.join(root, 'f1-validation.json'), result);
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') await focused();
else await validate();
