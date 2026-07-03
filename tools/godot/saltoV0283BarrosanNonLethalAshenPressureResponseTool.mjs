import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0283"));
const trueDefaultRoot = resolve(arg("true-default-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "true-default-runtime-baseline-lock-0283"));
const manual = join(repo, "artifacts", "manual-review", "v0283-barrosan-non-lethal-ashen-pressure-response");
const docPath = join(repo, "docs", "V0283_BARROSAN_NON_LETHAL_ASHEN_PRESSURE_RESPONSE_REPORT.md");
const trueDefaultPath = join(trueDefaultRoot, "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "non-lethal-ashen-pressure-response-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0283-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0283_preflight_head_ci_resolution.png",
  "02_v0283_true_default_runtime_baseline_no_fixture_no_opt_in.png",
  "03_v0283_retained_v0282_baseline_ledger_proof.png",
  "04_v0283_engage_available_before_click.png",
  "05_v0283_engage_armed_hud_clean.png",
  "06_v0283_engage_armed_exactly_one_world_label.png",
  "07_v0283_commit_engage_clicked.png",
  "08_v0283_post_commit_player_pressure_checked_once.png",
  "09_v0283_post_commit_ashen_braced_once.png",
  "10_v0283_combined_pressure_checked_and_ashen_braced.png",
  "11_v0283_repeat_commit_no_stack_no_duplicate_ashen_braced.png",
  "12_v0283_clear_guard_settles_ashen_response.png",
  "13_v0283_reguard_availability_clean.png",
  "14_v0283_watchpost_no_engage_commit_ashen_braced.png",
  "15_v0283_barracks_no_engage_commit_ashen_braced.png",
  "16_v0283_no_projectile_damage_death_despawn.png",
  "17_v0283_contact_sheet.png",
  "18_v0283_black_frame_rejection_report.png",
];

const requiredModes = [
  "v0283_engage_available_before_click",
  "v0283_engage_armed_hud_clean",
  "v0283_engage_armed_exactly_one_world_label",
  "v0283_commit_engage_clicked",
  "v0283_post_commit_player_pressure_checked_label",
  "v0283_post_commit_ashen_braced_label",
  "v0283_post_commit_combined_pressure_checked_ashen_braced",
  "v0283_repeat_commit_no_stack_no_duplicate_ashen_braced",
  "v0283_clear_guard_settles_ashen_response",
  "v0283_reguard_availability_clean",
  "v0283_watchpost_no_engage_commit_ashen_braced",
  "v0283_barracks_no_engage_commit_ashen_braced",
  "v0283_no_projectile_damage_death_despawn",
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

function evalEvidence() {
  const trueDefault = readJson(trueDefaultPath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanNonLethalAshenPressureResponse ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (trueDefault.checkpoint === "v0.283") errors.push("true default capture leaked v0.283 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0283_") || String(c.id ?? "").startsWith("v0283_"))) errors.push("true default capture contains v0.283 fixture actions");
  const defaultFrame = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultFrame) errors.push("true default baseline evidence is not the unmodified battle_default frame");

  if (optInRuntime.checkpoint !== "v0.283") errors.push(`opt-in runtime dispatched ${optInRuntime.checkpoint}, expected v0.283`);
  if (skin.enabled !== true) errors.push("opt-in runtime did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 13) errors.push(`opt-in runtime expected 13 v0.283 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.283 proof status is ${proof.status}`);
  for (const mode of requiredModes) if (!snaps[mode]) errors.push(`missing v0.283 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.283 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.screenshotTruthOnly || !snap.nonLethalAshenPressureResponseOnly) errors.push(`${mode} is not non-lethal/screenshot-truth only`);
    if (!snap.staleAshenApproachAbsent || !snap.staleClutterLabelsAbsent) errors.push(`${mode} leaked stale tactical world labels`);
  }

  for (const mode of ["v0283_engage_armed_hud_clean", "v0283_engage_armed_exactly_one_world_label"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 1 || labels[0] !== "ENGAGE ARMED") errors.push(`${mode} does not render exactly [ENGAGE ARMED]: ${JSON.stringify(labels)}`);
  }

  for (const mode of ["v0283_commit_engage_clicked", "v0283_post_commit_player_pressure_checked_label", "v0283_post_commit_ashen_braced_label", "v0283_post_commit_combined_pressure_checked_ashen_braced", "v0283_no_projectile_damage_death_despawn"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 2 || labels.filter((x) => x === "PRESSURE CHECKED").length !== 1 || labels.filter((x) => x === "ASHEN BRACED").length !== 1) errors.push(`${mode} does not render exactly one PRESSURE CHECKED and one ASHEN BRACED: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not preserve exactly one 90 -> 80 pressure check`);
    if (!snap.noEngageArmedAfterCommit) errors.push(`${mode} leaked ENGAGE ARMED after commit`);
  }

  if (!snapshot(snaps, "v0283_repeat_commit_no_stack_no_duplicate_ashen_braced").repeatCommitNoDuplicateAshenBraced) errors.push("repeat commit duplicated ASHEN BRACED or stacked pressure");
  if (!snapshot(snaps, "v0283_clear_guard_settles_ashen_response").clearGuardSettlesAshenResponse) errors.push("Clear Guard did not settle Ashen response cleanly");
  if (!snapshot(snaps, "v0283_reguard_availability_clean").reguardAvailabilityClean) errors.push("Reguard clean invariant failed");
  if (!snapshot(snaps, "v0283_watchpost_no_engage_commit_ashen_braced").noCommitEntityClean) errors.push("Watchpost leaked Engage/Commit/Ashen braced");
  if (!snapshot(snaps, "v0283_barracks_no_engage_commit_ashen_braced").noCommitEntityClean) errors.push("Barracks leaked Engage/Commit/Ashen braced");
  if (!snapshot(snaps, "v0283_no_projectile_damage_death_despawn").noProjectileDamageDeathDespawn) errors.push("no projectile/damage/death/despawn proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 15) errors.push(`expected 15 v0.283 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.283 Barrosan Non-Lethal Ashen Pressure Response Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `5bca383ea33454a2b720a0af5e6bfd4636b36633`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Review pack path: `artifacts/manual-review/v0283-barrosan-non-lethal-ashen-pressure-response/`.", "",
    "## What changed", "",
    "- Opt-in v0.283 Commit Engage now produces one passive Ashen response state: `ASHEN BRACED`.",
    "- Player-side `PRESSURE CHECKED` remains exactly one.",
    "- Pressure still changes from 90 to 80 exactly once; repeat commit does not stack.",
    "- Clear Guard removes/settles both player commit and Ashen response labels cleanly.",
    "- Watchpost and Barracks do not receive Engage, Commit Engage, or Ashen-braced actions.", "",
    "## Boundaries retained", "",
    "- True default runtime remains unmodified and does not dispatch v0.283 review steps.",
    "- No projectile, HP damage, enemy damage, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.",
    "- Stale labels remain absent: `ENGAGE ARMED` after commit, `ASHEN APPROACH`, `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `GUARD BRIDGE`, `CONTACT RESOLVED`, and `INTERCEPT READY`.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`, "",
    "Stop before v0.284.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0283_VALIDATION" : "PASS_V0283_BARROSAN_NON_LETHAL_ASHEN_PRESSURE_RESPONSE_VALIDATION";
  writeFileSync(join(root, "v0283-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
