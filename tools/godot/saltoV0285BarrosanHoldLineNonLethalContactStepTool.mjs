import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0285"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0285"));
const manual = join(repo, "artifacts", "manual-review", "v0285-barrosan-hold-line-non-lethal-contact-step");
const docPath = join(repo, "docs", "V0285_BARROSAN_HOLD_LINE_NON_LETHAL_CONTACT_STEP_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "hold-line-non-lethal-contact-step-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0285-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0285_preflight_head_ci_resolution.png",
  "02_v0285_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0285_retained_v0282_v0284_baseline_ledger_proof.png",
  "04_v0285_manual_fixture_baseline_clean_hud.png",
  "05_v0285_engage_available_before_click.png",
  "06_v0285_engage_armed.png",
  "07_v0285_commit_engage_clicked.png",
  "08_v0285_post_commit_pressure_checked_ashen_braced.png",
  "09_v0285_hold_line_available_after_commit_locked.png",
  "10_v0285_hold_line_clicked.png",
  "11_v0285_line_held_exactly_once.png",
  "12_v0285_ashen_contained_exactly_once.png",
  "13_v0285_combined_line_held_ashen_contained_readable_hud.png",
  "14_v0285_repeat_hold_line_no_duplicate_no_stack.png",
  "15_v0285_clear_guard_settles_hold_line.png",
  "16_v0285_reguard_availability_clean_after_hold_line.png",
  "17_v0285_watchpost_no_hold_line_engage_commit_ashen.png",
  "18_v0285_barracks_no_hold_line_engage_commit_ashen.png",
  "19_v0285_no_projectile_damage_death_despawn.png",
  "20_v0285_ui_layout_diagnostic_proof_retained.png",
  "21_v0285_contact_sheet.png",
  "22_v0285_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0285_manual_fixture_baseline_clean_hud",
  "v0285_engage_available_before_click",
  "v0285_engage_armed",
  "v0285_commit_engage_clicked",
  "v0285_post_commit_pressure_checked_ashen_braced",
  "v0285_hold_line_available_after_commit_locked",
  "v0285_hold_line_clicked",
  "v0285_line_held_exactly_once",
  "v0285_ashen_contained_exactly_once",
  "v0285_combined_line_held_ashen_contained_readable_hud",
  "v0285_repeat_hold_line_no_duplicate_no_stack",
  "v0285_clear_guard_settles_hold_line",
  "v0285_reguard_availability_clean_after_hold_line",
  "v0285_watchpost_no_hold_line_engage_commit_ashen",
  "v0285_barracks_no_hold_line_engage_commit_ashen",
  "v0285_no_projectile_damage_death_despawn",
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
  const proof = skin.barrosanHoldLineNonLethalContactStep ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.285") errors.push("true default capture leaked v0.285 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0285_") || String(c.id ?? "").startsWith("v0285_"))) errors.push("true default capture contains v0.285 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.285") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.285`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 16) errors.push(`opt-in runtime expected 16 v0.285 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.285 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.285 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.285 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const layout = snap.layoutDiagnostics ?? {};
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.screenshotTruthOnly || !snap.holdLineNonLethalContactStepOnly || !snap.v0284HudLayoutRetained || !snap.v0283StateBridgeRetained) errors.push(`${mode} is not Hold Line-only with v0.284/v0.283 retained`);
    if (!shortHudText(snap)) errors.push(`${mode} has raw paragraph or overlong HUD text`);
    if (layout.layoutStatus !== "PASS" || layout.textLineExceededAllowedWidth || layout.textOverlappedButtons || layout.lineCountExceededVisibleRows || !layout.rawParagraphsAbsent) errors.push(`${mode} failed layout diagnostics`);
  }

  if (snapshot(snaps, "v0285_manual_fixture_baseline_clean_hud").hudTextLines?.tacticalFacts !== "Select Aster.") errors.push("manual fixture did not retain clean HUD baseline");
  if (JSON.stringify(snapshot(snaps, "v0285_engage_armed").renderedTacticalWorldLabelTexts ?? []) !== JSON.stringify(["ENGAGE ARMED"])) errors.push("Engage armed did not preserve exactly one ENGAGE ARMED label");
  for (const mode of ["v0285_commit_engage_clicked", "v0285_post_commit_pressure_checked_ashen_braced", "v0285_hold_line_available_after_commit_locked"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.filter((x) => x === "PRESSURE CHECKED").length !== 1 || labels.filter((x) => x === "ASHEN BRACED").length !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0285_hold_line_available_after_commit_locked").holdLineAvailableAfterCommitLocked) errors.push("Hold Line was not available after Commit locked");

  for (const mode of ["v0285_hold_line_clicked", "v0285_line_held_exactly_once", "v0285_ashen_contained_exactly_once", "v0285_combined_line_held_ashen_contained_readable_hud", "v0285_repeat_hold_line_no_duplicate_no_stack", "v0285_no_projectile_damage_death_despawn"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.filter((x) => x === "LINE HELD").length !== 1) errors.push(`${mode} does not render LINE HELD exactly once: ${JSON.stringify(labels)}`);
    if (labels.filter((x) => x === "ASHEN CONTAINED").length !== 1) errors.push(`${mode} does not render ASHEN CONTAINED exactly once: ${JSON.stringify(labels)}`);
    if (labels.includes("ASHEN BRACED") || labels.includes("PRESSURE CHECKED")) errors.push(`${mode} left stale pre-Hold labels: ${JSON.stringify(labels)}`);
    if (!snap.holdLineResolvedOnce || !snap.staleAshenBracedAbsentAfterHold) errors.push(`${mode} did not resolve Hold Line once with stale Ashen braced absent`);
  }
  if (!snapshot(snaps, "v0285_repeat_hold_line_no_duplicate_no_stack").repeatHoldLineNoDuplicateLabels) errors.push("repeat Hold Line duplicated labels or stacked state");
  if (!snapshot(snaps, "v0285_clear_guard_settles_hold_line").clearGuardSettlesHoldLine || (snapshot(snaps, "v0285_clear_guard_settles_hold_line").renderedTacticalWorldLabelTexts ?? []).length !== 0) errors.push("Clear Guard did not settle held/contained labels cleanly");
  if (!snapshot(snaps, "v0285_reguard_availability_clean_after_hold_line").reguardAvailabilityCleanAfterHoldLine || (snapshot(snaps, "v0285_reguard_availability_clean_after_hold_line").renderedTacticalWorldLabelTexts ?? []).length !== 0) errors.push("Reguard clean invariant failed after Hold Line");
  if (!snapshot(snaps, "v0285_watchpost_no_hold_line_engage_commit_ashen").noCommandEntityClean) errors.push("Watchpost leaked Hold Line/Engage/Commit/Ashen action");
  if (!snapshot(snaps, "v0285_barracks_no_hold_line_engage_commit_ashen").noCommandEntityClean) errors.push("Barracks leaked Hold Line/Engage/Commit/Ashen action");
  if (!snapshot(snaps, "v0285_no_projectile_damage_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 18) errors.push(`expected 18 v0.285 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.285 Barrosan Hold Line Non-Lethal Contact Step Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `f5e0c81b8cf221d2637a8ed19fc511d525a4a15c`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0285-barrosan-hold-line-non-lethal-contact-step/`.", "",
    "## What changed", "",
    "- Added the opt-in `HOLD LINE` follow-up after the v0.283/v0.284 Commit Engage locked state.",
    "- Hold Line changes the selected Militia Defender card to `Line held` and shows `Bridge held | Pressure 80/100 | Ashen contained`.",
    "- The post-Hold world state renders `LINE HELD` near the defender and `ASHEN CONTAINED` near the Ashen side exactly once.",
    "- Repeating Hold Line is locked to the same state and cannot duplicate labels or stack pressure.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.285 review steps.",
    "- v0.284 HUD/text layout contract remains the layout source: four readable rows, button row separated, concise top strip.",
    "- v0.283 pressure/ASHEN BRACED state remains unchanged until Hold Line is invoked.",
    "- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.286.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0285_VALIDATION" : "PASS_V0285_BARROSAN_HOLD_LINE_NON_LETHAL_CONTACT_STEP_VALIDATION";
  writeFileSync(join(root, "v0285-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
