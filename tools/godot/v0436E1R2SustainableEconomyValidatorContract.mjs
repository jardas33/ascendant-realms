export const E1R2_PACK = 'artifacts/manual-review/v0436-e1r2-sustainable-economy-natural-conquest-attempt-02/';
export const E1R2_BLOCKER = 'INCONCLUSIVE_E1R_TIME_LIMIT';
export const E1R2_REQUIRED_FRAMES = Object.freeze(['01_E1R_STANDARD_MATCH_START.png', '02_E1R_WORKERS_RESUME_ECONOMY.png', '03_E1R_PRODUCTION_INFRASTRUCTURE.png', '04_E1R_MIXED_FORCE_IN_PRODUCTION.png', '05_E1R_FORCE_READINESS_TRUE.png']);

export function evaluateE1R2ValidatorContract({ branch, head, config, blocker, files = [], sourceWritesRejected = true, resourceTransactions = 0, queueResults = [] }) {
  const failures = [];
  if (!branch || !head) failures.push('branch or HEAD missing');
  const observed = config?.observed || {};
  if (observed.start_resources !== 'rich') failures.push(`observed start_resources is ${observed.start_resources}, expected rich`);
  if (observed.game_speed !== 2) failures.push('observed game speed is not 2x');
  if (observed.map !== 'hollowspan' || observed.mode !== 'skirmish' || observed.victory !== 'conquest') failures.push('match identity/configuration mismatch');
  if (observed.player_race !== 'barrosan' || observed.opponents?.[0]?.race !== 'lioraen' || observed.opponents?.[0]?.difficulty !== 'easy') failures.push('faction/opponent/difficulty mismatch');
  if (!sourceWritesRejected) failures.push('capture source direct gameplay writes not rejected');
  for (const frame of E1R2_REQUIRED_FRAMES) if (!files.includes(frame)) failures.push(`missing real headed frame ${frame}`);
  if (!blocker || blocker.status !== E1R2_BLOCKER) failures.push('missing truthful E1R2 bounded result');
  if (blocker && !blocker.reason) failures.push('E1R2 blocker reason missing');
  if (!resourceTransactions) failures.push('no real resource transaction evidence');
  if (!queueResults.length) failures.push('no real production queue evidence');
  const successOnly = files.filter(name => /VICTORY|RESULT_UI|CONTINUE|PLAY_AGAIN|FINAL_CONQUEST/.test(name));
  if (blocker && successOnly.length) failures.push(`blocker contains success-only frames: ${successOnly.join(',')}`);
  return { schema: 'v0436-e1r2-sustainable-economy-validator-v1', branch, head, status: blocker?.status || 'BLOCKED_E1R2_EVIDENCE_VALIDATION', blockerAccepted: Boolean(blocker), failures, passed: failures.length === 0 };
}
