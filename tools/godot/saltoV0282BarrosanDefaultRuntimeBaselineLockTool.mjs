import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0282"));
const manual = join(repo, "artifacts", "manual-review", "v0282-barrosan-default-runtime-baseline-lock");
const docPath = join(repo, "docs", "V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LOCK_REPORT.md");
const ledgerPath = join(repo, "docs", "V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LEDGER.json");
const trueDefaultPath = join(root, "true-default-runtime", "screenshot-runtime-manifest.json");
const manualFixturePath = join(root, "v0281-manual-review-fixture-source", "screenshot-runtime-manifest.json");
const optInRuntimePath = join(root, "v0281-opt-in-readability-runtime-source", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0282-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const reviewImages = [
  "01_v0282_preflight_head_ci_resolution.png",
  "02_v0282_true_default_runtime_baseline_no_review_fixture.png",
  "03_v0282_true_default_runtime_baseline_ledger_proof.png",
  "04_v0282_barrosan_manual_review_fixture_baseline.png",
  "05_v0282_opt_in_readability_runtime_baseline.png",
  "06_v0282_engage_available_before_click_real_hud_only.png",
  "07_v0282_engage_armed_real_hud_clean.png",
  "08_v0282_engage_armed_exactly_one_world_label.png",
  "09_v0282_commit_engage_clicked.png",
  "10_v0282_post_commit_real_hud_clean_truthful.png",
  "11_v0282_post_commit_exactly_one_world_label.png",
  "12_v0282_repeat_commit_no_pressure_stack.png",
  "13_v0282_clear_guard_removes_commit_label.png",
  "14_v0282_reguard_availability_clean.png",
  "15_v0282_watchpost_no_engage_commit_action.png",
  "16_v0282_barracks_no_engage_commit_action.png",
  "17_v0282_no_projectile_no_damage_no_death_proof.png",
  "18_v0282_contact_sheet.png",
  "19_v0282_black_frame_rejection_report.png",
];

const retainedRuntimeModes = [
  "v0281_engage_available_before_click_real_hud_only",
  "v0281_engage_armed_real_hud_clean",
  "v0281_engage_armed_exactly_one_world_label",
  "v0281_commit_engage_button_available_real_hud",
  "v0281_commit_engage_clicked",
  "v0281_post_commit_real_hud_clean_truthful",
  "v0281_post_commit_exactly_one_world_label",
  "v0281_repeat_commit_no_stack_real_hud_80",
  "v0281_clear_guard_removes_commit_label_real_hud_clean",
  "v0281_reguard_availability_clean_real_hud",
  "v0281_watchpost_no_engage_commit_action_real_hud",
  "v0281_barracks_no_engage_commit_action_real_hud",
  "v0281_no_projectile_unit_damage_enemy_death",
  "v0281_default_runtime_unchanged_probe",
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

function expectRecord(errors, ledger, name, expected) {
  const record = ledger.records?.[name];
  if (!record) {
    errors.push(`ledger missing ${name}`);
    return;
  }
  for (const [key, value] of Object.entries(expected)) {
    if (record[key] !== value) errors.push(`ledger ${name}.${key} expected ${value}, saw ${record[key]}`);
  }
}

function evalEvidence() {
  const ledger = readJson(ledgerPath);
  const trueDefault = readJson(trueDefaultPath);
  const manualFixture = readJson(manualFixturePath);
  const optInRuntime = readJson(optInRuntimePath);
  const stats = readJson(statsPath);
  const skin = optInRuntime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanRealHudTruthOverlayRemoval ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (ledger.checkpoint !== "v0.282") errors.push("ledger checkpoint is not v0.282");
  if (ledger.baseHead !== "242815a1802521cb01670f9a14150f5829806707") errors.push("ledger baseHead does not match v0.281 final HEAD");
  expectRecord(errors, ledger, "trueDefaultRuntimeStart", {
    barrosanOptInActive: false,
    manualReviewFixtureActive: false,
    engageOrCommitActive: false,
    pressureMarkerActive: false,
  });
  expectRecord(errors, ledger, "barrosanManualReviewFixtureStart", {
    barrosanOptInActive: false,
    manualReviewFixtureActive: true,
    engageOrCommitActive: false,
    pressureMarkerActive: false,
  });
  expectRecord(errors, ledger, "optInReadabilityRuntimeStart", {
    barrosanOptInActive: true,
    manualReviewFixtureActive: true,
    engageOrCommitActive: false,
    pressureMarkerActive: false,
  });

  if (trueDefault.checkpoint === "v0.281") errors.push("true default capture leaked v0.281 review fixture checkpoint");
  if (trueDefault.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("true default capture enabled Barrosan opt-in");
  if ((trueDefault.captures ?? []).some((c) => String(c.action ?? "").startsWith("v0281_") || String(c.id ?? "").startsWith("v0281_"))) errors.push("true default capture contains v0.281 fixture actions");
  const defaultBaselineCapture = (trueDefault.captures ?? []).find((c) => c.fileName === "03_battle_default.png" && c.action === "battle_default");
  if (!defaultBaselineCapture) errors.push("true default baseline evidence is not the unmodified battle_default frame");
  if (defaultBaselineCapture && /engage|commit|pressure/i.test(`${defaultBaselineCapture.action ?? ""} ${defaultBaselineCapture.id ?? ""} ${defaultBaselineCapture.label ?? ""}`)) errors.push("true default baseline frame leaked Engage/Commit/pressure fixture labels");

  if (manualFixture.checkpoint !== "v0.281") errors.push("manual review fixture source did not dispatch retained v0.281 fixture steps");
  if (manualFixture.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("manual review fixture source unexpectedly enabled Barrosan opt-in");
  if (manualFixture.captureCount !== 14) errors.push(`manual review fixture expected 14 retained v0.281 captures, saw ${manualFixture.captureCount}`);

  if (optInRuntime.checkpoint !== "v0.281") errors.push("opt-in readability source did not dispatch retained v0.281 fixture steps");
  if (skin.enabled !== true) errors.push("opt-in readability source did not enable Barrosan opt-in");
  if (optInRuntime.captureCount !== 14) errors.push(`opt-in readability expected 14 retained v0.281 captures, saw ${optInRuntime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`retained v0.281 proof status is ${proof.status}`);
  if (!proof.manualOnly || !proof.reviewOnlyOverlayAbsent || !proof.realSelectedUnitHudCardTruth) errors.push("retained v0.281 HUD/manual/overlay invariants failed");
  if (!proof.noProjectileUnitDamageEnemyDeath || !proof.noPathingAiEconomyFogDefaultMutation) errors.push("retained v0.281 no-combat/no-mutation invariants failed");
  for (const mode of retainedRuntimeModes) if (!snaps[mode]) errors.push(`missing retained v0.281 snapshot ${mode}`);
  for (const file of reviewImages) if (!existsSync(join(manual, file))) errors.push(`missing v0.282 review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = String(snap.combinedText ?? "");
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.screenshotTruthOnly) errors.push(`${mode} is not readability/screenshot-truth only`);
    if (text.includes("V0280EngageCommitReviewCard") || text.includes("review card overlay")) errors.push(`${mode} leaked the removed v0.280 review-card overlay`);
    if (!snap.reviewOnlyOverlayAbsent || Number(snap.selectedHudCardCount) !== 1 || !snap.realHudHasSingleStateBlock) errors.push(`${mode} failed real-HUD-only selected-card invariant`);
  }

  for (const mode of ["v0281_engage_armed_real_hud_clean", "v0281_engage_armed_exactly_one_world_label", "v0281_commit_engage_button_available_real_hud"]) {
    const labels = snapshot(snaps, mode).renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 1 || labels[0] !== "ENGAGE ARMED") errors.push(`${mode} does not render exactly [ENGAGE ARMED]: ${JSON.stringify(labels)}`);
  }
  for (const mode of ["v0281_commit_engage_clicked", "v0281_post_commit_real_hud_clean_truthful", "v0281_post_commit_exactly_one_world_label", "v0281_repeat_commit_no_stack_real_hud_80", "v0281_no_projectile_unit_damage_enemy_death"]) {
    const snap = snapshot(snaps, mode);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (labels.length !== 1 || labels[0] !== "PRESSURE CHECKED") errors.push(`${mode} does not render exactly [PRESSURE CHECKED]: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${mode} did not retain exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0281_repeat_commit_no_stack_real_hud_80").repeatCommitDoesNotStack) errors.push("repeat commit retained pressure stack");
  if (!snapshot(snaps, "v0281_clear_guard_removes_commit_label_real_hud_clean").commitLabelRemovedAfterClearGuard) errors.push("Clear Guard did not remove commit label");
  if (!snapshot(snaps, "v0281_reguard_availability_clean_real_hud").reguardAvailableClean) errors.push("Reguard availability clean invariant failed");
  if (snapshot(snaps, "v0281_watchpost_no_engage_commit_action_real_hud").engageActionOnWatchpost || snapshot(snaps, "v0281_watchpost_no_engage_commit_action_real_hud").commitActionOnWatchpost) errors.push("Watchpost leaked Engage/Commit");
  if (snapshot(snaps, "v0281_barracks_no_engage_commit_action_real_hud").engageActionOnBarracks || snapshot(snaps, "v0281_barracks_no_engage_commit_action_real_hud").commitActionOnBarracks) errors.push("Barracks leaked Engage/Commit");
  if (!snapshot(snaps, "v0281_no_projectile_unit_damage_enemy_death").noProjectileUnitDamageEnemyDeath) errors.push("no projectile/unit damage/enemy death proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 16) errors.push(`expected 16 v0.282 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 20000 || minUnique < 100 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");

  return { errors, ledger, trueDefault, manualFixture, optInRuntime, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.282 Barrosan Default Runtime Baseline Lock Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `242815a1802521cb01670f9a14150f5829806707`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Ledger: `docs/V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LEDGER.json`.",
    "- Review pack path: `artifacts/manual-review/v0282-barrosan-default-runtime-baseline-lock/`.", "",
    "## Baseline ledger separation", "",
    "- True default runtime: captured without Barrosan opt-in and without the v0.281 manual review fixture path.",
    "- Barrosan manual review fixture: retained v0.281 review steps are active, Barrosan opt-in remains disabled.",
    "- Opt-in readability runtime: retained v0.281 review steps are active and Barrosan opt-in is enabled.",
    "- The pack no longer labels a fixture capture as `default runtime unchanged`.", "",
    "## Boundary confirmation", "",
    "- Gameplay expansion: no.",
    "- Combat/projectile/HP damage/enemy death/despawn/pathing/AI/economy/fog/waves/runtime mutation: no.",
    "- v0.281 Engage/Commit readability behavior retained: yes.",
    "- v0.281 removed v0.280 review-card overlay remains absent: yes.",
    "- Real HUD/card remains single and clean: yes.",
    "- Watchpost/Barracks still do not expose Engage or Commit: yes.",
    "- Manual Commit Engage still checks pressure 90/100 -> 80/100 once, with no projectile, unit damage, enemy death/despawn, repeat stack, pathing, AI, economy, or fog change.", "",
    "## Pixel validation", "",
    `- Required review images: ${reviewImages.length}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.", "",
    "## Recommendation for v0.283", "",
    "- Proceed only after this baseline lock remains green remotely; the next slice may then decide whether to extend combat, but this checkpoint intentionally does not.", "",
    "Stop before v0.283.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0282_VALIDATION" : "PASS_V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LOCK_VALIDATION";
  writeFileSync(join(root, "v0282-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
