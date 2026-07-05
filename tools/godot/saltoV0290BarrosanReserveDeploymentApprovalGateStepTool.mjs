import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0290"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0290"));
const manual = join(repo, "artifacts", "manual-review", "v0290-barrosan-reserve-deployment-approval-gate-step");
const docPath = join(repo, "docs", "V0290_BARROSAN_RESERVE_DEPLOYMENT_APPROVAL_GATE_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "reserve-deployment-approval-gate-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0290-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const modeNames = [
  "manual_fixture_baseline_clean_hud",
  "engage_available_before_click",
  "engage_armed",
  "commit_engage_clicked",
  "post_commit_pressure_checked_ashen_braced",
  "hold_line_available_after_commit_locked",
  "hold_line_clicked",
  "line_held_exactly_once",
  "ashen_contained_exactly_once",
  "select_field_barracks_after_hold_line",
  "train_militia_available_reserve_slot_empty",
  "train_clicked",
  "reserve_ready_exactly_once",
  "assign_to_bridge_available",
  "assign_clicked",
  "reserve_assigned_exactly_once",
  "select_defender_after_reserve_assigned",
  "signal_available",
  "signal_clicked",
  "bridge_signal_sent_exactly_once",
  "signal_sent_exactly_once",
  "reserve_ack_exactly_once",
  "select_field_barracks_after_reserve_ack",
  "prepare_support_available",
  "prepare_clicked",
  "support_order_ready_exactly_once",
  "order_ready_exactly_once",
  "select_field_barracks_after_support_order_ready",
  "approve_available",
  "approve_clicked",
  "deployment_approved_exactly_once",
  "approved_exactly_once",
  "barracks_card_awaiting_launch_order",
  "defender_card_support_approved_awaiting_launch",
  "repeat_approve_no_duplicate_approval_marker_stack",
  "resources_unchanged_after_train_assign_signal_prepare_approve",
  "reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve",
  "field_barracks_no_engage_commit_hold_ashen_signal",
  "clear_guard_settles_defender_contact_clean_after_approve",
  "reguard_clean_after_approve_no_auto_deploy",
  "no_projectile_damage_hp_loss_death_despawn",
];

const requiredModes = modeNames.map((name) => `v0290_${name}`);
const reviewImages = [
  "01_v0290_preflight_head_ci_resolution.png",
  "02_v0290_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0290_retained_v0282_v0284_baseline_ledger_proof.png",
  ...modeNames.map((name, index) => `${String(index + 4).padStart(2, "0")}_v0290_${name}.png`),
  "46_v0290_ui_layout_diagnostic_proof_retained.png",
  "47_v0290_contact_sheet.png",
  "48_v0290_black_frame_rejection_report.png",
];

const readyModes = new Set(["v0290_train_clicked", "v0290_reserve_ready_exactly_once", "v0290_assign_to_bridge_available"]);
const assignedModes = new Set(["v0290_assign_clicked", "v0290_reserve_assigned_exactly_once", "v0290_select_defender_after_reserve_assigned", "v0290_signal_available"]);
const signaledModes = new Set(["v0290_signal_clicked", "v0290_bridge_signal_sent_exactly_once", "v0290_signal_sent_exactly_once", "v0290_reserve_ack_exactly_once", "v0290_select_field_barracks_after_reserve_ack", "v0290_prepare_support_available"]);
const supportReadyModes = new Set(["v0290_prepare_clicked", "v0290_support_order_ready_exactly_once", "v0290_order_ready_exactly_once", "v0290_select_field_barracks_after_support_order_ready", "v0290_approve_available"]);
const approvedModes = new Set([
  "v0290_approve_clicked",
  "v0290_deployment_approved_exactly_once",
  "v0290_approved_exactly_once",
  "v0290_barracks_card_awaiting_launch_order",
  "v0290_defender_card_support_approved_awaiting_launch",
  "v0290_repeat_approve_no_duplicate_approval_marker_stack",
  "v0290_resources_unchanged_after_train_assign_signal_prepare_approve",
  "v0290_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0290_field_barracks_no_engage_commit_hold_ashen_signal",
  "v0290_clear_guard_settles_defender_contact_clean_after_approve",
  "v0290_reguard_clean_after_approve_no_auto_deploy",
  "v0290_no_projectile_damage_hp_loss_death_despawn",
]);

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

function hasButton(snap, label) {
  return String(snap.hudTextLines?.button ?? "") === label;
}

function shortHudText(snap) {
  const lines = snap.hudTextLines ?? {};
  const values = [lines.nameAndRole, lines.primaryState, lines.tacticalFacts, lines.readiness, lines.button, lines.topStrip].map((v) => String(v ?? ""));
  return values.every((value) => value.length > 0 && value.length <= 74) &&
    !values.some((value) => /validator|projectile, damage|enemy death\/despawn|raw paragraph/i.test(value));
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
    "prepareActivatesAi", "approveChangesPressure", "approveMovesReserveMarker", "approveDeploysUnit",
    "approveCreatesProjectile", "approveCreatesAttackAnimation", "approveActivatesAi",
  ];
  return !forbidden.some((key) => Boolean(c[key]) || Boolean(snap[key]));
}

function checkLayout(errors, mode, snap) {
  const layout = snap.layoutDiagnostics ?? {};
  if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
  if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) {
    errors.push(`${mode} failed selected-card layout diagnostics`);
  }
}

function checkLabelPhase(errors, mode, snap) {
  const labels = snap.renderedTacticalWorldLabelTexts ?? [];
  if (readyModes.has(mode) && (labelCount(snap, "RESERVE READY") !== 1 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || labelCount(snap, "ORDER READY") !== 0 || labelCount(snap, "APPROVED") !== 0 || !snap.reserveReadyExactlyOne)) {
    errors.push(`${mode} does not render exactly one RESERVE READY before assignment`);
  }
  if (assignedModes.has(mode) && (labelCount(snap, "RESERVE ASSIGNED") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || labelCount(snap, "RESERVE ACK") !== 0 || labelCount(snap, "ORDER READY") !== 0 || labelCount(snap, "APPROVED") !== 0 || !snap.reserveAssignedExactlyOne)) {
    errors.push(`${mode} does not render exactly one RESERVE ASSIGNED before Signal`);
  }
  if (signaledModes.has(mode) && (labelCount(snap, "SIGNAL SENT") !== 1 || labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 0 || labelCount(snap, "APPROVED") !== 0 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || Number(snap.bridgeSignalSentStatusCount ?? 0) !== 1 || !snap.signalDoesNotCreateSecondMarker)) {
    errors.push(`${mode} does not render exactly one Signal/Reserve ACK without a second marker`);
  }
  if (supportReadyModes.has(mode) && (labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 1 || labelCount(snap, "APPROVED") !== 0 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || Number(snap.supportOrderReadyStatusCount ?? 0) !== 1 || !snap.prepareDoesNotCreateSecondMarker)) {
    errors.push(`${mode} does not render exactly one support-order-ready state before approval`);
  }
  if (approvedModes.has(mode)) {
    const settled = mode === "v0290_clear_guard_settles_defender_contact_clean_after_approve" || mode === "v0290_reguard_clean_after_approve_no_auto_deploy";
    if (labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 1 || labelCount(snap, "APPROVED") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || (!settled && Number(snap.deploymentApprovedStatusCount ?? 0) !== 1) || !snap.approveDoesNotCreateSecondMarker) {
      errors.push(`${mode} does not render exactly one approved state without duplicate marker`);
    }
  }
  if (labels.filter((x) => x === "APPROVED").length > 1) errors.push(`${mode} duplicated APPROVED world label`);
}

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanReserveDeploymentApprovalGateStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.290") errors.push("true default capture leaked v0.290 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0290_") || String(c.id ?? "").startsWith("v0290_"))) errors.push("true default capture contains v0.290 fixture actions");
  if (!(trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default")) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.290") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.290`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 42) errors.push(`opt-in runtime expected 42 v0.290 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.290 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.290 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.290 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    if (!requiredModes.includes(mode)) continue;
    if (!passive(snap)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.reserveDeploymentApprovalGateStepOnly || !snap.v0289SupportOrderRetained || !snap.v0288BridgeSignalRetained || !snap.v0287ReserveAssignedRetained || !snap.v0286ReserveReadyRetained || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.noCombatMovementPathingEconomyMutation) {
      errors.push(`${mode} is not approval-gate-only with retained v0.289/v0.288/v0.287/v0.286/v0.285/v0.284 chain`);
    }
    checkLayout(errors, mode, snap);
    checkLabelPhase(errors, mode, snap);
  }

  if (snapshot(snaps, "v0290_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0290_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0290_commit_engage_clicked", "v0290_post_commit_pressure_checked_ashen_braced", "v0290_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "PRESSURE CHECKED") !== 1 || labelCount(snap, "ASHEN BRACED") !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0290_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");
  for (const mode of ["v0290_hold_line_clicked", "v0290_line_held_exactly_once", "v0290_ashen_contained_exactly_once"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "LINE HELD") !== 1 || labelCount(snap, "ASHEN CONTAINED") !== 1) errors.push(`${mode} did not render LINE HELD and ASHEN CONTAINED exactly once`);
    if ((snap.renderedTacticalWorldLabelTexts ?? []).includes("ASHEN BRACED") || (snap.renderedTacticalWorldLabelTexts ?? []).includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }

  if (!snapshot(snaps, "v0290_train_militia_available_reserve_slot_empty").barracksTrainAvailable) errors.push("Field Barracks Train was not available with reserve slot empty");
  if (!snapshot(snaps, "v0290_train_clicked").trainCreatesReserveReadyExactlyOnce) errors.push("Train did not create exactly one RESERVE READY marker");
  if (!snapshot(snaps, "v0290_assign_to_bridge_available").assignAvailableAfterReserveReady) errors.push("Assign did not become available after RESERVE READY");
  if (!snapshot(snaps, "v0290_assign_clicked").assignCreatesReserveAssignedExactlyOnce) errors.push("Assign did not create exactly one RESERVE ASSIGNED state");
  if (!snapshot(snaps, "v0290_signal_available").signalAvailableAfterReserveAssigned) errors.push("Signal did not become available after RESERVE ASSIGNED");
  if (!snapshot(snaps, "v0290_bridge_signal_sent_exactly_once").signalCreatesBridgeSignalSentExactlyOnce) errors.push("Signal did not create BRIDGE SIGNAL SENT exactly once");
  if (!snapshot(snaps, "v0290_signal_sent_exactly_once").signalCreatesSignalSentExactlyOnce) errors.push("Signal did not create SIGNAL SENT exactly once");
  if (!snapshot(snaps, "v0290_reserve_ack_exactly_once").signalCreatesReserveAckExactlyOnce) errors.push("Signal did not create RESERVE ACK exactly once");
  if (!snapshot(snaps, "v0290_prepare_support_available").prepareAvailableAfterReserveAck) errors.push("Prepare did not become available after RESERVE ACK");
  if (!snapshot(snaps, "v0290_support_order_ready_exactly_once").prepareCreatesSupportOrderReadyExactlyOnce) errors.push("Prepare did not create SUPPORT ORDER READY exactly once");
  if (!snapshot(snaps, "v0290_order_ready_exactly_once").prepareCreatesOrderReadyExactlyOnce) errors.push("Prepare did not create ORDER READY exactly once");
  if (!snapshot(snaps, "v0290_approve_available").approveAvailableAfterSupportOrderReady || !hasButton(snapshot(snaps, "v0290_approve_available"), "Approve")) errors.push("Approve did not become available after SUPPORT ORDER READY");
  if (!snapshot(snaps, "v0290_deployment_approved_exactly_once").approveCreatesDeploymentApprovedExactlyOnce) errors.push("Approve did not create DEPLOYMENT APPROVED exactly once");
  if (!snapshot(snaps, "v0290_approved_exactly_once").approveCreatesApprovedExactlyOnce) errors.push("Approve did not create APPROVED exactly once");
  if (!snapshot(snaps, "v0290_repeat_approve_no_duplicate_approval_marker_stack").repeatApproveNoDuplicateApproval || !snapshot(snaps, "v0290_repeat_approve_no_duplicate_approval_marker_stack").repeatApproveNoSecondApprovalState || !snapshot(snaps, "v0290_repeat_approve_no_duplicate_approval_marker_stack").approveDoesNotCreateSecondMarker) errors.push("repeat Approve duplicated approval or reserve marker");
  if (!snapshot(snaps, "v0290_resources_unchanged_after_train_assign_signal_prepare_approve").resourcesUnchangedAfterTrainAssignSignalPrepareApprove) errors.push("resources changed after Train, Assign, Signal, Prepare, or Approve");
  if (!snapshot(snaps, "v0290_reserve_marker_no_movement_pathing_attack_deploy_behavior").reserveMarkerNoMovementPathingAttackDeployBehavior) errors.push("reserve marker gained movement/pathing/attack/deploy/engage/commit/hold behavior");
  if (!snapshot(snaps, "v0290_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve").watchpostNoReserveAssignSignalPrepareApproveAction) errors.push("Watchpost leaked reserve, assign, Signal, Prepare, Approve, or combat action");
  if (!snapshot(snaps, "v0290_field_barracks_no_engage_commit_hold_ashen_signal").fieldBarracksNoCombatOrSignalActions) errors.push("Field Barracks leaked combat or Signal action");
  if (!snapshot(snaps, "v0290_barracks_card_awaiting_launch_order").barracksCardAcknowledgesAwaitingLaunchOrder) errors.push("Barracks card did not acknowledge Awaiting launch order");
  if (!snapshot(snaps, "v0290_defender_card_support_approved_awaiting_launch").defenderCardAcknowledgesSupportApprovedAwaitingLaunch) errors.push("defender card did not acknowledge Support approved / Awaiting launch");
  if (!snapshot(snaps, "v0290_clear_guard_settles_defender_contact_clean_after_approve").clearGuardSettlesDefenderContactCleanAfterApprove) errors.push("Clear Guard did not settle defender contact cleanly after Approve");
  if (!snapshot(snaps, "v0290_reguard_clean_after_approve_no_auto_deploy").reguardCleanAfterApproveNoAutoDeploy) errors.push("Reguard was not clean after Approve or auto-deployed");
  if (!snapshot(snaps, "v0290_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/HP loss/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 44) errors.push(`expected 44 v0.290 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.290 Barrosan reserve deployment approval gate step Report",
    "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `6b57472202aefe0eb37025b6b8ea663d2eb2b56f`.",
    "- Baseline exact-SHA GitHub Actions run: `28743865693` (`success`).",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0290-barrosan-reserve-deployment-approval-gate-step/`.",
    "",
    "## What changed",
    "",
    "- Added a static opt-in `Approve` gate after the accepted v0.289 `SUPPORT ORDER READY` / `ORDER READY` state.",
    "- Selecting the Field Barracks after support order readiness exposes `Approve` without deployment, movement, route preview, pathing, or cost.",
    "- Approving creates one concise `DEPLOYMENT APPROVED` top status and one static `APPROVED` world label near the reserve/Barracks area.",
    "- The Field Barracks card reads `Deployment approved` / `Awaiting launch order`; the East bridge defender card reads `Support approved` / `Bridge held | Awaiting launch`.",
    "- Repeat Approve stays idempotent: no duplicate approval, no second state, no second marker, and no stack.",
    "",
    "## Boundaries retained",
    "",
    "- True default runtime remains unmodified and does not dispatch v0.290 review steps.",
    "- v0.289 Support Order, v0.288 Signal / Reserve ACK, v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before approval.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, route preview, AI, waves, fog, economy, deployment, or default mutation was added.",
    "",
    "## Pixel validation",
    "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "",
    "Stop before v0.291.",
    "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_v0290_VALIDATION" : "PASS_v0290_BARROSAN_RESERVE_DEPLOYMENT_APPROVAL_GATE_STEP_VALIDATION";
  writeFileSync(join(root, "v0290-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
