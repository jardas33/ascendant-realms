import { describe, expect, it } from 'vitest';
import { evaluateR1JValidatorContract, REQUIRED_R1J_BRANCH, R1J_STATUS } from './v0436R1JCompleteCombatAttributionValidator.mjs';

const head = 'ae9fe9022fd2efeafd90f207a448358b52ed419c';
const rootFiles = Array.from({ length: 24 }, (_, index) => ({ name: `root-${index}`, present: true }));
const base = {
  repo: '.', branch: REQUIRED_R1J_BRANCH, validatedHead: head, expectedHead: head,
  rootFiles: [
    'preflight.json','executable-provenance.json','launch-contract.json','r1i-frozen-baseline.json','session-comparability.json','combat-definition-audit.json','damage-formula-audit.json','complete-command-event-graph.json','complete-target-transition-graph.json','complete-attack-event-graph.json','complete-projectile-event-graph.json','complete-damage-event-graph.json','complete-death-attribution.json','per-attacker-uptime.json','per-attacker-effective-dps.json','range-and-reachability-audit.json','formation-and-collision-audit.json','expected-versus-observed.json','causal-decision.json','repair-decision.json','repair-diff-audit.json','accepted-and-rejected-evidence.json','capture-manifest.json','final-validation.json',
  ].map(name => ({ name, present: true })),
  preflight: { headed:true, hidden_window:false, godot_log_file_argument:false, source_sha:head, branch:REQUIRED_R1J_BRANCH, production_scene:'scenes/main.tscn -> scenes/game_world.tscn', default_runtime_unchanged:true, no_direct_state_writes:true, no_resource_injection:true, no_free_units:true },
  manifest: { source_sha:head, branch:REQUIRED_R1J_BRANCH },
  sessions: ['A','B'].map(session => ({ session, provenance:{source_sha:head}, comparability:{same_force_plan:true,same_configuration:true}, orders:[{order_event_id:'o1'},{order_event_id:'o2'}], commands:[{unit_command_event_id:'c1'}], transitions:[{target_transition_event_id:'t1',reason:'public_order'}], attacks:[{attack_event_id:'a1'}], projectiles:[{projectile_event_id:'p1',originating_attack_event_id:'a1',phases:[{phase:'impact'}]}], damage:[{damage_event_id:'d1',attack_event_id:'a1',projectile_event_id:'p1',victim_runtime_id:'v1',source_runtime_id:'u1',observed_hp_delta:5,final_damage:5,expected_applied_damage:5}], deaths:[], samples:Array.from({length:10},(_,i)=>({sample_event_id:`s${i}`})) })),
};

describe('v0.436-R1J complete combat attribution contract', () => {
  it('accepts complete bounded attribution evidence as inconclusive until classification', async () => {
    const result = await evaluateR1JValidatorContract(base);
    expect(result).toMatchObject({ passed:true, status:R1J_STATUS });
  });
  it('rejects unknown target transitions and unlinked damage', async () => {
    const unknown = structuredClone(base); unknown.sessions[0].transitions[0].reason = 'unknown';
    expect((await evaluateR1JValidatorContract(unknown)).passed).toBe(false);
    const unlinked = structuredClone(base); unlinked.sessions[0].damage[0].attack_event_id = '';
    expect((await evaluateR1JValidatorContract(unlinked)).passed).toBe(false);
  });
  it('rejects wrong provenance and non-headed evidence', async () => {
    const wrong = structuredClone(base); wrong.branch = 'main';
    expect((await evaluateR1JValidatorContract(wrong)).passed).toBe(false);
    const hidden = structuredClone(base); hidden.preflight.hidden_window = true;
    expect((await evaluateR1JValidatorContract(hidden)).passed).toBe(false);
  });
});
