export const REQUIRED_R1I_BRANCH = 'codex/v0436-first-complete-conquest-victory';
export const R1I_PACK = 'artifacts/manual-review/v0436-r1i-prepared-assault-combat-causality/';
export const R1I_STATUS = 'BLOCKED_R1I_COMBAT_CAUSALITY_INCONCLUSIVE';
export const REQUIRED_R1I_ROOT_FILES = Object.freeze([
  'preflight.json', 'executable-provenance.json', 'launch-contract.json',
  'r1h-baseline-contract.json', 'session-comparability-audit.json',
  'production-combat-definition-audit.json', 'damage-formula-audit.json',
  'session-a-command-ledger.json', 'session-b-command-ledger.json',
  'session-a-combat-events.json', 'session-b-combat-events.json',
  'session-a-casualty-ledger.json', 'session-b-casualty-ledger.json',
  'target-retention-audit.json', 'idle-and-attack-uptime-audit.json',
  'formation-and-navigation-audit.json', 'projectile-hit-audit.json',
  'expected-versus-observed-damage.json', 'time-to-kill-comparison.json',
  'causal-decision.json', 'accepted-and-rejected-evidence.json', 'final-validation.json',
]);
export const REQUIRED_R1I_FRAMES = Object.freeze([
  '01_R1I_SESSION_A_FORCE_READY.png', '02_R1I_SESSION_A_TARGET_ORDER.png',
  '03_R1I_SESSION_A_HERO_CONTACT.png', '04_R1I_SESSION_A_CASUALTY_STATE.png',
  '05_R1I_SESSION_A_TERMINAL.png', '06_R1I_SESSION_B_FORCE_READY.png',
  '07_R1I_SESSION_B_HERO_FOCUS_COMMAND.png', '08_R1I_SESSION_B_HERO_FOCUS_CONTACT.png',
  '09_R1I_SESSION_B_CASUALTY_STATE.png', '10_R1I_SESSION_B_TERMINAL.png',
  '11_R1I_CAUSAL_COMPARISON.png', '12_R1I_CONTACT_SHEET.png',
]);
export const R1I_CAUSAL_STATUSES = Object.freeze([
  'BLOCKED_R1I_TARGET_PRIORITY_OR_COMMAND_DEFECT_PROVEN',
  'BLOCKED_R1I_HERO_OVERMATCH_PROVEN',
  'BLOCKED_R1I_DAMAGE_OR_ARMOR_INTERACTION_PROVEN',
  'BLOCKED_R1I_FORMATION_OR_NAVIGATION_INTERFERENCE_PROVEN',
  'BLOCKED_R1I_PROJECTILE_OR_HIT_RESOLUTION_DEFECT_PROVEN',
  'BLOCKED_R1I_PREPARED_FORCE_COMPOSITION_INSUFFICIENT',
  R1I_STATUS,
]);

export function evaluateR1IValidatorContract({
  branch,
  validatedHead,
  sourceShas = [],
  sessions = [],
  rootFiles = [],
  frameFiles = {},
  provenance = {},
  baseline = {},
  sessionAudit = {},
  combatAudits = {},
  casualtyAudits = {},
  causalDecision = {},
  forbiddenPatterns = [],
}) {
  const failures = [];
  if (branch !== REQUIRED_R1I_BRANCH) failures.push(`wrong branch: ${branch}`);
  if (!validatedHead) failures.push('validated HEAD missing');
  const uniqueSources = [...new Set((Array.isArray(sourceShas) ? sourceShas : []).filter(Boolean))];
  if (uniqueSources.length !== 1 || uniqueSources[0] !== validatedHead) failures.push('R1I source SHA is missing, mixed, or not the validated HEAD');
  if (!Array.isArray(sessions) || sessions.length !== 2 || !['A', 'B'].every(id => sessions.includes(id))) failures.push('exactly two R1I sessions A and B are required');
  for (const root of REQUIRED_R1I_ROOT_FILES) if (!rootFiles.some(file => file.name === root && file.present)) failures.push(`missing root review-pack file ${root}`);
  for (const session of ['A', 'B']) {
    const files = frameFiles[session] || [];
    const required = session === 'A' ? REQUIRED_R1I_FRAMES.slice(0, 5) : REQUIRED_R1I_FRAMES.slice(5, 10);
    for (const frame of required) if (!files.includes(frame)) failures.push(`missing fresh headed frame ${session}/${frame}`);
    if (files.some(file => file.includes('R1H'))) failures.push(`stale R1H frame present in R1I session ${session}`);
    if (!sessionAudit[session]?.blocker_status) failures.push(`missing truthful blocker status for session ${session}`);
    if (!sessionAudit[session]?.comparable) failures.push(`session comparability failed for session ${session}`);
    if (!combatAudits[session]?.attributed_event_count) failures.push(`missing damage attribution for session ${session}`);
    if (!combatAudits[session]?.command_count) failures.push(`missing command ledger for session ${session}`);
    if (!casualtyAudits[session]?.present) failures.push(`missing casualty ledger for session ${session}`);
  }
  if (!provenance.headed || provenance.hidden_window || provenance.godot_log_file_argument) failures.push('evidence is not headed/visible or uses a Godot log-file shortcut');
  if (provenance.branch !== branch || provenance.source_sha !== validatedHead) failures.push('preflight provenance mismatch');
  if (baseline.production_scene !== 'scenes/main.tscn -> scenes/game_world.tscn') failures.push('R1H production scene baseline mismatch');
  if (baseline.resource_injection !== false || baseline.free_units !== false || baseline.direct_state_writes !== false) failures.push('capture baseline permits forbidden injection or direct writes');
  if (causalDecision.status !== R1I_STATUS) failures.push(`causal decision is not fail-closed inconclusive: ${causalDecision.status}`);
  if (causalDecision.supported_by_sessions?.join(',') !== 'A,B') failures.push('causal decision is not supported by both comparable sessions');
  for (const pattern of forbiddenPatterns) failures.push(`forbidden capture pattern: ${pattern}`);
  return {
    schema: 'v0436-r1i-prepared-assault-combat-causality-validator-v1',
    branch, validatedHead, sourceSha: uniqueSources[0] || null, sessions, failures,
    passed: failures.length === 0, status: failures.length ? 'BLOCKED_R1I_EVIDENCE_VALIDATION' : R1I_STATUS,
  };
}
