export const F1_SCHEMA = 'v0436-f1-reinforcement-throughput-v1';

export function evaluateF1ReinforcementContract({ branch, head, configuration, throughput, files = [], sourceWritesRejected = true }) {
  const failures = [];
  const observed = configuration?.observed || {};
  if (!branch || !head) failures.push('branch or HEAD missing');
  if (observed.start_resources !== 'rich' || observed.game_speed !== 2) failures.push('fresh F1 configuration is not Rich at 2x');
  if (observed.map !== 'hollowspan' || observed.mode !== 'skirmish' || observed.victory !== 'conquest') failures.push('fresh F1 map/mode/victory configuration mismatch');
  if (observed.player_race !== 'barrosan' || observed.opponents?.[0]?.race !== 'lioraen' || observed.opponents?.[0]?.difficulty !== 'easy') failures.push('fresh F1 faction/opponent configuration mismatch');
  if (!sourceWritesRejected) failures.push('capture source permits direct gameplay-state writes');
  if (!throughput || throughput.schema !== F1_SCHEMA) failures.push('missing F1 throughput schema');
  if (!throughput?.theoretical_cost_time?.totals?.['5'] || !throughput?.theoretical_cost_time?.totals?.['10'] || !throughput?.theoretical_cost_time?.totals?.['15']) failures.push('missing authoritative 5/10/15 theory');
  const samples = throughput?.samples || [];
  if (samples.length < 3) failures.push('insufficient 10-second simulation samples: ' + samples.length);
  const buckets = samples.map(sample => sample.bucket);
  if (buckets.some((bucket, index) => index > 0 && bucket <= buckets[index - 1])) failures.push('sample buckets are not strictly increasing');
  if (samples.some(sample => !Number.isFinite(sample.match_time_seconds))) failures.push('sample contains invalid simulation time');
  if (!throughput?.no_player_offense_before_simulation_seconds || throughput.no_player_offense_before_simulation_seconds < 600) failures.push('no-offense first-ten-minute contract missing');
  if (!Array.isArray(throughput?.queue_results) || throughput.queue_results.length === 0) failures.push('missing real queue attempt evidence');
  if (!files.some(name => name.toLowerCase().endsWith('.png'))) failures.push('missing headed gameplay screenshot evidence');
  if (files.filter(name => name.toLowerCase().endsWith('.png')).some(name => !name.includes('F1'))) failures.push('F1 evidence includes non-F1-labeled screenshot');
  return { schema: 'v0436-f1-reinforcement-diagnosis-validator-v1', branch, head, failures, passed: failures.length === 0 };
}
