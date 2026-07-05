import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0289"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0289"));
const manual = join(repo, "artifacts", "manual-review", "v0289-barrosan-reserve-support-order-prepared-step");
const docPath = join(repo, "docs", "V0289_BARROSAN_RESERVE_SUPPORT_ORDER_PREPARED_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "reserve-support-order-prepared-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0289-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0289_preflight_head_ci_resolution.png",
  "02_v0289_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0289_retained_v0282_v0284_baseline_ledger_proof.png",
  "04_v0289_manual_fixture_baseline_clean_hud.png",
  "05_v0289_engage_available_before_click.png",
  "06_v0289_engage_armed.png",
  "07_v0289_commit_engage_clicked.png",
  "08_v0289_post_commit_pressure_checked_ashen_braced.png",
  "09_v0289_hold_line_available_after_commit_locked.png",
  "10_v0289_hold_line_clicked.png",
  "11_v0289_line_held_exactly_once.png",
  "12_v0289_ashen_contained_exactly_once.png",
  "13_v0289_select_field_barracks_after_hold_line.png",
  "14_v0289_train_militia_available_reserve_slot_empty.png",
  "15_v0289_train_clicked.png",
  "16_v0289_reserve_ready_exactly_once.png",
  "17_v0289_assign_to_bridge_available.png",
  "18_v0289_assign_clicked.png",
  "19_v0289_reserve_assigned_exactly_once.png",
  "20_v0289_select_defender_after_reserve_assigned.png",
  "21_v0289_signal_available.png",
  "22_v0289_signal_clicked.png",
  "23_v0289_bridge_signal_sent_exactly_once.png",
  "24_v0289_signal_sent_exactly_once.png",
  "25_v0289_reserve_ack_exactly_once.png",
  "26_v0289_select_field_barracks_after_reserve_ack.png",
  "27_v0289_prepare_support_available.png",
  "28_v0289_prepare_clicked.png",
  "29_v0289_support_order_ready_exactly_once.png",
  "30_v0289_order_ready_exactly_once.png",
  "31_v0289_barracks_card_awaiting_deployment_approval.png",
  "32_v0289_defender_card_support_order_ready.png",
  "33_v0289_repeat_prepare_no_duplicate_order_marker_stack.png",
  "34_v0289_resources_unchanged_after_train_assign_signal_prepare.png",
  "35_v0289_reserve_marker_no_movement_pathing_attack_deploy_behavior.png",
  "36_v0289_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare.png",
  "37_v0289_field_barracks_no_engage_commit_hold_ashen_signal.png",
  "38_v0289_clear_guard_settles_defender_contact_clean_after_prepare.png",
  "39_v0289_reguard_clean_after_prepare_no_auto_deploy.png",
  "40_v0289_no_projectile_damage_hp_loss_death_despawn.png",
  "41_v0289_ui_layout_diagnostic_proof_retained.png",
  "42_v0289_contact_sheet.png",
  "43_v0289_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0289_manual_fixture_baseline_clean_hud",
  "v0289_engage_available_before_click",
  "v0289_engage_armed",
  "v0289_commit_engage_clicked",
  "v0289_post_commit_pressure_checked_ashen_braced",
  "v0289_hold_line_available_after_commit_locked",
  "v0289_hold_line_clicked",
  "v0289_line_held_exactly_once",
  "v0289_ashen_contained_exactly_once",
  "v0289_select_field_barracks_after_hold_line",
  "v0289_train_militia_available_reserve_slot_empty",
  "v0289_train_clicked",
  "v0289_reserve_ready_exactly_once",
  "v0289_assign_to_bridge_available",
  "v0289_assign_clicked",
  "v0289_reserve_assigned_exactly_once",
  "v0289_select_defender_after_reserve_assigned",
  "v0289_signal_available",
  "v0289_signal_clicked",
  "v0289_bridge_signal_sent_exactly_once",
  "v0289_signal_sent_exactly_once",
  "v0289_reserve_ack_exactly_once",
  "v0289_select_field_barracks_after_reserve_ack",
  "v0289_prepare_support_available",
  "v0289_prepare_clicked",
  "v0289_support_order_ready_exactly_once",
  "v0289_order_ready_exactly_once",
  "v0289_barracks_card_awaiting_deployment_approval",
  "v0289_defender_card_support_order_ready",
  "v0289_repeat_prepare_no_duplicate_order_marker_stack",
  "v0289_resources_unchanged_after_train_assign_signal_prepare",
  "v0289_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0289_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare",
  "v0289_field_barracks_no_engage_commit_hold_ashen_signal",
  "v0289_clear_guard_settles_defender_contact_clean_after_prepare",
  "v0289_reguard_clean_after_prepare_no_auto_deploy",
  "v0289_no_projectile_damage_hp_loss_death_despawn",
];

const readyModes = new Set(["v0289_train_clicked", "v0289_reserve_ready_exactly_once", "v0289_assign_to_bridge_available"]);
const assignedModes = new Set(["v0289_assign_clicked", "v0289_reserve_assigned_exactly_once", "v0289_select_defender_after_reserve_assigned", "v0289_signal_available"]);
const signaledModes = new Set(["v0289_signal_clicked", "v0289_bridge_signal_sent_exactly_once", "v0289_signal_sent_exactly_once", "v0289_reserve_ack_exactly_once", "v0289_select_field_barracks_after_reserve_ack", "v0289_prepare_support_available"]);
const preparedModes = new Set(["v0289_prepare_clicked", "v0289_support_order_ready_exactly_once", "v0289_order_ready_exactly_once", "v0289_barracks_card_awaiting_deployment_approval", "v0289_defender_card_support_order_ready", "v0289_repeat_prepare_no_duplicate_order_marker_stack", "v0289_resources_unchanged_after_train_assign_signal_prepare", "v0289_reserve_marker_no_movement_pathing_attack_deploy_behavior", "v0289_field_barracks_no_engage_commit_hold_ashen_signal", "v0289_clear_guard_settles_defender_contact_clean_after_prepare", "v0289_reguard_clean_after_prepare_no_auto_deploy", "v0289_no_projectile_damage_hp_loss_death_despawn"]);

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, mode) {
  return snaps[mode] ?? {};
}

function labelCount(snap, label) {
  return (snap.renderedTacticalWorldLabelTexts ?? []).filter((x) => x === label).length;
}

function shortHudText(snap) {
  const lines = snap.hudTextLines ?? {};
  const values = [lines.nameAndRole, lines.primaryState, lines.tacticalFacts, lines.readiness, lines.button, lines.topStrip].map((v) => String(v ?? ""));
  return values.every((value) => value.length > 0 && value.length <= 74) &&
    !values.some((value) => /validator|projectile, damage|enemy death\/despawn/i.test(value));
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
    "reserveMarkerDespawned", "autoDeployAdded", "pressureChangedByAssignment", "pressureChangedBySignal",
    "signalMovesReserveMarker", "signalDeploysUnit", "pressureChangedByPrepare", "prepareMovesReserveMarker",
    "prepareDeploysUnit", "routePreviewAdded", "prepareCreatesProjectile", "prepareCreatesAttackAnimation",
    "prepareActivatesAi",
  ];
  return !forbidden.some((key) => Boolean(c[key]) || Boolean(snap[key]));
}

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanReserveSupportOrderPreparedStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.289") errors.push("true default capture leaked v0.289 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0289_") || String(c.id ?? "").startsWith("v0289_"))) errors.push("true default capture contains v0.289 fixture actions");
  if (!(trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default")) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.289") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.289`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 37) errors.push(`opt-in runtime expected 37 v0.289 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.289 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.289 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.289 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(snap)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.reserveSupportOrderPreparedStepOnly || !snap.v0288BridgeSignalRetained || !snap.v0287ReserveAssignedRetained || !snap.v0286ReserveReadyRetained || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.supportOrderPreparedOnly || !snap.noCombatMovementPathingEconomyMutation) errors.push(`${mode} is not support-order-only with retained v0.288/v0.287/v0.286/v0.285/v0.284 chain`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
    if (readyModes.has(mode) && (labelCount(snap, "RESERVE READY") !== 1 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || labelCount(snap, "ORDER READY") !== 0 || !snap.reserveReadyExactlyOne)) errors.push(`${mode} does not render RESERVE READY exactly once before assignment`);
    if (assignedModes.has(mode) && (labelCount(snap, "RESERVE ASSIGNED") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || labelCount(snap, "RESERVE ACK") !== 0 || labelCount(snap, "ORDER READY") !== 0 || !snap.reserveAssignedExactlyOne)) errors.push(`${mode} does not render exactly one assigned label before Signal`);
    if (signaledModes.has(mode) && (labelCount(snap, "SIGNAL SENT") !== 1 || labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 0 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || Number(snap.bridgeSignalSentStatusCount ?? 0) !== 1 || !snap.signalDoesNotCreateSecondMarker)) errors.push(`${mode} does not render exactly one Signal/Reserve ACK without a second marker`);
    const settledAfterPrepare = mode === "v0289_clear_guard_settles_defender_contact_clean_after_prepare" || mode === "v0289_reguard_clean_after_prepare_no_auto_deploy";
    if (preparedModes.has(mode) && (labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || (!settledAfterPrepare && Number(snap.supportOrderReadyStatusCount ?? 0) !== 1) || !snap.prepareDoesNotCreateSecondMarker)) errors.push(`${mode} does not render exactly one support order without duplicate marker`);
  }

  if (snapshot(snaps, "v0289_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0289_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0289_commit_engage_clicked", "v0289_post_commit_pressure_checked_ashen_braced", "v0289_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "PRESSURE CHECKED") !== 1 || labelCount(snap, "ASHEN BRACED") !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0289_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");
  for (const mode of ["v0289_hold_line_clicked", "v0289_line_held_exactly_once", "v0289_ashen_contained_exactly_once"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "LINE HELD") !== 1 || labelCount(snap, "ASHEN CONTAINED") !== 1) errors.push(`${mode} did not render LINE HELD and ASHEN CONTAINED exactly once`);
    if ((snap.renderedTacticalWorldLabelTexts ?? []).includes("ASHEN BRACED") || (snap.renderedTacticalWorldLabelTexts ?? []).includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }

  if (!snapshot(snaps, "v0289_train_militia_available_reserve_slot_empty").barracksTrainAvailable) errors.push("Field Barracks Train was not available with reserve slot empty");
  if (!snapshot(snaps, "v0289_train_clicked").trainCreatesReserveReadyExactlyOnce) errors.push("Train did not create exactly one RESERVE READY marker");
  if (!snapshot(snaps, "v0289_assign_to_bridge_available").assignAvailableAfterReserveReady) errors.push("Assign did not become available after RESERVE READY");
  if (!snapshot(snaps, "v0289_assign_clicked").assignCreatesReserveAssignedExactlyOnce) errors.push("Assign did not create exactly one RESERVE ASSIGNED state");
  if (!snapshot(snaps, "v0289_signal_available").signalAvailableAfterReserveAssigned) errors.push("Signal did not become available after RESERVE ASSIGNED");
  if (!snapshot(snaps, "v0289_bridge_signal_sent_exactly_once").signalCreatesBridgeSignalSentExactlyOnce) errors.push("Signal did not create BRIDGE SIGNAL SENT exactly once");
  if (!snapshot(snaps, "v0289_signal_sent_exactly_once").signalCreatesSignalSentExactlyOnce) errors.push("Signal did not create SIGNAL SENT exactly once");
  if (!snapshot(snaps, "v0289_reserve_ack_exactly_once").signalCreatesReserveAckExactlyOnce) errors.push("Signal did not create RESERVE ACK exactly once");
  if (!snapshot(snaps, "v0289_prepare_support_available").prepareAvailableAfterReserveAck) errors.push("Prepare did not become available after RESERVE ACK");
  if (!snapshot(snaps, "v0289_support_order_ready_exactly_once").prepareCreatesSupportOrderReadyExactlyOnce) errors.push("Prepare did not create SUPPORT ORDER READY exactly once");
  if (!snapshot(snaps, "v0289_order_ready_exactly_once").prepareCreatesOrderReadyExactlyOnce) errors.push("Prepare did not create ORDER READY exactly once");
  if (!snapshot(snaps, "v0289_repeat_prepare_no_duplicate_order_marker_stack").repeatPrepareNoDuplicateOrder || !snapshot(snaps, "v0289_repeat_prepare_no_duplicate_order_marker_stack").repeatPrepareNoSecondSupportOrder) errors.push("repeat Prepare duplicated or stacked support order");
  if (!snapshot(snaps, "v0289_resources_unchanged_after_train_assign_signal_prepare").resourcesUnchangedAfterTrainAssignSignalPrepare) errors.push("resources changed after Train, Assign, Signal, or Prepare");
  if (!snapshot(snaps, "v0289_reserve_marker_no_movement_pathing_attack_deploy_behavior").reserveMarkerNoMovementPathingAttackDeployBehavior) errors.push("reserve marker gained movement/pathing/attack/deploy/engage/commit/hold behavior");
  if (!snapshot(snaps, "v0289_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare").watchpostNoReserveAssignSignalPrepareAction) errors.push("Watchpost leaked reserve, assign, Signal, Prepare, or combat action");
  if (!snapshot(snaps, "v0289_field_barracks_no_engage_commit_hold_ashen_signal").fieldBarracksNoCombatOrSignalActions) errors.push("Field Barracks leaked combat or Signal action");
  if (!snapshot(snaps, "v0289_defender_card_support_order_ready").defenderCardAcknowledgesSupportOrderReady) errors.push("defender card did not acknowledge Support order ready");
  if (!snapshot(snaps, "v0289_barracks_card_awaiting_deployment_approval").barracksCardAcknowledgesAwaitingDeploymentApproval) errors.push("Barracks card did not acknowledge Awaiting deployment approval");
  if (!snapshot(snaps, "v0289_clear_guard_settles_defender_contact_clean_after_prepare").clearGuardSettlesDefenderContactCleanAfterPrepare) errors.push("Clear Guard did not settle defender contact cleanly after Prepare");
  if (!snapshot(snaps, "v0289_reguard_clean_after_prepare_no_auto_deploy").reguardCleanAfterPrepareNoAutoDeploy) errors.push("Reguard was not clean after Prepare or auto-deployed");
  if (!snapshot(snaps, "v0289_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/HP loss/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 39) errors.push(`expected 39 v0.289 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.289 Barrosan reserve support order prepared step Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `094788075cfa2933cc67477283e0bc5aa33ebc07`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0289-barrosan-reserve-support-order-prepared-step/`.", "",
    "## What changed", "",
    "- Added a static opt-in `Prepare` state after the accepted v0.288 `RESERVE ACK` state.",
    "- The Field Barracks card exposes `Prepare support available`, then `Support order ready` / `Awaiting deployment approval`.",
    "- The East bridge defender card acknowledges `Support order ready` without deployment or movement.",
    "- Repeating Prepare preserves one `ORDER READY` label, one support order, and one static reserve marker.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.289 review steps.",
    "- v0.288 Signal / Reserve ACK, v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before support-order preparation.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, route preview, AI, waves, fog, economy, deployment, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.290.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_v0289_VALIDATION" : "PASS_v0289_BARROSAN_RESERVE_SUPPORT_ORDER_PREPARED_STEP_VALIDATION";
  writeFileSync(join(root, "v0289-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
