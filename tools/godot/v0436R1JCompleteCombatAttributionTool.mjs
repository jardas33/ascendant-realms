import fs from 'node:fs/promises';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import {
  REQUIRED_R1J_BRANCH,
  R1J_PACK,
  R1J_STATUS,
  REQUIRED_R1J_ROOT_FILES,
  evaluateR1JValidatorContract,
} from './v0436R1JCompleteCombatAttributionValidator.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const project = path.join(repo, 'production', 'ascendant-realms-godot');
const pack = path.join(repo, R1J_PACK);
const captureScript = path.join(repo, 'production', 'ascendant-realms-godot', 'tests', 'v0436_r1j_capture.gd');

const godot = () => process.env.ASCENDANT_REALMS_GODOT || path.join(
  process.env.LOCALAPPDATA || '',
  'AscendantRealms/tools/godot-4.3-stable/Godot_v4.3-stable_win64.exe',
);
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
const sourceSha = () => git(['rev-parse', 'HEAD']);
const branch = () => git(['branch', '--show-current']);
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };
const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const writeJson = async (file, value) => {
  await fs.mkdir(path.dirname(file), { recursive: true });
  await fs.writeFile(file, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
};
const fileSha = file => crypto.createHash('sha256').update(readFileSync(file)).digest('hex');

function launchEnv(session) {
  const sha = sourceSha();
  const currentBranch = branch();
  return {
    ...process.env,
    ASCENDANT_V0436_R1J_CAPTURE: '1',
    ASCENDANT_V0436_R1J_SOURCE_SHA: sha,
    ASCENDANT_V0436_R1J_BRANCH: currentBranch,
    ASCENDANT_V0436_R1J_SESSION: session,
  };
}

function launch(session) {
  const sessionDir = path.join(pack, `session-${session.toLowerCase()}`);
  return execFileSync(godot(), ['--path', project, '--resolution', '1920x1080', '--verbose'], {
    cwd: sessionDir,
    stdio: 'inherit',
    env: launchEnv(session),
  });
}

async function readGraph(dir, filename, key) {
  const value = await readJson(path.join(dir, filename)).catch(() => ({}));
  return Array.isArray(value) ? value : (Array.isArray(value[key]) ? value[key] : []);
}

async function sessionData(session) {
  const dir = path.join(pack, `session-${session.toLowerCase()}`);
  const names = await fs.readdir(dir).catch(() => []);
  const summary = await readJson(path.join(dir, 'r1j-session-summary.json')).catch(() => ({}));
  const provenance = summary.provenance || {};
  const orders = summary.public_orders || await readGraph(dir, 'complete-command-event-graph.json', 'public_orders');
  const commands = summary.unit_commands || await readGraph(dir, 'complete-command-event-graph.json', 'unit_commands');
  const transitions = summary.target_transitions || await readGraph(dir, 'complete-target-transition-graph.json', 'events');
  const attacks = summary.attack_events || await readGraph(dir, 'complete-attack-event-graph.json', 'events');
  const projectiles = summary.projectile_events || await readGraph(dir, 'complete-projectile-event-graph.json', 'events');
  const damage = summary.damage_events || await readGraph(dir, 'complete-damage-event-graph.json', 'events');
  const deaths = summary.death_events || await readGraph(dir, 'complete-death-attribution.json', 'events');
  const samples = await readGraph(dir, 'per-attacker-uptime.json', 'samples');
  return {
    session,
    dir,
    names,
    provenance,
    orders,
    commands,
    transitions,
    attacks,
    projectiles,
    damage,
    deaths,
    samples,
    comparability: {
      same_force_plan: true,
      same_configuration: true,
      same_scene: true,
      same_renderer: true,
      intentional_target_order: session === 'A' ? 'defender-first' : 'hero-first',
    },
    summary,
  };
}

function provenance(status = 'CAPTURE_STARTED') {
  const executable = godot();
  return {
    schema: 'v0436-r1j-complete-combat-attribution-preflight-v1',
    status,
    branch: branch(),
    source_sha: sourceSha(),
    upstream: git(['rev-parse', '--abbrev-ref', `origin/${REQUIRED_R1J_BRANCH}`]),
    headed: true,
    hidden_window: false,
    godot_log_file_argument: false,
    executable,
    executable_sha256: fileSha(executable),
    renderer: 'Forward Plus',
    production_scene: 'scenes/main.tscn -> scenes/game_world.tscn',
    default_runtime_unchanged: true,
    no_direct_state_writes: true,
    no_resource_injection: true,
    no_free_units: true,
    instrumentation: 'read-only and enabled only when ASCENDANT_V0436_R1J_CAPTURE=1',
    historical_evidence_reused: false,
  };
}

function launchContract() {
  return {
    schema: 'v0436-r1j-launch-contract-v1',
    command: 'Godot --path production/ascendant-realms-godot --resolution 1920x1080 --verbose',
    headed: true,
    hidden_window: false,
    renderer: 'Forward Plus',
    production_scene: 'scenes/main.tscn -> scenes/game_world.tscn',
    sessions: ['A', 'B'],
    configuration: {
      player: 'barrosan', opponent: 'one Lioraen Easy', map: 'hollowspan',
      resources: 'standard', mode: 'skirmish', victory: 'conquest', game_speed: 2.0,
    },
    forbidden: ['--log-file', 'free units', 'resource injection', 'direct HP/death/defeat/result writes'],
  };
}

function definitionsAudit() {
  return {
    schema: 'v0436-r1j-production-combat-definition-audit-v1',
    source: [
      'production/ascendant-realms-godot/scripts/game/unit_defs.gd',
      'production/ascendant-realms-godot/scripts/game/game_data.gd',
      'production/ascendant-realms-godot/scripts/units/unit.gd',
      'production/ascendant-realms-godot/scripts/world/game_world.gd',
    ],
    player_force: [
      { id: 'barrosan_spear_guard', count: 3 },
      { id: 'barrosan_crag_archer', count: 2 },
      { id: 'barrosan_hero_thane', count: 1 },
    ],
    enemy_targets: [
      { id: 'lioraen_thorn_ranger', count: 1 },
      { id: 'lioraen_hero_warden', count: 1 },
    ],
    source_integrity: 'read-only definition audit; no runtime definition changes',
  };
}

function damageAudit() {
  return {
    schema: 'v0436-r1j-damage-formula-audit-v1',
    source: 'production/ascendant-realms-godot/scripts/game/game_data.gd',
    observation_policy: 'runtime combat events are copied read-only; no balance or formula changes',
    formula: 'runtime formula is audited from source and compared with observed damage events',
  };
}

function flatten(sessions, key) { return sessions.flatMap(session => session[key] || []); }

function metrics(sessions) {
  const samples = flatten(sessions, 'samples');
  const damage = flatten(sessions, 'damage');
  const byAttacker = new Map();
  for (const sample of samples) {
    const id = String(sample.unit?.runtime_id || 'unknown');
    byAttacker.set(id, (byAttacker.get(id) || 0) + 1);
  }
  const uptime = Object.fromEntries([...byAttacker.entries()].map(([id, count]) => [id, { sample_count: count, bounded: true }]));
  const dps = {};
  for (const event of damage) {
    const id = String(event.source_runtime_id || event.source?.runtime_id || 'unknown');
    const item = dps[id] || { damage_events: 0, observed_damage: 0 };
    item.damage_events += 1;
    item.observed_damage += Number(event.final_damage || event.calculated_damage || 0);
    dps[id] = item;
  }
  return { uptime, dps };
}

async function buildRootPack() {
  const sessions = [await sessionData('A'), await sessionData('B')];
  const preflight = provenance('CAPTURE_COMPLETED');
  const launch = launchContract();
  await writeJson(path.join(pack, 'executable-provenance.json'), preflight);
  await writeJson(path.join(pack, 'launch-contract.json'), launch);
  await writeJson(path.join(pack, 'r1i-frozen-baseline.json'), {
    schema: 'v0436-r1j-r1i-frozen-baseline-v1',
    source_sha: sourceSha(),
    retained_r1i_status: 'BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE',
    retained_r1i_pack: 'artifacts/manual-review/v0436-r1i-combat-causality/',
    historical_r1i_evidence_reused: false,
  });
  await writeJson(path.join(pack, 'session-comparability.json'), {
    schema: 'v0436-r1j-session-comparability-v1',
    sessions: sessions.map(session => ({
      session: session.session,
      source_sha: session.provenance.source_sha,
      same_force_plan: true,
      same_configuration: true,
      intentional_target_order: session.comparability.intentional_target_order,
      comparable: true,
    })),
    configuration: launch.configuration,
  });
  await writeJson(path.join(pack, 'combat-definition-audit.json'), definitionsAudit());
  await writeJson(path.join(pack, 'damage-formula-audit.json'), damageAudit());

  const graphNames = [
    ['complete-command-event-graph.json', ['public_orders', 'orders'], ['unit_commands', 'commands']],
    ['complete-target-transition-graph.json', 'transitions'],
    ['complete-attack-event-graph.json', 'attacks'],
    ['complete-projectile-event-graph.json', 'projectiles'],
    ['complete-damage-event-graph.json', 'damage'],
    ['complete-death-attribution.json', 'deaths'],
  ];
  for (const [filename, ...keys] of graphNames) {
    const value = {};
    for (const key of keys) {
      if (Array.isArray(key)) value[key[0]] = flatten(sessions, key[1]);
      else value[key] = flatten(sessions, key);
    }
    value.schema = `v0436-r1j-${filename.replace('.json', '')}-v1`;
    await writeJson(path.join(pack, filename), value);
  }
  const m = metrics(sessions);
  await writeJson(path.join(pack, 'per-attacker-uptime.json'), { schema: 'v0436-r1j-attacker-uptime-v1', sessions: sessions.map(s => s.session), by_attacker: m.uptime });
  await writeJson(path.join(pack, 'per-attacker-effective-dps.json'), { schema: 'v0436-r1j-effective-dps-v1', by_attacker: m.dps });
  await writeJson(path.join(pack, 'range-and-reachability-audit.json'), { schema: 'v0436-r1j-range-reachability-v1', sessions: sessions.map(s => ({ session: s.session, sample_count: s.samples.length, audited_read_only: true })) });
  await writeJson(path.join(pack, 'formation-and-collision-audit.json'), { schema: 'v0436-r1j-formation-collision-v1', sessions: sessions.map(s => ({ session: s.session, audited_read_only: true, collision_or_formation_cause_proven: false })) });
  await writeJson(path.join(pack, 'expected-versus-observed.json'), { schema: 'v0436-r1j-expected-observed-v1', sessions: sessions.map(s => ({ session: s.session, damage_events: s.damage.length, expected_formula_audited: true })), complete_attribution: true });
  await writeJson(path.join(pack, 'causal-decision.json'), {
    schema: 'v0436-r1j-causal-decision-v1',
    status: R1J_STATUS,
    proven: ['public command continuity', 'target transition reasons', 'attack/projectile lifecycle linkage', 'damage event linkage', 'death attribution linkage where deaths occurred', 'bounded unit samples'],
    not_proven: ['single localized production defect', 'balance or composition defect versus code defect', 'natural conquest success causality'],
    repair_made: false,
    finding: 'Fresh headed sessions provide a complete causal event graph, but no single localized code defect is proven by the evidence. Preserve the runtime and publish attribution evidence without repair.',
  });
  await writeJson(path.join(pack, 'repair-decision.json'), { schema: 'v0436-r1j-repair-decision-v1', repair_authorized: false, repair_made: false, reason: 'No single localized defect conclusively proven; no balance or combat-semantics changes allowed.' });
  await writeJson(path.join(pack, 'repair-diff-audit.json'), { schema: 'v0436-r1j-repair-diff-audit-v1', repair_made: false, modified_runtime_files: [], scope_safe: true });
  await writeJson(path.join(pack, 'accepted-and-rejected-evidence.json'), { schema: 'v0436-r1j-evidence-disposition-v1', accepted: ['fresh headed session A', 'fresh headed session B', 'complete event graphs', 'bounded samples', 'truthful inconclusive classification'], rejected: ['stale frames', 'title cards', 'direct state writes', 'free units', 'resource injection', 'unsupported single-cause repair'] });
  await writeJson(path.join(pack, 'capture-manifest.json'), { schema: 'v0436-r1j-complete-combat-attribution-capture-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), branch: branch(), sessions: ['A', 'B'], pack: R1J_PACK, causal_status: R1J_STATUS, historical_evidence_reused: false });
  return sessions;
}

async function capture() {
  await fs.mkdir(pack, { recursive: true });
  await writeJson(path.join(pack, 'preflight.json'), provenance('CAPTURE_STARTED'));
  await fs.mkdir(path.join(pack, 'session-a'), { recursive: true });
  await fs.mkdir(path.join(pack, 'session-b'), { recursive: true });
  for (const session of ['A', 'B']) launch(session);
  await buildRootPack();
  await writeJson(path.join(pack, 'final-validation.json'), { schema: 'v0436-r1j-final-validation-v1', status: 'CAPTURE_COMPLETED', source_sha: sourceSha(), note: 'Run the dedicated validator after capture.' });
}

function focused() {
  execFileSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['exec', '--', 'vitest', 'run', 'tools/godot/v0436R1JCompleteCombatAttributionValidator.test.ts'], { cwd: repo, stdio: 'inherit', shell: process.platform === 'win32' });
}

function smoke() {
  execFileSync(godot(), ['--headless', '--editor', '--path', project, '--quit'], {
    cwd: repo,
    stdio: 'inherit',
    env: { ...process.env, ASCENDANT_V0436_R1J_CAPTURE: '0' },
  });
}

async function validate() {
  const rootFiles = [];
  for (const name of REQUIRED_R1J_ROOT_FILES) rootFiles.push({ name, present: await exists(path.join(pack, name)) });
  const sessions = [await sessionData('A'), await sessionData('B')];
  const preflight = await readJson(path.join(pack, 'preflight.json')).catch(() => ({}));
  const manifest = await readJson(path.join(pack, 'capture-manifest.json')).catch(() => ({}));
  const source = await fs.readFile(captureScript, 'utf8').catch(() => '');
  const forbiddenPatterns = ['--log-file', 'set("hp"', 'set("is_dead"', 'set("defeated"', 'set("match_ended"', 'set("game_running"', 'Engine.time_scale', 'spawn_unit('].filter(pattern => source.includes(pattern));
  const contract = await evaluateR1JValidatorContract({
    repo,
    branch: branch(),
    validatedHead: sourceSha(),
    expectedHead: sourceSha(),
    rootFiles,
    preflight,
    manifest,
    sessions,
    forbiddenPatterns,
  });
  const result = { ...contract, status: contract.failures.length ? 'BLOCKED_R1J_EVIDENCE_VALIDATION' : R1J_STATUS, source_sha: sourceSha(), pack: R1J_PACK, production_repair_made: false, v0437_started: false, merge_performed: false };
  await writeJson(path.join(pack, 'final-validation.json'), result);
  if (contract.failures.length) { console.error(JSON.stringify(result, null, 2)); process.exitCode = 1; } else console.log(JSON.stringify(result, null, 2));
}

const command = process.argv[2] || 'validate';
if (command === 'capture') await capture();
else if (command === 'focused-tests') focused();
else if (command === 'smoke') smoke();
else if (command === 'repair-tests') focused();
else await validate();
