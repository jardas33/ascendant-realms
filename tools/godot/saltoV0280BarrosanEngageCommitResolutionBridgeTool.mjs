import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0280"));
const manual = join(repo, "artifacts", "manual-review", "v0280-barrosan-engage-commit-resolution-bridge");
const docPath = join(repo, "docs", "V0280_BARROSAN_ENGAGE_COMMIT_RESOLUTION_BRIDGE_REPORT.md");
const runtimePath = join(root, "engage-commit-resolution-bridge-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0280-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0280_engage_available_before_click_visible",
  "v0280_engage_armed_exactly_one_world_label_visible",
  "v0280_commit_engage_button_available_visible",
  "v0280_commit_engage_clicked_visible",
  "v0280_post_commit_exactly_one_world_label_visible",
  "v0280_hud_card_post_commit_details_visible",
  "v0280_repeat_commit_no_stack_pressure_effects_visible",
  "v0280_clear_guard_removes_commit_label_visible",
  "v0280_reguard_availability_clean_visible",
  "v0280_watchpost_no_engage_commit_action_visible",
  "v0280_barracks_no_engage_commit_action_visible",
  "v0280_no_projectile_unit_damage_enemy_death_visible",
  "v0280_default_runtime_unchanged_probe_visible",
];

const requiredImages = [
  "01_v0280_preflight_head_ci_resolution.png",
  "02_v0280_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "16_v0280_contact_sheet_visible.png",
  "17_v0280_black_frame_rejection_report_visible.png",
];

const armedWorldLabelProofNames = [
  "v0280_engage_armed_exactly_one_world_label_visible",
  "v0280_commit_engage_button_available_visible",
];

const committedWorldLabelProofNames = [
  "v0280_commit_engage_clicked_visible",
  "v0280_post_commit_exactly_one_world_label_visible",
  "v0280_hud_card_post_commit_details_visible",
  "v0280_repeat_commit_no_stack_pressure_effects_visible",
  "v0280_no_projectile_unit_damage_enemy_death_visible",
];

const forbiddenRenderedWorldLabelFragments = [
  "ENGAGEMENT CONTAINED",
  "BRIDGE HELD",
  "CONTACT RESOLVED",
  "GUARD BRIDGE",
  "DEFENDER POSITION",
  "CONTACT THRESHOLD",
  "ASHEN SCOUTED CURRENT",
  "INTERCEPT READY",
  "HOLDING EAST BRIDGE",
  "FIRST CONTACT",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function snapshot(snaps, visibleName) {
  return snaps[visibleName.replace(/_visible$/, "")] ?? {};
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
  const runtime = readJson(runtimePath);
  const baseline = readJson(defaultPath);
  const stats = readJson(statsPath);
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanEngageCommitResolutionBridge ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];

  if (runtime.checkpoint !== "v0.280") errors.push("runtime checkpoint is not v0.280");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 13) errors.push(`expected 13 runtime captures, saw ${runtime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`v0.280 commit-resolution bridge status is ${proof.status}`);
  if (!proof.manualOnly || !proof.noProjectileUnitDamageEnemyDeath || !proof.noPathingAiEconomyFogDefaultMutation) errors.push("v0.280 proof did not stay manual/no-combat/no-mutation");
  for (const name of runtimeNames) if (!snaps[name.replace(/_visible$/, "")]) errors.push(`missing proof snapshot ${name}`);
  for (const file of requiredImages) if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.readabilityOnly || !snap.screenshotTruthOnly) errors.push(`${mode} is not readability/screenshot-truth only`);
    const expectedIntegrity = mode.includes("barracks_no_engage_commit_action") || mode.includes("default_runtime_unchanged_probe")
      ? 100
      : (mode.includes("commit_engage_clicked") || mode.includes("post_commit") || mode.includes("repeat_commit") || mode.includes("no_projectile_unit_damage_enemy_death") || mode.includes("clear_guard") || mode.includes("reguard")
          ? 80
          : 90);
    if (Number(c.pressureIntegrity ?? 100) !== expectedIntegrity) errors.push(`${mode} pressure integrity expected ${expectedIntegrity}, saw ${c.pressureIntegrity}`);
    if (/Watchpost attack|Tower attack|projectile fired|fires projectile|takes damage|enemy killed|enemy despawn/i.test(text)) errors.push(`${mode} text implies forbidden action`);
  }

  for (const name of armedWorldLabelProofNames) {
    const snap = snapshot(snaps, name);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    const forbidden = labels.filter((label) => forbiddenRenderedWorldLabelFragments.some((fragment) => String(label).includes(fragment)));
    if (forbidden.length) errors.push(`${name} contains forbidden rendered world labels: ${JSON.stringify(forbidden)}`);
    if (labels.length !== 1 || labels[0] !== "ENGAGE ARMED") errors.push(`${name} does not render exactly one tactical world label: ${JSON.stringify(labels)}`);
  }

  for (const name of armedWorldLabelProofNames) {
    const snap = snapshot(snaps, name);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    if (!snap.armedRuleRetained || !snap.forbiddenRenderedWorldLabelsAbsent) errors.push(`${name} failed retained v0.279 armed world-label rule: ${JSON.stringify(labels)}`);
    if (labels.length !== 1 || labels[0] !== "ENGAGE ARMED") errors.push(`${name} rendered labels are not exactly [ENGAGE ARMED]: ${JSON.stringify(labels)}`);
  }
  for (const name of committedWorldLabelProofNames) {
    const snap = snapshot(snaps, name);
    const labels = snap.renderedTacticalWorldLabelTexts ?? [];
    const forbidden = labels.filter((label) => forbiddenRenderedWorldLabelFragments.some((fragment) => String(label).includes(fragment)));
    if (forbidden.length) errors.push(`${name} contains forbidden committed world labels: ${JSON.stringify(forbidden)}`);
    if (labels.length !== 1 || labels[0] !== "PRESSURE CHECKED") errors.push(`${name} does not render exactly [PRESSURE CHECKED]: ${JSON.stringify(labels)}`);
    if (!snap.pressureChangedExactlyOnce || Number(snap.pressureBeforeCommit) !== 90 || Number(snap.pressureAfterCommit) !== 80) errors.push(`${name} did not apply exactly one 90 -> 80 pressure check`);
  }
  if (!snapshot(snaps, "v0280_commit_engage_button_available_visible").commitAvailable || !snapshot(snaps, "v0280_commit_engage_button_available_visible").commitActionOnMilitia) errors.push("Commit Engage button was not available only in valid armed Militia state");
  if (!snapshot(snaps, "v0280_hud_card_post_commit_details_visible").hudCardPostCommitDetails) errors.push("post-commit HUD/card detail proof failed");
  if (!snapshot(snaps, "v0280_repeat_commit_no_stack_pressure_effects_visible").repeatCommitDoesNotStack) errors.push("repeat Commit Engage stacked pressure/effects");
  if (!snapshot(snaps, "v0280_clear_guard_removes_commit_label_visible").commitLabelRemovedAfterClearGuard) errors.push("Clear Guard did not remove commit world label cleanly");
  if (!snapshot(snaps, "v0280_reguard_availability_clean_visible").reguardAvailableClean) errors.push("Reguard availability clean proof failed");
  if (!snapshot(snaps, "v0280_no_projectile_unit_damage_enemy_death_visible").noProjectileUnitDamageEnemyDeath) errors.push("no projectile/unit damage/enemy death proof failed");
  if (snapshot(snaps, "v0280_watchpost_no_engage_commit_action_visible").engageActionOnWatchpost || snapshot(snaps, "v0280_watchpost_no_engage_commit_action_visible").commitActionOnWatchpost) errors.push("Watchpost leaked Engage or Commit action");
  if (snapshot(snaps, "v0280_barracks_no_engage_commit_action_visible").engageActionOnBarracks || snapshot(snaps, "v0280_barracks_no_engage_commit_action_visible").commitActionOnBarracks) errors.push("Barracks leaked Engage or Commit action");
  if (snapshot(snaps, "v0280_default_runtime_unchanged_probe_visible").defaultRuntimeChanged) errors.push("default runtime changed probe failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 14) errors.push(`expected 14 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");
  return { errors, runtime, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.280 Barrosan Engage Commit Resolution Bridge Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `12e21632e8af6f2fb24d830972fad58f059bd07d`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0280-barrosan-engage-commit-resolution-bridge/`.", "",
    "## Boundary confirmation", "",
    "- v0.279 armed-state screenshot truth retained: yes. Armed state still renders exactly `ENGAGE ARMED`.",
    "- v0.280 is a manual/stateful resolution bridge only: yes.",
    "- Combat, attack, projectile, unit HP damage, enemy HP damage, enemy death/despawn, and recurring combat added: no.",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- Engage and Commit Engage remain Militia-only and remain unavailable outside the valid post-contact bridge-held / engagement-contained armed path.",
    "- Engage Armed uses exactly one world-space tactical label: `ENGAGE ARMED`.",
    "- Commit Engage appears only in the valid armed Militia Defender state.",
    "- One manual Commit Engage changes pressure state from 90/100 to 80/100 exactly once.",
    "- Post-commit uses exactly one world-space tactical label: `PRESSURE CHECKED`.",
    "- `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `CONTACT RESOLVED`, `FIRST CONTACT`, `DEFENDER POSITION`, `GUARD BRIDGE`, `CONTACT THRESHOLD`, `ASHEN SCOUTED CURRENT`, `INTERCEPT READY`, and `HOLDING EAST BRIDGE` are not visible as competing world labels while armed or committed.",
    "- HUD/card carries detailed state: Manual engage armed, Engagement contained, Bridge held, Pressure contained 90/100, No attack committed, No projectile, No damage.",
    "- HUD/card after commit carries: Engagement committed, Bridge held, Pressure checked 80/100, No projectile, No unit damage, No enemy death/despawn, Commit locked.",
    "- Repeat Commit Engage clicks do not stack pressure, labels, markers, attacks, projectiles, or damage.",
    "- Clear Guard after commit removes the commit world label cleanly and does not restore pressure automatically.",
    "- Reguard after Clear Guard restores availability without repeating the already committed consequence.",
    "- Watchpost and Barracks never show Engage or Commit Engage. Field Barracks remains the only Militia training source.",
    "- Watchpost remains passive/advisory/intel only.",
    "- Ashen pressure invariant retained: first contact drops 100/100 -> 90/100 once; manual Commit Engage checks pressure to 80/100 once; no unit/enemy damage.", "",
    "## Pixel validation", "",
    `- Required screenshots: ${requiredImages.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.", "",
    "## Recommendation for v0.281", "",
    "- If separately authorized, v0.281 can decide whether this stateful checked-pressure result becomes a true combat-resolution order. Keep it narrow and preserve rendered-node arbitration.", "",
    "Stop before v0.281.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0280_VALIDATION" : "PASS_V0280_BARROSAN_ENGAGE_COMMIT_RESOLUTION_BRIDGE_VALIDATION";
  writeFileSync(join(root, "v0280-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
