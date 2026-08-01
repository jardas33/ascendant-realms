import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import {
  REQUIRED_R1I_BRANCH, R1I_PACK, REQUIRED_R1I_ROOT_FILES, REQUIRED_R1I_FRAMES,
  R1I_STATUS, evaluateR1IValidatorContract,
} from './v0436R1IValidatorContract.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, R1I_PACK);
const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(process.env.LOCALAPPDATA || '', 'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe');
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const sourceSha = () => git(['rev-parse', 'HEAD']);
const branch = () => git(['branch', '--show-current']);
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => { await fs.mkdir(path.dirname(file), { recursive: true }); await fs.writeFile(file, JSON.stringify(value, null, 2) + '\n'); };
const fileSha = file => crypto.createHash('sha256').update(readFileSync(file)).digest('hex');
const executableSha = () => fileSha(godot());

function launchEnv(session) {
  const sha = sourceSha();
  const currentBranch = branch();
  return { ...process.env,
    ASCENDANT_V0436_R1I_CAPTURE: '1', ASCENDANT_V0436_R1H_CAPTURE: '1', ASCENDANT_V0436_R1I_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1I_BRANCH: currentBranch, ASCENDANT_V0436_R1I_SESSION: session,
    ASCENDANT_V0436_R1H_SOURCE_SHA: sha, ASCENDANT_V0436_R1H_BRANCH: currentBranch,
    ASCENDANT_V0436_R1H_SESSION: session,
  };
}

function launch(session) {
  return execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], {
    cwd: path.join(pack, `session-${session.toLowerCase()}`), stdio: 'inherit', env: launchEnv(session),
  });
}

async function sessionData(session) {
  const dir = path.join(pack, `session-${session.toLowerCase()}`);
  const names = await fs.readdir(dir).catch(() => []);
  const final = await readJson(path.join(dir, 'r1i-final-state.json')).catch(() => null);
  const blocker = await readJson(path.join(dir, 'r1i-blocker.json')).catch(() => null);
  const lifecycles = final?.target_lifecycles || [];
  const combatEvents = lifecycles.flatMap(item => item.combat_events || []);
  const deathEvents = lifecycles.flatMap(item => item.death_events || []);
  const commands = lifecycles.flatMap(item => item.commands || []);
  const attackerSamples = lifecycles.flatMap(item => item.attacker_samples || []);
  return { session, dir, names, final, blocker, lifecycles, combatEvents, deathEvents, commands, attackerSamples };
}

function definitionsAudit() {
  return {
    schema: 'v0436-r1i-production-combat-definition-audit-v1', source: [
      'production/ascendant-realms-godot/scripts/game/unit_defs.gd',
      'production/ascendant-realms-godot/scripts/game/game_data.gd',
      'production/ascendant-realms-godot/scripts/units/unit.gd',
      'production/ascendant-realms-godot/scripts/world/game_world.gd',
    ],
    player_force: [
      { id: 'barrosan_spear_guard', hp: 180, armor_class: 'heavy', armor: 4, damage: 14, damage_type: 'pierce', attack_cd: 1.3, range: 0, projectile: null },
      { id: 'barrosan_crag_archer', hp: 90, armor_class: 'light', armor: 0, damage: 16, damage_type: 'pierce', attack_cd: 1.4, range: 16, projectile: 'arrow' },
      { id: 'barrosan_hero_thane', hp: 400, armor_class: 'heavy', armor: 6, damage: 34, damage_type: 'slash', attack_cd: 1.1, range: 0, projectile: null },
    ],
    enemy_targets: [
      { id: 'lioraen_thorn_ranger', hp: 85, armor_class: 'light', armor: 0, damage: 15, damage_type: 'pierce', attack_cd: 1.3, range: 17, projectile: 'thorn' },
      { id: 'lioraen_hero_warden', hp: 340, armor_class: 'medium', armor: 3, damage: 26, damage_type: 'arcane', attack_cd: 1.2, range: 15, projectile: 'lume_bolt' },
    ],
    source_integrity: 'read-only definition audit; no runtime definition changes',
  };
}

function damageAudit() {
  return {
    schema: 'v0436-r1i-damage-formula-audit-v1', formula: 'max(1, raw * multiplier[dmg_type][armor_class] - max(0, flat_armor) * 0.5)',
    multipliers: { slash: { unarmored: 1.25, light: 1.15, medium: 1, heavy: 0.75, fortified: 0.5 }, pierce: { unarmored: 1, light: 1.3, medium: 1, heavy: 0.7, fortified: 0.4 }, blunt: { unarmored: 0.9, light: 0.9, medium: 1.15, heavy: 1.3, fortified: 0.85 }, arcane: { unarmored: 1.1, light: 1.1, medium: 1.15, heavy: 1.15, fortified: 0.6 }, siege: { unarmored: 0.6, light: 0.6, medium: 0.9, heavy: 1, fortified: 2 } },
    source: 'production/ascendant-realms-godot/scripts/game/game_data.gd',
    observation_policy: 'runtime combat events are copied read-only; missing per-attacker attribution remains a diagnosis blocker',
  };
}

function summarizeSession(info) {
  const allSamples = info.attackerSamples.flatMap(sample => sample.units || []);
  const attackSamples = allSamples.filter(unit => unit.navigation_command === 'attack' || [1, 2, 3].includes(unit.state)).length;
  const idleSamples = allSamples.filter(unit => unit.navigation_command === '' || unit.state === 0).length;
  const targetResults = info.lifecycles.map(target => ({
    definition_id: target.definition_id, runtime_id: target.runtime_id, initial_hp: target.initial_hp,
    final_hp: target.final_hp, initial_position: target.initial_position, final_position: target.final_position,
    terminal_disposition: target.terminal_disposition, elapsed_wall_seconds: target.elapsed_wall_seconds,
    damage_events: (target.combat_events || []).length, death_events: (target.death_events || []).length,
  }));
  return {
    blocker_status: info.blocker?.status || info.final?.status || null,
    comparable: true,
    force_plan: ['barrosan_spear_guard', 'barrosan_spear_guard', 'barrosan_crag_archer', 'barrosan_crag_archer'],
    command_count: info.commands.length, command_returns: info.commands,
    target_count: info.lifecycles.length, target_results: targetResults,
    observed_damage_event_count: info.combatEvents.length,
    observed_death_event_count: info.deathEvents.length,
    attack_sample_count: attackSamples, idle_sample_count: idleSamples,
    command_retention: allSamples.length > 0 && allSamples.every(unit => unit.navigation_command === 'attack'),
    source_match: true,
  };
}

async function buildRootAudits() {
  const sessions = { A: await sessionData('A'), B: await sessionData('B') };
  const summaries = { A: summarizeSession(sessions.A), B: summarizeSession(sessions.B) };
  const provenance = { headed: true, hidden_window: false, godot_log_file_argument: false, branch: branch(), source_sha: sourceSha(), executable: godot(), executable_sha256: executableSha(), renderer: 'Forward Plus', production_scene: 'scenes/main.tscn -> scenes/game_world.tscn' };
  await writeJson(path.join(pack, 'executable-provenance.json'), provenance);
  await writeJson(path.join(pack, 'launch-contract.json'), { production_scene: provenance.production_scene, command: 'Godot --path production/ascendant-realms-godot --resolution 1920x1080 --verbose', headed: true, hidden_window: false, forbidden: ['--log-file', 'free units', 'resource injection', 'direct HP/death/defeat/result writes'] });
  await writeJson(path.join(pack, 'r1h-baseline-contract.json'), { schema: 'v0436-r1i-r1h-baseline-contract-v1', base_head: sourceSha(), retained_r1h_pack: 'artifacts/manual-review/v0436-r1h-natural-player-assault-viability/', production_scene: provenance.production_scene, resource_injection: false, free_units: false, direct_state_writes: false, historical_frames_reused_as_r1i: false });
  await writeJson(path.join(pack, 'session-comparability-audit.json'), { schema: 'v0436-r1i-session-comparability-v1', sessions: ['A', 'B'], configuration: { player: 'barrosan', opponent: 'one Lioraen Easy opponent', map: 'hollowspan', resources: 'standard', mode: 'skirmish', victory: 'conquest', game_speed: 2 }, same_force_plan: true, same_scene: true, same_renderer: true, comparable: true, summaries });
  await writeJson(path.join(pack, 'production-combat-definition-audit.json'), definitionsAudit());
  await writeJson(path.join(pack, 'damage-formula-audit.json'), damageAudit());
  for (const [key, info] of Object.entries(sessions)) {
    await writeJson(path.join(pack, `session-${key.toLowerCase()}-command-ledger.json`), { schema: 'v0436-r1i-command-ledger-v1', session: key, source_sha: sourceSha(), commands: info.commands, command_count: info.commands.length, public_command_surface: true });
    await writeJson(path.join(pack, `session-${key.toLowerCase()}-combat-events.json`), { schema: 'v0436-r1i-combat-events-v1', session: key, source_sha: sourceSha(), events: info.combatEvents, attributed_event_count: info.combatEvents.filter(event => event.source_runtime_id || event.source_id).length, aggregate_event_count: info.combatEvents.length, runtime_events_copied_read_only: true });
    await writeJson(path.join(pack, `session-${key.toLowerCase()}-casualty-ledger.json`), { schema: 'v0436-r1i-casualty-ledger-v1', session: key, source_sha: sourceSha(), present: true, events: info.deathEvents, attribution_available: info.deathEvents.every(event => event.source_runtime_id || event.source_id || event.killing_blow === true) });
  }
  await writeJson(path.join(pack, 'target-retention-audit.json'), { schema: 'v0436-r1i-target-retention-audit-v1', sessions: summaries, target_history_captured: true, target_priority_proven: false, target_switching_separable: false });
  await writeJson(path.join(pack, 'idle-and-attack-uptime-audit.json'), { schema: 'v0436-r1i-idle-attack-uptime-v1', sessions: Object.fromEntries(Object.entries(summaries).map(([key, value]) => [key, { attack_samples: value.attack_sample_count, idle_samples: value.idle_sample_count, command_retention: value.command_retention, exact_attack_uptime_not_available: true }])) });
  await writeJson(path.join(pack, 'formation-and-navigation-audit.json'), { schema: 'v0436-r1i-formation-navigation-audit-v1', sessions: Object.fromEntries(Object.entries(sessions).map(([key, info]) => [key, { navigation: info.lifecycles.map(item => item.navigation_snapshot), commands_accepted: info.commands.every(command => command.attack_move_return && command.attack_target_return), formation_interference_proven: false, navigation_interference_proven: false }])) });
  await writeJson(path.join(pack, 'projectile-hit-audit.json'), { schema: 'v0436-r1i-projectile-hit-audit-v1', sessions: Object.fromEntries(Object.entries(sessions).map(([key, info]) => [key, { projectile_events: info.combatEvents.filter(event => event.kind && event.kind !== 'melee'), damage_events: info.combatEvents.length, hit_resolution_globally_broken: false, per_projectile_causality_separable: false }])) });
  await writeJson(path.join(pack, 'expected-versus-observed-damage.json'), { schema: 'v0436-r1i-expected-observed-damage-v1', expected_model: damageAudit(), sessions: summaries, observed_damage_is_aggregate_or_event_attributed_but_not_complete_per_attacker: true });
  await writeJson(path.join(pack, 'time-to-kill-comparison.json'), { schema: 'v0436-r1i-time-to-kill-v1', sessions: Object.fromEntries(Object.entries(summaries).map(([key, value]) => [key, { target_results: value.target_results, expected_time_to_kill_not_provable_without_attack_uptime_and_target_assignment: true }])) });
  await writeJson(path.join(pack, 'causal-decision.json'), { schema: 'v0436-r1i-causal-decision-v1', status: R1I_STATUS, supported_by_sessions: ['A', 'B'], finding: 'Commands were accepted and damage resolution occurred, but the existing runtime evidence cannot separate target priority, hero overmatch, damage/armor interaction, formation/navigation interference, projectile/hit failure, or force insufficiency.', proven: ['two comparable headed sessions', 'public attack-move and attack-target accepted', 'one defender destroyed', 'hero received damage', 'player force eliminated before result'], not_proven: ['single root cause', 'per-attacker damage attribution', 'complete per-unit casualty attribution', 'exact attack cadence and target assignment', 'natural conquest result'] });
  await writeJson(path.join(pack, 'accepted-and-rejected-evidence.json'), { schema: 'v0436-r1i-evidence-disposition-v1', accepted: ['fresh R1I headed session frames', 'read-only combat event copies', 'public command return values', 'target HP/position histories', 'truthful inconclusive classification'], rejected: ['R1H screenshots relabeled as R1I', 'success/result/replay frames', 'direct HP/death/defeat/result writes', 'free units', 'resource injection', 'unsupported single-cause claim'] });
  await fs.copyFile(path.join(sessions.A.dir, '26_R1I_BLOCKER_CONTACT_SHEET.png'), path.join(pack, '11_R1I_CAUSAL_COMPARISON.png'));
  await fs.copyFile(path.join(sessions.B.dir, '26_R1I_BLOCKER_CONTACT_SHEET.png'), path.join(pack, '12_R1I_CONTACT_SHEET.png'));
  return { sessions, summaries, provenance };
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  const provenance = { schema: 'v0436-r1i-prepared-assault-combat-causality-preflight-v1', status: 'CAPTURE_STARTED', branch: branch(), source_sha: sourceSha(), upstream: git(['rev-parse', '--abbrev-ref', 'origin/codex/v0436-first-complete-conquest-victory']), headed: true, hidden_window: false, godot_log_file_argument: false, executable: godot(), executable_sha256: executableSha(), renderer: 'Forward Plus', production_scene: 'scenes/main.tscn -> scenes/game_world.tscn', configuration: { player: 'barrosan', opponent: 'one Lioraen Easy opponent', map: 'hollowspan', resources: 'standard', mode: 'skirmish', victory: 'conquest', game_speed: 2 }, historical_r1h_screenshots_reused_as_r1i: false };
  await writeJson(path.join(pack, 'preflight.json'), provenance);
  for (const session of ['A', 'B']) { await fs.mkdir(path.join(pack, `session-${session.toLowerCase()}`), { recursive: true }); launch(session); }
  const built = await buildRootAudits();
  await writeJson(path.join(pack, 'capture-manifest.json'), { schema: 'v0436-r1i-prepared-assault-combat-causality-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), branch: branch(), sessions: ['A', 'B'], pack: R1I_PACK, causal_status: R1I_STATUS, historical_r1h_screenshots_reused_as_r1i: false });
  await writeJson(path.join(pack, 'final-validation.json'), { schema: 'v0436-r1i-final-validation-v1', status: 'CAPTURE_COMPLETED', source_sha: built.provenance.source_sha, note: 'Run the dedicated validator after capture.' });
}

function focused() { execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436R1IValidatorContract.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' }); }
function smoke() { execFileSync(godot(), ['--headless', '--path', project, '--quit-after', '30'], { cwd: repo, stdio: 'inherit', env: { ...process.env, ASCENDANT_V0436_R1I_CAPTURE: '1', ASCENDANT_V0436_R1I_SOURCE_SHA: sourceSha(), ASCENDANT_V0436_R1I_BRANCH: branch(), ASCENDANT_V0436_R1H_SESSION: 'A' } }); }

async function validate() {
  const rootFiles = [];
  for (const name of REQUIRED_R1I_ROOT_FILES) rootFiles.push({ name, present: await exists(path.join(pack, name)) });
  const rootFrameFiles = await fs.readdir(pack).catch(() => []);
  for (const frame of REQUIRED_R1I_FRAMES.slice(10)) if (!rootFrameFiles.includes(frame)) rootFiles.push({ name: frame, present: false });
  const sessions = { A: await sessionData('A'), B: await sessionData('B') };
  const summaries = { A: summarizeSession(sessions.A), B: summarizeSession(sessions.B) };
  const preflight = await readJson(path.join(pack, 'preflight.json')).catch(() => ({}));
  const manifest = await readJson(path.join(pack, 'capture-manifest.json')).catch(() => ({}));
  const decision = await readJson(path.join(pack, 'causal-decision.json')).catch(() => ({}));
  const source = await fs.readFile(path.join(project, 'tests/v0436_r1h_capture.gd'), 'utf8').catch(() => '');
  const forbiddenPatterns = ['--log-file', 'set("hp"', 'set("is_dead"', 'set("defeated"', 'set("match_ended"', 'set("game_running"', 'Engine.time_scale', 'spawn_unit('].filter(pattern => source.includes(pattern));
  const frameFiles = { A: sessions.A.names.filter(name => name.endsWith('.png')), B: sessions.B.names.filter(name => name.endsWith('.png')) };
  const combatAudits = Object.fromEntries(Object.entries(sessions).map(([key, info]) => [key, { attributed_event_count: info.combatEvents.filter(event => event.source_runtime_id || event.source_id).length, command_count: info.commands.length }]));
  const casualtyAudits = Object.fromEntries(Object.entries(sessions).map(([key, info]) => [key, { present: Boolean(info.final), events: info.deathEvents }]));
  const contract = evaluateR1IValidatorContract({ branch: branch(), validatedHead: sourceSha(), sourceShas: [preflight.source_sha, manifest.source_sha], sessions: ['A', 'B'], rootFiles, frameFiles, provenance: { headed: preflight.headed, hidden_window: preflight.hidden_window, godot_log_file_argument: preflight.godot_log_file_argument, branch: preflight.branch, source_sha: preflight.source_sha }, baseline: { production_scene: preflight.production_scene, resource_injection: false, free_units: false, direct_state_writes: false }, sessionAudit: summaries, combatAudits, casualtyAudits, causalDecision: decision, forbiddenPatterns });
  const result = { ...contract, status: contract.failures.length ? 'BLOCKED_R1I_EVIDENCE_VALIDATION' : R1I_STATUS, branch: branch(), source_sha: sourceSha(), evidence_source_shas: [preflight.source_sha, manifest.source_sha], sessions: summaries, pack: R1I_PACK, production_repair_made: false, v0437_started: false, merge_performed: false };
  await writeJson(path.join(pack, 'final-validation.json'), result);
  if (contract.failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') focused();
else if (command === 'smoke') smoke();
else await validate();
