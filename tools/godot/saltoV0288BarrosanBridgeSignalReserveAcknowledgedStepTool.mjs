import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0288"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0288"));
const manual = join(repo, "artifacts", "manual-review", "v0288-barrosan-bridge-signal-reserve-acknowledged-step");
const docPath = join(repo, "docs", "V0288_BARROSAN_BRIDGE_SIGNAL_RESERVE_ACKNOWLEDGED_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "bridge-signal-reserve-acknowledged-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0288-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0288_preflight_head_ci_resolution.png",
  "02_v0288_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0288_retained_v0282_v0284_baseline_ledger_proof.png",
  "04_v0288_manual_fixture_baseline_clean_hud.png",
  "05_v0288_engage_available_before_click.png",
  "06_v0288_engage_armed.png",
  "07_v0288_commit_engage_clicked.png",
  "08_v0288_post_commit_pressure_checked_ashen_braced.png",
  "09_v0288_hold_line_available_after_commit_locked.png",
  "10_v0288_hold_line_clicked.png",
  "11_v0288_line_held_exactly_once.png",
  "12_v0288_ashen_contained_exactly_once.png",
  "13_v0288_select_field_barracks_after_hold_line.png",
  "14_v0288_train_militia_available_reserve_slot_empty.png",
  "15_v0288_train_clicked.png",
  "16_v0288_reserve_ready_exactly_once.png",
  "17_v0288_assign_to_bridge_available.png",
  "18_v0288_assign_clicked.png",
  "19_v0288_reserve_assigned_exactly_once.png",
  "20_v0288_select_defender_after_reserve_assigned.png",
  "21_v0288_defender_card_signal_available.png",
  "22_v0288_signal_clicked.png",
  "23_v0288_bridge_signal_sent_exactly_once.png",
  "24_v0288_reserve_ack_exactly_once.png",
  "25_v0288_defender_card_reserve_acknowledged.png",
  "26_v0288_barracks_card_bridge_signal_received.png",
  "27_v0288_repeat_signal_no_duplicate_signal_ack_stack.png",
  "28_v0288_resources_unchanged_after_train_assign_signal.png",
  "29_v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior.png",
  "30_v0288_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal.png",
  "31_v0288_field_barracks_no_engage_commit_hold_ashen_signal.png",
  "32_v0288_clear_guard_settles_defender_contact_clean_after_signal.png",
  "33_v0288_reguard_clean_after_signal_no_auto_deploy.png",
  "34_v0288_no_projectile_damage_hp_loss_death_despawn.png",
  "35_v0288_ui_layout_diagnostic_proof_retained.png",
  "36_v0288_contact_sheet.png",
  "37_v0288_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0288_manual_fixture_baseline_clean_hud",
  "v0288_engage_available_before_click",
  "v0288_engage_armed",
  "v0288_commit_engage_clicked",
  "v0288_post_commit_pressure_checked_ashen_braced",
  "v0288_hold_line_available_after_commit_locked",
  "v0288_hold_line_clicked",
  "v0288_line_held_exactly_once",
  "v0288_ashen_contained_exactly_once",
  "v0288_select_field_barracks_after_hold_line",
  "v0288_train_militia_available_reserve_slot_empty",
  "v0288_train_clicked",
  "v0288_reserve_ready_exactly_once",
  "v0288_assign_to_bridge_available",
  "v0288_assign_clicked",
  "v0288_reserve_assigned_exactly_once",
  "v0288_select_defender_after_reserve_assigned",
  "v0288_defender_card_signal_available",
  "v0288_signal_clicked",
  "v0288_bridge_signal_sent_exactly_once",
  "v0288_reserve_ack_exactly_once",
  "v0288_defender_card_reserve_acknowledged",
  "v0288_barracks_card_bridge_signal_received",
  "v0288_repeat_signal_no_duplicate_signal_ack_stack",
  "v0288_resources_unchanged_after_train_assign_signal",
  "v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0288_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal",
  "v0288_field_barracks_no_engage_commit_hold_ashen_signal",
  "v0288_clear_guard_settles_defender_contact_clean_after_signal",
  "v0288_reguard_clean_after_signal_no_auto_deploy",
  "v0288_no_projectile_damage_hp_loss_death_despawn",
];

const readyModes = new Set([
  "v0288_train_clicked",
  "v0288_reserve_ready_exactly_once",
  "v0288_assign_to_bridge_available",
]);

const assignedModes = new Set([
  "v0288_assign_clicked",
  "v0288_reserve_assigned_exactly_once",
  "v0288_select_defender_after_reserve_assigned",
  "v0288_defender_card_signal_available",
]);

const signaledModes = new Set([
  "v0288_signal_clicked",
  "v0288_bridge_signal_sent_exactly_once",
  "v0288_reserve_ack_exactly_once",
  "v0288_defender_card_reserve_acknowledged",
  "v0288_barracks_card_bridge_signal_received",
  "v0288_repeat_signal_no_duplicate_signal_ack_stack",
  "v0288_resources_unchanged_after_train_assign_signal",
  "v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior",
  "v0288_field_barracks_no_engage_commit_hold_ashen_signal",
  "v0288_clear_guard_settles_defender_contact_clean_after_signal",
  "v0288_reguard_clean_after_signal_no_auto_deploy",
  "v0288_no_projectile_damage_hp_loss_death_despawn",
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
    "reserveMarkerDespawned", "autoDeployAdded", "pressureChangedByAssignment", "pressureChangedBySignal",
    "signalMovesReserveMarker", "signalDeploysUnit",
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
  const proof = skin.barrosanBridgeSignalReserveAcknowledgedStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.288") errors.push("true default capture leaked v0.288 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0288_") || String(c.id ?? "").startsWith("v0288_"))) errors.push("true default capture contains v0.288 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.288") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.288`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 31) errors.push(`opt-in runtime expected 31 v0.288 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.288 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.288 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.288 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(snap)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.bridgeSignalReserveAcknowledgedStepOnly || !snap.v0287ReserveAssignedRetained || !snap.v0286ReserveReadyRetained || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.signalAcknowledgementOnly || !snap.noCombatMovementPathingEconomyMutation) errors.push(`${mode} is not signal-ack-only with v0.287/v0.286/v0.285/v0.284 retained`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
    if (readyModes.has(mode) && (labelCount(snap, "RESERVE READY") !== 1 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || !snap.reserveReadyExactlyOne)) errors.push(`${mode} does not render RESERVE READY exactly once before assignment`);
    if (assignedModes.has(mode) && (labelCount(snap, "RESERVE ASSIGNED") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "SIGNAL SENT") !== 0 || labelCount(snap, "RESERVE ACK") !== 0 || !snap.reserveAssignedExactlyOne)) errors.push(`${mode} does not render exactly one assigned label before Signal`);
    const settledAfterSignal = mode === "v0288_clear_guard_settles_defender_contact_clean_after_signal" || mode === "v0288_reguard_clean_after_signal_no_auto_deploy";
    if (signaledModes.has(mode) && (labelCount(snap, "SIGNAL SENT") !== 1 || labelCount(snap, "RESERVE ACK") !== 1 || labelCount(snap, "RESERVE READY") !== 0 || labelCount(snap, "RESERVE ASSIGNED") !== 0 || (!settledAfterSignal && Number(snap.bridgeSignalSentStatusCount ?? 0) !== 1) || !snap.signalDoesNotCreateSecondMarker)) errors.push(`${mode} does not render exactly one Signal/Reserve ACK without a second marker`);
  }

  if (snapshot(snaps, "v0288_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0288_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0288_commit_engage_clicked", "v0288_post_commit_pressure_checked_ashen_braced", "v0288_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "PRESSURE CHECKED") !== 1 || labelCount(snap, "ASHEN BRACED") !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0288_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");
  for (const mode of ["v0288_hold_line_clicked", "v0288_line_held_exactly_once", "v0288_ashen_contained_exactly_once"]) {
    const snap = snapshot(snaps, mode);
    if (labelCount(snap, "LINE HELD") !== 1 || labelCount(snap, "ASHEN CONTAINED") !== 1) errors.push(`${mode} did not render LINE HELD and ASHEN CONTAINED exactly once`);
    if ((snap.renderedTacticalWorldLabelTexts ?? []).includes("ASHEN BRACED") || (snap.renderedTacticalWorldLabelTexts ?? []).includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }

  if (!snapshot(snaps, "v0288_train_militia_available_reserve_slot_empty").barracksTrainAvailable) errors.push("Field Barracks Train was not available with reserve slot empty");
  if (!snapshot(snaps, "v0288_train_clicked").trainCreatesReserveReadyExactlyOnce) errors.push("Train did not create exactly one RESERVE READY marker");
  if (!snapshot(snaps, "v0288_assign_to_bridge_available").assignAvailableAfterReserveReady) errors.push("Assign did not become available after RESERVE READY");
  if (!snapshot(snaps, "v0288_assign_clicked").assignCreatesReserveAssignedExactlyOnce) errors.push("Assign did not create exactly one RESERVE ASSIGNED state");
  if (!snapshot(snaps, "v0288_defender_card_signal_available").signalAvailableAfterReserveAssigned) errors.push("Signal did not become available after RESERVE ASSIGNED");
  if (!snapshot(snaps, "v0288_bridge_signal_sent_exactly_once").signalCreatesBridgeSignalSentExactlyOnce) errors.push("Signal did not create BRIDGE SIGNAL SENT exactly once");
  if (!snapshot(snaps, "v0288_reserve_ack_exactly_once").signalCreatesReserveAckExactlyOnce) errors.push("Signal did not create RESERVE ACK exactly once");
  if (!snapshot(snaps, "v0288_repeat_signal_no_duplicate_signal_ack_stack").repeatSignalNoDuplicateSignal || !snapshot(snaps, "v0288_repeat_signal_no_duplicate_signal_ack_stack").repeatSignalNoDuplicateAck) errors.push("repeat Signal duplicated or stacked signal/acknowledgement");
  if (!snapshot(snaps, "v0288_resources_unchanged_after_train_assign_signal").resourcesUnchangedAfterTrainAssignSignal) errors.push("resources changed after Train, Assign, or Signal");
  if (!snapshot(snaps, "v0288_reserve_marker_no_movement_pathing_attack_deploy_behavior").reserveMarkerNoMovementPathingAttackDeployBehavior) errors.push("reserve marker gained movement/pathing/attack/deploy/engage/commit/hold behavior");
  if (!snapshot(snaps, "v0288_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal").watchpostNoReserveAssignSignalAction) errors.push("Watchpost leaked reserve, assign, Signal, or combat action");
  if (!snapshot(snaps, "v0288_field_barracks_no_engage_commit_hold_ashen_signal").fieldBarracksNoCombatOrSignalActions) errors.push("Field Barracks leaked combat or Signal action");
  if (!snapshot(snaps, "v0288_defender_card_reserve_acknowledged").defenderCardAcknowledgesReserveAcknowledged) errors.push("defender card did not acknowledge Reserve acknowledged");
  if (!snapshot(snaps, "v0288_barracks_card_bridge_signal_received").barracksCardAcknowledgesBridgeSignalReceived) errors.push("Barracks card did not acknowledge Bridge signal received");
  if (!snapshot(snaps, "v0288_clear_guard_settles_defender_contact_clean_after_signal").clearGuardSettlesDefenderContactCleanAfterSignal) errors.push("Clear Guard did not settle defender contact cleanly after Signal");
  if (!snapshot(snaps, "v0288_reguard_clean_after_signal_no_auto_deploy").reguardCleanAfterSignalNoAutoDeploy) errors.push("Reguard was not clean after Signal or auto-deployed");
  if (!snapshot(snaps, "v0288_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/HP loss/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 33) errors.push(`expected 33 v0.288 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.288 Barrosan bridge signal reserve acknowledged step Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `04da01acfa5ee5fa8e6bdaab258750b81c957354`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0288-barrosan-bridge-signal-reserve-acknowledged-step/`.", "",
    "## What changed", "",
    "- Added a static opt-in `Signal` state after the accepted v0.287 `RESERVE ASSIGNED` state.",
    "- The East bridge defender card exposes `Signal available`, then `Signal sent` / `Reserve acknowledged`.",
    "- The Field Barracks card acknowledges `Bridge signal received` without receiving a Signal action.",
    "- Repeating Signal preserves one `SIGNAL SENT` label, one `RESERVE ACK` label, and one static reserve marker.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.288 review steps.",
    "- v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before signal acknowledgement.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.289.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_v0288_VALIDATION" : "PASS_v0288_BARROSAN_BRIDGE_SIGNAL_RESERVE_ACKNOWLEDGED_STEP_VALIDATION";
  writeFileSync(join(root, "v0288-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
