import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const REQUIRED_R1J_BRANCH = 'codex/v0436-first-complete-conquest-victory';
export const R1J_PACK = 'artifacts/manual-review/v0436-r1j-complete-combat-attribution-and-conditional-repair/';
export const R1J_STATUS = 'BLOCKED_R1J_COMPLETE_ATTRIBUTION_INCONCLUSIVE';
export const REQUIRED_R1J_ROOT_FILES = Object.freeze([
  'preflight.json', 'executable-provenance.json', 'launch-contract.json', 'r1i-frozen-baseline.json',
  'session-comparability.json', 'combat-definition-audit.json', 'damage-formula-audit.json',
  'complete-command-event-graph.json', 'complete-target-transition-graph.json',
  'complete-attack-event-graph.json', 'complete-projectile-event-graph.json',
  'complete-damage-event-graph.json', 'complete-death-attribution.json',
  'per-attacker-uptime.json', 'per-attacker-effective-dps.json',
  'range-and-reachability-audit.json', 'formation-and-collision-audit.json',
  'expected-versus-observed.json', 'causal-decision.json', 'repair-decision.json',
  'repair-diff-audit.json', 'accepted-and-rejected-evidence.json', 'capture-manifest.json',
  'final-validation.json',
]);

const readJson = async file => JSON.parse(await fs.readFile(file, 'utf8'));
const exists = async file => { try { await fs.access(file); return true; } catch { return false; } };

function uniqueIds(events, key, failures, label) {
  const ids = events.map(event => String(event?.[key] || '')).filter(Boolean);
  if (ids.length !== new Set(ids).size) failures.push(`${label} contains duplicate IDs`);
  if (events.some(event => !String(event?.[key] || ''))) failures.push(`${label} contains an event without ${key}`);
}

function validateGraph({ session, failures }) {
  const commands = session.commands || [];
  const orders = session.orders || [];
  const transitions = session.transitions || [];
  const attacks = session.attacks || [];
  const projectiles = session.projectiles || [];
  const damage = session.damage || [];
  const deaths = session.deaths || [];
  const samples = session.samples || [];
  uniqueIds(orders, 'order_event_id', failures, 'public orders');
  uniqueIds(commands, 'unit_command_event_id', failures, 'unit commands');
  uniqueIds(transitions, 'target_transition_event_id', failures, 'target transitions');
  uniqueIds(attacks, 'attack_event_id', failures, 'attacks');
  uniqueIds(projectiles, 'projectile_event_id', failures, 'projectiles');
  uniqueIds(damage, 'damage_event_id', failures, 'damage events');
  uniqueIds(deaths, 'death_event_id', failures, 'death events');
  if (!samples.length) failures.push('no bounded per-frame unit samples');
  if (!orders.length || !commands.length) failures.push('public command receipt graph is incomplete');
  if (transitions.some(event => String(event.reason) === 'unknown')) failures.push('target transition has unknown reason');
  for (const event of damage) {
    if (!event.attack_event_id) failures.push(`damage ${event.damage_event_id} is not linked to an attack`);
    if (!event.victim_runtime_id || !event.source_runtime_id) failures.push(`damage ${event.damage_event_id} lacks attacker/victim runtime IDs`);
    if (event.observed_hp_delta !== undefined && Math.abs(Number(event.observed_hp_delta) - Number(event.final_damage)) > 0.001) failures.push(`damage ${event.damage_event_id} HP delta contradicts applied damage`);
    if (event.expected_applied_damage !== undefined && Math.abs(Number(event.expected_applied_damage) - Number(event.final_damage)) > 0.001) failures.push(`damage ${event.damage_event_id} contradicts expected formula`);
  }
  const attackIds = new Set(attacks.map(event => String(event.attack_event_id)));
  for (const event of projectiles) {
    if (!event.originating_attack_event_id || !attackIds.has(String(event.originating_attack_event_id))) failures.push(`projectile ${event.projectile_event_id} lacks a valid attack link`);
    if (!Array.isArray(event.phases) || !event.phases.length) failures.push(`projectile ${event.projectile_event_id} has no lifecycle phases`);
  }
  const damageByVictim = new Map();
  for (const event of damage) {
    const key = String(event.victim_runtime_id);
    damageByVictim.set(key, [...(damageByVictim.get(key) || []), String(event.damage_event_id)]);
  }
  for (const event of deaths) {
    if (!event.victim_runtime_id) failures.push(`death ${event.death_event_id} lacks victim runtime ID`);
    const expected = damageByVictim.get(String(event.victim_runtime_id)) || [];
    const actual = event.contributing_damage_event_ids || [];
    for (const id of expected) if (!actual.includes(id)) failures.push(`death ${event.death_event_id} omits contributing damage ${id}`);
  }
  return { commands, orders, transitions, attacks, projectiles, damage, deaths, samples };
}

export async function evaluateR1JValidatorContract({ repo, branch, validatedHead, expectedHead, rootFiles, preflight, manifest, sessions, forbiddenPatterns = [] }) {
  const failures = [];
  if (branch !== REQUIRED_R1J_BRANCH) failures.push(`wrong branch: ${branch}`);
  if (validatedHead !== expectedHead) failures.push(`validated HEAD ${validatedHead} differs from expected ${expectedHead}`);
  for (const name of REQUIRED_R1J_ROOT_FILES) if (!rootFiles.some(file => file.name === name && file.present)) failures.push(`missing root review-pack file ${name}`);
  if (!preflight.headed || preflight.hidden_window || preflight.godot_log_file_argument) failures.push('evidence is not headed/visible or uses a Godot log-file shortcut');
  for (const source of [preflight.source_sha, manifest.source_sha, ...sessions.map(session => session.provenance?.source_sha)]) if (source !== validatedHead) failures.push(`evidence source SHA mismatch: ${source}`);
  if (preflight.branch !== branch || manifest.branch !== branch) failures.push('branch provenance mismatch');
  if (preflight.production_scene !== 'scenes/main.tscn -> scenes/game_world.tscn') failures.push('production scene mismatch');
  if (preflight.default_runtime_unchanged !== true) failures.push('true default runtime preservation is not proven');
  if (preflight.no_direct_state_writes !== true || preflight.no_resource_injection !== true || preflight.no_free_units !== true) failures.push('forbidden capture mutation flags are not proven');
  if (sessions.length !== 2 || !sessions.every(session => ['A', 'B'].includes(session.session))) failures.push('exactly comparable sessions A and B are required');
  const parsed = sessions.map(session => validateGraph({ session, failures }));
  if (parsed.some(session => session.orders.length < 2)) failures.push('each session must contain attack-move and attack-target public orders');
  if (parsed.some(session => session.attacks.length === 0)) failures.push('each session must contain attack attempts');
  if (parsed.some(session => session.damage.length === 0)) failures.push('each session must contain attributed damage');
  if (parsed.some(session => session.samples.length < 10)) failures.push('each session lacks sufficient continuous state samples');
  for (const pattern of forbiddenPatterns) failures.push(`forbidden R1J pattern: ${pattern}`);
  const comparable = sessions[0]?.comparability?.same_force_plan === true && sessions[1]?.comparability?.same_force_plan === true && sessions[0]?.comparability?.same_configuration === true && sessions[1]?.comparability?.same_configuration === true;
  if (!comparable) failures.push('session comparability contract is false');
  return { schema:'v0436-r1j-complete-combat-attribution-validator-v1', branch, validatedHead, expectedHead, failures, passed: failures.length === 0, status: failures.length ? 'BLOCKED_R1J_EVIDENCE_VALIDATION' : R1J_STATUS, sessions: parsed.map((value, index) => ({ session:['A','B'][index], orders:value.orders.length, commands:value.commands.length, transitions:value.transitions.length, attacks:value.attacks.length, projectiles:value.projectiles.length, damage:value.damage.length, deaths:value.deaths.length, samples:value.samples.length })) };
}
