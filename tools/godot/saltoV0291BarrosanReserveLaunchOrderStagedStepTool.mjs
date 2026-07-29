import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const hit = process.argv.find((value) => value.startsWith(prefix));
  return hit ? hit.slice(prefix.length) : "";
};
const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0291"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0291"));
const manual = join(repo, "artifacts", "manual-review", "v0291-barrosan-reserve-launch-order-staged-step");
const optInRuntimePath = join(root, "reserve-launch-order-staged-step-runtime", "screenshot-runtime-manifest.json");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0291-black-frame-stats.json");
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
  "select_field_barracks_after_deployment_approved",
  "stage_available",
  "stage_clicked",
  "launch_order_staged_exactly_once",
  "launch_staged_exactly_once",
  "barracks_card_awaiting_final_release",
  "defender_card_launch_staged_awaiting_release",
  "repeat_stage_no_duplicate_staging_marker_stack",
  "resources_unchanged_after_train_assign_signal_prepare_approve_stage",
  "reserve_marker_no_movement_pathing_attack_deploy_launch_behavior",
  "watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve_stage",
  "field_barracks_no_engage_commit_hold_ashen_signal",
  "clear_guard_settles_defender_contact_clean_after_stage",
  "reguard_clean_after_stage_no_auto_launch_deploy",
  "no_projectile_damage_hp_loss_death_despawn"
];
const requiredModes = modeNames.map((name) => `v0291_${name}`);
const reviewImages = [
  "01_v0291_preflight_head_ci_resolution.png",
  "02_v0291_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0291_retained_v0282_v0284_baseline_ledger_proof.png",
  ...modeNames.map((name, index) => `${String(index + 4).padStart(2, "0")}_v0291_${name}.png`),
  "53_v0291_ui_layout_diagnostic_proof_retained.png",
  "54_v0291_contact_sheet.png",
  "55_v0291_black_frame_rejection_report.png",
];
function readJson(path, fallback = {}) {
  if (!existsSync(path)) return fallback;
  return JSON.parse(readFileSync(path, "utf8"));
}
function snapshot(snaps, mode) { return snaps[mode] || {}; }
function labelCount(snap, label) { return (snap.renderedTacticalWorldLabelTexts || []).filter((x) => x === label).length; }
function hasButton(snap, label) { return String(snap.hudTextLines?.button || "") === label; }
function allFalse(snap, keys) { return keys.every((key) => snap[key] === false || snap[key] === undefined); }
function collectEvidence() {
  const errors = [];
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const proof = optInRuntime?.barrosanPlayableRuntimeSkin?.barrosanReserveLaunchOrderStagedStep || optInRuntime?.sceneStatus?.barrosanReserveLaunchOrderStagedStep || {};
  const snaps = proof.proofSnapshots || {};
  if (trueDefault.checkpoint === "v0.291") errors.push("true default capture leaked v0.291 review fixture checkpoint");
  if ((trueDefault.captures || []).some((capture) => String(capture.action || "").startsWith("v0291_"))) errors.push("true default capture contains v0.291 fixture actions");
  if (optInRuntime.checkpoint !== "v0.291") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.291`);
  if (optInRuntime.captureCount !== 49) errors.push(`opt-in runtime expected 49 v0.291 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.291 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.291 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.291 review image ${file}`);
  const pixelStats = readJson(statsPath, { stats: [] }).stats || [];
  if (pixelStats.length !== 51) errors.push(`expected 51 v0.291 captured PNG pixel stats, saw ${pixelStats.length}`);
  for (const mode of requiredModes) {
    const snap = snapshot(snaps, mode);
    if (!snap.reserveLaunchOrderStagedStepOnly || !snap.v0290ApprovalGateRetained || !snap.v0289SupportOrderRetained || !snap.v0288BridgeSignalRetained || !snap.v0287ReserveAssignedRetained || !snap.v0286ReserveReadyRetained || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.noCombatMovementPathingEconomyMutation) errors.push(`${mode} is not launch-order-staged-only with retained v0.290-v0.284 chain`);
    if (!allFalse(snap, ["stageChangesPressure", "stageMovesReserveMarker", "stageDeploysUnit", "stageLaunchesUnit", "stageCreatesProjectile", "stageCreatesAttackAnimation", "stageActivatesAi", "routePreviewAdded", "autoLaunchAdded", "autoDeployAdded"])) errors.push(`${mode} leaked movement/pathing/combat/AI/launch/deploy side effects`);
    if (snap.layoutDiagnostics?.layoutStatus !== "PASS") errors.push(`${mode} layout diagnostics failed`);
  }
  if (snapshot(snaps, "v0291_stage_available").stageAvailableAfterDeploymentApproved !== true || !hasButton(snapshot(snaps, "v0291_stage_available"), "Stage")) errors.push("Stage did not become available after DEPLOYMENT APPROVED");
  if (snapshot(snaps, "v0291_launch_order_staged_exactly_once").stageCreatesLaunchOrderStagedExactlyOnce !== true) errors.push("Stage did not create LAUNCH ORDER STAGED exactly once");
  if (snapshot(snaps, "v0291_launch_staged_exactly_once").stageCreatesLaunchStagedExactlyOnce !== true) errors.push("Stage did not create LAUNCH STAGED exactly once");
  if (snapshot(snaps, "v0291_repeat_stage_no_duplicate_staging_marker_stack").repeatStageNoDuplicateStaging !== true || snapshot(snaps, "v0291_repeat_stage_no_duplicate_staging_marker_stack").repeatStageNoSecondLaunchOrderState !== true) errors.push("repeat Stage duplicated staging state or marker");
  if (snapshot(snaps, "v0291_resources_unchanged_after_train_assign_signal_prepare_approve_stage").resourcesUnchangedAfterTrainAssignSignalPrepareApproveStage !== true) errors.push("resources changed after Train, Assign, Signal, Prepare, Approve, or Stage");
  if (snapshot(snaps, "v0291_reserve_marker_no_movement_pathing_attack_deploy_launch_behavior").reserveMarkerNoMovementPathingAttackDeployLaunchBehavior !== true) errors.push("reserve marker gained movement/pathing/attack/deploy/launch behavior");
  if (snapshot(snaps, "v0291_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve_stage").watchpostNoReserveAssignSignalPrepareApproveStageAction !== true) errors.push("Watchpost leaked reserve/assign/signal/prepare/approve/stage/combat action");
  if (snapshot(snaps, "v0291_field_barracks_no_engage_commit_hold_ashen_signal").fieldBarracksNoCombatOrSignalActions !== true) errors.push("Field Barracks leaked combat or Signal action");
  if (snapshot(snaps, "v0291_barracks_card_awaiting_final_release").barracksCardAcknowledgesAwaitingFinalRelease !== true) errors.push("Barracks card did not acknowledge Awaiting final release");
  if (snapshot(snaps, "v0291_defender_card_launch_staged_awaiting_release").defenderCardAcknowledgesLaunchStagedAwaitingRelease !== true) errors.push("defender card did not acknowledge Launch staged / Awaiting release");
  if (snapshot(snaps, "v0291_clear_guard_settles_defender_contact_clean_after_stage").clearGuardSettlesDefenderContactCleanAfterStage !== true) errors.push("Clear Guard did not settle defender contact cleanly after Stage");
  if (snapshot(snaps, "v0291_reguard_clean_after_stage_no_auto_launch_deploy").reguardCleanAfterStageNoAutoLaunchDeploy !== true) errors.push("Reguard was not clean after Stage or auto-launched/deployed");
  if (snapshot(snaps, "v0291_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn !== true) errors.push("no projectile/damage/HP loss/death/despawn proof failed");
  for (const mode of ["v0291_stage_clicked", "v0291_launch_order_staged_exactly_once", "v0291_launch_staged_exactly_once", "v0291_barracks_card_awaiting_final_release", "v0291_defender_card_launch_staged_awaiting_release", "v0291_repeat_stage_no_duplicate_staging_marker_stack"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "ORDER READY") !== 1 || labelCount(snap, "APPROVED") !== 1 || labelCount(snap, "LAUNCH STAGED") !== 1) errors.push(`${mode} did not preserve ACK/ORDER/APPROVED and add one LAUNCH STAGED label`);
  }
  return { errors, proof, optInRuntime, trueDefault, pixelSummary: pixelStats };
}
function writeReport(evidence) {
  const lines = [
    "# v0.291 Barrosan Reserve Launch Order Staged Step Report", "",
    `- Status: ${evidence.errors.length ? "FAIL" : "PASS"}`,
    "- Scope: static opt-in Stage gate after v0.290 DEPLOYMENT APPROVED.",
    "- New state: LAUNCH ORDER STAGED.",
    "- New world label: LAUNCH STAGED.",
    "- No launch, deployment, movement, pathing, combat, damage, AI, economy, fog, wave, or default-runtime mutation added.",
    "- Review pack path: `artifacts/manual-review/v0291-barrosan-reserve-launch-order-staged-step/`.",
    `- Runtime captures: ${evidence.optInRuntime.captureCount ?? "missing"} / 49.`,
    `- Required review images: ${reviewImages.length}.`,
    `- Pixel-stat frames: ${evidence.pixelSummary.length} / 51.`,
    "", "## Errors", ...(evidence.errors.length ? evidence.errors.map((e) => `- ${e}`) : ["- None."]),
  ];
  writeFileSync(join(repo, "docs", "V0291_BARROSAN_RESERVE_LAUNCH_ORDER_STAGED_STEP_REPORT.md"), lines.join("\n") + "\n");
}
const evidence = collectEvidence();
writeReport(evidence);
const status = evidence.errors.length ? "FAIL_v0291_VALIDATION" : "PASS_v0291_BARROSAN_RESERVE_LAUNCH_ORDER_STAGED_STEP_VALIDATION";
writeFileSync(join(root, "v0291-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
console.log(status);
if (command === "validation" && evidence.errors.length) process.exit(1);
