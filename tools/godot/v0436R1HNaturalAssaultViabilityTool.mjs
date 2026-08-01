import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import {
  REQUIRED_R1H_BRANCH,
  R1H_PACK,
  REQUIRED_R1H_FRAMES,
  SUCCESS_R1H_FRAMES,
  evaluateR1HValidatorContract,
} from './v0436R1HValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, R1H_PACK);
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const sourceSha = () => git(['rev-parse', 'HEAD']);
const branch = () => git(['branch', '--show-current']);
const isAncestor = sha => { try { execFileSync('git', ['merge-base', '--is-ancestor', sha, sourceSha()], { cwd: repo, stdio: 'ignore' }); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const executableSha = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

function launchEnv(session) {
  return {
    ...process.env,
    ASCENDANT_V0436_R1H_CAPTURE: '1',
    ASCENDANT_V0436_R1H_SOURCE_SHA: sourceSha(),
    ASCENDANT_V0436_R1H_BRANCH: branch(),
    ASCENDANT_V0436_R1H_SESSION: session,
  };
}

function launch(session) {
  const cwd = path.join(pack, `session-${session.toLowerCase()}`);
  return execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], {
    cwd,
    stdio: 'inherit',
    env: launchEnv(session),
  });
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  const executable = godot();
  await writeJson(path.join(pack, 'preflight.json'), {
    schema: 'v0436-r1h-preflight-v1',
    status: 'CAPTURE_STARTED',
    branch: branch(),
    source_sha: sourceSha(),
    upstream: git(['rev-parse', '--abbrev-ref', '@{u}']),
    executable,
    executable_sha256: executableSha(),
    renderer: 'project-default Forward Plus',
    launch_contract: 'headed Windows display; runner-owned stdout/stderr; no Godot --log-file; real production scenes/main.tscn -> scenes/game_world.tscn',
    match_configuration: { player_race: 'barrosan', opponent_race: 'lioraen', difficulty: 'easy', map: 'hollowspan', start_resources: 'standard', mode: 'skirmish', victory: 'conquest', game_speed: 2.0 },
    evidence_policy: 'truthful live evidence; blocker status is valid only when success-only frames are absent',
  });
  await writeJson(path.join(pack, 'executable-provenance.json'), { executable, version: 'Godot 4.3 stable', sha256: executableSha(), renderer: 'Forward Plus', headed: true, hidden_window: false, log_owner: 'R1H runner stdout/stderr' });
  await writeJson(path.join(pack, 'launch-contract.json'), { production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', command: 'Godot --path production/ascendant-realms-godot --resolution 1920x1080 --verbose', forbidden: ['--log-file', 'headless evidence', 'hidden-window evidence', 'direct gameplay state writes', 'free units', 'resource injection'] });
  await writeJson(path.join(pack, 'match-configuration.json'), { player: 'barrosan', opponent: 'one Lioraen Easy opponent', map: 'hollowspan', resources: 'standard', victory: 'conquest', mode: 'skirmish', game_speed: 2.0, sessions: ['A', 'B'], force_plan: ['barrosan_spear_guard', 'barrosan_spear_guard', 'barrosan_crag_archer', 'barrosan_crag_archer'] });
  for (const session of ['A', 'B']) {
    await fs.mkdir(path.join(pack, `session-${session.toLowerCase()}`), { recursive: true });
    try { launch(session); } catch (error) {
      await writeJson(path.join(pack, 'runner-process-result.json'), { session, exit_status: error.status ?? null, note: 'GDScript owns truthful blocker classification; nonzero process exit is retained for diagnosis.' });
      throw error;
    }
  }
  await writeJson(path.join(pack, 'capture-manifest.json'), { schema: 'v0436-r1h-natural-player-assault-viability-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), branch: branch(), sessions: ['A', 'B'], pack: R1H_PACK });
}

function focused() {
  execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436R1HValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' });
}

function smoke() {
  execFileSync(godot(), ['--headless', '--path', project, '--quit-after', '30'], { cwd: repo, stdio: 'inherit', env: launchEnv('A') });
}

async function sessionInfo(session) {
  const dir = path.join(pack, `session-${session.toLowerCase()}`);
  const names = await fs.readdir(dir).catch(() => []);
  const blocker = await readJson(path.join(dir, 'r1h-blocker.json')).catch(() => null);
  const finalState = await readJson(path.join(dir, 'r1h-final-state.json')).catch(() => null);
  return { dir, names, blocker, finalState };
}

async function validate() {
  const failures = [];
  const head = sourceSha();
  const currentBranch = branch();
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8').catch(() => '');
  for (const forbidden of ['--log-file', 'set("hp"', 'set("is_dead"', 'set("defeated"', 'set("match_ended"', 'set("game_running"', 'Engine.time_scale', 'spawn_unit(']) {
    if (source.includes(forbidden)) failures.push(`forbidden capture pattern: ${forbidden}`);
  }
  const rootRequiredNames = ['preflight.json', 'executable-provenance.json', 'launch-contract.json', 'match-configuration.json', 'capture-manifest.json'];
  const rootRequiredFiles = [];
  for (const name of rootRequiredNames) {
    const present = await exists(path.join(pack, name));
    rootRequiredFiles.push({ name, present });
    if (!present) failures.push(`missing root review-pack file ${name}`);
  }
  const provenance = await readJson(path.join(pack, 'preflight.json')).catch(() => null);
  const manifest = await readJson(path.join(pack, 'capture-manifest.json')).catch(() => null);
  if (!provenance || provenance.branch !== currentBranch || !isAncestor(String(provenance.source_sha || ''))) failures.push('preflight provenance mismatch');
  if (!manifest || manifest.status !== 'CAPTURE_COMPLETED' || manifest.branch !== currentBranch || !isAncestor(String(manifest.source_sha || ''))) failures.push('capture manifest provenance/status mismatch');
  const infos = { A: await sessionInfo('A'), B: await sessionInfo('B') };
  const blockers = [];
  const requiredFramesBySession = {};
  const successFramesBySession = {};
  for (const session of ['A', 'B']) {
    const info = infos[session];
    requiredFramesBySession[session] = info.names.filter(name => REQUIRED_R1H_FRAMES.includes(name));
    successFramesBySession[session] = info.names.filter(name => SUCCESS_R1H_FRAMES.includes(name));
    if (!info.finalState) failures.push(`missing ${session} r1h-final-state.json`);
    if (!info.names.some(name => name.endsWith('.png'))) failures.push(`missing real headed PNG evidence for session ${session}`);
    if (info.blocker) blockers.push({ session, ...info.blocker });
    const forbiddenSuccess = info.names.filter(name => /GENUINE_VICTORY|RESULT_UI|MATCH_FROZEN|CONTINUE|PLAY_AGAIN|FRESH_REPLAY/.test(name));
    if (info.blocker && forbiddenSuccess.length) failures.push(`blocker session ${session} contains success-only evidence: ${forbiddenSuccess.join(',')}`);
  }
  const sourceShas = [provenance?.source_sha, manifest?.source_sha].filter(Boolean);
  const contract = evaluateR1HValidatorContract({
    branch: currentBranch,
    validatedHead: head,
    sourceShas,
    sessions: ['A', 'B'],
    forbiddenPatterns: [],
    requiredRootFiles,
    requiredFramesBySession,
    successFramesBySession,
    blockers,
    directGameplayWritesRejected: true,
    normalEconomyEvidence: Object.values(infos).every(info => Boolean(info.finalState?.economy_timeline)),
    prototypeWiringPresent: source.includes('command_attack') || source.includes('issue_attack'),
    captureManifestStatus: manifest?.status || 'MISSING',
  });
  failures.push(...contract.failures);
  const primaryBlocker = blockers[0] || null;
  const status = failures.length ? 'BLOCKED_R1H_EVIDENCE_VALIDATION' : (primaryBlocker?.status || 'PASSED_V0436_R1H_NATURAL_CONQUEST_RESULT_REPLAY_PROOF');
  const result = {
    ...contract,
    schema: 'v0436-r1h-natural-player-assault-viability-validator-v1',
    status,
    passed: failures.length === 0,
    branch: currentBranch,
    source_sha: head,
    evidence_source_shas: sourceShas,
    pack: R1H_PACK,
    blocker: primaryBlocker,
    sessions: Object.fromEntries(Object.entries(infos).map(([key, value]) => [key, { blocker_status: value.blocker?.status || null, frames: value.names.filter(name => name.endsWith('.png')), final_state_present: Boolean(value.finalState) }])),
    direct_gameplay_writes_rejected: true,
    success_frames_rejected_when_blocked: true,
  };
  await writeJson(path.join(pack, 'final-validation.json'), result);
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') focused();
else if (command === 'smoke') smoke();
else await validate();
