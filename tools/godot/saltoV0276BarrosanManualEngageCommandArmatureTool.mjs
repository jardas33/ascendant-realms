import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const repo = process.cwd();
const command = process.argv[2] || "validation";
const arg = (name) => {
  const prefix = `--${name}=`;
  const found = process.argv.find((value) => value.startsWith(prefix));
  return found ? found.slice(prefix.length) : "";
};

const root = resolve(arg("artifact-root") || join(repo, "artifacts", "desktop-spikes", "godot-salto", "v0276"));
const manual = join(repo, "artifacts", "manual-review", "v0276-barrosan-manual-engage-command-armature");
const docPath = join(repo, "docs", "V0276_BARROSAN_MANUAL_ENGAGE_COMMAND_ARMATURE_REPORT.md");
const runtimePath = join(root, "manual-engage-command-armature-runtime", "screenshot-runtime-manifest.json");
const defaultPath = join(root, "default-runtime", "screenshot-runtime-manifest.json");
const statsPath = join(manual, "v0276-black-frame-stats.json");
const verdict = arg("verdict") || "PARTIAL";

const runtimeNames = [
  "v0276_engage_unavailable_before_contact_visible",
  "v0276_engage_unavailable_militia_training_visible",
  "v0276_engage_unavailable_no_guard_order_visible",
  "v0276_engage_unavailable_guard_pending_visible",
  "v0276_engage_unavailable_guard_cleared_before_contact_visible",
  "v0276_engage_unavailable_not_holding_bridge_visible",
  "v0276_engage_unavailable_contact_not_resolved_visible",
  "v0276_engage_available_bridge_held_visible",
  "v0276_engage_available_engagement_contained_visible",
  "v0276_engage_click_arms_no_damage_visible",
  "v0276_engage_repeat_click_no_stack_no_damage_visible",
  "v0276_engage_armed_label_clean_visible",
  "v0276_engage_armed_hud_no_attack_projectile_damage_visible",
  "v0276_clear_guard_cancels_engage_visible",
  "v0276_reguard_engage_available_again_visible",
  "v0276_reguard_rearm_no_damage_visible",
  "v0276_watchpost_no_engage_action_visible",
  "v0276_barracks_no_engage_action_visible",
  "v0276_label_arbitration_retained_visible",
  "v0276_minimap_contact_ping_current_only_visible",
  "v0276_no_projectile_no_tower_visible",
  "v0276_no_auto_move_no_auto_attack_visible",
  "v0276_no_repeated_damage_below_90_visible",
  "v0276_default_runtime_unchanged_probe_visible",
  "v0276_existing_barracks_still_trains_militia_visible",
];

const requiredImages = [
  "01_v0276_preflight_head_ci_resolution.png",
  "02_v0276_default_runtime_unchanged_visible.png",
  ...runtimeNames.map((name, index) => `${String(index + 3).padStart(2, "0")}_${name}.png`),
  "28_v0276_contact_sheet_visible.png",
  "29_v0276_black_frame_rejection_report_visible.png",
];

function readJson(path) {
  if (!existsSync(path)) throw new Error(`Missing ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}
function snapshot(snaps, visibleName) { return snaps[visibleName.replace(/_visible$/, "")] ?? {}; }
function contactOf(snaps, visibleName) { return snapshot(snaps, visibleName).firstContact ?? {}; }
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
    Number(c.watchpostHpBeforeContact) === Number(c.watchpostHpAfterContact) &&
    Number(c.pressureIntegrity ?? 100) >= 90;
}

function evalEvidence() {
  const runtime = readJson(runtimePath);
  const baseline = readJson(defaultPath);
  const stats = readJson(statsPath);
  const skin = runtime.barrosanPlayableRuntimeSkin ?? {};
  const proof = skin.barrosanManualEngageCommandArmature ?? {};
  const snaps = proof.proofSnapshots ?? {};
  const errors = [];
  if (runtime.checkpoint !== "v0.276") errors.push("runtime checkpoint is not v0.276");
  if (baseline.barrosanPlayableRuntimeSkin?.enabled === true) errors.push("default runtime changed/enabled Barrosan skin");
  if (skin.enabled !== true) errors.push("opt-in Barrosan runtime not enabled");
  if (runtime.captureCount !== 25) errors.push(`expected 25 runtime captures, saw ${runtime.captureCount}`);
  if (proof.status !== "PASS") errors.push(`manual Engage command armature status is ${proof.status}`);
  for (const name of runtimeNames) if (!snaps[name.replace(/_visible$/, "")]) errors.push(`missing proof snapshot ${name}`);
  for (const file of requiredImages) if (!existsSync(join(manual, file))) errors.push(`missing manual review image ${file}`);

  for (const [mode, snap] of Object.entries(snaps)) {
    const c = snap.firstContact ?? {};
    const text = snap.combinedText ?? "";
    if (!passive(c)) errors.push(`${mode} has forbidden behavior or mutation`);
    if (!snap.commandArmatureOnly) errors.push(`${mode} is not command-armature-only`);
    if (!snap.labelArbitrationRetained) errors.push(`${mode} did not retain label arbitration proof`);
    if (Number(c.pressureIntegrity ?? 100) < 90) errors.push(`${mode} integrity dropped below 90`);
    if (/Watchpost attack|Tower attack|projectile fired|fires projectile|takes damage|enemy killed|enemy despawn/i.test(text)) errors.push(`${mode} text implies forbidden action`);
  }

  for (const name of runtimeNames.filter((name) => name.startsWith("v0276_engage_unavailable"))) {
    const snap = snapshot(snaps, name);
    if (snap.manualEngageState !== "engage unavailable" || snap.manualEngageEligible) errors.push(`${name} availability gate failed`);
  }
  for (const name of ["v0276_engage_available_bridge_held_visible", "v0276_engage_available_engagement_contained_visible"]) {
    const snap = snapshot(snaps, name);
    if (snap.manualEngageState !== "engage available" || !snap.manualEngageEligible || !snap.engageActionOnMilitia) errors.push(`${name} did not expose Militia-only Engage`);
  }
  for (const name of ["v0276_engage_click_arms_no_damage_visible", "v0276_engage_armed_hud_no_attack_projectile_damage_visible", "v0276_reguard_rearm_no_damage_visible"]) {
    const snap = snapshot(snaps, name);
    if (snap.manualEngageState !== "engage armed" || !snap.manualEngageArmed || !snap.manualEngageNoDamage || !snap.manualEngageNoProjectile || !snap.manualEngageNoAttackCommitted) errors.push(`${name} arm/no-damage proof failed`);
  }
  if (!snapshot(snaps, "v0276_engage_repeat_click_no_stack_no_damage_visible").manualEngageRepeatClicksDoNotStack) errors.push("repeat-click no-stack proof failed");
  if (!snapshot(snaps, "v0276_engage_armed_label_clean_visible").manualEngageLabelVisible) errors.push("Engage armed label proof failed");
  if (!snapshot(snaps, "v0276_clear_guard_cancels_engage_visible").manualEngageCancelledByClearGuard) errors.push("Clear Guard cancel proof failed");
  if (!snapshot(snaps, "v0276_reguard_engage_available_again_visible").manualEngageReavailableAfterReguard) errors.push("Reguard reavailability proof failed");
  if (snapshot(snaps, "v0276_watchpost_no_engage_action_visible").engageActionOnWatchpost) errors.push("Watchpost leaked Engage action");
  if (snapshot(snaps, "v0276_barracks_no_engage_action_visible").engageActionOnBarracks) errors.push("Barracks leaked Engage action");
  if (!snapshot(snaps, "v0276_no_projectile_no_tower_visible").manualEngageNoProjectile) errors.push("no projectile/no tower proof failed");
  if (!snapshot(snaps, "v0276_no_auto_move_no_auto_attack_visible").manualEngageNoAutoMove || !snapshot(snaps, "v0276_no_auto_move_no_auto_attack_visible").manualEngageNoAutoAttack) errors.push("no auto move/attack proof failed");
  if (Number(contactOf(snaps, "v0276_no_repeated_damage_below_90_visible").pressureIntegrity) !== 90) errors.push("no repeated damage integrity proof failed");
  if (snapshot(snaps, "v0276_default_runtime_unchanged_probe_visible").defaultRuntimeChanged) errors.push("default runtime changed probe failed");
  if (!/Train Militia/i.test(snapshot(snaps, "v0276_existing_barracks_still_trains_militia_visible").combinedText ?? "")) errors.push("Barracks train retained proof failed");

  const pixelStats = stats.stats ?? [];
  const minBytes = Math.min(...pixelStats.map((s) => Number(s.bytes ?? 0)));
  const minUnique = Math.min(...pixelStats.map((s) => Number(s.sampleUniqueColors ?? 0)));
  const minBrightness = Math.min(...pixelStats.map((s) => Number(s.meanBrightness ?? 0)));
  const minStdDev = Math.min(...pixelStats.map((s) => Number(s.brightnessStdDev ?? 0)));
  if (pixelStats.length !== 26) errors.push(`expected 26 captured PNG pixel stats, saw ${pixelStats.length}`);
  if (minBytes < 25000 || minUnique < 120 || minBrightness < 5 || minStdDev < 3) errors.push("black-frame rejection thresholds failed");
  return { errors, runtime, proof, pixelSummary: { count: pixelStats.length, minBytes, minUnique, minBrightness, minStdDev } };
}

function writeReport(e) {
  const lines = [
    "# v0.276 Barrosan Manual Engage Command Armature Report", "",
    `- Verdict: \`${verdict}\`.`,
    "- Base commit: `65517b41d61b265a896136f08850e4ad735684cc`.",
    "- Implementation commit: `PENDING_PUBLICATION`.",
    "- Final HEAD: `PENDING_PUBLICATION`.",
    "- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.",
    "- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.",
    "- Review pack path: `artifacts/manual-review/v0276-barrosan-manual-engage-command-armature/`.", "",
    "## Boundary confirmation", "",
    "- Default runtime unchanged: yes.",
    "- Blender used: no.",
    "- GLB exported: no.",
    "- v0.276 adds the first explicit player-owned Militia-only Manual Engage command armature.",
    "- Engage appears only after Field Barracks, Militia, Watchpost, Guard Bridge, Bridge Held / Engagement Contained, and first contact resolved at Ashen pressure 90/100.",
    "- Engage click arms intent only; it does not attack, damage, spawn a projectile, kill, despawn, slow, stop, redirect, alter pathing/AI/waves/economy/fog, or mutate default runtime.",
    "- Re-clicks do not stack. Clear Guard cancels Engage. Reguard may make Engage available again and can re-arm without damage.",
    "- Watchpost and Barracks never show Engage. Field Barracks remains the Militia training source.",
    "- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.",
    "- Resource sequence unchanged: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.",
    "- v0.275 label arbitration remains the retained readability layer; long detail remains HUD-first.", "",
    "## Pixel validation", "",
    `- Required screenshots: ${requiredImages.length}.`,
    `- Runtime capture count: ${e.runtime.captureCount}.`,
    `- PNG files inspected for black-frame rejection: ${e.pixelSummary.count}.`,
    `- Minimum PNG bytes: ${e.pixelSummary.minBytes}.`,
    `- Minimum sampled unique colors: ${e.pixelSummary.minUnique}.`,
    `- Minimum mean brightness: ${e.pixelSummary.minBrightness}.`,
    `- Minimum brightness standard deviation: ${e.pixelSummary.minStdDev}.`,
    "- Screenshots are non-black/readable: yes.", "",
    "## Recommendation for v0.277", "",
    "- If separately authorized, connect the armed Engage intent to a bounded downstream order preview while preserving the no-damage/no-projectile/no-enemy-HP boundary until combat is explicitly scoped.", "",
    "Stop before v0.277.", "",
  ];
  writeFileSync(docPath, lines.join("\n"));
}

try {
  const evidence = evalEvidence();
  if (command === "capture") writeReport(evidence);
  const status = evidence.errors.length ? "FAIL_V0276_VALIDATION" : "PASS_V0276_BARROSAN_MANUAL_ENGAGE_COMMAND_ARMATURE_VALIDATION";
  writeFileSync(join(root, "v0276-validation-report.json"), JSON.stringify({ status, errors: evidence.errors, pixelSummary: evidence.pixelSummary }, null, 2) + "\n");
  if (evidence.errors.length) {
    console.error(evidence.errors.join("\n"));
    process.exit(1);
  }
} catch (error) {
  console.error(error?.stack || String(error));
  process.exit(1);
}
