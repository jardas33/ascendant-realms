import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0286"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0286"));
const manual = join(repo, "artifacts", "manual-review", "v0286-barrosan-field-barracks-reserve-ready-step");
const docPath = join(repo, "docs", "V0286_BARROSAN_FIELD_BARRACKS_RESERVE_READY_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "field-barracks-reserve-ready-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0286-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0286_preflight_head_ci_resolution.png",
  "02_v0286_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0286_retained_v0282_v0284_baseline_ledger_proof.png",
  "04_v0286_manual_fixture_baseline_clean_hud.png",
  "05_v0286_engage_available_before_click.png",
  "06_v0286_engage_armed.png",
  "07_v0286_commit_engage_clicked.png",
  "08_v0286_post_commit_pressure_checked_ashen_braced.png",
  "09_v0286_hold_line_available_after_commit_locked.png",
  "10_v0286_hold_line_clicked.png",
  "11_v0286_line_held_exactly_once.png",
  "12_v0286_ashen_contained_exactly_once.png",
  "13_v0286_select_field_barracks_after_hold_line.png",
  "14_v0286_field_barracks_train_available_reserve_slot_empty.png",
  "15_v0286_train_militia_clicked.png",
  "16_v0286_reserve_ready_exactly_once.png",
  "17_v0286_barracks_card_reserve_militia_ready.png",
  "18_v0286_repeat_train_no_duplicate_reserve_no_stack.png",
  "19_v0286_resources_unchanged_after_reserve_ready.png",
  "20_v0286_reserve_marker_no_movement_pathing_attack_actions.png",
  "21_v0286_watchpost_no_hold_line_engage_commit_ashen_reserve.png",
  "22_v0286_clear_guard_settles_defender_contact_clean.png",
  "23_v0286_reguard_clean_after_reserve_ready.png",
  "24_v0286_no_projectile_damage_hp_loss_death_despawn.png",
  "25_v0286_ui_layout_diagnostic_proof_retained.png",
  "26_v0286_contact_sheet.png",
  "27_v0286_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0286_manual_fixture_baseline_clean_hud",
  "v0286_engage_available_before_click",
  "v0286_engage_armed",
  "v0286_commit_engage_clicked",
  "v0286_post_commit_pressure_checked_ashen_braced",
  "v0286_hold_line_available_after_commit_locked",
  "v0286_hold_line_clicked",
  "v0286_line_held_exactly_once",
  "v0286_ashen_contained_exactly_once",
  "v0286_select_field_barracks_after_hold_line",
  "v0286_field_barracks_train_available_reserve_slot_empty",
  "v0286_train_militia_clicked",
  "v0286_reserve_ready_exactly_once",
  "v0286_barracks_card_reserve_militia_ready",
  "v0286_repeat_train_no_duplicate_reserve_no_stack",
  "v0286_resources_unchanged_after_reserve_ready",
  "v0286_reserve_marker_no_movement_pathing_attack_actions",
  "v0286_watchpost_no_hold_line_engage_commit_ashen_reserve",
  "v0286_clear_guard_settles_defender_contact_clean",
  "v0286_reguard_clean_after_reserve_ready",
  "v0286_no_projectile_damage_hp_loss_death_despawn",
];

const reserveModes = new Set([
  "v0286_train_militia_clicked",
  "v0286_reserve_ready_exactly_once",
  "v0286_barracks_card_reserve_militia_ready",
  "v0286_repeat_train_no_duplicate_reserve_no_stack",
  "v0286_resources_unchanged_after_reserve_ready",
  "v0286_reserve_marker_no_movement_pathing_attack_actions",
  "v0286_clear_guard_settles_defender_contact_clean",
  "v0286_reguard_clean_after_reserve_ready",
  "v0286_no_projectile_damage_hp_loss_death_despawn",
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
    "reserveMarkerAttackAdded", "reserveMarkerEngageAction", "reserveMarkerCommitAction", "reserveMarkerHoldLineAction",
    "reserveMarkerTakesDamage", "reserveMarkerDealsDamage", "reserveMarkerDeath", "reserveMarkerDespawned",
  ];
  return !forbidden.some((key) => Boolean(c[key]) || Boolean(snap[key]));
}

function shortHudText(snap) {
  const lines = snap.hudTextLines ?? {};
  const values = [lines.nameAndRole, lines.primaryState, lines.tacticalFacts, lines.readiness, lines.topStrip].map((v) => String(v ?? ""));
  return values.every((value) => value.length > 0 && value.length <= 74) &&
    !values.some((value) => /validator|projectile, damage|enemy death\/despawn/i.test(value));
}

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanFieldBarracksReserveReadyStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.286") errors.push("true default capture leaked v0.286 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0286_") || String(c.id ?? "").startsWith("v0286_"))) errors.push("true default capture contains v0.286 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.286") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.286`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 21) errors.push(`opt-in runtime expected 21 v0.286 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.286 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.286 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.286 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(snap)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.fieldBarracksReserveReadyStepOnly || !snap.v0285HoldLineFlowRetained || !snap.v0284HudLayoutRetained || !snap.productionReadinessOnly || !snap.noCombatMovementPathingEconomyMutation) errors.push(`${mode} is not reserve-readiness-only with v0.285/v0.284 retained`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
  }

  if (snapshot(snaps, "v0286_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0286_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0286_commit_engage_clicked", "v0286_post_commit_pressure_checked_ashen_braced", "v0286_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.filter((x) => x === "PRESSURE CHECKED").length !== 1 || labels.filter((x) => x === "ASHEN BRACED").length !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0286_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");

  for (const mode of ["v0286_hold_line_clicked", "v0286_line_held_exactly_once", "v0286_ashen_contained_exactly_once"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.filter((x) => x === "LINE HELD").length !== 1) errors.push(`${mode} does not render LINE HELD exactly once: ${JSON.stringify(labels)}`);
    if (labels.filter((x) => x === "ASHEN CONTAINED").length !== 1) errors.push(`${mode} does not render ASHEN CONTAINED exactly once: ${JSON.stringify(labels)}`);
    if (labels.includes("ASHEN BRACED") || labels.includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels: ${JSON.stringify(labels)}`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }

  if (!snapshot(snaps, "v0286_field_barracks_train_available_reserve_slot_empty").barracksTrainAvailable) errors.push("Field Barracks Train was not available with reserve slot empty");
  for (const mode of reserveModes) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.filter((x) => x === "RESERVE READY").length !== 1 || !snap.reserveReadyExactlyOne) errors.push(`${mode} does not render RESERVE READY exactly once: ${JSON.stringify(labels)}`);
  }
  if (!snapshot(snaps, "v0286_train_militia_clicked").trainCreatesReserveReadyExactlyOnce) errors.push("Train Militia did not create exactly one reserve marker");
  if (!snapshot(snaps, "v0286_repeat_train_no_duplicate_reserve_no_stack").repeatTrainNoDuplicateReserve) errors.push("repeat Train duplicated reserve marker or label");
  if (!snapshot(snaps, "v0286_resources_unchanged_after_reserve_ready").resourcesUnchangedAfterReserveReady) errors.push("resources changed after reserve ready");
  if (!snapshot(snaps, "v0286_reserve_marker_no_movement_pathing_attack_actions").reserveMarkerNoMovementPathingAttackActions) errors.push("reserve marker gained movement/pathing/attack/engage/commit/hold behavior");
  if (!snapshot(snaps, "v0286_watchpost_no_hold_line_engage_commit_ashen_reserve").watchpostNoReserveAction) errors.push("Watchpost leaked reserve or combat action");
  if (!snapshot(snaps, "v0286_clear_guard_settles_defender_contact_clean").clearGuardSettlesDefenderContactClean) errors.push("Clear Guard did not settle defender contact cleanly with reserve retained");
  if (!snapshot(snaps, "v0286_reguard_clean_after_reserve_ready").reguardCleanAfterReserveReady) errors.push("Reguard was not clean after reserve-ready state");
  if (!snapshot(snaps, "v0286_no_projectile_damage_hp_loss_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/HP loss/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 23) errors.push(`expected 23 v0.286 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.286 Barrosan Field Barracks Reserve Ready Step Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `049ffefc6303a81cce19ecdc91cac16098a0d78e`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0286-barrosan-field-barracks-reserve-ready-step/`.", "",
    "## What changed", "",
    "- Added a static opt-in `RESERVE READY` marker after the accepted v0.285 Hold Line state.",
    "- Field Barracks selected-card text now shows Train Militia availability, then reserve ready / no deployment.",
    "- Repeating Train preserves one marker and records no duplicate reserve state.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.286 review steps.",
    "- v0.285 Engage -> Commit -> Hold Line flow remains unchanged before Barracks Train.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.287.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0286_VALIDATION" : "PASS_V0286_BARROSAN_FIELD_BARRACKS_RESERVE_READY_STEP_VALIDATION";
  writeFileSync(join(root, "v0286-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
