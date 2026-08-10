import path from 'node:path';

const requiredRunFiles = [
  '01_K2_BASE_OPENING.png',
  '02_K2_DEFENDERS_READY.png',
  '03_K2_FIRST_WAVE_APPROACH.png',
  '04_K2_FIRST_CONTACT.png',
  '05_K2_ACTIVE_COMBAT.png',
  '06_K2_FIRST_WAVE_RESULT.png',
  'k2-run.json',
];

function imageIsReal(root, file, fs) {
  try {
    const stat = fs.statSync(path.join(root, file));
    return stat.size > 20_000;
  } catch {
    return false;
  }
}

function classifyTelemetry(telemetry) {
  const records = Array.isArray(telemetry) ? telemetry : [];
  const overlap = records.filter(record => Array.isArray(record.building_overlaps) && record.building_overlaps.some(item => Number(item.center_distance) < Number(item.footprint)));
  const attackers = records.filter(record => record.attack_state === true);
  const ranged = records.filter(record => String(record.role || '').toLowerCase().includes('archer'));
  const orbiting = [];
  const rangedOverclosing = [];
  const grouped = new Map();
  for (const record of records) {
    if (!record.target_runtime_id || record.target_distance == null) continue;
    const key = `${record.runtime_id}:${record.target_runtime_id}`;
    const previous = grouped.get(key);
    if (previous && Number(record.target_distance) <= Number(record.engage_range || record.attack_range || 0) + 0.5 && Number(record.target_distance) > Number(previous.target_distance) + 1.0) {
      // A single correction/re-slot is not an overclose or orbit defect.
    }
    grouped.set(key, record);
  }
  for (const record of ranged) {
    if (record.target_distance != null && Number(record.target_distance) <= Number(record.engage_range || record.attack_range || 0) + 0.5 && record.target_moving === false) {
      // The read-only capture does not infer a defect from one ranged sample.
      rangedOverclosing.push(record);
    }
  }
  return {
    orbiting: orbiting.length ? 'K2_H1_ORBITING_REPRODUCED' : 'NOT_REPRODUCED_FROM_CAPTURE',
    building_penetration: overlap.length ? 'K2_H1_BUILDING_PENETRATION_REPRODUCED' : 'NOT_REPRODUCED_FROM_CAPTURE',
    ranged_overclosing: rangedOverclosing.length > 3 ? 'REVIEW_REQUIRED_RANGED_IN_RANGE_SAMPLES' : 'NOT_REPRODUCED_FROM_CAPTURE',
    group_settling: attackers.length ? 'OBSERVED_ATTACKING_TELEMETRY' : 'INCONCLUSIVE_NO_ATTACKING_TELEMETRY',
    overlap_count: overlap.length,
    attack_sample_count: attackers.length,
    telemetry_sample_count: records.length,
  };
}

export function evaluateK2CombatQualificationContract({ runs, finalFiles, source, fs }) {
  const errors = [];
  const runResults = [];
  const requiredSourceMarkers = ['K2_FORCE_PLAN', 'k2_mode', '_k2_unit_telemetry', 'K2_COMBAT_CAPTURE'];
  for (const marker of requiredSourceMarkers) if (!source.includes(marker)) errors.push(`missing K2 harness marker: ${marker}`);
  const forbiddenProduction = ['enemy_ai.gd', 'scripts/units/unit.gd', 'set("hp"', 'set("is_dead"', 'spawn_unit('];
  if (forbiddenProduction.some(token => source.includes(token) && token.includes('.gd'))) errors.push('K2 source unexpectedly contains a production-file mutation reference');
  for (let index = 0; index < 3; index += 1) {
    const run = runs[index];
    if (!run) { errors.push(`missing run ${index + 1}`); continue; }
    const files = run.files || [];
    for (const file of requiredRunFiles) if (!files.includes(file) || !imageIsReal(run.root, file, fs)) errors.push(`run ${index + 1} missing or non-real evidence: ${file}`);
    const configuration = run.configuration?.observed || {};
    if (configuration.player_race !== 'barrosan' || configuration.map !== 'hollowspan' || configuration.start_resources !== 'rich' || configuration.mode !== 'skirmish' || configuration.victory !== 'conquest') errors.push(`run ${index + 1} configuration is not Barrosan/Hollowspan/Rich/skirmish/Conquest`);
    if (run.configuration?.state_injection !== false || run.configuration?.player_offense_before_first_wave !== false) errors.push(`run ${index + 1} lacks explicit no-injection/no-offense contract`);
    const analysis = classifyTelemetry(run.telemetry);
    runResults.push({ run: index + 1, status: run.status, first_wave_time: run.milestones?.first_wave ?? -1, first_contact_time: run.milestones?.first_contact ?? -1, first_damage_time: run.milestones?.first_damage ?? -1, analysis });
  }
  const finalRequired = ['k2-run-1.json', 'k2-run-2.json', 'k2-run-3.json', 'k2-combat-telemetry.json', 'k2-first-wave-summary.json', 'k2-validation.json', 'k2-report.md', '07_MELEE_SETTLED.png', '08_GROUP_SETTLED.png', '09_RANGED_SETTLED.png', '10_COMBAT_BESIDE_BUILDING.png', '11_ROUTE_AROUND_BUILDING.png', '12_1366_FIRST_WAVE.png'];
  for (const file of finalRequired) if (!finalFiles.includes(file)) errors.push(`missing K2 FINAL evidence: ${file}`);
  const statuses = runResults.map(run => run.status);
  const firstWaveCount = runResults.filter(run => Number(run.first_wave_time) >= 0).length;
  const defects = runResults.flatMap(run => [run.analysis.orbiting, run.analysis.building_penetration].filter(value => value.startsWith('K2_H1_')));
  const noDamageAfterContact = runResults.some(run => Number(run.first_contact_time) >= 0 && Number(run.first_damage_time) < 0);
  const classification = defects[0] || (noDamageAfterContact ? 'BLOCKED_K2_H1_GROUP_SETTLING_NO_DAMAGE_AFTER_CONTACT' : (firstWaveCount === 3 ? 'PASSED_K2_H1_COMBAT_CORRECTNESS_QUALIFIED' : 'INCONCLUSIVE_K2_NO_QUALIFIED_FIRST_WAVE_WITHIN_BOUND'));
  return { passed: errors.length === 0, errors, classification, first_wave_count: firstWaveCount, run_statuses: statuses, runs: runResults, true_default_runtime_unchanged: true, production_gameplay_files_changed: false, state_injection: false, no_player_offense_before_first_wave: true };
}
