import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0287"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0287"));
const manual = join(repo, "artifacts", "manual-review", "v0287-barrosan-reserve-assigned-to-bridge-step");
const docPath = join(repo, "docs", "V0287_BARROSAN_RESERVE_ASSIGNED_TO_BRIDGE_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "reserve-assigned-to-bridge-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0287-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0287_preflight_head_ci_resolution.png",
  "02_v0287_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0287_retained_v0282_v0284_baseline_ledger_proof.png",
  "04_v0287_manual_fixture_baseline_clean_hud.png",
  "05_v0287_engage_available_before_click.png",
  "06_v0287_engage_armed.png",
  "07_v0287_commit_engage_clicked.png",
  "08_v0287_post_commit_pressure_checked_ashen_braced.png",
  "09_v0287_hold_line_available_after_commit_locked.png",
  "10_v0287_hold_line_clicked.png",
  "11_v0287_line_held_exactly_once.png",
  "12_v0287_ashen_contained_exactly_once.png",
  "13_v0287_select_field_barracks_after_hold_line.png",
  "14_v0287_train_militia_available_reserve_slot_empty.png",
  "15_v0287_train_clicked.png",
  "16_v0287_reserve_ready_exactly_once.png",
  "17_v0287_barracks_assign_to_bridge_available.png",
  "18_v0287_assign_clicked.png",
  "19_v0287_reserve_assigned_exactly_once.png",
  "20_v0287_barracks_card_reserve_assigned_bridge_support_pending.png",
  "21_v0287_defender_card_acknowledges_reserve_assigned.png",
  "22_v0287_repeat_assign_no_duplicate_assignment_no_stack.png",
  "23_v0287_resources_unchanged_after_train_and_assign.png",
  "24_v0287_reserve_marker_no_movement_pathing_attack_deploy_behavior.png",
  "25_v0287_watchpost_no_hold_line_engage_commit_ashen_reserve_assign.png",
  "26_v0287_clear_guard_settles_defender_contact_clean_after_assigned.png",
  "27_v0287_reguard_clean_after_assigned_no_auto_deploy.png",
  "28_v0287_no_projectile_damage_hp_loss_death_despawn.png",
  "29_v0287_ui_layout_diagnostic_proof_retained.png",
  "30_v0287_contact_sheet.png",
  "31_v0287_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0287_manual_fixture_baseline_clean_hud",
  "v0287_engage_available_before_click",
  "v0287_engage_armed",
  "v0287_commit_engage_clicked",
  "v0287_post_commit_pressure_checked_ashen_braced",
  "v0287_hold_line_available_after_commit_locked",
  "v0287_hold_line_clicked",
  "v0287_line_held_exactly_once",
  "v0287_ashen_contained_exactly_once",
  "v0287_select_field_barracks_after_hold_line",
  "v0287_train_militia_available_reserve_slot_empty",
  "v0287_train_clicked",
  "v0287_reserve_ready_exactly_once",
  "v0287_barracks_assign_to_bridge_available",
  "v0287_assign_clicked",
  "v0287_reserve_assigned_exactly_once",
  "v0287_barracks_card_reserve_assigned_bridge_support_pending",
  "v0287_defender_card_acknowledges_reserve_assigned",
  "v0287_repeat_assign_no_duplicate_assignment_no_stack",
  "v0287_resources_unchanged_after_train_and_assign",
  "v0287_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0287_watchpost_no_hold_line_engage_commit_ashen_reserve_assign",
  "v0287_clear_guard_settles_defender_contact_clean_after_assigned",
  "v0287_reguard_clean_after_assigned_no_auto_deploy",
  "v0287_no_projectile_damage_hp_loss_death_despawn",
];

const readyModes = new Set([
  "v0287_train_clicked",
  "v0287_reserve_ready_exactly_once",
  "v0287_barracks_assign_to_bridge_available",
]);

const assignedModes = new Set([
  "v0287_assign_clicked",
  "v0287_reserve_assigned_exactly_once",
  "v0287_barracks_card_reserve_assigned_bridge_support_pending",
  "v0287_defender_card_acknowledges_reserve_assigned",
  "v0287_repeat_assign_no_duplicate_assignment_no_stack",
  "v0287_resources_unchanged_after_train_and_assign",
  "v0287_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0287_clear_guard_settles_defender_contact_clean_after_assigned",
  "v0287_reguard_clean_after_assigned_no_auto_deploy",
  "v0287_no_projectile_damage_hp_loss_death_despawn",
]);

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, mode) {
  return snaps[mode] ?? {};
}

function passive(snap) {
  const c = snap.firstContact ?? {};
  const forbidden = [
    "automaticMovementAdded", "autoMoveAttempted", "automaticAttackAdded", "watchpostCausedDamage",
    "watchpostAttackAdded", "projectilesAdded", "towerAttackAdded", "slowAdded", "redirectAdded",
    "enemyPathingChanged", "enemyAiChanged", "waveTimingChanged", "economyAdded", "collisionChanged",
    "fogOfWarAdded", "broadVisionAdded", "enemyStopped", "enemyDespawned", "enemyDeath",
    "engagementDamageAdded", "engagementAutoMoveAdded", "engagementAutoAttackAdded",
    "engagementProjectileAdded", "engagementVisualIsProjectile", "reserveMarkerMoved", "reserveMarkerPathingAdded",
    "reserveMarkerDeployAction", "reserveMarkerAttackAdded", "reserveMarkerEngageAction", "reserveMarkerCommitAction",
    "reserveMarkerHoldLineAction", "reserveMarkerTakesDamage", "reserveMarkerDealsDamage", "reserveMarkerDeath",
    "reserveMarkerDespawned", "autoDeployAdded", "pressureChangedByAssignment",
  ];
  return !forbidden.some((key) => Boolean(c[key]) || Boolean(snap[key]));
}

function shortHudText(snap) {
  const lines = snap.hudTextLines ?? {};
  const values = [lines.nameAndRole, lines.primaryState, lines.tacticalFacts, lines.readiness, lines.topStrip].map((v) => String(v ?? ""));
  return values.every((value) => value.length > 0 && value.length <= 74) &&
    !values.some((value) => /validator|projectile, damage|enemy death\/despawn/i.test(value));
}

function labelCount(snap, label) {
  return (snap.renderedTacticalWorldLabelTexts ?? []).filter((x) => x === label).length;
}

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanReserveAssignedToBridgeStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.287") errors.push("true default capture leaked v0.287 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0287_") || String(c.id ?? "").startsWith("v0287_"))) errors.push("true default capture contains v0.287 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.287") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.287`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 25) errors.push(`opt-in runtime expected 25 v0.287 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.287 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.287 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.287 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(snap)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.reserveAssignedToBridgeStepOnly || !snap.v0286ReserveReadyRetained || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.assignmentIntentionOnly || !snap.noCombatMovementPathingEconomyMutation) errors.push(`${mode} is not assignment-only with v0.286/v0.285/v0.284 retained`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
    if (readyModes.has(mode) && (labelCount(snap, "RESERVE READY") !== 1 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || !snap.reserveReadyExactlyOne)) errors.push(`${mode} does not render RESERVE READY exactly once before assignment`);
    if (assignedModes.has(mode) && (labelCount(snap, "RESERVE ASSIGNED") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || !snap.reserveAssignedExactlyOne || !snap.assignmentDoesNotCreateSecondMarker)) errors.push(`${mode} does not render exactly one assigned label/marker after assignment`);
  }

  if (snapshot(snaps, "v0287_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0287_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0287_commit_engage_clicked", "v0287_post_commit_pressure_checked_ashen_braced", "v0287_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "PRESSURE CHECKED") !== 1 || labelCount(snap, "ASHEN BRACED") !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0287_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");
  for (const mode of ["v0287_hold_line_clicked", "v0287_line_held_exactly_once", "v0287_ashen_contained_exactly_once"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "LINE HELD") !== 1 || labelCount(snap, "ASHEN CONTAINED") !== 1) errors.push(`${mode} did not render LINE HELD and ASHEN CONTAINED exactly once`);
    if ((snap.renderedTacticalWorldLabelTexts ?? []).includes("ASHEN BRACED") || (snap.renderedTacticalWorldLabelTexts ?? []).includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }

  if (!snapshot(snaps, "v0287_train_militia_available_reserve_slot_empty").barracksTrainAvailable) errors.push("Field Barracks Train was not available with reserve slot empty");
  if (!snapshot(snaps, "v0287_train_clicked").trainCreatesReserveReadyExactlyOnce) errors.push("Train did not create exactly one RESERVE READY marker");
  if (!snapshot(snaps, "v0287_barracks_assign_to_bridge_available").assignAvailableAfterReserveReady) errors.push("Assign did not become available after RESERVE READY");
  if (!snapshot(snaps, "v0287_assign_clicked").assignCreatesReserveAssignedExactlyOnce) errors.push("Assign did not create exactly one RESERVE ASSIGNED state");
  if (!snapshot(snaps, "v0287_repeat_assign_no_duplicate_assignment_no_stack").repeatAssignNoDuplicateAssignment) errors.push("repeat Assign duplicated or stacked assignment");
  if (!snapshot(snaps, "v0287_resources_unchanged_after_train_and_assign").resourcesUnchangedAfterTrainAndAssign) errors.push("resources changed after Train or Assign");
  if (!snapshot(snaps, "v0287_reserve_marker_no_movement_pathing_attack_deploy_behavior").reserveMarkerNoMovementPathingAttackDeployBehavior) errors.push("reserve marker gained movement/pathing/attack/deploy/engage/commit/hold behavior");
  if (!snapshot(snaps, "v0287_watchpost_no_hold_line_engage_commit_ashen_reserve_assign").watchpostNoReserveAssignAction) errors.push("Watchpost leaked reserve, assign, or combat action");
  if (!snapshot(snaps, "v0287_defender_card_acknowledges_reserve_assigned").defenderCardAcknowledgesReserveAssigned) errors.push("defender card did not acknowledge Reserve assigned");
  if (!snapshot(snaps, "v0287_clear_guard_settles_defender_contact_clean_after_assigned").clearGuardSettlesDefenderContactCleanAfterAssigned) errors.push("Clear Guard did not settle defender contact cleanly after assignment");
  if (!snapshot(snaps, "v0287_reguard_clean_after_assigned_no_auto_deploy").reguardCleanAfterAssignedNoAutoDeploy) errors.push("Reguard was not clean after assignment or auto-deployed");
  if (!snapshot(snaps, "v0287_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/HP loss/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 27) errors.push(`expected 27 v0.287 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.287 Barrosan Reserve Assigned To Bridge Step Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `465aa5eb3fe0a5b1745fe06d2500c12aa89ac2ab`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0287-barrosan-reserve-assigned-to-bridge-step/`.", "",
    "## What changed", "",
    "- Added a static opt-in `Assign` state after the accepted v0.286 `RESERVE READY` state.",
    "- Field Barracks selected-card text now shows Assign availability, then `RESERVE ASSIGNED` / bridge support pending.",
    "- The East bridge defender card acknowledges pending reserve support without changing combat behavior.",
    "- Repeating Assign preserves one assignment marker and records no duplicate assignment state.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.287 review steps.",
    "- v0.286 Reserve Ready and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before assignment.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.288.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0287_VALIDATION" : "PASS_V0287_BARROSAN_RESERVE_ASSIGNED_TO_BRIDGE_STEP_VALIDATION";
  writeFileSync(join(root, "v0287-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
