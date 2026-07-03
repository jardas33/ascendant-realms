import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0284"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0284"));
const manual = join(repo, "artifacts", "manual-review", "v0284-barrosan-hud-text-layout-repair");
const docPath = join(repo, "docs", "V0284_BARROSAN_HUD_TEXT_LAYOUT_REPAIR_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "hud-text-layout-repair-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0284-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0284_preflight_head_ci_resolution.png",
  "02_v0284_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0284_retained_v0282_baseline_ledger_proof.png",
  "04_v0284_manual_fixture_baseline_clean_select_aster.png",
  "05_v0284_engage_available_before_click_readable_hud.png",
  "06_v0284_engage_armed_readable_hud.png",
  "07_v0284_engage_armed_exactly_one_short_world_label.png",
  "08_v0284_commit_engage_clicked_readable_hud.png",
  "09_v0284_post_commit_pressure_checked_once_readable_hud.png",
  "10_v0284_post_commit_ashen_braced_once_readable_hud.png",
  "11_v0284_combined_labels_readable_hud.png",
  "12_v0284_repeat_commit_no_duplicate_readable_hud.png",
  "13_v0284_clear_guard_settles_ashen_response_readable_hud.png",
  "14_v0284_reguard_availability_clean_readable_hud.png",
  "15_v0284_watchpost_no_engage_commit_ashen_braced_readable_hud.png",
  "16_v0284_barracks_no_engage_commit_ashen_braced_readable_hud.png",
  "17_v0284_no_projectile_damage_death_despawn_readable_hud.png",
  "18_v0284_ui_layout_diagnostic_proof.png",
  "19_v0284_contact_sheet.png",
  "20_v0284_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0284_manual_fixture_baseline_clean_select_aster",
  "v0284_engage_available_before_click",
  "v0284_engage_armed_hud_clean",
  "v0284_engage_armed_exactly_one_world_label",
  "v0284_commit_engage_clicked",
  "v0284_post_commit_player_pressure_checked_label",
  "v0284_post_commit_ashen_braced_label",
  "v0284_post_commit_combined_pressure_checked_ashen_braced",
  "v0284_repeat_commit_no_stack_no_duplicate_ashen_braced",
  "v0284_clear_guard_settles_ashen_response",
  "v0284_reguard_availability_clean",
  "v0284_watchpost_no_engage_commit_ashen_braced",
  "v0284_barracks_no_engage_commit_ashen_braced",
  "v0284_no_projectile_damage_death_despawn",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, mode) {
  return snaps[mode] ?? {};
}

function passive(c) {
  return ![
    "automaticMovementAdded", "autoMoveAttempted", "automaticAttackAdded", "watchpostCausedDamage",
    "watchpostAttackAdded", "projectilesAdded", "towerAttackAdded", "slowAdded", "redirectAdded",
    "enemyPathingChanged", "enemyAiChanged", "waveTimingChanged", "economyAdded", "collisionChanged",
    "fogOfWarAdded", "broadVisionAdded", "enemyStopped", "enemyDespawned", "enemyDeath",
    "engagementDamageAdded", "engagementAutoMoveAdded", "engagementAutoAttackAdded",
    "engagementProjectileAdded", "engagementVisualIsProjectile",
  ].some((key) => Boolean(c[key])) &&
    Number(c.militiaHpBeforeContact) === Number(c.militiaHpAfterContact) &&
    Number(c.watchpostHpBeforeContact) === Number(c.watchpostHpAfterContact);
}

function shortHudText(snap) {
  const lines = snap.hudTextLines ?? {};
  const values = [lines.nameAndRole, lines.primaryState, lines.tacticalFacts, lines.readiness, lines.topStrip].map((v) => String(v ?? ""));
  return values.every((value) => value.length > 0 && value.length <= 74) &&
    !values.some((value) => /no attack, projectile|enemy death\/despawn|movement, death|validator/i.test(value));
}

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanHudTextLayoutRepair ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.284") errors.push("true default capture leaked v0.284 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0284_") || String(c.id ?? "").startsWith("v0284_"))) errors.push("true default capture contains v0.284 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.284") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.284`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 14) errors.push(`opt-in runtime expected 14 v0.284 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.284 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.284 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.284 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.screenshotTruthOnly || !snap.hudTextLayoutRepairOnly || !snap.v0283StateBridgeRetained) errors.push(`${mode} is not readability/layout-only with v0.283 retained`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
  }

  if (snapshot(snaps, "v0284_manual_fixture_baseline_clean_select_aster").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not place Select Aster inside the selected card text");
  for (const mode of ["v0284_engage_armed_hud_clean", "v0284_engage_armed_exactly_one_world_label"]) {
    const labels = snapshot(snaps, mode).renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 1 || labels[0] !== "ENGAGE ARMED") errors.push(`${mode} does not render exactly [ENGAGE ARMED]: ${JSON.stringify(labels)}`);
  }
  for (const mode of ["v0284_commit_engage_clicked", "v0284_post_commit_player_pressure_checked_label", "v0284_post_commit_ashen_braced_label", "v0284_post_commit_combined_pressure_checked_ashen_braced", "v0284_no_projectile_damage_death_despawn"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 2 || labels.filter((x) => x === "PRESSURE CHECKED").length !== 1 || labels.filter((x) => x === "ASHEN BRACED").length !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0284_repeat_commit_no_stack_no_duplicate_ashen_braced").repeatCommitNoDuplicateAshenBraced) errors.push("repeat commit duplicated ASHEN BRACED or stacked pressure");
  if (!snapshot(snaps, "v0284_clear_guard_settles_ashen_response").clearGuardSettlesAshenResponse) errors.push("Clear Guard did not settle Ashen response cleanly");
  if (!snapshot(snaps, "v0284_reguard_availability_clean").reguardAvailabilityClean) errors.push("Reguard clean invariant failed");
  if (!snapshot(snaps, "v0284_watchpost_no_engage_commit_ashen_braced").noCommitEntityClean) errors.push("Watchpost leaked Engage/Commit/Ashen braced");
  if (!snapshot(snaps, "v0284_barracks_no_engage_commit_ashen_braced").noCommitEntityClean) errors.push("Barracks leaked Engage/Commit/Ashen braced");
  if (!snapshot(snaps, "v0284_no_projectile_damage_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 16) errors.push(`expected 16 v0.284 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.284 Barrosan HUD/Text Layout Repair Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `57a229804fd3e37cb9e55f0219b34742b17b5de4`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0284-barrosan-hud-text-layout-repair/`.", "",
    "## What changed", "",
    "- Added an opt-in v0.284 HUD/text layout wrapper over the retained v0.283 state bridge.",
    "- Selected-unit card now uses four short game-facing rows: name/role, primary state, tactical facts, and readiness.",
    "- Button row is explicitly separated from the text rect and checked by deterministic layout diagnostics.",
    "- Top status strip uses concise vocabulary only.",
    "- The manual fixture `Select Aster.` copy is held inside the selected-card facts row instead of floating beside the card.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.284 review steps.",
    "- v0.283 pressure/ASHEN BRACED state proof remains the source of truth.",
    "- No projectile, HP damage, enemy damage, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.285.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0284_VALIDATION" : "PASS_V0284_BARROSAN_HUD_TEXT_LAYOUT_REPAIR_VALIDATION";
  writeFileSync(join(root, "v0284-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
