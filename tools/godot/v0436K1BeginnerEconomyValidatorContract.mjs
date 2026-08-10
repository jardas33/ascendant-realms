export function evaluateK1BeginnerEconomyContract({ benchmark, configuration, files, source }) {
  const errors = [];
  const requiredActions = ['TRAIN_WORKER', 'ASSIGN_WORKER', 'BUILD_HOUSING', 'BUILD_WAR_HALL', 'QUEUE_MILITARY', 'BUILD_MORE_HOUSING', 'QUEUE_NEXT_MILITARY'];
  const actions = new Set((benchmark?.action_trace || []).map(entry => typeof entry === 'string' ? entry : entry.action));
  const final = benchmark?.final || {};
  const observed = configuration?.observed || {};
  if (benchmark?.status !== 'PASS_K1_BEGINNER_ECONOMY_DRIVER') errors.push(`benchmark status is ${benchmark?.status || 'missing'}`);
  if (benchmark?.samples_every_simulation_seconds !== 5) errors.push('telemetry is not sampled every 5 simulation seconds');
  if ((benchmark?.samples || []).length < 10) errors.push('fewer than ten five-second telemetry samples were captured');
  for (const action of requiredActions) if (!actions.has(action)) errors.push(`missing required public action trace: ${action}`);
  if (observed.player_race !== 'barrosan' || observed.map !== 'hollowspan' || observed.start_resources !== 'rich' || observed.mode !== 'skirmish' || observed.victory !== 'conquest') errors.push('configuration is not Barrosan / Hollowspan / Rich / skirmish / conquest');
  if ((final.peak_workers || 0) < 6) errors.push(`worker target not reached: peak ${final.peak_workers || final.workers_total || 0}`);
  if (!final.war_hall_built) errors.push('completed War Hall not observed');
  if ((final.housing_count || 0) < 1) errors.push('housing not observed');
  if (final.completed_combat_units < 5) errors.push(`five-combat-unit target not reached: ${final.completed_combat_units}`);
  if ((final.player_offense_count || 0) !== 0) errors.push('player offense occurred during the opening benchmark');
  if (benchmark?.public_actions_only !== true || benchmark?.state_injection !== false) errors.push('benchmark was not explicitly public-action-only/state-injection-free');
  const forbidden = ['set("hp"', 'set("is_dead"', 'set("defeated"', 'spawn_unit(', 'free_units'];
  if (forbidden.some(token => source.includes(token))) errors.push('capture harness contains forbidden state injection token');
  const requiredFiles = ['01_K1_OPENING_BASELINE.png', '02_K1_ECONOMY_AND_FORCE_READY.png', 'k1-benchmark.json', 'k1-blocker.json', 'k1-match-configuration.json'];
  for (const file of requiredFiles) if (!files.includes(file)) errors.push(`missing K1 evidence file: ${file}`);
  return { passed: errors.length === 0, errors, status: benchmark?.status || 'MISSING', final, action_count: (benchmark?.action_trace || []).length, sample_count: (benchmark?.samples || []).length };
}
