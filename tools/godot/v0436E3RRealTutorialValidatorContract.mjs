export const E3R_PACK = 'artifacts/manual-review/v0436-e3r-real-tutorial/';
export const E3R_REQUIRED_FRAMES = Object.freeze([
  '01_MAIN_MENU_TUTORIAL_ENTRY.png', '02_STEP1_CAMERA.png', '03_STEP2_SELECT.png',
  '04_STEP3_GATHER_EXTRACTION.png', '05_STEP4_FOUNDATION.png', '06_STEP4_BUILD_COMPLETE.png',
  '07_STEP5_TRAINING.png', '08_STEP5_UNIT_COMPLETE.png', '09_STEP6_HERO_COMMAND.png',
  '10_STEP7_ATTACK.png', '11_STEP7_REAL_DAMAGE.png', '12_STEP8_LUME_TARGET.png',
  '13_STEP8_UNITS_IN_CAPTURE_ZONE.png', '14_STEP8_CAPTURE_PROGRESS.png', '15_STEP8_LUME_OWNED.png',
  '16_TUTORIAL_COMPLETE.png', '17_TUTORIAL_RETURN_MENU.png', '18_1366_TUTORIAL_ACTIVE.png',
  '19_1366_TUTORIAL_COMPLETE.png',
]);

const E3R_BLOCKERS = new Set([
  'BLOCKED_E3R_TUTORIAL_NOT_STARTED', 'BLOCKED_E3R_TUTORIAL_NAVIGATION',
  'BLOCKED_E3R_STEP_1_REAL_EVENT_NOT_OBSERVED', 'BLOCKED_E3R_STEP_2_REAL_EVENT_NOT_OBSERVED',
  'BLOCKED_E3R_STEP_3_REAL_EVENT_NOT_OBSERVED', 'BLOCKED_E3R_STEP_4_REAL_EVENT_NOT_OBSERVED',
  'BLOCKED_E3R_STEP_5_REAL_EVENT_NOT_OBSERVED', 'BLOCKED_E3R_STEP_6_REAL_EVENT_NOT_OBSERVED',
  'BLOCKED_E3R_STEP_7_REAL_EVENT_NOT_OBSERVED', 'BLOCKED_E3R_LUME_UNREACHABLE',
  'BLOCKED_E3R_LUME_OWNERSHIP_NOT_RECOGNIZED',
]);

export function evaluateE3RValidatorContract({
  branch, validatedHead, sourceSha, manifest, files = [], blocker = null,
  sourceWritesRejected = true, blackFrameRejected = true,
}) {
  const failures = [];
  if (!branch) failures.push('branch missing');
  if (!validatedHead) failures.push('validated HEAD missing');
  if (!sourceSha || sourceSha !== validatedHead) failures.push('manifest source SHA does not equal validated HEAD');
  if (!manifest || manifest.schema !== 'v0436-e3r-real-tutorial-v1') failures.push('missing or invalid E3R manifest');
  if (manifest && manifest.menu_entry !== 'How to Play button pressed through the normal main menu') failures.push('non-menu tutorial entry provenance');
  if (!sourceWritesRejected) failures.push('capture source direct gameplay writes not rejected');
  if (!blackFrameRejected) failures.push('black-frame rejection failed');
  const names = new Set(files);
  const presentFrames = E3R_REQUIRED_FRAMES.filter(name => names.has(name));
  if (blocker) {
    if (!E3R_BLOCKERS.has(String(blocker.status))) failures.push(`unknown E3R blocker ${blocker.status}`);
    if (!blocker.reason) failures.push('truthful blocker reason missing');
    if (names.has('15_STEP8_LUME_OWNED.png') || names.has('16_TUTORIAL_COMPLETE.png') || names.has('17_TUTORIAL_RETURN_MENU.png') || names.has('19_1366_TUTORIAL_COMPLETE.png')) {
      failures.push('blocked E3R pack contains success-only evidence');
    }
    for (const key of ['status', 'reason', 'last_valid_frame', 'later_phases_not_run']) if (!(key in blocker)) failures.push(`blocker missing ${key}`);
  } else {
    for (const frame of E3R_REQUIRED_FRAMES) if (!names.has(frame)) failures.push(`missing required frame ${frame}`);
  }
  return {
    schema: 'v0436-e3r-real-tutorial-validator-v1', branch, validatedHead,
    sourceSha: sourceSha || null, status: blocker?.status || (failures.length ? 'BLOCKED_E3R_EVIDENCE_VALIDATION' : 'PASSED_V0436_E3R_REAL_TUTORIAL'),
    truthfulBlockerAccepted: Boolean(blocker), presentFrames, failures, passed: failures.length === 0,
  };
}
