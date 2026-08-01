export const REQUIRED_R1H_BRANCH = 'codex/v0436-first-complete-conquest-victory';
export const R1H_PACK = 'artifacts/manual-review/v0436-r1h-natural-player-assault-viability/';
export const R1H_BLOCKER_STATUSES = Object.freeze([
  'BLOCKED_R1H_WORKERS_DID_NOT_RESUME_GATHERING',
  'BLOCKED_R1H_STANDARD_ECONOMY_STALLED',
  'BLOCKED_R1H_PREPARED_ASSAULT_FORCE_ELIMINATED',
  'BLOCKED_R1H_PLAYER_PRODUCTION_CANNOT_RECOVER',
  'BLOCKED_R1H_TARGET_UNREACHABLE',
  'BLOCKED_R1H_TARGET_NOT_TAKING_DAMAGE',
  'BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE',
  'BLOCKED_R1H_PREDICATE_TRUE_COMMANDER_NOT_DEFEATED',
  'BLOCKED_R1H_DEFEATED_TEAM_NOT_TRIGGERING_END_GAME',
  'BLOCKED_R1H_RESULT_REASON_INCORRECT',
  'BLOCKED_R1H_CONTINUE_ACTION_FAILED',
  'BLOCKED_R1H_PLAY_AGAIN_ACTION_FAILED',
  'BLOCKED_R1H_REPLAY_NOT_FRESH',
  'BLOCKED_R1H_CAPTURE_STRATEGY_INCONCLUSIVE',
]);

export const REQUIRED_R1H_FRAMES = Object.freeze([
  '01_R1H_STANDARD_MATCH_START.png',
  '02_R1H_WORKERS_RESUME_ECONOMY.png',
  '03_R1H_PRODUCTION_INFRASTRUCTURE.png',
  '04_R1H_MIXED_FORCE_IN_PRODUCTION.png',
  '05_R1H_FORCE_READINESS_TRUE.png',
  '06_R1H_ENEMY_DEFENDER_INVENTORY.png',
  '07_R1H_WAVE_ONE_COMMAND.png',
  '08_R1H_WAVE_ONE_COMBAT.png',
  '09_R1H_WAVE_ONE_TERMINAL_STATE.png',
]);

export const SUCCESS_R1H_FRAMES = Object.freeze([
  '17_R1H_FINAL_CONQUEST_PREDICATE.png',
  '18_R1H_GENUINE_VICTORY.png',
  '19_R1H_RESULT_UI.png',
  '20_R1H_MATCH_FROZEN.png',
  '21_R1H_CONTINUE_BUTTON.png',
  '22_R1H_CONTINUE_DESTINATION.png',
  '24_R1H_PLAY_AGAIN_BUTTON.png',
  '25_R1H_FRESH_REPLAY.png',
]);

export function evaluateR1HValidatorContract({
  branch,
  validatedHead,
  sourceShas = [],
  sessions = [],
  forbiddenPatterns = [],
  requiredRootFiles = [],
  requiredFramesBySession = {},
  successFramesBySession = {},
  blockers = [],
  directGameplayWritesRejected = true,
  normalEconomyEvidence = true,
  prototypeWiringPresent = true,
  captureManifestStatus = 'CAPTURE_COMPLETED',
}) {
  const failures = [];
  if (branch !== REQUIRED_R1H_BRANCH) failures.push(`wrong branch: ${branch}`);
  if (!validatedHead) failures.push('validated HEAD missing');
  if (!prototypeWiringPresent) failures.push('R1H opt-in wiring missing');
  if (captureManifestStatus !== 'CAPTURE_COMPLETED') failures.push(`capture manifest status: ${captureManifestStatus}`);
  if (!directGameplayWritesRejected) failures.push('direct gameplay writes were not rejected');
  if (!normalEconomyEvidence) failures.push('normal economy evidence missing');
  if (!Array.isArray(sessions) || sessions.length !== 2 || !['A', 'B'].every(id => sessions.includes(id))) {
    failures.push('exactly two R1H sessions A and B are required');
  }
  const uniqueSources = [...new Set((Array.isArray(sourceShas) ? sourceShas : []).filter(Boolean))];
  if (uniqueSources.length !== 1) failures.push('R1H evidence source SHA is missing or mixed');
  for (const root of requiredRootFiles) if (!root.present) failures.push(`missing root review-pack file ${root.name}`);
  for (const session of ['A', 'B']) {
    const required = requiredFramesBySession?.[session] || [];
    const success = successFramesBySession?.[session] || [];
    for (const frame of REQUIRED_R1H_FRAMES) if (!required.includes(frame)) failures.push(`missing required frame ${session}/${frame}`);
    const blocker = blockers.find(value => value.session === session) || null;
    if (blocker) {
      if (!R1H_BLOCKER_STATUSES.includes(String(blocker.status))) failures.push(`unknown blocker status ${session}: ${blocker.status}`);
      if (!blocker.reason) failures.push(`blocker reason missing for session ${session}`);
      if (success.length) failures.push(`blocker session ${session} contains success-only frames`);
      for (const key of ['force_plan', 'economy_timeline', 'completed_production', 'player_inventory', 'enemy_inventory', 'target_lifecycles', 'surviving_entities', 'resource_transactions', 'navigation_state', 'match_state', 'last_valid_frame', 'later_phases_not_run']) {
        if (!(key in blocker)) failures.push(`blocker missing ${session}.${key}`);
      }
    } else {
      for (const frame of SUCCESS_R1H_FRAMES) if (!success.includes(frame)) failures.push(`missing success frame ${session}/${frame}`);
    }
  }
  for (const pattern of forbiddenPatterns) failures.push(`forbidden capture pattern: ${pattern}`);
  return {
    schema: 'v0436-r1h-natural-player-assault-viability-validator-v1',
    branch,
    validatedHead,
    sourceSha: uniqueSources[0] || null,
    sessions,
    failures,
    passed: failures.length === 0,
    status: blockers.length ? blockers[0].status : (failures.length ? 'BLOCKED_R1H_EVIDENCE_VALIDATION' : 'PASSED_V0436_R1H_NATURAL_CONQUEST_RESULT_REPLAY_PROOF'),
  };
}
