export const E3R_STEP8_REPAIR_REQUIRED_FRAMES = Object.freeze([
  '01_MENU_ENTRY.png',
  '02_STEP1_CAMERA.png',
  '03_STEP2_SELECT.png',
  '04_STEP3_EXTRACTION.png',
  '05_STEP4_BUILDING_COMPLETE.png',
  '06_STEP5_UNIT_COMPLETE.png',
  '07_STEP6_HERO_COMMAND.png',
  '08_STEP7_REAL_DAMAGE.png',
  '09_STEP8_TARGET_LUME.png',
  '10_STEP8_UNITS_ENTER_RADIUS.png',
  '11_STEP8_PROGRESS_LOW.png',
  '12_STEP8_PROGRESS_HIGH.png',
  '13_STEP8_OWNER_TRANSITION.png',
  '14_STEP8_LUME_OWNED.png',
  '15_TUTORIAL_COMPLETE.png',
  '16_RETURN_TO_MAIN_MENU.png',
  '17_1366_STEP8.png',
  '18_1366_TUTORIAL_COMPLETE.png',
]);

export function evaluateE3RStep8RepairContract({ manifest, telemetry, files, sourceSha, branch }) {
  const failures = [];
  const present = new Set(files || []);
  for (const frame of E3R_STEP8_REPAIR_REQUIRED_FRAMES) if (!present.has(frame)) failures.push('missing required frame ' + frame);
  if (!manifest || manifest.schema !== 'v0436-e3r-step8-repair-manifest-v1') failures.push('missing or invalid step-8 repair manifest');
  if (manifest?.state_injection !== false) failures.push('state injection was not explicitly false');
  if (manifest?.natural_capture !== true) failures.push('manifest does not prove natural capture');
  if (manifest?.tutorial?.completed !== true || manifest?.tutorial?.step_index !== 9) failures.push('tutorial completion snapshot is not step 9');
  if (manifest?.return_flow?.main_menu_reached !== true) failures.push('return flow did not reach the main menu');
  if (manifest?.return_flow?.completion_button_exercised !== true) failures.push('completion button was not exercised');
  if (manifest?.capture_semantics?.before?.radius !== manifest?.capture_semantics?.after?.radius) failures.push('capture radius changed');
  if (manifest?.capture_semantics?.before?.rate !== manifest?.capture_semantics?.after?.rate) failures.push('capture rate changed');
  if (manifest?.capture_semantics?.contest_changed !== false) failures.push('contest semantics changed');
  if (manifest?.capture_semantics?.benefit_changed !== false) failures.push('benefit semantics changed');
  const samples = Array.isArray(telemetry?.samples) ? telemetry.samples : [];
  if (samples.length < 100) failures.push('telemetry sample count too low: ' + samples.length);
  if (!samples.some(sample => sample.expected_target?.same_instance === true)) failures.push('target identity was not proven');
  if (!samples.some(sample => Number(sample.progress) > 0.05)) failures.push('progress never exceeded 0.05');
  if (!samples.some(sample => Number(sample.owner_team) === Number(manifest?.player_team))) failures.push('natural owner transition was not observed');
  if (!samples.some(sample => sample.tutorial?.completed === true && Number(sample.tutorial?.step_index) === 9)) failures.push('tutorial did not observe completed step 9');
  if (sourceSha && manifest?.source_sha !== sourceSha) failures.push('manifest source SHA does not match validated HEAD');
  if (branch && manifest?.branch !== branch) failures.push('manifest branch does not match validated branch');
  return {
    schema: 'v0436-e3r-step8-repair-validator-v1',
    passed: failures.length === 0,
    status: failures.length === 0 ? 'PASSED_E3R_REAL_TUTORIAL_GOLDEN_PATH' : 'BLOCKED_E3R_STEP8_REPAIR_EVIDENCE',
    failures,
    required_frames: E3R_STEP8_REPAIR_REQUIRED_FRAMES,
  };
}
