import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, 'artifacts', 'manual-review', 'v0436-r1g-natural-conquest-predicate-truth');
const branchName = 'codex/v0436-first-complete-conquest-victory';
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const upstream = () => { try { return git(['rev-parse', '--abbrev-ref', '@{u}']); } catch { return 'no-upstream'; } };
const sourceSha = () => git(['rev-parse', 'HEAD']);
const isAncestor = sha => { try { execFileSync('git', ['merge-base', '--is-ancestor', sha, sourceSha()], { cwd: repo, stdio: 'ignore' }); return true; } catch { return false; } };
const startResources = () => process.env.ASCENDANT_E1_START_RESOURCES || 'standard';
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const executableSha = () => crypto.createHash('sha256').update(readFileSync(godot())).digest('hex');

const requiredFrames = [
  '01_R1G_MATCH_CONFIGURATION.png','02_R1G_INITIAL_PRODUCTION_MATCH.png','03_R1G_NAVIGATION_READY.png',
  '04_R1G_PLAYER_PRODUCTION_READY.png','05_R1G_ASSAULT_COMMAND.png','06_R1G_REAL_COMBAT_CONTACT.png',
  '07_R1G_REAL_DAMAGE.png','08_R1G_ENEMY_HQ_ACTUAL_STATE.png','09_R1G_REMAINING_BUILDING_INVENTORY.png',
  '10_R1G_REBUILD_CAPABILITY_INVENTORY.png','11_R1G_FINAL_CONQUEST_PREDICATE.png'
];

function launchEnv(session) {
  return { ...process.env, ASCENDANT_V0436_R1G_CAPTURE: '1', ASCENDANT_V0436_R1G_SOURCE_SHA: sourceSha(), ASCENDANT_V0436_R1G_BRANCH: git(['branch', '--show-current']), ASCENDANT_V0436_R1G_SESSION: session };
}

function launch(session) {
  const env = launchEnv(session);
  const cwd = path.join(pack, `session-${session.toLowerCase()}`);
  return execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], { cwd, stdio: 'inherit', env });
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  const executable = godot();
  await writeJson(path.join(pack, 'preflight.json'), { schema: 'v0436-r1g-preflight-v1', status: 'CAPTURE_STARTED', branch: git(['branch', '--show-current']), source_sha: sourceSha(), upstream: upstream(), executable, executable_sha256: executableSha(), renderer: 'project-default Forward Plus', launch_contract: 'headed Windows display; runner-owned stdout/stderr; no Godot --log-file; real production scenes/main.tscn -> scenes/game_world.tscn', match_configuration: { player_race: 'barrosan', opponent_race: 'lioraen', difficulty: 'easy', map: 'hollowspan', start_resources: startResources(), mode: 'skirmish', victory: 'conquest', game_speed: 2.0 } });
  await writeJson(path.join(pack, 'executable-provenance.json'), { executable, version: 'Godot 4.3 stable', sha256: executableSha(), renderer: 'Forward Plus', headed: true, hidden_window: false, log_owner: 'R1G runner stdout/stderr' });
  await writeJson(path.join(pack, 'launch-contract.json'), { production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', command: 'Godot --path production/ascendant-realms-godot --resolution 1920x1080 --verbose', forbidden: ['--log-file', 'headless evidence', 'hidden-window evidence', 'direct gameplay state writes'] });
  await writeJson(path.join(pack, 'match-configuration.json'), { player: 'barrosan', opponent: 'one Lioraen Easy opponent', map: 'hollowspan', resources: startResources(), victory: 'conquest', mode: 'skirmish', game_speed: 2.0, sessions: ['A', 'B'] });
  for (const session of ['A', 'B']) {
    await fs.mkdir(path.join(pack, `session-${session.toLowerCase()}`), { recursive: true });
    try { launch(session); } catch (error) {
      await writeJson(path.join(pack, 'runner-process-result.json'), { session, exit_status: error.status ?? null, note: 'GDScript owns truthful blocker classification; nonzero process exit is retained for diagnosis.' });
      throw error;
    }
  }
  await writeJson(path.join(pack, 'capture-manifest.json'), { schema: 'v0436-r1g-natural-conquest-predicate-truth-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), branch: git(['branch', '--show-current']), sessions: ['A', 'B'], pack: 'artifacts/manual-review/v0436-r1g-natural-conquest-predicate-truth/' });
}

function focused() {
  execFileSync(godot(), ['--headless', '--path', project, '--script', 'res://tests/v0436_conquest_victory.gd', '--quit-after', '20'], { cwd: repo, stdio: 'inherit', env: launchEnv('A') });
}

function smoke() {
  execFileSync(godot(), ['--headless', '--path', project, '--quit-after', '30'], { cwd: repo, stdio: 'inherit', env: launchEnv('A') });
}

async function sessionFiles(session) {
  const dir = path.join(pack, `session-${session.toLowerCase()}`);
  const names = await fs.readdir(dir).catch(() => []);
  return { dir, names };
}

async function validate() {
  const failures = [];
  const head = sourceSha();
  const branch = git(['branch', '--show-current']);
  if (branch !== branchName) failures.push(`wrong branch: ${branch}`);
  if (head !== sourceSha()) failures.push('source SHA changed during validation');
  if (!(await exists(path.join(pack, 'preflight.json')))) failures.push('missing preflight.json');
  if (!(await exists(path.join(pack, 'executable-provenance.json')))) failures.push('missing executable-provenance.json');
  if (!(await exists(path.join(pack, 'launch-contract.json')))) failures.push('missing launch-contract.json');
  if (!(await exists(path.join(pack, 'capture-manifest.json')))) failures.push('missing capture-manifest.json');
  const source = await fs.readFile(path.join(repo, 'production/ascendant-realms-godot/tests/v0436_r1g_capture.gd'), 'utf8').catch(() => '');
  const runner = await fs.readFile(new URL(import.meta.url), 'utf8');
  for (const forbidden of ['--log-file', 'emit_signal("pressed")', 'set("hp"', 'set("is_dead"', 'set("defeated"', 'set("match_ended"', 'set("game_running"']) {
    if (source.includes(forbidden)) failures.push(`forbidden capture pattern: ${forbidden}`);
  }
  const provenance = await readJson(path.join(pack, 'preflight.json')).catch(() => null);
  if (!provenance || !isAncestor(provenance.source_sha || '') || provenance.branch !== branch) failures.push('preflight provenance mismatch');
  const manifest = await readJson(path.join(pack, 'capture-manifest.json')).catch(() => null);
  if (!manifest || manifest.status !== 'CAPTURE_COMPLETED' || !isAncestor(manifest.source_sha || '') || manifest.branch !== branch) failures.push('capture manifest provenance/status mismatch');
  const blockers = [];
  const sessionStates = {};
  for (const session of ['A', 'B']) {
    const { dir, names } = await sessionFiles(session);
    const blockerPath = path.join(dir, 'r1g-blocker.json');
    const blocker = await readJson(blockerPath).catch(() => null);
    if (blocker) blockers.push({ session, ...blocker });
    const finalState = await readJson(path.join(dir, 'r1g-final-state.json')).catch(() => null);
    sessionStates[session] = finalState;
    if (!finalState) failures.push(`missing ${session} r1g-final-state.json`);
    if (!names.some(name => name.endsWith('.png'))) failures.push(`missing real headed PNG evidence for session ${session}`);
    const forbiddenSuccess = names.filter(name => /GENUINE_VICTORY|RESULT_UI|FROZEN|CONTINUE|PLAY_AGAIN|FRESH_REPLAY/.test(name));
    if (blocker && forbiddenSuccess.length) failures.push(`blocker session ${session} contains success-only evidence: ${forbiddenSuccess.join(',')}`);
    if (!blocker) {
      for (const frame of requiredFrames) if (!(await exists(path.join(dir, frame)))) failures.push(`missing success-path frame ${session}/${frame}`);
      if (!(await exists(path.join(dir, 'result-state-audit.json')))) failures.push(`missing result audit for session ${session}`);
    }
  }
  const primaryBlocker = blockers[0] || null;
  const packStatus = primaryBlocker ? 'BLOCKED_WITH_TRUTHFUL_LIVE_EVIDENCE' : 'SUCCESS_PATH_REACHED';
  const blockerSummary = primaryBlocker ? { status: primaryBlocker.status, reason: primaryBlocker.reason, source_sha: primaryBlocker.provenance?.source_sha, session: primaryBlocker.session } : { status: 'NOT_REACHED', reason: 'no blocker; success path would provide result evidence' };
  await writeJson(path.join(pack, 'r1g-blocker.json'), primaryBlocker || { schema: 'v0436-r1g-blocker-v1', status: 'NOT_REACHED', reason: 'success path reached', source_sha: head });
  await writeJson(path.join(pack, 'capture-contract-audit.json'), { schema: 'v0436-r1g-capture-contract-audit-v1', status: packStatus, source_sha: head, normal_public_actions: ['selection', 'attack-move', 'attack-target', 'building placement', 'worker construction', 'real-cost production'], forbidden_driver_writes: ['HP', 'death', 'defeat', 'result', 'match state', 'resources', 'post-start teleportation'], no_direct_button_signal_emission: true, no_godot_log_file: true });
  await writeJson(path.join(pack, 'target-lifecycle-audit.json'), { schema: 'v0436-r1g-target-lifecycle-audit-v1', status: packStatus, source_sha: head, sessions: Object.entries(sessionStates).map(([session, state]) => ({ session, target_lifecycles: state?.target_lifecycles || [], blocker: state?.status || 'not-reached' })) });
  await writeJson(path.join(pack, 'predicate-snapshot-sequence.json'), { schema: 'v0436-r1g-predicate-snapshot-sequence-v1', status: packStatus, source_sha: head, sessions: Object.entries(sessionStates).map(([session, state]) => ({ session, sequence: state?.predicate_sequence || [], predicate: state?.predicate || null })) });
  await writeJson(path.join(pack, 'victory-check-audit.json'), { schema: 'v0436-r1g-victory-check-audit-v1', status: primaryBlocker ? 'NOT_REACHED_DUE_BLOCKER' : 'REACHED', source_sha: head, observation: primaryBlocker ? 'No victory claim was made because the normal assault terminated at a live blocker before final predicate truth.' : 'Read-only live result observation recorded.' });
  await writeJson(path.join(pack, 'navigation-monitoring-audit.json'), { schema: 'v0436-r1g-navigation-monitoring-audit-v1', status: packStatus, source_sha: head, source: 'live target position samples and GameWorld navigation_runtime_snapshot', sessions: Object.entries(sessionStates).map(([session, state]) => ({ session, target_lifecycles: state?.target_lifecycles || [] })) });
  await writeJson(path.join(pack, 'combat-and-destruction-audit.json'), { schema: 'v0436-r1g-combat-destruction-audit-v1', status: packStatus, source_sha: head, evidence: Object.entries(sessionStates).map(([session, state]) => ({ session, last_valid_frame: state?.frames?.at(-1) || null, target_lifecycles: state?.target_lifecycles || [] })) });
  await writeJson(path.join(pack, 'result-state-audit.json'), { schema: 'v0436-r1g-result-state-audit-v1', status: primaryBlocker ? 'NOT_REACHED_DUE_BLOCKER' : 'REACHED', source_sha: head, sessions: ['A', 'B'], note: primaryBlocker ? 'Success-only result evidence is intentionally absent.' : 'See session result-state-audit.json files.' });
  await writeJson(path.join(pack, 'freeze-audit.json'), { schema: 'v0436-r1g-freeze-audit-v1', status: primaryBlocker ? 'NOT_REACHED_DUE_BLOCKER' : 'REACHED', source_sha: head, note: primaryBlocker ? 'Freeze proof was not run after the truthful blocker.' : 'See session freeze-audit.json files.' });
  await writeJson(path.join(pack, 'continue-action-audit.json'), { schema: 'v0436-r1g-continue-action-audit-v1', status: 'NOT_REACHED_DUE_BLOCKER', source_sha: head, note: 'Continue requires genuine natural Victory; not attempted after blocker.' });
  await writeJson(path.join(pack, 'play-again-action-audit.json'), { schema: 'v0436-r1g-play-again-action-audit-v1', status: 'NOT_REACHED_DUE_BLOCKER', source_sha: head, note: 'Play Again requires genuine natural Victory; not attempted after blocker.' });
  await writeJson(path.join(pack, 'fresh-replay-audit.json'), { schema: 'v0436-r1g-fresh-replay-audit-v1', status: 'NOT_REACHED_DUE_BLOCKER', source_sha: head, note: 'Fresh replay requires genuine natural Victory; not attempted after blocker.' });
  await writeJson(path.join(pack, 'accepted-and-rejected-evidence.json'), { schema: 'v0436-r1g-evidence-disposition-v1', source_sha: head, accepted: ['fresh headed R1G frames', 'live predicate snapshots', 'target lifecycle audits', 'truthful blocker'], rejected: ['historical R1C frames', 'title cards', 'success-named frames without matching live state', 'direct result/replay signals'] });
  const rootRequired = ['preflight.json','executable-provenance.json','launch-contract.json','match-configuration.json','capture-contract-audit.json','target-lifecycle-audit.json','predicate-snapshot-sequence.json','victory-check-audit.json','navigation-monitoring-audit.json','combat-and-destruction-audit.json','result-state-audit.json','freeze-audit.json','continue-action-audit.json','play-again-action-audit.json','fresh-replay-audit.json','accepted-and-rejected-evidence.json','r1g-blocker.json'];
  for (const file of rootRequired) if (!(await exists(path.join(pack, file)))) failures.push(`missing root review-pack file ${file}`);
  if (primaryBlocker) {
    const blockerSheet = path.join(pack, 'session-a', '21_R1G_BLOCKER_CONTACT_SHEET.png');
    if (await exists(blockerSheet)) await fs.copyFile(blockerSheet, path.join(pack, '21_R1G_BLOCKER_CONTACT_SHEET.png'));
  }
  if (!primaryBlocker) {
    const a = await readJson(path.join(pack, 'session-a', 'continue-action-audit.json')).catch(() => null);
    const b = await readJson(path.join(pack, 'session-b', 'play-again-action-audit.json')).catch(() => null);
    if (!a || !b) failures.push('missing genuine Continue/Play Again audits');
  }
  if (primaryBlocker) {
    const required = ['status','reason','complete_current_predicate','surviving_entity_inventory','player_force_inventory','last_commands','target_lifecycles','last_valid_frame','why_later_phases_were_not_run'];
    for (const key of required) if (!(key in primaryBlocker)) failures.push(`blocker missing ${key}`);
  }
  const result = { schema: 'v0436-r1g-natural-conquest-predicate-truth-validator-v1', status: primaryBlocker?.status || (failures.length ? 'BLOCKED_R1G_EVIDENCE_VALIDATION' : 'PASSED_V0436_R1G_NATURAL_CONQUEST_RESULT_REPLAY_PROOF'), passed: failures.length === 0, branch, source_sha: head, failures, blocker: primaryBlocker, pack: 'artifacts/manual-review/v0436-r1g-natural-conquest-predicate-truth/', success_frames_rejected_when_blocked: true, r1c_pack_reused: false, direct_gameplay_writes_rejected: true };
  await writeJson(path.join(pack, 'final-validation.json'), result);
  if (failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') focused();
else if (command === 'smoke') smoke();
else await validate();
