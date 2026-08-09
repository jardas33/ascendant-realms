export const F2_REQUIRED_FRAMES = Object.freeze([
  '01_F2_STANDARD_MATCH_START.png',
  '02_F2_WORKERS_RESUME_ECONOMY.png',
  '03_F2_PRODUCTION_INFRASTRUCTURE.png',
  '04_F2_ARMY_READY_12PLUS.png',
  '06_F2_MIXED_ARMY.png',
  '07_F2_MAIN_ASSAULT.png',
  '08_F2_ENEMY_ARMY_ENGAGEMENT.png',
]);

export function evaluateF2NaturalConquestContract({ branch, head, config, status, reason, blockerPhase = '', files = [], samples = [], workerExpansion = [], queueResults = [], sourceWritesRejected = true, resourceTransactions = 0 }) {
  const failures = [];
  if (!branch || !head) failures.push('branch or HEAD missing');
  const observed = config?.observed || {};
  const earlyRuntimeBlocker = /^BLOCKED_F2_SYSTEM_DEFECT_/.test(status || '') && blockerPhase === 'runtime_startup' && files.includes('f2-blocker.json');
  if (!earlyRuntimeBlocker) {
    if (observed.start_resources !== 'rich') failures.push(`observed start_resources is ${observed.start_resources}, expected rich`);
    if (observed.game_speed !== 2) failures.push('observed game speed is not 2x');
    if (observed.map !== 'hollowspan' || observed.mode !== 'skirmish' || observed.victory !== 'conquest') failures.push('match identity/configuration mismatch');
    if (observed.player_race !== 'barrosan' || observed.opponents?.[0]?.race !== 'lioraen' || observed.opponents?.[0]?.difficulty !== 'easy') failures.push('faction/opponent/difficulty mismatch');
  }
  if (!sourceWritesRejected) failures.push('capture source direct gameplay writes not rejected');
  if (!status || !/^(PASSED_F2_NATURAL_CONQUEST|FAILED_F2_NATURAL_PLAYER_DEFEAT|INCONCLUSIVE_F2_TIME_LIMIT|BLOCKED_F2_SYSTEM_DEFECT_)/.test(status)) failures.push(`untruthful F2 terminal classification: ${status}`);
  if (!reason) failures.push('F2 reason missing');
  if (!earlyRuntimeBlocker) {
    for (const frame of F2_REQUIRED_FRAMES) if (!files.includes(frame)) failures.push(`missing real headed frame ${frame}`);
    if (files.filter(name => name.endsWith('.png')).length < 5) failures.push('insufficient real gameplay PNG evidence');
    if (samples.length < 2) failures.push('missing 10-second normal-play telemetry samples');
    if (!workerExpansion.length) failures.push('missing normal HQ worker-expansion ledger');
    if (!queueResults.length) failures.push('missing real military queue evidence');
    if (!resourceTransactions) failures.push('missing real resource transaction evidence');
  }
  if (status !== 'PASSED_F2_NATURAL_CONQUEST' && files.some(name => /NATURAL_CONQUEST|GENUINE_VICTORY|RESULT_UI/.test(name))) failures.push('non-success result contains victory-only evidence');
  return { schema: 'v0436-f2-natural-conquest-validator-v1', branch, head, status: status || 'BLOCKED_F2_EVIDENCE_VALIDATION', failures, passed: failures.length === 0 };
}
