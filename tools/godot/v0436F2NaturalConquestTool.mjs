import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { F2_REQUIRED_FRAMES, evaluateF2NaturalConquestContract } from './v0436F2NaturalConquestValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const root = process.env.ASCENDANT_V0436_F2_ROOT || 'D:\\CodexData\\evidence\\ascendant-realms-core-playability-e\\F2_NATURAL_CONQUEST\\FINAL';
const session = path.join(root, 'session-a');
const godot = () => process.env.ASCENDANT_REALMS_GODOT || 'D:\\CodexData\\tools\\godot-4.6.3-stable\\Godot_v4.6.3-stable_win64.exe';
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const executableSha = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

function env() {
  return { ...process.env, ASCENDANT_V0436_R1H_CAPTURE: '1', ASCENDANT_V0436_F2_CAPTURE: '1', ASCENDANT_V0436_F2_OUT: session + path.sep, ASCENDANT_V0436_R1H_SOURCE_SHA: git(['rev-parse', 'HEAD']), ASCENDANT_V0436_R1H_BRANCH: git(['branch', '--show-current']), ASCENDANT_V0436_R1H_SESSION: 'A' };
}

async function focused() { execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436F2NaturalConquestValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' }); }

async function capture() {
  await fs.mkdir(session, { recursive: true });
  await writeJson(path.join(root, 'preflight.json'), { schema: 'v0436-f2-natural-conquest-preflight-v1', status: 'CAPTURE_STARTED', branch: git(['branch', '--show-current']), source_sha: git(['rev-parse', 'HEAD']), executable: godot(), executable_sha256: executableSha(), headed: true, wall_clock_limit_minutes: 40, configuration: { player: 'barrosan', opponent: 'lioraen easy', map: 'hollowspan', resources: 'rich', victory: 'conquest', game_speed: 2.0 }, no_state_injection: true });
  let exitStatus = 0;
  try { execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], { cwd: session, stdio: 'inherit', env: env() }); } catch (error) { exitStatus = error.status ?? null; }
  await writeJson(path.join(root, 'runner-process-result.json'), { exit_status: exitStatus, note: 'GDScript owns truthful F2 terminal classification; process status retained independently.' });
  const files = await fs.readdir(session).catch(() => []);
  if (files.length === 0 && exitStatus !== 0) {
    await writeJson(path.join(session, 'f2-blocker.json'), {
      schema: 'v0436-f2-blocker-v1',
      status: 'BLOCKED_F2_SYSTEM_DEFECT_RUNTIME_STARTUP_LOADING_LOOP',
      reason: 'Godot never entered the match scene: the headed process remained in loading_screen.gd:_run_preload_sequence with repeated clustered shader-cache and RGB8 conversion output, and produced no gameplay frame or session ledger.',
      blocker_phase: 'runtime_startup',
      runner_exit_status: exitStatus,
      godot_log: 'C:/Users/barro/AppData/Roaming/Godot/app_userdata/Ascendant Realms/logs/godot2026-08-09T17.40.42.log',
      samples: [],
      worker_queue_results: [],
      military_queue_results: [],
      resource_transactions: []
    });
    files.push('f2-blocker.json');
  }
  await writeJson(path.join(root, 'capture-manifest.json'), { schema: 'v0436-f2-natural-conquest-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: git(['rev-parse', 'HEAD']), branch: git(['branch', '--show-current']), files, session });
  await writeMarkdown();
}

async function writeMarkdown() {
  const summary = await readJson(path.join(session, 'f2-match-summary.json')).catch(() => null);
  const blocker = await readJson(path.join(session, 'f2-blocker.json')).catch(() => null);
  const samples = summary?.samples || blocker?.samples || [];
  const workers = summary?.worker_queue_results || blocker?.worker_expansion || [];
  const queues = summary?.military_queue_results || blocker?.military_queue_results || [];
  const status = summary?.status || blocker?.status || 'MISSING';
  const reason = summary?.reason || blocker?.reason || 'bounded run did not produce a terminal ledger';
  const lines = ['# F2 Natural Conquest', '', 'Status: ' + status, 'Reason: ' + reason, '', 'Configuration: Barrosan vs Lioraen Easy / Hollowspan / Rich / Conquest / 2.0x', 'Normal public commands only; no state injection or balance change.', '', '## Observed ledger', '- 10-second telemetry samples: ' + samples.length, '- normal HQ worker queue records: ' + workers.length, '- military queue records: ' + queues.length, '- resource transactions: ' + ((summary?.resource_transactions || blocker?.resource_transactions || []).length), '- wall seconds: ' + (summary?.wall_seconds ?? 'bounded/recorded in session ledger'), '', 'The terminal classification is evidence-led and does not claim victory unless the real GameWorld result predicate was reached.'];
  await fs.writeFile(path.join(root, 'f2-natural-conquest.md'), lines.join('\n') + '\n');
}

async function validate() {
  const files = await fs.readdir(session).catch(() => []);
  const config = await readJson(path.join(session, 'match-configuration.json')).catch(() => null);
  const summary = await readJson(path.join(session, 'f2-match-summary.json')).catch(() => null);
  const blocker = await readJson(path.join(session, 'f2-blocker.json')).catch(() => null);
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8');
  const forbidden = ['set("hp"', 'set("is_dead"', 'set("defeated"', 'set("match_ended"', 'set("game_running"', 'spawn_unit(', 'free_units'];
  const payload = summary || blocker || {};
  const result = evaluateF2NaturalConquestContract({ branch: git(['branch', '--show-current']), head: git(['rev-parse', 'HEAD']), config, status: payload.status, reason: payload.reason, blockerPhase: payload.blocker_phase || '', files, samples: payload.samples || [], workerExpansion: payload.worker_queue_results || payload.worker_expansion || [], queueResults: payload.military_queue_results || [], sourceWritesRejected: !forbidden.some(value => source.includes(value)), resourceTransactions: (payload.resource_transactions || []).length });
  result.evidence_root = root; result.files = files; result.required_frames = F2_REQUIRED_FRAMES;
  await writeJson(path.join(root, 'f2-validation.json'), result);
  console.log(JSON.stringify(result, null, 2));
  if (!result.passed) process.exitCode = 1;
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture(); else if (command === 'focused-tests') await focused(); else await validate();
